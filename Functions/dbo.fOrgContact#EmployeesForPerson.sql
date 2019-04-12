SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- User Defined Function

CREATE FUNCTION [dbo].[fOrgContact#EmployeesForPerson]
(
	@PersonSID															int
)
returns @orgContact#EmployeesForPerson	table
(
	 OrgContactSID													int																		-- the identifier of the contact record
	,OrgSID																	int																		-- the identifier for the person
	,PersonSID															int																		-- the identifier for the org
	,RegistrantSID													int							null									-- the identifier, if any, for the registrant
	,PersonFirstName												nvarchar(30)													-- the first name of the person
	,PersonLastName													nvarchar(35)													-- the last name of the person
	,PersonCommonName												nvarchar(30)		null									-- the common name of the person
	,PersonDisplayName											nvarchar(65)													-- the formatted display name of the person
	,IsReviewAdmin													bit																		-- whether or not the person is a review administrator
	,EffectiveTime													datetime															-- the date the contact became effective
	,ExpiryTime															datetime				null									-- the date, if any, the contact will expire
	,RegistrationSID										int							null									-- system ID of the active registration
	,PracticeRegisterSectionLabel						nvarchar(35)		null									-- the label of the first section the person has an active registration on
	,OrgName																nvarchar(150)													-- the name of the org
	,OrgLabel																nvarchar(35)													-- the label of the org
)
as
/*********************************************************************************************************************************
TableF	: OrgContact - Employees for person
Notice  : Copyright © 2016 Softworks Group Inc.
Summary	: Returns a table of columns for OrgContact, Person, Org, etc for use on the "My Employees" screen
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Kris Dawson | Nov	2016			|	Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function is called by the MyEmployees view to get all the contact records for a single person that are considered to be
that person's employees.

Example
-------
<TestHarness>
	<Test Name="Simple" Description="A basic test of the functionality">
		<SQLScript>
			<![CDATA[
				declare
						@personSID			int
					,	@orgSID					int
					,	@genderSID			int
					, @testPersonSID	int
				
				begin tran
				
				-- Look up a random person to set as a review admin
				select
					@personSID = p.PersonSID
				from
					sf.Person p
				join
					dbo.Registrant r on r.PersonSID = p.PersonSID
				order by
					newid()
				
				
				-- Lookup a gender needed to create a test person
				select
					@genderSID = g.GenderSID
				from
					sf.Gender g
				order by
				 newid()
				
				 -- Create a new person. Note, we set the name to something we know to test for
				insert into sf.Person
				(
						GenderSID
					,	FirstName
					,	LastName
				)
				select
					@genderSID
					,'Test First Name'
					,'Test Last Name'
				
				set @testPersonSID = scope_identity()
				
				-- The function filters out Persons who are not registrants.
				insert into dbo.Registrant
				(
						PersonSID
					,	RegistrantNo
				)
				select
						@testPersonSID
					,	'***TEST***'
				
				-- Look for Softworks Group Inc. because we need that to test for.
				select
					@orgSID = o.orgSID
				from
					dbo.Org o
				where
					o.OrgName = 'Softworks Group Inc.'
				
				insert into dbo.OrgContact
				(
						OrgSID
					,	PersonSID
					,	EffectiveTime
					, IsReviewAdmin
				)
				select
						@orgSID
					,	@personSID
					,	sf.fNow()
					, cast( 1 as bit)
				
				insert into dbo.OrgContact
				(
						OrgSID
					,	PersonSID
					,	EffectiveTime
				)
				select
						@orgSID
					,	@testPersonSID
					,	sf.fNow()
				
					select 
							PersonFirstName
						,	PersonLastName
						, OrgName
						,	OrgLabel
					from 
						dbo.fOrgContact#EmployeesForPerson(@personSID)
				
				if @@ROWCOUNT = 0 raiserror('',16,1)
				if @@TRANCOUNT > 0 rollback
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1" />
			<Assertion Type="ExecutionTime" Value="00:00:80"/>
		</Assertions>
	</Test>	
</TestHarness>


exec sf.pUnitTest#Execute
  @ObjectName = 'dbo.fOrgContact#EmployeesForPerson'
 ,@DefaultTestOnly = 1


------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		 @ON                              bit = cast(1 as bit)								-- a constant to reduce repetitive cast syntax in bit comparisons
		,@OFF                             bit = cast(0 as bit)								-- a constant to reduce repetitive cast syntax in bit comparisons
		,@nowPlus1												datetimeoffset(7)										-- constant for is active checks
	
	declare
		@managedOrgContact	                  table		                        -- stores org contacts the person is considered a manager for
			(
				 OrgContactSID				int not null																-- record ID joined to main entity to return results
			)

	set @nowPlus1 = dateadd(day, 1, sf.fNow())
	
	-- get all contacts from the orgs the person is an active supervisor admin for
	
	insert
		@managedOrgContact
	select
		moc.OrgContactSID
	from																																		-- soc = supervisor contact, moc = managed contact
		dbo.OrgContact soc
	join
		dbo.OrgContact moc on soc.OrgSID = moc.OrgSID
	and
		moc.PersonSID <> @PersonSID
	and
		sf.fIsActive(moc.EffectiveTime, isnull(moc.ExpiryTime, @nowPlus1)) = @ON
	join
		dbo.Registrant r on moc.PersonSID = r.PersonSID
	where 
		soc.PersonSID = @PersonSID
	and
		soc.IsReviewAdmin = @ON
	and
		sf.fIsActive(soc.EffectiveTime, isnull(soc.ExpiryTime, @nowPlus1)) = @ON

	-- get all contacts where the person is identified as a contact on a registrant app and is an active, plain, supervisor for that org

	insert
		@managedOrgContact
	select
		moc.OrgContactSID
	from																																		-- soc = supervisor contact, moc = managed contact
		dbo.OrgContact soc
	join
		dbo.RegistrantApp				ra	on soc.OrgSID = ra.OrgSID
	join
		dbo.RegistrantAppReview rar on ra.RegistrantAppSID = rar.RegistrantAppSID
	join
		dbo.OrgContact moc on rar.PersonSID = moc.PersonSID
	and
		soc.OrgSID = moc.OrgSID
	and
		moc.PersonSID <> @PersonSID
	and
		sf.fIsActive(moc.EffectiveTime, isnull(moc.ExpiryTime, @nowPlus1)) = @ON
	where 
		soc.PersonSID = @PersonSID
	and
		soc.IsReviewAdmin = @ON
	and
		soc.IsReviewAdmin = @OFF																							-- avoid duplicating records if supervisor and admin are both on for a contact
	and
		sf.fIsActive(soc.EffectiveTime, isnull(soc.ExpiryTime, @nowPlus1)) = @ON

	-- add the active employees to the return table

	insert 
		@orgContact#EmployeesForPerson
	(
		 OrgContactSID									
		,OrgSID												
		,PersonSID										
		,RegistrantSID								
		,PersonFirstName							
		,PersonLastName								
		,PersonCommonName							
		,PersonDisplayName			
		,IsReviewAdmin			
		,EffectiveTime								
		,ExpiryTime				
		,RegistrationSID						
		,PracticeRegisterSectionLabel	
		,OrgName											
		,OrgLabel																
	)
	select
		 oc.OrgContactSID
		,oc.OrgSID
		,oc.PersonSID
		,r.RegistrantSID
		,p.FirstName
		,p.LastName
		,p.CommonName
		,sf.fFormatDisplayName(p.LastName, isnull(p.CommonName, p.FirstName))
		,oc.IsReviewAdmin
		,oc.EffectiveTime
		,oc.ExpiryTime
		,x.RegistrationSID
		,x.PracticeRegisterSectionLabel
		,o.OrgName
		,o.OrgLabel
	from
		dbo.OrgContact oc
	join
		@managedOrgContact moc on oc.OrgContactSID = moc.OrgContactSID
	join
		sf.Person p on oc.PersonSID = p.PersonSID
	join
		dbo.Org o on oc.OrgSID = o.OrgSID
	join
		dbo.Registrant r on oc.PersonSID = r.PersonSID
	outer apply
		(
			select top 1
				 rl.RegistrationSID
				,prs.PracticeRegisterSectionLabel
			from
				dbo.Registration rl
			join
				dbo.PracticeRegisterSection prs on rl.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
			where
				rl.RegistrantSID = r.RegistrantSID
			and
				sf.fIsActive(rl.EffectiveTime, rl.ExpiryTime) = @ON
		) x

	return

end
GO
