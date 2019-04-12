SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pLearningPlanActivity#Upsert
	@RowGUID									 uniqueidentifier			-- pass sub-form ID here - used to determine if NEW row or UPDATE
 ,@RegistrantLearningPlanSID int									-- key of the registrant learning plan to attach activity to
 ,@CompetenceTypeActivitySID int									-- key of the competence type and activity being planned/reported on
 ,@UnitValue								 decimal(5, 2) = 1.0	-- number of units - defaults to one if activity-based model
 ,@LearningClaimTypeSID			 int									-- status of the activity - use "PLANNED" if not yet complete
 ,@ActivityDate							 date = null					-- optional - date activity is started
 ,@ActivityDescription			 nvarchar(max) = null -- optional - description of activity/summary of learning
 ,@PlannedCompletion				 date = null					-- optional - date activity is planned to be complete
 ,@OrgSID										 int = null						-- optional - organization that sponsored the activity
 ,@IsSubjectToReview				 bit = null						-- optional - whether the activity is explicitly selected for renewal submission
 ,@IsArchived								 bit = null						-- optional - prevents the activity from being carried forward if incomplete
 ,@UserDefinedColumns				 xml = null						-- optional - additional extended columns
 ,@LearningPlanActivityXID	 varchar(150) = null	-- optional - additional XID column
 ,@LearningPlanActivitySID	 int = null output		-- key value of activity record inserted or updated
 ,@RegistrantSID						 int = null						-- not used but passed by form procedures due to entity mapping
 ,@FormVersionSID						 int = null						-- not used but passed by form procedures due to entity mapping
 ,@LearningModelSID					 int = null						-- not used but passed by form procedures due to entity mapping
 ,@ReasonSID								 int = null						-- not used but passed by form procedures due to entity mapping
