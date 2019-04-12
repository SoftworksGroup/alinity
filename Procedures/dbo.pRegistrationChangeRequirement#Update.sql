SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrationChangeRequirement#Update]
	 @RegistrationChangeRequirementSID        int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@RegistrationChangeSID                   int               = null -- table column values to update:
	,@RegistrationRequirementSID              int               = null
	,@PersonDocSID                            int               = null
	,@RegistrantExamSID                       int               = null
	,@ExpiryMonths                            smallint          = null
	,@RequirementStatusSID                    int               = null
	,@RequirementSequence                     int               = null
	,@UserDefinedColumns                      xml               = null
	,@RegistrationChangeRequirementXID        varchar(150)      = null
	,@LegacyKey                               nvarchar(50)      = null
	,@UpdateUser                              nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp                                timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected                            tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied                           bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext                                xml               = null -- other values defining context for the update (if any)
	,@RegistrationSID                         int               = null -- not a base table column
	,@PracticeRegisterSectionSID              int               = null -- not a base table column
	,@RegistrationYear                        smallint          = null -- not a base table column
	,@NextFollowUp                            date              = null -- not a base table column
	,@RegistrationEffective                   date              = null -- not a base table column
	,@ReservedRegistrantNo                    varchar(50)       = null -- not a base table column
	,@ReasonSID                               int               = null -- not a base table column
	,@RegistrationChangeInvoiceSID            int               = null -- not a base table column
	,@ComplaintSID                            int               = null -- not a base table column
	,@RegistrationChangeRowGUID               uniqueidentifier  = null -- not a base table column
	,@RegistrationRequirementTypeSID          int               = null -- not a base table column
	,@RegistrationRequirementLabel            nvarchar(35)      = null -- not a base table column
	,@RegistrationRequirementPersonDocTypeSID int               = null -- not a base table column
	,@RegistrationRequirementExamSID          int               = null -- not a base table column
	,@RegistrationRequirementExpiryMonths     smallint          = null -- not a base table column
	,@RegistrationRequirementIsActive         bit               = null -- not a base table column
	,@RegistrationRequirementRowGUID          uniqueidentifier  = null -- not a base table column
	,@RequirementStatusSCD                    varchar(10)       = null -- not a base table column
	,@RequirementStatusLabel                  nvarchar(35)      = null -- not a base table column
	,@IsFinal                                 bit               = null -- not a base table column
	,@RequirementStatusSequence               int               = null -- not a base table column
	,@RequirementStatusIsDefault              bit               = null -- not a base table column
	,@RequirementStatusRowGUID                uniqueidentifier  = null -- not a base table column
	,@PersonSID                               int               = null -- not a base table column
	,@PersonDocPersonDocTypeSID               int               = null -- not a base table column
	,@DocumentTitle                           nvarchar(100)     = null -- not a base table column
	,@AdditionalInfo                          nvarchar(50)      = null -- not a base table column
	,@ArchivedTime                            datetimeoffset(7) = null -- not a base table column
	,@FileTypeSID                             int               = null -- not a base table column
	,@FileTypeSCD                             varchar(8)        = null -- not a base table column
	,@ShowToRegistrant                        bit               = null -- not a base table column
	,@ApplicationGrantSID                     int               = null -- not a base table column
	,@IsRemoved                               bit               = null -- not a base table column
	,@ExpiryDate                              date              = null -- not a base table column
	,@ApplicationReportSID                    int               = null -- not a base table column
	,@ReportEntitySID                         int               = null -- not a base table column
	,@PersonDocCancelledTime                  datetimeoffset(7) = null -- not a base table column
	,@PersonDocProcessedTime                  datetimeoffset(7) = null -- not a base table column
	,@ContextLink                             uniqueidentifier  = null -- not a base table column
	,@PersonDocRowGUID                        uniqueidentifier  = null -- not a base table column
	,@RegistrantSID                           int               = null -- not a base table column
	,@RegistrantExamExamSID                   int               = null -- not a base table column
	,@ExamDate                                date              = null -- not a base table column
	,@ExamResultDate                          date              = null -- not a base table column
	,@PassingScore                            int               = null -- not a base table column
	,@Score                                   int               = null -- not a base table column
	,@ExamStatusSID                           int               = null -- not a base table column
	,@SchedulingPreferences                   nvarchar(1000)    = null -- not a base table column
	,@AssignedLocation                        varchar(15)       = null -- not a base table column
	,@ExamReference                           varchar(25)       = null -- not a base table column
	,@ExamOfferingSID                         int               = null -- not a base table column
	,@RegistrantExamInvoiceSID                int               = null -- not a base table column
	,@ConfirmedTime                           datetimeoffset(7) = null -- not a base table column
	,@RegistrantExamCancelledTime             datetimeoffset(7) = null -- not a base table column
	,@RegistrantExamProcessedTime             datetimeoffset(7) = null -- not a base table column
	,@RegistrantExamRowGUID                   uniqueidentifier  = null -- not a base table column
	,@IsDeleteEnabled                         bit               = null -- not a base table column
	,@IsMandatory                             bit               = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : dbo.pRegistrationChangeRequirement#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the dbo.RegistrationChangeRequirement table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the dbo.RegistrationChangeRequirement table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vRegistrationChangeRequirement entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pRegistrationChangeRequirement procedure. The extended procedure is only called
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

