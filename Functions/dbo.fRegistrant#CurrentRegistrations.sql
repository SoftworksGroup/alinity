SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fRegistrant#CurrentRegistrations] (@RegistrantSID int) -- key of registrant to return current registrations for
returns @CurrentRegistrations table
(
	RegistrantSID								 int								-- key of registrant who registrations are assigned to
 ,RegistrationSID							 int								-- key of each registration returned
 ,RegistrantRenewalSID				 int								-- key of renewal associated with the registration if any
 ,RegistrationNo							 nvarchar(50)				-- system assigned registration number based on registrantNo.year.sequence
 ,PracticeRegisterSID					 int								-- key of the practice register the registration is under
 ,PracticeRegisterSectionSID	 int								-- key of the section of register the registration is under
 ,EffectiveTime								 datetime						-- date and time registration became effective
 ,ExpiryTime									 datetime						-- date and time the registration expires
 ,PracticeRegisterName				 nvarchar(65)				-- name of the practice register registration is under
 ,PracticeRegisterLabel				 nvarchar(35)				-- label of the practice register registration is under	
 ,IsActivePractice						 bit								-- indicates whether type of registration is active practice
 ,PracticeRegisterSectionLabel nvarchar(35)				-- label of the section of register the registration is under		
 ,IsSectionDisplayedOnLicense	 bit								-- indicates whether the section is displayed on registration
 ,LicenseRegistrationYear			 smallint						-- registration year the registration is/was in effect
 ,RenewalRegistrationYear			 smallint						-- registration year the next renewal is available for (null if not available)
 ,RenewalStatusSCD						 varchar(25)				-- status code of the registration's renewal - if any
 ,RenewalStatusLabel					 nvarchar(35)				-- status label of the registration's renewal - if any
 ,RenewalUpdateTime						 datetimeoffset(7)	-- date and time renewal of the registration was last updated 
 ,RenewalRowGUID							 uniqueidentifier		-- row GUID of the renewal used to get form set statuses
 ,RenewalFormSID							 int								-- form of the renewal used to get form set statuses
 ,RenewalIsEditEnabled				 bit								-- whether edit is enabled on the renewal form associated with registration
 ,RenewalIsDeleteEnabled			 bit								-- whether delete is enabled on renewal form associated with registration
 ,RenewalIsUnPaid							 bit								-- whether invoice associated with the registrations renewal is unpaid
 ,RenewalTotalDue							 decimal(11, 2)			-- amount due on invoice associated with the registration - if any
 ,RenewalIsRegisterChange			 bit								-- whether the current renewal reflected a register change
 ,IsCurrentUserVerifier				 bit								-- whether the currently logged in user is a verifier (has early access to renewal)
 ,RegistrationLabel						 nvarchar(80)				-- a label to use to display the registration/registration
 ,IsRenewalEnabled						 bit								-- whether renewal is enabled for this registration
 ,IsReinstatementEnabled			 bit								-- whether reinstatement is enabled for this registration
 ,RegisterRank								 smallint						-- rank order of the registration based on register rank
)
/*********************************************************************************************************************************
Function  : Registrant - Get Current Licenses
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : This function returns a data set of currently active registrations for a registrant along with renewal status
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)				| Month Year	| Change Summary
				 : ---------------- | ------------|---------------------------------------------------------------------------------------
				 : Tim Edlund				| Sep 2017 		| Initial version.
				 : Cory Ng					| Dec 2017		| Added renewal row GUID in returned dataset to be used to get renewal form set statuses
				 : Tim Edlund				| Jan 2018		| Removed WHERE clause criteria to select for current registration year only
----------------------------------------------------------------------------------------------------------------------------------
 
Comments
--------
This function is used across the system to obtain the list of currently active registrations for a registrant.  A sproc wrapper for
the function also exists for calls from the UI.  While most implementations allow only a single active registration, the function
will return multiple records if more than one active registration is in effect at the time of the call.  The current time in the
user timezone is used for comparison.

A registrant may only have 1 open renewal for each registration.  They may "withdraw" a renewal created in error (e.g. renewing
to wrong status) and another renewal record created.  This function eliminates any registration-renewal pairing where the 
renewal record has been withdrawn.

Maintenance Note
----------------
The structure returned by this function and that returned by dbo.fRegistrant#LatestRegistration must be kept the same since 
the #Latest function calls this one expecting the same structure.  This function also uses the same content selection
selection as the #LatestRegistration function - only the WHERE clause is different.

Example
--------------
<TestHarness>
  <Test Name = "RandomYear" IsDefault ="true" Description="Executes the function to return renewal registration data for a random year.">
    <SQLScript>
      <![CDATA[

					declare
							@registrantSID							int
						,	@currentRegistrationYear		int
						, @practiceRegisterSectionSID	int
						,	@regEffective								datetime2
						,	@regExpiry									datetime2
					

		begin tran

		select top 1
			@registrantSID = r.RegistrantSID
		from
			dbo.Registrant r
		order by 
		newid()

		
		select
			@currentRegistrationYear = 	dbo.fRegistrationYear#Current()

				select
			@practiceRegisterSectionSID = prs.PracticeRegisterSectionSID
		from
			dbo.PracticeRegister pr
		join
			dbo.PracticeRegisterSection prs on pr.PracticeRegisterSID = prs.PracticeRegisterSID
		where
			pr.PracticeRegisterLabel = 'Active'
		and
			prs.IsActive = cast( 1 as bit)
		
			
		select
				@regEffective		= rsy.YearStartTime
			,	@regExpiry			= rsy.YearEndTime
		from
			dbo.RegistrationSchedule rs
		join
			dbo.RegistrationScheduleYear rsy on rs.RegistrationScheduleSID = rsy.RegistrationScheduleSID
		where
			rs.IsDefault = cast(1 as bit)
		and
			rsy.RegistrationYear = @currentRegistrationYear

		delete from dbo.Registration
		where
			RegistrantSID = @registrantSID
		and
			RegistrationYear = @currentRegistrationYear

		insert into
			dbo.Registration
		(
				RegistrantSID
			,	PracticeRegisterSectionSID
			,	RegistrationYear
			,	LicenseNO
			,	EffectiveTime
			,	ExpiryTime
		)
		select
				@registrantSID
			,	@practiceRegisterSectionSID
			,	@currentRegistrationYear
			,	'***TEST***'
			, @regEffective
			,	@regExpiry
		

		select
				LicenseNO
			,	PracticeRegisterLabel
		from
			dbo.fRegistrant#CurrentRegistrations(@registrantSID) x;
		
		if @@ROWCOUNT = 0 raiserror( N'* ERROR: no sample data found to run test', 18, 1) 
		if @@TRANCOUNT > 0 rollback

		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="1" Value="***TEST***" />
			<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="2" Value="Active" />
      <Assertion Type="ExecutionTime" Value="00:00:10"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName			= 'dbo.fRegistrant#CurrentRegistrations'
	,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */
