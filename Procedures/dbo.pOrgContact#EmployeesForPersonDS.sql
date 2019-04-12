SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pOrgContact#EmployeesForPersonDS]
	 @PersonSID						int						= null															-- the SID of the person to look up employees for
	,@SearchString				nvarchar(150)	= null															-- name string to search, "last, first middle" or partial or OrgName
as
/*********************************************************************************************************************************
Procedure : "My Employees" for person
Notice    : Copyright © 2016 Softworks Group Inc.
Summary   : Runs the table valued function of the same name and returns the results
History   : Author(s)   | Month Year  | Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Kris Dawson	| Nov 2016    | Initial version

Comments
--------
See fOrgContact#EmployeesForPerson for documentation

Example:
--------

<TestHarness>
	<Test Name = "Basic execution" IsDefault ="true" Description="Runs the procedure for a random person">
		<SQLScript>
			<![CDATA[
			declare
				@personSID    int

			select top 1
				@personSID = oc.PersonSID
			from
				dbo.OrgContact oc
			order by
				newid()

			exec dbo.pOrgContact#EmployeesForPersonDS
				 @PersonSID			= @personSID
				,@SearchString	= ''
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="ExecutionTime" Value="00:00:03" ResultSet="1" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.pOrgContact#EmployeesForPersonDS'

-------------------------------------------------------------------------------------------------------------------------------- */

set nocount on

begin

	declare
		 @errorNo                         int = 0                             -- 0 no error, <50000 SQL error, else business rule
		,@lastName                        nvarchar(35)                        -- for name searches, buffer for each name part:
		,@firstName                       nvarchar(30)
		,@middleNames                     nvarchar(30)

	begin try

		exec sf.pSearchName#Split
				@SearchName   = @SearchString
			 ,@LastName     = @lastName       output
			 ,@FirstName    = @firstName      output
			 ,@MiddleNames  = @middleNames    output

		set @SearchString = '%' + ltrim(rtrim(@searchString))	+ '%'						-- format for Org search option

		select 
			 oc.OrgContactSID									
			,oc.OrgSID												
			,oc.PersonSID										
			,oc.RegistrantSID								
			,oc.PersonFirstName							
			,oc.PersonLastName								
			,oc.PersonCommonName							
			,oc.PersonDisplayName			
			,oc.IsReviewAdmin			
			,oc.EffectiveTime								
			,oc.ExpiryTime										
			,oc.RegistrationSID
			,oc.PracticeRegisterSectionLabel	
			,oc.OrgName											
			,oc.OrgLabel											 
		from
			fOrgContact#EmployeesForPerson(@PersonSID) oc
		where
		(
				(
					isnull(oc.PersonLastName, '~') like @lastName
				and
					(
						@firstName is null																						-- if no first name provided, only needs to match on last name
						or
						isnull(oc.PersonFirstName, '~') like @firstName								-- or first name is matched
						or
						isnull(oc.PersonFirstName, '~') like @middleNames							-- or first name matches with middle names component
					)
				)
				or
					isnull(oc.OrgName, '~') like @searchString + N'%'								-- check if value entered was a OrgName or like a OrgName
				or
					isnull(oc.PersonFirstName, '~') like @SearchString + N'%'				-- or like a first name on its own
			)

	end try

	begin catch
		exec @errorNo = sf.pErrorRethrow                                      -- catch the error, rollback if pending, and re-throw
	end catch

	return(@errorNo)

end
GO
