SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrantAudit#GetGroup]
	 @RegistrationYear		smallint																					-- the year to assign to the audit
	,@AuditTypeSID				int																								-- the type of audit to assign
	,@AuditGroupSize			int		= 9999999																		-- maximum size of the audit group to return (default - unlimited)
	,@Query								xml																								-- a document identifying a query and optional parameters
as
/*********************************************************************************************************************************
Procedure : Registrant Audit - Get Group
Notice    : Copyright © 2017 Softworks Group Inc.
Summary   : Returns registrant (entity) records as candidates for auditing
-----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)				| Month Year  | Change Summary
				 : ----------------	|	----------	| --------------
				 : Tim Edlund				| Apr 2017    | Initial version
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure returns an audit group of registrants (dbo.vRegistrant).  The procedure is intended to be called from the UI after
the user has filled out a form identifying the audit type (@AuditTypeSID) and the maximum number of registrants to include in the
selection (@AuditGroupSize).  The final parameter is an XML document identifying the query (reference to sf.Query) to use to
select the group. The format expected for the XML appears below:

declare
		@query xml = N'
		<Query QuerySID="1000123">
			<Parameters>
				<Parameter ID="SomeSID" Value="1000001" />
				<Parameter ID="DirectedAuditYear" Value="2016" />
				<Parameter ID="SomeParm" Value="*null*" />
			</Parameters>
		</Query>'

select @query	AuditCriteria

Registrants are returned by this procedure as candidates for auditing.  The candidate list can then be refined by the user and
finally saved as audit records.  The saving process is carried out by dbo.pRegistrantAudit#SetGroup.

The procedure executes the query and stores the results into a temporary table.  Records are then selected randomly from the table
up to the maximum size of the group specified in the parameter.  The result set returned includes a bit indicating whether
or not the particular registrant returned is eligible for audit according to the base product criteria. The function returning
the eligibility bit will ideally be included in the Query logic itself as a filter to avoid including rows that cannot be
saved into the audit.

For details on eligibility for audit, see dbo.fRegistrant#IsEligibleForAudit


Example
-------
<TestHarness>
  <Test Name="Test" IsDefault="true" Description="-">
  <SQLScript>
  select 1 RegistrantSID, cast(null as nvarchar(65)) RegistrantLabel, cast(null as varchar(150)) EmailAddress, cast(null as smallint) DirectedAuditYearCompetence, cast(1 as bit) IsEligibleForAudit
  </SQLScript>
  <Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:02" />
		</Assertions>
  </Test>
	<Test Name="FileAsName" IsDefault="false" Description="Select 100 direct audit candidates.">
		<SQLScript>
			<![CDATA[

-- NOTE: THIS TEST IS DEPENDENT ON SPECIFIC DATA LABELS for the audit query and the audit
-- type.  This test will not work on all instances unless the expected configuration values
-- have been created!

declare
		@querySID							int
	,	@registrationYear			smallint
	,	@query								xml
	, @auditTypeSID					int

select 
	 @querySID						= q.QuerySID
	,@registrationYear = (sf.fTodayYear() - 1 )
from 
	sf.Query q 
where 
	q.QueryLabel like 'Manually selected for%'															-- hardcoded label reference!

set @query = replace(replace(
N'<Query QuerySID="#######">
<Parameters>
	<Parameter ID="Year" Value="XXXX" />
</Parameters>
</Query>'
, '#######', ltrim(@querySID))
, 'XXXX', ltrim(@registrationYear))

select top 1
	@auditTypeSID = at.AuditTypeSID
from
	dbo.AuditType at
where
	at.AuditTypeLabel like 'Directed%'																			-- hardcoded label reference!

exec dbo.pRegistrantAudit#GetGroup
	 @RegistrationYear		= @registrationYear
	,@AuditTypeSID				= @auditTypeSID
	,@AuditGroupSize			= 100
	,@Query								= @query

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:02" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.pRegistrantAudit#GetGroup'
-------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on

	declare
		 @errorNo												int = 0																-- 0 no error, <50000 SQL error, else business rule
		,@errorText											nvarchar(4000)												-- message text (for business rule errors)
		,@blankParm											nvarchar(100)													-- error checking buffer for required parameters
		,@querySID											int																		-- next query key to process
		,@queryParameters								xml																		-- query parameter document (to pass to pQuery#Execute)
		
	declare
		@auditGroup											table																	-- a table to hold registrant keys returned from queries
		(
			 ID														int			not null identity(1,1)
			,RegistrantSID								int			not null
		)

	begin try

		-- check parameters

		if @RegistrationYear is null set @blankParm = '@RegistrationYear'
		if @AuditTypeSID		 is null set @blankParm = '@AuditTypeSID'		
		if @AuditGroupSize	 is null set @blankParm = '@AuditGroupSize'	
		if @Query						 is null set @blankParm = '@Query'

		if @blankParm is not null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= @blankParm

			raiserror(@errorText, 18, 1)
		
		end

		-- parse xml to obtain data for query execution

		select
			 @querySID        = Query.q.value('@QuerySID', 'int')
			,@queryParameters = Query.q.query('Parameters')
		from
			@query.nodes('//Query') Query(q)

		if isnull(@querySID,0) = 0
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@QuerySID'

			raiserror(@errorText, 16, 1)

		end

		-- manually check for null mandatory parameters
		declare
				@baseParam								xml

		select
			@baseParam = qy.QueryParameters
		from
			sf.Query qy
		where
			QuerySID = @querySID

		select top (1)
			@blankParm = qn.x.value('@Label', 'nvarchar(100)')
		from
			@queryParameters.nodes('/Parameters/Parameter') pn(x)
		join
			@baseParam.nodes('/Parameters/Parameter') qn(x) on pn.x.value('@ID', 'nvarchar(100)') = qn.x.value('@ID', 'nvarchar(100)')
		where
			pn.x.value('@Value', 'nvarchar(100)') = ''
		and
			isnull(qn.x.value('@IsMandatory', 'bit'), 0) = 1

		if @blankParm is not null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= @blankParm

			raiserror(@errorText, 16, 1)

		end

		-- store query results

		insert
			@auditGroup
		(
			RegistrantSID
		)
		exec sf.pQuery#Execute
			 @QuerySID        = @querySID
			,@QueryParameters = @queryParameters

		-- return the results including a bit indicating whether the
		-- registrant is eligible (should already be filtered in query)

		select top (@AuditGroupSize)
			 r.RegistrantSID
			,	sf.fFormatFileAsName(p.LastName, p.FirstName, p.MiddleNames) + ' (' + r.RegistrantNo + ')'	RegistrantLabel
			,pea.EmailAddress				
			,r.DirectedAuditYearCompetence
			,dbo.fRegistrant#IsEligibleForAudit(r.RegistrantSID, @AuditTypeSID, @RegistrationYear)				IsEligibleForAudit
		from
			dbo.Registrant						r
		join
			sf.Person									p   on r.PersonSID = p.PersonSID
		left outer join
			sf.PersonEmailAddress			pea	on p.PersonSID = pea.PersonSID and pea.IsActive = cast(1 as bit) and pea.IsPrimary = cast(1 as bit)
		join
			@auditGroup			ag on r.RegistrantSID = ag.RegistrantSID						-- filter by key values returned from the query
		order by
			newid()																															-- randomize records selected if larger than @AuditGroupSize

	end try

	begin catch
		if @@trancount > 0 rollback
		exec @errorNo = sf.pErrorRethrow																			-- catch the error, rollback if pending, and re-throw
	end catch

	return(@errorNo)

end
GO
