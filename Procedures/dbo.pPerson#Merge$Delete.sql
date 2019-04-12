SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pPerson#Merge$Delete
	@PersonSIDFrom int									-- key of the person chosen as the duplicate
 ,@ChangeLog		 nvarchar(max) output -- text value summarizing changes made
 ,@DebugLevel		 int									-- when > 0 additional output is sent to the console to trace progress and performance
as
/*********************************************************************************************************************************
Sproc    : Person - Merge$Delete
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : This procedure deletes records that could not be moved due to duplication or overlapping dates in Merge operations
----------------------------------------------------------------------------------------------------------------------------------
History		: Author								| Month Year	| Change Summary
					: --------------------- + ----------- + --------------------------------------------------------------------------------
					: Tim Edlund						| May 2018		|	Initial version
					: Tim Edlund						| Jul 2018		| Removed key parameters other than PersonSID. 

Comments	
--------
This is a subroutine of pPerson#Merge responsible for deleting records that remain after all move-able records have been
assigned to the target Person. Some records may not be assigned to the target key (PersonSID, RegistrationSID and 
ApplicationUserSID) because they already exist for the target key or because they are in date ranges that overlap the 
date ranges where records exist for the target.

The subroutine updates the @ChangeLog parameter with details of records deleted. The log text is only updated when at
least 1 row is affected by the statement. This parameter is then returned to the caller for display.  

The deletion statements in this procedure are generated through an algorithm that examines the FK dependencies of 
all tables related to sf.Person including child dependencies to the lowest level of the model.  Because of this 
approach and because a table may be related to a parent table through more than one key, more than one delete statement
may be generated against the same table; one for each FK relationship.  This will cause the log to include more 
than one report of records deleted in the situation where the relationships end up targeting different records.

This routine does not catch errors or commit transactions. These actions must be performed by the parent procedure. The 
transaction management is omitted since the caller may be invoked in "Preview" mode where all deletes are rolled back.

The code included in this procedure can be initially generated through automation. Use the "GenPersonMerge.sql" utility
script in the Alinity DB project to generate the code. 

Example
-------
Test this procedure through the parent passing @ForceDeletion = 1 and using "Preview" mode  to avoid committing transactions. 
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo					 int							 = 0										-- 0 no error, <50000 SQL error, else business rule
	 ,@CRLF							 nchar(2)					 = char(13) + char(10)	-- constant for carriage return + line feed pair
	 ,@TAB							 nchar(2)					 = N'  '								-- constant for tab character
	 ,@rowsAffected			 int																			-- tracks rows affected by each update statement
	 ,@totalRowsAffected int							 = 0										-- tracks total count of rows updated
	 ,@timeCheck				 datetimeoffset(7) = sysdatetimeoffset(); -- timing mark trace value for debug output

	if @DebugLevel > 1
	begin

		exec sf.pDebugPrint
			@DebugString = N'Initiating deletes'
		 ,@TimeCheck = @timeCheck output;

	end;

	set @ChangeLog += @CRLF + @CRLF;
	set @ChangeLog += 'Records Deleted';

	-- Table: dbo.RegistrantAppReviewResponse
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.Form->sf.FormVersion->dbo.RegistrantApp->dbo.RegistrantAppReview->dbo.RegistrantAppReviewResponse

	delete
	x6
	from
		sf.Person												z
	join
		sf.ApplicationUser							x1 on z.PersonSID								= x1.PersonSID
	join
		sf.Form													x2 on x1.ApplicationUserSID			= x2.ApplicationUserSID
	join
		sf.FormVersion									x3 on x2.FormSID								= x3.FormSID
	join
		dbo.RegistrantApp								x4 on x3.FormVersionSID					= x4.FormVersionSID
	join
		dbo.RegistrantAppReview					x5 on x4.RegistrantAppSID				= x5.RegistrantAppSID
	join
		dbo.RegistrantAppReviewResponse x6 on x5.RegistrantAppReviewSID = x6.RegistrantAppReviewSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant App Review Response record(s) deleted';
	end;

	-- Table: dbo.RegistrantAppReviewStatus
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.Form->sf.FormVersion->dbo.RegistrantApp->dbo.RegistrantAppReview->dbo.RegistrantAppReviewStatus

	delete
	x6
	from
		sf.Person											z
	join
		sf.ApplicationUser						x1 on z.PersonSID								= x1.PersonSID
	join
		sf.Form												x2 on x1.ApplicationUserSID			= x2.ApplicationUserSID
	join
		sf.FormVersion								x3 on x2.FormSID								= x3.FormSID
	join
		dbo.RegistrantApp							x4 on x3.FormVersionSID					= x4.FormVersionSID
	join
		dbo.RegistrantAppReview				x5 on x4.RegistrantAppSID				= x5.RegistrantAppSID
	join
		dbo.RegistrantAppReviewStatus x6 on x5.RegistrantAppReviewSID = x6.RegistrantAppReviewSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant App Review Status record(s) deleted';
	end;

	-- Table: dbo.RegistrantAuditReviewResponse
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.Form->sf.FormVersion->dbo.RegistrantAudit->dbo.RegistrantAuditReview->dbo.RegistrantAuditReviewResponse

	delete
	x6
	from
		sf.Person													z
	join
		sf.ApplicationUser								x1 on z.PersonSID									= x1.PersonSID
	join
		sf.Form														x2 on x1.ApplicationUserSID				= x2.ApplicationUserSID
	join
		sf.FormVersion										x3 on x2.FormSID									= x3.FormSID
	join
		dbo.RegistrantAudit								x4 on x3.FormVersionSID						= x4.FormVersionSID
	join
		dbo.RegistrantAuditReview					x5 on x4.RegistrantAuditSID				= x5.RegistrantAuditSID
	join
		dbo.RegistrantAuditReviewResponse x6 on x5.RegistrantAuditReviewSID = x6.RegistrantAuditReviewSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant Audit Review Response record(s) deleted';
	end;

	-- Table: dbo.RegistrantAuditReviewStatus
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.Form->sf.FormVersion->dbo.RegistrantAudit->dbo.RegistrantAuditReview->dbo.RegistrantAuditReviewStatus

	delete
	x6
	from
		sf.Person												z
	join
		sf.ApplicationUser							x1 on z.PersonSID									= x1.PersonSID
	join
		sf.Form													x2 on x1.ApplicationUserSID				= x2.ApplicationUserSID
	join
		sf.FormVersion									x3 on x2.FormSID									= x3.FormSID
	join
		dbo.RegistrantAudit							x4 on x3.FormVersionSID						= x4.FormVersionSID
	join
		dbo.RegistrantAuditReview				x5 on x4.RegistrantAuditSID				= x5.RegistrantAuditSID
	join
		dbo.RegistrantAuditReviewStatus x6 on x5.RegistrantAuditReviewSID = x6.RegistrantAuditReviewSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant Audit Review Status record(s) deleted';
	end;

	-- Table: dbo.LearningPlanActivity
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.Form->sf.FormVersion->dbo.RegistrantLearningPlan->dbo.LearningPlanActivity

	delete
	x5
	from
		sf.Person									 z
	join
		sf.ApplicationUser				 x1 on z.PersonSID									= x1.PersonSID
	join
		sf.Form										 x2 on x1.ApplicationUserSID				= x2.ApplicationUserSID
	join
		sf.FormVersion						 x3 on x2.FormSID										= x3.FormSID
	join
		dbo.RegistrantLearningPlan x4 on x3.FormVersionSID						= x4.FormVersionSID
	join
		dbo.LearningPlanActivity	 x5 on x4.RegistrantLearningPlanSID = x5.RegistrantLearningPlanSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Learning Plan Activity record(s) deleted';
	end;

	-- Table: dbo.ProfileUpdateResponse
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.Form->sf.FormVersion->dbo.ProfileUpdate->dbo.ProfileUpdateResponse

	delete
	x5
	from
		sf.Person									z
	join
		sf.ApplicationUser				x1 on z.PersonSID						= x1.PersonSID
	join
		sf.Form										x2 on x1.ApplicationUserSID = x2.ApplicationUserSID
	join
		sf.FormVersion						x3 on x2.FormSID						= x3.FormSID
	join
		dbo.ProfileUpdate					x4 on x3.FormVersionSID			= x4.FormVersionSID
	join
		dbo.ProfileUpdateResponse x5 on x4.ProfileUpdateSID		= x5.ProfileUpdateSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Profile Update Response record(s) deleted';
	end;

	-- Table: dbo.ProfileUpdateStatus
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.Form->sf.FormVersion->dbo.ProfileUpdate->dbo.ProfileUpdateStatus

	delete
	x5
	from
		sf.Person								z
	join
		sf.ApplicationUser			x1 on z.PersonSID						= x1.PersonSID
	join
		sf.Form									x2 on x1.ApplicationUserSID = x2.ApplicationUserSID
	join
		sf.FormVersion					x3 on x2.FormSID						= x3.FormSID
	join
		dbo.ProfileUpdate				x4 on x3.FormVersionSID			= x4.FormVersionSID
	join
		dbo.ProfileUpdateStatus x5 on x4.ProfileUpdateSID		= x5.ProfileUpdateSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Profile Update Status record(s) deleted';
	end;

	-- Table: dbo.RegistrantAppResponse
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.Form->sf.FormVersion->dbo.RegistrantApp->dbo.RegistrantAppResponse

	delete
	x5
	from
		sf.Person									z
	join
		sf.ApplicationUser				x1 on z.PersonSID						= x1.PersonSID
	join
		sf.Form										x2 on x1.ApplicationUserSID = x2.ApplicationUserSID
	join
		sf.FormVersion						x3 on x2.FormSID						= x3.FormSID
	join
		dbo.RegistrantApp					x4 on x3.FormVersionSID			= x4.FormVersionSID
	join
		dbo.RegistrantAppResponse x5 on x4.RegistrantAppSID		= x5.RegistrantAppSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant App Response record(s) deleted';
	end;

	-- Table: dbo.RegistrantAppReview
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.Form->sf.FormVersion->dbo.RegistrantApp->dbo.RegistrantAppReview

	delete
	x5
	from
		sf.Person								z
	join
		sf.ApplicationUser			x1 on z.PersonSID						= x1.PersonSID
	join
		sf.Form									x2 on x1.ApplicationUserSID = x2.ApplicationUserSID
	join
		sf.FormVersion					x3 on x2.FormSID						= x3.FormSID
	join
		dbo.RegistrantApp				x4 on x3.FormVersionSID			= x4.FormVersionSID
	join
		dbo.RegistrantAppReview x5 on x4.RegistrantAppSID		= x5.RegistrantAppSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant App Review record(s) deleted';
	end;

	-- Table: dbo.RegistrantAppReviewResponse
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.Form->sf.FormVersion->dbo.RegistrantAppReview->dbo.RegistrantAppReviewResponse

	delete
	x5
	from
		sf.Person												z
	join
		sf.ApplicationUser							x1 on z.PersonSID								= x1.PersonSID
	join
		sf.Form													x2 on x1.ApplicationUserSID			= x2.ApplicationUserSID
	join
		sf.FormVersion									x3 on x2.FormSID								= x3.FormSID
	join
		dbo.RegistrantAppReview					x4 on x3.FormVersionSID					= x4.FormVersionSID
	join
		dbo.RegistrantAppReviewResponse x5 on x4.RegistrantAppReviewSID = x5.RegistrantAppReviewSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant App Review Response record(s) deleted';
	end;

	-- Table: dbo.RegistrantAppReviewResponse
	-- FK Chain: sf.Person->dbo.Registrant->dbo.Registration->dbo.RegistrantApp->dbo.RegistrantAppReview->dbo.RegistrantAppReviewResponse

	delete
	x5
	from
		sf.Person												z
	join
		dbo.Registrant									x1 on z.PersonSID								= x1.PersonSID
	join
		dbo.Registration								x2 on x1.RegistrantSID					= x2.RegistrantSID
	join
		dbo.RegistrantApp								x3 on x2.RegistrationSID				= x3.RegistrationSID
	join
		dbo.RegistrantAppReview					x4 on x3.RegistrantAppSID				= x4.RegistrantAppSID
	join
		dbo.RegistrantAppReviewResponse x5 on x4.RegistrantAppReviewSID = x5.RegistrantAppReviewSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant App Review Response record(s) deleted';
	end;

	-- Table: dbo.RegistrantAppReviewResponse
	-- FK Chain: sf.Person->dbo.Invoice->dbo.Registration->dbo.RegistrantApp->dbo.RegistrantAppReview->dbo.RegistrantAppReviewResponse

	delete
	x5
	from
		sf.Person												z
	join
		dbo.Invoice											x1 on z.PersonSID								= x1.PersonSID
	join
		dbo.Registration								x2 on x1.InvoiceSID							= x2.InvoiceSID
	join
		dbo.RegistrantApp								x3 on x2.RegistrationSID				= x3.RegistrationSID
	join
		dbo.RegistrantAppReview					x4 on x3.RegistrantAppSID				= x4.RegistrantAppSID
	join
		dbo.RegistrantAppReviewResponse x5 on x4.RegistrantAppReviewSID = x5.RegistrantAppReviewSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant App Review Response record(s) deleted';
	end;

	-- Table: dbo.RegistrantAppReviewStatus
	-- FK Chain: sf.Person->dbo.Invoice->dbo.Registration->dbo.RegistrantApp->dbo.RegistrantAppReview->dbo.RegistrantAppReviewStatus

	delete
	x5
	from
		sf.Person											z
	join
		dbo.Invoice										x1 on z.PersonSID								= x1.PersonSID
	join
		dbo.Registration							x2 on x1.InvoiceSID							= x2.InvoiceSID
	join
		dbo.RegistrantApp							x3 on x2.RegistrationSID				= x3.RegistrationSID
	join
		dbo.RegistrantAppReview				x4 on x3.RegistrantAppSID				= x4.RegistrantAppSID
	join
		dbo.RegistrantAppReviewStatus x5 on x4.RegistrantAppReviewSID = x5.RegistrantAppReviewSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant App Review Status record(s) deleted';
	end;

	-- Table: dbo.RegistrantAppReviewStatus
	-- FK Chain: sf.Person->dbo.Registrant->dbo.Registration->dbo.RegistrantApp->dbo.RegistrantAppReview->dbo.RegistrantAppReviewStatus

	delete
	x5
	from
		sf.Person											z
	join
		dbo.Registrant								x1 on z.PersonSID								= x1.PersonSID
	join
		dbo.Registration							x2 on x1.RegistrantSID					= x2.RegistrantSID
	join
		dbo.RegistrantApp							x3 on x2.RegistrationSID				= x3.RegistrationSID
	join
		dbo.RegistrantAppReview				x4 on x3.RegistrantAppSID				= x4.RegistrantAppSID
	join
		dbo.RegistrantAppReviewStatus x5 on x4.RegistrantAppReviewSID = x5.RegistrantAppReviewSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant App Review Status record(s) deleted';
	end;

	-- Table: dbo.RegistrantAppReviewStatus
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.Form->sf.FormVersion->dbo.RegistrantAppReview->dbo.RegistrantAppReviewStatus

	delete
	x5
	from
		sf.Person											z
	join
		sf.ApplicationUser						x1 on z.PersonSID								= x1.PersonSID
	join
		sf.Form												x2 on x1.ApplicationUserSID			= x2.ApplicationUserSID
	join
		sf.FormVersion								x3 on x2.FormSID								= x3.FormSID
	join
		dbo.RegistrantAppReview				x4 on x3.FormVersionSID					= x4.FormVersionSID
	join
		dbo.RegistrantAppReviewStatus x5 on x4.RegistrantAppReviewSID = x5.RegistrantAppReviewSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant App Review Status record(s) deleted';
	end;

	-- Table: dbo.RegistrantAppStatus
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.Form->sf.FormVersion->dbo.RegistrantApp->dbo.RegistrantAppStatus

	delete
	x5
	from
		sf.Person								z
	join
		sf.ApplicationUser			x1 on z.PersonSID						= x1.PersonSID
	join
		sf.Form									x2 on x1.ApplicationUserSID = x2.ApplicationUserSID
	join
		sf.FormVersion					x3 on x2.FormSID						= x3.FormSID
	join
		dbo.RegistrantApp				x4 on x3.FormVersionSID			= x4.FormVersionSID
	join
		dbo.RegistrantAppStatus x5 on x4.RegistrantAppSID		= x5.RegistrantAppSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant App Status record(s) deleted';
	end;

	-- Table: dbo.RegistrantAuditResponse
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.Form->sf.FormVersion->dbo.RegistrantAudit->dbo.RegistrantAuditResponse

	delete
	x5
	from
		sf.Person										z
	join
		sf.ApplicationUser					x1 on z.PersonSID						= x1.PersonSID
	join
		sf.Form											x2 on x1.ApplicationUserSID = x2.ApplicationUserSID
	join
		sf.FormVersion							x3 on x2.FormSID						= x3.FormSID
	join
		dbo.RegistrantAudit					x4 on x3.FormVersionSID			= x4.FormVersionSID
	join
		dbo.RegistrantAuditResponse x5 on x4.RegistrantAuditSID = x5.RegistrantAuditSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant Audit Response record(s) deleted';
	end;

	-- Table: dbo.RegistrantAuditReview
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.Form->sf.FormVersion->dbo.RegistrantAudit->dbo.RegistrantAuditReview

	delete
	x5
	from
		sf.Person									z
	join
		sf.ApplicationUser				x1 on z.PersonSID						= x1.PersonSID
	join
		sf.Form										x2 on x1.ApplicationUserSID = x2.ApplicationUserSID
	join
		sf.FormVersion						x3 on x2.FormSID						= x3.FormSID
	join
		dbo.RegistrantAudit				x4 on x3.FormVersionSID			= x4.FormVersionSID
	join
		dbo.RegistrantAuditReview x5 on x4.RegistrantAuditSID = x5.RegistrantAuditSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant Audit Review record(s) deleted';
	end;

	-- Table: dbo.RegistrantAuditReviewResponse
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.Form->sf.FormVersion->dbo.RegistrantAuditReview->dbo.RegistrantAuditReviewResponse

	delete
	x5
	from
		sf.Person													z
	join
		sf.ApplicationUser								x1 on z.PersonSID									= x1.PersonSID
	join
		sf.Form														x2 on x1.ApplicationUserSID				= x2.ApplicationUserSID
	join
		sf.FormVersion										x3 on x2.FormSID									= x3.FormSID
	join
		dbo.RegistrantAuditReview					x4 on x3.FormVersionSID						= x4.FormVersionSID
	join
		dbo.RegistrantAuditReviewResponse x5 on x4.RegistrantAuditReviewSID = x5.RegistrantAuditReviewSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant Audit Review Response record(s) deleted';
	end;

	-- Table: dbo.RegistrantAuditReviewStatus
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.Form->sf.FormVersion->dbo.RegistrantAuditReview->dbo.RegistrantAuditReviewStatus

	delete
	x5
	from
		sf.Person												z
	join
		sf.ApplicationUser							x1 on z.PersonSID									= x1.PersonSID
	join
		sf.Form													x2 on x1.ApplicationUserSID				= x2.ApplicationUserSID
	join
		sf.FormVersion									x3 on x2.FormSID									= x3.FormSID
	join
		dbo.RegistrantAuditReview				x4 on x3.FormVersionSID						= x4.FormVersionSID
	join
		dbo.RegistrantAuditReviewStatus x5 on x4.RegistrantAuditReviewSID = x5.RegistrantAuditReviewSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant Audit Review Status record(s) deleted';
	end;

	-- Table: dbo.RegistrantAuditStatus
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.Form->sf.FormVersion->dbo.RegistrantAudit->dbo.RegistrantAuditStatus

	delete
	x5
	from
		sf.Person									z
	join
		sf.ApplicationUser				x1 on z.PersonSID						= x1.PersonSID
	join
		sf.Form										x2 on x1.ApplicationUserSID = x2.ApplicationUserSID
	join
		sf.FormVersion						x3 on x2.FormSID						= x3.FormSID
	join
		dbo.RegistrantAudit				x4 on x3.FormVersionSID			= x4.FormVersionSID
	join
		dbo.RegistrantAuditStatus x5 on x4.RegistrantAuditSID = x5.RegistrantAuditSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant Audit Status record(s) deleted';
	end;

	-- Table: dbo.RegistrantLearningPlanResponse
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.Form->sf.FormVersion->dbo.RegistrantLearningPlan->dbo.RegistrantLearningPlanResponse

	delete
	x5
	from
		sf.Person													 z
	join
		sf.ApplicationUser								 x1 on z.PersonSID									= x1.PersonSID
	join
		sf.Form														 x2 on x1.ApplicationUserSID				= x2.ApplicationUserSID
	join
		sf.FormVersion										 x3 on x2.FormSID										= x3.FormSID
	join
		dbo.RegistrantLearningPlan				 x4 on x3.FormVersionSID						= x4.FormVersionSID
	join
		dbo.RegistrantLearningPlanResponse x5 on x4.RegistrantLearningPlanSID = x5.RegistrantLearningPlanSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant Learning Plan Response record(s) deleted';
	end;

	-- Table: dbo.RegistrantLearningPlanStatus
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.Form->sf.FormVersion->dbo.RegistrantLearningPlan->dbo.RegistrantLearningPlanStatus

	delete
	x5
	from
		sf.Person												 z
	join
		sf.ApplicationUser							 x1 on z.PersonSID									= x1.PersonSID
	join
		sf.Form													 x2 on x1.ApplicationUserSID				= x2.ApplicationUserSID
	join
		sf.FormVersion									 x3 on x2.FormSID										= x3.FormSID
	join
		dbo.RegistrantLearningPlan			 x4 on x3.FormVersionSID						= x4.FormVersionSID
	join
		dbo.RegistrantLearningPlanStatus x5 on x4.RegistrantLearningPlanSID = x5.RegistrantLearningPlanSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant Learning Plan Status record(s) deleted';
	end;

	-- Table: dbo.RegistrantRenewalResponse
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.Form->sf.FormVersion->dbo.RegistrantRenewal->dbo.RegistrantRenewalResponse

	delete
	x5
	from
		sf.Person											z
	join
		sf.ApplicationUser						x1 on z.PersonSID							= x1.PersonSID
	join
		sf.Form												x2 on x1.ApplicationUserSID		= x2.ApplicationUserSID
	join
		sf.FormVersion								x3 on x2.FormSID							= x3.FormSID
	join
		dbo.RegistrantRenewal					x4 on x3.FormVersionSID				= x4.FormVersionSID
	join
		dbo.RegistrantRenewalResponse x5 on x4.RegistrantRenewalSID = x5.RegistrantRenewalSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant Renewal Response record(s) deleted';
	end;

	-- Table: dbo.RegistrantRenewalStatus
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.Form->sf.FormVersion->dbo.RegistrantRenewal->dbo.RegistrantRenewalStatus

	delete
	x5
	from
		sf.Person										z
	join
		sf.ApplicationUser					x1 on z.PersonSID							= x1.PersonSID
	join
		sf.Form											x2 on x1.ApplicationUserSID		= x2.ApplicationUserSID
	join
		sf.FormVersion							x3 on x2.FormSID							= x3.FormSID
	join
		dbo.RegistrantRenewal				x4 on x3.FormVersionSID				= x4.FormVersionSID
	join
		dbo.RegistrantRenewalStatus x5 on x4.RegistrantRenewalSID = x5.RegistrantRenewalSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant Renewal Status record(s) deleted';
	end;

	-- Table: dbo.ReinstatementResponse
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.Form->sf.FormVersion->dbo.Reinstatement->dbo.ReinstatementResponse

	delete
	x5
	from
		sf.Person									z
	join
		sf.ApplicationUser				x1 on z.PersonSID						= x1.PersonSID
	join
		sf.Form										x2 on x1.ApplicationUserSID = x2.ApplicationUserSID
	join
		sf.FormVersion						x3 on x2.FormSID						= x3.FormSID
	join
		dbo.Reinstatement					x4 on x3.FormVersionSID			= x4.FormVersionSID
	join
		dbo.ReinstatementResponse x5 on x4.ReinstatementSID		= x5.ReinstatementSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Reinstatement Response record(s) deleted';
	end;

	-- Table: dbo.ReinstatementStatus
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.Form->sf.FormVersion->dbo.Reinstatement->dbo.ReinstatementStatus

	delete
	x5
	from
		sf.Person								z
	join
		sf.ApplicationUser			x1 on z.PersonSID						= x1.PersonSID
	join
		sf.Form									x2 on x1.ApplicationUserSID = x2.ApplicationUserSID
	join
		sf.FormVersion					x3 on x2.FormSID						= x3.FormSID
	join
		dbo.Reinstatement				x4 on x3.FormVersionSID			= x4.FormVersionSID
	join
		dbo.ReinstatementStatus x5 on x4.ReinstatementSID		= x5.ReinstatementSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Reinstatement Status record(s) deleted';
	end;

	-- Table: dbo.PersonGroupDoc
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.PersonGroup->dbo.PersonGroupFolder->dbo.PersonGroupDoc

	delete
	x4
	from
		sf.Person							z
	join
		sf.ApplicationUser		x1 on z.PersonSID							= x1.PersonSID
	join
		sf.PersonGroup				x2 on x1.ApplicationUserSID		= x2.ApplicationUserSID
	join
		dbo.PersonGroupFolder x3 on x2.PersonGroupSID				= x3.PersonGroupSID
	join
		dbo.PersonGroupDoc		x4 on x3.PersonGroupFolderSID = x4.PersonGroupFolderSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Person Group Doc record(s) deleted';
	end;

	-- Table: dbo.ProfileUpdate
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.Form->sf.FormVersion->dbo.ProfileUpdate

	delete
	x4
	from
		sf.Person					 z
	join
		sf.ApplicationUser x1 on z.PersonSID					 = x1.PersonSID
	join
		sf.Form						 x2 on x1.ApplicationUserSID = x2.ApplicationUserSID
	join
		sf.FormVersion		 x3 on x2.FormSID						 = x3.FormSID
	join
		dbo.ProfileUpdate	 x4 on x3.FormVersionSID		 = x4.FormVersionSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Profile Update record(s) deleted';
	end;

	-- Table: dbo.RegistrantApp
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.Form->sf.FormVersion->dbo.RegistrantApp

	delete
	x4
	from
		sf.Person					 z
	join
		sf.ApplicationUser x1 on z.PersonSID					 = x1.PersonSID
	join
		sf.Form						 x2 on x1.ApplicationUserSID = x2.ApplicationUserSID
	join
		sf.FormVersion		 x3 on x2.FormSID						 = x3.FormSID
	join
		dbo.RegistrantApp	 x4 on x3.FormVersionSID		 = x4.FormVersionSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant App record(s) deleted';
	end;

	-- Table: dbo.RegistrantAppResponse
	-- FK Chain: sf.Person->dbo.Registrant->dbo.Registration->dbo.RegistrantApp->dbo.RegistrantAppResponse

	delete
	x4
	from
		sf.Person									z
	join
		dbo.Registrant						x1 on z.PersonSID					= x1.PersonSID
	join
		dbo.Registration					x2 on x1.RegistrantSID		= x2.RegistrantSID
	join
		dbo.RegistrantApp					x3 on x2.RegistrationSID	= x3.RegistrationSID
	join
		dbo.RegistrantAppResponse x4 on x3.RegistrantAppSID = x4.RegistrantAppSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant App Response record(s) deleted';
	end;

	-- Table: dbo.RegistrantAppResponse
	-- FK Chain: sf.Person->dbo.Invoice->dbo.Registration->dbo.RegistrantApp->dbo.RegistrantAppResponse

	delete
	x4
	from
		sf.Person									z
	join
		dbo.Invoice								x1 on z.PersonSID					= x1.PersonSID
	join
		dbo.Registration					x2 on x1.InvoiceSID				= x2.InvoiceSID
	join
		dbo.RegistrantApp					x3 on x2.RegistrationSID	= x3.RegistrationSID
	join
		dbo.RegistrantAppResponse x4 on x3.RegistrantAppSID = x4.RegistrantAppSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant App Response record(s) deleted';
	end;

	-- Table: dbo.RegistrantAppReview
	-- FK Chain: sf.Person->dbo.Invoice->dbo.Registration->dbo.RegistrantApp->dbo.RegistrantAppReview

	delete
	x4
	from
		sf.Person								z
	join
		dbo.Invoice							x1 on z.PersonSID					= x1.PersonSID
	join
		dbo.Registration				x2 on x1.InvoiceSID				= x2.InvoiceSID
	join
		dbo.RegistrantApp				x3 on x2.RegistrationSID	= x3.RegistrationSID
	join
		dbo.RegistrantAppReview x4 on x3.RegistrantAppSID = x4.RegistrantAppSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant App Review record(s) deleted';
	end;

	-- Table: dbo.RegistrantAppReview
	-- FK Chain: sf.Person->dbo.Registrant->dbo.Registration->dbo.RegistrantApp->dbo.RegistrantAppReview

	delete
	x4
	from
		sf.Person								z
	join
		dbo.Registrant					x1 on z.PersonSID					= x1.PersonSID
	join
		dbo.Registration				x2 on x1.RegistrantSID		= x2.RegistrantSID
	join
		dbo.RegistrantApp				x3 on x2.RegistrationSID	= x3.RegistrationSID
	join
		dbo.RegistrantAppReview x4 on x3.RegistrantAppSID = x4.RegistrantAppSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant App Review record(s) deleted';
	end;

	-- Table: dbo.RegistrantAppReview
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.Form->sf.FormVersion->dbo.RegistrantAppReview

	delete
	x4
	from
		sf.Person								z
	join
		sf.ApplicationUser			x1 on z.PersonSID						= x1.PersonSID
	join
		sf.Form									x2 on x1.ApplicationUserSID = x2.ApplicationUserSID
	join
		sf.FormVersion					x3 on x2.FormSID						= x3.FormSID
	join
		dbo.RegistrantAppReview x4 on x3.FormVersionSID			= x4.FormVersionSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant App Review record(s) deleted';
	end;

	-- Table: dbo.RegistrantAppReviewResponse
	-- FK Chain: sf.Person->dbo.Invoice->dbo.RegistrantApp->dbo.RegistrantAppReview->dbo.RegistrantAppReviewResponse

	delete
	x4
	from
		sf.Person												z
	join
		dbo.Invoice											x1 on z.PersonSID								= x1.PersonSID
	join
		dbo.RegistrantApp								x2 on x1.InvoiceSID							= x2.InvoiceSID
	join
		dbo.RegistrantAppReview					x3 on x2.RegistrantAppSID				= x3.RegistrantAppSID
	join
		dbo.RegistrantAppReviewResponse x4 on x3.RegistrantAppReviewSID = x4.RegistrantAppReviewSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant App Review Response record(s) deleted';
	end;

	-- Table: dbo.RegistrantAppReviewStatus
	-- FK Chain: sf.Person->dbo.Invoice->dbo.RegistrantApp->dbo.RegistrantAppReview->dbo.RegistrantAppReviewStatus

	delete
	x4
	from
		sf.Person											z
	join
		dbo.Invoice										x1 on z.PersonSID								= x1.PersonSID
	join
		dbo.RegistrantApp							x2 on x1.InvoiceSID							= x2.InvoiceSID
	join
		dbo.RegistrantAppReview				x3 on x2.RegistrantAppSID				= x3.RegistrantAppSID
	join
		dbo.RegistrantAppReviewStatus x4 on x3.RegistrantAppReviewSID = x4.RegistrantAppReviewSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant App Review Status record(s) deleted';
	end;

	-- Table: dbo.RegistrantAppStatus
	-- FK Chain: sf.Person->dbo.Invoice->dbo.Registration->dbo.RegistrantApp->dbo.RegistrantAppStatus

	delete
	x4
	from
		sf.Person								z
	join
		dbo.Invoice							x1 on z.PersonSID					= x1.PersonSID
	join
		dbo.Registration				x2 on x1.InvoiceSID				= x2.InvoiceSID
	join
		dbo.RegistrantApp				x3 on x2.RegistrationSID	= x3.RegistrationSID
	join
		dbo.RegistrantAppStatus x4 on x3.RegistrantAppSID = x4.RegistrantAppSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant App Status record(s) deleted';
	end;

	-- Table: dbo.RegistrantAppStatus
	-- FK Chain: sf.Person->dbo.Registrant->dbo.Registration->dbo.RegistrantApp->dbo.RegistrantAppStatus

	delete
	x4
	from
		sf.Person								z
	join
		dbo.Registrant					x1 on z.PersonSID					= x1.PersonSID
	join
		dbo.Registration				x2 on x1.RegistrantSID		= x2.RegistrantSID
	join
		dbo.RegistrantApp				x3 on x2.RegistrationSID	= x3.RegistrationSID
	join
		dbo.RegistrantAppStatus x4 on x3.RegistrantAppSID = x4.RegistrantAppSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant App Status record(s) deleted';
	end;

	-- Table: dbo.RegistrantAudit
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.Form->sf.FormVersion->dbo.RegistrantAudit

	delete
	x4
	from
		sf.Person						z
	join
		sf.ApplicationUser	x1 on z.PersonSID						= x1.PersonSID
	join
		sf.Form							x2 on x1.ApplicationUserSID = x2.ApplicationUserSID
	join
		sf.FormVersion			x3 on x2.FormSID						= x3.FormSID
	join
		dbo.RegistrantAudit x4 on x3.FormVersionSID			= x4.FormVersionSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant Audit record(s) deleted';
	end;

	-- Table: dbo.RegistrantAuditReview
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.Form->sf.FormVersion->dbo.RegistrantAuditReview

	delete
	x4
	from
		sf.Person									z
	join
		sf.ApplicationUser				x1 on z.PersonSID						= x1.PersonSID
	join
		sf.Form										x2 on x1.ApplicationUserSID = x2.ApplicationUserSID
	join
		sf.FormVersion						x3 on x2.FormSID						= x3.FormSID
	join
		dbo.RegistrantAuditReview x4 on x3.FormVersionSID			= x4.FormVersionSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant Audit Review record(s) deleted';
	end;

	-- Table: dbo.RegistrantAuditReviewResponse
	-- FK Chain: sf.Person->dbo.Registrant->dbo.RegistrantAudit->dbo.RegistrantAuditReview->dbo.RegistrantAuditReviewResponse

	delete
	x4
	from
		sf.Person													z
	join
		dbo.Registrant										x1 on z.PersonSID									= x1.PersonSID
	join
		dbo.RegistrantAudit								x2 on x1.RegistrantSID						= x2.RegistrantSID
	join
		dbo.RegistrantAuditReview					x3 on x2.RegistrantAuditSID				= x3.RegistrantAuditSID
	join
		dbo.RegistrantAuditReviewResponse x4 on x3.RegistrantAuditReviewSID = x4.RegistrantAuditReviewSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant Audit Review Response record(s) deleted';
	end;

	-- Table: dbo.RegistrantAuditReviewStatus
	-- FK Chain: sf.Person->dbo.Registrant->dbo.RegistrantAudit->dbo.RegistrantAuditReview->dbo.RegistrantAuditReviewStatus

	delete
	x4
	from
		sf.Person												z
	join
		dbo.Registrant									x1 on z.PersonSID									= x1.PersonSID
	join
		dbo.RegistrantAudit							x2 on x1.RegistrantSID						= x2.RegistrantSID
	join
		dbo.RegistrantAuditReview				x3 on x2.RegistrantAuditSID				= x3.RegistrantAuditSID
	join
		dbo.RegistrantAuditReviewStatus x4 on x3.RegistrantAuditReviewSID = x4.RegistrantAuditReviewSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant Audit Review Status record(s) deleted';
	end;

	-- Table: dbo.RegistrantLearningPlan
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.Form->sf.FormVersion->dbo.RegistrantLearningPlan

	delete
	x4
	from
		sf.Person									 z
	join
		sf.ApplicationUser				 x1 on z.PersonSID					 = x1.PersonSID
	join
		sf.Form										 x2 on x1.ApplicationUserSID = x2.ApplicationUserSID
	join
		sf.FormVersion						 x3 on x2.FormSID						 = x3.FormSID
	join
		dbo.RegistrantLearningPlan x4 on x3.FormVersionSID		 = x4.FormVersionSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant Learning Plan record(s) deleted';
	end;

	-- Table: dbo.RegistrantRenewal
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.Form->sf.FormVersion->dbo.RegistrantRenewal

	delete
	x4
	from
		sf.Person							z
	join
		sf.ApplicationUser		x1 on z.PersonSID						= x1.PersonSID
	join
		sf.Form								x2 on x1.ApplicationUserSID = x2.ApplicationUserSID
	join
		sf.FormVersion				x3 on x2.FormSID						= x3.FormSID
	join
		dbo.RegistrantRenewal x4 on x3.FormVersionSID			= x4.FormVersionSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant Renewal record(s) deleted';
	end;

	-- Table: dbo.RegistrantRenewalResponse
	-- FK Chain: sf.Person->dbo.Registrant->dbo.Registration->dbo.RegistrantRenewal->dbo.RegistrantRenewalResponse

	delete
	x4
	from
		sf.Person											z
	join
		dbo.Registrant								x1 on z.PersonSID							= x1.PersonSID
	join
		dbo.Registration							x2 on x1.RegistrantSID				= x2.RegistrantSID
	join
		dbo.RegistrantRenewal					x3 on x2.RegistrationSID			= x3.RegistrationSID
	join
		dbo.RegistrantRenewalResponse x4 on x3.RegistrantRenewalSID = x4.RegistrantRenewalSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant Renewal Response record(s) deleted';
	end;

	-- Table: dbo.RegistrantRenewalResponse
	-- FK Chain: sf.Person->dbo.Invoice->dbo.Registration->dbo.RegistrantRenewal->dbo.RegistrantRenewalResponse

	delete
	x4
	from
		sf.Person											z
	join
		dbo.Invoice										x1 on z.PersonSID							= x1.PersonSID
	join
		dbo.Registration							x2 on x1.InvoiceSID						= x2.InvoiceSID
	join
		dbo.RegistrantRenewal					x3 on x2.RegistrationSID			= x3.RegistrationSID
	join
		dbo.RegistrantRenewalResponse x4 on x3.RegistrantRenewalSID = x4.RegistrantRenewalSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant Renewal Response record(s) deleted';
	end;

	-- Table: dbo.RegistrantRenewalStatus
	-- FK Chain: sf.Person->dbo.Invoice->dbo.Registration->dbo.RegistrantRenewal->dbo.RegistrantRenewalStatus

	delete
	x4
	from
		sf.Person										z
	join
		dbo.Invoice									x1 on z.PersonSID							= x1.PersonSID
	join
		dbo.Registration						x2 on x1.InvoiceSID						= x2.InvoiceSID
	join
		dbo.RegistrantRenewal				x3 on x2.RegistrationSID			= x3.RegistrationSID
	join
		dbo.RegistrantRenewalStatus x4 on x3.RegistrantRenewalSID = x4.RegistrantRenewalSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant Renewal Status record(s) deleted';
	end;

	-- Table: dbo.RegistrantRenewalStatus
	-- FK Chain: sf.Person->dbo.Registrant->dbo.Registration->dbo.RegistrantRenewal->dbo.RegistrantRenewalStatus

	delete
	x4
	from
		sf.Person										z
	join
		dbo.Registrant							x1 on z.PersonSID							= x1.PersonSID
	join
		dbo.Registration						x2 on x1.RegistrantSID				= x2.RegistrantSID
	join
		dbo.RegistrantRenewal				x3 on x2.RegistrationSID			= x3.RegistrationSID
	join
		dbo.RegistrantRenewalStatus x4 on x3.RegistrantRenewalSID = x4.RegistrantRenewalSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant Renewal Status record(s) deleted';
	end;

	-- Table: dbo.RegistrationChangeRequirement
	-- FK Chain: sf.Person->dbo.Registrant->dbo.Registration->dbo.RegistrationChange->dbo.RegistrationChangeRequirement

	delete
	x4
	from
		sf.Person													z
	join
		dbo.Registrant										x1 on z.PersonSID							 = x1.PersonSID
	join
		dbo.Registration									x2 on x1.RegistrantSID				 = x2.RegistrantSID
	join
		dbo.RegistrationChange						x3 on x2.RegistrationSID			 = x3.RegistrationSID
	join
		dbo.RegistrationChangeRequirement x4 on x3.RegistrationChangeSID = x4.RegistrationChangeSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registration Change Requirement record(s) deleted';
	end;

	-- Table: dbo.RegistrationChangeRequirement
	-- FK Chain: sf.Person->dbo.Invoice->dbo.Registration->dbo.RegistrationChange->dbo.RegistrationChangeRequirement

	delete
	x4
	from
		sf.Person													z
	join
		dbo.Invoice												x1 on z.PersonSID							 = x1.PersonSID
	join
		dbo.Registration									x2 on x1.InvoiceSID						 = x2.InvoiceSID
	join
		dbo.RegistrationChange						x3 on x2.RegistrationSID			 = x3.RegistrationSID
	join
		dbo.RegistrationChangeRequirement x4 on x3.RegistrationChangeSID = x4.RegistrationChangeSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registration Change Requirement record(s) deleted';
	end;

	-- Table: dbo.RegistrationChangeStatus
	-- FK Chain: sf.Person->dbo.Invoice->dbo.Registration->dbo.RegistrationChange->dbo.RegistrationChangeStatus

	delete
	x4
	from
		sf.Person										 z
	join
		dbo.Invoice									 x1 on z.PersonSID							= x1.PersonSID
	join
		dbo.Registration						 x2 on x1.InvoiceSID						= x2.InvoiceSID
	join
		dbo.RegistrationChange			 x3 on x2.RegistrationSID				= x3.RegistrationSID
	join
		dbo.RegistrationChangeStatus x4 on x3.RegistrationChangeSID = x4.RegistrationChangeSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registration Change Status record(s) deleted';
	end;

	-- Table: dbo.RegistrationChangeStatus
	-- FK Chain: sf.Person->dbo.Registrant->dbo.Registration->dbo.RegistrationChange->dbo.RegistrationChangeStatus

	delete
	x4
	from
		sf.Person										 z
	join
		dbo.Registrant							 x1 on z.PersonSID							= x1.PersonSID
	join
		dbo.Registration						 x2 on x1.RegistrantSID					= x2.RegistrantSID
	join
		dbo.RegistrationChange			 x3 on x2.RegistrationSID				= x3.RegistrationSID
	join
		dbo.RegistrationChangeStatus x4 on x3.RegistrationChangeSID = x4.RegistrationChangeSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registration Change Status record(s) deleted';
	end;

	-- Table: dbo.Reinstatement
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.Form->sf.FormVersion->dbo.Reinstatement

	delete
	x4
	from
		sf.Person					 z
	join
		sf.ApplicationUser x1 on z.PersonSID					 = x1.PersonSID
	join
		sf.Form						 x2 on x1.ApplicationUserSID = x2.ApplicationUserSID
	join
		sf.FormVersion		 x3 on x2.FormSID						 = x3.FormSID
	join
		dbo.Reinstatement	 x4 on x3.FormVersionSID		 = x4.FormVersionSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Reinstatement record(s) deleted';
	end;

	-- Table: dbo.ReinstatementResponse
	-- FK Chain: sf.Person->dbo.Registrant->dbo.Registration->dbo.Reinstatement->dbo.ReinstatementResponse

	delete
	x4
	from
		sf.Person									z
	join
		dbo.Registrant						x1 on z.PersonSID					= x1.PersonSID
	join
		dbo.Registration					x2 on x1.RegistrantSID		= x2.RegistrantSID
	join
		dbo.Reinstatement					x3 on x2.RegistrationSID	= x3.RegistrationSID
	join
		dbo.ReinstatementResponse x4 on x3.ReinstatementSID = x4.ReinstatementSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Reinstatement Response record(s) deleted';
	end;

	-- Table: dbo.ReinstatementResponse
	-- FK Chain: sf.Person->dbo.Invoice->dbo.Registration->dbo.Reinstatement->dbo.ReinstatementResponse

	delete
	x4
	from
		sf.Person									z
	join
		dbo.Invoice								x1 on z.PersonSID					= x1.PersonSID
	join
		dbo.Registration					x2 on x1.InvoiceSID				= x2.InvoiceSID
	join
		dbo.Reinstatement					x3 on x2.RegistrationSID	= x3.RegistrationSID
	join
		dbo.ReinstatementResponse x4 on x3.ReinstatementSID = x4.ReinstatementSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Reinstatement Response record(s) deleted';
	end;

	-- Table: dbo.ReinstatementStatus
	-- FK Chain: sf.Person->dbo.Invoice->dbo.Registration->dbo.Reinstatement->dbo.ReinstatementStatus

	delete
	x4
	from
		sf.Person								z
	join
		dbo.Invoice							x1 on z.PersonSID					= x1.PersonSID
	join
		dbo.Registration				x2 on x1.InvoiceSID				= x2.InvoiceSID
	join
		dbo.Reinstatement				x3 on x2.RegistrationSID	= x3.RegistrationSID
	join
		dbo.ReinstatementStatus x4 on x3.ReinstatementSID = x4.ReinstatementSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Reinstatement Status record(s) deleted';
	end;

	-- Table: dbo.ReinstatementStatus
	-- FK Chain: sf.Person->dbo.Registrant->dbo.Registration->dbo.Reinstatement->dbo.ReinstatementStatus

	delete
	x4
	from
		sf.Person								z
	join
		dbo.Registrant					x1 on z.PersonSID					= x1.PersonSID
	join
		dbo.Registration				x2 on x1.RegistrantSID		= x2.RegistrantSID
	join
		dbo.Reinstatement				x3 on x2.RegistrationSID	= x3.RegistrationSID
	join
		dbo.ReinstatementStatus x4 on x3.ReinstatementSID = x4.ReinstatementSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Reinstatement Status record(s) deleted';
	end;

	-- Table: sf.Task
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.TaskQueue->sf.TaskTrigger->sf.Task

	delete
	x4
	from
		sf.Person					 z
	join
		sf.ApplicationUser x1 on z.PersonSID					 = x1.PersonSID
	join
		sf.TaskQueue			 x2 on x1.ApplicationUserSID = x2.ApplicationUserSID
	join
		sf.TaskTrigger		 x3 on x2.TaskQueueSID			 = x3.TaskQueueSID
	join
		sf.Task						 x4 on x3.TaskTriggerSID		 = x4.TaskTriggerSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Task record(s) deleted';
	end;

	-- Table: dbo.AuditTypeForm
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.Form->dbo.AuditTypeForm

	delete
	x3
	from
		sf.Person					 z
	join
		sf.ApplicationUser x1 on z.PersonSID					 = x1.PersonSID
	join
		sf.Form						 x2 on x1.ApplicationUserSID = x2.ApplicationUserSID
	join
		dbo.AuditTypeForm	 x3 on x2.FormSID						 = x3.FormSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Audit Type Form record(s) deleted';
	end;

	-- Table: dbo.EmploymentSupervisor
	-- FK Chain: sf.Person->dbo.Registrant->dbo.RegistrantEmployment->dbo.EmploymentSupervisor

	delete
	x3
	from
		sf.Person								 z
	join
		dbo.Registrant					 x1 on z.PersonSID								= x1.PersonSID
	join
		dbo.RegistrantEmployment x2 on x1.RegistrantSID						= x2.RegistrantSID
	join
		dbo.EmploymentSupervisor x3 on x2.RegistrantEmploymentSID = x3.RegistrantEmploymentSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Employment Supervisor record(s) deleted';
	end;

	-- Table: dbo.EmploymentSupervisor
	-- FK Chain: sf.Person->dbo.Registrant->dbo.RegistrantEmployment->dbo.EmploymentSupervisor

	delete
	x3
	from
		sf.Person								 z
	join
		dbo.Registrant					 x1 on z.PersonSID								= x1.PersonSID
	join
		dbo.RegistrantEmployment x2 on x1.RegistrantSID						= x2.RegistrantSID
	join
		dbo.EmploymentSupervisor x3 on x2.RegistrantEmploymentSID = x3.RegistrantEmploymentSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Employment Supervisor record(s) deleted';
	end;

	-- Table: dbo.GLTransaction
	-- FK Chain: sf.Person->dbo.Invoice->dbo.InvoicePayment->dbo.GLTransaction

	delete
	x3
	from
		sf.Person					 z
	join
		dbo.Invoice				 x1 on z.PersonSID					= x1.PersonSID
	join
		dbo.InvoicePayment x2 on x1.InvoiceSID				= x2.InvoiceSID
	join
		dbo.GLTransaction	 x3 on x2.InvoicePaymentSID = x3.InvoicePaymentSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' GLTransaction record(s) deleted';
	end;

	-- Table: dbo.GLTransaction
	-- FK Chain: sf.Person->dbo.Payment->dbo.InvoicePayment->dbo.GLTransaction

	delete
	x3
	from
		sf.Person					 z
	join
		dbo.Payment				 x1 on z.PersonSID					= x1.PersonSID
	join
		dbo.InvoicePayment x2 on x1.PaymentSID				= x2.PaymentSID
	join
		dbo.GLTransaction	 x3 on x2.InvoicePaymentSID = x3.InvoicePaymentSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' GLTransaction record(s) deleted';
	end;

	-- Table: dbo.LearningPlanActivity
	-- FK Chain: sf.Person->dbo.Registrant->dbo.RegistrantLearningPlan->dbo.LearningPlanActivity

	delete
	x3
	from
		sf.Person									 z
	join
		dbo.Registrant						 x1 on z.PersonSID									= x1.PersonSID
	join
		dbo.RegistrantLearningPlan x2 on x1.RegistrantSID							= x2.RegistrantSID
	join
		dbo.LearningPlanActivity	 x3 on x2.RegistrantLearningPlanSID = x3.RegistrantLearningPlanSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Learning Plan Activity record(s) deleted';
	end;

	-- Table: dbo.PersonGroupFolder
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.PersonGroup->dbo.PersonGroupFolder

	delete
	x3
	from
		sf.Person							z
	join
		sf.ApplicationUser		x1 on z.PersonSID						= x1.PersonSID
	join
		sf.PersonGroup				x2 on x1.ApplicationUserSID = x2.ApplicationUserSID
	join
		dbo.PersonGroupFolder x3 on x2.PersonGroupSID			= x3.PersonGroupSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Person Group Folder record(s) deleted';
	end;

	-- Table: dbo.PracticeRegisterForm
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.Form->dbo.PracticeRegisterForm

	delete
	x3
	from
		sf.Person								 z
	join
		sf.ApplicationUser			 x1 on z.PersonSID					 = x1.PersonSID
	join
		sf.Form									 x2 on x1.ApplicationUserSID = x2.ApplicationUserSID
	join
		dbo.PracticeRegisterForm x3 on x2.FormSID						 = x3.FormSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Practice Register Form record(s) deleted';
	end;

	-- Table: dbo.RegistrantApp
	-- FK Chain: sf.Person->dbo.Registrant->dbo.Registration->dbo.RegistrantApp

	delete
	x3
	from
		sf.Person					z
	join
		dbo.Registrant		x1 on z.PersonSID				 = x1.PersonSID
	join
		dbo.Registration	x2 on x1.RegistrantSID	 = x2.RegistrantSID
	join
		dbo.RegistrantApp x3 on x2.RegistrationSID = x3.RegistrationSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant App record(s) deleted';
	end;

	-- Table: dbo.RegistrantApp
	-- FK Chain: sf.Person->dbo.Invoice->dbo.Registration->dbo.RegistrantApp

	delete
	x3
	from
		sf.Person					z
	join
		dbo.Invoice				x1 on z.PersonSID				 = x1.PersonSID
	join
		dbo.Registration	x2 on x1.InvoiceSID			 = x2.InvoiceSID
	join
		dbo.RegistrantApp x3 on x2.RegistrationSID = x3.RegistrationSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant App record(s) deleted';
	end;

	-- Table: dbo.RegistrantAppResponse
	-- FK Chain: sf.Person->dbo.Invoice->dbo.RegistrantApp->dbo.RegistrantAppResponse

	delete
	x3
	from
		sf.Person									z
	join
		dbo.Invoice								x1 on z.PersonSID					= x1.PersonSID
	join
		dbo.RegistrantApp					x2 on x1.InvoiceSID				= x2.InvoiceSID
	join
		dbo.RegistrantAppResponse x3 on x2.RegistrantAppSID = x3.RegistrantAppSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant App Response record(s) deleted';
	end;

	-- Table: dbo.RegistrantAppReview
	-- FK Chain: sf.Person->dbo.Invoice->dbo.RegistrantApp->dbo.RegistrantAppReview

	delete
	x3
	from
		sf.Person								z
	join
		dbo.Invoice							x1 on z.PersonSID					= x1.PersonSID
	join
		dbo.RegistrantApp				x2 on x1.InvoiceSID				= x2.InvoiceSID
	join
		dbo.RegistrantAppReview x3 on x2.RegistrantAppSID = x3.RegistrantAppSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant App Review record(s) deleted';
	end;

	-- Table: dbo.RegistrantAppStatus
	-- FK Chain: sf.Person->dbo.Invoice->dbo.RegistrantApp->dbo.RegistrantAppStatus

	delete
	x3
	from
		sf.Person								z
	join
		dbo.Invoice							x1 on z.PersonSID					= x1.PersonSID
	join
		dbo.RegistrantApp				x2 on x1.InvoiceSID				= x2.InvoiceSID
	join
		dbo.RegistrantAppStatus x3 on x2.RegistrantAppSID = x3.RegistrantAppSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant App Status record(s) deleted';
	end;

	-- Table: dbo.RegistrantAuditResponse
	-- FK Chain: sf.Person->dbo.Registrant->dbo.RegistrantAudit->dbo.RegistrantAuditResponse

	delete
	x3
	from
		sf.Person										z
	join
		dbo.Registrant							x1 on z.PersonSID						= x1.PersonSID
	join
		dbo.RegistrantAudit					x2 on x1.RegistrantSID			= x2.RegistrantSID
	join
		dbo.RegistrantAuditResponse x3 on x2.RegistrantAuditSID = x3.RegistrantAuditSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant Audit Response record(s) deleted';
	end;

	-- Table: dbo.RegistrantAuditReview
	-- FK Chain: sf.Person->dbo.Registrant->dbo.RegistrantAudit->dbo.RegistrantAuditReview

	delete
	x3
	from
		sf.Person									z
	join
		dbo.Registrant						x1 on z.PersonSID						= x1.PersonSID
	join
		dbo.RegistrantAudit				x2 on x1.RegistrantSID			= x2.RegistrantSID
	join
		dbo.RegistrantAuditReview x3 on x2.RegistrantAuditSID = x3.RegistrantAuditSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant Audit Review record(s) deleted';
	end;

	-- Table: dbo.RegistrantAuditStatus
	-- FK Chain: sf.Person->dbo.Registrant->dbo.RegistrantAudit->dbo.RegistrantAuditStatus

	delete
	x3
	from
		sf.Person									z
	join
		dbo.Registrant						x1 on z.PersonSID						= x1.PersonSID
	join
		dbo.RegistrantAudit				x2 on x1.RegistrantSID			= x2.RegistrantSID
	join
		dbo.RegistrantAuditStatus x3 on x2.RegistrantAuditSID = x3.RegistrantAuditSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant Audit Status record(s) deleted';
	end;

	-- Table: dbo.RegistrantEmploymentPracticeArea
	-- FK Chain: sf.Person->dbo.Registrant->dbo.RegistrantEmployment->dbo.RegistrantEmploymentPracticeArea

	delete
	x3
	from
		sf.Person														 z
	join
		dbo.Registrant											 x1 on z.PersonSID								= x1.PersonSID
	join
		dbo.RegistrantEmployment						 x2 on x1.RegistrantSID						= x2.RegistrantSID
	join
		dbo.RegistrantEmploymentPracticeArea x3 on x2.RegistrantEmploymentSID = x3.RegistrantEmploymentSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant Employment Practice Area record(s) deleted';
	end;

	-- Table: dbo.RegistrantLearningPlanResponse
	-- FK Chain: sf.Person->dbo.Registrant->dbo.RegistrantLearningPlan->dbo.RegistrantLearningPlanResponse

	delete
	x3
	from
		sf.Person													 z
	join
		dbo.Registrant										 x1 on z.PersonSID									= x1.PersonSID
	join
		dbo.RegistrantLearningPlan				 x2 on x1.RegistrantSID							= x2.RegistrantSID
	join
		dbo.RegistrantLearningPlanResponse x3 on x2.RegistrantLearningPlanSID = x3.RegistrantLearningPlanSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant Learning Plan Response record(s) deleted';
	end;

	-- Table: dbo.RegistrantLearningPlanStatus
	-- FK Chain: sf.Person->dbo.Registrant->dbo.RegistrantLearningPlan->dbo.RegistrantLearningPlanStatus

	delete
	x3
	from
		sf.Person												 z
	join
		dbo.Registrant									 x1 on z.PersonSID									= x1.PersonSID
	join
		dbo.RegistrantLearningPlan			 x2 on x1.RegistrantSID							= x2.RegistrantSID
	join
		dbo.RegistrantLearningPlanStatus x3 on x2.RegistrantLearningPlanSID = x3.RegistrantLearningPlanSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant Learning Plan Status record(s) deleted';
	end;

	-- Table: dbo.RegistrantRenewal
	-- FK Chain: sf.Person->dbo.Invoice->dbo.Registration->dbo.RegistrantRenewal

	delete
	x3
	from
		sf.Person							z
	join
		dbo.Invoice						x1 on z.PersonSID				 = x1.PersonSID
	join
		dbo.Registration			x2 on x1.InvoiceSID			 = x2.InvoiceSID
	join
		dbo.RegistrantRenewal x3 on x2.RegistrationSID = x3.RegistrationSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant Renewal record(s) deleted';
	end;

	-- Table: dbo.RegistrantRenewal
	-- FK Chain: sf.Person->dbo.Registrant->dbo.Registration->dbo.RegistrantRenewal

	delete
	x3
	from
		sf.Person							z
	join
		dbo.Registrant				x1 on z.PersonSID				 = x1.PersonSID
	join
		dbo.Registration			x2 on x1.RegistrantSID	 = x2.RegistrantSID
	join
		dbo.RegistrantRenewal x3 on x2.RegistrationSID = x3.RegistrationSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant Renewal record(s) deleted';
	end;

	-- Table: dbo.RegistrantRenewalResponse
	-- FK Chain: sf.Person->dbo.Invoice->dbo.RegistrantRenewal->dbo.RegistrantRenewalResponse

	delete
	x3
	from
		sf.Person											z
	join
		dbo.Invoice										x1 on z.PersonSID							= x1.PersonSID
	join
		dbo.RegistrantRenewal					x2 on x1.InvoiceSID						= x2.InvoiceSID
	join
		dbo.RegistrantRenewalResponse x3 on x2.RegistrantRenewalSID = x3.RegistrantRenewalSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant Renewal Response record(s) deleted';
	end;

	-- Table: dbo.RegistrantRenewalStatus
	-- FK Chain: sf.Person->dbo.Invoice->dbo.RegistrantRenewal->dbo.RegistrantRenewalStatus

	delete
	x3
	from
		sf.Person										z
	join
		dbo.Invoice									x1 on z.PersonSID							= x1.PersonSID
	join
		dbo.RegistrantRenewal				x2 on x1.InvoiceSID						= x2.InvoiceSID
	join
		dbo.RegistrantRenewalStatus x3 on x2.RegistrantRenewalSID = x3.RegistrantRenewalSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant Renewal Status record(s) deleted';
	end;

	-- Table: dbo.RegistrationChange
	-- FK Chain: sf.Person->dbo.Invoice->dbo.Registration->dbo.RegistrationChange

	delete
	x3
	from
		sf.Person							 z
	join
		dbo.Invoice						 x1 on z.PersonSID				= x1.PersonSID
	join
		dbo.Registration			 x2 on x1.InvoiceSID			= x2.InvoiceSID
	join
		dbo.RegistrationChange x3 on x2.RegistrationSID = x3.RegistrationSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registration Change record(s) deleted';
	end;

	-- Table: dbo.RegistrationChange
	-- FK Chain: sf.Person->dbo.Registrant->dbo.Registration->dbo.RegistrationChange

	delete
	x3
	from
		sf.Person							 z
	join
		dbo.Registrant				 x1 on z.PersonSID				= x1.PersonSID
	join
		dbo.Registration			 x2 on x1.RegistrantSID		= x2.RegistrantSID
	join
		dbo.RegistrationChange x3 on x2.RegistrationSID = x3.RegistrationSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registration Change record(s) deleted';
	end;

	-- Table: dbo.RegistrationChangeRequirement
	-- FK Chain: sf.Person->dbo.Invoice->dbo.RegistrantExam->dbo.RegistrationChangeRequirement

	delete
	x3
	from
		sf.Person													z
	join
		dbo.Invoice												x1 on z.PersonSID					 = x1.PersonSID
	join
		dbo.RegistrantExam								x2 on x1.InvoiceSID				 = x2.InvoiceSID
	join
		dbo.RegistrationChangeRequirement x3 on x2.RegistrantExamSID = x3.RegistrantExamSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registration Change Requirement record(s) deleted';
	end;

	-- Table: dbo.RegistrationChangeRequirement
	-- FK Chain: sf.Person->dbo.Registrant->dbo.RegistrantExam->dbo.RegistrationChangeRequirement

	delete
	x3
	from
		sf.Person													z
	join
		dbo.Registrant										x1 on z.PersonSID					 = x1.PersonSID
	join
		dbo.RegistrantExam								x2 on x1.RegistrantSID		 = x2.RegistrantSID
	join
		dbo.RegistrationChangeRequirement x3 on x2.RegistrantExamSID = x3.RegistrantExamSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registration Change Requirement record(s) deleted';
	end;

	-- Table: dbo.RegistrationChangeRequirement
	-- FK Chain: sf.Person->dbo.Invoice->dbo.RegistrationChange->dbo.RegistrationChangeRequirement

	delete
	x3
	from
		sf.Person													z
	join
		dbo.Invoice												x1 on z.PersonSID							 = x1.PersonSID
	join
		dbo.RegistrationChange						x2 on x1.InvoiceSID						 = x2.InvoiceSID
	join
		dbo.RegistrationChangeRequirement x3 on x2.RegistrationChangeSID = x3.RegistrationChangeSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registration Change Requirement record(s) deleted';
	end;

	-- Table: dbo.RegistrationChangeStatus
	-- FK Chain: sf.Person->dbo.Invoice->dbo.RegistrationChange->dbo.RegistrationChangeStatus

	delete
	x3
	from
		sf.Person										 z
	join
		dbo.Invoice									 x1 on z.PersonSID							= x1.PersonSID
	join
		dbo.RegistrationChange			 x2 on x1.InvoiceSID						= x2.InvoiceSID
	join
		dbo.RegistrationChangeStatus x3 on x2.RegistrationChangeSID = x3.RegistrationChangeSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registration Change Status record(s) deleted';
	end;

	-- Table: dbo.RegistrationProfile
	-- FK Chain: sf.Person->dbo.Invoice->dbo.Registration->dbo.RegistrationProfile

	delete
	x3
	from
		sf.Person								z
	join
		dbo.Invoice							x1 on z.PersonSID				 = x1.PersonSID
	join
		dbo.Registration				x2 on x1.InvoiceSID			 = x2.InvoiceSID
	join
		dbo.RegistrationProfile x3 on x2.RegistrationSID = x3.RegistrationSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registration Profile record(s) deleted';
	end;

	-- Table: dbo.RegistrationProfile
	-- FK Chain: sf.Person->dbo.Registrant->dbo.Registration->dbo.RegistrationProfile

	delete
	x3
	from
		sf.Person								z
	join
		dbo.Registrant					x1 on z.PersonSID				 = x1.PersonSID
	join
		dbo.Registration				x2 on x1.RegistrantSID	 = x2.RegistrantSID
	join
		dbo.RegistrationProfile x3 on x2.RegistrationSID = x3.RegistrationSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registration Profile record(s) deleted';
	end;

	-- Table: dbo.RegistrationProfile
	-- FK Chain: sf.Person->dbo.Registrant->dbo.RegistrantEmployment->dbo.RegistrationProfile

	delete
	x3
	from
		sf.Person								 z
	join
		dbo.Registrant					 x1 on z.PersonSID								= x1.PersonSID
	join
		dbo.RegistrantEmployment x2 on x1.RegistrantSID						= x2.RegistrantSID
	join
		dbo.RegistrationProfile	 x3 on x2.RegistrantEmploymentSID = x3.Employment1RegistrantEmploymentSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registration Profile record(s) deleted';
	end;

	-- Table: dbo.RegistrationProfile
	-- FK Chain: sf.Person->dbo.Registrant->dbo.RegistrantEmployment->dbo.RegistrationProfile

	delete
	x3
	from
		sf.Person								 z
	join
		dbo.Registrant					 x1 on z.PersonSID								= x1.PersonSID
	join
		dbo.RegistrantEmployment x2 on x1.RegistrantSID						= x2.RegistrantSID
	join
		dbo.RegistrationProfile	 x3 on x2.RegistrantEmploymentSID = x3.Employment2RegistrantEmploymentSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registration Profile record(s) deleted';
	end;

	-- Table: dbo.RegistrationProfile
	-- FK Chain: sf.Person->dbo.Registrant->dbo.RegistrantEmployment->dbo.RegistrationProfile

	delete
	x3
	from
		sf.Person								 z
	join
		dbo.Registrant					 x1 on z.PersonSID								= x1.PersonSID
	join
		dbo.RegistrantEmployment x2 on x1.RegistrantSID						= x2.RegistrantSID
	join
		dbo.RegistrationProfile	 x3 on x2.RegistrantEmploymentSID = x3.Employment3RegistrantEmploymentSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registration Profile record(s) deleted';
	end;

	-- Table: dbo.RegistrationProfile
	-- FK Chain: sf.Person->dbo.Registrant->dbo.RegistrantEmployment->dbo.RegistrationProfile

	delete
	x3
	from
		sf.Person								 z
	join
		dbo.Registrant					 x1 on z.PersonSID								= x1.PersonSID
	join
		dbo.RegistrantEmployment x2 on x1.RegistrantSID						= x2.RegistrantSID
	join
		dbo.RegistrationProfile	 x3 on x2.RegistrantEmploymentSID = x3.Employment1RegistrantEmploymentSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registration Profile record(s) deleted';
	end;

	delete
	x3
	from
		sf.Person								 z
	join
		dbo.Registrant					 x1 on z.PersonSID								= x1.PersonSID
	join
		dbo.RegistrantEmployment x2 on x1.RegistrantSID						= x2.RegistrantSID
	join
		dbo.RegistrationProfile	 x3 on x2.RegistrantEmploymentSID = x3.Employment2RegistrantEmploymentSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registration Profile record(s) deleted';
	end;

	delete
	x3
	from
		sf.Person								 z
	join
		dbo.Registrant					 x1 on z.PersonSID								= x1.PersonSID
	join
		dbo.RegistrantEmployment x2 on x1.RegistrantSID						= x2.RegistrantSID
	join
		dbo.RegistrationProfile	 x3 on x2.RegistrantEmploymentSID = x3.Employment3RegistrantEmploymentSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registration Profile record(s) deleted';
	end;

	-- Table: dbo.RegistrationProfile
	-- FK Chain: sf.Person->dbo.Registrant->dbo.RegistrantEmployment->dbo.RegistrationProfile

	delete
	x3
	from
		sf.Person								 z
	join
		dbo.Registrant					 x1 on z.PersonSID								= x1.PersonSID
	join
		dbo.RegistrantEmployment x2 on x1.RegistrantSID						= x2.RegistrantSID
	join
		dbo.RegistrationProfile	 x3 on x2.RegistrantEmploymentSID = x3.Employment1RegistrantEmploymentSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registration Profile record(s) deleted';
	end;

	delete
	x3
	from
		sf.Person								 z
	join
		dbo.Registrant					 x1 on z.PersonSID								= x1.PersonSID
	join
		dbo.RegistrantEmployment x2 on x1.RegistrantSID						= x2.RegistrantSID
	join
		dbo.RegistrationProfile	 x3 on x2.RegistrantEmploymentSID = x3.Employment2RegistrantEmploymentSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registration Profile record(s) deleted';
	end;

	delete
	x3
	from
		sf.Person								 z
	join
		dbo.Registrant					 x1 on z.PersonSID								= x1.PersonSID
	join
		dbo.RegistrantEmployment x2 on x1.RegistrantSID						= x2.RegistrantSID
	join
		dbo.RegistrationProfile	 x3 on x2.RegistrantEmploymentSID = x3.Employment3RegistrantEmploymentSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registration Profile record(s) deleted';
	end;

	-- Table: dbo.RegistrationProfile
	-- FK Chain: sf.Person->dbo.Registrant->dbo.RegistrantCredential->dbo.RegistrationProfile

	delete
	x3
	from
		sf.Person								 z
	join
		dbo.Registrant					 x1 on z.PersonSID								= x1.PersonSID
	join
		dbo.RegistrantCredential x2 on x1.RegistrantSID						= x2.RegistrantSID
	join
		dbo.RegistrationProfile	 x3 on x2.RegistrantCredentialSID = x3.Education1RegistrantCredentialSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registration Profile record(s) deleted';
	end;

	delete
	x3
	from
		sf.Person								 z
	join
		dbo.Registrant					 x1 on z.PersonSID								= x1.PersonSID
	join
		dbo.RegistrantCredential x2 on x1.RegistrantSID						= x2.RegistrantSID
	join
		dbo.RegistrationProfile	 x3 on x2.RegistrantCredentialSID = x3.Education2RegistrantCredentialSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registration Profile record(s) deleted';
	end;

	delete
	x3
	from
		sf.Person								 z
	join
		dbo.Registrant					 x1 on z.PersonSID								= x1.PersonSID
	join
		dbo.RegistrantCredential x2 on x1.RegistrantSID						= x2.RegistrantSID
	join
		dbo.RegistrationProfile	 x3 on x2.RegistrantCredentialSID = x3.Education3RegistrantCredentialSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registration Profile record(s) deleted';
	end;

	-- Table: dbo.RegistrationProfile
	-- FK Chain: sf.Person->dbo.Registrant->dbo.RegistrantCredential->dbo.RegistrationProfile

	delete
	x3
	from
		sf.Person								 z
	join
		dbo.Registrant					 x1 on z.PersonSID								= x1.PersonSID
	join
		dbo.RegistrantCredential x2 on x1.RegistrantSID						= x2.RegistrantSID
	join
		dbo.RegistrationProfile	 x3 on x2.RegistrantCredentialSID = x3.Education1RegistrantCredentialSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registration Profile record(s) deleted';
	end;

	delete
	x3
	from
		sf.Person								 z
	join
		dbo.Registrant					 x1 on z.PersonSID								= x1.PersonSID
	join
		dbo.RegistrantCredential x2 on x1.RegistrantSID						= x2.RegistrantSID
	join
		dbo.RegistrationProfile	 x3 on x2.RegistrantCredentialSID = x3.Education2RegistrantCredentialSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registration Profile record(s) deleted';
	end;

	delete
	x3
	from
		sf.Person								 z
	join
		dbo.Registrant					 x1 on z.PersonSID								= x1.PersonSID
	join
		dbo.RegistrantCredential x2 on x1.RegistrantSID						= x2.RegistrantSID
	join
		dbo.RegistrationProfile	 x3 on x2.RegistrantCredentialSID = x3.Education3RegistrantCredentialSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registration Profile record(s) deleted';
	end;

	-- Table: dbo.RegistrationProfile
	-- FK Chain: sf.Person->dbo.Registrant->dbo.RegistrantCredential->dbo.RegistrationProfile

	delete
	x3
	from
		sf.Person								 z
	join
		dbo.Registrant					 x1 on z.PersonSID								= x1.PersonSID
	join
		dbo.RegistrantCredential x2 on x1.RegistrantSID						= x2.RegistrantSID
	join
		dbo.RegistrationProfile	 x3 on x2.RegistrantCredentialSID = x3.Education1RegistrantCredentialSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registration Profile record(s) deleted';
	end;

	delete
	x3
	from
		sf.Person								 z
	join
		dbo.Registrant					 x1 on z.PersonSID								= x1.PersonSID
	join
		dbo.RegistrantCredential x2 on x1.RegistrantSID						= x2.RegistrantSID
	join
		dbo.RegistrationProfile	 x3 on x2.RegistrantCredentialSID = x3.Education2RegistrantCredentialSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registration Profile record(s) deleted';
	end;

	delete
	x3
	from
		sf.Person								 z
	join
		dbo.Registrant					 x1 on z.PersonSID								= x1.PersonSID
	join
		dbo.RegistrantCredential x2 on x1.RegistrantSID						= x2.RegistrantSID
	join
		dbo.RegistrationProfile	 x3 on x2.RegistrantCredentialSID = x3.Education3RegistrantCredentialSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registration Profile record(s) deleted';
	end;

	-- Table: dbo.RegistrationProfile
	-- FK Chain: sf.Person->dbo.Registrant->dbo.RegistrantPractice->dbo.RegistrationProfile

	delete
	x3
	from
		sf.Person								z
	join
		dbo.Registrant					x1 on z.PersonSID							 = x1.PersonSID
	join
		dbo.RegistrantPractice	x2 on x1.RegistrantSID				 = x2.RegistrantSID
	join
		dbo.RegistrationProfile x3 on x2.RegistrantPracticeSID = x3.RegistrantPracticeSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registration Profile record(s) deleted';
	end;

	-- Table: dbo.Reinstatement
	-- FK Chain: sf.Person->dbo.Registrant->dbo.Registration->dbo.Reinstatement

	delete
	x3
	from
		sf.Person					z
	join
		dbo.Registrant		x1 on z.PersonSID				 = x1.PersonSID
	join
		dbo.Registration	x2 on x1.RegistrantSID	 = x2.RegistrantSID
	join
		dbo.Reinstatement x3 on x2.RegistrationSID = x3.RegistrationSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Reinstatement record(s) deleted';
	end;

	-- Table: dbo.Reinstatement
	-- FK Chain: sf.Person->dbo.Invoice->dbo.Registration->dbo.Reinstatement

	delete
	x3
	from
		sf.Person					z
	join
		dbo.Invoice				x1 on z.PersonSID				 = x1.PersonSID
	join
		dbo.Registration	x2 on x1.InvoiceSID			 = x2.InvoiceSID
	join
		dbo.Reinstatement x3 on x2.RegistrationSID = x3.RegistrationSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Reinstatement record(s) deleted';
	end;

	-- Table: dbo.ReinstatementResponse
	-- FK Chain: sf.Person->dbo.Invoice->dbo.Reinstatement->dbo.ReinstatementResponse

	delete
	x3
	from
		sf.Person									z
	join
		dbo.Invoice								x1 on z.PersonSID					= x1.PersonSID
	join
		dbo.Reinstatement					x2 on x1.InvoiceSID				= x2.InvoiceSID
	join
		dbo.ReinstatementResponse x3 on x2.ReinstatementSID = x3.ReinstatementSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Reinstatement Response record(s) deleted';
	end;

	-- Table: dbo.ReinstatementStatus
	-- FK Chain: sf.Person->dbo.Invoice->dbo.Reinstatement->dbo.ReinstatementStatus

	delete
	x3
	from
		sf.Person								z
	join
		dbo.Invoice							x1 on z.PersonSID					= x1.PersonSID
	join
		dbo.Reinstatement				x2 on x1.InvoiceSID				= x2.InvoiceSID
	join
		dbo.ReinstatementStatus x3 on x2.ReinstatementSID = x3.ReinstatementSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Reinstatement Status record(s) deleted';
	end;

	-- Table: sf.ApplicationUserSessionProperty
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.ApplicationUserSession->sf.ApplicationUserSessionProperty

	delete
	x3
	from
		sf.Person													z
	join
		sf.ApplicationUser								x1 on z.PersonSID									 = x1.PersonSID
	join
		sf.ApplicationUserSession					x2 on x1.ApplicationUserSID				 = x2.ApplicationUserSID
	join
		sf.ApplicationUserSessionProperty x3 on x2.ApplicationUserSessionSID = x3.ApplicationUserSessionSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Application User Session Property record(s) deleted';
	end;

	-- Table: sf.EmailMessageAttachment
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.EmailMessage->sf.EmailMessageAttachment

	delete
	x3
	from
		sf.Person									z
	join
		sf.ApplicationUser				x1 on z.PersonSID						= x1.PersonSID
	join
		sf.EmailMessage						x2 on x1.ApplicationUserSID = x2.ApplicationUserSID
	join
		sf.EmailMessageAttachment x3 on x2.EmailMessageSID		= x3.EmailMessageSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Email Message Attachment record(s) deleted';
	end;

	-- Table: sf.FormSubForm
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.Form->sf.FormSubForm

	delete
	x3
	from
		sf.Person					 z
	join
		sf.ApplicationUser x1 on z.PersonSID					 = x1.PersonSID
	join
		sf.Form						 x2 on x1.ApplicationUserSID = x2.ApplicationUserSID
	join
		sf.FormSubForm		 x3 on x2.FormSID						 = x3.FormSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Form Sub Form record(s) deleted';
	end;

	-- Table: sf.FormSubForm
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.Form->sf.FormSubForm

	delete
	x3
	from
		sf.Person					 z
	join
		sf.ApplicationUser x1 on z.PersonSID					 = x1.PersonSID
	join
		sf.Form						 x2 on x1.ApplicationUserSID = x2.ApplicationUserSID
	join
		sf.FormSubForm		 x3 on x2.FormSID						 = x3.FormSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Form Sub Form record(s) deleted';
	end;

	-- Table: sf.FormVersion
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.Form->sf.FormVersion

	delete
	x3
	from
		sf.Person					 z
	join
		sf.ApplicationUser x1 on z.PersonSID					 = x1.PersonSID
	join
		sf.Form						 x2 on x1.ApplicationUserSID = x2.ApplicationUserSID
	join
		sf.FormVersion		 x3 on x2.FormSID						 = x3.FormSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Form Version record(s) deleted';
	end;

	-- Table: sf.PersonEmailMessage
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.EmailMessage->sf.PersonEmailMessage

	delete
	x3
	from
		sf.Person							z
	join
		sf.ApplicationUser		x1 on z.PersonSID						= x1.PersonSID
	join
		sf.EmailMessage				x2 on x1.ApplicationUserSID = x2.ApplicationUserSID
	join
		sf.PersonEmailMessage x3 on x2.EmailMessageSID		= x3.EmailMessageSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Person Email Message record(s) deleted';
	end;

	-- Table: sf.PersonEmailMessage
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.EmailTrigger->sf.PersonEmailMessage

	delete
	x3
	from
		sf.Person							z
	join
		sf.ApplicationUser		x1 on z.PersonSID						= x1.PersonSID
	join
		sf.EmailTrigger				x2 on x1.ApplicationUserSID = x2.ApplicationUserSID
	join
		sf.PersonEmailMessage x3 on x2.EmailTriggerSID		= x3.EmailTriggerSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Person Email Message record(s) deleted';
	end;

	-- Table: sf.PersonGroupMember
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.PersonGroup->sf.PersonGroupMember

	delete
	x3
	from
		sf.Person						 z
	join
		sf.ApplicationUser	 x1 on z.PersonSID					 = x1.PersonSID
	join
		sf.PersonGroup			 x2 on x1.ApplicationUserSID = x2.ApplicationUserSID
	join
		sf.PersonGroupMember x3 on x2.PersonGroupSID		 = x3.PersonGroupSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Person Group Member record(s) deleted';
	end;

	-- Table: sf.PersonTextMessage
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.TextTrigger->sf.PersonTextMessage

	delete
	x3
	from
		sf.Person						 z
	join
		sf.ApplicationUser	 x1 on z.PersonSID					 = x1.PersonSID
	join
		sf.TextTrigger			 x2 on x1.ApplicationUserSID = x2.ApplicationUserSID
	join
		sf.PersonTextMessage x3 on x2.TextTriggerSID		 = x3.TextTriggerSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Person Text Message record(s) deleted';
	end;

	-- Table: sf.PersonTextMessage
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.TextMessage->sf.PersonTextMessage

	delete
	x3
	from
		sf.Person						 z
	join
		sf.ApplicationUser	 x1 on z.PersonSID					 = x1.PersonSID
	join
		sf.TextMessage			 x2 on x1.ApplicationUserSID = x2.ApplicationUserSID
	join
		sf.PersonTextMessage x3 on x2.TextMessageSID		 = x3.TextMessageSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Person Text Message record(s) deleted';
	end;

	-- Table: sf.RecordAudit
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.ApplicationUserSession->sf.RecordAudit

	delete
	x3
	from
		sf.Person									z
	join
		sf.ApplicationUser				x1 on z.PersonSID									 = x1.PersonSID
	join
		sf.ApplicationUserSession x2 on x1.ApplicationUserSID				 = x2.ApplicationUserSID
	join
		sf.RecordAudit						x3 on x2.ApplicationUserSessionSID = x3.ApplicationUserSessionSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Record Audit record(s) deleted';
	end;

	-- Table: sf.Task
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.TaskTrigger->sf.Task

	delete
	x3
	from
		sf.Person					 z
	join
		sf.ApplicationUser x1 on z.PersonSID					 = x1.PersonSID
	join
		sf.TaskTrigger		 x2 on x1.ApplicationUserSID = x2.ApplicationUserSID
	join
		sf.Task						 x3 on x2.TaskTriggerSID		 = x3.TaskTriggerSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Task record(s) deleted';
	end;

	-- Table: sf.Task
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.TaskQueue->sf.Task

	delete
	x3
	from
		sf.Person					 z
	join
		sf.ApplicationUser x1 on z.PersonSID					 = x1.PersonSID
	join
		sf.TaskQueue			 x2 on x1.ApplicationUserSID = x2.ApplicationUserSID
	join
		sf.Task						 x3 on x2.TaskQueueSID			 = x3.TaskQueueSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Task record(s) deleted';
	end;

	-- Table: sf.TaskQueueSubscriber
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.TaskQueue->sf.TaskQueueSubscriber

	delete
	x3
	from
		sf.Person							 z
	join
		sf.ApplicationUser		 x1 on z.PersonSID					 = x1.PersonSID
	join
		sf.TaskQueue					 x2 on x1.ApplicationUserSID = x2.ApplicationUserSID
	join
		sf.TaskQueueSubscriber x3 on x2.TaskQueueSID			 = x3.TaskQueueSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Task Queue Subscriber record(s) deleted';
	end;

	-- Table: sf.TaskTrigger
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.TaskQueue->sf.TaskTrigger

	delete
	x3
	from
		sf.Person					 z
	join
		sf.ApplicationUser x1 on z.PersonSID					 = x1.PersonSID
	join
		sf.TaskQueue			 x2 on x1.ApplicationUserSID = x2.ApplicationUserSID
	join
		sf.TaskTrigger		 x3 on x2.TaskQueueSID			 = x3.TaskQueueSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Task Trigger record(s) deleted';
	end;

	-- Table: dbo.GLTransaction
	-- FK Chain: sf.Person->dbo.Payment->dbo.GLTransaction

	delete
	x2
	from
		sf.Person					z
	join
		dbo.Payment				x1 on z.PersonSID		= x1.PersonSID
	join
		dbo.GLTransaction x2 on x1.PaymentSID = x2.PaymentSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' GLTransaction record(s) deleted';
	end;

	-- Table: dbo.InvoiceItem
	-- FK Chain: sf.Person->dbo.Invoice->dbo.InvoiceItem

	delete
	x2
	from
		sf.Person				z
	join
		dbo.Invoice			x1 on z.PersonSID		= x1.PersonSID
	join
		dbo.InvoiceItem x2 on x1.InvoiceSID = x2.InvoiceSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Invoice Item record(s) deleted';
	end;

	-- Table: dbo.InvoicePayment
	-- FK Chain: sf.Person->dbo.Invoice->dbo.InvoicePayment

	delete
	x2
	from
		sf.Person					 z
	join
		dbo.Invoice				 x1 on z.PersonSID	 = x1.PersonSID
	join
		dbo.InvoicePayment x2 on x1.InvoiceSID = x2.InvoiceSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Invoice Payment record(s) deleted';
	end;

	-- Table: dbo.InvoicePayment
	-- FK Chain: sf.Person->dbo.Payment->dbo.InvoicePayment

	delete
	x2
	from
		sf.Person					 z
	join
		dbo.Payment				 x1 on z.PersonSID	 = x1.PersonSID
	join
		dbo.InvoicePayment x2 on x1.PaymentSID = x2.PaymentSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Invoice Payment record(s) deleted';
	end;

	-- Table: dbo.PAPTransaction
	-- FK Chain: sf.Person->dbo.Payment->dbo.PAPTransaction

	delete
	x2
	from
		sf.Person					 z
	join
		dbo.Payment				 x1 on z.PersonSID	 = x1.PersonSID
	join
		dbo.PAPTransaction x2 on x1.PaymentSID = x2.PaymentSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' PAPTransaction record(s) deleted';
	end;

	-- Table: dbo.PAPTransaction
	-- FK Chain: sf.Person->dbo.PAPSubscription->dbo.PAPTransaction

	delete
	x2
	from
		sf.Person						z
	join
		dbo.PAPSubscription x1 on z.PersonSID						= x1.PersonSID
	join
		dbo.PAPTransaction	x2 on x1.PAPSubscriptionSID = x2.PAPSubscriptionSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' PAPTransaction record(s) deleted';
	end;

	-- Table: dbo.PaymentProcessorResponse
	-- FK Chain: sf.Person->dbo.Payment->dbo.PaymentProcessorResponse

	delete
	x2
	from
		sf.Person										 z
	join
		dbo.Payment									 x1 on z.PersonSID	 = x1.PersonSID
	join
		dbo.PaymentProcessorResponse x2 on x1.PaymentSID = x2.PaymentSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Payment Processor Response record(s) deleted';
	end;

	-- Table: dbo.PersonDocContext
	-- FK Chain: sf.Person->dbo.PersonDoc->dbo.PersonDocContext

	delete
	x2
	from
		sf.Person						 z
	join
		dbo.PersonDoc				 x1 on z.PersonSID		 = x1.PersonSID
	join
		dbo.PersonDocContext x2 on x1.PersonDocSID = x2.PersonDocSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Person Doc Context record(s) deleted';
	end;

	-- Table: dbo.PersonNoteContext
	-- FK Chain: sf.Person->dbo.PersonNote->dbo.PersonNoteContext

	delete
	x2
	from
		sf.Person							z
	join
		dbo.PersonNote				x1 on z.PersonSID			 = x1.PersonSID
	join
		dbo.PersonNoteContext x2 on x1.PersonNoteSID = x2.PersonNoteSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Person Note Context record(s) deleted';
	end;

	-- Table: dbo.ProfileUpdateResponse
	-- FK Chain: sf.Person->dbo.ProfileUpdate->dbo.ProfileUpdateResponse

	delete
	x2
	from
		sf.Person									z
	join
		dbo.ProfileUpdate					x1 on z.PersonSID					= x1.PersonSID
	join
		dbo.ProfileUpdateResponse x2 on x1.ProfileUpdateSID = x2.ProfileUpdateSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Profile Update Response record(s) deleted';
	end;

	-- Table: dbo.ProfileUpdateStatus
	-- FK Chain: sf.Person->dbo.ProfileUpdate->dbo.ProfileUpdateStatus

	delete
	x2
	from
		sf.Person								z
	join
		dbo.ProfileUpdate				x1 on z.PersonSID					= x1.PersonSID
	join
		dbo.ProfileUpdateStatus x2 on x1.ProfileUpdateSID = x2.ProfileUpdateSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Profile Update Status record(s) deleted';
	end;

	-- Table: dbo.RegistrantApp
	-- FK Chain: sf.Person->dbo.Invoice->dbo.RegistrantApp

	delete
	x2
	from
		sf.Person					z
	join
		dbo.Invoice				x1 on z.PersonSID		= x1.PersonSID
	join
		dbo.RegistrantApp x2 on x1.InvoiceSID = x2.InvoiceSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant App record(s) deleted';
	end;

	-- Table: dbo.RegistrantAppReviewResponse
	-- FK Chain: sf.Person->dbo.RegistrantAppReview->dbo.RegistrantAppReviewResponse

	delete
	x2
	from
		sf.Person												z
	join
		dbo.RegistrantAppReview					x1 on z.PersonSID								= x1.PersonSID
	join
		dbo.RegistrantAppReviewResponse x2 on x1.RegistrantAppReviewSID = x2.RegistrantAppReviewSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant App Review Response record(s) deleted';
	end;

	-- Table: dbo.RegistrantAppReviewStatus
	-- FK Chain: sf.Person->dbo.RegistrantAppReview->dbo.RegistrantAppReviewStatus

	delete
	x2
	from
		sf.Person											z
	join
		dbo.RegistrantAppReview				x1 on z.PersonSID								= x1.PersonSID
	join
		dbo.RegistrantAppReviewStatus x2 on x1.RegistrantAppReviewSID = x2.RegistrantAppReviewSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant App Review Status record(s) deleted';
	end;

	-- Table: dbo.RegistrantAudit
	-- FK Chain: sf.Person->dbo.Registrant->dbo.RegistrantAudit

	delete
	x2
	from
		sf.Person						z
	join
		dbo.Registrant			x1 on z.PersonSID			 = x1.PersonSID
	join
		dbo.RegistrantAudit x2 on x1.RegistrantSID = x2.RegistrantSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant Audit record(s) deleted';
	end;

	-- Table: dbo.RegistrantAuditReviewResponse
	-- FK Chain: sf.Person->dbo.RegistrantAuditReview->dbo.RegistrantAuditReviewResponse

	delete
	x2
	from
		sf.Person													z
	join
		dbo.RegistrantAuditReview					x1 on z.PersonSID									= x1.PersonSID
	join
		dbo.RegistrantAuditReviewResponse x2 on x1.RegistrantAuditReviewSID = x2.RegistrantAuditReviewSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant Audit Review Response record(s) deleted';
	end;

	-- Table: dbo.RegistrantAuditReviewStatus
	-- FK Chain: sf.Person->dbo.RegistrantAuditReview->dbo.RegistrantAuditReviewStatus

	delete
	x2
	from
		sf.Person												z
	join
		dbo.RegistrantAuditReview				x1 on z.PersonSID									= x1.PersonSID
	join
		dbo.RegistrantAuditReviewStatus x2 on x1.RegistrantAuditReviewSID = x2.RegistrantAuditReviewSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant Audit Review Status record(s) deleted';
	end;

	-- Table: dbo.RegistrantCredential
	-- FK Chain: sf.Person->dbo.Registrant->dbo.RegistrantCredential

	delete
	x2
	from
		sf.Person								 z
	join
		dbo.Registrant					 x1 on z.PersonSID			= x1.PersonSID
	join
		dbo.RegistrantCredential x2 on x1.RegistrantSID = x2.RegistrantSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant Credential record(s) deleted';
	end;

	-- Table: dbo.RegistrantEmployment
	-- FK Chain: sf.Person->dbo.Registrant->dbo.RegistrantEmployment

	delete
	x2
	from
		sf.Person								 z
	join
		dbo.Registrant					 x1 on z.PersonSID			= x1.PersonSID
	join
		dbo.RegistrantEmployment x2 on x1.RegistrantSID = x2.RegistrantSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant Employment record(s) deleted';
	end;

	-- Table: dbo.RegistrantExam
	-- FK Chain: sf.Person->dbo.Registrant->dbo.RegistrantExam

	delete
	x2
	from
		sf.Person					 z
	join
		dbo.Registrant		 x1 on z.PersonSID			= x1.PersonSID
	join
		dbo.RegistrantExam x2 on x1.RegistrantSID = x2.RegistrantSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant Exam record(s) deleted';
	end;

	-- Table: dbo.RegistrantExam
	-- FK Chain: sf.Person->dbo.Invoice->dbo.RegistrantExam

	delete
	x2
	from
		sf.Person					 z
	join
		dbo.Invoice				 x1 on z.PersonSID	 = x1.PersonSID
	join
		dbo.RegistrantExam x2 on x1.InvoiceSID = x2.InvoiceSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant Exam record(s) deleted';
	end;

	-- Table: dbo.RegistrantIdentifier
	-- FK Chain: sf.Person->dbo.Registrant->dbo.RegistrantIdentifier

	delete
	x2
	from
		sf.Person								 z
	join
		dbo.Registrant					 x1 on z.PersonSID			= x1.PersonSID
	join
		dbo.RegistrantIdentifier x2 on x1.RegistrantSID = x2.RegistrantSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant Identifier record(s) deleted';
	end;

	-- Table: dbo.RegistrantInactivePeriod
	-- FK Chain: sf.Person->dbo.Registrant->dbo.RegistrantInactivePeriod

	delete
	x2
	from
		sf.Person										 z
	join
		dbo.Registrant							 x1 on z.PersonSID			= x1.PersonSID
	join
		dbo.RegistrantInactivePeriod x2 on x1.RegistrantSID = x2.RegistrantSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant Inactive Period record(s) deleted';
	end;

	-- Table: dbo.RegistrantLanguage
	-- FK Chain: sf.Person->dbo.Registrant->dbo.RegistrantLanguage

	delete
	x2
	from
		sf.Person							 z
	join
		dbo.Registrant				 x1 on z.PersonSID			= x1.PersonSID
	join
		dbo.RegistrantLanguage x2 on x1.RegistrantSID = x2.RegistrantSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant Language record(s) deleted';
	end;

	-- Table: dbo.RegistrantLearningPlan
	-- FK Chain: sf.Person->dbo.Registrant->dbo.RegistrantLearningPlan

	delete
	x2
	from
		sf.Person									 z
	join
		dbo.Registrant						 x1 on z.PersonSID			= x1.PersonSID
	join
		dbo.RegistrantLearningPlan x2 on x1.RegistrantSID = x2.RegistrantSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant Learning Plan record(s) deleted';
	end;

	-- Table: dbo.RegistrantPractice
	-- FK Chain: sf.Person->dbo.Registrant->dbo.RegistrantPractice

	delete
	x2
	from
		sf.Person							 z
	join
		dbo.Registrant				 x1 on z.PersonSID			= x1.PersonSID
	join
		dbo.RegistrantPractice x2 on x1.RegistrantSID = x2.RegistrantSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant Practice record(s) deleted';
	end;

	-- Table: dbo.RegistrantPracticeRestriction
	-- FK Chain: sf.Person->dbo.Registrant->dbo.RegistrantPracticeRestriction

	delete
	x2
	from
		sf.Person													z
	join
		dbo.Registrant										x1 on z.PersonSID			 = x1.PersonSID
	join
		dbo.RegistrantPracticeRestriction x2 on x1.RegistrantSID = x2.RegistrantSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant Practice Restriction record(s) deleted';
	end;

	-- Table: dbo.RegistrantRenewal
	-- FK Chain: sf.Person->dbo.Invoice->dbo.RegistrantRenewal

	delete
	x2
	from
		sf.Person							z
	join
		dbo.Invoice						x1 on z.PersonSID		= x1.PersonSID
	join
		dbo.RegistrantRenewal x2 on x1.InvoiceSID = x2.InvoiceSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant Renewal record(s) deleted';
	end;

	-- Table: dbo.Registration
	-- FK Chain: sf.Person->dbo.Invoice->dbo.Registration

	delete
	x2
	from
		sf.Person				 z
	join
		dbo.Invoice			 x1 on z.PersonSID	 = x1.PersonSID
	join
		dbo.Registration x2 on x1.InvoiceSID = x2.InvoiceSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registration record(s) deleted';
	end;

	-- Table: dbo.Registration
	-- FK Chain: sf.Person->dbo.Registrant->dbo.Registration

	delete
	x2
	from
		sf.Person				 z
	join
		dbo.Registrant	 x1 on z.PersonSID			= x1.PersonSID
	join
		dbo.Registration x2 on x1.RegistrantSID = x2.RegistrantSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registration record(s) deleted';
	end;

	-- Table: dbo.RegistrationChange
	-- FK Chain: sf.Person->dbo.Invoice->dbo.RegistrationChange

	delete
	x2
	from
		sf.Person							 z
	join
		dbo.Invoice						 x1 on z.PersonSID	 = x1.PersonSID
	join
		dbo.RegistrationChange x2 on x1.InvoiceSID = x2.InvoiceSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registration Change record(s) deleted';
	end;

	-- Table: dbo.RegistrationChangeRequirement
	-- FK Chain: sf.Person->dbo.PersonDoc->dbo.RegistrationChangeRequirement

	delete
	x2
	from
		sf.Person													z
	join
		dbo.PersonDoc											x1 on z.PersonSID			= x1.PersonSID
	join
		dbo.RegistrationChangeRequirement x2 on x1.PersonDocSID = x2.PersonDocSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registration Change Requirement record(s) deleted';
	end;

	-- Table: dbo.RegistrationProfile
	-- FK Chain: sf.Person->dbo.PersonMailingAddress->dbo.RegistrationProfile

	delete
	x2
	from
		sf.Person								 z
	join
		dbo.PersonMailingAddress x1 on z.PersonSID								= x1.PersonSID
	join
		dbo.RegistrationProfile	 x2 on x1.PersonMailingAddressSID = x2.PersonMailingAddressSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registration Profile record(s) deleted';
	end;

	-- Table: dbo.RegistrationProfile
	-- FK Chain: sf.Person->dbo.Registrant->dbo.RegistrationProfile

	delete
	x2
	from
		sf.Person								z
	join
		dbo.Registrant					x1 on z.PersonSID			 = x1.PersonSID
	join
		dbo.RegistrationProfile x2 on x1.RegistrantSID = x2.RegistrantSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registration Profile record(s) deleted';
	end;

	-- Table: dbo.Reinstatement
	-- FK Chain: sf.Person->dbo.Invoice->dbo.Reinstatement

	delete
	x2
	from
		sf.Person					z
	join
		dbo.Invoice				x1 on z.PersonSID		= x1.PersonSID
	join
		dbo.Reinstatement x2 on x1.InvoiceSID = x2.InvoiceSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Reinstatement record(s) deleted';
	end;

	-- Table: sf.ApplicationUserGrant
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.ApplicationUserGrant

	delete
	x2
	from
		sf.Person								z
	join
		sf.ApplicationUser			x1 on z.PersonSID						= x1.PersonSID
	join
		sf.ApplicationUserGrant x2 on x1.ApplicationUserSID = x2.ApplicationUserSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Application User Grant record(s) deleted';
	end;

	-- Table: sf.ApplicationUserProfileProperty
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.ApplicationUserProfileProperty

	delete
	x2
	from
		sf.Person													z
	join
		sf.ApplicationUser								x1 on z.PersonSID						= x1.PersonSID
	join
		sf.ApplicationUserProfileProperty x2 on x1.ApplicationUserSID = x2.ApplicationUserSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Application User Profile Property record(s) deleted';
	end;

	-- Table: sf.ApplicationUserSession
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.ApplicationUserSession

	delete
	x2
	from
		sf.Person									z
	join
		sf.ApplicationUser				x1 on z.PersonSID						= x1.PersonSID
	join
		sf.ApplicationUserSession x2 on x1.ApplicationUserSID = x2.ApplicationUserSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Application User Session record(s) deleted';
	end;

	-- Table: sf.ClearedAnnouncement
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.ClearedAnnouncement

	delete
	x2
	from
		sf.Person							 z
	join
		sf.ApplicationUser		 x1 on z.PersonSID					 = x1.PersonSID
	join
		sf.ClearedAnnouncement x2 on x1.ApplicationUserSID = x2.ApplicationUserSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Cleared Announcement record(s) deleted';
	end;

	-- Table: sf.EmailMessage
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.EmailMessage

	delete
	x2
	from
		sf.Person					 z
	join
		sf.ApplicationUser x1 on z.PersonSID					 = x1.PersonSID
	join
		sf.EmailMessage		 x2 on x1.ApplicationUserSID = x2.ApplicationUserSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Email Message record(s) deleted';
	end;

	-- Table: sf.EmailTrigger
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.EmailTrigger

	delete
	x2
	from
		sf.Person					 z
	join
		sf.ApplicationUser x1 on z.PersonSID					 = x1.PersonSID
	join
		sf.EmailTrigger		 x2 on x1.ApplicationUserSID = x2.ApplicationUserSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Email Trigger record(s) deleted';
	end;

	-- Table: sf.Form
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.Form

	delete
	x2
	from
		sf.Person					 z
	join
		sf.ApplicationUser x1 on z.PersonSID					 = x1.PersonSID
	join
		sf.Form						 x2 on x1.ApplicationUserSID = x2.ApplicationUserSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Form record(s) deleted';
	end;

	-- Table: sf.PersonGroup
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.PersonGroup

	delete
	x2
	from
		sf.Person					 z
	join
		sf.ApplicationUser x1 on z.PersonSID					 = x1.PersonSID
	join
		sf.PersonGroup		 x2 on x1.ApplicationUserSID = x2.ApplicationUserSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Person Group record(s) deleted';
	end;

	-- Table: sf.Task
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.Task

	delete
	x2
	from
		sf.Person					 z
	join
		sf.ApplicationUser x1 on z.PersonSID					 = x1.PersonSID
	join
		sf.Task						 x2 on x1.ApplicationUserSID = x2.ApplicationUserSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Task record(s) deleted';
	end;

	-- Table: sf.TaskQueue
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.TaskQueue

	delete
	x2
	from
		sf.Person					 z
	join
		sf.ApplicationUser x1 on z.PersonSID					 = x1.PersonSID
	join
		sf.TaskQueue			 x2 on x1.ApplicationUserSID = x2.ApplicationUserSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Task Queue record(s) deleted';
	end;

	-- Table: sf.TaskQueueSubscriber
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.TaskQueueSubscriber

	delete
	x2
	from
		sf.Person							 z
	join
		sf.ApplicationUser		 x1 on z.PersonSID					 = x1.PersonSID
	join
		sf.TaskQueueSubscriber x2 on x1.ApplicationUserSID = x2.ApplicationUserSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Task Queue Subscriber record(s) deleted';
	end;

	-- Table: sf.TaskTrigger
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.TaskTrigger

	delete
	x2
	from
		sf.Person					 z
	join
		sf.ApplicationUser x1 on z.PersonSID					 = x1.PersonSID
	join
		sf.TaskTrigger		 x2 on x1.ApplicationUserSID = x2.ApplicationUserSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Task Trigger record(s) deleted';
	end;

	-- Table: sf.TextMessage
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.TextMessage

	delete
	x2
	from
		sf.Person					 z
	join
		sf.ApplicationUser x1 on z.PersonSID					 = x1.PersonSID
	join
		sf.TextMessage		 x2 on x1.ApplicationUserSID = x2.ApplicationUserSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Text Message record(s) deleted';
	end;

	-- Table: sf.TextTrigger
	-- FK Chain: sf.Person->sf.ApplicationUser->sf.TextTrigger

	delete
	x2
	from
		sf.Person					 z
	join
		sf.ApplicationUser x1 on z.PersonSID					 = x1.PersonSID
	join
		sf.TextTrigger		 x2 on x1.ApplicationUserSID = x2.ApplicationUserSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Text Trigger record(s) deleted';
	end;

	-- Table: stg.CredentialProfile
	-- FK Chain: sf.Person->dbo.Registrant->stg.CredentialProfile

	delete
	x2
	from
		sf.Person							z
	join
		dbo.Registrant				x1 on z.PersonSID			 = x1.PersonSID
	join
		stg.CredentialProfile x2 on x1.RegistrantSID = x2.RegistrantSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Credential Profile record(s) deleted';
	end;

	-- Table: stg.PersonProfile
	-- FK Chain: sf.Person->dbo.Registrant->stg.PersonProfile

	delete
	x2
	from
		sf.Person					z
	join
		dbo.Registrant		x1 on z.PersonSID			 = x1.PersonSID
	join
		stg.PersonProfile x2 on x1.RegistrantSID = x2.RegistrantSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Person Profile record(s) deleted';
	end;

	-- Table: stg.PersonProfile
	-- FK Chain: sf.Person->sf.ApplicationUser->stg.PersonProfile

	delete
	x2
	from
		sf.Person					 z
	join
		sf.ApplicationUser x1 on z.PersonSID					 = x1.PersonSID
	join
		stg.PersonProfile	 x2 on x1.ApplicationUserSID = x2.ApplicationUserSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Person Profile record(s) deleted';
	end;

	-- Table: stg.PersonProfile
	-- FK Chain: sf.Person->sf.PersonEmailAddress->stg.PersonProfile

	delete
	x2
	from
		sf.Person							z
	join
		sf.PersonEmailAddress x1 on z.PersonSID							 = x1.PersonSID
	join
		stg.PersonProfile			x2 on x1.PersonEmailAddressSID = x2.PersonEmailAddressSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Person Profile record(s) deleted';
	end;

	-- Table: stg.PersonProfile
	-- FK Chain: sf.Person->dbo.PersonMailingAddress->stg.PersonProfile

	delete
	x2
	from
		sf.Person								 z
	join
		dbo.PersonMailingAddress x1 on z.PersonSID								= x1.PersonSID
	join
		stg.PersonProfile				 x2 on x1.PersonMailingAddressSID = x2.PersonMailingAddressSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Person Profile record(s) deleted';
	end;

	-- Table: dbo.Invoice
	-- FK Chain: sf.Person->dbo.Invoice

	delete
	x1
	from
		sf.Person		z
	join
		dbo.Invoice x1 on z.PersonSID = x1.PersonSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Invoice record(s) deleted';
	end;

	-- Table: dbo.OrgContact
	-- FK Chain: sf.Person->dbo.OrgContact

	delete
	x1
	from
		sf.Person			 z
	join
		dbo.OrgContact x1 on z.PersonSID = x1.PersonSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Org Contact record(s) deleted';
	end;

	-- Table: dbo.PAPSubscription
	-- FK Chain: sf.Person->dbo.PAPSubscription

	delete
	x1
	from
		sf.Person						z
	join
		dbo.PAPSubscription x1 on z.PersonSID = x1.PersonSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' PAPSubscription record(s) deleted';
	end;

	-- Table: dbo.Payment
	-- FK Chain: sf.Person->dbo.Payment

	delete
	x1
	from
		sf.Person		z
	join
		dbo.Payment x1 on z.PersonSID = x1.PersonSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Payment record(s) deleted';
	end;

	-- Table: dbo.PersonDoc
	-- FK Chain: sf.Person->dbo.PersonDoc

	delete
	x1
	from
		sf.Person			z
	join
		dbo.PersonDoc x1 on z.PersonSID = x1.PersonSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Person Doc record(s) deleted';
	end;

	-- Table: dbo.PersonMailingAddress
	-- FK Chain: sf.Person->dbo.PersonMailingAddress

	delete
	x1
	from
		sf.Person								 z
	join
		dbo.PersonMailingAddress x1 on z.PersonSID = x1.PersonSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Person Mailing Address record(s) deleted';
	end;

	-- Table: dbo.PersonNote
	-- FK Chain: sf.Person->dbo.PersonNote

	delete
	x1
	from
		sf.Person			 z
	join
		dbo.PersonNote x1 on z.PersonSID = x1.PersonSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Person Note record(s) deleted';
	end;

	-- Table: dbo.ProfileUpdate
	-- FK Chain: sf.Person->dbo.ProfileUpdate

	delete
	x1
	from
		sf.Person					z
	join
		dbo.ProfileUpdate x1 on z.PersonSID = x1.PersonSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Profile Update record(s) deleted';
	end;

	-- Table: dbo.Registrant
	-- FK Chain: sf.Person->dbo.Registrant

	delete
	x1
	from
		sf.Person			 z
	join
		dbo.Registrant x1 on z.PersonSID = x1.PersonSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant record(s) deleted';
	end;

	-- Table: dbo.RegistrantAppReview
	-- FK Chain: sf.Person->dbo.RegistrantAppReview

	delete
	x1
	from
		sf.Person								z
	join
		dbo.RegistrantAppReview x1 on z.PersonSID = x1.PersonSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant App Review record(s) deleted';
	end;

	-- Table: dbo.RegistrantAuditReview
	-- FK Chain: sf.Person->dbo.RegistrantAuditReview

	delete
	x1
	from
		sf.Person									z
	join
		dbo.RegistrantAuditReview x1 on z.PersonSID = x1.PersonSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Registrant Audit Review record(s) deleted';
	end;

	-- Table: sf.ApplicationUser
	-- FK Chain: sf.Person->sf.ApplicationUser

	delete
	x1
	from
		sf.Person					 z
	join
		sf.ApplicationUser x1 on z.PersonSID = x1.PersonSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Application User record(s) deleted';
	end;

	-- Table: sf.PersonEmailAddress
	-- FK Chain: sf.Person->sf.PersonEmailAddress

	delete
	x1
	from
		sf.Person							z
	join
		sf.PersonEmailAddress x1 on z.PersonSID = x1.PersonSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Person Email Address record(s) deleted';
	end;

	-- Table: sf.PersonEmailMessage
	-- FK Chain: sf.Person->sf.PersonEmailMessage

	delete
	x1
	from
		sf.Person							z
	join
		sf.PersonEmailMessage x1 on z.PersonSID = x1.PersonSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Person Email Message record(s) deleted';
	end;

	-- Table: sf.PersonGroupMember
	-- FK Chain: sf.Person->sf.PersonGroupMember

	delete
	x1
	from
		sf.Person						 z
	join
		sf.PersonGroupMember x1 on z.PersonSID = x1.PersonSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Person Group Member record(s) deleted';
	end;

	-- Table: sf.PersonMailingPreference
	-- FK Chain: sf.Person->sf.PersonMailingPreference

	delete
	x1
	from
		sf.Person									 z
	join
		sf.PersonMailingPreference x1 on z.PersonSID = x1.PersonSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Person Mailing Preference record(s) deleted';
	end;

	-- Table: sf.PersonOtherName
	-- FK Chain: sf.Person->sf.PersonOtherName

	delete
	x1
	from
		sf.Person					 z
	join
		sf.PersonOtherName x1 on z.PersonSID = x1.PersonSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Person Other Name record(s) deleted';
	end;

	-- Table: sf.PersonTextMessage
	-- FK Chain: sf.Person->sf.PersonTextMessage

	delete
	x1
	from
		sf.Person						 z
	join
		sf.PersonTextMessage x1 on z.PersonSID = x1.PersonSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Person Text Message record(s) deleted';
	end;

	-- Table: stg.PersonProfile
	-- FK Chain: sf.Person->stg.PersonProfile

	delete
	x1
	from
		sf.Person					z
	join
		stg.PersonProfile x1 on z.PersonSID = x1.PersonSID
	where
		z.PersonSID = @PersonSIDFrom;

	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Person Profile record(s) deleted';
	end;

	-- and finally delete the base PERSON record

	delete sf .Person where PersonSID = @PersonSIDFrom;
	set @rowsAffected = @@rowcount;
	set @totalRowsAffected += @rowsAffected;

	if @rowsAffected > 0
	begin
		set @ChangeLog += @CRLF + @TAB + ltrim(@rowsAffected) + N' Person record deleted';
	end;

	if @totalRowsAffected = 0
	begin
		set @ChangeLog += @CRLF + @TAB + 'None';
	end;

	if @DebugLevel > 1
	begin

		exec sf.pDebugPrint
			@DebugString = N'Deletes complete'
		 ,@TimeCheck = @timeCheck output;

	end;

	return (@errorNo);
end;
GO
