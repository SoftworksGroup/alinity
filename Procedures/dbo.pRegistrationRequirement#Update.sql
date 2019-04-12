SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrationRequirement#Update]
	 @RegistrationRequirementSID           int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@RegistrationRequirementTypeSID       int               = null -- table column values to update:
	,@RegistrationRequirementLabel         nvarchar(35)      = null
	,@RequirementDescription               varbinary(max)    = null
	,@AdminGuidance                        varbinary(max)    = null
	,@PersonDocTypeSID                     int               = null
	,@ExamSID                              int               = null
	,@ExpiryMonths                         smallint          = null
	,@IsActive                             bit               = null
	,@UserDefinedColumns                   xml               = null
	,@RegistrationRequirementXID           varchar(150)      = null
	,@LegacyKey                            nvarchar(50)      = null
	,@UpdateUser                           nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                             timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected                         tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied                        bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext                             xml               = null -- other values defining context for the update (if any)
	,@RegistrationRequirementTypeLabel     nvarchar(35)      = null -- not a base table column
	,@RegistrationRequirementTypeCode      varchar(20)       = null -- not a base table column
	,@RegistrationRequirementTypeCategory  nvarchar(65)      = null -- not a base table column
	,@IsAppliedToPeople                    bit               = null -- not a base table column
	,@IsAppliedToOrganizations             bit               = null -- not a base table column
	,@RegistrationRequirementTypeIsDefault bit               = null -- not a base table column
	,@RegistrationRequirementTypeIsActive  bit               = null -- not a base table column
	,@RegistrationRequirementTypeRowGUID   uniqueidentifier  = null -- not a base table column
	,@ExamName                             nvarchar(50)      = null -- not a base table column
	,@ExamCategory                         nvarchar(65)      = null -- not a base table column
	,@PassingScore                         int               = null -- not a base table column
	,@EffectiveTime                        datetime          = null -- not a base table column
	,@ExpiryTime                           datetime          = null -- not a base table column
	,@IsOnlineExam                         bit               = null -- not a base table column
	,@IsEnabledOnPortal                    bit               = null -- not a base table column
	,@Sequence                             int               = null -- not a base table column
	,@CultureSID                           int               = null -- not a base table column
	,@LastVerifiedTime                     datetimeoffset(7) = null -- not a base table column
	,@MinLagDaysBetweenAttempts            smallint          = null -- not a base table column
	,@MaxAttemptsPerYear                   tinyint           = null -- not a base table column
	,@VendorExamID                         varchar(25)       = null -- not a base table column
	,@ExamRowGUID                          uniqueidentifier  = null -- not a base table column
	,@PersonDocTypeSCD                     varchar(15)       = null -- not a base table column
	,@PersonDocTypeLabel                   nvarchar(35)      = null -- not a base table column
	,@PersonDocTypeCategory                nvarchar(65)      = null -- not a base table column
	,@PersonDocTypeIsDefault               bit               = null -- not a base table column
	,@PersonDocTypeIsActive                bit               = null -- not a base table column
	,@PersonDocTypeRowGUID                 uniqueidentifier  = null -- not a base table column
	,@IsDeleteEnabled                      bit               = null -- not a base table column
	,@IsDeclaration                        bit               = null -- not a base table column
	,@IsExam                               bit               = null -- not a base table column
	,@IsDocument                           bit               = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : dbo.pRegistrationRequirement#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the dbo.RegistrationRequirement table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the dbo.RegistrationRequirement table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vRegistrationRequirement entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pRegistrationRequirement procedure. The extended procedure is only called
where it exists in the DB. The first parameter passed @Mode is set to either "update.pre" or "update.post" to provide context for
the extended logic.

The @zContext parameter is an additional construct available to support overrides where different results are produced based on
content provided in the XML from the client tier. This parameter may contain multiple values.

The "@IsReselected" parameter controls output and "@IsNullApplied" controls whether or not parameters with null values overwrite
corresponding columns on the row.

For client-tier calls using the Microsoft Entity Framework and RIA Services, the @IsReselected bit should be passed as 1 to
force re-selection of table columns + extended view columns (the entity view).

Values for parameters representing mandatory columns must be provided unless @IsNullApplied is passed as 0. If @IsNullApplied = 1
any parameter with a null value overwrites the corresponding column value with null.  @IsNullApplied defaults to 0 but should be
passed as 1 when calling through the entity framework domain service since all columns are mapped to the procedure.

If the @UpdateUser parameter is passed as the special value "SystemUser", then the system user established in sf.ConfigParam
is applied. This option is useful for conversion and system generated updates the user would not recognize as having caused. Any
other value provided for the parameter (including null) is overwritten with the current application user.

