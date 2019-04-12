SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pExportJob#Verify]
	 @RowCount                int                  = null output						-- count of records processed
	,@RuleCount               tinyint              = null output						-- count of business rules enforced on the table
	,@ErrorCount              int                  = null output						-- count of errors encountered
	,@ReturnSelect            bit                  = 0											-- when 1 output values are returned as a dataset
as
/*********************************************************************************************************************************
Sproc    : Business Rule Verification for sf.ExportJob
Notice   : Copyright © 2012 Softworks Group Inc.
Summary  : checks sf.ExportJob for current business rules and logs errors encountered into sf.BusinessRuleError
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pCheckFcnGen | Designer: Tim Edlund
Version   : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to verify that data in the sf.ExportJob table meets the business rules currently in effect for it.
This is a batch operation that calls the verification function, sf.fExportJob#Check(), on each row. If an error is
detected it is logged to the sf.BusinessRuleError table for review in the UI and follow-up.  The verification function is the same
one used for online checking through a table check constraint.  The procedure leaves the table with the check constraint enabled,
however, if errors were encountered the constraint is enabled with the NOCHECK option.

The SGI standard for enforcing business rules, except those that apply only on DELETE, is to use a check constraint.  A single
check constraint is implemented on each table. The one constraint checks all business rules by calling a function and passing
it all columns in the table. This procedure calls that same function but using SELECT syntax to check for errors.  Note that even
where the constraint was enabled with the "CHECK" option, the need for batch checking still exists.  The reason is that optional
business rules can be turned on and off through the UI.  The check function is designed so that it only applies rules which have
an active status. When rule settings are changed therefore the table data needs to be re-verified because additional rules may
now be active.

The procedure verifies the data according to the following algorithm. First, it removes and then attempts to re-apply a table
constraint using the CHECK option (the default).  Since the constraint references the check function and all rows are evaluated
before the constraint is applied with the CHECK option. If the process succeeds all rows are valid and processing is complete.

If an error is encountered on the attempt to apply the constraint using CHECK, then the procedure calls the function using SELECT
syntax on each row. Any errors encountered are swallowed and logged into the sf.BusinessRuleError table for review in the
UI and correction.  The row-by-agonizing-row (RBAR) method is required so that logging of errors by individual rows can be
achieved. When the process completes the check constraint is enabled, but this time using the NOCHECK option since errors are
known to exist. The constraint ensures that no future edits or additions to the table's rows will be accepted unless they are
valid.

Any previous errors logged for the table are removed before the process begins (using either method).

The procedure sets the status of each business rule record (sf.BusinessRule) to in-process while the procedure is executing.  This
status is reflected in the UI for monitoring.  Note also that the procedure ensures any mandatory business rules are enabled before
the process begins.  This is done to protect against situations where a developer forgot to re-enable rules after a data loading
or conversion task.

Example:

	exec sf.pExportJob#Verify
		@ReturnSelect = 1

select * from sf.vBusinessRule      where ApplicationEntitySCD = 'sf.ExportJob'
select * from sf.vBusinessRuleError where ApplicationEntitySCD = 'sf.ExportJob'

-------------------------------------------------------------------------------------------------------------------------------- */

