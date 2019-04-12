SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pPerson#Merge$Move
	@PersonSIDFrom					int										-- key of the person chosen as the duplicate
 ,@PersonSIDTo						int										-- key of the person chosen as the merge target
 ,@ApplicationUserSIDFrom int										-- key of the application user chosen as duplicate
 ,@ApplicationUserSIDTo		int										-- key of the application user chosen as the merge target
 ,@RegistrantSIDFrom			int										-- key of the registrant chosen as duplicate
 ,@RegistrantSIDTo				int										-- key of the registrant chosen as the merge target
 ,@MergeSource						xml										-- document written to user-defined-column of target records to trace source merge keys
 ,@ChangeLog							nvarchar(max) output	-- text value summarizing changes made
 ,@DebugLevel							int										-- when > 0 additional output is sent to the console to trace progress and performance
as
/*********************************************************************************************************************************
Sproc    : Person - Merge$Move
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : This procedure updates top-level foreign keys to move records from one person to another
----------------------------------------------------------------------------------------------------------------------------------
History		: Author								| Month Year	| Change Summary
					: --------------------- + ----------- + --------------------------------------------------------------------------------
					: Tim Edlund						| May 2018		|	Initial version
					: Tim Edlund						| Jul 2018		| Revised delete check for deletion paths. Added trx savepoints.

Comments	
--------
This is a subroutine of pPerson#Merge responsible for moving records from one set of parent keys to another through update
statements. The procedure does not call EF #Update sprocs in order to minimize impacts of secondary updates and business
rules when performing the move action.

When running merges it is possible the source PersonSID (the "from" key) will not have any associated sf.ApplicationUser
and/or dbo.Registrant record. When this occurs the FromSID parameters will be null.  No special branching is used in 
this procedure to handle that scenario since the update statements will not find rows when these key values are NULL.

The subroutine updates the @ChangeLog parameter with details of records updated. The log text is only updated when at
least 1 row is affected by the statement. This parameter is then returned to the caller for display. 

The procedure updates the User-Defined-Column of the target record with the @MergeSource parameter document. Note that
the update to the column is only made where the User-Defined-Column is NULL. 

The code included in this procedure can be initially generated through automation. Use the "GenPersonMerge.sql" utility
script in the Alinity DB project to generate the template code including overrides of the WHERE clause to handle
business rules. 

LIMITATIONS
-----------
The routine creates a unique save point in advance of each update statement and rolls back to that save point
when an error is detected.  Note however, that not all errors can be recovered from and when the xact_state = -1
the transaction can neither be committed or rolled back. This will occur when a business rule violation from a
check constraint is violated by the update.  Special handling logic to avoid the violation in the sub-query
WHERE clause in the update statement is required. 

Example
-------
Test this procedure through the parent using "Preview" mode to avoid committing transactions. 
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo					 int							 = 0																			-- 0 no error, <50000 SQL error, else business rule
	 ,@brError					 nvarchar(1000)																							-- buffer for business rule errors
	 ,@CRLF							 nchar(2)					 = char(13) + char(10)										-- constant for carriage return + line feed pair
	 ,@TAB							 nchar(2)					 = N'  '																	-- constant for tab character
	 ,@ON								 bit							 = cast(1 as bit)													-- constant for bit comparisons = 1
	 ,@serverTime				 datetimeoffset(7) = sysdatetimeoffset()										-- time at server to set for update time on affected records
	 ,@updateUser				 nvarchar(75)			 = sf.fApplicationUserSession#UserName()	-- application user performing the merge
	 ,@rowsAffected			 int																												-- tracks rows affected by each update statement
	 ,@totalRowsAffected int							 = 0																			-- tracks total count of rows updated
	 ,@messageSCD				 varchar(128)																								-- message code as found in sf.Message
	 ,@errorSeverity		 int																												-- severity: 16 user, 17 configuration, 18 program 
	 ,@columnNames			 xml																												-- column list on which business rule error occurred
	 ,@rowSID						 int																												-- primary key value on row where error occurred

	 ,@timeCheck				 datetimeoffset(7) = sysdatetimeoffset();										-- timing mark trace value for debug output

	if @DebugLevel > 1
	begin

		exec sf.pDebugPrint
			@DebugString = N'Initiating updates'
		 ,@TimeCheck = @timeCheck output;

	end;

	set @ChangeLog += @CRLF + @CRLF;
	set @ChangeLog += 'Records Moved';

	/****************************************************************************************************
UPDATE STATEMENTS
Use these statement in: dbo.pPerson#Merge$Move
*****************************************************************************************************/

	-- Registrant App Review

	begin try
		save transaction trx1;

		update
			dbo.RegistrantAppReview
		set
			PersonSID = @PersonSIDTo
		 ,UpdateTime = @serverTime
		 ,UpdateUser = @updateUser
		 ,UserDefinedColumns = isnull(UserDefinedColumns, @MergeSource)
		where
			PersonSID = @PersonSIDFrom; -- assign records from old account

		set @rowsAffected = @@rowcount;
		set @totalRowsAffected += @rowsAffected;

		if @rowsAffected > 0
		begin
			set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + ' Registrant App Review record(s) moved';
		end;

	end try
	begin catch

		if xact_state() = 1
		begin
			set @ChangeLog += @CRLF + @TAB + '0 Registrant App Review record(s) moved. Duplicate(s) would be created.';
			rollback transaction trx1; -- rollback to save point
		end;
		else if xact_state() = -1
		begin
			set @brError = error_message();

			if @brError like N'%<err>%</err>%' -- business rule violation raised via check constraint 
			begin

				exec sf.pErrorRethrow$Check
					@MessageSCD = @messageSCD
				 ,@MessageText = @brError output	-- parse out the text from the XML
				 ,@ErrorSeverity = @errorSeverity
				 ,@ColumnNames = @columnNames
				 ,@RowSID = @rowSID;

			end;

			set @brError =
				N'*** ERROR: Unable to process move for dbo.RegistrantAppReview record(s) due to unhandled business rule violation.' + isnull(@brError, '');
			raiserror(@brError, 18, 1);
		end;

	end catch;

	-- Registrant Audit Review

	begin try
		save transaction trx2;

		update
			dbo.RegistrantAuditReview
		set
			PersonSID = @PersonSIDTo
		 ,UpdateTime = @serverTime
		 ,UpdateUser = @updateUser
		 ,UserDefinedColumns = isnull(UserDefinedColumns, @MergeSource)
		where
			PersonSID = @PersonSIDFrom; -- assign records from old account

		set @rowsAffected = @@rowcount;
		set @totalRowsAffected += @rowsAffected;

		if @rowsAffected > 0
		begin
			set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + ' Registrant Audit Review record(s) moved';
		end;

	end try
	begin catch

		if xact_state() = 1
		begin
			set @ChangeLog += @CRLF + @TAB + '0 Registrant Audit Review record(s) moved. Duplicate(s) would be created.';
			rollback transaction trx2; -- rollback to save point
		end;
		else if xact_state() = -1
		begin
			set @brError = error_message();

			if @brError like N'%<err>%</err>%' -- business rule violation raised via check constraint 
			begin

				exec sf.pErrorRethrow$Check
					@MessageSCD = @messageSCD
				 ,@MessageText = @brError output	-- parse out the text from the XML
				 ,@ErrorSeverity = @errorSeverity
				 ,@ColumnNames = @columnNames
				 ,@RowSID = @rowSID;

			end;

			set @brError =
				N'*** ERROR: Unable to process move for dbo.RegistrantAuditReview record(s) due to unhandled business rule violation.' + isnull(@brError, '');
			raiserror(@brError, 18, 1);
		end;

	end catch;

	-- Profile Update

	begin try
		save transaction trx4;

		update
			dbo.ProfileUpdate
		set
			PersonSID = @PersonSIDTo
		 ,UpdateTime = @serverTime
		 ,UpdateUser = @updateUser
		 ,UserDefinedColumns = isnull(UserDefinedColumns, @MergeSource)
		where
			PersonSID = @PersonSIDFrom; -- assign records from old account

		set @rowsAffected = @@rowcount;
		set @totalRowsAffected += @rowsAffected;

		if @rowsAffected > 0
		begin
			set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + ' Profile Update record(s) moved';
		end;

	end try
	begin catch

		if xact_state() = 1
		begin
			set @ChangeLog += @CRLF + @TAB + '0 Profile Update record(s) moved. Duplicate(s) would be created.';
			rollback transaction trx4; -- rollback to save point
		end;
		else if xact_state() = -1
		begin
			set @brError = error_message();

			if @brError like N'%<err>%</err>%' -- business rule violation raised via check constraint 
			begin

				exec sf.pErrorRethrow$Check
					@MessageSCD = @messageSCD
				 ,@MessageText = @brError output	-- parse out the text from the XML
				 ,@ErrorSeverity = @errorSeverity
				 ,@ColumnNames = @columnNames
				 ,@RowSID = @rowSID;

			end;

			set @brError = N'*** ERROR: Unable to process move for dbo.ProfileUpdate record(s) due to unhandled business rule violation.' + isnull(@brError, '');
			raiserror(@brError, 18, 1);
		end;

	end catch;

	-- Registrant Audit

	begin try
		save transaction trx5;

		update
			dbo.RegistrantAudit
		set
			RegistrantSID = @RegistrantSIDTo
		 ,UpdateTime = @serverTime
		 ,UpdateUser = @updateUser
		 ,UserDefinedColumns = isnull(UserDefinedColumns, @MergeSource)
		where
			RegistrantSID = @RegistrantSIDFrom; -- assign records from old account

		set @rowsAffected = @@rowcount;
		set @totalRowsAffected += @rowsAffected;

		if @rowsAffected > 0
		begin
			set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + ' Registrant Audit record(s) moved';
		end;

	end try
	begin catch

		if xact_state() = 1
		begin
			set @ChangeLog += @CRLF + @TAB + '0 Registrant Audit record(s) moved. Duplicate(s) would be created.';
			rollback transaction trx5; -- rollback to save point
		end;
		else if xact_state() = -1
		begin
			set @brError = error_message();

			if @brError like N'%<err>%</err>%' -- business rule violation raised via check constraint 
			begin

				exec sf.pErrorRethrow$Check
					@MessageSCD = @messageSCD
				 ,@MessageText = @brError output	-- parse out the text from the XML
				 ,@ErrorSeverity = @errorSeverity
				 ,@ColumnNames = @columnNames
				 ,@RowSID = @rowSID;

			end;

			set @brError = N'*** ERROR: Unable to process move for dbo.RegistrantAudit record(s) due to unhandled business rule violation.' + isnull(@brError, '');
			raiserror(@brError, 18, 1);
		end;

	end catch;

	-- Registrant Exam

	begin try
		save transaction trx6;

		update
			dbo.RegistrantExam
		set
			RegistrantSID = @RegistrantSIDTo
		 ,UpdateTime = @serverTime
		 ,UpdateUser = @updateUser
		 ,UserDefinedColumns = isnull(UserDefinedColumns, @MergeSource)
		where
			RegistrantSID = @RegistrantSIDFrom; -- assign records from old account

		set @rowsAffected = @@rowcount;
		set @totalRowsAffected += @rowsAffected;

		if @rowsAffected > 0
		begin
			set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + ' Registrant Exam record(s) moved';
		end;

	end try
	begin catch

		if xact_state() = 1
		begin
			set @ChangeLog += @CRLF + @TAB + '0 Registrant Exam record(s) moved. Duplicate(s) would be created.';
			rollback transaction trx6; -- rollback to save point
		end;
		else if xact_state() = -1
		begin
			set @brError = error_message();

			if @brError like N'%<err>%</err>%' -- business rule violation raised via check constraint 
			begin

				exec sf.pErrorRethrow$Check
					@MessageSCD = @messageSCD
				 ,@MessageText = @brError output	-- parse out the text from the XML
				 ,@ErrorSeverity = @errorSeverity
				 ,@ColumnNames = @columnNames
				 ,@RowSID = @rowSID;

			end;

			set @brError = N'*** ERROR: Unable to process move for dbo.RegistrantExam record(s) due to unhandled business rule violation.' + isnull(@brError, '');
			raiserror(@brError, 18, 1);
		end;

	end catch;

	-- Registrant Identifier

	begin try
		save transaction trx7;

		update
			dbo.RegistrantIdentifier
		set
			RegistrantSID = @RegistrantSIDTo
		 ,UpdateTime = @serverTime
		 ,UpdateUser = @updateUser
		 ,UserDefinedColumns = isnull(UserDefinedColumns, @MergeSource)
		where
			RegistrantSID = @RegistrantSIDFrom; -- assign records from old account

		set @rowsAffected = @@rowcount;
		set @totalRowsAffected += @rowsAffected;

		if @rowsAffected > 0
		begin
			set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + ' Registrant Identifier record(s) moved';
		end;

	end try
	begin catch

		if xact_state() = 1
		begin
			set @ChangeLog += @CRLF + @TAB + '0 Registrant Identifier record(s) moved. Duplicate(s) would be created.';
			rollback transaction trx7; -- rollback to save point
		end;
		else if xact_state() = -1
		begin
			set @brError = error_message();

			if @brError like N'%<err>%</err>%' -- business rule violation raised via check constraint 
			begin

				exec sf.pErrorRethrow$Check
					@MessageSCD = @messageSCD
				 ,@MessageText = @brError output	-- parse out the text from the XML
				 ,@ErrorSeverity = @errorSeverity
				 ,@ColumnNames = @columnNames
				 ,@RowSID = @rowSID;

			end;

			set @brError =
				N'*** ERROR: Unable to process move for dbo.RegistrantIdentifier record(s) due to unhandled business rule violation.' + isnull(@brError, '');
			raiserror(@brError, 18, 1);
		end;

	end catch;

	-- Registrant Learning Plan

	begin try
		save transaction trx8;

		update
			dbo.RegistrantLearningPlan
		set
			RegistrantSID = @RegistrantSIDTo
		 ,UpdateTime = @serverTime
		 ,UpdateUser = @updateUser
		 ,UserDefinedColumns = isnull(UserDefinedColumns, @MergeSource)
		where
			RegistrantSID = @RegistrantSIDFrom; -- assign records from old account

		set @rowsAffected = @@rowcount;
		set @totalRowsAffected += @rowsAffected;

		if @rowsAffected > 0
		begin
			set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + ' Registrant Learning Plan record(s) moved';
		end;

	end try
	begin catch

		if xact_state() = 1
		begin
			set @ChangeLog += @CRLF + @TAB + '0 Registrant Learning Plan record(s) moved. Duplicate(s) would be created.';
			rollback transaction trx8; -- rollback to save point
		end;
		else if xact_state() = -1
		begin
			set @brError = error_message();

			if @brError like N'%<err>%</err>%' -- business rule violation raised via check constraint 
			begin

				exec sf.pErrorRethrow$Check
					@MessageSCD = @messageSCD
				 ,@MessageText = @brError output	-- parse out the text from the XML
				 ,@ErrorSeverity = @errorSeverity
				 ,@ColumnNames = @columnNames
				 ,@RowSID = @rowSID;

			end;

			set @brError =
				N'*** ERROR: Unable to process move for dbo.RegistrantLearningPlan record(s) due to unhandled business rule violation.' + isnull(@brError, '');
			raiserror(@brError, 18, 1);
		end;

	end catch;

	-- Registration Profile

	begin try
		save transaction trx9;

		update
			dbo.RegistrationProfile
		set
			RegistrantSID = @RegistrantSIDTo
		 ,UpdateTime = @serverTime
		 ,UpdateUser = @updateUser
		 ,UserDefinedColumns = isnull(UserDefinedColumns, @MergeSource)
		where
			RegistrantSID = @RegistrantSIDFrom; -- assign records from old account

		set @rowsAffected = @@rowcount;
		set @totalRowsAffected += @rowsAffected;

		if @rowsAffected > 0
		begin
			set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + ' Registration Profile record(s) moved';
		end;

	end try
	begin catch

		if xact_state() = 1
		begin
			set @ChangeLog += @CRLF + @TAB + '0 Registration Profile record(s) moved. Duplicate(s) would be created.';
			rollback transaction trx9; -- rollback to save point
		end;
		else if xact_state() = -1
		begin
			set @brError = error_message();

			if @brError like N'%<err>%</err>%' -- business rule violation raised via check constraint 
			begin

				exec sf.pErrorRethrow$Check
					@MessageSCD = @messageSCD
				 ,@MessageText = @brError output	-- parse out the text from the XML
				 ,@ErrorSeverity = @errorSeverity
				 ,@ColumnNames = @columnNames
				 ,@RowSID = @rowSID;

			end;

			set @brError =
				N'*** ERROR: Unable to process move for dbo.RegistrationProfile record(s) due to unhandled business rule violation.' + isnull(@brError, '');
			raiserror(@brError, 18, 1);
		end;

	end catch;

	-- Task

	begin try
		save transaction trx10;

		update
			sf.Task
		set
			ApplicationUserSID = @ApplicationUserSIDTo
		 ,UpdateTime = @serverTime
		 ,UpdateUser = @updateUser
		 ,UserDefinedColumns = isnull(UserDefinedColumns, @MergeSource)
		where
			ApplicationUserSID = @ApplicationUserSIDFrom; -- assign records from old account

		set @rowsAffected = @@rowcount;
		set @totalRowsAffected += @rowsAffected;

		if @rowsAffected > 0
		begin
			set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + ' Task record(s) moved';
		end;

	end try
	begin catch

		if xact_state() = 1
		begin
			set @ChangeLog += @CRLF + @TAB + '0 Task record(s) moved. Duplicate(s) would be created.';
			rollback transaction trx10; -- rollback to save point
		end;
		else if xact_state() = -1
		begin
			set @brError = error_message();

			if @brError like N'%<err>%</err>%' -- business rule violation raised via check constraint 
			begin

				exec sf.pErrorRethrow$Check
					@MessageSCD = @messageSCD
				 ,@MessageText = @brError output	-- parse out the text from the XML
				 ,@ErrorSeverity = @errorSeverity
				 ,@ColumnNames = @columnNames
				 ,@RowSID = @rowSID;

			end;

			set @brError = N'*** ERROR: Unable to process move for sf.Task record(s) due to unhandled business rule violation.' + isnull(@brError, '');
			raiserror(@brError, 18, 1);
		end;

	end catch;

	-- Org Contact

	begin try
		save transaction trx11;

		update
			dbo.OrgContact
		set
			PersonSID = @PersonSIDTo
		 ,UpdateTime = @serverTime
		 ,UpdateUser = @updateUser
		 ,UserDefinedColumns = isnull(UserDefinedColumns, @MergeSource)
		where
			PersonSID = @PersonSIDFrom -- assign records from old account
			and not exists -- avoid assigning duplicates
		(
			select
				1
			from
				dbo.OrgContact x
			where
				x.PersonSID																																														= @PersonSIDTo
				and x.OrgSID																																													= OrgContact.OrgSID
				and sf.fIsDateOverlap(x.EffectiveTime, x.ExpiryTime, OrgContact.EffectiveTime, OrgContact.ExpiryTime) = @ON
		);

		set @rowsAffected = @@rowcount;
		set @totalRowsAffected += @rowsAffected;

		if @rowsAffected > 0
		begin
			set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + ' Org Contact record(s) moved';
		end;

	end try
	begin catch

		if xact_state() = 1
		begin
			set @ChangeLog += @CRLF + @TAB + '0 Org Contact record(s) moved. Duplicate(s) would be created.';
			rollback transaction trx11; -- rollback to save point
		end;
		else if xact_state() = -1
		begin
			set @brError = error_message();

			if @brError like N'%<err>%</err>%' -- business rule violation raised via check constraint 
			begin

				exec sf.pErrorRethrow$Check
					@MessageSCD = @messageSCD
				 ,@MessageText = @brError output	-- parse out the text from the XML
				 ,@ErrorSeverity = @errorSeverity
				 ,@ColumnNames = @columnNames
				 ,@RowSID = @rowSID;

			end;

			set @brError = N'*** ERROR: Unable to process move for dbo.OrgContact record(s) due to unhandled business rule violation.' + isnull(@brError, '');
			raiserror(@brError, 18, 1);
		end;

	end catch;

	-- Registrant Credential

	begin try
		save transaction trx12;

		update
			dbo.RegistrantCredential
		set
			RegistrantSID = @RegistrantSIDTo
		 ,UpdateTime = @serverTime
		 ,UpdateUser = @updateUser
		 ,UserDefinedColumns = isnull(UserDefinedColumns, @MergeSource)
		where
			RegistrantSID = @RegistrantSIDFrom; -- assign records from old account

		set @rowsAffected = @@rowcount;
		set @totalRowsAffected += @rowsAffected;

		if @rowsAffected > 0
		begin
			set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + ' Registrant Credential record(s) moved';
		end;

	end try
	begin catch

		if xact_state() = 1
		begin
			set @ChangeLog += @CRLF + @TAB + '0 Registrant Credential record(s) moved. Duplicate(s) would be created.';
			rollback transaction trx12; -- rollback to save point
		end;
		else if xact_state() = -1
		begin
			set @brError = error_message();

			if @brError like N'%<err>%</err>%' -- business rule violation raised via check constraint 
			begin

				exec sf.pErrorRethrow$Check
					@MessageSCD = @messageSCD
				 ,@MessageText = @brError output	-- parse out the text from the XML
				 ,@ErrorSeverity = @errorSeverity
				 ,@ColumnNames = @columnNames
				 ,@RowSID = @rowSID;

			end;

			set @brError =
				N'*** ERROR: Unable to process move for dbo.RegistrantCredential record(s) due to unhandled business rule violation.' + isnull(@brError, '');
			raiserror(@brError, 18, 1);
		end;

	end catch;

	-- Registrant Employment

	begin try
		save transaction trx13;

		update
			dbo.RegistrantEmployment
		set
			RegistrantSID = @RegistrantSIDTo
		 ,UpdateTime = @serverTime
		 ,UpdateUser = @updateUser
		 ,UserDefinedColumns = isnull(UserDefinedColumns, @MergeSource)
		where
			RegistrantSID = @RegistrantSIDFrom; -- assign records from old account

		set @rowsAffected = @@rowcount;
		set @totalRowsAffected += @rowsAffected;

		if @rowsAffected > 0
		begin
			set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + ' Registrant Employment record(s) moved';
		end;

	end try
	begin catch

		if xact_state() = 1
		begin
			set @ChangeLog += @CRLF + @TAB + '0 Registrant Employment record(s) moved. Duplicate(s) would be created.';
			rollback transaction trx13; -- rollback to save point
		end;
		else if xact_state() = -1
		begin
			set @brError = error_message();

			if @brError like N'%<err>%</err>%' -- business rule violation raised via check constraint 
			begin

				exec sf.pErrorRethrow$Check
					@MessageSCD = @messageSCD
				 ,@MessageText = @brError output	-- parse out the text from the XML
				 ,@ErrorSeverity = @errorSeverity
				 ,@ColumnNames = @columnNames
				 ,@RowSID = @rowSID;

			end;

			set @brError =
				N'*** ERROR: Unable to process move for dbo.RegistrantEmployment record(s) due to unhandled business rule violation.' + isnull(@brError, '');
			raiserror(@brError, 18, 1);
		end;

	end catch;

	-- Registration

	begin try
		save transaction trx15;

		update
			dbo.Registration
		set
			RegistrantSID = @RegistrantSIDTo
		 ,UpdateTime = @serverTime
		 ,UpdateUser = @updateUser
		 ,UserDefinedColumns = isnull(UserDefinedColumns, @MergeSource)
		where
			RegistrantSID = @RegistrantSIDFrom -- assign records from old account
			and not exists -- avoid assigning an overlap
		(
			select
				1
			from
				dbo.Registration x
			where
				x.RegistrantSID = @RegistrantSIDTo and sf.fIsDateOverlap(x.EffectiveTime, x.ExpiryTime, Registration.EffectiveTime, Registration.ExpiryTime) = @ON
		);

		set @rowsAffected = @@rowcount;
		set @totalRowsAffected += @rowsAffected;

		if @rowsAffected > 0
		begin
			set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + ' Registration record(s) moved';
		end;

	end try
	begin catch

		if xact_state() = 1
		begin
			set @ChangeLog += @CRLF + @TAB + '0 Registration record(s) moved. Duplicate(s) would be created.';
			rollback transaction trx15; -- rollback to save point
		end;
		else if xact_state() = -1
		begin
			set @brError = error_message();

			if @brError like N'%<err>%</err>%' -- business rule violation raised via check constraint 
			begin

				exec sf.pErrorRethrow$Check
					@MessageSCD = @messageSCD
				 ,@MessageText = @brError output	-- parse out the text from the XML
				 ,@ErrorSeverity = @errorSeverity
				 ,@ColumnNames = @columnNames
				 ,@RowSID = @rowSID;

			end;

			set @brError = N'*** ERROR: Unable to process move for dbo.Registration record(s) due to unhandled business rule violation.' + isnull(@brError, '');
			raiserror(@brError, 18, 1);
		end;

	end catch;

	-- Person Email Message

	begin try
		save transaction trx16;

		update
			sf.PersonEmailMessage
		set
			PersonSID = @PersonSIDTo
		 ,UpdateTime = @serverTime
		 ,UpdateUser = @updateUser
		 ,UserDefinedColumns = isnull(UserDefinedColumns, @MergeSource)
		where
			PersonSID = @PersonSIDFrom; -- assign records from old account

		set @rowsAffected = @@rowcount;
		set @totalRowsAffected += @rowsAffected;

		if @rowsAffected > 0
		begin
			set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + ' Person Email Message record(s) moved';
		end;

	end try
	begin catch

		if xact_state() = 1
		begin
			set @ChangeLog += @CRLF + @TAB + '0 Person Email Message record(s) moved. Duplicate(s) would be created.';
			rollback transaction trx16; -- rollback to save point
		end;
		else if xact_state() = -1
		begin
			set @brError = error_message();

			if @brError like N'%<err>%</err>%' -- business rule violation raised via check constraint 
			begin

				exec sf.pErrorRethrow$Check
					@MessageSCD = @messageSCD
				 ,@MessageText = @brError output	-- parse out the text from the XML
				 ,@ErrorSeverity = @errorSeverity
				 ,@ColumnNames = @columnNames
				 ,@RowSID = @rowSID;

			end;

			set @brError = N'*** ERROR: Unable to process move for sf.PersonEmailMessage record(s) due to unhandled business rule violation.' + isnull(@brError, '');
			raiserror(@brError, 18, 1);
		end;

	end catch;

	-- Person Group Member

	begin try
		save transaction trx17;

		update
			sf.PersonGroupMember
		set
			PersonSID = @PersonSIDTo
		 ,UpdateTime = @serverTime
		 ,UpdateUser = @updateUser
		 ,UserDefinedColumns = isnull(UserDefinedColumns, @MergeSource)
		where
			PersonSID = @PersonSIDFrom -- assign records from old account
			and not exists -- avoid assigning duplicates
		(
			select
				1
			from
				sf.PersonGroupMember x
			where
				x.PersonSID																																																					= @PersonSIDTo
				and x.PersonGroupSID																																																= PersonGroupMember.PersonGroupSID
				and sf.fIsDateOverlap(x.EffectiveTime, x.ExpiryTime, PersonGroupMember.EffectiveTime, PersonGroupMember.ExpiryTime) = @ON
		);

		set @rowsAffected = @@rowcount;
		set @totalRowsAffected += @rowsAffected;

		if @rowsAffected > 0
		begin
			set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + ' Person Group Member record(s) moved';
		end;

	end try
	begin catch

		if xact_state() = 1
		begin
			set @ChangeLog += @CRLF + @TAB + '0 Person Group Member record(s) moved. Duplicate(s) would be created.';
			rollback transaction trx17; -- rollback to save point
		end;
		else if xact_state() = -1
		begin
			set @brError = error_message();

			if @brError like N'%<err>%</err>%' -- business rule violation raised via check constraint 
			begin

				exec sf.pErrorRethrow$Check
					@MessageSCD = @messageSCD
				 ,@MessageText = @brError output	-- parse out the text from the XML
				 ,@ErrorSeverity = @errorSeverity
				 ,@ColumnNames = @columnNames
				 ,@RowSID = @rowSID;

			end;

			set @brError = N'*** ERROR: Unable to process move for sf.PersonGroupMember record(s) due to unhandled business rule violation.' + isnull(@brError, '');
			raiserror(@brError, 18, 1);
		end;

	end catch;

	-- Person Text Message

	begin try
		save transaction trx18;

		update
			sf.PersonTextMessage
		set
			PersonSID = @PersonSIDTo
		 ,UpdateTime = @serverTime
		 ,UpdateUser = @updateUser
		 ,UserDefinedColumns = isnull(UserDefinedColumns, @MergeSource)
		where
			PersonSID = @PersonSIDFrom; -- assign records from old account

		set @rowsAffected = @@rowcount;
		set @totalRowsAffected += @rowsAffected;

		if @rowsAffected > 0
		begin
			set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + ' Person Text Message record(s) moved';
		end;

	end try
	begin catch

		if xact_state() = 1
		begin
			set @ChangeLog += @CRLF + @TAB + '0 Person Text Message record(s) moved. Duplicate(s) would be created.';
			rollback transaction trx18; -- rollback to save point
		end;
		else if xact_state() = -1
		begin
			set @brError = error_message();

			if @brError like N'%<err>%</err>%' -- business rule violation raised via check constraint 
			begin

				exec sf.pErrorRethrow$Check
					@MessageSCD = @messageSCD
				 ,@MessageText = @brError output	-- parse out the text from the XML
				 ,@ErrorSeverity = @errorSeverity
				 ,@ColumnNames = @columnNames
				 ,@RowSID = @rowSID;

			end;

			set @brError = N'*** ERROR: Unable to process move for sf.PersonTextMessage record(s) due to unhandled business rule violation.' + isnull(@brError, '');
			raiserror(@brError, 18, 1);
		end;

	end catch;

	-- Task Queue Subscriber

	begin try
		save transaction trx19;

		update
			sf.TaskQueueSubscriber
		set
			ApplicationUserSID = @ApplicationUserSIDTo
		 ,UpdateTime = @serverTime
		 ,UpdateUser = @updateUser
		 ,UserDefinedColumns = isnull(UserDefinedColumns, @MergeSource)
		where
			ApplicationUserSID = @ApplicationUserSIDFrom -- assign records from old account
			and not exists -- avoid assigning duplicates
		(
			select
				1
			from
				sf.TaskQueueSubscriber x
			where
				x.ApplicationUserSID																																																		= @ApplicationUserSIDTo
				and x.TaskQueueSID																																																			= TaskQueueSubscriber.TaskQueueSID
				and sf.fIsDateOverlap(x.EffectiveTime, x.ExpiryTime, TaskQueueSubscriber.EffectiveTime, TaskQueueSubscriber.ExpiryTime) = @ON
		);

		set @rowsAffected = @@rowcount;
		set @totalRowsAffected += @rowsAffected;

		if @rowsAffected > 0
		begin
			set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + ' Task Queue Subscriber record(s) moved';
		end;

	end try
	begin catch

		if xact_state() = 1
		begin
			set @ChangeLog += @CRLF + @TAB + '0 Task Queue Subscriber record(s) moved. Duplicate(s) would be created.';
			rollback transaction trx19; -- rollback to save point
		end;
		else if xact_state() = -1
		begin
			set @brError = error_message();

			if @brError like N'%<err>%</err>%' -- business rule violation raised via check constraint 
			begin

				exec sf.pErrorRethrow$Check
					@MessageSCD = @messageSCD
				 ,@MessageText = @brError output	-- parse out the text from the XML
				 ,@ErrorSeverity = @errorSeverity
				 ,@ColumnNames = @columnNames
				 ,@RowSID = @rowSID;

			end;

			set @brError =
				N'*** ERROR: Unable to process move for sf.TaskQueueSubscriber record(s) due to unhandled business rule violation.' + isnull(@brError, '');
			raiserror(@brError, 18, 1);
		end;

	end catch;

	-- Task Trigger

	begin try
		save transaction trx20;

		update
			sf.TaskTrigger
		set
			ApplicationUserSID = @ApplicationUserSIDTo
		 ,UpdateTime = @serverTime
		 ,UpdateUser = @updateUser
		 ,UserDefinedColumns = isnull(UserDefinedColumns, @MergeSource)
		where
			ApplicationUserSID = @ApplicationUserSIDFrom; -- assign records from old account

		set @rowsAffected = @@rowcount;
		set @totalRowsAffected += @rowsAffected;

		if @rowsAffected > 0
		begin
			set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + ' Task Trigger record(s) moved';
		end;

	end try
	begin catch

		if xact_state() = 1
		begin
			set @ChangeLog += @CRLF + @TAB + '0 Task Trigger record(s) moved. Duplicate(s) would be created.';
			rollback transaction trx20; -- rollback to save point
		end;
		else if xact_state() = -1
		begin
			set @brError = error_message();

			if @brError like N'%<err>%</err>%' -- business rule violation raised via check constraint 
			begin

				exec sf.pErrorRethrow$Check
					@MessageSCD = @messageSCD
				 ,@MessageText = @brError output	-- parse out the text from the XML
				 ,@ErrorSeverity = @errorSeverity
				 ,@ColumnNames = @columnNames
				 ,@RowSID = @rowSID;

			end;

			set @brError = N'*** ERROR: Unable to process move for sf.TaskTrigger record(s) due to unhandled business rule violation.' + isnull(@brError, '');
			raiserror(@brError, 18, 1);
		end;

	end catch;

	-- Credential Profile

	begin try
		save transaction trx21;

		update
			stg.CredentialProfile
		set
			RegistrantSID = @RegistrantSIDTo
		 ,UpdateTime = @serverTime
		 ,UpdateUser = @updateUser
		 ,UserDefinedColumns = isnull(UserDefinedColumns, @MergeSource)
		where
			RegistrantSID = @RegistrantSIDFrom; -- assign records from old account

		set @rowsAffected = @@rowcount;
		set @totalRowsAffected += @rowsAffected;

		if @rowsAffected > 0
		begin
			set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + ' Credential Profile record(s) moved';
		end;

	end try
	begin catch

		if xact_state() = 1
		begin
			set @ChangeLog += @CRLF + @TAB + '0 Credential Profile record(s) moved. Duplicate(s) would be created.';
			rollback transaction trx21; -- rollback to save point
		end;
		else if xact_state() = -1
		begin
			set @brError = error_message();

			if @brError like N'%<err>%</err>%' -- business rule violation raised via check constraint 
			begin

				exec sf.pErrorRethrow$Check
					@MessageSCD = @messageSCD
				 ,@MessageText = @brError output	-- parse out the text from the XML
				 ,@ErrorSeverity = @errorSeverity
				 ,@ColumnNames = @columnNames
				 ,@RowSID = @rowSID;

			end;

			set @brError = N'*** ERROR: Unable to process move for stg.CredentialProfile record(s) due to unhandled business rule violation.' + isnull(@brError, '');
			raiserror(@brError, 18, 1);
		end;

	end catch;

	-- Person Profile

	begin try
		save transaction trx22;

		update
			stg.PersonProfile
		set
			RegistrantSID = @RegistrantSIDTo
		 ,UpdateTime = @serverTime
		 ,UpdateUser = @updateUser
		 ,UserDefinedColumns = isnull(UserDefinedColumns, @MergeSource)
		where
			RegistrantSID = @RegistrantSIDFrom; -- assign records from old account

		set @rowsAffected = @@rowcount;
		set @totalRowsAffected += @rowsAffected;

		if @rowsAffected > 0
		begin
			set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + ' Person Profile record(s) moved';
		end;

	end try
	begin catch

		if xact_state() = 1
		begin
			set @ChangeLog += @CRLF + @TAB + '0 Person Profile record(s) moved. Duplicate(s) would be created.';
			rollback transaction trx22; -- rollback to save point
		end;
		else if xact_state() = -1
		begin
			set @brError = error_message();

			if @brError like N'%<err>%</err>%' -- business rule violation raised via check constraint 
			begin

				exec sf.pErrorRethrow$Check
					@MessageSCD = @messageSCD
				 ,@MessageText = @brError output	-- parse out the text from the XML
				 ,@ErrorSeverity = @errorSeverity
				 ,@ColumnNames = @columnNames
				 ,@RowSID = @rowSID;

			end;

			set @brError = N'*** ERROR: Unable to process move for stg.PersonProfile record(s) due to unhandled business rule violation.' + isnull(@brError, '');
			raiserror(@brError, 18, 1);
		end;

	end catch;

	-- Person Profile

	begin try
		save transaction trx23;

		update
			stg.PersonProfile
		set
			ApplicationUserSID = @ApplicationUserSIDTo
		 ,UpdateTime = @serverTime
		 ,UpdateUser = @updateUser
		 ,UserDefinedColumns = isnull(UserDefinedColumns, @MergeSource)
		where
			ApplicationUserSID = @ApplicationUserSIDFrom; -- assign records from old account

		set @rowsAffected = @@rowcount;
		set @totalRowsAffected += @rowsAffected;

		if @rowsAffected > 0
		begin
			set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + ' Person Profile record(s) moved';
		end;

	end try
	begin catch

		if xact_state() = 1
		begin
			set @ChangeLog += @CRLF + @TAB + '0 Person Profile record(s) moved. Duplicate(s) would be created.';
			rollback transaction trx23; -- rollback to save point
		end;
		else if xact_state() = -1
		begin
			set @brError = error_message();

			if @brError like N'%<err>%</err>%' -- business rule violation raised via check constraint 
			begin

				exec sf.pErrorRethrow$Check
					@MessageSCD = @messageSCD
				 ,@MessageText = @brError output	-- parse out the text from the XML
				 ,@ErrorSeverity = @errorSeverity
				 ,@ColumnNames = @columnNames
				 ,@RowSID = @rowSID;

			end;

			set @brError = N'*** ERROR: Unable to process move for stg.PersonProfile record(s) due to unhandled business rule violation.' + isnull(@brError, '');
			raiserror(@brError, 18, 1);
		end;

	end catch;

	-- Person Profile

	begin try
		save transaction trx24;

		update
			stg.PersonProfile
		set
			PersonSID = @PersonSIDTo
		 ,UpdateTime = @serverTime
		 ,UpdateUser = @updateUser
		 ,UserDefinedColumns = isnull(UserDefinedColumns, @MergeSource)
		where
			PersonSID = @PersonSIDFrom; -- assign records from old account

		set @rowsAffected = @@rowcount;
		set @totalRowsAffected += @rowsAffected;

		if @rowsAffected > 0
		begin
			set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + ' Person Profile record(s) moved';
		end;

	end try
	begin catch

		if xact_state() = 1
		begin
			set @ChangeLog += @CRLF + @TAB + '0 Person Profile record(s) moved. Duplicate(s) would be created.';
			rollback transaction trx24; -- rollback to save point
		end;
		else if xact_state() = -1
		begin
			set @brError = error_message();

			if @brError like N'%<err>%</err>%' -- business rule violation raised via check constraint 
			begin

				exec sf.pErrorRethrow$Check
					@MessageSCD = @messageSCD
				 ,@MessageText = @brError output	-- parse out the text from the XML
				 ,@ErrorSeverity = @errorSeverity
				 ,@ColumnNames = @columnNames
				 ,@RowSID = @rowSID;

			end;

			set @brError = N'*** ERROR: Unable to process move for stg.PersonProfile record(s) due to unhandled business rule violation.' + isnull(@brError, '');
			raiserror(@brError, 18, 1);
		end;

	end catch;

	-- Person Mailing Address

	begin try
		save transaction trx25;

		update
			dbo.PersonMailingAddress
		set
			PersonSID = @PersonSIDTo
		 ,UpdateTime = @serverTime
		 ,UpdateUser = @updateUser
		 ,UserDefinedColumns = isnull(UserDefinedColumns, @MergeSource)
		where
			PersonSID = @PersonSIDFrom; -- assign records from old account

		set @rowsAffected = @@rowcount;
		set @totalRowsAffected += @rowsAffected;

		if @rowsAffected > 0
		begin
			set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + ' Person Mailing Address record(s) moved';
		end;

	end try
	begin catch

		if xact_state() = 1
		begin
			set @ChangeLog += @CRLF + @TAB + '0 Person Mailing Address record(s) moved. Duplicate(s) would be created.';
			rollback transaction trx25; -- rollback to save point
		end;
		else if xact_state() = -1
		begin
			set @brError = error_message();

			if @brError like N'%<err>%</err>%' -- business rule violation raised via check constraint 
			begin

				exec sf.pErrorRethrow$Check
					@MessageSCD = @messageSCD
				 ,@MessageText = @brError output	-- parse out the text from the XML
				 ,@ErrorSeverity = @errorSeverity
				 ,@ColumnNames = @columnNames
				 ,@RowSID = @rowSID;

			end;

			set @brError =
				N'*** ERROR: Unable to process move for dbo.PersonMailingAddress record(s) due to unhandled business rule violation.' + isnull(@brError, '');
			raiserror(@brError, 18, 1);
		end;

	end catch;

	-- Registrant Inactive Period

	begin try
		save transaction trx26;

		update
			dbo.RegistrantInactivePeriod
		set
			RegistrantSID = @RegistrantSIDTo
		 ,UpdateTime = @serverTime
		 ,UpdateUser = @updateUser
		 ,UserDefinedColumns = isnull(UserDefinedColumns, @MergeSource)
		where
			RegistrantSID = @RegistrantSIDFrom -- assign records from old account
			and not exists -- avoid assigning duplicates
		(
			select
				1
			from
				dbo.RegistrantInactivePeriod x
			where
				x.RegistrantSID																																																										= @RegistrantSIDTo
				and sf.fIsDateOverlap(x.EffectiveTime, x.ExpiryTime, RegistrantInactivePeriod.EffectiveTime, RegistrantInactivePeriod.ExpiryTime) = @ON
		);

		set @rowsAffected = @@rowcount;
		set @totalRowsAffected += @rowsAffected;

		if @rowsAffected > 0
		begin
			set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + ' Registrant Inactive Period record(s) moved';
		end;

	end try
	begin catch

		if xact_state() = 1
		begin
			set @ChangeLog += @CRLF + @TAB + '0 Registrant Inactive Period record(s) moved. Duplicate(s) would be created.';
			rollback transaction trx26; -- rollback to save point
		end;
		else if xact_state() = -1
		begin
			set @brError = error_message();

			if @brError like N'%<err>%</err>%' -- business rule violation raised via check constraint 
			begin

				exec sf.pErrorRethrow$Check
					@MessageSCD = @messageSCD
				 ,@MessageText = @brError output	-- parse out the text from the XML
				 ,@ErrorSeverity = @errorSeverity
				 ,@ColumnNames = @columnNames
				 ,@RowSID = @rowSID;

			end;

			set @brError =
				N'*** ERROR: Unable to process move for dbo.RegistrantInactivePeriod record(s) due to unhandled business rule violation.' + isnull(@brError, '');
			raiserror(@brError, 18, 1);
		end;

	end catch;

	-- Registrant Language

	begin try
		save transaction trx27;

		update
			dbo.RegistrantLanguage
		set
			RegistrantSID = @RegistrantSIDTo
		 ,UpdateTime = @serverTime
		 ,UpdateUser = @updateUser
		 ,UserDefinedColumns = isnull(UserDefinedColumns, @MergeSource)
		where
			RegistrantSID = @RegistrantSIDFrom; -- assign records from old account

		set @rowsAffected = @@rowcount;
		set @totalRowsAffected += @rowsAffected;

		if @rowsAffected > 0
		begin
			set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + ' Registrant Language record(s) moved';
		end;

	end try
	begin catch

		if xact_state() = 1
		begin
			set @ChangeLog += @CRLF + @TAB + '0 Registrant Language record(s) moved. Duplicate(s) would be created.';
			rollback transaction trx27; -- rollback to save point
		end;
		else if xact_state() = -1
		begin
			set @brError = error_message();

			if @brError like N'%<err>%</err>%' -- business rule violation raised via check constraint 
			begin

				exec sf.pErrorRethrow$Check
					@MessageSCD = @messageSCD
				 ,@MessageText = @brError output	-- parse out the text from the XML
				 ,@ErrorSeverity = @errorSeverity
				 ,@ColumnNames = @columnNames
				 ,@RowSID = @rowSID;

			end;

			set @brError =
				N'*** ERROR: Unable to process move for dbo.RegistrantLanguage record(s) due to unhandled business rule violation.' + isnull(@brError, '');
			raiserror(@brError, 18, 1);
		end;

	end catch;

	-- Registrant Practice

	begin try
		save transaction trx28;

		update
			dbo.RegistrantPractice
		set
			RegistrantSID = @RegistrantSIDTo
		 ,UpdateTime = @serverTime
		 ,UpdateUser = @updateUser
		 ,UserDefinedColumns = isnull(UserDefinedColumns, @MergeSource)
		where
			RegistrantSID = @RegistrantSIDFrom; -- assign records from old account

		set @rowsAffected = @@rowcount;
		set @totalRowsAffected += @rowsAffected;

		if @rowsAffected > 0
		begin
			set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + ' Registrant Practice record(s) moved';
		end;

	end try
	begin catch

		if xact_state() = 1
		begin
			set @ChangeLog += @CRLF + @TAB + '0 Registrant Practice record(s) moved. Duplicate(s) would be created.';
			rollback transaction trx28; -- rollback to save point
		end;
		else if xact_state() = -1
		begin
			set @brError = error_message();

			if @brError like N'%<err>%</err>%' -- business rule violation raised via check constraint 
			begin

				exec sf.pErrorRethrow$Check
					@MessageSCD = @messageSCD
				 ,@MessageText = @brError output	-- parse out the text from the XML
				 ,@ErrorSeverity = @errorSeverity
				 ,@ColumnNames = @columnNames
				 ,@RowSID = @rowSID;

			end;

			set @brError =
				N'*** ERROR: Unable to process move for dbo.RegistrantPractice record(s) due to unhandled business rule violation.' + isnull(@brError, '');
			raiserror(@brError, 18, 1);
		end;

	end catch;

	-- Registrant Practice Restriction

	begin try
		save transaction trx29;

		update
			dbo.RegistrantPracticeRestriction
		set
			RegistrantSID = @RegistrantSIDTo
		 ,UpdateTime = @serverTime
		 ,UpdateUser = @updateUser
		 ,UserDefinedColumns = isnull(UserDefinedColumns, @MergeSource)
		where
			RegistrantSID = @RegistrantSIDFrom -- assign records from old account
			and not exists -- avoid assigning duplicates
		(
			select
				1
			from
				dbo.RegistrantPracticeRestriction x
			where
				x.RegistrantSID																																																															= @RegistrantSIDTo
				and x.PracticeRestrictionSID																																																								= RegistrantPracticeRestriction.PracticeRestrictionSID
				and sf.fIsDateOverlap(x.EffectiveTime, x.ExpiryTime, RegistrantPracticeRestriction.EffectiveTime, RegistrantPracticeRestriction.ExpiryTime) = @ON
		);

		set @rowsAffected = @@rowcount;
		set @totalRowsAffected += @rowsAffected;

		if @rowsAffected > 0
		begin
			set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + ' Registrant Practice Restriction record(s) moved';
		end;

	end try
	begin catch

		if xact_state() = 1
		begin
			set @ChangeLog += @CRLF + @TAB + '0 Registrant Practice Restriction record(s) moved. Duplicate(s) would be created.';
			rollback transaction trx29; -- rollback to save point
		end;
		else if xact_state() = -1
		begin
			set @brError = error_message();

			if @brError like N'%<err>%</err>%' -- business rule violation raised via check constraint 
			begin

				exec sf.pErrorRethrow$Check
					@MessageSCD = @messageSCD
				 ,@MessageText = @brError output	-- parse out the text from the XML
				 ,@ErrorSeverity = @errorSeverity
				 ,@ColumnNames = @columnNames
				 ,@RowSID = @rowSID;

			end;

			set @brError =
				N'*** ERROR: Unable to process move for dbo.RegistrantPracticeRestriction record(s) due to unhandled business rule violation.' + isnull(@brError, '');
			raiserror(@brError, 18, 1);
		end;

	end catch;

	-- Application User Grant

	begin try
		save transaction trx30;

		update
			sf.ApplicationUserGrant
		set
			ApplicationUserSID = @ApplicationUserSIDTo
		 ,UpdateTime = @serverTime
		 ,UpdateUser = @updateUser
		 ,UserDefinedColumns = isnull(UserDefinedColumns, @MergeSource)
		where
			ApplicationUserSID = @ApplicationUserSIDFrom; -- assign records from old account

		set @rowsAffected = @@rowcount;
		set @totalRowsAffected += @rowsAffected;

		if @rowsAffected > 0
		begin
			set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + ' Application User Grant record(s) moved';
		end;

	end try
	begin catch

		if xact_state() = 1
		begin
			set @ChangeLog += @CRLF + @TAB + '0 Application User Grant record(s) moved. Duplicate(s) would be created.';
			rollback transaction trx30; -- rollback to save point
		end;
		else if xact_state() = -1
		begin
			set @brError = error_message();

			if @brError like N'%<err>%</err>%' -- business rule violation raised via check constraint 
			begin

				exec sf.pErrorRethrow$Check
					@MessageSCD = @messageSCD
				 ,@MessageText = @brError output	-- parse out the text from the XML
				 ,@ErrorSeverity = @errorSeverity
				 ,@ColumnNames = @columnNames
				 ,@RowSID = @rowSID;

			end;

			set @brError =
				N'*** ERROR: Unable to process move for sf.ApplicationUserGrant record(s) due to unhandled business rule violation.' + isnull(@brError, '');
			raiserror(@brError, 18, 1);
		end;

	end catch;

	-- Application User Profile Property

	begin try
		save transaction trx31;

		update
			sf.ApplicationUserProfileProperty
		set
			ApplicationUserSID = @ApplicationUserSIDTo
		 ,UpdateTime = @serverTime
		 ,UpdateUser = @updateUser
		 ,UserDefinedColumns = isnull(UserDefinedColumns, @MergeSource)
		where
			ApplicationUserSID = @ApplicationUserSIDFrom; -- assign records from old account

		set @rowsAffected = @@rowcount;
		set @totalRowsAffected += @rowsAffected;

		if @rowsAffected > 0
		begin
			set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + ' Application User Profile Property record(s) moved';
		end;

	end try
	begin catch

		if xact_state() = 1
		begin
			set @ChangeLog += @CRLF + @TAB + '0 Application User Profile Property record(s) moved. Duplicate(s) would be created.';
			rollback transaction trx31; -- rollback to save point
		end;
		else if xact_state() = -1
		begin
			set @brError = error_message();

			if @brError like N'%<err>%</err>%' -- business rule violation raised via check constraint 
			begin

				exec sf.pErrorRethrow$Check
					@MessageSCD = @messageSCD
				 ,@MessageText = @brError output	-- parse out the text from the XML
				 ,@ErrorSeverity = @errorSeverity
				 ,@ColumnNames = @columnNames
				 ,@RowSID = @rowSID;

			end;

			set @brError =
				N'*** ERROR: Unable to process move for sf.ApplicationUserProfileProperty record(s) due to unhandled business rule violation.' + isnull(@brError, '');
			raiserror(@brError, 18, 1);
		end;

	end catch;

	-- Application User Session

	begin try
		save transaction trx32;

		update
			sf.ApplicationUserSession
		set
			ApplicationUserSID = @ApplicationUserSIDTo
		 ,UpdateTime = @serverTime
		 ,UpdateUser = @updateUser
		 ,UserDefinedColumns = isnull(UserDefinedColumns, @MergeSource)
		where
			ApplicationUserSID = @ApplicationUserSIDFrom; -- assign records from old account

		set @rowsAffected = @@rowcount;
		set @totalRowsAffected += @rowsAffected;

		if @rowsAffected > 0
		begin
			set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + ' Application User Session record(s) moved';
		end;

	end try
	begin catch

		if xact_state() = 1
		begin
			set @ChangeLog += @CRLF + @TAB + '0 Application User Session record(s) moved. Duplicate(s) would be created.';
			rollback transaction trx32; -- rollback to save point
		end;
		else if xact_state() = -1
		begin
			set @brError = error_message();

			if @brError like N'%<err>%</err>%' -- business rule violation raised via check constraint 
			begin

				exec sf.pErrorRethrow$Check
					@MessageSCD = @messageSCD
				 ,@MessageText = @brError output	-- parse out the text from the XML
				 ,@ErrorSeverity = @errorSeverity
				 ,@ColumnNames = @columnNames
				 ,@RowSID = @rowSID;

			end;

			set @brError =
				N'*** ERROR: Unable to process move for sf.ApplicationUserSession record(s) due to unhandled business rule violation.' + isnull(@brError, '');
			raiserror(@brError, 18, 1);
		end;

	end catch;

	-- Cleared Announcement

	begin try
		save transaction trx33;

		update
			sf.ClearedAnnouncement
		set
			ApplicationUserSID = @ApplicationUserSIDTo
		 ,UpdateTime = @serverTime
		 ,UpdateUser = @updateUser
		 ,UserDefinedColumns = isnull(UserDefinedColumns, @MergeSource)
		where
			ApplicationUserSID = @ApplicationUserSIDFrom; -- assign records from old account

		set @rowsAffected = @@rowcount;
		set @totalRowsAffected += @rowsAffected;

		if @rowsAffected > 0
		begin
			set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + ' Cleared Announcement record(s) moved';
		end;

	end try
	begin catch

		if xact_state() = 1
		begin
			set @ChangeLog += @CRLF + @TAB + '0 Cleared Announcement record(s) moved. Duplicate(s) would be created.';
			rollback transaction trx33; -- rollback to save point
		end;
		else if xact_state() = -1
		begin
			set @brError = error_message();

			if @brError like N'%<err>%</err>%' -- business rule violation raised via check constraint 
			begin

				exec sf.pErrorRethrow$Check
					@MessageSCD = @messageSCD
				 ,@MessageText = @brError output	-- parse out the text from the XML
				 ,@ErrorSeverity = @errorSeverity
				 ,@ColumnNames = @columnNames
				 ,@RowSID = @rowSID;

			end;

			set @brError =
				N'*** ERROR: Unable to process move for sf.ClearedAnnouncement record(s) due to unhandled business rule violation.' + isnull(@brError, '');
			raiserror(@brError, 18, 1);
		end;

	end catch;

	-- Email Message

	begin try
		save transaction trx34;

		update
			sf.EmailMessage
		set
			ApplicationUserSID = @ApplicationUserSIDTo
		 ,UpdateTime = @serverTime
		 ,UpdateUser = @updateUser
		 ,UserDefinedColumns = isnull(UserDefinedColumns, @MergeSource)
		where
			ApplicationUserSID = @ApplicationUserSIDFrom; -- assign records from old account

		set @rowsAffected = @@rowcount;
		set @totalRowsAffected += @rowsAffected;

		if @rowsAffected > 0
		begin
			set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + ' Email Message record(s) moved';
		end;

	end try
	begin catch

		if xact_state() = 1
		begin
			set @ChangeLog += @CRLF + @TAB + '0 Email Message record(s) moved. Duplicate(s) would be created.';
			rollback transaction trx34; -- rollback to save point
		end;
		else if xact_state() = -1
		begin
			set @brError = error_message();

			if @brError like N'%<err>%</err>%' -- business rule violation raised via check constraint 
			begin

				exec sf.pErrorRethrow$Check
					@MessageSCD = @messageSCD
				 ,@MessageText = @brError output	-- parse out the text from the XML
				 ,@ErrorSeverity = @errorSeverity
				 ,@ColumnNames = @columnNames
				 ,@RowSID = @rowSID;

			end;

			set @brError = N'*** ERROR: Unable to process move for sf.EmailMessage record(s) due to unhandled business rule violation.' + isnull(@brError, '');
			raiserror(@brError, 18, 1);
		end;

	end catch;

	-- Email Trigger

	begin try
		save transaction trx35;

		update
			sf.EmailTrigger
		set
			ApplicationUserSID = @ApplicationUserSIDTo
		 ,UpdateTime = @serverTime
		 ,UpdateUser = @updateUser
		 ,UserDefinedColumns = isnull(UserDefinedColumns, @MergeSource)
		where
			ApplicationUserSID = @ApplicationUserSIDFrom; -- assign records from old account

		set @rowsAffected = @@rowcount;
		set @totalRowsAffected += @rowsAffected;

		if @rowsAffected > 0
		begin
			set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + ' Email Trigger record(s) moved';
		end;

	end try
	begin catch

		if xact_state() = 1
		begin
			set @ChangeLog += @CRLF + @TAB + '0 Email Trigger record(s) moved. Duplicate(s) would be created.';
			rollback transaction trx35; -- rollback to save point
		end;
		else if xact_state() = -1
		begin
			set @brError = error_message();

			if @brError like N'%<err>%</err>%' -- business rule violation raised via check constraint 
			begin

				exec sf.pErrorRethrow$Check
					@MessageSCD = @messageSCD
				 ,@MessageText = @brError output	-- parse out the text from the XML
				 ,@ErrorSeverity = @errorSeverity
				 ,@ColumnNames = @columnNames
				 ,@RowSID = @rowSID;

			end;

			set @brError = N'*** ERROR: Unable to process move for sf.EmailTrigger record(s) due to unhandled business rule violation.' + isnull(@brError, '');
			raiserror(@brError, 18, 1);
		end;

	end catch;

	-- Form

	begin try
		save transaction trx36;

		update
			sf.Form
		set
			ApplicationUserSID = @ApplicationUserSIDTo
		 ,UpdateTime = @serverTime
		 ,UpdateUser = @updateUser
		 ,UserDefinedColumns = isnull(UserDefinedColumns, @MergeSource)
		where
			ApplicationUserSID = @ApplicationUserSIDFrom; -- assign records from old account

		set @rowsAffected = @@rowcount;
		set @totalRowsAffected += @rowsAffected;

		if @rowsAffected > 0
		begin
			set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + ' Form record(s) moved';
		end;

	end try
	begin catch

		if xact_state() = 1
		begin
			set @ChangeLog += @CRLF + @TAB + '0 Form record(s) moved. Duplicate(s) would be created.';
			rollback transaction trx36; -- rollback to save point
		end;
		else if xact_state() = -1
		begin
			set @brError = error_message();

			if @brError like N'%<err>%</err>%' -- business rule violation raised via check constraint 
			begin

				exec sf.pErrorRethrow$Check
					@MessageSCD = @messageSCD
				 ,@MessageText = @brError output	-- parse out the text from the XML
				 ,@ErrorSeverity = @errorSeverity
				 ,@ColumnNames = @columnNames
				 ,@RowSID = @rowSID;

			end;

			set @brError = N'*** ERROR: Unable to process move for sf.Form record(s) due to unhandled business rule violation.' + isnull(@brError, '');
			raiserror(@brError, 18, 1);
		end;

	end catch;

	-- Person Group

	begin try
		save transaction trx37;

		update
			sf.PersonGroup
		set
			ApplicationUserSID = @ApplicationUserSIDTo
		 ,UpdateTime = @serverTime
		 ,UpdateUser = @updateUser
		 ,UserDefinedColumns = isnull(UserDefinedColumns, @MergeSource)
		where
			ApplicationUserSID = @ApplicationUserSIDFrom; -- assign records from old account

		set @rowsAffected = @@rowcount;
		set @totalRowsAffected += @rowsAffected;

		if @rowsAffected > 0
		begin
			set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + ' Person Group record(s) moved';
		end;

	end try
	begin catch

		if xact_state() = 1
		begin
			set @ChangeLog += @CRLF + @TAB + '0 Person Group record(s) moved. Duplicate(s) would be created.';
			rollback transaction trx37; -- rollback to save point
		end;
		else if xact_state() = -1
		begin
			set @brError = error_message();

			if @brError like N'%<err>%</err>%' -- business rule violation raised via check constraint 
			begin

				exec sf.pErrorRethrow$Check
					@MessageSCD = @messageSCD
				 ,@MessageText = @brError output	-- parse out the text from the XML
				 ,@ErrorSeverity = @errorSeverity
				 ,@ColumnNames = @columnNames
				 ,@RowSID = @rowSID;

			end;

			set @brError = N'*** ERROR: Unable to process move for sf.PersonGroup record(s) due to unhandled business rule violation.' + isnull(@brError, '');
			raiserror(@brError, 18, 1);
		end;

	end catch;

	-- Task Queue

	begin try
		save transaction trx38;

		update
			sf.TaskQueue
		set
			ApplicationUserSID = @ApplicationUserSIDTo
		 ,UpdateTime = @serverTime
		 ,UpdateUser = @updateUser
		 ,UserDefinedColumns = isnull(UserDefinedColumns, @MergeSource)
		where
			ApplicationUserSID = @ApplicationUserSIDFrom; -- assign records from old account

		set @rowsAffected = @@rowcount;
		set @totalRowsAffected += @rowsAffected;

		if @rowsAffected > 0
		begin
			set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + ' Task Queue record(s) moved';
		end;

	end try
	begin catch

		if xact_state() = 1
		begin
			set @ChangeLog += @CRLF + @TAB + '0 Task Queue record(s) moved. Duplicate(s) would be created.';
			rollback transaction trx38; -- rollback to save point
		end;
		else if xact_state() = -1
		begin
			set @brError = error_message();

			if @brError like N'%<err>%</err>%' -- business rule violation raised via check constraint 
			begin

				exec sf.pErrorRethrow$Check
					@MessageSCD = @messageSCD
				 ,@MessageText = @brError output	-- parse out the text from the XML
				 ,@ErrorSeverity = @errorSeverity
				 ,@ColumnNames = @columnNames
				 ,@RowSID = @rowSID;

			end;

			set @brError = N'*** ERROR: Unable to process move for sf.TaskQueue record(s) due to unhandled business rule violation.' + isnull(@brError, '');
			raiserror(@brError, 18, 1);
		end;

	end catch;

	-- Text Message

	begin try
		save transaction trx39;

		update
			sf.TextMessage
		set
			ApplicationUserSID = @ApplicationUserSIDTo
		 ,UpdateTime = @serverTime
		 ,UpdateUser = @updateUser
		 ,UserDefinedColumns = isnull(UserDefinedColumns, @MergeSource)
		where
			ApplicationUserSID = @ApplicationUserSIDFrom; -- assign records from old account

		set @rowsAffected = @@rowcount;
		set @totalRowsAffected += @rowsAffected;

		if @rowsAffected > 0
		begin
			set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + ' Text Message record(s) moved';
		end;

	end try
	begin catch

		if xact_state() = 1
		begin
			set @ChangeLog += @CRLF + @TAB + '0 Text Message record(s) moved. Duplicate(s) would be created.';
			rollback transaction trx39; -- rollback to save point
		end;
		else if xact_state() = -1
		begin
			set @brError = error_message();

			if @brError like N'%<err>%</err>%' -- business rule violation raised via check constraint 
			begin

				exec sf.pErrorRethrow$Check
					@MessageSCD = @messageSCD
				 ,@MessageText = @brError output	-- parse out the text from the XML
				 ,@ErrorSeverity = @errorSeverity
				 ,@ColumnNames = @columnNames
				 ,@RowSID = @rowSID;

			end;

			set @brError = N'*** ERROR: Unable to process move for sf.TextMessage record(s) due to unhandled business rule violation.' + isnull(@brError, '');
			raiserror(@brError, 18, 1);
		end;

	end catch;

	-- Text Trigger

	begin try
		save transaction trx40;

		update
			sf.TextTrigger
		set
			ApplicationUserSID = @ApplicationUserSIDTo
		 ,UpdateTime = @serverTime
		 ,UpdateUser = @updateUser
		 ,UserDefinedColumns = isnull(UserDefinedColumns, @MergeSource)
		where
			ApplicationUserSID = @ApplicationUserSIDFrom; -- assign records from old account

		set @rowsAffected = @@rowcount;
		set @totalRowsAffected += @rowsAffected;

		if @rowsAffected > 0
		begin
			set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + ' Text Trigger record(s) moved';
		end;

	end try
	begin catch

		if xact_state() = 1
		begin
			set @ChangeLog += @CRLF + @TAB + '0 Text Trigger record(s) moved. Duplicate(s) would be created.';
			rollback transaction trx40; -- rollback to save point
		end;
		else if xact_state() = -1
		begin
			set @brError = error_message();

			if @brError like N'%<err>%</err>%' -- business rule violation raised via check constraint 
			begin

				exec sf.pErrorRethrow$Check
					@MessageSCD = @messageSCD
				 ,@MessageText = @brError output	-- parse out the text from the XML
				 ,@ErrorSeverity = @errorSeverity
				 ,@ColumnNames = @columnNames
				 ,@RowSID = @rowSID;

			end;

			set @brError = N'*** ERROR: Unable to process move for sf.TextTrigger record(s) due to unhandled business rule violation.' + isnull(@brError, '');
			raiserror(@brError, 18, 1);
		end;

	end catch;

	-- Invoice

	begin try
		save transaction trx41;

		update
			dbo.Invoice
		set
			PersonSID = @PersonSIDTo
		 ,UpdateTime = @serverTime
		 ,UpdateUser = @updateUser
		 ,UserDefinedColumns = isnull(UserDefinedColumns, @MergeSource)
		where
			PersonSID = @PersonSIDFrom; -- assign records from old account

		set @rowsAffected = @@rowcount;
		set @totalRowsAffected += @rowsAffected;

		if @rowsAffected > 0
		begin
			set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + ' Invoice record(s) moved';
		end;

	end try
	begin catch

		if xact_state() = 1
		begin
			set @ChangeLog += @CRLF + @TAB + '0 Invoice record(s) moved. Duplicate(s) would be created.';
			rollback transaction trx41; -- rollback to save point
		end;
		else if xact_state() = -1
		begin
			set @brError = error_message();

			if @brError like N'%<err>%</err>%' -- business rule violation raised via check constraint 
			begin

				exec sf.pErrorRethrow$Check
					@MessageSCD = @messageSCD
				 ,@MessageText = @brError output	-- parse out the text from the XML
				 ,@ErrorSeverity = @errorSeverity
				 ,@ColumnNames = @columnNames
				 ,@RowSID = @rowSID;

			end;

			set @brError = N'*** ERROR: Unable to process move for dbo.Invoice record(s) due to unhandled business rule violation.' + isnull(@brError, '');
			raiserror(@brError, 18, 1);
		end;

	end catch;

	-- PAPSubscription

	begin try
		save transaction trx42;

		update
			dbo.PAPSubscription
		set
			PersonSID = @PersonSIDTo
		 ,UpdateTime = @serverTime
		 ,UpdateUser = @updateUser
		 ,UserDefinedColumns = isnull(UserDefinedColumns, @MergeSource)
		where
			PersonSID = @PersonSIDFrom; -- assign records from old account

		set @rowsAffected = @@rowcount;
		set @totalRowsAffected += @rowsAffected;

		if @rowsAffected > 0
		begin
			set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + ' PAPSubscription record(s) moved';
		end;

	end try
	begin catch

		if xact_state() = 1
		begin
			set @ChangeLog += @CRLF + @TAB + '0 PAPSubscription record(s) moved. Duplicate(s) would be created.';
			rollback transaction trx42; -- rollback to save point
		end;
		else if xact_state() = -1
		begin
			set @brError = error_message();

			if @brError like N'%<err>%</err>%' -- business rule violation raised via check constraint 
			begin

				exec sf.pErrorRethrow$Check
					@MessageSCD = @messageSCD
				 ,@MessageText = @brError output	-- parse out the text from the XML
				 ,@ErrorSeverity = @errorSeverity
				 ,@ColumnNames = @columnNames
				 ,@RowSID = @rowSID;

			end;

			set @brError = N'*** ERROR: Unable to process move for dbo.PAPSubscription record(s) due to unhandled business rule violation.' + isnull(@brError, '');
			raiserror(@brError, 18, 1);
		end;

	end catch;

	-- Payment

	begin try
		save transaction trx43;

		update
			dbo.Payment
		set
			PersonSID = @PersonSIDTo
		 ,UpdateTime = @serverTime
		 ,UpdateUser = @updateUser
		 ,UserDefinedColumns = isnull(UserDefinedColumns, @MergeSource)
		where
			PersonSID = @PersonSIDFrom; -- assign records from old account

		set @rowsAffected = @@rowcount;
		set @totalRowsAffected += @rowsAffected;

		if @rowsAffected > 0
		begin
			set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + ' Payment record(s) moved';
		end;

	end try
	begin catch

		if xact_state() = 1
		begin
			set @ChangeLog += @CRLF + @TAB + '0 Payment record(s) moved. Duplicate(s) would be created.';
			rollback transaction trx43; -- rollback to save point
		end;
		else if xact_state() = -1
		begin
			set @brError = error_message();

			if @brError like N'%<err>%</err>%' -- business rule violation raised via check constraint 
			begin

				exec sf.pErrorRethrow$Check
					@MessageSCD = @messageSCD
				 ,@MessageText = @brError output	-- parse out the text from the XML
				 ,@ErrorSeverity = @errorSeverity
				 ,@ColumnNames = @columnNames
				 ,@RowSID = @rowSID;

			end;

			set @brError = N'*** ERROR: Unable to process move for dbo.Payment record(s) due to unhandled business rule violation.' + isnull(@brError, '');
			raiserror(@brError, 18, 1);
		end;

	end catch;

	-- Person Doc

	begin try
		save transaction trx44;

		update
			dbo.PersonDoc
		set
			PersonSID = @PersonSIDTo
		 ,UpdateTime = @serverTime
		 ,UpdateUser = @updateUser
		 ,UserDefinedColumns = isnull(UserDefinedColumns, @MergeSource)
		where
			PersonSID = @PersonSIDFrom; -- assign records from old account

		set @rowsAffected = @@rowcount;
		set @totalRowsAffected += @rowsAffected;

		if @rowsAffected > 0
		begin
			set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + ' Person Doc record(s) moved';
		end;

	end try
	begin catch

		if xact_state() = 1
		begin
			set @ChangeLog += @CRLF + @TAB + '0 Person Doc record(s) moved. Duplicate(s) would be created.';
			rollback transaction trx44; -- rollback to save point
		end;
		else if xact_state() = -1
		begin
			set @brError = error_message();

			if @brError like N'%<err>%</err>%' -- business rule violation raised via check constraint 
			begin

				exec sf.pErrorRethrow$Check
					@MessageSCD = @messageSCD
				 ,@MessageText = @brError output	-- parse out the text from the XML
				 ,@ErrorSeverity = @errorSeverity
				 ,@ColumnNames = @columnNames
				 ,@RowSID = @rowSID;

			end;

			set @brError = N'*** ERROR: Unable to process move for dbo.PersonDoc record(s) due to unhandled business rule violation.' + isnull(@brError, '');
			raiserror(@brError, 18, 1);
		end;

	end catch;

	-- Person Note

	begin try
		save transaction trx45;

		update
			dbo.PersonNote
		set
			PersonSID = @PersonSIDTo
		 ,UpdateTime = @serverTime
		 ,UpdateUser = @updateUser
		 ,UserDefinedColumns = isnull(UserDefinedColumns, @MergeSource)
		where
			PersonSID = @PersonSIDFrom; -- assign records from old account

		set @rowsAffected = @@rowcount;
		set @totalRowsAffected += @rowsAffected;

		if @rowsAffected > 0
		begin
			set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + ' Person Note record(s) moved';
		end;

	end try
	begin catch

		if xact_state() = 1
		begin
			set @ChangeLog += @CRLF + @TAB + '0 Person Note record(s) moved. Duplicate(s) would be created.';
			rollback transaction trx45; -- rollback to save point
		end;
		else if xact_state() = -1
		begin
			set @brError = error_message();

			if @brError like N'%<err>%</err>%' -- business rule violation raised via check constraint 
			begin

				exec sf.pErrorRethrow$Check
					@MessageSCD = @messageSCD
				 ,@MessageText = @brError output	-- parse out the text from the XML
				 ,@ErrorSeverity = @errorSeverity
				 ,@ColumnNames = @columnNames
				 ,@RowSID = @rowSID;

			end;

			set @brError = N'*** ERROR: Unable to process move for dbo.PersonNote record(s) due to unhandled business rule violation.' + isnull(@brError, '');
			raiserror(@brError, 18, 1);
		end;

	end catch;

	-- Registrant

	begin try
		save transaction trx46;

		update
			dbo.Registrant
		set
			PersonSID = @PersonSIDTo
		 ,UpdateTime = @serverTime
		 ,UpdateUser = @updateUser
		 ,UserDefinedColumns = isnull(UserDefinedColumns, @MergeSource)
		where
			PersonSID = @PersonSIDFrom; -- assign records from old account

		set @rowsAffected = @@rowcount;
		set @totalRowsAffected += @rowsAffected;

		if @rowsAffected > 0
		begin
			set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + ' Registrant record(s) moved';
		end;

	end try
	begin catch

		if xact_state() = 1
		begin
			set @ChangeLog += @CRLF + @TAB + '0 Registrant record(s) moved. Duplicate(s) would be created.';
			rollback transaction trx46; -- rollback to save point
		end;
		else if xact_state() = -1
		begin
			set @brError = error_message();

			if @brError like N'%<err>%</err>%' -- business rule violation raised via check constraint 
			begin

				exec sf.pErrorRethrow$Check
					@MessageSCD = @messageSCD
				 ,@MessageText = @brError output	-- parse out the text from the XML
				 ,@ErrorSeverity = @errorSeverity
				 ,@ColumnNames = @columnNames
				 ,@RowSID = @rowSID;

			end;

			set @brError = N'*** ERROR: Unable to process move for dbo.Registrant record(s) due to unhandled business rule violation.' + isnull(@brError, '');
			raiserror(@brError, 18, 1);
		end;

	end catch;

	-- Application User

	begin try
		save transaction trx47;

		update
			sf.ApplicationUser
		set
			PersonSID = @PersonSIDTo
		 ,UpdateTime = @serverTime
		 ,UpdateUser = @updateUser
		 ,UserDefinedColumns = isnull(UserDefinedColumns, @MergeSource)
		where
			PersonSID = @PersonSIDFrom; -- assign records from old account

		set @rowsAffected = @@rowcount;
		set @totalRowsAffected += @rowsAffected;

		if @rowsAffected > 0
		begin
			set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + ' Application User record(s) moved';
		end;

	end try
	begin catch

		if xact_state() = 1
		begin
			set @ChangeLog += @CRLF + @TAB + '0 Application User record(s) moved. Duplicate(s) would be created.';
			rollback transaction trx47; -- rollback to save point
		end;
		else if xact_state() = -1
		begin
			set @brError = error_message();

			if @brError like N'%<err>%</err>%' -- business rule violation raised via check constraint 
			begin

				exec sf.pErrorRethrow$Check
					@MessageSCD = @messageSCD
				 ,@MessageText = @brError output	-- parse out the text from the XML
				 ,@ErrorSeverity = @errorSeverity
				 ,@ColumnNames = @columnNames
				 ,@RowSID = @rowSID;

			end;

			set @brError = N'*** ERROR: Unable to process move for sf.ApplicationUser record(s) due to unhandled business rule violation.' + isnull(@brError, '');
			raiserror(@brError, 18, 1);
		end;

	end catch;

	-- Person Email Address

	begin try
		save transaction trx48;

		update
			sf.PersonEmailAddress
		set
			PersonSID = @PersonSIDTo
		 ,UpdateTime = @serverTime
		 ,UpdateUser = @updateUser
		 ,UserDefinedColumns = isnull(UserDefinedColumns, @MergeSource)
		where
			PersonSID = @PersonSIDFrom; -- assign records from old account

		set @rowsAffected = @@rowcount;
		set @totalRowsAffected += @rowsAffected;

		if @rowsAffected > 0
		begin
			set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + ' Person Email Address record(s) moved';
		end;

	end try
	begin catch

		if xact_state() = 1
		begin
			set @ChangeLog += @CRLF + @TAB + '0 Person Email Address record(s) moved. Duplicate(s) would be created.';
			rollback transaction trx48; -- rollback to save point
		end;
		else if xact_state() = -1
		begin
			set @brError = error_message();

			if @brError like N'%<err>%</err>%' -- business rule violation raised via check constraint 
			begin

				exec sf.pErrorRethrow$Check
					@MessageSCD = @messageSCD
				 ,@MessageText = @brError output	-- parse out the text from the XML
				 ,@ErrorSeverity = @errorSeverity
				 ,@ColumnNames = @columnNames
				 ,@RowSID = @rowSID;

			end;

			set @brError = N'*** ERROR: Unable to process move for sf.PersonEmailAddress record(s) due to unhandled business rule violation.' + isnull(@brError, '');
			raiserror(@brError, 18, 1);
		end;

	end catch;

	-- Person Mailing Preference

	begin try
		save transaction trx49;

		update
			sf.PersonMailingPreference
		set
			PersonSID = @PersonSIDTo
		 ,UpdateTime = @serverTime
		 ,UpdateUser = @updateUser
		 ,UserDefinedColumns = isnull(UserDefinedColumns, @MergeSource)
		where
			PersonSID = @PersonSIDFrom -- assign records from old account
			and not exists -- avoid assigning duplicates
		(
			select
				1
			from
				sf.PersonMailingPreference x
			where
				x.PersonSID																																																											= @PersonSIDTo
				and x.MailingPreferenceSID																																																			= PersonMailingPreference.MailingPreferenceSID
				and sf.fIsDateOverlap(x.EffectiveTime, x.ExpiryTime, PersonMailingPreference.EffectiveTime, PersonMailingPreference.ExpiryTime) = @ON
		);

		set @rowsAffected = @@rowcount;
		set @totalRowsAffected += @rowsAffected;

		if @rowsAffected > 0
		begin
			set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + ' Person Mailing Preference record(s) moved';
		end;

	end try
	begin catch

		if xact_state() = 1
		begin
			set @ChangeLog += @CRLF + @TAB + '0 Person Mailing Preference record(s) moved. Duplicate(s) would be created.';
			rollback transaction trx49; -- rollback to save point
		end;
		else if xact_state() = -1
		begin
			set @brError = error_message();

			if @brError like N'%<err>%</err>%' -- business rule violation raised via check constraint 
			begin

				exec sf.pErrorRethrow$Check
					@MessageSCD = @messageSCD
				 ,@MessageText = @brError output	-- parse out the text from the XML
				 ,@ErrorSeverity = @errorSeverity
				 ,@ColumnNames = @columnNames
				 ,@RowSID = @rowSID;

			end;

			set @brError =
				N'*** ERROR: Unable to process move for sf.PersonMailingPreference record(s) due to unhandled business rule violation.' + isnull(@brError, '');
			raiserror(@brError, 18, 1);
		end;

	end catch;

	-- Person Other Name

	begin try
		save transaction trx50;

		update
			sf.PersonOtherName
		set
			PersonSID = @PersonSIDTo
		 ,UpdateTime = @serverTime
		 ,UpdateUser = @updateUser
		 ,UserDefinedColumns = isnull(UserDefinedColumns, @MergeSource)
		where
			PersonSID = @PersonSIDFrom; -- assign records from old account

		set @rowsAffected = @@rowcount;
		set @totalRowsAffected += @rowsAffected;

		if @rowsAffected > 0
		begin
			set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + ' Person Other Name record(s) moved';
		end;

	end try
	begin catch

		if xact_state() = 1
		begin
			set @ChangeLog += @CRLF + @TAB + '0 Person Other Name record(s) moved. Duplicate(s) would be created.';
			rollback transaction trx50; -- rollback to save point
		end;
		else if xact_state() = -1
		begin
			set @brError = error_message();

			if @brError like N'%<err>%</err>%' -- business rule violation raised via check constraint 
			begin

				exec sf.pErrorRethrow$Check
					@MessageSCD = @messageSCD
				 ,@MessageText = @brError output	-- parse out the text from the XML
				 ,@ErrorSeverity = @errorSeverity
				 ,@ColumnNames = @columnNames
				 ,@RowSID = @rowSID;

			end;

			set @brError = N'*** ERROR: Unable to process move for sf.PersonOtherName record(s) due to unhandled business rule violation.' + isnull(@brError, '');
			raiserror(@brError, 18, 1);
		end;

	end catch;

	if @totalRowsAffected = 0
	begin
		set @ChangeLog += @CRLF + @TAB + 'None';
	end;

	if @DebugLevel > 1
	begin

		exec sf.pDebugPrint
			@DebugString = N'Updates complete'
		 ,@TimeCheck = @timeCheck output;

	end;

	return (@errorNo);
end;
GO
