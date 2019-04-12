SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pApplicationUser#Get]
	@ApplicationUserSID int -- key of record to get entity for
as
/*********************************************************************************************************************************
Sproc    : Application User Get
Notice   : Copyright © 2015 Softworks Group Inc.
Summary  : Returns single row of user context information including database, user display name, and application grants as xml
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year  | Change Summary
				 : ------------ + ----------- + ------------------------------------------------------------------------------------------
				 : Kris Dawson	|	Apr 2010		|	Initial Version
				 : Cory Ng			| Aug 2015		| Excluded IsDeleteEnabled from select list to improve performance
				 : Tim Edlund		| Nov 2015		| Excluded live checking of database status.
				 : Tim Edlund		| Jun 2017		| Added client acronym to "Test"/"Production" DB label.
				 : Tim Edlund		| Jan 2018		| Removed "Culture" column which is now replaced by sf.Culture.CultureSCD in main entity
----------------------------------------------------------------------------------------------------------------------------------

Comments
--------

This procedure is designed to be called by the front end at start-up.  The user is already authorized by the time of this call
through an aspx page so only the user information needs to be acquired. This method is also called by pApplicationUser#Authorize
to return the entity upon successful authorization of a user. Finally this procedure is also intended to be used by any middle
or front end application when updated user information is required.

The procedure returns 1 row of user profile/context information, a session GUID to identify the session on subsequent calls to
the database, and, an XML document of grants they have been assigned. Each grant is a system code stored in the sf.ApplicationGrant
table. The existence of the code in the dataset means that the right has been granted (a row in sf.ApplicationUserGrant).  Grants
not made do not appear in the XML. If the user has the SysAdmin grant, then they are treated by the application as if all grant
codes have been assigned to them.

The procedure returns the name of the database. This is done so that the UI can display the name and provide the user confirmation
that the are logged into the correct database - e.g. UAT, PROD, etc.. The client acronym is added to the database name - which is
separated from the db_name() function value.

Example:
--------

<TestHarness>
	<Test Name="AuthorizeRandomUser" IsDefault="true" Description="Selects an active user at random, who has at least 1 grant, and attempts
				to authorize them.">
		<SQLScript>
			<![CDATA[

declare
	@applicationUserSID	int

select top (1)
	 @applicationUserSID	= au.ApplicationUserSID
from
	sf.ApplicationUser au
order by
	newid()

exec sf.pApplicationUser#Get
	@ApplicationUserSID	= @applicationUserSID

]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:03" ResultSet="1"  />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.pApplicationUser#Get'

------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo	 int = 0				-- 0 no error, if < 50000 SQL error, else business rule
	 ,@errorText nvarchar(4000) -- message text (for business rule errors)
	 ,@blankParm varchar(100)		-- tracks blank values in required parameters

	begin try

		-- check parameters

		if @ApplicationUserSID is null
			set @blankParm = '@ApplicationUserSID';

		if @blankParm is not null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = @blankParm;

			raiserror(@errorText, 18, 1);

		end;

		-- return the profile and context information to the UI

		select
			--!<ColumnList DataSource="sf.vApplicationUser" Alias="au" Exclude="DatabaseDisplayName,DatabaseStatusColor,ApplicationGrantXML,IsDeleteEnabled">
			 au.ApplicationUserSID
			,au.PersonSID
			,au.CultureSID
			,au.AuthenticationAuthoritySID
			,au.UserName
			,au.LastReviewTime
			,au.LastReviewUser
			,au.IsPotentialDuplicate
			,au.IsTemplate
			,au.GlassBreakPassword
			,au.LastGlassBreakPasswordChangeTime
			,au.Comments
			,au.IsActive
			,au.AuthenticationSystemID
			,au.ChangeAudit
			,au.UserDefinedColumns
			,au.ApplicationUserXID
			,au.LegacyKey
			,au.IsDeleted
			,au.CreateUser
			,au.CreateTime
			,au.UpdateUser
			,au.UpdateTime
			,au.RowGUID
			,au.RowStamp
			,au.AuthenticationAuthoritySCD
			,au.AuthenticationAuthorityLabel
			,au.AuthenticationAuthorityIsActive
			,au.AuthenticationAuthorityIsDefault
			,au.AuthenticationAuthorityRowGUID
			,au.CultureSCD
			,au.CultureLabel
			,au.CultureIsDefault
			,au.CultureIsActive
			,au.CultureRowGUID
			,au.GenderSID
			,au.NamePrefixSID
			,au.FirstName
			,au.CommonName
			,au.MiddleNames
			,au.LastName
			,au.BirthDate
			,au.DeathDate
			,au.HomePhone
			,au.MobilePhone
			,au.IsTextMessagingEnabled
			,au.ImportBatch
			,au.PersonRowGUID
			,au.ChangeReason
			,au.IsReselected
			,au.IsNullApplied
			,au.zContext
			,au.ApplicationUserSessionSID
			,au.SessionGUID
			,au.FileAsName
			,au.FullName
			,au.DisplayName
			,au.PrimaryEmailAddress
			,au.PrimaryEmailAddressSID
			,au.PreferredPhone
			,au.LoginCount
			,au.NextProfileReviewDueDate
			,au.IsNextProfileReviewOverdue
			,au.NextGlassBreakPasswordChangeDueDate
			,au.IsNextGlassBreakPasswordOverdue
			,au.GlassBreakCountInLast24Hours
			,au.License
			,au.IsSysAdmin
			,au.LastDBAccessTime
			,au.DaysSinceLastDBAccess
			,au.IsAccessingNow
			,au.IsUnused
			,au.TemplateApplicationUserSID
			,au.LatestUpdateTime
			,au.LatestUpdateUser
			,au.DatabaseName
			,au.IsConfirmed
			,au.AutoSaveInterval
			,au.IsFederatedLogin
			,au.Password
			--!</ColumnList>
		 ,cast(0 as bit)												 IsDeleteEnabled
		 ,upper(
				replace(replace(replace(replace(replace(replace(au.DatabaseName, '_STG', ''), 'TestV6', ''), 'Test', ''), 'Alinity', ''), 'Synoptec', ''), 'V6', ''))
			+ ' ' + (case
								 when charindex('Test', au.DatabaseName) > 0 then 'Test'
								 when charindex('_STG', au.DatabaseName) > 0 then 'Test'
								 when au.DatabaseName like 'demo%' then '' -- demo and dev databases are not referred to as either test or production (blank)
								 when au.DatabaseName like 'dev%' then ''
								 else 'Production'
							 end)													 DatabaseDisplayName
		 ,(case
				 when charindex('Test', au.DatabaseName) > 0 then '#595751' -- SGI grey for test and dev
				 when charindex('_STG', au.DatabaseName) > 0 then '#595751'
				 when au.DatabaseName like 'dev%' then '#595751'
				 else '#5DABDB'																							-- light blue for production and demo
			 end)																	 DatabaseStatusColor
		 ,convert(xml
			 ,( select
						aug.ApplicationGrantSCD [Grant/@SCD]
					from
						sf.vApplicationUserGrant aug
					where
						aug.ApplicationUserSID = @ApplicationUserSID and aug.IsActive = cast(1 as bit) -- ensure grant is in effect now
					for xml path(''), root('Grants'))) ApplicationGrantXML
		from
			sf.vApplicationUser au
		where
			au.ApplicationUserSID = @ApplicationUserSID;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);

end;
GO
