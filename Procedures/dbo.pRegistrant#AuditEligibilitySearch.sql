SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrant#AuditEligibilitySearch]
	 @SearchString                nvarchar(150) = null	-- name string to search against the registrant's name or email
	,@AuditTypeSID                int           = null
	,@RegistrationYear            smallint      = null
as
/*********************************************************************************************************************************
Procedure : Registrant - Audit Eligibility Search
Notice    : Copyright © 2015 Softworks Group Inc.
Summary   : Searches the registrant audit entity for the search string and search options provided
History   : Author(s)   | Month Year  | Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Cory Ng			| Apr 2017		| Initial version

Comments
--------
TODO: Documentation

Text search
-----------
The search is performed against the applicant's full name and email. A substring search is performed so rows matching any
part of the search string are returned. Wildcard characters: *, %, ?, _ are allowed within string searches.  The procedure 
puts wildcards on both ends of the string if not already provided.

Example:
--------
<TestHarness>
	<Test Name = "RegistrantAuditSID" IsDefault ="true" Description="Finds all registrants that have a 't' in their name">
		<SQLScript>
			<![CDATA[

				exec dbo.pRegistrant#AuditEligibilitySearch @SearchString = 't'

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:03" ResultSet="1" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.pRegistrant#AuditEligibilitySearch'
-------------------------------------------------------------------------------------------------------------------------------- */

set nocount on

begin

	declare
		 @errorNo                         int = 0                             -- 0 no error, <50000 SQL error, else business rule
		,@errorText                       nvarchar(4000)                      -- message text (for business rule errors)
		,@ON                              bit = cast(1 as bit)                -- used on bit comparisons to avoid multiple casts
		,@OFF                             bit = cast(0 as bit)                -- used on bit comparisons to avoid multiple casts
		,@searchType                      varchar(25)                         -- type of search; returned with entity for debugging
		,@maxRows                         int                                 -- maximum rows allowed on search
		,@pinnedAudits                    xml                                 -- pinned audits that are sorted to the top
		,@lastName                        nvarchar(35)                        -- for name searches, buffer for each name part:
		,@firstName                       nvarchar(30)
		,@middleNames                     nvarchar(30)

	begin try

		declare
			@selected                         table                             -- stores results of query - SID only
			(
				 ID                             int identity(1, 1)  not null      -- identity to track add order - preserves custom sorts
				,EntitySID                      int                 not null      -- record ID joined to main entity to return results
			)

		set @SearchString = ltrim(rtrim(@SearchString))												-- remove leading and trailing spaces from character type columns
		if len(@SearchString) = 0 set @SearchString = null										-- when empty string is passed in, set it to null

		-- retrieve max rows for string searches and set other defaults

		set @maxRows      = cast(isnull(sf.fConfigParam#Value('MaxRowsOnSearch'), '100')  as int)

		-- execute the searches

		set @SearchString = sf.fSearchString#Format(@SearchString)					-- format search string and add leading % if not there

		select
				@firstName		= sn.FirstName
			,@lastName		= sn.LastName
			,@middleNames	= sn.MiddleNames
		from
			sf.fSearchName#Split(@SearchString) sn

		if left(@SearchString,1) <> '%'
		begin
			set @SearchString = cast(N'%' + @SearchString as nvarchar(150))
		end

		insert
			@selected
		(
			EntitySID
		)
		select top (@maxRows)
			r.RegistrantSID
		from
			dbo.Registrant r
		join
			sf.vPerson p on r.PersonSID = p.PersonSID
		where
		(
			(
				p.LastName like @lastName
			and
				(
					@firstName is null																						-- if no first name provided, only needs to match on last name
					or
					p.FirstName like @firstName																		-- or first name is matched
					or
					p.FirstName like @middleNames																	-- or first name matches with middle names component
					or
					isnull(p.MiddleNames, '!') like @middleNames									-- or middle names match
					or
					isnull(p.MiddleNames, '!') like @firstName										-- or middle name matches the first name provided
				)
			)
			or
				p.FirstName like @SearchString + N'%'														-- or like a first name on its own
			or
				p.PrimaryEmailAddress like @SearchString + N'%'                 -- or like the email address
		)

		-- return all columns from the entity joined to the PK value from the memory table
		-- the XML column is excluded with the tag so that it's content can be returned
		-- from the variable
		
		select
			 r.RegistrantSID
			,r.RegistrantLabel	
			,r.EmailAddress				
			,r.DirectedAuditYearCompetence
			,dbo.fRegistrant#IsEligibleForAudit(r.RegistrantSID, @AuditTypeSID, @RegistrationYear)				IsEligibleForAudit
		from
			dbo.vRegistrant	r
		join
			@selected			ag on r.RegistrantSID = ag.EntitySID						-- filter by key values returned from the query
		order by
			newid()				

	end try

	begin catch
		exec @errorNo = sf.pErrorRethrow                                      -- catch the error, rollback if pending, and re-throw
	end catch

	return(@errorNo)

end
GO
