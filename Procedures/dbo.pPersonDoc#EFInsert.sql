SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pPersonDoc#EFInsert]
	 @PersonSID                 int               = null										-- required! if not passed value must be set in custom logic prior to insert
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
Procedure : dbo.pPersonDoc#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pPersonDoc#Insert for use with MS Entity Framework (does not declare PK output parameter)
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is a wrapper for the standard insert procedure for the table. It is provided particularly for application using the
Microsoft Entity Framework (EF). The current version of the EF generates an error if an entity attribute is defined as an output
parameter. This procedure does not declare the primary key output parameter but passes all remaining parameters to the standard
insert procedure.

-------------------------------------------------------------------------------------------------------------------------------- */

begin
	set nocount on

	declare
		 @errorNo                                      int = 0								-- 0 no error, <50000 SQL error, else business rule
		,@tranCount                                    int = @@trancount			-- determines whether a wrapping transaction exists
		,@sprocName                                    nvarchar(128) = object_name(@@procid)						-- name of currently executing procedure
		,@xState                                       int										-- error state detected in catch block

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

		-- call the main procedure

		exec @errorNo = dbo.pPersonDoc#Insert
			 @PersonSID                 = @PersonSID
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
