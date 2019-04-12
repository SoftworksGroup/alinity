SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrationChangeRequirement#Insert]
	 @RegistrationChangeRequirementSID        int               = null output													-- identity value assigned to the new record
	,@RegistrationChangeSID                   int               = null			-- required! if not passed value must be set in custom logic prior to insert
	,@RegistrationRequirementSID              int               = null			-- required! if not passed value must be set in custom logic prior to insert
	,@PersonDocSID                            int               = null			
	,@RegistrantExamSID                       int               = null			
	,@ExpiryMonths                            smallint          = null			-- default: (0)
	,@RequirementStatusSID                    int               = null			-- required! if not passed value must be set in custom logic prior to insert
	,@RequirementSequence                     int               = null			-- default: (10)
	,@UserDefinedColumns                      xml               = null			
	,@RegistrationChangeRequirementXID        varchar(150)      = null			
	,@LegacyKey                               nvarchar(50)      = null			
	,@CreateUser                              nvarchar(75)      = null			-- default: suser_sname()
	,@IsReselected                            tinyint           = null			-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                                xml               = null			-- other values defining context for the insert (if any)
	,@RegistrationSID                         int               = null			-- not a base table column (default ignored)
	,@PracticeRegisterSectionSID              int               = null			-- not a base table column (default ignored)
	,@RegistrationYear                        smallint          = null			-- not a base table column (default ignored)
	,@NextFollowUp                            date              = null			-- not a base table column (default ignored)
	,@RegistrationEffective                   date              = null			-- not a base table column (default ignored)
	,@ReservedRegistrantNo                    varchar(50)       = null			-- not a base table column (default ignored)
	,@ReasonSID                               int               = null			-- not a base table column (default ignored)
	,@RegistrationChangeInvoiceSID            int               = null			-- not a base table column (default ignored)
	,@ComplaintSID                            int               = null			-- not a base table column (default ignored)
	,@RegistrationChangeRowGUID               uniqueidentifier  = null			-- not a base table column (default ignored)
	,@RegistrationRequirementTypeSID          int               = null			-- not a base table column (default ignored)
	,@RegistrationRequirementLabel            nvarchar(35)      = null			-- not a base table column (default ignored)
	,@RegistrationRequirementPersonDocTypeSID int               = null			-- not a base table column (default ignored)
	,@RegistrationRequirementExamSID          int               = null			-- not a base table column (default ignored)
	,@RegistrationRequirementExpiryMonths     smallint          = null			-- not a base table column (default ignored)
	,@RegistrationRequirementIsActive         bit               = null			-- not a base table column (default ignored)
	,@RegistrationRequirementRowGUID          uniqueidentifier  = null			-- not a base table column (default ignored)
	,@RequirementStatusSCD                    varchar(10)       = null			-- not a base table column (default ignored)
	,@RequirementStatusLabel                  nvarchar(35)      = null			-- not a base table column (default ignored)
	,@IsFinal                                 bit               = null			-- not a base table column (default ignored)
	,@RequirementStatusSequence               int               = null			-- not a base table column (default ignored)
	,@RequirementStatusIsDefault              bit               = null			-- not a base table column (default ignored)
	,@RequirementStatusRowGUID                uniqueidentifier  = null			-- not a base table column (default ignored)
	,@PersonSID                               int               = null			-- not a base table column (default ignored)
	,@PersonDocPersonDocTypeSID               int               = null			-- not a base table column (default ignored)
	,@DocumentTitle                           nvarchar(100)     = null			-- not a base table column (default ignored)
	,@AdditionalInfo                          nvarchar(50)      = null			-- not a base table column (default ignored)
	,@ArchivedTime                            datetimeoffset(7) = null			-- not a base table column (default ignored)
	,@FileTypeSID                             int               = null			-- not a base table column (default ignored)
	,@FileTypeSCD                             varchar(8)        = null			-- not a base table column (default ignored)
	,@ShowToRegistrant                        bit               = null			-- not a base table column (default ignored)
	,@ApplicationGrantSID                     int               = null			-- not a base table column (default ignored)
	,@IsRemoved                               bit               = null			-- not a base table column (default ignored)
	,@ExpiryDate                              date              = null			-- not a base table column (default ignored)
	,@ApplicationReportSID                    int               = null			-- not a base table column (default ignored)
	,@ReportEntitySID                         int               = null			-- not a base table column (default ignored)
	,@PersonDocCancelledTime                  datetimeoffset(7) = null			-- not a base table column (default ignored)
	,@PersonDocProcessedTime                  datetimeoffset(7) = null			-- not a base table column (default ignored)
	,@ContextLink                             uniqueidentifier  = null			-- not a base table column (default ignored)
	,@PersonDocRowGUID                        uniqueidentifier  = null			-- not a base table column (default ignored)
	,@RegistrantSID                           int               = null			-- not a base table column (default ignored)
	,@RegistrantExamExamSID                   int               = null			-- not a base table column (default ignored)
	,@ExamDate                                date              = null			-- not a base table column (default ignored)
	,@ExamResultDate                          date              = null			-- not a base table column (default ignored)
	,@PassingScore                            int               = null			-- not a base table column (default ignored)
	,@Score                                   int               = null			-- not a base table column (default ignored)
	,@ExamStatusSID                           int               = null			-- not a base table column (default ignored)
	,@SchedulingPreferences                   nvarchar(1000)    = null			-- not a base table column (default ignored)
	,@AssignedLocation                        varchar(15)       = null			-- not a base table column (default ignored)
	,@ExamReference                           varchar(25)       = null			-- not a base table column (default ignored)
	,@ExamOfferingSID                         int               = null			-- not a base table column (default ignored)
	,@RegistrantExamInvoiceSID                int               = null			-- not a base table column (default ignored)
	,@ConfirmedTime                           datetimeoffset(7) = null			-- not a base table column (default ignored)
	,@RegistrantExamCancelledTime             datetimeoffset(7) = null			-- not a base table column (default ignored)
	,@RegistrantExamProcessedTime             datetimeoffset(7) = null			-- not a base table column (default ignored)
	,@RegistrantExamRowGUID                   uniqueidentifier  = null			-- not a base table column (default ignored)
	,@IsDeleteEnabled                         bit               = null			-- not a base table column (default ignored)
	,@IsMandatory                             bit               = null			-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pRegistrationChangeRequirement#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the dbo.RegistrationChangeRequirement table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the dbo.RegistrationChangeRequirement table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vRegistrationChangeRequirement entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pRegistrationChangeRequirement procedure. The extended procedure is only called
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

	set @RegistrationChangeRequirementSID = null														-- initialize output parameter

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

		set @RegistrationChangeRequirementXID = ltrim(rtrim(@RegistrationChangeRequirementXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @CreateUser = ltrim(rtrim(@CreateUser))
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
		if len(@CreateUser) = 0 set @CreateUser = null
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

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @ExpiryMonths = isnull(@ExpiryMonths,(0))
		set @RequirementSequence = isnull(@RequirementSequence,(10))
		set @CreateUser = isnull(@CreateUser,suser_sname())
		set @IsReselected                     = isnull(@IsReselected                    ,(0))
		
		-- look up the FK value matching the system code if set; this allows
		-- FK values value to be set/updated based on system code values
		
		if @RequirementStatusSCD is not null
		begin
		
			select
				@RequirementStatusSID = x.RequirementStatusSID
			from
				dbo.RequirementStatus x
			where
				x.RequirementStatusSCD = @RequirementStatusSCD
		
		end
		
		-- set default value on mandatory foreign keys where configured
		-- and if value not already assigned
		
		if @RequirementStatusSID  is null select @RequirementStatusSID  = x.RequirementStatusSID from dbo.RequirementStatus x where x.IsDefault = @ON

		-- apply the table-specific pre-insert logic (if any)

		--! <PreInsert>
		--  Tim Edlund | Apr 2018
		-- Set the next sequence number to +10
		-- from the current maximum and round

		if @RegistrationChangeSID is not null and isnull(@RequirementSequence,10) = 10
		begin

			select
				@RequirementSequence = max(rcr.RequirementSequence)
			from
				dbo.RegistrationChangeRequirement rcr
			where
				rcr.RegistrationChangeSID = @RegistrationChangeSID;

			if @@rowcount = 0
			begin
				set @RequirementSequence = 10;
			end;
			else
			begin
				set @RequirementSequence = round(@RequirementSequence + 10, -1);
			end;

		end;
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
				r.RoutineName = 'pRegistrationChangeRequirement'
		)
		begin
		
			exec @errorNo = ext.pRegistrationChangeRequirement
				 @Mode                                    = 'insert.pre'
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
				,@CreateUser                              = @CreateUser
				,@IsReselected                            = @IsReselected
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

		-- insert the record

		insert
			dbo.RegistrationChangeRequirement
		(
			 RegistrationChangeSID
			,RegistrationRequirementSID
			,PersonDocSID
			,RegistrantExamSID
			,ExpiryMonths
			,RequirementStatusSID
			,RequirementSequence
			,UserDefinedColumns
			,RegistrationChangeRequirementXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @RegistrationChangeSID
			,@RegistrationRequirementSID
			,@PersonDocSID
			,@RegistrantExamSID
			,@ExpiryMonths
			,@RequirementStatusSID
			,@RequirementSequence
			,@UserDefinedColumns
			,@RegistrationChangeRequirementXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected                     = @@rowcount
			,@RegistrationChangeRequirementSID = scope_identity()								-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'dbo.RegistrationChangeRequirement'
				,@Arg3        = @rowsAffected
				,@Arg4        = @RegistrationChangeRequirementSID
			
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
				r.RoutineName = 'pRegistrationChangeRequirement'
		)
		begin
		
			exec @errorNo = ext.pRegistrationChangeRequirement
				 @Mode                                    = 'insert.post'
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
				,@CreateUser                              = @CreateUser
				,@IsReselected                            = @IsReselected
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
