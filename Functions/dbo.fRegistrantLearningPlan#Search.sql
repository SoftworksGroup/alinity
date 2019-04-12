SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fRegistrantLearningPlan#Search] 
(
   @RegistrantSID                  int                                     -- registrant to return learning plan information for
  ,@RegistrationYear               smallint                                -- registration year to return learning plan information for
) 
returns table
/*********************************************************************************************************************************
Function: Registrant Learning Plan - Search
Notice  : Copyright © 2017 Softworks Group Inc.
Summary	: Returns learning plan information used to support the search UI
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Cory Ng   	| Dec 2017			|	Initial Version 
				: Cory Ng			| Jan 2019			| Changed the join to registration to just get their latest registration even if its inactive
																				so that learning plans are returned for members that were moved to an inactive register
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function is intended for management of Registrant Learning Plans but is based on Registrant.  The change in base entity
is required in order to show not only registrants who have, or are in the process of completing their learning plan, but also 
those registrants who haven't started.  

The function cannot be run without the Registration Year (of licensing) as the base selection criteria.

The function is designed to allow learning plans from not only the current year to be selected, but also learning plans from 
previous years. It is possible to use the function, for example, to find out who did not complete their learning plan 5 years 
ago. 

Because of the design of the function which must report on learning plans which have not yet started the Form Status Label and 
Form Owner Label are overridden.

Maintenance Note
----------------
A search sproc - pRegistrantLearningPlan#SearchCT depends on the structure of this function so do not modify this structure without
checking the dependencies in the sproc first.

Example
-------
<TestHarness>
	<Test Name="NotStarted" Description="Learning plan should show up as not started">
		<SQLScript>
			<![CDATA[
			declare
				@registrantSID						int
			,	@currentRegistrationYear	smallint

			begin tran
			
			select
				@currentRegistrationYear = dbo.fRegistrationYear#Current()

			-- Get a registrant with a registration in the current year.
			select
			  @registrantSID = r.RegistrantSID
			from
				 dbo.Registrant								r
			 join
				 sf.Person										p on r.PersonSID = p.PersonSID
			 join
				dbo.Registration					rl on r.RegistrantSID = rl.RegistrantSID and rl.RegistrationYear = @currentRegistrationYear
			join
				dbo.PracticeRegisterSection		prs on rl.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
			join
				dbo.PracticeRegister					pr on prs.PracticeRegisterSID = pr.PracticeRegisterSID
			order by
			  newid()
	
			-- Delete existing data, so it doesn't interfere with test 
			delete from 
				dbo.RegistrantLearningPlanStatus 
			where 
				RegistrantLearningPlanSID in 
					(	select 
							RegistrantLearningPlanSID 
						from 
							dbo.RegistrantLearningPlan 
						where 
							RegistrantSID = @registrantSID 
						and 
							RegistrationYear = @currentRegistrationYear
						)
	
			delete from 
				dbo.RegistrantLearningPlan 		
			where 
				RegistrantSID = @registrantSID 
			and 
				RegistrationYear = @currentRegistrationYear
	
	
			select
					FormStatusLabel
				,	RegistrantLearningPlanSID
			from
				dbo.fRegistrantLearningPlan#Search(@registrantSID, @currentRegistrationYear)
	
			if @@ROWCOUNT = 0 raiserror( N'* ERROR: no sample data found to run test', 18, 1) 
			if @@TRANCOUNT > 0 rollback

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>
			<Assertion Type="ScalarValue" RowSet="1" ResultSet="1" Column="1" Row="1" Value="Not Started"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
	<Test Name="Started"   Description="Learning plan should show up as started">
		<SQLScript>
			<![CDATA[

			declare
					@registrantSID							int
				,	@currentRegistrationYear		smallint
				, @FormVersionSID							int
				,	@RegistrantLearningPlanSID	int
				, @FormStatusSID							int
			
			begin tran
			
			select
				@currentRegistrationYear = dbo.fRegistrationYear#Current()
			
			-- Get a registrant with a registration in the current year.
			select
			  @registrantSID = r.RegistrantSID
			from
				 dbo.Registrant								r
			 join
				 sf.Person										p on r.PersonSID = p.PersonSID
			 join
				dbo.Registration					rl on r.RegistrantSID = rl.RegistrantSID and rl.RegistrationYear = @currentRegistrationYear
			join
				dbo.PracticeRegisterSection		prs on rl.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
			join
				dbo.PracticeRegister					pr on prs.PracticeRegisterSID = pr.PracticeRegisterSID
			order by
			  newid()
			
			-- Any form works
			select top 1
				@FormVersionSID = fv.FormVersionSID
			from
				sf.FormVersion fv
			order by
				newid()
			
			-- We need the "new" form status
			select top 1
				@FormStatusSID = fs.FormStatusSID
			from
				sf.FormStatus fs
			where
				fs.FormStatusLabel = 'new'
			
			-- Delete existing data, so it doesn't interfere with test 
			delete from 
				dbo.RegistrantLearningPlanStatus 
			where 
				RegistrantLearningPlanSID in 
					(	select 
							RegistrantLearningPlanSID 
						from 
							dbo.RegistrantLearningPlan 
						where 
							RegistrantSID = @registrantSID 
						and 
							RegistrationYear = @currentRegistrationYear
						)
			
			delete from 
				dbo.RegistrantLearningPlan 		
			where 
				RegistrantSID = @registrantSID 
			and 
				RegistrationYear = @currentRegistrationYear
			
			-- Create a new unstarted learning plan.
			insert into dbo.RegistrantLearningPlan
			(
					RegistrantSID
				,	RegistrationYear
				,	FormVersionSID
				,	FormResponseDraft
				,	AdminComments
			)
			select
					@RegistrantSID
				,	@CurrentRegistrationYear
				,	@FormVersionSID
				,'<FormResponse/>'
				,'<AdminComments/>'
			
			set @RegistrantLearningPlanSID = scope_identity()
			
			insert into dbo.RegistrantLearningPlanStatus
			(
					RegistrantLearningPlanSID
				,	FormStatusSID
			)
			select
				@RegistrantLearningPlanSID
				, @FormStatusSID
			
			select
					FormStatusLabel
				,	RegistrantLearningPlanSID
			from
				dbo.fRegistrantLearningPlan#Search(@registrantSID, @currentRegistrationYear)
			
			if @@ROWCOUNT = 0 raiserror( N'* ERROR: no sample data found to run test', 18, 1) 
			if @@TRANCOUNT > 0 rollback

			]]>
		</SQLScript>
		<Assertions>
				<Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>
				<Assertion Type="ScalarValue" RowSet="1" ResultSet="1" Column="1" Row="1" Value="Started (not submitted)"/>
				<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>	
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.fRegistrantLearningPlan#Search'
	,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */
