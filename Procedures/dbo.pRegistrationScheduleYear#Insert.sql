SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrationScheduleYear#Insert]
	 @RegistrationScheduleYearSID                int               = null output											-- identity value assigned to the new record
	,@RegistrationScheduleSID                    int               = null		-- required! if not passed value must be set in custom logic prior to insert
	,@RegistrationYear                           smallint          = null		-- required! if not passed value must be set in custom logic prior to insert
	,@YearStartTime                              datetime          = null		-- required! if not passed value must be set in custom logic prior to insert
	,@YearEndTime                                datetime          = null		-- required! if not passed value must be set in custom logic prior to insert
	,@RenewalVerificationOpenTime                datetime          = null		-- required! if not passed value must be set in custom logic prior to insert
	,@RenewalGeneralOpenTime                     datetime          = null		-- required! if not passed value must be set in custom logic prior to insert
	,@RenewalLateFeeStartTime                    datetime          = null		-- required! if not passed value must be set in custom logic prior to insert
	,@RenewalEndTime                             datetime          = null		-- required! if not passed value must be set in custom logic prior to insert
	,@ReinstatementVerificationOpenTime          datetime          = null		-- required! if not passed value must be set in custom logic prior to insert
	,@ReinstatementGeneralOpenTime               datetime          = null		-- required! if not passed value must be set in custom logic prior to insert
	,@ReinstatementEndTime                       datetime          = null		-- required! if not passed value must be set in custom logic prior to insert
	,@CECollectionStartTime                      datetime          = null		-- required! if not passed value must be set in custom logic prior to insert
	,@CECollectionEndTime                        datetime          = null		-- required! if not passed value must be set in custom logic prior to insert
	,@PAPBlockStartTime                          datetime          = null		-- required! if not passed value must be set in custom logic prior to insert
	,@PAPBlockEndTime                            datetime          = null		-- required! if not passed value must be set in custom logic prior to insert
	,@UserDefinedColumns                         xml               = null		
	,@RegistrationScheduleYearXID                varchar(150)      = null		
	,@LegacyKey                                  nvarchar(50)      = null		
	,@CreateUser                                 nvarchar(75)      = null		-- default: suser_sname()
	,@IsReselected                               tinyint           = null		-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                                   xml               = null		-- other values defining context for the insert (if any)
	,@RegistrationScheduleLabel                  nvarchar(35)      = null		-- not a base table column (default ignored)
	,@RegistrationScheduleIsDefault              bit               = null		-- not a base table column (default ignored)
	,@RegistrationScheduleIsActive               bit               = null		-- not a base table column (default ignored)
	,@RegistrationScheduleRowGUID                uniqueidentifier  = null		-- not a base table column (default ignored)
	,@IsDeleteEnabled                            bit               = null		-- not a base table column (default ignored)
	,@RegistrationYearLabel                      varchar(25)       = null		-- not a base table column (default ignored)
	,@RenewalVerificationOpenTimeComponent       time(7)           = null		-- not a base table column (default ignored)
	,@RenewalGeneralOpenTimeComponent            time(7)           = null		-- not a base table column (default ignored)
	,@ReinstatementVerificationOpenTimeComponent time(7)           = null		-- not a base table column (default ignored)
	,@ReinstatementGeneralOpenTimeComponent      time(7)           = null		-- not a base table column (default ignored)
	,@YearStartTimeComponent                     time(7)           = null		-- not a base table column (default ignored)
	,@YearEndTimeComponent                       time(7)           = null		-- not a base table column (default ignored)
	,@RenewalLateFeeStartTimeComponent           time(7)           = null		-- not a base table column (default ignored)
	,@RenewalEndTimeComponent                    time(7)           = null		-- not a base table column (default ignored)
	,@ReinstatementEndTimeComponent              time(7)           = null		-- not a base table column (default ignored)
	,@PAPBlockStartTimeComponent                 time(7)           = null		-- not a base table column (default ignored)
	,@PAPBlockEndTimeComponent                   time(7)           = null		-- not a base table column (default ignored)
	,@IsEditEnabled                              bit               = null		-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pRegistrationScheduleYear#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the dbo.RegistrationScheduleYear table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the dbo.RegistrationScheduleYear table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vRegistrationScheduleYear entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pRegistrationScheduleYear procedure. The extended procedure is only called
where it exists in the DB. The first parameter passed @Mode is set to either "insert.pre" or "insert.post" to provide context for
the extended logic.