The @RowStamp parameter should always be passed when calling from the user interface. The @RowStamp parameter is used to
preemptively check for an overwrite.  The value should be passed as the RowStamp value from the row when it was last
retrieved into the UI. If the RowStamp on the record changes from the value passed, this procedure will raise an exception and
avoid the overwrite.  For calls from back-end procedures, the @RowStamp parameter can be left blank and it will default to the
current time stamp on the record (avoiding the need to look up the value prior to calling.)

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

		-- check parameters

		if @RegistrationRequirementSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@RegistrationRequirementSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @RegistrationRequirementLabel = ltrim(rtrim(@RegistrationRequirementLabel))
		set @RegistrationRequirementXID = ltrim(rtrim(@RegistrationRequirementXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
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
		if len(@UpdateUser) = 0 set @UpdateUser = null
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

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @RegistrationRequirementTypeSID       = isnull(@RegistrationRequirementTypeSID,rr.RegistrationRequirementTypeSID)
				,@RegistrationRequirementLabel         = isnull(@RegistrationRequirementLabel,rr.RegistrationRequirementLabel)
				,@RequirementDescription               = isnull(@RequirementDescription,rr.RequirementDescription)
				,@AdminGuidance                        = isnull(@AdminGuidance,rr.AdminGuidance)
				,@PersonDocTypeSID                     = isnull(@PersonDocTypeSID,rr.PersonDocTypeSID)
				,@ExamSID                              = isnull(@ExamSID,rr.ExamSID)
				,@ExpiryMonths                         = isnull(@ExpiryMonths,rr.ExpiryMonths)
				,@IsActive                             = isnull(@IsActive,rr.IsActive)
				,@UserDefinedColumns                   = isnull(@UserDefinedColumns,rr.UserDefinedColumns)
				,@RegistrationRequirementXID           = isnull(@RegistrationRequirementXID,rr.RegistrationRequirementXID)
				,@LegacyKey                            = isnull(@LegacyKey,rr.LegacyKey)
				,@UpdateUser                           = isnull(@UpdateUser,rr.UpdateUser)
				,@IsReselected                         = isnull(@IsReselected,rr.IsReselected)
				,@IsNullApplied                        = isnull(@IsNullApplied,rr.IsNullApplied)
				,@zContext                             = isnull(@zContext,rr.zContext)
				,@RegistrationRequirementTypeLabel     = isnull(@RegistrationRequirementTypeLabel,rr.RegistrationRequirementTypeLabel)
				,@RegistrationRequirementTypeCode      = isnull(@RegistrationRequirementTypeCode,rr.RegistrationRequirementTypeCode)
				,@RegistrationRequirementTypeCategory  = isnull(@RegistrationRequirementTypeCategory,rr.RegistrationRequirementTypeCategory)
				,@IsAppliedToPeople                    = isnull(@IsAppliedToPeople,rr.IsAppliedToPeople)
				,@IsAppliedToOrganizations             = isnull(@IsAppliedToOrganizations,rr.IsAppliedToOrganizations)
				,@RegistrationRequirementTypeIsDefault = isnull(@RegistrationRequirementTypeIsDefault,rr.RegistrationRequirementTypeIsDefault)
				,@RegistrationRequirementTypeIsActive  = isnull(@RegistrationRequirementTypeIsActive,rr.RegistrationRequirementTypeIsActive)
				,@RegistrationRequirementTypeRowGUID   = isnull(@RegistrationRequirementTypeRowGUID,rr.RegistrationRequirementTypeRowGUID)
				,@ExamName                             = isnull(@ExamName,rr.ExamName)
				,@ExamCategory                         = isnull(@ExamCategory,rr.ExamCategory)
				,@PassingScore                         = isnull(@PassingScore,rr.PassingScore)
				,@EffectiveTime                        = isnull(@EffectiveTime,rr.EffectiveTime)
				,@ExpiryTime                           = isnull(@ExpiryTime,rr.ExpiryTime)
				,@IsOnlineExam                         = isnull(@IsOnlineExam,rr.IsOnlineExam)
				,@IsEnabledOnPortal                    = isnull(@IsEnabledOnPortal,rr.IsEnabledOnPortal)
				,@Sequence                             = isnull(@Sequence,rr.Sequence)
				,@CultureSID                           = isnull(@CultureSID,rr.CultureSID)
				,@LastVerifiedTime                     = isnull(@LastVerifiedTime,rr.LastVerifiedTime)
				,@MinLagDaysBetweenAttempts            = isnull(@MinLagDaysBetweenAttempts,rr.MinLagDaysBetweenAttempts)
				,@MaxAttemptsPerYear                   = isnull(@MaxAttemptsPerYear,rr.MaxAttemptsPerYear)
				,@VendorExamID                         = isnull(@VendorExamID,rr.VendorExamID)
				,@ExamRowGUID                          = isnull(@ExamRowGUID,rr.ExamRowGUID)
				,@PersonDocTypeSCD                     = isnull(@PersonDocTypeSCD,rr.PersonDocTypeSCD)
				,@PersonDocTypeLabel                   = isnull(@PersonDocTypeLabel,rr.PersonDocTypeLabel)
				,@PersonDocTypeCategory                = isnull(@PersonDocTypeCategory,rr.PersonDocTypeCategory)
				,@PersonDocTypeIsDefault               = isnull(@PersonDocTypeIsDefault,rr.PersonDocTypeIsDefault)
				,@PersonDocTypeIsActive                = isnull(@PersonDocTypeIsActive,rr.PersonDocTypeIsActive)
				,@PersonDocTypeRowGUID                 = isnull(@PersonDocTypeRowGUID,rr.PersonDocTypeRowGUID)
				,@IsDeleteEnabled                      = isnull(@IsDeleteEnabled,rr.IsDeleteEnabled)
				,@IsDeclaration                        = isnull(@IsDeclaration,rr.IsDeclaration)
				,@IsExam                               = isnull(@IsExam,rr.IsExam)
				,@IsDocument                           = isnull(@IsDocument,rr.IsDocument)
			from
				dbo.vRegistrationRequirement rr
			where
				rr.RegistrationRequirementSID = @RegistrationRequirementSID

		end
		
		-- look up the FK value matching the system code if set; this allows
		-- FK values value to be set/updated based on system code values
		
		if @PersonDocTypeSCD is not null and @PersonDocTypeSID = (select x.PersonDocTypeSID from dbo.RegistrationRequirement x where x.RegistrationRequirementSID = @RegistrationRequirementSID)
		begin
		
			select
				@PersonDocTypeSID = x.PersonDocTypeSID
			from
				dbo.PersonDocType x
			where
				x.PersonDocTypeSCD = @PersonDocTypeSCD
		
		end

		-- block changing FK values to parent records which are inactive (UI should prevent this)
		
		if (select x.PersonDocTypeSID from dbo.RegistrationRequirement x where x.RegistrationRequirementSID = @RegistrationRequirementSID) <> @PersonDocTypeSID
		begin
			if (select x.IsActive from dbo.PersonDocType x where x.PersonDocTypeSID = @PersonDocTypeSID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'person doc type'
				
				raiserror(@errorText, 16, 1)
				
			end
		end
		
		if (select x.RegistrationRequirementTypeSID from dbo.RegistrationRequirement x where x.RegistrationRequirementSID = @RegistrationRequirementSID) <> @RegistrationRequirementTypeSID
		begin
			if (select x.IsActive from dbo.RegistrationRequirementType x where x.RegistrationRequirementTypeSID = @RegistrationRequirementTypeSID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'registration requirement type'
				
				raiserror(@errorText, 16, 1)
				
			end
		end

		-- apply the table-specific pre-update logic (if any)

		--! <PreUpdate>
		--  insert pre-update logic here ...
		--! </PreUpdate>
	
		-- call the extended version of the procedure (if it exists) for "update.pre" mode
		
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
				 @Mode                                 = 'update.pre'
				,@RegistrationRequirementSID           = @RegistrationRequirementSID
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
				,@UpdateUser                           = @UpdateUser
				,@RowStamp                             = @RowStamp
				,@IsReselected                         = @IsReselected
				,@IsNullApplied                        = @IsNullApplied
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

		-- update the record

		update
			dbo.RegistrationRequirement
		set
			 RegistrationRequirementTypeSID = @RegistrationRequirementTypeSID
			,RegistrationRequirementLabel = @RegistrationRequirementLabel
			,RequirementDescription = @RequirementDescription
			,AdminGuidance = @AdminGuidance
			,PersonDocTypeSID = @PersonDocTypeSID
			,ExamSID = @ExamSID
			,ExpiryMonths = @ExpiryMonths
			,IsActive = @IsActive
			,UserDefinedColumns = @UserDefinedColumns
			,RegistrationRequirementXID = @RegistrationRequirementXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			RegistrationRequirementSID = @RegistrationRequirementSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from dbo.RegistrationRequirement where RegistrationRequirementSID = @registrationRequirementSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'dbo.RegistrationRequirement'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'dbo.RegistrationRequirement'
					,@Arg2        = @registrationRequirementSID
				
				raiserror(@errorText, 18, 1)
			end

		end
		else if @rowsAffected <> 1
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The %1 operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'update'
				,@Arg2        = 'dbo.RegistrationRequirement'
				,@Arg3        = @rowsAffected
				,@Arg4        = @registrationRequirementSID
			
			raiserror(@errorText, 18, 1)
		end

		-- apply the table-specific post-update logic (if any)

		--! <PostUpdate>
		--  insert post-update logic here ...
		--! </PostUpdate>
	
		-- call the extended version of the procedure for update.post - if it exists
		
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
				 @Mode                                 = 'update.post'
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
				,@UpdateUser                           = @UpdateUser
				,@RowStamp                             = @RowStamp
				,@IsReselected                         = @IsReselected
				,@IsNullApplied                        = @IsNullApplied
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