as
return ( select
					 r.RegistrantSID
					,r.RegistrantNo
					,rlp.RegistrantLearningPlanSID
					,dbo.fRegistrant#Label(p.LastName, p.FirstName, p.MiddleNames, r.RegistrantNo, 'LEARNINGPLAN')								RegistrantLabel
					,pr.PracticeRegisterLabel
					,rrcs.FormStatusSID																																																										-- the label has an override but not the code or SID (used for searching)
					,rrcs.FormStatusSCD
					,case
						 when rrcs.FormStatusSCD is null then 'Not Started'
						 when rrcs.FormStatusSCD = 'APPROVED' then 'Complete'
						 when rrcs.FormStatusSCD = 'NEW' then 'Started (not submitted)'
						 when rrcs.FormStatusSCD = 'UNLOCKED' then 'Reviewing (admin)'
						 else rrcs.FormStatusLabel
					 end																																																				 FormStatusLabel	
					,case
						 when rrcs.FormStatusSCD is null then 'REGISTRANT'																				 
						 when rrcs.FormStatusSCD = 'SUBMITTED' then 'REGISTRANT'
						 when rrcs.FormOwnerSCD = 'ASSIGNEE' then 'REGISTRANT'
						 else rrcs.FormOwnerSCD
					 end																																																				 FormOwnerSCD
					,rrcs.FormOwnerLabel
					,p.PersonSID
					,p.FirstName
					,p.MiddleNames
					,p.LastName
					,pea.EmailAddress
					,rl.RegistrationYear		
					,rlp.NextFollowUp
					,cast((case when rlp.NextFollowUp <= sf.fToday() then 1 else 0 end) as bit)																	 IsFollowUpDue
					,cast((case when rlp.RegistrantLearningPlanSID is null then 1 else 0 end) as bit)														 IsNotStarted
					,cast(isnull(pdc.PersonDocContextSID, 0) as bit)																														 IsPDFGenerated						-- controls where PDF icon display in UI
					,pdc.PersonDocSID
					,case
						 when rrcs.FormStatusSCD = 'APPROVED' and pdc.PersonDocContextSID is null then cast(1 as bit)
						 else cast(0 as bit)
					 end																																																				 IsPDFRequired						-- to support search filter on records requiring PDF generation
					,rrcs.CreateUser																																														 LastStatusChangeUser
					,rrcs.CreateTime																																														 LastStatusChangeTime
					,rlp.RegistrantLearningPlanXID
					,rlp.LegacyKey
				 from
					 dbo.Registrant																														r
				 join
					 sf.Person																																p on r.PersonSID = p.PersonSID
				 cross apply
					dbo.fRegistrant#Registration(r.RegistrantSID, cast(0 as bit), @RegistrationYear) lr
				 join
					dbo.Registration																											rl on lr.RegistrationSID = rl.RegistrationSID
				join
					dbo.PracticeRegisterSection																								prs on rl.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
				join
					dbo.PracticeRegister																											pr on prs.PracticeRegisterSID = pr.PracticeRegisterSID
         left outer join
				 (
					select
						 xrlp.RegistrantLearningPlanSID
						,xrlp.RegistrantSID
						,xrlp.NextFollowUp
						,xrlp.RegistrantLearningPlanXID
						,xrlp.LegacyKey
					from
           dbo.RegistrantLearningPlan																							  xrlp 
					join
						dbo.LearningModel xlm on xrlp.LearningModelSID = xlm.LearningModelSID
					where
						xrlp.RegistrantSID = @RegistrantSID
					and
						@RegistrationYear between xrlp.RegistrationYear and (xrlp.RegistrationYear + xlm.CycleLengthYears - 1)
				) rlp on r.RegistrantSID = rlp.RegistrantSID
				 left outer join
					 sf.PersonEmailAddress																										pea on p.PersonSID = pea.PersonSID and pea.IsActive = cast(1 as bit) and pea.IsPrimary = cast(1 as bit)
         cross apply
         (
          select
						ae.ApplicationEntitySID
					from
						sf.ApplicationEntity ae
					where
					 ae.ApplicationEntitySCD = 'dbo.RegistrantLearningPlan'
         ) ae
				 left outer join
					 dbo.PersonDocContext																											pdc on rlp.RegistrantLearningPlanSID = pdc.EntitySID -- keep this order to apply index
																																													 and pdc.IsPrimary = cast(1 as bit) and pdc.ApplicationEntitySID = ae.ApplicationEntitySID
				 outer apply dbo.fRegistrantLearningPlan#CurrentStatus(rlp.RegistrantLearningPlanSID) rrcs
				 where
					 r.RegistrantSID = @RegistrantSID);
GO