begin
	set nocount on

	declare
		 @errorNo                           int = 0														-- 0 no error, <50000 SQL error, else business rule
		,@errorText                         nvarchar(4000)										-- message text (for business rule errors)
		,@i                                 int																-- loop index
		,@j                                 int																-- string position index
		,@nextSID                           int																-- next row PK value to process
		,@nextGUID                          uniqueidentifier									-- next row GUID value - applied to error log
		,@isValid                           bit																-- return value from check function call
		,@systemUser                        nvarchar(75)											-- for audit details recorded on error log
		,@runRBAR                           bit  = 0													-- tracks if "row-by-agonizing-row" process is needed
		,@messageSCD                        varchar(75)												-- message code as found in sf.Message
		,@messageText                       nvarchar(1000)										-- default text to add for new sf.Message records
		,@errorSeverity                     int																-- severity: 16 user, 17 configuration, 18 program
		,@columnNames                       xml																-- column name or column name list returned FOR XML
		,@applicationEntitySID              int																-- id of table in sf.ApplicationEntity - for logging
		,@newBusinessRuleSID                int																-- id for new business rule records added during verification
		,@columnName											  nvarchar(128)											-- column name rule applies to if check is duplicated

	declare
		@work                               table
		(
			 ID             int               identity(1,1)
			,RowSID         int               not null
			,RowGUID        uniqueidentifier  not null
		)

	set @RowCount   = 0																											-- ensure output values are initialized in all code paths
	set @RuleCount  = 0
	set @ErrorCount = 0

	begin try

		-- remove previous error log records for this table - set audit
		-- information for CDC tracking via update before making deletion

		set @systemUser = isnull(left(sf.fConfigParam#Value('SystemUser'),75), sf.fApplicationUserSession#UserName())

		begin transaction

		update
			sf.BusinessRuleError
		set
			 IsDeleted  = 1
			,UpdateUser = @systemUser
			,UpdateTime = sysdatetimeoffset()
		where
			BusinessRuleErrorSID
		in
			(
			select
				bre.BusinessRuleErrorSID
			from
				sf.vBusinessRuleError bre
			where
				bre.ApplicationEntitySCD = 'sf.ExportJob'													-- the application entity SCD is the schema + table name
			)

		delete
			sf.BusinessRuleError
		where
			BusinessRuleErrorSID
		in
			(
			select
				bre.BusinessRuleErrorSID
			from
				sf.vBusinessRuleError bre
			where
				bre.ApplicationEntitySCD = 'sf.ExportJob'
			)

		if @@rowcount > 0 and (select count(1) from sf.BusinessRuleError) = 0	-- if content was deleted and no rows remain, reset identity
		begin
			dbcc checkident('sf.BusinessRuleError',reseed, 1000000) with NO_INFOMSGS
		end

		commit

		-- ensure all mandatory rules for the table are enabled

		update
			br
		set
			 BusinessRuleStatus = 'p'
			,UpdateUser          = @systemUser
			,UpdateTime          = sysdatetimeoffset()
		from
			sf.BusinessRule  br
		join
			sf.vBusinessRule#Ext brx on br.BusinessRuleSID = brx.BusinessRuleSID
		where
			brx.ApplicationEntitySCD = 'sf.ExportJob'
		and
			brx.IsMandatory = 1
		and
			br.BusinessRuleStatus = 'x'

		-- mark the active rules for the table as in process (!) to support monitoring

		update
			br
		set
			 BusinessRuleStatus = '!'
			,UpdateTime          = sysdatetimeoffset()													-- do not change UpdateUser so that person turning on rule remains
		from
			sf.BusinessRule br
		join
			sf.vBusinessRule#Ext brx on br.BusinessRuleSID = brx.BusinessRuleSID
		where
			brx.ApplicationEntitySCD = 'sf.ExportJob'
		and
			br.BusinessRuleStatus <> 'x'

		-- method 1 - drop the check constraint if it exists and then re-apply it

		if exists
		(
		select
			1
		from
			sf.vCheckConstraint cc
		where
			cc.SchemaName = 'sf'
		and
			cc.ConstraintName = 'ck_ExportJob'
		)
		begin
			exec sp_executesql N'alter table sf.ExportJob drop constraint ck_ExportJob'										-- drop via dynamic SQL to avoid reference errors in VS project
		end

		-- trap error so that RBAR processing can be executed if any rows are not valid

		begin try

			alter table sf.ExportJob with CHECK add constraint ck_ExportJob
			check
				(
				sf.fExportJob#Check
					(
					 ExportJobSID
					,ExportJobName
					,ExportJobCode
					,FileFormatSID
					,JobScheduleSID
					,LastExecuteTime
					,LastExecuteUser
					,ExecuteCount
					,ExportJobXID
					,LegacyKey
					,IsDeleted
					,CreateUser
					,CreateTime
					,UpdateUser
					,UpdateTime
					,RowGUID
					) = 1
				)

			select @RowCount = count(1) from sf.ExportJob												-- rules validated - calculate row count to return

		end try

		begin catch

			set @errorText       = error_message()
			set @errorSeverity   = error_severity()

			if @errorText like N'%<err>%</err>%'																-- business rule violation raised via check constraint
			begin
				set @runRBAR = 1
			end
			else
			begin
				exec @errorNo = sf.pErrorRethrow																	-- unexpected error - rethrow it
			end

		end catch

		-- method 2 - only applied if constraint could not be enabled above

		if @runRBAR = 1
		begin

			select
				@applicationEntitySID = ae.ApplicationEntitySID										-- obtain application entity pk for logging
			from
				sf.vApplicationEntity ae
			where
				ae.BaseTableSchemaName = 'sf'
			and
				ae.BaseTableName       = 'ExportJob'

			insert
				@work																															-- load a work table with pk values to process
			select
				 x.ExportJobSID
				,x.RowGUID
			from
				sf.ExportJob x
			order by
				x.ExportJobSID

			set @RowCount    = @@rowcount
			set @ErrorCount = 0
			set @i          = 0

			while @i < @RowCount																								-- check rules for each row
			begin

				set @i += 1

				select
					 @nextSID   = w.RowSID
					,@nextGUID  = w.RowGUID
				from
					@work w
				where
					ID = @i

				-- call the function on the row and trap any errors with an inner catch block
				-- report the error and continue processing

				begin try

					select
						@isValid = sf.fExportJob#Check
							(
							 x.ExportJobSID
							,x.ExportJobName
							,x.ExportJobCode
							,x.FileFormatSID
							,x.JobScheduleSID
							,x.LastExecuteTime
							,x.LastExecuteUser
							,x.ExecuteCount
							,x.ExportJobXID
							,x.LegacyKey
							,x.IsDeleted
							,x.CreateUser
							,x.CreateTime
							,x.UpdateUser
							,x.UpdateTime
							,x.RowGUID
							)
					from
						sf.ExportJob  x
					where
						x.ExportJobSID = @nextSID

				end try

				begin catch

					set @errorText       = error_message()
					set @errorSeverity   = error_severity()

					if @errorText like N'%<err>%</err>%'														-- business rule violation raised via check constraint
					begin

						set @ErrorCount      += 1

						exec sf.pErrorRethrow$Check																		-- call subroutine from the error processor to parse the error text
							 @MessageSCD      = @messageSCD       output
							,@MessageText     = @errorText        output
							,@ErrorSeverity   = @errorSeverity    output
							,@ColumnNames     = @columnNames      output
							,@RowSID          = @nextSID          output

						if @nextSID is not null																				-- add PK value onto end of message text
						begin
							set @errorText = convert(nvarchar(1900), @errorText + N' [SID=' + convert(varchar(10), @nextSID) + ']')
						end

						-- before logging the error, ensure a business rule parent record exists

						set @newBusinessRuleSID = null

						-- if a column name is included with the message code, strip it out; it must
						-- appear as the ending segment

						set @columnName = replace(@messageSCD, 'MBR.', '')

						if @columnName like N'%.%'
						begin
							set @columnName = sf.fObjectName(@columnName)
							set @messageSCD = replace(@messageSCD, '.' + @columnName, '')
						end
						else
						begin
							set @columnName = null
						end

						select																												-- lookup the rule based on code, entity and column
							@newBusinessRuleSID = br.BusinessRuleSID
						from
							sf.vBusinessRule br
						where
							br.ApplicationEntitySID = @applicationEntitySID
						and
							br.MessageSCD = @messageSCD
						and
							br.ColumnName = @columnName

						if @newBusinessRuleSID is null																-- if a rule is not found, insert it
						begin

							set @messageText = cast(@errorText as nvarchar(1000))

							exec sf.pBusinessRule#Insert
								 @BusinessRuleSID       = @newBusinessRuleSID output
								,@MessageSCD            = @messageSCD
								,@ColumnName            = @columnName
								,@MessageText           = @messageText
								,@CreateUser            = @systemUser
								,@ApplicationEntitySID  = @applicationEntitySID

						end

						exec sf.pBusinessRuleError#Insert															-- log the error
							 @BusinessRuleSID       = @newBusinessRuleSID
							,@MessageSCD            = @messageSCD
							,@MessageText           = @errorText
							,@SourceSID             = @nextSID
							,@SourceGUID            = @nextGUID
							,@CreateUser            = @systemUser
							,@ApplicationEntitySID  = @applicationEntitySID

					end
					else
					begin
						exec @errorNo = sf.pErrorRethrow															-- unexpected error - rethrow it
					end

				end catch

			end																																	-- end loop

			-- turn on the constraint using NOCHECK to ensure any records
			-- or edited going forward are valid

			alter table sf.ExportJob with NOCHECK add constraint ck_ExportJob
			check
				(
				sf.fExportJob#Check
					(
					 ExportJobSID
					,ExportJobName
					,ExportJobCode
					,FileFormatSID
					,JobScheduleSID
					,LastExecuteTime
					,LastExecuteUser
					,ExecuteCount
					,ExportJobXID
					,LegacyKey
					,IsDeleted
					,CreateUser
					,CreateTime
					,UpdateUser
					,UpdateTime
					,RowGUID
					) = 1
				)

		end																																		-- end @runRBAR = 1

		-- get count of rules being applied on this table

		select
			 @RuleCount = isnull(count(1),0)
		from
			sf.vBusinessRule br
		where
			br.ApplicationEntitySCD = 'sf.ExportJob'
		and
			br.BusinessRuleStatus <> 'x'

		-- finally update the rule status to ON wherever the status was set to in-process

		update
			br
		set
			 BusinessRuleStatus = 'o'
			,UpdateTime          = sysdatetimeoffset()
		from
			sf.BusinessRule br
		join
			sf.vBusinessRule#Ext brx on br.BusinessRuleSID = brx.BusinessRuleSID
		where
			brx.ApplicationEntitySCD = 'sf.ExportJob'
		and
			br.BusinessRuleStatus = '!'

		if @ReturnSelect = 1
		begin

			select
				 @RowCount    [RowCount]
				,@RuleCount    RuleCount
				,@ErrorCount   ErrorCount

		end

	end try

	begin catch

		-- on a general failure, reset the rule status back to pending

		update
			br
		set
			 BusinessRuleStatus = 'p'
			,UpdateTime          = sysdatetimeoffset()
		from
			sf.BusinessRule br
		join
			sf.vBusinessRule#Ext brx on br.BusinessRuleSID = brx.BusinessRuleSID
		where
			brx.ApplicationEntitySCD = 'sf.ExportJob'
		and
			br.BusinessRuleStatus = '!'

		-- then re-throw to caller

		exec @errorNo = sf.pErrorRethrow																			-- catch the error, rollback if pending, and re-throw
	end catch

	return(@errorNo)

end
GO
