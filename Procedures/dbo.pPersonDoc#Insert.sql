SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pPersonDoc#Insert]
	 @PersonDocSID              int               = null output							-- identity value assigned to the new record
	,@PersonSID                 int               = null										-- required! if not passed value must be set in custom logic prior to insert
	,@PersonDocTypeSID          int               = null										-- required! if not passed value must be set in custom logic prior to insert
	,@DocumentTitle             nvarchar(100)     = null										-- required! if not passed value must be set in custom logic prior to insert
	,@AdditionalInfo            nvarchar(50)      = null										
	,@DocumentContent           varbinary(max)    = null										
	,@DocumentHTML              nvarchar(max)     = null										
	,@ArchivedTime              datetimeoffset(7) = null										
	,@FileTypeSID               int               = null										-- required! if not passed value must be set in custom logic prior to insert
	,@FileTypeSCD               varchar(8)        = null										-- required! if not passed value must be set in custom logic prior to insert
	,@TagList                   xml               = null										-- default: CONVERT(xml,N'<TagList/>',(0))
	,@DocumentNotes             nvarchar(max)     = null										
	,@ShowToRegistrant          bit               = null										-- default: CONVERT(bit,(0))
	,@ApplicationGrantSID       int               = null										
	,@IsRemoved                 bit               = null										-- default: CONVERT(bit,(0))
	,@ExpiryDate                date              = null										
	,@ApplicationReportSID      int               = null										
	,@ReportEntitySID           int               = null										
	,@CancelledTime             datetimeoffset(7) = null										
	,@ProcessedTime             datetimeoffset(7) = null										
	,@ContextLink               uniqueidentifier  = null										
	,@UserDefinedColumns        xml               = null										
	,@PersonDocXID              varchar(150)      = null										
	,@LegacyKey                 nvarchar(50)      = null										
	,@CreateUser                nvarchar(75)      = null										-- default: suser_sname()
	,@IsReselected              tinyint           = null										-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                  xml               = null										-- other values defining context for the insert (if any)
	,@PersonDocTypeSCD          varchar(15)       = null										-- not a base table column (default ignored)
	,@PersonDocTypeLabel        nvarchar(35)      = null										-- not a base table column (default ignored)
	,@PersonDocTypeCategory     nvarchar(65)      = null										-- not a base table column (default ignored)
	,@PersonDocTypeIsDefault    bit               = null										-- not a base table column (default ignored)
	,@PersonDocTypeIsActive     bit               = null										-- not a base table column (default ignored)
	,@PersonDocTypeRowGUID      uniqueidentifier  = null										-- not a base table column (default ignored)
	,@FileTypeFileTypeSCD       varchar(8)        = null										-- not a base table column (default ignored)
	,@FileTypeLabel             nvarchar(35)      = null										-- not a base table column (default ignored)
	,@MimeType                  varchar(255)      = null										-- not a base table column (default ignored)
	,@IsInline                  bit               = null										-- not a base table column (default ignored)
	,@FileTypeIsActive          bit               = null										-- not a base table column (default ignored)
	,@FileTypeRowGUID           uniqueidentifier  = null										-- not a base table column (default ignored)
	,@GenderSID                 int               = null										-- not a base table column (default ignored)
	,@NamePrefixSID             int               = null										-- not a base table column (default ignored)
	,@FirstName                 nvarchar(30)      = null										-- not a base table column (default ignored)
	,@CommonName                nvarchar(30)      = null										-- not a base table column (default ignored)
	,@MiddleNames               nvarchar(30)      = null										-- not a base table column (default ignored)
	,@LastName                  nvarchar(35)      = null										-- not a base table column (default ignored)
	,@BirthDate                 date              = null										-- not a base table column (default ignored)
	,@DeathDate                 date              = null										-- not a base table column (default ignored)
	,@HomePhone                 varchar(25)       = null										-- not a base table column (default ignored)
	,@MobilePhone               varchar(25)       = null										-- not a base table column (default ignored)
	,@IsTextMessagingEnabled    bit               = null										-- not a base table column (default ignored)
	,@ImportBatch               nvarchar(100)     = null										-- not a base table column (default ignored)
	,@PersonRowGUID             uniqueidentifier  = null										-- not a base table column (default ignored)
	,@ApplicationGrantSCD       varchar(30)       = null										-- not a base table column (default ignored)
	,@ApplicationGrantName      nvarchar(150)     = null										-- not a base table column (default ignored)
	,@ApplicationGrantIsDefault bit               = null										-- not a base table column (default ignored)
	,@ApplicationGrantRowGUID   uniqueidentifier  = null										-- not a base table column (default ignored)
	,@ApplicationReportName     nvarchar(65)      = null										-- not a base table column (default ignored)
	,@IconFillColor             char(9)           = null										-- not a base table column (default ignored)
	,@DisplayRank               tinyint           = null										-- not a base table column (default ignored)
	,@IsCustom                  bit               = null										-- not a base table column (default ignored)
	,@ApplicationReportRowGUID  uniqueidentifier  = null										-- not a base table column (default ignored)
	,@IsDeleteEnabled           bit               = null										-- not a base table column (default ignored)
	,@IsDocReplaced             bit               = null										-- not a base table column (default ignored)
	,@IsReadGranted             bit               = null										-- not a base table column (default ignored)
	,@IsReportPending           bit               = null										-- not a base table column (default ignored)
	,@IsReportCancelled         bit               = null										-- not a base table column (default ignored)
	,@ApplicationEntitySID      int               = null										-- not a base table column (default ignored)
	,@EntitySID                 int               = null										-- not a base table column (default ignored)
	,@IsPrimary                 bit               = null										-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pPersonDoc#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the dbo.PersonDoc table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the dbo.PersonDoc table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vPersonDoc entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pPersonDoc procedure. The extended procedure is only called
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

	set @PersonDocSID = null																								-- initialize output parameter

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

		set @DocumentTitle = ltrim(rtrim(@DocumentTitle))
		set @AdditionalInfo = ltrim(rtrim(@AdditionalInfo))
		set @DocumentHTML = ltrim(rtrim(@DocumentHTML))
		set @FileTypeSCD = ltrim(rtrim(@FileTypeSCD))
		set @DocumentNotes = ltrim(rtrim(@DocumentNotes))
		set @PersonDocXID = ltrim(rtrim(@PersonDocXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @CreateUser = ltrim(rtrim(@CreateUser))
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
		if len(@CreateUser) = 0 set @CreateUser = null
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

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @TagList = isnull(@TagList,CONVERT(xml,N'<TagList/>',(0)))
		set @ShowToRegistrant = isnull(@ShowToRegistrant,CONVERT(bit,(0)))
		set @IsRemoved = isnull(@IsRemoved,CONVERT(bit,(0)))
		set @CreateUser = isnull(@CreateUser,suser_sname())
		set @IsReselected         = isnull(@IsReselected        ,(0))
		
		-- ensure both the file type code (SCD) and key (SID) are provided - default from the value provided
		
		if @FileTypeSCD is null and @FileTypeSID is not null
		begin
		
			select
				@FileTypeSCD = ft.FileTypeSCD
			from
				sf.FileType ft
			where
				ft.FileTypeSID = @FileTypeSID
			and
				ft.IsActive = @ON
			
		end
		
		if @FileTypeSID is null and @FileTypeSCD is not null
		begin
		
			select
				@FileTypeSID = ft.FileTypeSID
			from
				sf.FileType ft
			where
				ft.FileTypeSCD = @FileTypeSCD
			and
				ft.IsActive = @ON
			
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
		
		if @PersonDocTypeSCD is not null
		begin
		
			select
				@PersonDocTypeSID = x.PersonDocTypeSID
			from
				dbo.PersonDocType x
			where
				x.PersonDocTypeSCD = @PersonDocTypeSCD
		
		end
		
		if @ApplicationGrantSCD is not null
		begin
		
			select
				@ApplicationGrantSID = x.ApplicationGrantSID
			from
				sf.ApplicationGrant x
			where
				x.ApplicationGrantSCD = @ApplicationGrantSCD
		
		end
		
		set @TagList = sf.fTagList#SetTagTimes(@TagList)											-- add times to the tags applied (if any)
		
		-- set default value on mandatory foreign keys where configured
		-- and if value not already assigned
		
		if @PersonDocTypeSID  is null select @PersonDocTypeSID  = x.PersonDocTypeSID from dbo.PersonDocType x where x.IsDefault = @ON

		-- apply the table-specific pre-insert logic (if any)

		--! <PreInsert>		
		-- Tim Edlund | Nov 2018
		-- If the title does not already include a time
		-- component, add it now (helps with uniqueness)

		if @DocumentTitle not like '% _M'
		begin
			set @DocumentTitle = ltrim(rtrim(@DocumentTitle)) + ' ' + format(sf.fNow(), 'dd-MMM-yyyy hh:mm tt');  -- add current time in client TZ to title
		end

		-- Tim Edlund | Feb 2017
		-- Ensure the name given to the document is unique.  If not unique,
		-- increment with a counter. First rename starts at 2 - "MyDoc Title(2)"

		declare
			 @i												int = 1																		-- counter for title name extension
			,@originalDocumentTitle		nvarchar(100) = @DocumentTitle							-- base document name

		while exists(select 1 from dbo.PersonDoc pd where pd.DocumentTitle = @DocumentTitle and pd.PersonSID = @PersonSID) and @i < 1000
		begin																																	-- terminate and raise duplicate key error if not resolved after 1000 iterations
			set @i += 1
			set @DocumentTitle = left(@originalDocumentTitle,73 - len(ltrim(cast(@i as nvarchar(4))))) + '(' + ltrim(cast(@i as nvarchar(4))) + ')'
		end
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
				r.RoutineName = 'pPersonDoc'
		)
		begin
		
			exec @errorNo = ext.pPersonDoc
				 @Mode                      = 'insert.pre'
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
				,@CreateUser                = @CreateUser
				,@IsReselected              = @IsReselected
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

		-- insert the record

		insert
			dbo.PersonDoc
		(
			 PersonSID
			,PersonDocTypeSID
			,DocumentTitle
			,AdditionalInfo
			,DocumentContent
			,DocumentHTML
			,ArchivedTime
			,FileTypeSID
			,FileTypeSCD
			,TagList
			,DocumentNotes
			,ShowToRegistrant
			,ApplicationGrantSID
			,IsRemoved
			,ExpiryDate
			,ApplicationReportSID
			,ReportEntitySID
			,CancelledTime
			,ProcessedTime
			,ContextLink
			,UserDefinedColumns
			,PersonDocXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @PersonSID
			,@PersonDocTypeSID
			,@DocumentTitle
			,@AdditionalInfo
			,@DocumentContent
			,@DocumentHTML
			,@ArchivedTime
			,@FileTypeSID
			,@FileTypeSCD
			,@TagList
			,@DocumentNotes
			,@ShowToRegistrant
			,@ApplicationGrantSID
			,@IsRemoved
			,@ExpiryDate
			,@ApplicationReportSID
			,@ReportEntitySID
			,@CancelledTime
			,@ProcessedTime
			,@ContextLink
			,@UserDefinedColumns
			,@PersonDocXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected = @@rowcount
			,@PersonDocSID = scope_identity()																		-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'dbo.PersonDoc'
				,@Arg3        = @rowsAffected
				,@Arg4        = @PersonDocSID
			
			raiserror(@errorText, 18, 1)
			
		end

		-- apply the table-specific post-insert logic (if any)

		--! <PostInsert>
		-- Tim Edlund | Nov 2018
		-- If context information was provided in the call
		-- then create it as part of the transaction. Note
		-- that the context is always established as PRIMARY

		if @ApplicationEntitySID is not null and @EntitySID is not null
		begin

			insert dbo.PersonDocContext
			(
				PersonDocSID
			 ,ApplicationEntitySID
			 ,EntitySID
			 ,IsPrimary
			 ,CreateUser
			 ,UpdateUser
			)
			values
			(
				 @PersonDocSID
				,@ApplicationEntitySID
				,@EntitySID
				,@ON
				,@CreateUser
				,@CreateUser
			)

		end
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
				r.RoutineName = 'pPersonDoc'
		)
		begin
		
			exec @errorNo = ext.pPersonDoc
				 @Mode                      = 'insert.post'
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
				,@CreateUser                = @CreateUser
				,@IsReselected              = @IsReselected
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
