SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pSetup$SF#Query]
	 @SetupUser											nvarchar(75)											      -- user assigned to audit columns
	,@Language                      char(2)                                 -- language to install for
	,@Region                        varchar(10)         										-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup sf.Query data
Notice   : Copyright © 2012 Softworks Group Inc.
Summary  : updates sf.Query master table with starting values for the application
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Tim Edlund		| Nov	2012			| Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------
This procedure adds queries provided as defaults by the product, but which are missing from the sf.Query table. Unlike many 
pSetup routines, a MERGE is not used to synchronize the target table with the version defined in the procedure. Synchronization
is avoided because sf.Query is a configurable maintainable table and synchronization could cause records to be deleted on upgrades.

This procedure adds some standard queries which exist for all tables that have associated search procedures.  The remaining queries
are part of the product but must be added specifically for each entity.  These appear below the generic queries with a section
for each entity. 

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully.">
		<SQLScript>
		<![CDATA[
		
			exec dbo.pSetup$SF#Query
				 @SetupUser = 'system@alinityapp.com'
				,@Language = 'EN'
				,@Region = 'CA'

			select * from sf.Query

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$SF#Query'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */
																																																																		
begin  

	set nocount on

	declare
		 @errorNo                           int = 0                           -- 0 no error, if < 50000 SQL error, else business rule
		,@errorText                         nvarchar(4000)                    -- message text (for business rule errors)
		,@sourceCount                       int                               -- count of rows in the source table
		,@targetCount                       int                               -- count of rows in the target table
		,@ON																bit = cast(1 as bit)							-- constant for boolean comparisons
		,@applicationPageSID								int																-- key of the page to link the quick search to
		,@defaultQueryCategorySID						int																-- default location for queries not otherwise placed into a category
		,@profileQueryCategorySID						int																-- default location for queries not otherwise placed into a category
		,@queryCategorySID									int																-- used to place queries into specific, non-default, categories

	begin try

		declare
			@setup						        table																			-- setup data for staging rows to be inserted
			(
			 ID												int								identity(1,1)
			,QueryCode								varchar(30)				not null
			,QueryCategorySID					int								not null
			,QueryLabel								nvarchar(35)			not null
			,ToolTip									nvarchar(250)			not null
			,QuerySQL									nvarchar(max)			not null
			,QueryParameters					xml								null
			,ApplicationPageSID				int								not null
			,IsActive									bit default 1			not null
			)
			
		select
			@defaultQueryCategorySID = qc.QueryCategorySID
		from
			sf.QueryCategory qc
		where
			qc.IsDefault = @ON

		select
			@profileQueryCategorySID = QueryCategorySID
		from
			sf.QueryCategory
		where
			IsActive = @ON
		and
			QueryCategoryCode = 'S!PROFILE'

		if isnull(@defaultQueryCategorySID,0) = 0
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RequiredDataMissingForSetup'
				,@MessageText = @errorText output
				,@DefaultText = N'Data required for setup of "%1" records is missing: "%2".'
				,@Arg1        = 'Query (sf.Query)'
				,@Arg2        = 'Default Query Category (sf.QueryCategory)'
			
			raiserror(@errorText, 18, 1)
			
		end

		-- insert standard queries to find records recently updated (by anyone or the current user)
		-- these queries can be added generically for any table that has an associated #Search procedure 
		-- and a application page ending with "List" (naming convention dependency!)

		------------------------
		-- PAPSubscriptions
		------------------------
		
		insert
			@setup
		(
			QueryCategorySID
			,QueryLabel
			,QueryCode
			,ToolTip
			,QueryParameters
			,QuerySQL
			,ApplicationPageSID
		)
		select
			@defaultQueryCategorySID
			,N'Find by phone'
			,N'[NONE].PAP.FIND.BY.PHONE'
			,N'Returns people matching the phone number or portion of phone number entered (searches both Home Phone and Mobile Phone numbers).'
		,N'<Parameters>
					<Parameter ID="PhoneNumber" Label="Phone number" Type="TextBox" IsMandatory="true" />
				</Parameters>'
			,N' select
							pap.PAPSubscriptionSID
					from
					    sf.Person        p
					join
					    dbo.PAPSubscription pap on p.PersonSID = pap.PersonSID
					where
					    p.HomePhone like ''%'' + [@PhoneNumber] + ''%'' or p.MobilePhone like ''%'' + [@PhoneNumber] + ''%'''
			,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'PAPSubscription'

		----------------------------------------
		-- sf.ConfigParam
		----------------------------------------

		insert
			@setup
		(
		QueryCategorySID		
		,QueryLabel			
		,QueryCode
		,ToolTip	
		,QueryParameters					
		,QuerySQL						
		,ApplicationPageSID
		)
		select
			@defaultQueryCategorySID
			,N'Editable Configuration'
			,N'[NONE].EDITABLE.CONFIG'
			,N'Returns all configuration parameters that can be altered.'
			,null
			,N'	select
						cp.ConfigParamSID
					from
						sf.ConfigParam cp
					where
						cp.IsReadOnly = cast(0 as bit)'
			,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'ConfigParamList'			
		
		----------------------------------------
		-- Person group queries
		----------------------------------------
		
		insert
			@setup
		(
			 QueryCategorySID
			,QueryLabel
			,QueryCode
			,ToolTip
			,QueryParameters
			,QuerySQL
			,ApplicationPageSID
		)
		select
			 @defaultQueryCategorySID
			,N'Overdue for review'
			,N'[NONE].OVERDUE.REVIEW'
			,N'Returns groups that are overdue for review by an administrators.'
			,null
			,N'select
					pg.PersonGroupSID
				from
					sf.vPersonGroup pg
				where
					pg.IsNextReviewOverdue = cast(1 as bit)'
			,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'GroupList'

		insert
			@setup
		(
			 QueryCategorySID
			,QueryLabel
			,QueryCode
			,ToolTip
			,QueryParameters
			,QuerySQL
			,ApplicationPageSID
		)
		select
			 @defaultQueryCategorySID
			,N'Static groups with no members'
			,N'[NONE].SANS.MEMBERS'
			,N'Returns static groups (not smart) that have no members assigned.'
			,null
			,N'select distinct
					pg.PersonGroupSID
				from
					sf.PersonGroup pg
				left outer join
					sf.PersonGroupMember pgm on pg.PersonGroupSID = pgm.PersonGroupSID
				where
					pg.QuerySID is null
				and
					pgm.PersonGroupMemberSID is null'
			,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'GroupList'

		insert
			@setup
		(
			 QueryCategorySID
			,QueryLabel
			,QueryCode
			,ToolTip
			,QueryParameters
			,QuerySQL
			,ApplicationPageSID
		)
		select
			 @defaultQueryCategorySID
			,N'With expired members'
			,N'[NONE].EXPIRED.MEMBERS'
			,N'Returns static groups (not smart) with members who are expired and require replacement.'
			,null
			,N'select distinct
					pg.PersonGroupSID
				from
					sf.PersonGroup pg
				left outer join
					sf.PersonGroupMember pgm on pg.PersonGroupSID = pgm.PersonGroupSID
				where
					pg.QuerySID is null
				and
					pgm.PersonGroupMemberSID is null'
			,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'GroupList'

		------------------------
		-- Person List
		------------------------

		insert
			@setup
		(
			QueryCategorySID
			,QueryLabel
			,QueryCode
			,ToolTip
			,QueryParameters
			,QuerySQL
			,ApplicationPageSID
		)
		select
			(select QueryCategorySID from sf.QueryCategory where QueryCategoryCode = 'S!DATA.QUALITY')
			,N'Username and email mismatch'
			,N'[NONE].EMAIL.MISMATCH'
			,N'Gets people that have a mismatching username and primary email address'
			,null
			,N'select
					au.PersonSID
				from
					sf.ApplicationUser au
				join
					sf.PersonEmailAddress pea on au.PersonSID = pea.PersonSID and pea.IsPrimary = cast(1 as bit)
				where
					pea.EmailAddress <> au.UserName'
			,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'PersonList'

		insert
			@setup
		(
			QueryCategorySID
			,QueryLabel
			,QueryCode
			,ToolTip
			,QueryParameters
			,QuerySQL
			,ApplicationPageSID
		)
		select
			@defaultQueryCategorySID
			,N'By permission'
			,N'[NONE].BY.GRANT'
			,N'Returns users who hold an active instance of the selected grant'
			,cast(N'<Parameters>
							<Parameter ID="GrantSID" Label="Grant" Type="Select" IsMandatory="true">
								<SQL>select ApplicationGrantSID [Value], ApplicationGrantName [Label] from sf.ApplicationGrant order by [Label]</SQL>
							</Parameter>
						</Parameters>' as xml)
			,N'select
	au.PersonSID
from
	sf.ApplicationUserGrant aug
join
	sf.ApplicationUser au on au.ApplicationUserSID = aug.ApplicationUserSID
where
	aug.ApplicationGrantSID = [@GrantSID]
and
	sf.fIsActive(aug.EffectiveTime, aug.ExpiryTime) = 1'
			,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'PersonList'

		select top(1) @queryCategorySID = qc.QueryCategorySID from sf.QueryCategory qc where qc.QueryCategoryLabel like 'Application %' order by qc.QueryCategorySID

		insert
			@setup
		(
			QueryCategorySID
			,QueryLabel
			,QueryCode
			,ToolTip
			,QueryParameters
			,QuerySQL
			,ApplicationPageSID
		)
		select
			isnull(@queryCategorySID, @defaultQueryCategorySID)
			,N'Application reviewers'
			,N'[NONE].APP.REVIEWERS'
			,N'Return all application reviewers/supervisors. Note that these individuals may or may not have applications currently assigned to them.'
			,cast(N'<Parameters>
							<Parameter ID="IsActiveOnly" Label="Active only" Type="CheckBox" IsMandatory="false" DefaultValue="True"/>
						</Parameters>' as xml)
			,N' select
			au.PersonSID
		from
			sf.ApplicationUser au
		join
			sf.ApplicationUserGrant aug on au.ApplicationUserSID = aug.ApplicationUserSID
		join
			sf.ApplicationGrant ag on aug.ApplicationGrantSID = ag.ApplicationGrantSID
		where
			ag.ApplicationGrantSCD = ''EXTERNAL.APPLICATION''
		and
			((au.IsActive = isnull([@IsActiveOnly], 0) and sf.fIsActive(aug.EffectiveTime, aug.ExpiryTime) = isnull([@IsActiveOnly],0)) or isnull([@IsActiveOnly],0) = cast(0 as bit))'
			,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'PersonList'

		select top(1) @queryCategorySID = qc.QueryCategorySID from sf.QueryCategory qc where qc.QueryCategoryLabel like 'Audit %' order by qc.QueryCategorySID

		insert
			@setup
		(
			QueryCategorySID
			,QueryLabel
			,QueryCode
			,ToolTip
			,QueryParameters
			,QuerySQL
			,ApplicationPageSID
		)
		select
			isnull(@queryCategorySID, @defaultQueryCategorySID)
			,N'Audit reviewers'
			,N'[NONE].AUDIT.REVIEWERS'
			,N'Return all people who are assigned audit reviewer grant and then filter on active account or not based on check box'
			,cast(N'<Parameters>
							<Parameter ID="IsActiveOnly" Label="Active only" Type="CheckBox" IsMandatory="false" DefaultValue="True"/>
						</Parameters>' as xml)
			,N'select
			au.PersonSID
		from
			sf.ApplicationUser au
		join
			sf.ApplicationUserGrant aug on au.ApplicationUserSID = aug.ApplicationUserSID
		join
			sf.ApplicationGrant ag on aug.ApplicationGrantSID = ag.ApplicationGrantSID
		where
			ag.ApplicationGrantSCD = ''EXTERNAL.AUDIT''
		and
			((au.IsActive = isnull([@IsActiveOnly], 0) and sf.fIsActive(aug.EffectiveTime, aug.ExpiryTime) = isnull([@IsActiveOnly],0)) or isnull([@IsActiveOnly],0) = cast(0 as bit))'
			,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'PersonList'

		insert
			@setup
		(
			QueryCategorySID
			,QueryLabel
			,QueryCode
			,ToolTip
			,QueryParameters
			,QuerySQL
			,ApplicationPageSID
		)
		select
			(select QueryCategorySID from sf.QueryCategory where QueryCategoryCode = 'S!DATA.QUALITY')
			,N'Account review overdue'
			,N'[NONE].ACCOUNT.REVIEW.OVERDUE'
			,N'Returns active accounts overdue for review. See settings for overdue threshold. De-activating accounts not being used is recommended.'
			,null
			,N'select
    au.PersonSID
from
    sf.vApplicationUser au
where
    au.IsActive = cast(1 as bit)
and
    au.IsNextProfileReviewOverdue = cast(1 as bit)'
			,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'PersonList'

		insert
			@setup
		(
			QueryCategorySID
			,QueryLabel
			,QueryCode
			,ToolTip
			,QueryParameters
			,QuerySQL
			,ApplicationPageSID
		)
		select
			@defaultQueryCategorySID
			,N'All reviewers'
			,N'[NONE].ALL.REVIEWERS'
			,N'Returns all users who have a active application or audit reviewer grant.'
			,null
			,N'select
	au.PersonSID
from
	sf.ApplicationUser au
join
	sf.ApplicationUserGrant aug on aug.ApplicationUserSID = au.ApplicationUserSID
join
	sf.ApplicationGrant ag on ag.ApplicationGrantSID = aug.ApplicationGrantSID
where
	sf.fIsActive(aug.EffectiveTime, aug.ExpiryTime) = cast(1 as bit)
and
(
	ag.ApplicationGrantSCD = ''EXTERNAL.AUDIT''
or
	ag.ApplicationGrantSCD = ''EXTERNAL.APPLICATION''
)'
			,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'PersonList'

		insert
			@setup
		(
			QueryCategorySID
			,QueryLabel
			,QueryCode
			,ToolTip
			,QueryParameters
			,QuerySQL
			,ApplicationPageSID
		)
		select
			(select QueryCategorySID from sf.QueryCategory where QueryCategoryCode = 'S!DATA.QUALITY')
			,N'Potential duplicates'
			,N'[NONE].DUPE.MEMBERS'
			,N'Returns active accounts marked as possible duplicates by the system when created (based on name and phone numbers). Confirm accounts or merge.'
			,null
			,N'select
    au.PersonSID
from
    sf.vApplicationUser au
where
    au.IsActive = cast(1 as bit)
and
    au.IsPotentialDuplicate = cast(1 as bit)'
			,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'PersonList'

		insert
			@setup
		(
			QueryCategorySID
			,QueryLabel
			,QueryCode
			,ToolTip
			,QueryParameters
			,QuerySQL
			,ApplicationPageSID
		)
		select
			(select QueryCategorySID from sf.QueryCategory where QueryCategoryCode = 'S!DATA.QUALITY')
			,N'Password change required'
			,N'[NONE].REQ.PASS.CHANGE'
			,N'Gets people whose passwords have expired and need to be changed on their next login.'
			,null
			,N'select
  au.PersonSID
from
  sf.vApplicationUser au
where
  au.IsNextGlassBreakPasswordOverdue = cast(1 as bit)'
			,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'PersonList'

		insert
			@setup
		(
			QueryCategorySID
			,QueryLabel
			,QueryCode
			,ToolTip
			,QueryParameters
			,QuerySQL
			,ApplicationPageSID
		)
		select
			@defaultQueryCategorySID
			,N'Specialization (Current)'
			,N'[NONE].FIND.BY.SPECIAL'
			,N'Returns members currently on a selected Register with a given (active) specialization'
			,N'
<Parameters>
<Parameter ID="RegistrationYear" Label="Registration year" Type="Select" IsMandatory ="true" Cell="1" DefaultValue="[@@CurrentRegYear]">
	<SQL>
		select
		cast(rsy.RegistrationYear as int)  Value
		,rsy.RegistrationYearLabel         Label
		from
		dbo.vRegistrationScheduleYear rsy
		order by
		rsy.RegistrationYear desc
	</SQL>
</Parameter>
<Parameter ID="PracticeRegisterSID" Label="Register" Type="Select" IsMandatory ="true">
    <SQL>
      select
      pr.PracticeRegisterSID   Value
      ,pr.PracticeRegisterLabel Label
      from
      dbo.PracticeRegister pr
      where
      pr.IsActive = cast(1 as bit)
      order by
      pr.PracticeRegisterLabel
    </SQL>
  </Parameter>
<Parameter ID="SpecializationSID" Label="Specialization" Type="Select" IsMandatory ="true">
    <SQL>
      select
      crd.CredentialSID		Value
      ,crd.CredentialLabel	Label
      from
      dbo.Credential crd
      where
      crd.IsActive = 1
			and
			crd.IsSpecialization = 1
      order by
      crd.CredentialLabel
    </SQL>
  </Parameter>
	</Parameters>
'
,N'
select distinct
	lReg.PersonSID
from
	dbo.fRegistrant#LatestRegistration(-1, [@RegistrationYear]) lReg
join
	dbo.RegistrantCredential										 rc on lReg.RegistrantSID	 = rc.RegistrantSID
join
	dbo.Credential															 c on rc.CredentialSID		 = c.CredentialSID and c.IsSpecialization = 1
join
	dbo.CredentialType													 ct on c.CredentialTypeSID = ct.CredentialTypeSID
where
	lReg.PracticeRegisterSID = [@practiceRegisterSID] and rc.CredentialSID = [@specializationSID] and sf.fIsActive(rc.EffectiveTime, rc.ExpiryTime) = 1
option (recompile)'
			,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'PersonList'

		insert
			@setup
		(
			QueryCategorySID
			,QueryLabel
			,QueryCode
			,ToolTip
			,QueryParameters
			,QuerySQL
			,ApplicationPageSID
		)
		select
			(select QueryCategorySID from sf.QueryCategory where QueryCategoryCode = 'S!DATA.QUALITY')
			,N'Specialization (Missing)'
			,N'[NONE].MISSING.SPECIAL'
			,N'Returns members currently in active-practice who are missing a selected specialization'
			,N'
<Parameters><Parameter ID="SpecializationSID" Label="Specialization" Type="Select" IsMandatory ="true">
    <SQL>
      select
      crd.CredentialSID		Value
      ,crd.CredentialLabel	Label
      from
      dbo.Credential crd
      where
      crd.IsActive = 1
      order by
      crd.CredentialLabel
    </SQL>
  </Parameter>
<Parameter ID="PracticeRegisterSID" Label="Register" Type="Select" IsMandatory ="true">
    <SQL>
      select
      pr.PracticeRegisterSID   Value
      ,pr.PracticeRegisterLabel Label
      from
      dbo.PracticeRegister pr
      where
      pr.IsActive = cast(1 as bit)
      order by
      pr.PracticeRegisterLabel
    </SQL>
  </Parameter>
	</Parameters>
'
,N'
select distinct
	r.PersonSID
from
	dbo.fRegistrant#LatestRegistration(-1, null) lReg
join
	dbo.Registrant																						r on lReg.RegistrantSID																	= r.RegistrantSID

left outer join
	dbo.RegistrantCredential																	rc on r.RegistrantSID																		= rc.RegistrantSID
																																	and rc.CredentialSID															= [@SpecializationSID]
																																	and sf.fIsActive(rc.EffectiveTime, rc.ExpiryTime) = 1	 
where
rc.CredentialSID is null and lReg.PracticeRegisterSID = [@PracticeRegisterSID]
option (recompile)'
			,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'PersonList'

		insert
			@setup
		(
			QueryCategorySID
			,QueryLabel
			,QueryCode
			,ToolTip
			,QueryParameters
			,QuerySQL
			,ApplicationPageSID
		)
		select
			@defaultQueryCategorySID
			,N'Other registrations'
			,N'[NONE].FIND.BY.OTHERJUR'
			,N'Returns members currently registered in another profession'
			,N'
<Parameters>
  <Parameter ID="RegistrationYear" Label="Registration year" Type="Select" IsMandatory="true" Cell="1" DefaultValue="[@@CurrentRegYear]">
    <SQL>
		select
		cast(rsy.RegistrationYear as int)  Value
		,rsy.RegistrationYearLabel         Label
		from
		dbo.vRegistrationScheduleYear rsy
		order by
		rsy.RegistrationYear desc
	</SQL>
  </Parameter>
  <Parameter ID="PracticeRegisterSID" Label="Register" Type="Select" IsMandatory="true">
    <SQL>
      select
      pr.PracticeRegisterSID   Value
      ,pr.PracticeRegisterLabel Label
      from
      dbo.PracticeRegister pr
      where
      pr.IsActive = cast(1 as bit)
      order by
      pr.PracticeRegisterLabel
    </SQL>
  </Parameter>
  <Parameter ID="IdentifierCategorySID" Label="Registration category" Type="Select" IsMandatory="true">
    <SQL>
select 
	min(it.IdentifierTypeSID) Value
 ,it.IdentifierTypeCategory Label
from
	dbo.RegistrantIdentifier ri
join
	dbo.IdentifierType			 it on ri.IdentifierTypeSID = it.IdentifierTypeSID
where
	it.IdentifierTypeCategory is not null
and
	it.IsOtherRegistration = cast(1 as bit)
group by
	it.IdentifierTypeCategory
    </SQL>
  </Parameter>
  <Parameter ID="IdentifierTypeSID" Label="Registration type" Type="Select" IsMandatory="false">
    <SQL>
select distinct
	it.IdentifierTypeSID Value
 ,it.IdentifierTypeLabel Label
from
	dbo.RegistrantIdentifier ri
join
	dbo.IdentifierType			 it on ri.IdentifierTypeSID = it.IdentifierTypeSID
where
	it.IdentifierTypeCategory is not null
and
	it.IsOtherRegistration = cast(1 as bit)
order by
	it.IdentifierTypeLabel
    </SQL>
  </Parameter>
</Parameters>
'
,N'
  select distinct
	lReg.PersonSID
from
	dbo.fRegistrant#LatestRegistration(-1, [@RegistrationYear]) lReg
join
	dbo.RegistrantIdentifier																		ri on lReg.RegistrantSID	 = ri.RegistrantSID
join
	dbo.IdentifierType																					it on ri.IdentifierTypeSID = it.IdentifierTypeSID
join
	dbo.IdentifierType																					x on x.IdentifierTypeSID	 = [@identifierCategorySID] and it.IdentifierTypeCategory = x.IdentifierTypeCategory
where
	lReg.PracticeRegisterSID																										= [@practiceRegisterSID]
	and
	(
		[@identifierTypeSID] is null or ri.IdentifierTypeSID											= [@identifierTypeSID]
	)
	and
	(
		ri.EffectiveDate is null or sf.fIsActive(ri.EffectiveDate, ri.ExpiryDate) = 1
	)
option (recompile)'
			,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'PersonList'

		insert
			@setup
		(
			QueryCategorySID
			,QueryLabel
			,QueryCode
			,ToolTip
			,QueryParameters
			,QuerySQL
			,ApplicationPageSID
		)
		select
			@profileQueryCategorySID
			,N'Employment status'
			,N'[NONE].FIND.BY.EMPSTAT'
			,N'Returns members selected by status of employment (eg. full-time, part-time)'
			,N'
<Parameters>
<Parameter ID="RegistrationYear" Label="Registration year" Type="Select" IsMandatory ="true" Cell="1" DefaultValue="[@@CurrentRegYear]">
	<SQL>
		select
		cast(rsy.RegistrationYear as int)  Value
		,rsy.RegistrationYearLabel         Label
		from
		dbo.vRegistrationScheduleYear rsy
		order by
		rsy.RegistrationYear desc
	</SQL>
</Parameter>
<Parameter ID="PracticeRegisterSID" Label="Register" Type="Select" IsMandatory ="true">
    <SQL>
      select
      pr.PracticeRegisterSID   Value
      ,pr.PracticeRegisterLabel Label
      from
      dbo.PracticeRegister pr
      where
      pr.IsActive = cast(1 as bit)
      order by
      pr.PracticeRegisterLabel
    </SQL>
  </Parameter>
<Parameter ID="EmploymentStatusSID" Label="Employment status" Type="Select" IsMandatory ="true">
    <SQL>
select
	es.EmploymentStatusSID	Value
 ,es.EmploymentStatusName Label
from
	dbo.EmploymentStatus es
where
	es.IsActive = cast(1 as bit)
order by
	es.EmploymentStatusName;
    </SQL>
  </Parameter>
<Parameter ID="EmploymentTypeSID" Label="Employment type" Type="Select" IsMandatory ="false">
    <SQL>
select
	es.EmploymentTypeSID	Value
 ,es.EmploymentTypeName Label
from
	dbo.EmploymentType es
where
	es.IsActive = cast(1 as bit)
order by
	es.EmploymentTypeName;
    </SQL>
  </Parameter>
<Parameter ID="IsPrimaryEmployer" Label="Primary employer only" Type="Checkbox" IsMandatory ="false"/>
	</Parameters>
'
,N'
select
	lReg.PersonSID
from
	dbo.fRegistrant#LatestRegistration(-1, [@RegistrationYear]) lReg
join
	dbo.RegistrantPractice											 regP on lReg.RegistrantSID = regP.RegistrantSID and lReg.RegistrationYear = regP.RegistrationYear
join
	dbo.RegistrantEmployment re on lReg.RegistrantSID = re.RegistrantSID and lreg.RegistrationYear = re.RegistrationYear 
join
	dbo.EmploymentType et on re.EmploymentTypeSID = et.EmploymentTypeSID
where
	lReg.PracticeRegisterSID = [@practiceRegisterSID] and regP.EmploymentStatusSID = [@employmentStatusSID]
	and
	([@employmentTypeSID] is null or et.EmploymentTypeSID = [@employmentTypeSID])
	and
	([@isPrimaryEmployer] = cast(0 as bit) or dbo.fRegistrantEmployment#Rank(re.RegistrantEmploymentSID) = 1)
	option (recompile)'
				,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'PersonList'

		insert
			@setup
		(
			QueryCategorySID
			,QueryLabel
			,QueryCode
			,ToolTip
			,QueryParameters
			,QuerySQL
			,ApplicationPageSID
		)
		select
			@profileQueryCategorySID
			,N'Employer type'
			,N'[NONE].FIND.BY.EMPTYPE'
			,N'Returns members selected by type of employment organization'
			,N'
<Parameters>
<Parameter ID="RegistrationYear" Label="Registration year" Type="Select" IsMandatory ="true" Cell="1" DefaultValue="[@@CurrentRegYear]">
	<SQL>
		select
		cast(rsy.RegistrationYear as int)  Value
		,rsy.RegistrationYearLabel         Label
		from
		dbo.vRegistrationScheduleYear rsy
		order by
		rsy.RegistrationYear desc
	</SQL>
</Parameter>
<Parameter ID="PracticeRegisterSID" Label="Register" Type="Select" IsMandatory ="true">
    <SQL>
      select
      pr.PracticeRegisterSID   Value
      ,pr.PracticeRegisterLabel Label
      from
      dbo.PracticeRegister pr
      where
      pr.IsActive = cast(1 as bit)
      order by
      pr.PracticeRegisterLabel
    </SQL>
  </Parameter>
<Parameter ID="OrgTypeSID" Label="Employer type" Type="Select" IsMandatory ="true">
    <SQL>
select
	ot.OrgTypeSID	 Value
 ,ot.OrgTypeName Label
from
	dbo.OrgType ot
order by
	ot.OrgTypeName
    </SQL>
  </Parameter>
<Parameter ID="IsPrimaryEmployer" Label="Primary employer only" Type="Checkbox" IsMandatory ="false"/>
	</Parameters>
'
,N'
select distinct
	lReg.PersonSID
from
	dbo.fRegistrant#LatestRegistration(-1, [@registrationYear]) lReg
join
	dbo.RegistrantEmployment re on lreg.RegistrantSID = re.RegistrantSID and lreg.RegistrationYear = re.RegistrationYear
join
	dbo.Org o on	re.OrgSID = o.OrgSID
join
	dbo.OrgType ot on o.OrgTypeSID = ot.OrgTypeSID
where
	lReg.PracticeRegisterSID = [@practiceRegisterSID] and ot.OrgTypeSID = [@orgTypeSID]
	and
	([@isPrimaryEmployer] = cast(0 as bit) or dbo.fRegistrantEmployment#Rank(re.RegistrantEmploymentSID) = 1)
	option (recompile)'
				,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'PersonList'

		insert
			@setup
		(
			QueryCategorySID
			,QueryLabel
			,QueryCode
			,ToolTip
			,QueryParameters
			,QuerySQL
			,ApplicationPageSID
		)
		select
			@defaultQueryCategorySID
			,N'Area of responsibility'
			,N'[NONE].FIND.BY.EMPAREA'
			,N'Returns members selected by area of responsibility/practice area and register'
			,N'
<Parameters>
<Parameter ID="RegistrationYear" Label="Registration year" Type="Select" IsMandatory ="true" Cell="1" DefaultValue="[@@CurrentRegYear]">
	<SQL>
		select
		cast(rsy.RegistrationYear as int)  Value
		,rsy.RegistrationYearLabel         Label
		from
		dbo.vRegistrationScheduleYear rsy
		order by
		rsy.RegistrationYear desc
	</SQL>
</Parameter>
<Parameter ID="PracticeRegisterSID" Label="Register" Type="Select" IsMandatory ="false">
    <SQL>
      select
      pr.PracticeRegisterSID   Value
      ,pr.PracticeRegisterLabel Label
      from
      dbo.PracticeRegister pr
      where
      pr.IsActive = cast(1 as bit)
      order by
      pr.PracticeRegisterLabel
    </SQL>
  </Parameter>
<Parameter ID="PracticeAreaSID" Label="Practice area" Type="Select" IsMandatory ="true">
    <SQL>
select
	pa.PracticeAreaSID	Value
 ,pa.PracticeAreaName Label
from
	dbo.PracticeArea pa
where
	pa.IsActive = cast(1 as bit)
order by
	pa.PracticeAreaName;
    </SQL>
  </Parameter>
<Parameter ID="IsPrimaryEmployer" Label="Primary employer only" Type="Checkbox" IsMandatory ="false"/>
	</Parameters>
'
,N'
select distinct
	lReg.PersonSID
from
	dbo.fRegistrant#LatestRegistration(-1, [@registrationYear]) lReg
join
	dbo.RegistrantEmployment re on lreg.RegistrantSID = re.RegistrantSID and lreg.RegistrationYear = re.RegistrationYear
join
	dbo.RegistrantEmploymentPracticeArea repa on re.RegistrantEmploymentSID = repa.RegistrantEmploymentSID
where
	([@practiceRegisterSID] is null or lReg.PracticeRegisterSID = [@practiceRegisterSID])
	and 
	repa.PracticeAreaSID = [@practiceAreaSID]
	and
	([@isPrimaryEmployer] = cast(0 as bit) or dbo.fRegistrantEmployment#Rank(re.RegistrantEmploymentSID) = 1)
	option (recompile)'
				,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'PersonList'

		insert
			@setup
		(
			QueryCategorySID
			,QueryLabel
			,QueryCode
			,ToolTip
			,QueryParameters
			,QuerySQL
			,ApplicationPageSID
		)
		select
			@defaultQueryCategorySID
			,N'By register'
			,N'[NONE].FIND.BY.REGISTER'
			,N'Returns members currently on a selected register'
			,N'
<Parameters><Parameter ID="PracticeRegisterSID" Label="Register" Type="Select" IsMandatory ="true">
    <SQL>
      select
      pr.PracticeRegisterSID   Value
      ,pr.PracticeRegisterLabel Label
      from
      dbo.PracticeRegister pr
      where
      pr.IsActive = cast(1 as bit)
      order by
      pr.PracticeRegisterLabel
    </SQL>
  </Parameter>
	</Parameters>
'
,N'
			select
				r.PersonSID
			from
				dbo.Registrant r
			cross apply
				dbo.fRegistrant#RegistrationCurrent(r.RegistrantSID) lReg
			where
				lReg.PracticeRegisterSID = [@PracticeRegisterSID]'
			,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'PersonList'

		insert
			@setup
		(
			QueryCategorySID
			,QueryLabel
			,QueryCode
			,ToolTip
			,QueryParameters
			,QuerySQL
			,ApplicationPageSID
		)
		select
			@defaultQueryCategorySID
			,N'Currently Practicing'
			,N'[NONE].CURRENT.PRACTICING'
			,N'Returns all registrants in active practice.'
			,null
			,N'select
				ra.PersonSID
			from
				dbo.fRegistration#Active(sf.fNow()) ra
			where
				ra.IsActivePractice = cast(1 as bit)'
			,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'PersonList'

	insert
			@setup
		(
			QueryCategorySID
			,QueryLabel
			,QueryCode
			,ToolTip
			,QueryParameters
			,QuerySQL
			,ApplicationPageSID
		)
		select
			(select QueryCategorySID from sf.QueryCategory where QueryCategoryCode = 'S!DATA.QUALITY')
			,N'Missing/invalid birth dates'
			,N'[NONE].INVALID.BIRTHDATE'
			,N'Returns current and previously registered members where the birth date is missing or results in an age outside of the range of 18-100 years. Invalid birthdates impact accuracy of some reports.'
			,null
			,N'
				select 
					distinct p.PersonSID 
				from  
					sf.Person	p 
				join
					dbo.Registrant								r														on p.PersonSID							= r.PersonSID 
				join 
					dbo.Registration					rl													on r.RegistrantSID					= rl.RegistrantSID 
				where 
					p.BirthDate is null 
				or 
				(
					sf.fAgeInYears(p.BirthDate, sf.fToday()) not between 18 and 100
				)'
			,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'PersonList'

		insert
			@setup
		(
			QueryCategorySID
			,QueryLabel
			,QueryCode
			,ToolTip
			,QueryParameters
			,QuerySQL
			,ApplicationPageSID
		)
		select
			(select QueryCategorySID from sf.QueryCategory where QueryCategoryCode = 'S!DATA.QUALITY')
			,N'Missing home addresses'
			,N'[NONE].PER.MISSING.ADDRESS'
			,N'Returns people where no active home address exists.'
			,null
			,N'select 
				p.PersonSID
			from
				sf.Person							p
			join
				dbo.Registrant r on p.PersonSID = r.PersonSID
			outer apply
				dbo.fPersonMailingAddress#Current(p.PersonSID) pmac
			where
				pmac.PersonMailingAddressSID is null'
			,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'PersonList'

		insert
			@setup
		(
			QueryCategorySID
			,QueryLabel
			,QueryCode
			,ToolTip
			,QueryParameters
			,QuerySQL
			,ApplicationPageSID
		)
		select
			(select QueryCategorySID from sf.QueryCategory where QueryCategoryCode = 'S!DATA.QUALITY')
			,N'Missing phone number'
			,N'[NONE].MISSING.PHONE'
			,N'Returns people where neither a Home Phone nor a Mobile Phone number is stored on their record.'
			,null
			,N'select 
					p.PersonSID
				from
					sf.Person							p
				left join
					sf.ApplicationUser au on au.PersonSID = p.PersonSID 
				where
					p.HomePhone is null 
				and 
					p.MobilePhone is null
				and
					au.UserName <> ''admin@helpdesk''
				and
					au.UserName <> ''JobExec'' '
			,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'PersonList'

		insert
			@setup
		(
			QueryCategorySID
			,QueryLabel
			,QueryCode
			,ToolTip
			,QueryParameters
			,QuerySQL
			,ApplicationPageSID
		)
		select
			@profileQueryCategorySID
			,N'Find by phone'
			,N'[NONE].PER.FIND.BY.PHONE'
			,N'Returns people matching the phone number or portion of phone number entered (searches both Home Phone and Mobile Phone numbers).'
		,N'<Parameters>
					<Parameter ID="PhoneNumber" Label="Phone number" Type="TextBox" IsMandatory="true" />
				</Parameters>'
			,N'select 
					p.PersonSID
				from
					sf.Person							p
				where
					p.HomePhone like ''%''+ [@PhoneNumber] +''%''
				or 
					p.MobilePhone like ''%'' + [@PhoneNumber] +''%'''
			,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'PersonList'

		insert
			@setup
		(
			QueryCategorySID
			,QueryLabel
			,QueryCode
			,ToolTip
			,QueryParameters
			,QuerySQL
			,ApplicationPageSID
		)
		select
			(select QueryCategorySID from sf.QueryCategory where QueryCategoryCode = 'S!DATA.QUALITY')
			,N'Addresses requiring admin review'
			,N'[NONE].ADDRESS.REVIEW'
			,N'Returns people where the home address entered is marked as requiring administrative review.'
			,null
			,	N'select 
					p.PersonSID
				from
					sf.Person							p
				cross apply
					dbo.fPersonMailingAddress#Current(p.PersonSID) pmac
				where
					pmac.IsAdminReviewRequired = cast(1 as bit)'
			,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'PersonList'

		insert
			@setup
		(
			QueryCategorySID
			,QueryLabel
			,QueryCode
			,ToolTip
			,QueryParameters
			,QuerySQL
			,ApplicationPageSID
		)
		select
			@defaultQueryCategorySID
			,N'By Notes'
			,N'[NONE].FIND.BY.NOTES'
			,N'Returns a list of people who have at least one note matching the provided criteria.'
			,N'<Parameters><Parameter ID="text" Label="Title or body text" Type="TextBox" IsMandatory="false" /><Parameter ID="tag" Label="Tag" Type="TextBox" IsMandatory="false" /><Parameter ID="personNoteTypeSID" Label="Type" Type="Select" IsMandatory="false"><SQL>select PersonNoteTypeSID Value, isnull(PersonNoteTypeCategory + '' - '', '''') + PersonNoteTypeLabel Label from dbo.PersonNoteType order by PersonNoteTypeCategory, Label</SQL></Parameter><Parameter ID="createUser" Label="Created by (*user name)" Type="TextBox" IsMandatory="false" /><Parameter ID="beginTime" Label="Created after" Type="DatePicker" IsMandatory="false" /><Parameter ID="endTime" Label="Created before" Type="DatePicker" IsMandatory="false" /><Parameter ID="persontype" Label="For" Type="Select" IsMandatory="false"><Items><Item Label="Non-registrants only" Value="2" /><Item Label="Registrants only" Value="3" /></Items></Parameter></Parameters>'
			,N'declare
				 @searchText nvarchar(1000) = case when len(isnull([@text], '''')) = 0 then ''%'' else ''%'' + [@text] + ''%'' end
				,@tagText nvarchar(1000) = lower(isnull([@tag],''''))
				,@createTimeStart datetime = case when len(isnull([@beginTime], '''')) = 0 then cast(0 as datetime) else cast(cast(cast([@beginTime] as date) as varchar(10)) + '' 00:00:00'' as datetime) end
				,@createTimeEnd datetime = case when len(isnull([@endTime], '''')) = 0 then cast(2000000 as datetime) else cast(cast(cast([@endTime] as date) as varchar(10)) + '' 23:59:59'' as datetime) end
				,@noteTypeSID int = case when len(isnull([@personNoteTypeSID], '''')) = 0 then null else cast([@personNoteTypeSID] as int) end
				,@forUser nvarchar(77) = case when len(isnull([@createUser], '''')) = 0 then ''%'' else ''%'' + [@createUser] + ''%'' end
				,@forType int = case when len(isnull([@persontype], '''')) = 0 then 1 else cast([@persontype] as int) end
			select distinct top(@maxRows)
				p.PersonSID
			from 
				sf.Person p
			join
				dbo.PersonNote pn on p.PersonSID = pn.PersonSID
			left outer join
				dbo.Registrant r on p.PersonSID = r.PersonSID
			where 
			(
				pn.NoteContent like @searchText
			or
				pn.NoteTitle like @searchText
			)
			and
				pn.PersonNoteTypeSID = isnull(@noteTypeSID, pn.PersonNoteTypeSID)
			and
				pn.CreateUser like @forUser
			and
				pn.CreateTime > @createTimeStart
			and
				pn.CreateTime < @createTimeEnd
			and
			(
				@forType = 1
			or
				(@forType = 2 and r.RegistrantSID is null)
			or
				(@forType = 3 and r.RegistrantSID is not null)
			)
			and
			(
				@tagText = ''''
				or
				TagList.exist(''/TagList/Tag/@Name[contains(lower-case(.), sql:variable("@tagText"))]'') = 1
			)'
			,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'PersonList'

		insert
			@setup
		(
			QueryCategorySID
			,QueryLabel
			,QueryCode
			,ToolTip
			,QueryParameters
			,QuerySQL
			,ApplicationPageSID
		)
		select
			@defaultQueryCategorySID
			,N'Mailing preference'
			,N'[NONE].FIND.BY.MAILPREF'
			,N'Returns people who have an active mailing preference for the selected mailing list.'
			,N'<Parameters>
					<Parameter ID="mailingPreferenceSID" Label="Mailing preference" Type="Select" IsMandatory="true">
						<SQL>select MailingPreferenceSID [Value], MailingPreferenceLabel [Label] from sf.MailingPreference order by MailingPreferenceLabel asc</SQL>
					</Parameter>
				</Parameters>'
			,N'select
						p.PersonSID [PersonSID]
					from
						sf.Person p
					join
						sf.PersonMailingPreference pmp	on  p.PersonSID = pmp.PersonSID
					join
						sf.MailingPreference mp	on  pmp.MailingPreferenceSID = mp.MailingPreferenceSID
					where
						mp.MailingPreferenceSID = [@mailingPreferenceSID]
					and
					(
						pmp.EffectiveTime <= sf.fNow()
						and
						(
							pmp.ExpiryTime is null
							or
							pmp.ExpiryTime > sf.fNow()
						)
					)'
			,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'PersonList'
			
		insert
			@setup
		(
			QueryCategorySID
			,QueryLabel
			,QueryCode
			,ToolTip
			,QueryParameters
			,QuerySQL
			,ApplicationPageSID
		)
		select
			@defaultQueryCategorySID
			,N'By employment role'
			,N'[NONE].FIND.BY.EMPROLE'
			,N'Returns people who have active employment with this role'
			,N'<Parameters>
					<Parameter ID="EmploymentRoleSID" Label="Role" Type="Select" IsMandatory="true">
						<SQL>select er.EmploymentRoleSID [Value], er.EmploymentRoleName [Label] from dbo.EmploymentRole er order by er.EmploymentRoleName</SQL>
					</Parameter>
				</Parameters>'
			,N'select distinct
  r.PersonSID
from
  dbo.RegistrantEmployment re
join
  dbo.Registrant r on re.RegistrantSID = r.RegistrantSID
where
  sf.fIsActive(re.EffectiveTime, re.ExpiryTime) = cast(1 as bit)
and
  re.EmploymentRoleSID = [@EmploymentRoleSID]'
			,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'PersonList'

		insert
			@setup
		(
			QueryCategorySID
			,QueryLabel
			,QueryCode
			,ToolTip
			,QueryParameters
			,QuerySQL
			,ApplicationPageSID
		)
		select
			@defaultQueryCategorySID
			,N'Specialization effective between'
			,N'[NONE].FIND.BY.SPECIAL.EFF'
			,N'Returns members who were granted a specialization between the specified dates'
			,N'<Parameters>
					<Parameter ID="CredentialSID" Label="Specialization" Type="Select" IsMandatory="true">
						<SQL>select c.CredentialSID [Value], c.CredentialLabel [Label] from dbo.Credential c where c.IsSpecialization = cast(1 as bit) and c.IsActive = cast(1 as bit) order by c.CredentialLabel</SQL>
					</Parameter>
					<Parameter ID="StartDate" Label="From" Type="DatePicker" Cell="2" DefaultValue="[@@Date]-7"/>
						<Parameter ID="EndDate" Label="To" Type="DatePicker" Cell="3" DefaultValue="[@@Date]"/>
				</Parameters>'
			,N'select
  r.PersonSID
from
  dbo.RegistrantCredential rc
join
  dbo.Credential c on rc.CredentialSID = c.CredentialSID
join
  dbo.Registrant r on rc.RegistrantSID = r.RegistrantSID
where
	c.IsSpecialization = cast(1 as bit)
and
  rc.EffectiveTime between isnull([@StartDate],rc.EffectiveTime) and isnull([@EndDate],rc.EffectiveTime)'
			,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'PersonList'

		insert
			@setup
		(
			QueryCategorySID
			,QueryLabel
			,QueryCode
			,ToolTip
			,QueryParameters
			,QuerySQL
			,ApplicationPageSID
		)
		select
			@defaultQueryCategorySID
			,N'Specialization expires between'
			,N'[NONE].FIND.BY.SPECIAL.EXP'
			,N'Returns members who has a specific specialization expire between the specified dates'
			,N'<Parameters>
					<Parameter ID="CredentialSID" Label="Specialization" Type="Select" IsMandatory="true">
						<SQL>select c.CredentialSID [Value], c.CredentialLabel [Label] from dbo.Credential c where c.IsSpecialization = cast(1 as bit) and c.IsActive = cast(1 as bit) order by c.CredentialLabel</SQL>
					</Parameter>
					<Parameter ID="StartDate" Label="From" Type="DatePicker" Cell="2" DefaultValue="[@@Date]-7"/>
						<Parameter ID="EndDate" Label="To" Type="DatePicker" Cell="3" DefaultValue="[@@Date]"/>
				</Parameters>'
			,N'select
  r.PersonSID
from
  dbo.RegistrantCredential rc
join
  dbo.Credential c on rc.CredentialSID = c.CredentialSID
join
  dbo.Registrant r on rc.RegistrantSID = r.RegistrantSID
where
  rc.ExpiryTime between isnull([@StartDate], rc.ExpiryTime) and isnull([@EndDate], rc.ExpiryTime)'
			,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'PersonList'

		insert
			@setup
		(
			QueryCategorySID
			,QueryLabel
			,QueryCode
			,ToolTip
			,QueryParameters
			,QuerySQL
			,ApplicationPageSID
		)
		select
			@defaultQueryCategorySID
			,N'Lack practice hours'
			,N'[NONE].LACK.HOURS'
			,N'Returns members who have lower then the required practice hours for the specified year (year ending)'
			,N'<Parameters>
					<Parameter ID="RegistrationYear" Label="Registration year" Type="Select" IsMandatory ="true" Cell="1" DefaultValue="[@@CurrentRegYear]">
						<SQL>
							select
							cast(rsy.RegistrationYear as int)  Value
							,rsy.RegistrationYearLabel         Label
							from
							dbo.vRegistrationScheduleYear rsy
							order by
							rsy.RegistrationYear desc
						</SQL>
					</Parameter>
				</Parameters>'
			,N'select
  r.PersonSID
from
  dbo.Registrant r
cross apply
    dbo.fRegistrant#RegistrationCurrent(r.RegistrantSID) rrc
cross apply
  dbo.fRegistrant#PracticeHoursByYear(r.RegistrantSID, null, [@RegistrationYear]) rph
where
  rrc.IsActivePractice = cast(1 as bit)
group by  
  r.PersonSID
having
  sum(rph.TotalHours) < cast(sf.fConfigParam#Value(''PracticeHourRequirement'') as int)'
			,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'PersonList'

		insert
			@setup
		(
			QueryCategorySID
			,QueryLabel
			,QueryCode
			,ToolTip
			,QueryParameters
			,QuerySQL
			,ApplicationPageSID
		)
		select
			@profileQueryCategorySID
			,N'Find by birth date'
			,'[NONE].FIND.BY.BIRTHDATE'
			,N'Returns users by age and where their birth date falls between (inclusive) the two dates provided.'
			,cast('<Parameters>
								<Parameter ID="AgeInYears" Label="Age" Type="Numeric" IsMandatory="true" />
								<Parameter ID="StartDate" Label="Start date" Type="DatePicker" IsMandatory="false" />
								<Parameter ID="EndDate" Label="End date" Type="DatePicker" IsMandatory="false" />
						</Parameters>' as xml)
			,N'select
	p.PersonSID
from
	sf.Person p
join
	(select sf.fNow() CurrentTime) ct on 1 = 1
where
	sf.fAgeInYears(p.BirthDate, ct.CurrentTime) = [@AgeInYears]
and
	([@StartDate] is null or p.BirthDate >= [@StartDate])
and
	([@EndDate] is null or p.BirthDate <= [@EndDate])'
			,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'PersonList'

		insert
			@setup
		(
			QueryCategorySID
			,QueryLabel
			,QueryCode
			,ToolTip
			,QueryParameters
			,QuerySQL
			,ApplicationPageSID
		)
		select
			@profileQueryCategorySID
			,N'Find by gender'
			,'[NONE].FIND.BY.GENDER'
			,N'Returns users with a matching gender.'
			,cast('<Parameters>
								<Parameter ID="GenderSID" Label="Gender" Type="Select" IsMandatory="true">
									<SQL>select GenderSID [Value], GenderLabel [Label] from sf.Gender where IsActive = 1 order by [Label]</SQL>
								</Parameter>
						</Parameters>' as xml)
			,N'select
				p.PersonSID
			from
				sf.Person p
			where
				p.GenderSID = [@GenderSID]'
			,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'PersonList'

		insert
			@setup
		(
			QueryCategorySID
			,QueryLabel
			,QueryCode
			,ToolTip
			,QueryParameters
			,QuerySQL
			,ApplicationPageSID
		)
		select
			@profileQueryCategorySID
			,N'Find by language'
			,'[NONE].FIND.BY.LANGUAGE'
			,N'Returns users with a matching language.'
			,cast('<Parameters>
								<Parameter ID="LanguageSID" Label="Language" Type="Select" IsMandatory="true">
									<SQL>select LanguageSID [Value], LanguageLabel [Label] from dbo.[Language] where IsActive = 1 order by [Label]</SQL>
								</Parameter>
							<Parameter ID="IsSpoken" Label="Written" Type="Select" IsMandatory="false">
								<Items>
									<Item Value="1" Label="Yes"/>
									<Item Value="0" Label="No"/>
								</Items>
							</Parameter>
							<Parameter ID="IsWritten" Label="Spoken" Type="Select" IsMandatory="false">
								<Items>
									<Item Value="1" Label="Yes"/>
									<Item Value="0" Label="No"/>
								</Items>
							</Parameter>
						</Parameters>' as xml)
			,N'select
				r.PersonSID
			from
				dbo.Registrant r
			join
				RegistrantLanguage rl on r.RegistrantSID = rl.RegistrantSID
			where
				rl.LanguageSID = [@LanguageSID]
			and
				rl.IsSpoken = isnull([@IsSpoken], IsSpoken)
			and
				rl.IsWritten = isnull([@IsWritten], IsWritten)'
			,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'PersonList'

		insert
			@setup
		(
			QueryCategorySID
			,QueryLabel
			,QueryCode
			,ToolTip
			,QueryParameters
			,QuerySQL
			,ApplicationPageSID
		)
		select
			@profileQueryCategorySID
			,N'Find by condition'
			,'[NONE].FIND.BY.RESTRICTION'
			,N'Only returns restrictions that are currently effective.'
			,cast('<Parameters>
							<Parameter ID="PracticeRestrictionSID" Label="Condition" Type="Select" IsMandatory="true">
								<SQL>select PracticeRestrictionSID [Value], PracticeRestrictionLabel [Label] from dbo.PracticeRestriction where IsActive = 1 order by [Label]</SQL>
							</Parameter>
							<Parameter ID="PracticeRegisterSID" Label="Register" Type="Select" IsMandatory="false">
								<SQL>select PracticeRegisterSID [Value], PracticeRegisterLabel [Label] from dbo.PracticeRegister where IsActive = 1 order by [Label]</SQL>
							</Parameter>
						</Parameters>' as xml)
			,N'select
				reg.PersonSID
			from
				dbo.fRegistrant#ActiveRegistrationCurrent(null) reg
			join
				dbo.vRegistrantPracticeRestriction rpr on rpr.RegistrantSID = reg.RegistrantSID
			where
				rpr.IsActive = 1
			and
				rpr.PracticeRestrictionSID = [@PracticeRestrictionSID]
			and
				([@practiceRegisterSID] is null or reg.PracticeRegisterSID = [@practiceRegisterSID])'
			,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'PersonList'

		insert
			@setup
		(
			QueryCategorySID
			,QueryLabel
			,QueryCode
			,ToolTip
			,QueryParameters
			,QuerySQL
			,ApplicationPageSID
		)
		select
			@profileQueryCategorySID
			,N'Find by credential'
			,'[NONE].FIND.BY.CREDENTIAL'
			,N'Returns users that graduated from the given org between the dates provided (inclusive).'
			,cast('<Parameters>
							<Parameter ID="CredentialSID" Label="Education" Type="Select" IsMandatory="false">
								<SQL>select CredentialSID [Value], CredentialLabel [Label] from dbo.[Credential] where IsActive = 1 and IsSpecialization = 0 order by [Label]</SQL>
							</Parameter>
							<Parameter ID="OrgSID" Label="Education Org" Type="AutoComplete" IsMandatory="false">
								<SQL>select OrgSID [Value], OrgLabel [Label] from dbo.Org where IsActive = 1 and IsCredentialAuthority =1 order by [Label]</SQL>
							</Parameter>
							<Parameter ID="StartDate" Label="Start date" Type="DatePicker" IsMandatory="false" />
							<Parameter ID="EndDate" Label="End date" Type="DatePicker" IsMandatory="false" />
						</Parameters>' as xml)
			,N'
			select distinct
				rg.PersonSID
			from
				dbo.Registrant rg
			join
				dbo.RegistrantCredential rc on rg.RegistrantSID = rc.RegistrantSID
			where
				rc.CredentialSID = [@credentialSID]
			and
				([@OrgSID] is null or rc.OrgSID = [@OrgSID])
			and
				([@startDate] is null or rc.EffectiveTime >= [@startDate])
			and
				([@endDate] is null or rc.EffectiveTime <= [@endDate])'
			,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'PersonList'

		insert
			@setup
		(
			QueryCategorySID
			,QueryLabel
			,QueryCode
			,ToolTip
			,QueryParameters
			,QuerySQL
			,ApplicationPageSID
		)
		select
			@profileQueryCategorySID
			,N'Find by employer'
			,'[NONE].FIND.BY.EMPLOYER'
			,N'Can optionally filter by whether the user is still employed at the organization. If no effective date is specified for an employment record, then it is still considered active if it is from the previous registration year.'
			,cast('<Parameters>
							<Parameter ID="OrgSID" Label="Employer Org" Type="AutoComplete" IsMandatory="true">
								<SQL>select OrgSID [Value], OrgLabel [Label] from dbo.Org where IsActive = 1 and IsEmployer = 1 order by [Label]</SQL>
							</Parameter>
							<Parameter ID="IsActive" Label="Is Active" Type="Select" IsMandatory="false">
								<Items>
									<Item Value="1" Label="Yes"/>
									<Item Value="0" Label="No"/>
								</Items>
							</Parameter>
						</Parameters>' as xml)
			,N'select
	rg.PersonSID
from
	dbo.RegistrantEmployment re
join
	dbo.Registrant rg on re.RegistrantSID = rg.RegistrantSID
join
	(select dbo.fRegistrationYear#Current() - 1 PreviousYear) st on 1= 1
where
	re.OrgSID = [@OrgSID]
and
(
	([@IsActive] is null)
or
	([@IsActive] = 1 and re.RegistrationYear >= st.PreviousYear and ((re.EffectiveTime is null and re.ExpiryTime is null) or sf.fIsActive(re.EffectiveTime, re.ExpiryTime) = 1))
or
	([@IsActive] = 0 and (re.RegistrationYear < st.PreviousYear or (re.RegistrationYear = st.PreviousYear and re.EffectiveTime is not null and sf.fIsActive(re.EffectiveTime, re.ExpiryTime) = 0)))
)
group by
		rg.PersonSID
	,	re.OrgSID'
			,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'PersonList'


		------------------------
		-- Learning Plan
		------------------------
		insert
			@setup
		(
			QueryCategorySID
			,QueryLabel
			,QueryCode
			,ToolTip
			,QueryParameters
			,QuerySQL
			,ApplicationPageSID
		)
		select
			@defaultQueryCategorySID
			,N'Find by phone'
			,N'[NONE].LP.FIND.BY.PHONE'
			,N'Returns people matching the phone number or portion of phone number entered (searches both Home Phone and Mobile Phone numbers).'
		,N'<Parameters>
					<Parameter ID="PhoneNumber" Label="Phone number" Type="TextBox" IsMandatory="true" />
				</Parameters>'
			,N' select
							rlp.RegistrantLearningPlanSID
					from
					    sf.Person p
					join 
							dbo.Registrant  r on p.PersonSID = r.PersonSID
					join
					    dbo.RegistrantLearningPlan rlp on r.RegistrantSID = rlp.RegistrantSID
					where
					    p.HomePhone like ''%'' + [@PhoneNumber] + ''%'' or p.MobilePhone like ''%'' + [@PhoneNumber] + ''%'''
			,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'RegistrantLearningPlanList'

		------------------------
		-- Org List
		------------------------

		insert
			@setup
		(
			QueryCategorySID
			,QueryLabel
			,QueryCode
			,ToolTip
			,QueryParameters
			,QuerySQL
			,ApplicationPageSID
		)
		select
			(select QueryCategorySID from sf.QueryCategory where QueryCategoryCode = 'S!DATA.QUALITY')
			,N'Missing Addresses'
			,N'[NONE].ORG.MISSING.ADDRESS'
			,N'Returns organizations that have an address of "NO ADDRESS".'
			,null
			,N'
				select
						o.OrgSID
				from 
					dbo.Org o
				where 
					o.StreetAddress1 = ''[NO ADDRESS]''
				or
					o.StreetAddress1 = ''NO ADDRESS'''
			,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'OrgList'

		insert
			@setup
		(
			QueryCategorySID
			,QueryLabel
			,QueryCode
			,ToolTip
			,QueryParameters
			,QuerySQL
			,ApplicationPageSID
		)
		select
			@defaultQueryCategorySID
			,N'Employers with employees'
			,N'[NONE].HAS.EMPLOYEES'
			,N'Returns all employers that have employees associated with them from either the current year or the previous one (to account for members who have not updated their profile since the previous renewal)'
			,null
			,N'select
		o.OrgSID
from 
	dbo.Org o
join
(
	select
		re.OrgSID
	from
		dbo.RegistrantEmployment re
	cross apply
		(select year(getdate()) - 1 CurrentYear) cy
	where
		re.RegistrationYear >= cy.CurrentYear
	group by
		re.OrgSID
) re on re.OrgSID = o.OrgSID
where
	o.IsEmployer = 1'
			,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'OrgList'
		
		------------------------
		-- Learning Plan List
		------------------------

		insert
			@setup
		(
			QueryCategorySID
			,QueryLabel
			,QueryCode
			,ToolTip
			,QueryParameters
			,QuerySQL
			,ApplicationPageSID
		)
		select
			@defaultQueryCategorySID
			,N'By un-approved type or activity'
			,N'[NONE].LEARN.UNAPPROVED'
	    ,N'Returns all continuing competence plans by un-approved type or activity.'
			,cast(N'
		<Parameters>
		<Parameter ID="RegistrationYear" Label="Registration year" Type="Select" DefaultValue="[@@CurrentRegYear]">
    <SQL>
      select
				 cast(rsy.RegistrationYear as int)  Value 
				,rsy.RegistrationYearLabel          Label
			from
				dbo.vRegistrationScheduleYear rsy
			order by
				rsy.RegistrationYear desc
    </SQL>
  </Parameter>
			<Parameter ID="CompetenceTypeSID" Label="Competence type" Type="Select" IsMandatory="False">
				<SQL>
					select
             ct.CompetenceTypeSID     Value
            ,ct.CompetenceTypeLabel   Label
          from
            dbo.CompetenceType ct
          where
            ct.IsActive = cast(1 as bit)
          order by
            ct.CompetenceTypeLabel
				</SQL>
			</Parameter>
			<Parameter ID="CompetenceActivitySID" Label="Activity" Type="Select" IsMandatory="False">
				<SQL>
					select 
             ca.CompetenceActivitySID   Value
            ,ca.CompetenceActivityName  Label
          from 
            dbo.CompetenceActivity ca
          where
            ca.IsActive = cast(1 as bit)
          order by
            ca.CompetenceActivityName
				</SQL>
			</Parameter>
		</Parameters>' as xml)
	, N'select distinct
   rlp.RegistrantSID
from
  dbo.LearningPlanActivity lpa
join
	dbo.vRegistrantLearningPlan rlp on lpa.RegistrantLearningPlanSID = rlp.RegistrantLearningPlanSID
join
  dbo.LearningClaimType lct on lpa.LearningClaimTypeSID = lct.LearningClaimTypeSID
join
  dbo.CompetenceTypeActivity cta on lpa.CompetenceTypeActivitySID = cta.CompetenceTypeActivitySID
where
	([@RegistrationYear] between rlp.RegistrationYear and rlp.CycleEndRegistrationYear)
and
  lct.IsComplete = cast(0 as bit)
and
  lct.IsWithdrawn = cast(0 as bit)
and
  cta.CompetenceTypeSID = isnull([@CompetenceTypeSID], cta.CompetenceTypeSID)
and
  cta.CompetenceActivitySID = isnull([@CompetenceActivitySID], cta.CompetenceActivitySID)'
			,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'RegistrantLearningPlanList'

		insert
			@setup
		(
			QueryCategorySID
			,QueryLabel
			,QueryCode
			,ToolTip
			,QueryParameters
			,QuerySQL
			,ApplicationPageSID
		)
		select
			@defaultQueryCategorySID
			,N'By cycle'
			,N'[NONE].LEARN.CYCLE'
	    ,N'Returns all continuing competence plans for a specific cycle.'
			,cast(N'
		<Parameters>
		<Parameter ID="RegistrationYear" Label="Cycle year" Type="Select" DefaultValue="[@@CurrentRegYear]">
    <SQL>
      select 
				 cast(rsy.RegistrationYear as int) Value
				,ltrim(year(rsy.YearStartTime)) + '' - '' + ltrim(rsy.RegistrationYear + lm.CycleLengthYears - 1) Label
			from 
				dbo.RegistrationScheduleYear rsy
			join
				dbo.LearningModel lm on lm.IsDefault = cast(1 as bit)
			order by
				rsy.RegistrationYear desc
    </SQL>	
  </Parameter>
			<Parameter ID="FormStatusSID" Label="Status" Type="Select" IsMandatory="False">
				<SQL>
					select
						 fs.FormStatusSID     Value
						,fs.FormStatusLabel   Label
					from
						sf.FormStatus fs
					order by
						fs.FormStatusSequence
				</SQL>
			</Parameter>
		</Parameters>' as xml)
	, N'select
  rlp.RegistrantSID
from
  dbo.RegistrantLearningPlan rlp
cross apply 
  dbo.fRegistrantLearningPlan#CurrentStatus(rlp.RegistrantLearningPlanSID) cs
where
  rlp.RegistrationYear = [@RegistrationYear]
and
  cs.FormStatusSID = isnull([@FormStatusSID], cs.FormStatusSID)'
			,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'RegistrantLearningPlanList'

		-- execute subroutines to load queries related to 
		-- each entity with a search page

		exec dbo.pSetup$SF#Query$EmailMessage
			@SetupUser = @SetupUser;

		exec dbo.pSetup$SF#Query$ProfileUpdate
			@SetupUser = @SetupUser;

		exec dbo.pSetup$SF#Query$Registration
			@SetupUser = @SetupUser;

		exec dbo.pSetup$SF#Query$Audit; -- OLD style

		exec dbo.pSetup$SF#Query$Payment
			@SetupUser = @SetupUser;

		exec dbo.pSetup$SF#Query$Invoice
			@SetupUser = @SetupUser;

		exec dbo.pSetup$SF#Query$Task
			@SetupUser = @SetupUser;

		exec dbo.pSetup$SF#Query$Complaint
			@SetupUser = @SetupUser;

		exec dbo.pSetup$SF#Query$RegistrantProfile
			@SetupUser = @SetupUser;

		exec dbo.pSetup$SF#Query$EmailTrigger; -- OLD style

		exec dbo.pSetup$SF#Query$Org -- OLD style
			@SetupUser = @SetupUser;

		merge sf.Query as target
		using
		(
			select
				s.QueryCategorySID
			 ,s.QueryLabel
			 ,s.QueryCode
			 ,s.ToolTip
			 ,s.QuerySQL
			 ,s.QueryParameters
			 ,s.ApplicationPageSID
			 ,s.IsActive
			 ,sysdatetime() CurrentTime
			from
				@setup s
		) as source
		(QueryCategorySID, QueryLabel, QueryCode, ToolTip, QuerySQL, QueryParameters, ApplicationPageSID, IsActive, CurrentTime)
		on (
				 target.ApplicationPageSID = source.ApplicationPageSID and target.QueryLabel = source.QueryLabel
			 )
		when matched and checksum(target.QuerySQL, target.ToolTip, target.QueryCategorySID, target.IsActive, cast(target.QueryParameters as nvarchar(max))) -- target checksum
		<> -- compared to
		checksum(source.QuerySQL, source.ToolTip, source.QueryCategorySID, target.IsActive, cast(source.QueryParameters as nvarchar(max))) -- source checksum
		then update set
					 target.QuerySQL = source.QuerySQL
					,target.QueryCode = source.QueryCode
					,target.ToolTip = source.ToolTip
					,target.QueryCategorySID = source.QueryCategorySID
					,target.IsActive = source.IsActive
					,target.QueryParameters = source.QueryParameters
					,target.UpdateUser = @SetupUser
					,target.UpdateTime = source.CurrentTime
		when not matched by target then
			insert
			(
				QueryCategorySID
			 ,QueryLabel
			 ,QueryCode
			 ,ToolTip
			 ,QuerySQL
			 ,QueryParameters
			 ,ApplicationPageSID
			 ,IsActive
			 ,CreateUser
			 ,UpdateUser
			)
			values
			(
				source.QueryCategorySID, source.QueryLabel, source.QueryCode, source.ToolTip, source.QuerySQL, source.QueryParameters, source.ApplicationPageSID
			 ,source.IsActive, @SetupUser, @SetupUser
			);

		-- check count of @setup table and the target table
		-- target should have at least as many rows as @setup

		select @sourceCount	 = count(1) from @setup ;
		select @targetCount	 = count(1) from sf .Query;

		if isnull(@targetCount, 0) < @sourceCount
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'SetupCountTooLow'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'Insert of some setup records failed. Source table count is %1 but target table (%2) count is only %3. Check "JOIN" conditions.'
			 ,@Arg1 = @sourceCount
			 ,@Arg2 = 'sf.Query'
			 ,@Arg3 = @targetCount;

			raiserror(@errorText, 18, 1);
		end;
			
	end try

	begin catch
		exec @errorNo = sf.pErrorRethrow
	end catch

	return(@errorNo)
end
GO