The @zContext parameter is an additional construct available to support overrides where different results are produced based on
content provided in the XML from the client tier. This parameter may contain multiple values.

The "@IsReselected" parameter controls whether the entity row is returned as a dataset (SELECT). There are 3 settings:
   0 - no data set is returned
   1 - return the full entity
   2 - return only the SID (primary key) of the row inserted

For client-tier calls using the Microsoft Entity Framework and RIA Services, the @IsReselected bit should be passed as 1 to
force re-selection of table columns + extended view columns (the entity view).

Values for parameters representing mandatory columns must be provided unless a database default exists.  The default values
displayed as comments next to the parameter declarations above, and the list of columns returned from the entity view when
@IsReselected = 1, were obtained from the data dictionary at generation time. If the table or view design has been
updated since then, the procedure must be regenerated to keep comments up to date. In the StudioDB run dbo.pEFGen
to update all views and procedures which appear out-of-date.

The procedure does not accept a parameter for UpdateUser since the @CreateUser value is applied into both the user audit
columns.  Audit times are set automatically through database defaults and cannot be passed or overwritten.

If the @CreateUser parameter is passed as the special value "SystemUser", then the system user established in sf.ConfigParam
is applied. This option is useful for conversion and system generated inserts the user would not recognize as have caused. Any
other value provided for the parameter (including null) is overwritten with the current application user.

Business rule compliance is checked through a table constraint which calls fRegistrationScheduleYearCheck to test all rules.

-------------------------------------------------------------------------------------------------------------------------------- */

