SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrationRequirement#Insert]
	 @RegistrationRequirementSID           int               = null output	-- identity value assigned to the new record
	,@RegistrationRequirementTypeSID       int               = null					-- required! if not passed value must be set in custom logic prior to insert
	,@RegistrationRequirementLabel         nvarchar(35)      = null					-- required! if not passed value must be set in custom logic prior to insert
	,@RequirementDescription               varbinary(max)    = null					
	,@AdminGuidance                        varbinary(max)    = null					
	,@PersonDocTypeSID                     int               = null					
	,@ExamSID                              int               = null					
	,@ExpiryMonths                         smallint          = null					-- default: (0)
	,@IsActive                             bit               = null					-- default: (1)
	,@UserDefinedColumns                   xml               = null					
	,@RegistrationRequirementXID           varchar(150)      = null					
	,@LegacyKey                            nvarchar(50)      = null					
	,@CreateUser                           nvarchar(75)      = null					-- default: suser_sname()
	,@IsReselected                         tinyint           = null					-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                             xml               = null					-- other values defining context for the insert (if any)
	,@RegistrationRequirementTypeLabel     nvarchar(35)      = null					-- not a base table column (default ignored)
	,@RegistrationRequirementTypeCode      varchar(20)       = null					-- not a base table column (default ignored)
	,@RegistrationRequirementTypeCategory  nvarchar(65)      = null					-- not a base table column (default ignored)
	,@IsAppliedToPeople                    bit               = null					-- not a base table column (default ignored)
	,@IsAppliedToOrganizations             bit               = null					-- not a base table column (default ignored)
	,@RegistrationRequirementTypeIsDefault bit               = null					-- not a base table column (default ignored)
	,@RegistrationRequirementTypeIsActive  bit               = null					-- not a base table column (default ignored)
	,@RegistrationRequirementTypeRowGUID   uniqueidentifier  = null					-- not a base table column (default ignored)
	,@ExamName                             nvarchar(50)      = null					-- not a base table column (default ignored)
	,@ExamCategory                         nvarchar(65)      = null					-- not a base table column (default ignored)
	,@PassingScore                         int               = null					-- not a base table column (default ignored)
	,@EffectiveTime                        datetime          = null					-- not a base table column (default ignored)
	,@ExpiryTime                           datetime          = null					-- not a base table column (default ignored)
	,@IsOnlineExam                         bit               = null					-- not a base table column (default ignored)
	,@IsEnabledOnPortal                    bit               = null					-- not a base table column (default ignored)
	,@Sequence                             int               = null					-- not a base table column (default ignored)
	,@CultureSID                           int               = null					-- not a base table column (default ignored)
	,@LastVerifiedTime                     datetimeoffset(7) = null					-- not a base table column (default ignored)
	,@MinLagDaysBetweenAttempts            smallint          = null					-- not a base table column (default ignored)
	,@MaxAttemptsPerYear                   tinyint           = null					-- not a base table column (default ignored)
	,@VendorExamID                         varchar(25)       = null					-- not a base table column (default ignored)
	,@ExamRowGUID                          uniqueidentifier  = null					-- not a base table column (default ignored)
	,@PersonDocTypeSCD                     varchar(15)       = null					-- not a base table column (default ignored)
	,@PersonDocTypeLabel                   nvarchar(35)      = null					-- not a base table column (default ignored)
	,@PersonDocTypeCategory                nvarchar(65)      = null					-- not a base table column (default ignored)
	,@PersonDocTypeIsDefault               bit               = null					-- not a base table column (default ignored)
	,@PersonDocTypeIsActive                bit               = null					-- not a base table column (default ignored)
	,@PersonDocTypeRowGUID                 uniqueidentifier  = null					-- not a base table column (default ignored)
	,@IsDeleteEnabled                      bit               = null					-- not a base table column (default ignored)
	,@IsDeclaration                        bit               = null					-- not a base table column (default ignored)
	,@IsExam                               bit               = null					-- not a base table column (default ignored)
	,@IsDocument                           bit               = null					-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pRegistrationRequirement#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the dbo.RegistrationRequirement table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the dbo.RegistrationRequirement table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vRegistrationRequirement entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pRegistrationRequirement procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fRegistrationRequirementCheck to test all rules.

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

	set @RegistrationRequirementSID = null																	-- initialize output parameter

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

		set @RegistrationRequirementLabel = ltrim(rtrim(@RegistrationRequirementLabel))
		set @RegistrationRequirementXID = ltrim(rtrim(@RegistrationRequirementXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @CreateUser = ltrim(rtrim(@CreateUser))
		set @RegistrationRequirementTypeLabel = ltrim(rtrim(@RegistrationRequirementTypeLabel))
		set @RegistrationRequirementTypeCode = ltrim(rtrim(@RegistrationRequirementTypeCode))
		set @RegistrationRequirementTypeCategory = ltrim(rtrim(@RegistrationRequirementTypeCategory))
		set @ExamName = ltrim(rtrim(@ExamName))
		set @ExamCategory = ltrim(rtrim(@ExamCategory))
		set @VendorExamID = ltrim(rtrim(@VendorExamID))
		set @PersonDocTypeSCD = ltrim(rtrim(@PersonDocTypeSCD))
		set @PersonDocTypeLabel = ltrim(rtrim(@PersonDocTypeLabel))
		set @PersonDocTypeCategory = ltrim(rtrim(@PersonDocTypeCategory))

		-- set zero length strings to null to avoid storing them in the record

		if len(@RegistrationRequirementLabel) = 0 set @RegistrationRequirementLabel = null
		if len(@RegistrationRequirementXID) = 0 set @RegistrationRequirementXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@CreateUser) = 0 set @CreateUser = null
		if len(@RegistrationRequirementTypeLabel) = 0 set @RegistrationRequirementTypeLabel = null
		if len(@RegistrationRequirementTypeCode) = 0 set @RegistrationRequirementTypeCode = null
		if len(@RegistrationRequirementTypeCategory) = 0 set @RegistrationRequirementTypeCategory = null
		if len(@ExamName) = 0 set @ExamName = null
		if len(@ExamCategory) = 0 set @ExamCategory = null
		if len(@VendorExamID) = 0 set @VendorExamID = null
		if len(@PersonDocTypeSCD) = 0 set @PersonDocTypeSCD = null
		if len(@PersonDocTypeLabel) = 0 set @PersonDocTypeLabel = null
		if len(@PersonDocTypeCategory) = 0 set @PersonDocTypeCategory = null

		-- set the ID of the user

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @ExpiryMonths = isnull(@ExpiryMonths,(0))
		set @IsActive = isnull(@IsActive,(1))
		set @CreateUser = isnull(@CreateUser,suser_sname())
		set @IsReselected                   = isnull(@IsReselected                  ,(0))
		
		-- look up the FK value matching the system code if set; this allows
		-- FK values value to be set/updated based on system code values
		
		if @PersonDocTypeSCD is not null
		begin
		
			select
				@PersonDocTypeSID = x.PersonDocTypeSID
			from
				dbo.PersonDocType x
			where
				x.PersonDocTypeSCD = @PersonDocTypeSCD
		
		end
		
		-- set default value on mandatory foreign keys where configured
		-- and if value not already assigned
		
		if @RegistrationRequirementTypeSID  is null select @RegistrationRequirementTypeSID  = x.RegistrationRequirementTypeSID from dbo.RegistrationRequirementType x where x.IsDefault = @ON

		-- apply the table-specific pre-insert logic (if any)

		--! <PreInsert>
		--  insert pre-insert logic here ...
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
				r.RoutineName = 'pRegistrationRequirement'
		)
		begin
		
			exec @errorNo = ext.pRegistrationRequirement
				 @Mode                                 = 'insert.pre'
				,@RegistrationRequirementTypeSID       = @RegistrationRequirementTypeSID output
				,@RegistrationRequirementLabel         = @RegistrationRequirementLabel output
				,@RequirementDescription               = @RequirementDescription output
				,@AdminGuidance                        = @AdminGuidance output
				,@PersonDocTypeSID                     = @PersonDocTypeSID output
				,@ExamSID                              = @ExamSID output
				,@ExpiryMonths                         = @ExpiryMonths output
				,@IsActive                             = @IsActive output
				,@UserDefinedColumns                   = @UserDefinedColumns output
				,@RegistrationRequirementXID           = @RegistrationRequirementXID output
				,@LegacyKey                            = @LegacyKey output
				,@CreateUser                           = @CreateUser
				,@IsReselected                         = @IsReselected
				,@zContext                             = @zContext
				,@RegistrationRequirementTypeLabel     = @RegistrationRequirementTypeLabel
				,@RegistrationRequirementTypeCode      = @RegistrationRequirementTypeCode
				,@RegistrationRequirementTypeCategory  = @RegistrationRequirementTypeCategory
				,@IsAppliedToPeople                    = @IsAppliedToPeople
				,@IsAppliedToOrganizations             = @IsAppliedToOrganizations
				,@RegistrationRequirementTypeIsDefault = @RegistrationRequirementTypeIsDefault
				,@RegistrationRequirementTypeIsActive  = @RegistrationRequirementTypeIsActive
				,@RegistrationRequirementTypeRowGUID   = @RegistrationRequirementTypeRowGUID
				,@ExamName                             = @ExamName
				,@ExamCategory                         = @ExamCategory
				,@PassingScore                         = @PassingScore
				,@EffectiveTime                        = @EffectiveTime
				,@ExpiryTime                           = @ExpiryTime
				,@IsOnlineExam                         = @IsOnlineExam
				,@IsEnabledOnPortal                    = @IsEnabledOnPortal
				,@Sequence                             = @Sequence
				,@CultureSID                           = @CultureSID
				,@LastVerifiedTime                     = @LastVerifiedTime
				,@MinLagDaysBetweenAttempts            = @MinLagDaysBetweenAttempts
				,@MaxAttemptsPerYear                   = @MaxAttemptsPerYear
				,@VendorExamID                         = @VendorExamID
				,@ExamRowGUID                          = @ExamRowGUID
				,@PersonDocTypeSCD                     = @PersonDocTypeSCD
				,@PersonDocTypeLabel                   = @PersonDocTypeLabel
				,@PersonDocTypeCategory                = @PersonDocTypeCategory
				,@PersonDocTypeIsDefault               = @PersonDocTypeIsDefault
				,@PersonDocTypeIsActive                = @PersonDocTypeIsActive
				,@PersonDocTypeRowGUID                 = @PersonDocTypeRowGUID
				,@IsDeleteEnabled                      = @IsDeleteEnabled
				,@IsDeclaration                        = @IsDeclaration
				,@IsExam                               = @IsExam
				,@IsDocument                           = @IsDocument
		
		end

		-- insert the record

		insert
			dbo.RegistrationRequirement
		(
			 RegistrationRequirementTypeSID
			,RegistrationRequirementLabel
			,RequirementDescription
			,AdminGuidance
			,PersonDocTypeSID
			,ExamSID
			,ExpiryMonths
			,IsActive
			,UserDefinedColumns
			,RegistrationRequirementXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @RegistrationRequirementTypeSID
			,@RegistrationRequirementLabel
			,@RequirementDescription
			,@AdminGuidance
			,@PersonDocTypeSID
			,@ExamSID
			,@ExpiryMonths
			,@IsActive
			,@UserDefinedColumns
			,@RegistrationRequirementXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected               = @@rowcount
			,@RegistrationRequirementSID = scope_identity()											-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'dbo.RegistrationRequirement'
				,@Arg3        = @rowsAffected
				,@Arg4        = @RegistrationRequirementSID
			
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
				r.RoutineName = 'pRegistrationRequirement'
		)
		begin
		
			exec @errorNo = ext.pRegistrationRequirement
				 @Mode                                 = 'insert.post'
				,@RegistrationRequirementSID           = @RegistrationRequirementSID
				,@RegistrationRequirementTypeSID       = @RegistrationRequirementTypeSID
				,@RegistrationRequirementLabel         = @RegistrationRequirementLabel
				,@RequirementDescription               = @RequirementDescription
				,@AdminGuidance                        = @AdminGuidance
				,@PersonDocTypeSID                     = @PersonDocTypeSID
				,@ExamSID                              = @ExamSID
				,@ExpiryMonths                         = @ExpiryMonths
				,@IsActive                             = @IsActive
				,@UserDefinedColumns                   = @UserDefinedColumns
				,@RegistrationRequirementXID           = @RegistrationRequirementXID
				,@LegacyKey                            = @LegacyKey
				,@CreateUser                           = @CreateUser
				,@IsReselected                         = @IsReselected
				,@zContext                             = @zContext
				,@RegistrationRequirementTypeLabel     = @RegistrationRequirementTypeLabel
				,@RegistrationRequirementTypeCode      = @RegistrationRequirementTypeCode
				,@RegistrationRequirementTypeCategory  = @RegistrationRequirementTypeCategory
				,@IsAppliedToPeople                    = @IsAppliedToPeople
				,@IsAppliedToOrganizations             = @IsAppliedToOrganizations
				,@RegistrationRequirementTypeIsDefault = @RegistrationRequirementTypeIsDefault
				,@RegistrationRequirementTypeIsActive  = @RegistrationRequirementTypeIsActive
				,@RegistrationRequirementTypeRowGUID   = @RegistrationRequirementTypeRowGUID
				,@ExamName                             = @ExamName
				,@ExamCategory                         = @ExamCategory
				,@PassingScore                         = @PassingScore
				,@EffectiveTime                        = @EffectiveTime
				,@ExpiryTime                           = @ExpiryTime
				,@IsOnlineExam                         = @IsOnlineExam
				,@IsEnabledOnPortal                    = @IsEnabledOnPortal
				,@Sequence                             = @Sequence
				,@CultureSID                           = @CultureSID
				,@LastVerifiedTime                     = @LastVerifiedTime
				,@MinLagDaysBetweenAttempts            = @MinLagDaysBetweenAttempts
				,@MaxAttemptsPerYear                   = @MaxAttemptsPerYear
				,@VendorExamID                         = @VendorExamID
				,@ExamRowGUID                          = @ExamRowGUID
				,@PersonDocTypeSCD                     = @PersonDocTypeSCD
				,@PersonDocTypeLabel                   = @PersonDocTypeLabel
				,@PersonDocTypeCategory                = @PersonDocTypeCategory
				,@PersonDocTypeIsDefault               = @PersonDocTypeIsDefault
				,@PersonDocTypeIsActive                = @PersonDocTypeIsActive
				,@PersonDocTypeRowGUID                 = @PersonDocTypeRowGUID
				,@IsDeleteEnabled                      = @IsDeleteEnabled
				,@IsDeclaration                        = @IsDeclaration
				,@IsExam                               = @IsExam
				,@IsDocument                           = @IsDocument
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.RegistrationRequirementSID
			from
				dbo.vRegistrationRequirement ent
			where
				ent.RegistrationRequirementSID = @RegistrationRequirementSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.RegistrationRequirementSID
				,ent.RegistrationRequirementTypeSID
				,ent.RegistrationRequirementLabel
				,ent.RequirementDescription
				,ent.AdminGuidance
				,ent.PersonDocTypeSID
				,ent.ExamSID
				,ent.ExpiryMonths
				,ent.IsActive
				,ent.UserDefinedColumns
				,ent.RegistrationRequirementXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.RegistrationRequirementTypeLabel
				,ent.RegistrationRequirementTypeCode
				,ent.RegistrationRequirementTypeCategory
				,ent.IsAppliedToPeople
				,ent.IsAppliedToOrganizations
				,ent.RegistrationRequirementTypeIsDefault
				,ent.RegistrationRequirementTypeIsActive
				,ent.RegistrationRequirementTypeRowGUID
				,ent.ExamName
				,ent.ExamCategory
				,ent.PassingScore
				,ent.EffectiveTime
				,ent.ExpiryTime
				,ent.IsOnlineExam
				,ent.IsEnabledOnPortal
				,ent.Sequence
				,ent.CultureSID
				,ent.LastVerifiedTime
				,ent.MinLagDaysBetweenAttempts
				,ent.MaxAttemptsPerYear
				,ent.VendorExamID
				,ent.ExamRowGUID
				,ent.PersonDocTypeSCD
				,ent.PersonDocTypeLabel
				,ent.PersonDocTypeCategory
				,ent.PersonDocTypeIsDefault
				,ent.PersonDocTypeIsActive
				,ent.PersonDocTypeRowGUID
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
				,ent.IsDeclaration
				,ent.IsExam
				,ent.IsDocument
			from
				dbo.vRegistrationRequirement ent
			where
				ent.RegistrationRequirementSID = @RegistrationRequirementSID

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