Business rule compliance is checked through a table constraint which calls fRegistrationChangeRequirementCheck to test all rules.

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

		if @RegistrationChangeRequirementSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@RegistrationChangeRequirementSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @RegistrationChangeRequirementXID = ltrim(rtrim(@RegistrationChangeRequirementXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
		set @ReservedRegistrantNo = ltrim(rtrim(@ReservedRegistrantNo))
		set @RegistrationRequirementLabel = ltrim(rtrim(@RegistrationRequirementLabel))
		set @RequirementStatusSCD = ltrim(rtrim(@RequirementStatusSCD))
		set @RequirementStatusLabel = ltrim(rtrim(@RequirementStatusLabel))
		set @DocumentTitle = ltrim(rtrim(@DocumentTitle))
		set @AdditionalInfo = ltrim(rtrim(@AdditionalInfo))
		set @FileTypeSCD = ltrim(rtrim(@FileTypeSCD))
		set @SchedulingPreferences = ltrim(rtrim(@SchedulingPreferences))
		set @AssignedLocation = ltrim(rtrim(@AssignedLocation))
		set @ExamReference = ltrim(rtrim(@ExamReference))

		-- set zero length strings to null to avoid storing them in the record

		if len(@RegistrationChangeRequirementXID) = 0 set @RegistrationChangeRequirementXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@UpdateUser) = 0 set @UpdateUser = null
		if len(@ReservedRegistrantNo) = 0 set @ReservedRegistrantNo = null
		if len(@RegistrationRequirementLabel) = 0 set @RegistrationRequirementLabel = null
		if len(@RequirementStatusSCD) = 0 set @RequirementStatusSCD = null
		if len(@RequirementStatusLabel) = 0 set @RequirementStatusLabel = null
		if len(@DocumentTitle) = 0 set @DocumentTitle = null
		if len(@AdditionalInfo) = 0 set @AdditionalInfo = null
		if len(@FileTypeSCD) = 0 set @FileTypeSCD = null
		if len(@SchedulingPreferences) = 0 set @SchedulingPreferences = null
		if len(@AssignedLocation) = 0 set @AssignedLocation = null
		if len(@ExamReference) = 0 set @ExamReference = null

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @RegistrationChangeSID                   = isnull(@RegistrationChangeSID,rcr.RegistrationChangeSID)
				,@RegistrationRequirementSID              = isnull(@RegistrationRequirementSID,rcr.RegistrationRequirementSID)
				,@PersonDocSID                            = isnull(@PersonDocSID,rcr.PersonDocSID)
				,@RegistrantExamSID                       = isnull(@RegistrantExamSID,rcr.RegistrantExamSID)
				,@ExpiryMonths                            = isnull(@ExpiryMonths,rcr.ExpiryMonths)
				,@RequirementStatusSID                    = isnull(@RequirementStatusSID,rcr.RequirementStatusSID)
				,@RequirementSequence                     = isnull(@RequirementSequence,rcr.RequirementSequence)
				,@UserDefinedColumns                      = isnull(@UserDefinedColumns,rcr.UserDefinedColumns)
				,@RegistrationChangeRequirementXID        = isnull(@RegistrationChangeRequirementXID,rcr.RegistrationChangeRequirementXID)
				,@LegacyKey                               = isnull(@LegacyKey,rcr.LegacyKey)
				,@UpdateUser                              = isnull(@UpdateUser,rcr.UpdateUser)
				,@IsReselected                            = isnull(@IsReselected,rcr.IsReselected)
				,@IsNullApplied                           = isnull(@IsNullApplied,rcr.IsNullApplied)
				,@zContext                                = isnull(@zContext,rcr.zContext)
				,@RegistrationSID                         = isnull(@RegistrationSID,rcr.RegistrationSID)
				,@PracticeRegisterSectionSID              = isnull(@PracticeRegisterSectionSID,rcr.PracticeRegisterSectionSID)
				,@RegistrationYear                        = isnull(@RegistrationYear,rcr.RegistrationYear)
				,@NextFollowUp                            = isnull(@NextFollowUp,rcr.NextFollowUp)
				,@RegistrationEffective                   = isnull(@RegistrationEffective,rcr.RegistrationEffective)
				,@ReservedRegistrantNo                    = isnull(@ReservedRegistrantNo,rcr.ReservedRegistrantNo)
				,@ReasonSID                               = isnull(@ReasonSID,rcr.ReasonSID)
				,@RegistrationChangeInvoiceSID            = isnull(@RegistrationChangeInvoiceSID,rcr.RegistrationChangeInvoiceSID)
				,@ComplaintSID                            = isnull(@ComplaintSID,rcr.ComplaintSID)
				,@RegistrationChangeRowGUID               = isnull(@RegistrationChangeRowGUID,rcr.RegistrationChangeRowGUID)
				,@RegistrationRequirementTypeSID          = isnull(@RegistrationRequirementTypeSID,rcr.RegistrationRequirementTypeSID)
				,@RegistrationRequirementLabel            = isnull(@RegistrationRequirementLabel,rcr.RegistrationRequirementLabel)
				,@RegistrationRequirementPersonDocTypeSID = isnull(@RegistrationRequirementPersonDocTypeSID,rcr.RegistrationRequirementPersonDocTypeSID)
				,@RegistrationRequirementExamSID          = isnull(@RegistrationRequirementExamSID,rcr.RegistrationRequirementExamSID)
				,@RegistrationRequirementExpiryMonths     = isnull(@RegistrationRequirementExpiryMonths,rcr.RegistrationRequirementExpiryMonths)
				,@RegistrationRequirementIsActive         = isnull(@RegistrationRequirementIsActive,rcr.RegistrationRequirementIsActive)
				,@RegistrationRequirementRowGUID          = isnull(@RegistrationRequirementRowGUID,rcr.RegistrationRequirementRowGUID)
				,@RequirementStatusSCD                    = isnull(@RequirementStatusSCD,rcr.RequirementStatusSCD)
				,@RequirementStatusLabel                  = isnull(@RequirementStatusLabel,rcr.RequirementStatusLabel)
				,@IsFinal                                 = isnull(@IsFinal,rcr.IsFinal)
				,@RequirementStatusSequence               = isnull(@RequirementStatusSequence,rcr.RequirementStatusSequence)
				,@RequirementStatusIsDefault              = isnull(@RequirementStatusIsDefault,rcr.RequirementStatusIsDefault)
				,@RequirementStatusRowGUID                = isnull(@RequirementStatusRowGUID,rcr.RequirementStatusRowGUID)
				,@PersonSID                               = isnull(@PersonSID,rcr.PersonSID)
				,@PersonDocPersonDocTypeSID               = isnull(@PersonDocPersonDocTypeSID,rcr.PersonDocPersonDocTypeSID)
				,@DocumentTitle                           = isnull(@DocumentTitle,rcr.DocumentTitle)
				,@AdditionalInfo                          = isnull(@AdditionalInfo,rcr.AdditionalInfo)
				,@ArchivedTime                            = isnull(@ArchivedTime,rcr.ArchivedTime)
				,@FileTypeSID                             = isnull(@FileTypeSID,rcr.FileTypeSID)
				,@FileTypeSCD                             = isnull(@FileTypeSCD,rcr.FileTypeSCD)
				,@ShowToRegistrant                        = isnull(@ShowToRegistrant,rcr.ShowToRegistrant)
				,@ApplicationGrantSID                     = isnull(@ApplicationGrantSID,rcr.ApplicationGrantSID)
				,@IsRemoved                               = isnull(@IsRemoved,rcr.IsRemoved)
				,@ExpiryDate                              = isnull(@ExpiryDate,rcr.ExpiryDate)
				,@ApplicationReportSID                    = isnull(@ApplicationReportSID,rcr.ApplicationReportSID)
				,@ReportEntitySID                         = isnull(@ReportEntitySID,rcr.ReportEntitySID)
				,@PersonDocCancelledTime                  = isnull(@PersonDocCancelledTime,rcr.PersonDocCancelledTime)
				,@PersonDocProcessedTime                  = isnull(@PersonDocProcessedTime,rcr.PersonDocProcessedTime)
				,@ContextLink                             = isnull(@ContextLink,rcr.ContextLink)
				,@PersonDocRowGUID                        = isnull(@PersonDocRowGUID,rcr.PersonDocRowGUID)
				,@RegistrantSID                           = isnull(@RegistrantSID,rcr.RegistrantSID)
				,@RegistrantExamExamSID                   = isnull(@RegistrantExamExamSID,rcr.RegistrantExamExamSID)
				,@ExamDate                                = isnull(@ExamDate,rcr.ExamDate)
				,@ExamResultDate                          = isnull(@ExamResultDate,rcr.ExamResultDate)
				,@PassingScore                            = isnull(@PassingScore,rcr.PassingScore)
				,@Score                                   = isnull(@Score,rcr.Score)
				,@ExamStatusSID                           = isnull(@ExamStatusSID,rcr.ExamStatusSID)
				,@SchedulingPreferences                   = isnull(@SchedulingPreferences,rcr.SchedulingPreferences)
				,@AssignedLocation                        = isnull(@AssignedLocation,rcr.AssignedLocation)
				,@ExamReference                           = isnull(@ExamReference,rcr.ExamReference)
				,@ExamOfferingSID                         = isnull(@ExamOfferingSID,rcr.ExamOfferingSID)
				,@RegistrantExamInvoiceSID                = isnull(@RegistrantExamInvoiceSID,rcr.RegistrantExamInvoiceSID)
				,@ConfirmedTime                           = isnull(@ConfirmedTime,rcr.ConfirmedTime)
				,@RegistrantExamCancelledTime             = isnull(@RegistrantExamCancelledTime,rcr.RegistrantExamCancelledTime)
				,@RegistrantExamProcessedTime             = isnull(@RegistrantExamProcessedTime,rcr.RegistrantExamProcessedTime)
				,@RegistrantExamRowGUID                   = isnull(@RegistrantExamRowGUID,rcr.RegistrantExamRowGUID)
				,@IsDeleteEnabled                         = isnull(@IsDeleteEnabled,rcr.IsDeleteEnabled)
				,@IsMandatory                             = isnull(@IsMandatory,rcr.IsMandatory)
			from
				dbo.vRegistrationChangeRequirement rcr
			where
				rcr.RegistrationChangeRequirementSID = @RegistrationChangeRequirementSID

		end
		
		-- look up the FK value matching the system code if set; this allows
		-- FK values value to be set/updated based on system code values
		
		if @RequirementStatusSCD is not null and @RequirementStatusSID = (select x.RequirementStatusSID from dbo.RegistrationChangeRequirement x where x.RegistrationChangeRequirementSID = @RegistrationChangeRequirementSID)
		begin
		
			select
				@RequirementStatusSID = x.RequirementStatusSID
			from
				dbo.RequirementStatus x
			where
				x.RequirementStatusSCD = @RequirementStatusSCD
		
		end

		-- block changing FK values to parent records which are inactive (UI should prevent this)
		
		if (select x.RegistrationRequirementSID from dbo.RegistrationChangeRequirement x where x.RegistrationChangeRequirementSID = @RegistrationChangeRequirementSID) <> @RegistrationRequirementSID
		begin
			if (select x.IsActive from dbo.RegistrationRequirement x where x.RegistrationRequirementSID = @RegistrationRequirementSID) = @OFF
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'AssignmentToInactiveParent'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 assigned is marked inactive. Leave the record unchanged or set to an active %1.'
					,@Arg1        = N'registration requirement'
				
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
				r.RoutineName = 'pRegistrationChangeRequirement'
		)
		begin
		
			exec @errorNo = ext.pRegistrationChangeRequirement
				 @Mode                                    = 'update.pre'
				,@RegistrationChangeRequirementSID        = @RegistrationChangeRequirementSID
				,@RegistrationChangeSID                   = @RegistrationChangeSID output
				,@RegistrationRequirementSID              = @RegistrationRequirementSID output
				,@PersonDocSID                            = @PersonDocSID output
				,@RegistrantExamSID                       = @RegistrantExamSID output
				,@ExpiryMonths                            = @ExpiryMonths output
				,@RequirementStatusSID                    = @RequirementStatusSID output
				,@RequirementSequence                     = @RequirementSequence output
				,@UserDefinedColumns                      = @UserDefinedColumns output
				,@RegistrationChangeRequirementXID        = @RegistrationChangeRequirementXID output
				,@LegacyKey                               = @LegacyKey output
				,@UpdateUser                              = @UpdateUser
				,@RowStamp                                = @RowStamp
				,@IsReselected                            = @IsReselected
				,@IsNullApplied                           = @IsNullApplied
				,@zContext                                = @zContext
				,@RegistrationSID                         = @RegistrationSID
				,@PracticeRegisterSectionSID              = @PracticeRegisterSectionSID
				,@RegistrationYear                        = @RegistrationYear
				,@NextFollowUp                            = @NextFollowUp
				,@RegistrationEffective                   = @RegistrationEffective
				,@ReservedRegistrantNo                    = @ReservedRegistrantNo
				,@ReasonSID                               = @ReasonSID
				,@RegistrationChangeInvoiceSID            = @RegistrationChangeInvoiceSID
				,@ComplaintSID                            = @ComplaintSID
				,@RegistrationChangeRowGUID               = @RegistrationChangeRowGUID
				,@RegistrationRequirementTypeSID          = @RegistrationRequirementTypeSID
				,@RegistrationRequirementLabel            = @RegistrationRequirementLabel
				,@RegistrationRequirementPersonDocTypeSID = @RegistrationRequirementPersonDocTypeSID
				,@RegistrationRequirementExamSID          = @RegistrationRequirementExamSID
				,@RegistrationRequirementExpiryMonths     = @RegistrationRequirementExpiryMonths
				,@RegistrationRequirementIsActive         = @RegistrationRequirementIsActive
				,@RegistrationRequirementRowGUID          = @RegistrationRequirementRowGUID
				,@RequirementStatusSCD                    = @RequirementStatusSCD
				,@RequirementStatusLabel                  = @RequirementStatusLabel
				,@IsFinal                                 = @IsFinal
				,@RequirementStatusSequence               = @RequirementStatusSequence
				,@RequirementStatusIsDefault              = @RequirementStatusIsDefault
				,@RequirementStatusRowGUID                = @RequirementStatusRowGUID
				,@PersonSID                               = @PersonSID
				,@PersonDocPersonDocTypeSID               = @PersonDocPersonDocTypeSID
				,@DocumentTitle                           = @DocumentTitle
				,@AdditionalInfo                          = @AdditionalInfo
				,@ArchivedTime                            = @ArchivedTime
				,@FileTypeSID                             = @FileTypeSID
				,@FileTypeSCD                             = @FileTypeSCD
				,@ShowToRegistrant                        = @ShowToRegistrant
				,@ApplicationGrantSID                     = @ApplicationGrantSID
				,@IsRemoved                               = @IsRemoved
				,@ExpiryDate                              = @ExpiryDate
				,@ApplicationReportSID                    = @ApplicationReportSID
				,@ReportEntitySID                         = @ReportEntitySID
				,@PersonDocCancelledTime                  = @PersonDocCancelledTime
				,@PersonDocProcessedTime                  = @PersonDocProcessedTime
				,@ContextLink                             = @ContextLink
				,@PersonDocRowGUID                        = @PersonDocRowGUID
				,@RegistrantSID                           = @RegistrantSID
				,@RegistrantExamExamSID                   = @RegistrantExamExamSID
				,@ExamDate                                = @ExamDate
				,@ExamResultDate                          = @ExamResultDate
				,@PassingScore                            = @PassingScore
				,@Score                                   = @Score
				,@ExamStatusSID                           = @ExamStatusSID
				,@SchedulingPreferences                   = @SchedulingPreferences
				,@AssignedLocation                        = @AssignedLocation
				,@ExamReference                           = @ExamReference
				,@ExamOfferingSID                         = @ExamOfferingSID
				,@RegistrantExamInvoiceSID                = @RegistrantExamInvoiceSID
				,@ConfirmedTime                           = @ConfirmedTime
				,@RegistrantExamCancelledTime             = @RegistrantExamCancelledTime
				,@RegistrantExamProcessedTime             = @RegistrantExamProcessedTime
				,@RegistrantExamRowGUID                   = @RegistrantExamRowGUID
				,@IsDeleteEnabled                         = @IsDeleteEnabled
				,@IsMandatory                             = @IsMandatory
		
		end

		-- update the record

		update
			dbo.RegistrationChangeRequirement
		set
			 RegistrationChangeSID = @RegistrationChangeSID
			,RegistrationRequirementSID = @RegistrationRequirementSID
			,PersonDocSID = @PersonDocSID
			,RegistrantExamSID = @RegistrantExamSID
			,ExpiryMonths = @ExpiryMonths
			,RequirementStatusSID = @RequirementStatusSID
			,RequirementSequence = @RequirementSequence
			,UserDefinedColumns = @UserDefinedColumns
			,RegistrationChangeRequirementXID = @RegistrationChangeRequirementXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			RegistrationChangeRequirementSID = @RegistrationChangeRequirementSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from dbo.RegistrationChangeRequirement where RegistrationChangeRequirementSID = @registrationChangeRequirementSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'dbo.RegistrationChangeRequirement'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'dbo.RegistrationChangeRequirement'
					,@Arg2        = @registrationChangeRequirementSID
				
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
				,@Arg2        = 'dbo.RegistrationChangeRequirement'
				,@Arg3        = @rowsAffected
				,@Arg4        = @registrationChangeRequirementSID
			
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
				r.RoutineName = 'pRegistrationChangeRequirement'
		)
		begin
		
			exec @errorNo = ext.pRegistrationChangeRequirement
				 @Mode                                    = 'update.post'
				,@RegistrationChangeRequirementSID        = @RegistrationChangeRequirementSID
				,@RegistrationChangeSID                   = @RegistrationChangeSID
				,@RegistrationRequirementSID              = @RegistrationRequirementSID
				,@PersonDocSID                            = @PersonDocSID
				,@RegistrantExamSID                       = @RegistrantExamSID
				,@ExpiryMonths                            = @ExpiryMonths
				,@RequirementStatusSID                    = @RequirementStatusSID
				,@RequirementSequence                     = @RequirementSequence
				,@UserDefinedColumns                      = @UserDefinedColumns
				,@RegistrationChangeRequirementXID        = @RegistrationChangeRequirementXID
				,@LegacyKey                               = @LegacyKey
				,@UpdateUser                              = @UpdateUser
				,@RowStamp                                = @RowStamp
				,@IsReselected                            = @IsReselected
				,@IsNullApplied                           = @IsNullApplied
				,@zContext                                = @zContext
				,@RegistrationSID                         = @RegistrationSID
				,@PracticeRegisterSectionSID              = @PracticeRegisterSectionSID
				,@RegistrationYear                        = @RegistrationYear
				,@NextFollowUp                            = @NextFollowUp
				,@RegistrationEffective                   = @RegistrationEffective
				,@ReservedRegistrantNo                    = @ReservedRegistrantNo
				,@ReasonSID                               = @ReasonSID
				,@RegistrationChangeInvoiceSID            = @RegistrationChangeInvoiceSID
				,@ComplaintSID                            = @ComplaintSID
				,@RegistrationChangeRowGUID               = @RegistrationChangeRowGUID
				,@RegistrationRequirementTypeSID          = @RegistrationRequirementTypeSID
				,@RegistrationRequirementLabel            = @RegistrationRequirementLabel
				,@RegistrationRequirementPersonDocTypeSID = @RegistrationRequirementPersonDocTypeSID
				,@RegistrationRequirementExamSID          = @RegistrationRequirementExamSID
				,@RegistrationRequirementExpiryMonths     = @RegistrationRequirementExpiryMonths
				,@RegistrationRequirementIsActive         = @RegistrationRequirementIsActive
				,@RegistrationRequirementRowGUID          = @RegistrationRequirementRowGUID
				,@RequirementStatusSCD                    = @RequirementStatusSCD
				,@RequirementStatusLabel                  = @RequirementStatusLabel
				,@IsFinal                                 = @IsFinal
				,@RequirementStatusSequence               = @RequirementStatusSequence
				,@RequirementStatusIsDefault              = @RequirementStatusIsDefault
				,@RequirementStatusRowGUID                = @RequirementStatusRowGUID
				,@PersonSID                               = @PersonSID
				,@PersonDocPersonDocTypeSID               = @PersonDocPersonDocTypeSID
				,@DocumentTitle                           = @DocumentTitle
				,@AdditionalInfo                          = @AdditionalInfo
				,@ArchivedTime                            = @ArchivedTime
				,@FileTypeSID                             = @FileTypeSID
				,@FileTypeSCD                             = @FileTypeSCD
				,@ShowToRegistrant                        = @ShowToRegistrant
				,@ApplicationGrantSID                     = @ApplicationGrantSID
				,@IsRemoved                               = @IsRemoved
				,@ExpiryDate                              = @ExpiryDate
				,@ApplicationReportSID                    = @ApplicationReportSID
				,@ReportEntitySID                         = @ReportEntitySID
				,@PersonDocCancelledTime                  = @PersonDocCancelledTime
				,@PersonDocProcessedTime                  = @PersonDocProcessedTime
				,@ContextLink                             = @ContextLink
				,@PersonDocRowGUID                        = @PersonDocRowGUID
				,@RegistrantSID                           = @RegistrantSID
				,@RegistrantExamExamSID                   = @RegistrantExamExamSID
				,@ExamDate                                = @ExamDate
				,@ExamResultDate                          = @ExamResultDate
				,@PassingScore                            = @PassingScore
				,@Score                                   = @Score
				,@ExamStatusSID                           = @ExamStatusSID
				,@SchedulingPreferences                   = @SchedulingPreferences
				,@AssignedLocation                        = @AssignedLocation
				,@ExamReference                           = @ExamReference
				,@ExamOfferingSID                         = @ExamOfferingSID
				,@RegistrantExamInvoiceSID                = @RegistrantExamInvoiceSID
				,@ConfirmedTime                           = @ConfirmedTime
				,@RegistrantExamCancelledTime             = @RegistrantExamCancelledTime
				,@RegistrantExamProcessedTime             = @RegistrantExamProcessedTime
				,@RegistrantExamRowGUID                   = @RegistrantExamRowGUID
				,@IsDeleteEnabled                         = @IsDeleteEnabled
				,@IsMandatory                             = @IsMandatory
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.RegistrationChangeRequirementSID
			from
				dbo.vRegistrationChangeRequirement ent
			where
				ent.RegistrationChangeRequirementSID = @RegistrationChangeRequirementSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.RegistrationChangeRequirementSID
				,ent.RegistrationChangeSID
				,ent.RegistrationRequirementSID
				,ent.PersonDocSID
				,ent.RegistrantExamSID
				,ent.ExpiryMonths
				,ent.RequirementStatusSID
				,ent.RequirementSequence
				,ent.UserDefinedColumns
				,ent.RegistrationChangeRequirementXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.RegistrationSID
				,ent.PracticeRegisterSectionSID
				,ent.RegistrationYear
				,ent.NextFollowUp
				,ent.RegistrationEffective
				,ent.ReservedRegistrantNo
				,ent.ReasonSID
				,ent.RegistrationChangeInvoiceSID
				,ent.ComplaintSID
				,ent.RegistrationChangeRowGUID
				,ent.RegistrationRequirementTypeSID
				,ent.RegistrationRequirementLabel
				,ent.RegistrationRequirementPersonDocTypeSID
				,ent.RegistrationRequirementExamSID
				,ent.RegistrationRequirementExpiryMonths
				,ent.RegistrationRequirementIsActive
				,ent.RegistrationRequirementRowGUID
				,ent.RequirementStatusSCD
				,ent.RequirementStatusLabel
				,ent.IsFinal
				,ent.RequirementStatusSequence
				,ent.RequirementStatusIsDefault
				,ent.RequirementStatusRowGUID
				,ent.PersonSID
				,ent.PersonDocPersonDocTypeSID
				,ent.DocumentTitle
				,ent.AdditionalInfo
				,ent.ArchivedTime
				,ent.FileTypeSID
				,ent.FileTypeSCD
				,ent.ShowToRegistrant
				,ent.ApplicationGrantSID
				,ent.IsRemoved
				,ent.ExpiryDate
				,ent.ApplicationReportSID
				,ent.ReportEntitySID
				,ent.PersonDocCancelledTime
				,ent.PersonDocProcessedTime
				,ent.ContextLink
				,ent.PersonDocRowGUID
				,ent.RegistrantSID
				,ent.RegistrantExamExamSID
				,ent.ExamDate
				,ent.ExamResultDate
				,ent.PassingScore
				,ent.Score
				,ent.ExamStatusSID
				,ent.SchedulingPreferences
				,ent.AssignedLocation
				,ent.ExamReference
				,ent.ExamOfferingSID
				,ent.RegistrantExamInvoiceSID
				,ent.ConfirmedTime
				,ent.RegistrantExamCancelledTime
				,ent.RegistrantExamProcessedTime
				,ent.RegistrantExamRowGUID
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
				,ent.IsMandatory
			from
				dbo.vRegistrationChangeRequirement ent
			where
				ent.RegistrationChangeRequirementSID = @RegistrationChangeRequirementSID

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