begin
	set nocount on

	declare
		 @errorNo                                      int = 0								-- 0 no error, <50000 SQL error, else business rule
		,@tranCount                                    int = @@trancount			-- determines whether a wrapping transaction exists
		,@sprocName                                    nvarchar(128) = object_name(@@procid)						-- name of currently executing procedure
		,@xState                                       int										-- error state detected in catch block
		,@errorText                                    nvarchar(4000)					-- message text (for business rule errors)
		,@rowsAffected                                 int = 0								-- tracks rows impacted by the operation (error check)
		,@recordSID                                    int										-- tracks primary key value for clearing current default
		,@ON                                           bit = cast(1 as bit)		-- constant for bit comparison and assignments
		,@OFF                                          bit = cast(0 as bit)		-- constant for bit comparison and assignments

	set @RegistrationScheduleYearSID = null																	-- initialize output parameter

	begin try

		-- use a transaction so that any additional updates implemented through the extended
		-- procedure or through table-specific logic succeed or fail as a logical unit

		if @tranCount = 0																											-- no outer transaction
		begin
			begin transaction
		end
		else																																	-- outer transaction so create save point
		begin
			save transaction @sprocName
		end

		-- remove leading and trailing spaces from character type columns

		set @RegistrationScheduleYearXID = ltrim(rtrim(@RegistrationScheduleYearXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @CreateUser = ltrim(rtrim(@CreateUser))
		set @RegistrationScheduleLabel = ltrim(rtrim(@RegistrationScheduleLabel))
		set @RegistrationYearLabel = ltrim(rtrim(@RegistrationYearLabel))

		-- set zero length strings to null to avoid storing them in the record

		if len(@RegistrationScheduleYearXID) = 0 set @RegistrationScheduleYearXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@CreateUser) = 0 set @CreateUser = null
		if len(@RegistrationScheduleLabel) = 0 set @RegistrationScheduleLabel = null
		if len(@RegistrationYearLabel) = 0 set @RegistrationYearLabel = null

		-- set the ID of the user

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @CreateUser = isnull(@CreateUser,suser_sname())
		set @IsReselected                      = isnull(@IsReselected                     ,(0))
		
		-- set default value on mandatory foreign keys where configured
		-- and if value not already assigned
		
		if @RegistrationScheduleSID  is null select @RegistrationScheduleSID  = x.RegistrationScheduleSID from dbo.RegistrationSchedule x where x.IsDefault = @ON

		-- apply the table-specific pre-insert logic (if any)

		--! <PreInsert>
		-- Tim Edlund | Sep 2017
		-- The registration year is automatically set to the year of
		-- the term end.  The user cannot override this setting
		-- as it is required by product code.  Display the Registration
		-- Year on the UI but do not prompt user for it!

		if @YearEndTime is not null set @RegistrationYear = cast(year(@YearEndTime) as smallint)

		-- Tim Edlund | Sep 2017
		-- Combine time components with dates where the user has entered
		-- values into them.  Note that only specific "Open" times can be
		-- modified by the end user.  The rest are set by the system
		-- automatically and cannot be overridden.

		if @RenewalVerificationOpenTimeComponent is not null and @RenewalVerificationOpenTime is not null
		begin
			set @RenewalVerificationOpenTime = cast(cast(@RenewalVerificationOpenTime as date) as datetime) + cast(@RenewalVerificationOpenTimeComponent as datetime);
		end;

		if @RenewalGeneralOpenTimeComponent is not null and @RenewalGeneralOpenTime is not null
		begin
			set @RenewalGeneralOpenTime = cast(cast(@RenewalGeneralOpenTime as date) as datetime) + cast(@RenewalGeneralOpenTimeComponent as datetime);
		end;

		if @ReinstatementVerificationOpenTimeComponent is not null and @ReinstatementVerificationOpenTime is not null
		begin
			set @ReinstatementVerificationOpenTime
				= cast(cast(@ReinstatementVerificationOpenTime as date) as datetime) + cast(@ReinstatementVerificationOpenTimeComponent as datetime);
		end;

		if @ReinstatementGeneralOpenTimeComponent is not null and @ReinstatementGeneralOpenTime is not null
		begin
			set @ReinstatementGeneralOpenTime = cast(cast(@ReinstatementGeneralOpenTime as date) as datetime) + cast(@ReinstatementGeneralOpenTimeComponent as datetime);
		end;

		-- Tim Edlund | Sep 2017
		-- Set the opening and ending times on other columns where
		-- user setting of times is not allowed.

		set @YearStartTime						= cast(cast(@YearStartTime as date) as datetime);
		set @YearEndTime							=	cast(cast(@YearEndTime as date) as datetime) + cast(cast('23:59:59' as time) as datetime);
		set @RenewalLateFeeStartTime	= cast(cast(@RenewalLateFeeStartTime as date) as datetime);
		set @RenewalEndTime						= cast(cast(@RenewalEndTime as date) as datetime) + cast(cast('23:59:59' as time) as datetime);
		set @ReinstatementEndTime			= cast(cast(@ReinstatementEndTime as date) as datetime) + cast(cast('23:59:59' as time) as datetime);
		set @PAPBlockStartTime				= cast(cast(@PAPBlockStartTime as date) as datetime);
		set @PAPBlockEndTime					=	cast(cast(@PAPBlockEndTime as date) as datetime) + cast(cast('23:59:59' as time) as datetime);

		--! </PreInsert>
	
		-- call the extended version of the procedure (if it exists) for "insert.pre" mode
		
		if exists
		(
			select
				1
			from
				sf.vRoutine r
			where
				r.SchemaName = 'ext'
			and
				r.RoutineName = 'pRegistrationScheduleYear'
		)
		begin
		
			exec @errorNo = ext.pRegistrationScheduleYear
				 @Mode                                       = 'insert.pre'
				,@RegistrationScheduleSID                    = @RegistrationScheduleSID output
				,@RegistrationYear                           = @RegistrationYear output
				,@YearStartTime                              = @YearStartTime output
				,@YearEndTime                                = @YearEndTime output
				,@RenewalVerificationOpenTime                = @RenewalVerificationOpenTime output
				,@RenewalGeneralOpenTime                     = @RenewalGeneralOpenTime output
				,@RenewalLateFeeStartTime                    = @RenewalLateFeeStartTime output
				,@RenewalEndTime                             = @RenewalEndTime output
				,@ReinstatementVerificationOpenTime          = @ReinstatementVerificationOpenTime output
				,@ReinstatementGeneralOpenTime               = @ReinstatementGeneralOpenTime output
				,@ReinstatementEndTime                       = @ReinstatementEndTime output
				,@CECollectionStartTime                      = @CECollectionStartTime output
				,@CECollectionEndTime                        = @CECollectionEndTime output
				,@PAPBlockStartTime                          = @PAPBlockStartTime output
				,@PAPBlockEndTime                            = @PAPBlockEndTime output
				,@UserDefinedColumns                         = @UserDefinedColumns output
				,@RegistrationScheduleYearXID                = @RegistrationScheduleYearXID output
				,@LegacyKey                                  = @LegacyKey output
				,@CreateUser                                 = @CreateUser
				,@IsReselected                               = @IsReselected
				,@zContext                                   = @zContext
				,@RegistrationScheduleLabel                  = @RegistrationScheduleLabel
				,@RegistrationScheduleIsDefault              = @RegistrationScheduleIsDefault
				,@RegistrationScheduleIsActive               = @RegistrationScheduleIsActive
				,@RegistrationScheduleRowGUID                = @RegistrationScheduleRowGUID
				,@IsDeleteEnabled                            = @IsDeleteEnabled
				,@RegistrationYearLabel                      = @RegistrationYearLabel
				,@RenewalVerificationOpenTimeComponent       = @RenewalVerificationOpenTimeComponent
				,@RenewalGeneralOpenTimeComponent            = @RenewalGeneralOpenTimeComponent
				,@ReinstatementVerificationOpenTimeComponent = @ReinstatementVerificationOpenTimeComponent
				,@ReinstatementGeneralOpenTimeComponent      = @ReinstatementGeneralOpenTimeComponent
				,@YearStartTimeComponent                     = @YearStartTimeComponent
				,@YearEndTimeComponent                       = @YearEndTimeComponent
				,@RenewalLateFeeStartTimeComponent           = @RenewalLateFeeStartTimeComponent
				,@RenewalEndTimeComponent                    = @RenewalEndTimeComponent
				,@ReinstatementEndTimeComponent              = @ReinstatementEndTimeComponent
				,@PAPBlockStartTimeComponent                 = @PAPBlockStartTimeComponent
				,@PAPBlockEndTimeComponent                   = @PAPBlockEndTimeComponent
				,@IsEditEnabled                              = @IsEditEnabled
		
		end

		-- insert the record

		insert
			dbo.RegistrationScheduleYear
		(
			 RegistrationScheduleSID
			,RegistrationYear
			,YearStartTime
			,YearEndTime
			,RenewalVerificationOpenTime
			,RenewalGeneralOpenTime
			,RenewalLateFeeStartTime
			,RenewalEndTime
			,ReinstatementVerificationOpenTime
			,ReinstatementGeneralOpenTime
			,ReinstatementEndTime
			,CECollectionStartTime
			,CECollectionEndTime
			,PAPBlockStartTime
			,PAPBlockEndTime
			,UserDefinedColumns
			,RegistrationScheduleYearXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @RegistrationScheduleSID
			,@RegistrationYear
			,@YearStartTime
			,@YearEndTime
			,@RenewalVerificationOpenTime
			,@RenewalGeneralOpenTime
			,@RenewalLateFeeStartTime
			,@RenewalEndTime
			,@ReinstatementVerificationOpenTime
			,@ReinstatementGeneralOpenTime
			,@ReinstatementEndTime
			,@CECollectionStartTime
			,@CECollectionEndTime
			,@PAPBlockStartTime
			,@PAPBlockEndTime
			,@UserDefinedColumns
			,@RegistrationScheduleYearXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected                = @@rowcount
			,@RegistrationScheduleYearSID = scope_identity()										-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'dbo.RegistrationScheduleYear'
				,@Arg3        = @rowsAffected
				,@Arg4        = @RegistrationScheduleYearSID
			
			raiserror(@errorText, 18, 1)
			
		end

		-- apply the table-specific post-insert logic (if any)

		--! <PostInsert>
		--  insert post-insert logic here ...
		--! </PostInsert>
	
		-- call the extended version of the procedure (if it exists) for "insert.post" mode
		
		if exists
		(
			select
				1
			from
				sf.vRoutine r
			where
				r.SchemaName = 'ext'
			and
				r.RoutineName = 'pRegistrationScheduleYear'
		)
		begin
		
			exec @errorNo = ext.pRegistrationScheduleYear
				 @Mode                                       = 'insert.post'
				,@RegistrationScheduleYearSID                = @RegistrationScheduleYearSID
				,@RegistrationScheduleSID                    = @RegistrationScheduleSID
				,@RegistrationYear                           = @RegistrationYear
				,@YearStartTime                              = @YearStartTime
				,@YearEndTime                                = @YearEndTime
				,@RenewalVerificationOpenTime                = @RenewalVerificationOpenTime
				,@RenewalGeneralOpenTime                     = @RenewalGeneralOpenTime
				,@RenewalLateFeeStartTime                    = @RenewalLateFeeStartTime
				,@RenewalEndTime                             = @RenewalEndTime
				,@ReinstatementVerificationOpenTime          = @ReinstatementVerificationOpenTime
				,@ReinstatementGeneralOpenTime               = @ReinstatementGeneralOpenTime
				,@ReinstatementEndTime                       = @ReinstatementEndTime
				,@CECollectionStartTime                      = @CECollectionStartTime
				,@CECollectionEndTime                        = @CECollectionEndTime
				,@PAPBlockStartTime                          = @PAPBlockStartTime
				,@PAPBlockEndTime                            = @PAPBlockEndTime
				,@UserDefinedColumns                         = @UserDefinedColumns
				,@RegistrationScheduleYearXID                = @RegistrationScheduleYearXID
				,@LegacyKey                                  = @LegacyKey
				,@CreateUser                                 = @CreateUser
				,@IsReselected                               = @IsReselected
				,@zContext                                   = @zContext
				,@RegistrationScheduleLabel                  = @RegistrationScheduleLabel
				,@RegistrationScheduleIsDefault              = @RegistrationScheduleIsDefault
				,@RegistrationScheduleIsActive               = @RegistrationScheduleIsActive
				,@RegistrationScheduleRowGUID                = @RegistrationScheduleRowGUID
				,@IsDeleteEnabled                            = @IsDeleteEnabled
				,@RegistrationYearLabel                      = @RegistrationYearLabel
				,@RenewalVerificationOpenTimeComponent       = @RenewalVerificationOpenTimeComponent
				,@RenewalGeneralOpenTimeComponent            = @RenewalGeneralOpenTimeComponent
				,@ReinstatementVerificationOpenTimeComponent = @ReinstatementVerificationOpenTimeComponent
				,@ReinstatementGeneralOpenTimeComponent      = @ReinstatementGeneralOpenTimeComponent
				,@YearStartTimeComponent                     = @YearStartTimeComponent
				,@YearEndTimeComponent                       = @YearEndTimeComponent
				,@RenewalLateFeeStartTimeComponent           = @RenewalLateFeeStartTimeComponent
				,@RenewalEndTimeComponent                    = @RenewalEndTimeComponent
				,@ReinstatementEndTimeComponent              = @ReinstatementEndTimeComponent
				,@PAPBlockStartTimeComponent                 = @PAPBlockStartTimeComponent
				,@PAPBlockEndTimeComponent                   = @PAPBlockEndTimeComponent
				,@IsEditEnabled                              = @IsEditEnabled
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.RegistrationScheduleYearSID
			from
				dbo.vRegistrationScheduleYear ent
			where
				ent.RegistrationScheduleYearSID = @RegistrationScheduleYearSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.RegistrationScheduleYearSID
				,ent.RegistrationScheduleSID
				,ent.RegistrationYear
				,ent.YearStartTime
				,ent.YearEndTime
				,ent.RenewalVerificationOpenTime
				,ent.RenewalGeneralOpenTime
				,ent.RenewalLateFeeStartTime
				,ent.RenewalEndTime
				,ent.ReinstatementVerificationOpenTime
				,ent.ReinstatementGeneralOpenTime
				,ent.ReinstatementEndTime
				,ent.CECollectionStartTime
				,ent.CECollectionEndTime
				,ent.PAPBlockStartTime
				,ent.PAPBlockEndTime
				,ent.UserDefinedColumns
				,ent.RegistrationScheduleYearXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.RegistrationScheduleLabel
				,ent.RegistrationScheduleIsDefault
				,ent.RegistrationScheduleIsActive
				,ent.RegistrationScheduleRowGUID
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
				,ent.RegistrationYearLabel
				,ent.RenewalVerificationOpenTimeComponent
				,ent.RenewalGeneralOpenTimeComponent
				,ent.ReinstatementVerificationOpenTimeComponent
				,ent.ReinstatementGeneralOpenTimeComponent
				,ent.YearStartTimeComponent
				,ent.YearEndTimeComponent
				,ent.RenewalLateFeeStartTimeComponent
				,ent.RenewalEndTimeComponent
				,ent.ReinstatementEndTimeComponent
				,ent.PAPBlockStartTimeComponent
				,ent.PAPBlockEndTimeComponent
				,ent.IsEditEnabled
			from
				dbo.vRegistrationScheduleYear ent
			where
				ent.RegistrationScheduleYearSID = @RegistrationScheduleYearSID

		end

	end try

	begin catch
		set @xState = xact_state()
		
		if @tranCount > 0 and @xState = 1
		begin
			rollback transaction @sprocName																			-- committable wrapping trx exists: rollback to savepoint
		end
		else if @xState <> 0																									-- full rollback
		begin
			rollback
		end
		
		exec @errorNo = sf.pErrorRethrow																			-- process message text and re-throw the error
	end catch

	return(@errorNo)

end
GO