begin
	declare
		@ON										 bit			= cast(1 as bit)													-- constant for bit comparisons = 1
	 ,@OFF									 bit			= cast(0 as bit)													-- constant for bit comparison = 0
	 ,@isCurrentUserVerifier bit			= sf.fIsGranted('EXTERNAL.VERIFICATION')	-- indicates if the current user is a renewal verifier
	 ,@now									 datetime = sf.fNow();															-- current time in user timezone

	insert
		@CurrentRegistrations
	(
		RegistrantSID
	 ,RegistrationSID
	 ,RegistrantRenewalSID
	 ,RegistrationNo
	 ,PracticeRegisterSID
	 ,PracticeRegisterSectionSID
	 ,EffectiveTime
	 ,ExpiryTime
	 ,PracticeRegisterName
	 ,PracticeRegisterLabel
	 ,IsActivePractice
	 ,PracticeRegisterSectionLabel
	 ,IsSectionDisplayedOnLicense
	 ,LicenseRegistrationYear
	 ,RenewalRegistrationYear
	 ,RenewalStatusSCD
	 ,RenewalStatusLabel
	 ,RenewalUpdateTime
	 ,RenewalRowGUID
	 ,RenewalFormSID
	 ,RenewalIsEditEnabled
	 ,RenewalIsDeleteEnabled
	 ,RenewalIsUnPaid
	 ,RenewalTotalDue
	 ,RenewalIsRegisterChange
	 ,IsCurrentUserVerifier
	 ,RegistrationLabel
	 ,IsRenewalEnabled
	 ,IsReinstatementEnabled
	 ,RegisterRank
	)
	select
		rl.RegistrantSID
	 ,rl.RegistrationSID
	 ,rr.RegistrantRenewalSID			-- ** Maintenance Note:  if modifying this select also change fRegistrant#LatestRegistration function !!
	 ,rl.RegistrationNo
	 ,prs.PracticeRegisterSID
	 ,rl.PracticeRegisterSectionSID
	 ,rl.EffectiveTime
	 ,rl.ExpiryTime
	 ,pr.PracticeRegisterName
	 ,pr.PracticeRegisterLabel
	 ,pr.IsActivePractice
	 ,prs.PracticeRegisterSectionLabel
	 ,prs.IsDisplayedOnLicense																																													IsSectionDisplayedOnLicense
	 ,rl.RegistrationYear																																																LicenseRegistrationYear
	 ,rr.RegistrationYear																																																RenewalRegistrationYear
	 ,rr.FormStatusSCD																																											RenewalStatusSCD
	 ,rr.FormStatusLabel																																										RenewalStatusLabel
	 ,rr.UpdateTime																																																			RenewalUpdateTime
	 ,rr.RowGUID																																																				RenewalRowGUID
	 ,rr.FormSID																																																				RenewalFormSID
	 ,isnull(rr.IsEditEnabled, cast(0 as bit))																																					RenewalIsEditEnabled
	 ,dbo.fRegistrantRenewal#IsDeleteEnabled(rr.RegistrantRenewalSID)																										RenewalIsDeleteEnabled
	 ,isnull(rr.IsUnPaid, @OFF)																																													RenewalIsUnPaid
	 ,rr.TotalDue																																																				RenewalTotalDue
	 ,isnull(rr.IsRegisterChange, @OFF)																																									RenewalIsRegisterChange
	 ,@isCurrentUserVerifier																																														IsCurrentUserVerifier
	 ,ltrim(rl.RegistrationYear) + N' ' + pr.PracticeRegisterLabel
		+ (case when prs.IsDisplayedOnLicense = cast(1 as bit) then ' - ' + prs.PracticeRegisterSectionLabel else '' end) RegistrationLabel
	 ,case
			when rr.RegistrantRenewalSID is not null then @OFF					 -- registration already has a renewal record
			when pr.IsRenewalEnabled = @OFF then @OFF										 -- register does not allow renewal
			else cast(isnull(rsy.RegistrationScheduleYearSID, 0) as bit) -- otherwise check schedule for open renewal
		end																																																								IsRenewalEnabled
	 ,cast(0
as bit)																																																								IsReinstatementEnabled	-- TODO: Tim Sep 2017 Not yet implemented
	 ,pr.RegisterRank
	from
		dbo.Registration						 rl
	join
		dbo.PracticeRegisterSection	 prs on rl.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
	join
		dbo.PracticeRegister				 pr on prs.PracticeRegisterSID				= pr.PracticeRegisterSID
	left outer join
	(
		select
			rr.RegistrantRenewalSID
		 ,rr.RegistrationSID
		 ,rr.RegistrationYear
		 ,rr.RowGUID
		 ,fv.FormSID
		 ,rrx.FormStatusSCD
		 ,rrx.FormStatusLabel
		 ,rr.UpdateTime
		 ,rrx.IsEditEnabled
		 ,rrx.IsUnPaid
		 ,rrx.TotalDue
		 ,rrx.IsRegisterChange
		from
			dbo.RegistrantRenewal																					rr
		join
			sf.FormVersion																								fv on rr.FormVersionSID = fv.FormVersionSID
		cross apply dbo.fRegistrantRenewal#Ext(rr.RegistrantRenewalSID) rrx
		where
			isnull(rrx.FormStatusSCD, 'NEW') <> 'WITHDRAWN'	-- user may withdraw initial renewal and create second one (ignore withdrawn renewals)
	)															 rr on rl.RegistrationSID							= rr.RegistrationSID
	left outer join
		dbo.RegistrationScheduleYear rsy on pr.RegistrationScheduleSID		= rsy.RegistrationScheduleSID
																				and rsy.RegistrationYear			= rl.RegistrationYear + 1
																				and (@now
																				between (case when @isCurrentUserVerifier = @ON then rsy.RenewalVerificationOpenTime else rsy.RenewalGeneralOpenTime end) and rsy.RenewalEndTime
																						)
	where
		rl.RegistrantSID = @RegistrantSID and sf.fIsActiveAt(rl.EffectiveTime, rl.ExpiryTime, @now) = @ON;

	return;
end;
GO