as
/*********************************************************************************************************************************
Sproc    : Learning Plan Activity Upsert
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : This procedure is called by Learning Plan Forms via the sf.Form#Post procedure to insert and update learning activities
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)				| Month Year | Change Summary
				 : ---------------- | -----------|----------------------------------------------------------------------------------------
				 : Tim Edlund				| Dec 2017 	 | Initial version.
				 : Russ Poirier			| Oct 2018	 | Added XID to parameter list.
				 : Tim Edlund				| Nov 2018	 | Added support for updating person-doc-context record associated with the sub-form
----------------------------------------------------------------------------------------------------------------------------------
 
Comments
--------
This procedure handles writing data from the Learning Activity sub-form area of learning plan forms into the database.  The target
table is dbo.LearningPlanActivity which is a child table of dbo.RegistrantLearningPlan.

In order to establish whether the activity being passed already exist in the database, the GUID from the sub-form row must be
passed into the procedure.  This value is then looked up against the RowGUID column in the Learning-Plan-Activity  table to 
determine if it already exists.  If an existing record is not found, then one is inserted and the RowGUID passed in is written
to the RowGUID column on the new record.

The procedure returns the primary key of the learning plan activity record inserted or updated as an output variable (optional).

Updating Document Context to this Sub-Form Record
-------------------------------------------------
Where forms have a document upload option the document is saved into the dbo.PersonDoc record and a context is immediately 
created for the parent form (in this case dbo.RegistrantLearningPlan).  If the document upload occurs on a sub-form,
e.g. LearningPlanActivity, no context can be saved for it immediately as the sub-form record may not yet be saved into the
table. To support setting context to a sub-form, then, the "ContextLink" column on the PersonDoc can be set to the sub-form ID
as the document is saved. This procedure looks for the existence of a ContextLink value that matches the sub-form ID (which
this procedure sets as the RowGUID).  If found, it then executes an update to change the context from the parent form to the 
sub-form record. If the ContextLink is not found, it is assumed to point to the parent record in which case no update is required.

Known Limitations
-----------------
The GUID value provided by the sub-form must be unique across the database.  If this is not the case a duplicate key error
will occur.

Call Syntax
-----------

 -- this example updates an existing row 
 -- without making any changes

declare
	@rowGUID									 uniqueidentifier
 ,@registrantLearningPlanSID int
 ,@competenceTypeActivitySID int
 ,@learningClaimTypeSID			 int
 ,@plannedCompletion				 date
 ,@learningPlanActivitySID	 int;

select top (1)
	@rowGUID									 = lpa.RowGUID
 ,@registrantLearningPlanSID = lpa.RegistrantLearningPlanSID
 ,@competenceTypeActivitySID = lpa.CompetenceTypeActivitySID
 ,@learningClaimTypeSID			 = lpa.LearningClaimTypeSID
 ,@plannedCompletion				 = lpa.PlannedCompletion
 ,@learningPlanActivitySID	 = lpa.LearningPlanActivitySID
from
	dbo.LearningPlanActivity lpa
order by
	newid();

exec dbo.pLearningPlanActivity#Upsert
	@RowGUID = @rowGUID
 ,@RegistrantLearningPlanSID = @registrantLearningPlanSID
 ,@CompetenceTypeActivitySID = @competenceTypeActivitySID
 ,@LearningClaimTypeSID = @learningClaimTypeSID
 ,@PlannedCompletion = @plannedCompletion
 ,@LearningPlanActivitySID = @learningPlanActivitySID output;

select
	lpa.LearningPlanActivitySID
 ,lpa.RegistrantLearningPlanSID
 ,lpa.CompetenceTypeActivitySID
 ,lpa.UnitValue
 ,lpa.LearningClaimTypeSID
 ,lpa.PlannedCompletion
 ,lpa.RowGUID
from
	dbo.LearningPlanActivity lpa
where
	lpa.LearningPlanActivitySID = @learningPlanActivitySID;

------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo							int						= 0								-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText						nvarchar(4000)									-- message text for business rule errors
	 ,@blankParm						varchar(50)											-- tracks name of any required parameter not passed
	 ,@ON										bit						= cast(1 as bit)	-- constant for bit comparisons = 1
	 ,@OFF									bit						= cast(0 as bit)	-- constant for bit comparison = 0
	 ,@applicationEntityRLP int															-- key of the Registrant Learning Plan entity for document context
	 ,@applicationEntityLPA int															-- key of the Learning Plan Activity entity for document context
	 ,@inserted							bit															-- tracks whether insert is performed
	 ,@personDocSID					int;														-- key of linked person doc if any

	set @LearningPlanActivitySID = null; -- initialize in all code paths

	set @RegistrantSID = @RegistrantSID; -- set to avoid code analysis errors (not used)
	set @FormVersionSID = @FormVersionSID;
	set @ReasonSID = @ReasonSID;

	begin try

		-- check parameters

-- SQL Prompt formatting off
		if @RegistrantLearningPlanSID is null set @blankParm = '@RegistrantLearningPlanSID' 
		if @CompetenceTypeActivitySID is null set @blankParm = '@CompetenceTypeActivitySID'
		if @LearningClaimTypeSID			is null set @blankParm = '@LearningClaimTypeSID'		 																					
-- SQL Prompt formatting on

		if @blankParm is not null
		begin
			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = @blankParm;

			raiserror(@errorText, 18, 1);
		end;

		if @UnitValue is null set @UnitValue = 1.0; -- unit value defaults to 1

		if @LearningPlanActivitySID is null
		begin
			
			if @RowGUID	is null
			begin

				set @blankParm = '@RowGUID'	;

				exec sf.pMessage#Get
					@MessageSCD = 'BlankParameter'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
				 ,@Arg1 = @blankParm;

				raiserror(@errorText, 18, 1);

			end;

			-- look for existing record based on the row GUID provided

			select
				@LearningPlanActivitySID = lpa.LearningPlanActivitySID
			from
				dbo.LearningPlanActivity lpa
			where
				lpa.RowGUID = @RowGUID;

		end;

		if @LearningPlanActivitySID is null -- record does not exist, add it
		begin

			exec dbo.pLearningPlanActivity#Insert
				@LearningPlanActivitySID = @LearningPlanActivitySID output
			 ,@RegistrantLearningPlanSID = @RegistrantLearningPlanSID
			 ,@CompetenceTypeActivitySID = @CompetenceTypeActivitySID
			 ,@UnitValue = @UnitValue
			 ,@LearningClaimTypeSID = @LearningClaimTypeSID
			 ,@PlannedCompletion = @PlannedCompletion
			 ,@ActivityDescription = @ActivityDescription
			 ,@ActivityDate = @ActivityDate
			 ,@OrgSID = @OrgSID
			 ,@IsArchived = @IsArchived
			 ,@IsSubjectToReview = @IsSubjectToReview
			 ,@UserDefinedColumns = @UserDefinedColumns
			 ,@LearningPlanActivityXID = @LearningPlanActivityXID;

			update -- update the row GUID on the new row to the sub-form ID value passed in
				dbo.LearningPlanActivity
			set
				RowGUID = @RowGUID
			where
				LearningPlanActivitySID = @LearningPlanActivitySID;

			set @inserted = @ON;

		end;
		else -- otherwise record was found so update existing row
		begin

			exec dbo.pLearningPlanActivity#Update
				@LearningPlanActivitySID = @LearningPlanActivitySID
			 ,@RegistrantLearningPlanSID = @RegistrantLearningPlanSID
			 ,@CompetenceTypeActivitySID = @CompetenceTypeActivitySID
			 ,@UnitValue = @UnitValue
			 ,@LearningClaimTypeSID = @LearningClaimTypeSID
			 ,@PlannedCompletion = @PlannedCompletion
			 ,@ActivityDescription = @ActivityDescription
			 ,@ActivityDate = @ActivityDate
			 ,@OrgSID = @OrgSID
			 ,@IsArchived = @IsArchived
			 ,@IsSubjectToReview = @IsSubjectToReview
			 ,@UserDefinedColumns = @UserDefinedColumns
			 ,@LearningPlanActivityXID = @LearningPlanActivityXID;

			set @inserted = @OFF;

		end;

		-- if the ID for this sub-form record was placed into
		-- the link context of a document, update that context
		-- to this record instead of the parent form

		select
			@personDocSID = pd.PersonDocSID
		from
			dbo.PersonDoc pd
		where
			pd.ContextLink = @RowGUID;

		if @personDocSID is not null
		begin

			select
				@applicationEntityRLP = ae.ApplicationEntitySID
			from
				sf.ApplicationEntity ae
			where
				ae.ApplicationEntitySCD = 'dbo.RegistrantLearningPlan';

			select
				@applicationEntityLPA = ae.ApplicationEntitySID
			from
				sf.ApplicationEntity ae
			where
				ae.ApplicationEntitySCD = 'dbo.LearningPlanActivity';

			if @applicationEntityLPA is null or @applicationEntityRLP is null
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'RecordNotFound'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
				 ,@Arg1 = 'sf.ApplicationEntity'
				 ,@Arg2 = 'dbo.RegistrantLearningPlan/dbo.LearningPlanActivity';

				raiserror(@errorText, 18, 1);

			end;

			update
				dbo.PersonDocContext
			set
				EntitySID = @LearningPlanActivitySID
			 ,ApplicationEntitySID = @applicationEntityLPA	-- audit info intentionally not adjusted (same as previous assignment)
			where
				PersonDocSID	= @personDocSID -- key of document found for this sub-form context
				and EntitySID = @RegistrantLearningPlanSID and ApplicationEntitySID = @applicationEntityRLP;	-- currently assigned to parent record

			if @@rowcount = 0 and @inserted = @ON -- if updating, context may have already been modified
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'RecordNotFound'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
				 ,@Arg1 = 'dbo.PersonDocContext'
				 ,@Arg2 = @personDocSID;

				raiserror(@errorText, 18, 1);

			end;

		end;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
