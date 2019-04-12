SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fPracticeRegister#Ext]
(
	@PracticeRegisterSID int -- key of record to retrieve values for
)
returns @PracticeRegister#Ext table
(
	RegistrantAppFormVersionSID							 int			-- current published version of each supported form type:
 ,RegistrantAppVerificationFormVersionSID	 int
 ,RegistrantRenewalFormVersionSID					 int
 ,RegistrantRenewalReviewFormVersionSID		 int
 ,CompetenceReviewFormVersionSID					 int
 ,CompetenceReviewAssessmentFormVersionSID int
 ,CurrentRegistrationYear									 smallint -- registration year for the current (client timezone) time
 ,CurrentRenewalYear											 smallint -- registration year registrant can renew to - if renewal is open
 ,CurrentReinstatementYear								 smallint -- current registration year registrant can change registration for if open
 ,NextReinstatementYear										 smallint -- next registration year registrant can change registration for if open
 ,IsCurrentUserVerifier										 bit			-- indicates if current user has grant for verifying renewals and reinstatements
)
as
/*********************************************************************************************************************************
TableF		: Practice Register Extended Columns
Notice		: Copyright © 2017 Softworks Group Inc.
Summary		: Returns a table of calculated columns for the PracticeRegister extended view (vPracticeRegister#Ext)
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-------------------------------------------------------------------------------------------
					: Tim Edlund  | Mar 2017		|	Initial version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------

This function is called by the dbo.vPracticeRegister#Ext view to return a series of calculated values. By using a table 
function, many lookups required for the calculated values can be executed once rather than many times if separate functions are 
used.

This function expects to be selected for a single primary key value.  The function is not designed for inclusion in SELECTs 
scanning large portions of the table.  Performance in that context may not be acceptable and to resolve that, selected 
components of logic may need to be isolated into smaller functions that can be called separately.

The main logic in the function selects the latest published version of each type of form supported in the system for the given
Practice Register key.  The form types are stored in a system-code-table: sf.FormType.  When new form types are added, this 
function must be updated!

Example
-------

<TestHarness>
	<Test Name = "Simple" Description="Returns the extended columns for an instance of the entity at random.">
	<SQLScript>
	<![CDATA[

		select top 10
				prfx.*				
		from 
			dbo.PracticeRegister pr
		cross apply
			dbo.fPracticeRegister#Ext(pr.PracticeRegisterSID) prfx
		order by
			newid()

	]]>
	</SQLScript>
	<Assertions>
		<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
		<Assertion Type="ExecutionTime" Value="00:00:02" />
	</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.fPracticeRegister#Ext'
	
------------------------------------------------------------------------------------------------------------------------------- */
begin
	declare
		@ON																				bit			 = cast(1 as bit)														-- constant to eliminate repetitive casting syntax
	 ,@OFF																			bit			 = cast(0 as bit)														-- constant to eliminate repetitive casting syntax
	 ,@now																			datetime = sf.fNow()																-- current time in client timezone
	 ,@registrantAppFormVersionSID							int																									-- current published version of each supported form type:
	 ,@registrantAppVerificationFormVersionSID	int
	 ,@registrantRenewalFormVersionSID					int
	 ,@registrantRenewalReviewFormVersionSID		int
	 ,@competenceReviewFormVersionSID						int
	 ,@competenceReviewAssessmentFormVersionSID int
	 ,@currentRegistrationYear									smallint																						-- registration year for the current (client timezone) time
	 ,@currentRenewalYear												smallint																						-- registration year registrant can renew to - if renewal is open
	 ,@currentReinstatementYear									smallint																						-- current registration year registrant can change registration for if open
	 ,@nextReinstatementYear										smallint																						-- next registration year registrant can change registration for if open
	 ,@isCurrentUserVerifier										bit			 = sf.fIsGranted('EXTERNAL.VERIFICATION');	-- indicates if the current user is a renewal verifier

	select
		@registrantAppFormVersionSID							= max((case when ft.FormTypeSCD = 'APPLICATION.MAIN' then fv.FormVersionSID else 0 end))
	 ,@registrantAppVerificationFormVersionSID	= max((case when ft.FormTypeSCD = 'APPLICATION.REVIEW' then fv.FormVersionSID else 0 end))
	 ,@registrantRenewalFormVersionSID					= max((case when ft.FormTypeSCD = 'RENEWAL.MAIN' then fv.FormVersionSID else 0 end))
	 ,@registrantRenewalReviewFormVersionSID		= max((case when ft.FormTypeSCD = 'RENEWAL.REVIEW' then fv.FormVersionSID else 0 end))
	 ,@competenceReviewFormVersionSID						= max((case when ft.FormTypeSCD = 'AUDIT.MAIN' then fv.FormVersionSID else 0 end))
	 ,@competenceReviewAssessmentFormVersionSID = max((case when ft.FormTypeSCD = 'AUDIT.REVIEW' then fv.FormVersionSID else 0 end))
	from
		dbo.PracticeRegisterForm prf
	join
		sf.Form									 f on prf.FormSID		 = f.FormSID and f.IsActive = @ON -- NOTE: only active forms are included in selection!
	join
		sf.FormType							 ft on f.FormTypeSID = ft.FormTypeSID
	join
		sf.FormVersion					 fv on f.FormSID		 = fv.FormSID and fv.VersionNo > 0
	where
		prf.PracticeRegisterSID = @PracticeRegisterSID;

	-- retrieve the registration year that matches the current time
	-- along with the renewal year; a max of 1 record is expected 
	-- for each (use "top 1" to handle configuration errors)

	set @currentRegistrationYear = dbo.fRegistrationYear#Current();
	set @currentRenewalYear = cast(@currentRegistrationYear + 1 as smallint);

	-- if renewal is not currently open for the renewal year, we
	-- want to return it as a null value

	if not exists
	(
		select
			1
		from
			dbo.PracticeRegister				 pr
		join
			dbo.RegistrationScheduleYear rsyRnwl on pr.RegistrationScheduleSID	 = rsyRnwl.RegistrationScheduleSID
																							and rsyRnwl.RegistrationYear = @currentRenewalYear
																							and (@now
																							between (case when @isCurrentUserVerifier = @ON then rsyRnwl.RenewalVerificationOpenTime else
																																																																				 rsyRnwl.RenewalGeneralOpenTime end
																											) and rsyRnwl.RenewalEndTime)
		where
			pr.PracticeRegisterSID = @PracticeRegisterSID
		and
			pr.IsRenewalEnabled = @ON
	)
		set @currentRenewalYear = null;

	-- it is possible for 2 reinstatement years to be active at the same
	-- time so use a separate select based on min/max 

	select
		@currentReinstatementYear = min(rsy.RegistrationYear)
	 ,@nextReinstatementYear		= max(rsy.RegistrationYear)
	from
		dbo.PracticeRegister				 pr
	left outer join
		dbo.RegistrationScheduleYear rsy on pr.RegistrationScheduleSID = rsy.RegistrationScheduleSID
																				and @now between (case
																													when @isCurrentUserVerifier = @ON then rsy.ReinstatementVerificationOpenTime
																													else rsy.ReinstatementGeneralOpenTime
																													end
																												 ) and rsy.ReinstatementEndTime
	where
		pr.PracticeRegisterSID = @PracticeRegisterSID;

	insert
		@PracticeRegister#Ext
	(
		RegistrantAppFormVersionSID
	 ,RegistrantAppVerificationFormVersionSID
	 ,RegistrantRenewalFormVersionSID
	 ,RegistrantRenewalReviewFormVersionSID
	 ,CompetenceReviewFormVersionSID
	 ,CompetenceReviewAssessmentFormVersionSID
	 ,CurrentRegistrationYear
	 ,CurrentRenewalYear
	 ,CurrentReinstatementYear
	 ,NextReinstatementYear
	 ,IsCurrentUserVerifier
	)
	select
		@registrantAppFormVersionSID
	 ,@registrantAppVerificationFormVersionSID
	 ,@registrantRenewalFormVersionSID
	 ,@registrantRenewalReviewFormVersionSID
	 ,@competenceReviewFormVersionSID
	 ,@competenceReviewAssessmentFormVersionSID
	 ,@currentRegistrationYear
	 ,@currentRenewalYear
	 ,@currentReinstatementYear
	 ,@nextReinstatementYear
	 ,@isCurrentUserVerifier;

	return;
end;
GO
