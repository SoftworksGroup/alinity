SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pPersonDoc#Update]
	 @PersonDocSID              int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@PersonSID                 int               = null -- table column values to update:
	,@PersonDocTypeSID          int               = null
	,@DocumentTitle             nvarchar(100)     = null
	,@AdditionalInfo            nvarchar(50)      = null
	,@DocumentContent           varbinary(max)    = null
	,@DocumentHTML              nvarchar(max)     = null
	,@ArchivedTime              datetimeoffset(7) = null
	,@FileTypeSID               int               = null
	,@FileTypeSCD               varchar(8)        = null
	,@TagList                   xml               = null
	,@DocumentNotes             nvarchar(max)     = null
	,@ShowToRegistrant          bit               = null
	,@ApplicationGrantSID       int               = null
	,@IsRemoved                 bit               = null
	,@ExpiryDate                date              = null
	,@ApplicationReportSID      int               = null
	,@ReportEntitySID           int               = null
	,@CancelledTime             datetimeoffset(7) = null
	,@ProcessedTime             datetimeoffset(7) = null
	,@ContextLink               uniqueidentifier  = null
	,@UserDefinedColumns        xml               = null
	,@PersonDocXID              varchar(150)      = null
	,@LegacyKey                 nvarchar(50)      = null
	,@UpdateUser                nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                  timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected              tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied             bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext                  xml               = null -- other values defining context for the update (if any)
	,@PersonDocTypeSCD          varchar(15)       = null -- not a base table column
	,@PersonDocTypeLabel        nvarchar(35)      = null -- not a base table column
	,@PersonDocTypeCategory     nvarchar(65)      = null -- not a base table column
	,@PersonDocTypeIsDefault    bit               = null -- not a base table column
	,@PersonDocTypeIsActive     bit               = null -- not a base table column
	,@PersonDocTypeRowGUID      uniqueidentifier  = null -- not a base table column
	,@FileTypeFileTypeSCD       varchar(8)        = null -- not a base table column
	,@FileTypeLabel             nvarchar(35)      = null -- not a base table column
	,@MimeType                  varchar(255)      = null -- not a base table column
	,@IsInline                  bit               = null -- not a base table column
	,@FileTypeIsActive          bit               = null -- not a base table column
	,@FileTypeRowGUID           uniqueidentifier  = null -- not a base table column
	,@GenderSID                 int               = null -- not a base table column
	,@NamePrefixSID             int               = null -- not a base table column
	,@FirstName                 nvarchar(30)      = null -- not a base table column
	,@CommonName                nvarchar(30)      = null -- not a base table column
	,@MiddleNames               nvarchar(30)      = null -- not a base table column
	,@LastName                  nvarchar(35)      = null -- not a base table column
	,@BirthDate                 date              = null -- not a base table column
	,@DeathDate                 date              = null -- not a base table column
	,@HomePhone                 varchar(25)       = null -- not a base table column
	,@MobilePhone               varchar(25)       = null -- not a base table column
	,@IsTextMessagingEnabled    bit               = null -- not a base table column
	,@ImportBatch               nvarchar(100)     = null -- not a base table column
	,@PersonRowGUID             uniqueidentifier  = null -- not a base table column
	,@ApplicationGrantSCD       varchar(30)       = null -- not a base table column
	,@ApplicationGrantName      nvarchar(150)     = null -- not a base table column
	,@ApplicationGrantIsDefault bit               = null -- not a base table column
	,@ApplicationGrantRowGUID   uniqueidentifier  = null -- not a base table column
	,@ApplicationReportName     nvarchar(65)      = null -- not a base table column
	,@IconFillColor             char(9)           = null -- not a base table column
	,@DisplayRank               tinyint           = null -- not a base table column
	,@IsCustom                  bit               = null -- not a base table column
	,@ApplicationReportRowGUID  uniqueidentifier  = null -- not a base table column
	,@IsDeleteEnabled           bit               = null -- not a base table column
	,@IsDocReplaced             bit               = null -- not a base table column
	,@IsReadGranted             bit               = null -- not a base table column
	,@IsReportPending           bit               = null -- not a base table column
	,@IsReportCancelled         bit               = null -- not a base table column
	,@ApplicationEntitySID      int               = null -- not a base table column
	,@EntitySID                 int               = null -- not a base table column
	,@IsPrimary                 bit               = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : dbo.pPersonDoc#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the dbo.PersonDoc table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the dbo.PersonDoc table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vPersonDoc entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pPersonDoc procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fPersonDocCheck to test all rules.

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

		if @PersonDocSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@PersonDocSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @DocumentTitle = ltrim(rtrim(@DocumentTitle))
		set @AdditionalInfo = ltrim(rtrim(@AdditionalInfo))
		set @DocumentHTML = ltrim(rtrim(@DocumentHTML))
		set @FileTypeSCD = ltrim(rtrim(@FileTypeSCD))
		set @DocumentNotes = ltrim(rtrim(@DocumentNotes))
		set @PersonDocXID = ltrim(rtrim(@PersonDocXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
		set @PersonDocTypeSCD = ltrim(rtrim(@PersonDocTypeSCD))
		set @PersonDocTypeLabel = ltrim(rtrim(@PersonDocTypeLabel))
		set @PersonDocTypeCategory = ltrim(rtrim(@PersonDocTypeCategory))
		set @FileTypeFileTypeSCD = ltrim(rtrim(@FileTypeFileTypeSCD))
		set @FileTypeLabel = ltrim(rtrim(@FileTypeLabel))
		set @MimeType = ltrim(rtrim(@MimeType))
		set @FirstName = ltrim(rtrim(@FirstName))
		set @CommonName = ltrim(rtrim(@CommonName))
		set @MiddleNames = ltrim(rtrim(@MiddleNames))
		set @LastName = ltrim(rtrim(@LastName))
		set @HomePhone = ltrim(rtrim(@HomePhone))
		set @MobilePhone = ltrim(rtrim(@MobilePhone))
		set @ImportBatch = ltrim(rtrim(@ImportBatch))
		set @ApplicationGrantSCD = ltrim(rtrim(@ApplicationGrantSCD))
		set @ApplicationGrantName = ltrim(rtrim(@ApplicationGrantName))
		set @ApplicationReportName = ltrim(rtrim(@ApplicationReportName))
		set @IconFillColor = ltrim(rtrim(@IconFillColor))

		-- set zero length strings to null to avoid storing them in the record

		if len(@DocumentTitle) = 0 set @DocumentTitle = null
		if len(@AdditionalInfo) = 0 set @AdditionalInfo = null
		if len(@DocumentHTML) = 0 set @DocumentHTML = null
		if len(@FileTypeSCD) = 0 set @FileTypeSCD = null
		if len(@DocumentNotes) = 0 set @DocumentNotes = null
		if len(@PersonDocXID) = 0 set @PersonDocXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@UpdateUser) = 0 set @UpdateUser = null
		if len(@PersonDocTypeSCD) = 0 set @PersonDocTypeSCD = null
		if len(@PersonDocTypeLabel) = 0 set @PersonDocTypeLabel = null
		if len(@PersonDocTypeCategory) = 0 set @PersonDocTypeCategory = null
		if len(@FileTypeFileTypeSCD) = 0 set @FileTypeFileTypeSCD = null
		if len(@FileTypeLabel) = 0 set @FileTypeLabel = null
		if len(@MimeType) = 0 set @MimeType = null
		if len(@FirstName) = 0 set @FirstName = null
		if len(@CommonName) = 0 set @CommonName = null
		if len(@MiddleNames) = 0 set @MiddleNames = null
		if len(@LastName) = 0 set @LastName = null
		if len(@HomePhone) = 0 set @HomePhone = null
		if len(@MobilePhone) = 0 set @MobilePhone = null
		if len(@ImportBatch) = 0 set @ImportBatch = null
		if len(@ApplicationGrantSCD) = 0 set @ApplicationGrantSCD = null
		if len(@ApplicationGrantName) = 0 set @ApplicationGrantName = null
		if len(@ApplicationReportName) = 0 set @ApplicationReportName = null
		if len(@IconFillColor) = 0 set @IconFillColor = null

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @PersonSID                 = isnull(@PersonSID,pd.PersonSID)
				,@PersonDocTypeSID          = isnull(@PersonDocTypeSID,pd.PersonDocTypeSID)
				,@DocumentTitle             = isnull(@DocumentTitle,pd.DocumentTitle)
				,@AdditionalInfo            = isnull(@AdditionalInfo,pd.AdditionalInfo)
				,@DocumentContent           = isnull(@DocumentContent,pd.DocumentContent)
				,@DocumentHTML              = isnull(@DocumentHTML,pd.DocumentHTML)
				,@ArchivedTime              = isnull(@ArchivedTime,pd.ArchivedTime)
				,@FileTypeSID               = isnull(@FileTypeSID,pd.FileTypeSID)
				,@FileTypeSCD               = isnull(@FileTypeSCD,pd.FileTypeSCD)
				,@TagList                   = isnull(@TagList,pd.TagList)
				,@DocumentNotes             = isnull(@DocumentNotes,pd.DocumentNotes)
				,@ShowToRegistrant          = isnull(@ShowToRegistrant,pd.ShowToRegistrant)
				,@ApplicationGrantSID       = isnull(@ApplicationGrantSID,pd.ApplicationGrantSID)
				,@IsRemoved                 = isnull(@IsRemoved,pd.IsRemoved)
				,@ExpiryDate                = isnull(@ExpiryDate,pd.ExpiryDate)
				,@ApplicationReportSID      = isnull(@ApplicationReportSID,pd.ApplicationReportSID)
				,@ReportEntitySID           = isnull(@ReportEntitySID,pd.ReportEntitySID)
				,@CancelledTime             = isnull(@CancelledTime,pd.CancelledTime)
				,@ProcessedTime             = isnull(@ProcessedTime,pd.ProcessedTime)
				,@ContextLink               = isnull(@ContextLink,pd.ContextLink)
				,@UserDefinedColumns        = isnull(@UserDefinedColumns,pd.UserDefinedColumns)
				,@PersonDocXID              = isnull(@PersonDocXID,pd.PersonDocXID)
				,@LegacyKey                 = isnull(@LegacyKey,pd.LegacyKey)
				,@UpdateUser                = isnull(@UpdateUser,pd.UpdateUser)
				,@IsReselected              = isnull(@IsReselected,pd.IsReselected)
				,@IsNullApplied             = isnull(@IsNullApplied,pd.IsNullApplied)
				,@zContext                  = isnull(@zContext,pd.zContext)
				,@PersonDocTypeSCD          = isnull(@PersonDocTypeSCD,pd.PersonDocTypeSCD)
				,@PersonDocTypeLabel        = isnull(@PersonDocTypeLabel,pd.PersonDocTypeLabel)
				,@PersonDocTypeCategory     = isnull(@PersonDocTypeCategory,pd.PersonDocTypeCategory)
				,@PersonDocTypeIsDefault    = isnull(@PersonDocTypeIsDefault,pd.PersonDocTypeIsDefault)
				,@PersonDocTypeIsActive     = isnull(@PersonDocTypeIsActive,pd.PersonDocTypeIsActive)
				,@PersonDocTypeRowGUID      = isnull(@PersonDocTypeRowGUID,pd.PersonDocTypeRowGUID)
				,@FileTypeFileTypeSCD       = isnull(@FileTypeFileTypeSCD,pd.FileTypeFileTypeSCD)
				,@FileTypeLabel             = isnull(@FileTypeLabel,pd.FileTypeLabel)
				,@MimeType                  = isnull(@MimeType,pd.MimeType)
				,@IsInline                  = isnull(@IsInline,pd.IsInline)
				,@FileTypeIsActive          = isnull(@FileTypeIsActive,pd.FileTypeIsActive)
				,@FileTypeRowGUID           = isnull(@FileTypeRowGUID,pd.FileTypeRowGUID)
				,@GenderSID                 = isnull(@GenderSID,pd.GenderSID)
				,@NamePrefixSID             = isnull(@NamePrefixSID,pd.NamePrefixSID)
				,@FirstName                 = isnull(@FirstName,pd.FirstName)
				,@CommonName                = isnull(@CommonName,pd.CommonName)
				,@MiddleNames               = isnull(@MiddleNames,pd.MiddleNames)
				,@LastName                  = isnull(@LastName,pd.LastName)
				,@BirthDate                 = isnull(@BirthDate,pd.BirthDate)
				,@DeathDate                 = isnull(@DeathDate,pd.DeathDate)
				,@HomePhone                 = isnull(@HomePhone,pd.HomePhone)
				,@MobilePhone               = isnull(@MobilePhone,pd.MobilePhone)
				,@IsTextMessagingEnabled    = isnull(@IsTextMessagingEnabled,pd.IsTextMessagingEnabled)
				,@ImportBatch               = isnull(@ImportBatch,pd.ImportBatch)
				,@PersonRowGUID             = isnull(@PersonRowGUID,pd.PersonRowGUID)
				,@ApplicationGrantSCD       = isnull(@ApplicationGrantSCD,pd.ApplicationGrantSCD)
				,@ApplicationGrantName      = isnull(@ApplicationGrantName,pd.ApplicationGrantName)
				,@ApplicationGrantIsDefault = isnull(@ApplicationGrantIsDefault,pd.ApplicationGrantIsDefault)
				,@ApplicationGrantRowGUID   = isnull(@ApplicationGrantRowGUID,pd.ApplicationGrantRowGUID)
				,@ApplicationReportName     = isnull(@ApplicationReportName,pd.ApplicationReportName)
				,@IconFillColor             = isnull(@IconFillColor,pd.IconFillColor)
				,@DisplayRank               = isnull(@DisplayRank,pd.DisplayRank)
				,@IsCustom                  = isnull(@IsCustom,pd.IsCustom)
				,@ApplicationReportRowGUID  = isnull(@ApplicationReportRowGUID,pd.ApplicationReportRowGUID)
				,@IsDeleteEnabled           = isnull(@IsDeleteEnabled,pd.IsDeleteEnabled)
				,@IsDocReplaced             = isnull(@IsDocReplaced,pd.IsDocReplaced)
				,@IsReadGranted             = isnull(@IsReadGranted,pd.IsReadGranted)
				,@IsReportPending           = isnull(@IsReportPending,pd.IsReportPending)
				,@IsReportCancelled         = isnull(@IsReportCancelled,pd.IsReportCancelled)
				,@ApplicationEntitySID      = isnull(@ApplicationEntitySID,pd.ApplicationEntitySID)
				,@EntitySID                 = isnull(@EntitySID,pd.EntitySID)
				,@IsPrimary                 = isnull(@IsPrimary,pd.IsPrimary)
			from
				dbo.vPersonDoc pd
			where
				pd.PersonDocSID = @PersonDocSID

		end
		
		-- ensure the file type SID value matches the code being set; a trigger
		-- enforces the rule for updates outside of the EF sprocs
		
		select
			@FileTypeSID = ft.FileTypeSID
		from
			sf.FileType ft
		where
			ft.FileTypeSCD = @FileTypeSCD
		and
			ft.IsActive = @ON
		
		if @@rowcount = 0
		begin
		
			exec sf.pMessage#Get
				@MessageSCD  = 'FileTypeNotFound'
				,@MessageText = @errorText output
				,@DefaultText = N'The file type "%1" is not supported. Upload a different file or ask your administrator if this type can be added to the configuration.'
				,@Arg1        = @FileTypeSCD
		
			raiserror(@errorText, 16, 1)
		end
		
		-- look up the FK value matching the system code if set; this allows
		-- FK values value to be set/updated based on system code values
		
		if @PersonDocTypeSCD is not null and @PersonDocTypeSID = (select x.PersonDocTypeSID from dbo.PersonDoc x where x.PersonDocSID = @PersonDocSID)
		begin
		
			select
				@PersonDocTypeSID = x.PersonDocTypeSID
			from
				dbo.PersonDocType x
			where
				x.PersonDocTypeSCD = @PersonDocTypeSCD
		
		end
		
		if @ApplicationGrantSCD is not null and @ApplicationGrantSID = (select x.ApplicationGrantSID from dbo.PersonDoc x where x.PersonDocSID = @PersonDocSID)
		begin
		
			select
				@ApplicationGrantSID = x.ApplicationGrantSID
			from
				sf.ApplicationGrant x
			where
				x.ApplicationGrantSCD = @ApplicationGrantSCD
		
		end
		
		set @TagList = sf.fTagList#SetTagTimes(@TagList)											-- add times to the new tags applied (if any)

		-- block changing FK values to parent records which are inactive (UI should prevent this)
		
		if (select x.FileTypeSID from dbo.PersonDoc x where x.PersonDocSID = @PersonDocSID) <> @FileTypeSID
		begin
			if (select x.IsActive from sf.FileType x where x.FileTypeSID = @FileTypeSID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'file type'
				
				raiserror(@errorText, 16, 1)
				
			end
		end
		
		if (select x.PersonDocTypeSID from dbo.PersonDoc x where x.PersonDocSID = @PersonDocSID) <> @PersonDocTypeSID
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

		-- apply the table-specific pre-update logic (if any)

		--! <PreUpdate>
		-- Kris Dawson | Mar 2018
		-- If IsReportCancelled is on but CancelledTime is null set CancelledTime

		if @IsReportCancelled = @ON and @CancelledTime is null set @CancelledTime = sysdatetimeoffset()
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
				r.RoutineName = 'pPersonDoc'
		)
		begin
		
			exec @errorNo = ext.pPersonDoc
				 @Mode                      = 'update.pre'
				,@PersonDocSID              = @PersonDocSID
				,@PersonSID                 = @PersonSID output
				,@PersonDocTypeSID          = @PersonDocTypeSID output
				,@DocumentTitle             = @DocumentTitle output
				,@AdditionalInfo            = @AdditionalInfo output
				,@DocumentContent           = @DocumentContent output
				,@DocumentHTML              = @DocumentHTML output
				,@ArchivedTime              = @ArchivedTime output
				,@FileTypeSID               = @FileTypeSID output
				,@FileTypeSCD               = @FileTypeSCD output
				,@TagList                   = @TagList output
				,@DocumentNotes             = @DocumentNotes output
				,@ShowToRegistrant          = @ShowToRegistrant output
				,@ApplicationGrantSID       = @ApplicationGrantSID output
				,@IsRemoved                 = @IsRemoved output
				,@ExpiryDate                = @ExpiryDate output
				,@ApplicationReportSID      = @ApplicationReportSID output
				,@ReportEntitySID           = @ReportEntitySID output
				,@CancelledTime             = @CancelledTime output
				,@ProcessedTime             = @ProcessedTime output
				,@ContextLink               = @ContextLink output
				,@UserDefinedColumns        = @UserDefinedColumns output
				,@PersonDocXID              = @PersonDocXID output
				,@LegacyKey                 = @LegacyKey output
				,@UpdateUser                = @UpdateUser
				,@RowStamp                  = @RowStamp
				,@IsReselected              = @IsReselected
				,@IsNullApplied             = @IsNullApplied
				,@zContext                  = @zContext
				,@PersonDocTypeSCD          = @PersonDocTypeSCD
				,@PersonDocTypeLabel        = @PersonDocTypeLabel
				,@PersonDocTypeCategory     = @PersonDocTypeCategory
				,@PersonDocTypeIsDefault    = @PersonDocTypeIsDefault
				,@PersonDocTypeIsActive     = @PersonDocTypeIsActive
				,@PersonDocTypeRowGUID      = @PersonDocTypeRowGUID
				,@FileTypeFileTypeSCD       = @FileTypeFileTypeSCD
				,@FileTypeLabel             = @FileTypeLabel
				,@MimeType                  = @MimeType
				,@IsInline                  = @IsInline
				,@FileTypeIsActive          = @FileTypeIsActive
				,@FileTypeRowGUID           = @FileTypeRowGUID
				,@GenderSID                 = @GenderSID
				,@NamePrefixSID             = @NamePrefixSID
				,@FirstName                 = @FirstName
				,@CommonName                = @CommonName
				,@MiddleNames               = @MiddleNames
				,@LastName                  = @LastName
				,@BirthDate                 = @BirthDate
				,@DeathDate                 = @DeathDate
				,@HomePhone                 = @HomePhone
				,@MobilePhone               = @MobilePhone
				,@IsTextMessagingEnabled    = @IsTextMessagingEnabled
				,@ImportBatch               = @ImportBatch
				,@PersonRowGUID             = @PersonRowGUID
				,@ApplicationGrantSCD       = @ApplicationGrantSCD
				,@ApplicationGrantName      = @ApplicationGrantName
				,@ApplicationGrantIsDefault = @ApplicationGrantIsDefault
				,@ApplicationGrantRowGUID   = @ApplicationGrantRowGUID
				,@ApplicationReportName     = @ApplicationReportName
				,@IconFillColor             = @IconFillColor
				,@DisplayRank               = @DisplayRank
				,@IsCustom                  = @IsCustom
				,@ApplicationReportRowGUID  = @ApplicationReportRowGUID
				,@IsDeleteEnabled           = @IsDeleteEnabled
				,@IsDocReplaced             = @IsDocReplaced
				,@IsReadGranted             = @IsReadGranted
				,@IsReportPending           = @IsReportPending
				,@IsReportCancelled         = @IsReportCancelled
				,@ApplicationEntitySID      = @ApplicationEntitySID
				,@EntitySID                 = @EntitySID
				,@IsPrimary                 = @IsPrimary
		
		end

		-- update the record

		update
			dbo.PersonDoc
		set
			 PersonSID = @PersonSID
			,PersonDocTypeSID = @PersonDocTypeSID
			,DocumentTitle = @DocumentTitle
			,AdditionalInfo = @AdditionalInfo
			,DocumentContent = @DocumentContent
			,DocumentHTML = @DocumentHTML
			,ArchivedTime = @ArchivedTime
			,FileTypeSID = @FileTypeSID
			,FileTypeSCD = @FileTypeSCD
			,TagList = @TagList
			,DocumentNotes = @DocumentNotes
			,ShowToRegistrant = @ShowToRegistrant
			,ApplicationGrantSID = @ApplicationGrantSID
			,IsRemoved = @IsRemoved
			,ExpiryDate = @ExpiryDate
			,ApplicationReportSID = @ApplicationReportSID
			,ReportEntitySID = @ReportEntitySID
			,CancelledTime = @CancelledTime
			,ProcessedTime = @ProcessedTime
			,ContextLink = @ContextLink
			,UserDefinedColumns = @UserDefinedColumns
			,PersonDocXID = @PersonDocXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			PersonDocSID = @PersonDocSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from dbo.PersonDoc where PersonDocSID = @personDocSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'dbo.PersonDoc'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'dbo.PersonDoc'
					,@Arg2        = @personDocSID
				
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
				,@Arg2        = 'dbo.PersonDoc'
				,@Arg3        = @rowsAffected
				,@Arg4        = @personDocSID
			
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
				r.RoutineName = 'pPersonDoc'
		)
		begin
		
			exec @errorNo = ext.pPersonDoc
				 @Mode                      = 'update.post'
				,@PersonDocSID              = @PersonDocSID
				,@PersonSID                 = @PersonSID
				,@PersonDocTypeSID          = @PersonDocTypeSID
				,@DocumentTitle             = @DocumentTitle
				,@AdditionalInfo            = @AdditionalInfo
				,@DocumentContent           = @DocumentContent
				,@DocumentHTML              = @DocumentHTML
				,@ArchivedTime              = @ArchivedTime
				,@FileTypeSID               = @FileTypeSID
				,@FileTypeSCD               = @FileTypeSCD
				,@TagList                   = @TagList
				,@DocumentNotes             = @DocumentNotes
				,@ShowToRegistrant          = @ShowToRegistrant
				,@ApplicationGrantSID       = @ApplicationGrantSID
				,@IsRemoved                 = @IsRemoved
				,@ExpiryDate                = @ExpiryDate
				,@ApplicationReportSID      = @ApplicationReportSID
				,@ReportEntitySID           = @ReportEntitySID
				,@CancelledTime             = @CancelledTime
				,@ProcessedTime             = @ProcessedTime
				,@ContextLink               = @ContextLink
				,@UserDefinedColumns        = @UserDefinedColumns
				,@PersonDocXID              = @PersonDocXID
				,@LegacyKey                 = @LegacyKey
				,@UpdateUser                = @UpdateUser
				,@RowStamp                  = @RowStamp
				,@IsReselected              = @IsReselected
				,@IsNullApplied             = @IsNullApplied
				,@zContext                  = @zContext
				,@PersonDocTypeSCD          = @PersonDocTypeSCD
				,@PersonDocTypeLabel        = @PersonDocTypeLabel
				,@PersonDocTypeCategory     = @PersonDocTypeCategory
				,@PersonDocTypeIsDefault    = @PersonDocTypeIsDefault
				,@PersonDocTypeIsActive     = @PersonDocTypeIsActive
				,@PersonDocTypeRowGUID      = @PersonDocTypeRowGUID
				,@FileTypeFileTypeSCD       = @FileTypeFileTypeSCD
				,@FileTypeLabel             = @FileTypeLabel
				,@MimeType                  = @MimeType
				,@IsInline                  = @IsInline
				,@FileTypeIsActive          = @FileTypeIsActive
				,@FileTypeRowGUID           = @FileTypeRowGUID
				,@GenderSID                 = @GenderSID
				,@NamePrefixSID             = @NamePrefixSID
				,@FirstName                 = @FirstName
				,@CommonName                = @CommonName
				,@MiddleNames               = @MiddleNames
				,@LastName                  = @LastName
				,@BirthDate                 = @BirthDate
				,@DeathDate                 = @DeathDate
				,@HomePhone                 = @HomePhone
				,@MobilePhone               = @MobilePhone
				,@IsTextMessagingEnabled    = @IsTextMessagingEnabled
				,@ImportBatch               = @ImportBatch
				,@PersonRowGUID             = @PersonRowGUID
				,@ApplicationGrantSCD       = @ApplicationGrantSCD
				,@ApplicationGrantName      = @ApplicationGrantName
				,@ApplicationGrantIsDefault = @ApplicationGrantIsDefault
				,@ApplicationGrantRowGUID   = @ApplicationGrantRowGUID
				,@ApplicationReportName     = @ApplicationReportName
				,@IconFillColor             = @IconFillColor
				,@DisplayRank               = @DisplayRank
				,@IsCustom                  = @IsCustom
				,@ApplicationReportRowGUID  = @ApplicationReportRowGUID
				,@IsDeleteEnabled           = @IsDeleteEnabled
				,@IsDocReplaced             = @IsDocReplaced
				,@IsReadGranted             = @IsReadGranted
				,@IsReportPending           = @IsReportPending
				,@IsReportCancelled         = @IsReportCancelled
				,@ApplicationEntitySID      = @ApplicationEntitySID
				,@EntitySID                 = @EntitySID
				,@IsPrimary                 = @IsPrimary
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.PersonDocSID
			from
				dbo.vPersonDoc ent
			where
				ent.PersonDocSID = @PersonDocSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.PersonDocSID
				,ent.PersonSID
				,ent.PersonDocTypeSID
				,ent.DocumentTitle
				,ent.AdditionalInfo
				,ent.DocumentContent
				,ent.DocumentHTML
				,ent.ArchivedTime
				,ent.FileTypeSID
				,ent.FileTypeSCD
				,ent.TagList
				,ent.DocumentNotes
				,ent.ShowToRegistrant
				,ent.ApplicationGrantSID
				,ent.IsRemoved
				,ent.ExpiryDate
				,ent.ApplicationReportSID
				,ent.ReportEntitySID
				,ent.CancelledTime
				,ent.ProcessedTime
				,ent.ContextLink
				,ent.UserDefinedColumns
				,ent.PersonDocXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.PersonDocTypeSCD
				,ent.PersonDocTypeLabel
				,ent.PersonDocTypeCategory
				,ent.PersonDocTypeIsDefault
				,ent.PersonDocTypeIsActive
				,ent.PersonDocTypeRowGUID
				,ent.FileTypeFileTypeSCD
				,ent.FileTypeLabel
				,ent.MimeType
				,ent.IsInline
				,ent.FileTypeIsActive
				,ent.FileTypeRowGUID
				,ent.GenderSID
				,ent.NamePrefixSID
				,ent.FirstName
				,ent.CommonName
				,ent.MiddleNames
				,ent.LastName
				,ent.BirthDate
				,ent.DeathDate
				,ent.HomePhone
				,ent.MobilePhone
				,ent.IsTextMessagingEnabled
				,ent.ImportBatch
				,ent.PersonRowGUID
				,ent.ApplicationGrantSCD
				,ent.ApplicationGrantName
				,ent.ApplicationGrantIsDefault
				,ent.ApplicationGrantRowGUID
				,ent.ApplicationReportName
				,ent.IconFillColor
				,ent.DisplayRank
				,ent.IsCustom
				,ent.ApplicationReportRowGUID
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
				,ent.IsDocReplaced
				,ent.IsReadGranted
				,ent.IsReportPending
				,ent.IsReportCancelled
				,ent.ApplicationEntitySID
				,ent.EntitySID
				,ent.IsPrimary
			from
				dbo.vPersonDoc ent
			where
				ent.PersonDocSID = @PersonDocSID

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
