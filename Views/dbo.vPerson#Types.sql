SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vPerson#Types]
as
/*********************************************************************************************************************************
View    : Person Types
Notice  : Copyright © 2012 Softworks Group Inc.
Summary	: Returns bits for the types of entities each sf.Person plays in the current database
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Cory Ng		  | May 2016      |	Initial Version
				: Cory Ng			|	May 2017			| Added applicant as a person type
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This is a utility view that identifies the entity types a sf.Person record plays in the system. Minimal identifying information
about the person is returned along with a bit column indicating the status of the Person for each of the possible roles in 
the system:

	IsApplicationUser 
	IsOrgContact
	IsRegistrant
	IsApplicant

	IsAdministrator - derived based on person being an Application User but not a Provider
	IsUnassigned    - derived based on the Person not having any of the previous types

The information on the view is used in wizard dialogs to determine whether an existing Person record already has a type
entity (e.g. Registrant) or a new one needs to be created.  The view is also useful in generation of sample data to select
person types.

NOTE: This view is dependent on the enforcement of a unique key on the PersonSID in the ApplicationUser, Registrant and
OrgContact tables.  The joins expect 0 or 1 row only!

The view is based on the sf.Person table but must be deployed as a DBO view since all the type tables are deployed in DBO
and the framework is independent of any objects in schemas other than SF.

Example
-------
<TestHarness>
	<Test Name="One" Description="returns 1 record at random from the view">
		<SQLScript>
			<![CDATA[

			declare 
				@PersonSID int
			
			select
				@PersonSID	= x.PersonSID
			from
				sf.Person x
			order by
				newid()
			
			select
				 *
			from
				dbo.vPerson#Types x
			where
				x.PersonSID = @PersonSID

			if @@ROWCOUNT = 0 raiserror( N'* ERROR: no sample data found to run test', 18, 1)

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1" />
			<Assertion Type="ExecutionTime" Value="00:00:02"/>
		</Assertions>
	</Test>
	<Test Name="All" IsDefault="True"  Description="returns all records from the view.">
		<SQLScript>
			<![CDATA[

			select
				 *
			from
				dbo.vPerson#Types

			if @@ROWCOUNT = 0 raiserror( N'* ERROR: no sample data found to run test', 18, 1)

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1" />
			<Assertion Type="ExecutionTime" Value="00:00:80"/>
		</Assertions>
	</Test>	
</TestHarness>

exec sf.pUnitTest#Execute
  @ObjectName = 'dbo.vPerson#Types'
 ,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */

select
	 p.PersonSID
	,p.FileAsName
	,p.DisplayName
	,p.FullName
	,au.ApplicationUserSID
	,r.RegistrantSID
	,x.OrgContactSID
	,cast(isnull(au.ApplicationUserSID      ,0) as bit)                     IsApplicationUser                    
	,cast(isnull(r.RegistrantSID						,0) as bit)                     IsRegistrant
	,cast(isnull(ra.RegistrantAppSID				,0) as bit)											IsApplicant
	,cast(isnull(x.OrgContactSID						,0) as bit)											IsOrgContact
	,cast
	(
		case
			when au.ApplicationUserSID is not null and r.RegistrantSID is null and x.OrgContactSID is null then 1
			else 0
		end
	as bit
	)                                                                       IsAdministrator
	,cast
	(
		case
			when au.ApplicationUserSID        is null 
				and	r.RegistrantSID							is null 
				and ra.RegistrantAppSID					is null
				and x.OrgContactSID							is null then 1
			else 0
		end
	as bit
	)                                                                       IsUnassigned
from
	sf.vPerson						p
left outer join
	sf.ApplicationUser    au on p.PersonSID = au.PersonSID
left outer join
	dbo.Registrant        r on p.PersonSID = r.PersonSID
left outer join
	dbo.vRegistrantApp		ra on r.RegistrantSID = ra.RegistrantAppSID and ra.IsInProgress = cast(1 as bit)
left outer join
(
	select
		oc.PersonSID
	 ,max(oc.OrgContactSID) OrgContactSID          -- latest SID
	from
		dbo.OrgContact oc
	group by
		oc.PersonSID
) x on p.PersonSID = x.PersonSID
GO
