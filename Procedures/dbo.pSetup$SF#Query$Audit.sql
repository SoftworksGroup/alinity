SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.[pSetup$SF#Query$Audit]
as
/*********************************************************************************************************************************
Sproc    : Setup Audit Queries
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : Returns a data set of sf.Query master table data to pSetup$SF#Query
----------------------------------------------------------------------------------------------------------------------------------
History		: Author	  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Russell P		| Aug 2018		|	Initial version

Comments	
--------
This procedure adds queries used to support the audit UI.

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Returns configured registration queries.">
		<SQLScript>
		<![CDATA[
		
			exec dbo.pSetup$SF#Query$Audit

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
	 @ObjectName = 'dbo.pSetup$SF#Query$Audit'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo						int						= 0								-- 0 no error, if < 50000 SQL error, else business rule
	 ,@errorText					nvarchar(4000)									-- message text (for business rule errors)
	 ,@applicationPageSID int															-- key of the search page where these queries are to appear
	 ,@queryCategorySID		int															-- key of category for this query set

	begin try

		declare @setup table -- setup data for staging rows to be inserted
		(
			ID								 int					 identity(1, 1)
		 ,QueryCategorySID	 int					 not null
		 ,QueryLabel				 nvarchar(35)	 not null
		 ,ToolTip						 nvarchar(250) not null
		 ,QuerySQL					 nvarchar(max) not null
		 ,QueryParameters		 xml					 null
		 ,ApplicationPageSID int					 not null
		);

		select
			@applicationPageSID = ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'RegistrantAuditList';

		if @applicationPageSID is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'sf.ApplicationPage'
			 ,@Arg2 = 'RegistrantAuditList';

			raiserror(@errorText, 18, 1);
		end;

		select top (1) 
			@querycategorysid= qc.QueryCategorySID 
		from 
			sf.QueryCategory qc 
		where 
			qc.QueryCategoryLabel like 'Audit %' 
		order by 
			qc.QueryCategorySID

		if @applicationPageSID is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'sf.QueryCategory'
			 ,@Arg2 = 'Audit %';

			raiserror(@errorText, 18, 1);
		end;

		insert
			@setup
		(
			QueryCategorySID
			,QueryLabel
			,ToolTip
			,QueryParameters
			,QuerySQL
			,ApplicationPageSID
		)
		select
			 @queryCategorySID
			,N'Open audits by reviewer'
			,N'Returns all open applications with the reviewer entered through the search.'
			,cast(N'
				<Parameters>
					<Parameter ID="ReviewerPersonSID" Label="Reviewer name" Type="AutoComplete" IsMandatory="True">
						<SQL>
							select
									p.PersonSID   Value
								,p.FileAsName Label
							from
								sf.vPerson p
							join
								sf.vApplicationUserGrant aug
									on  p.PersonSID = aug.PersonSID
							where
								aug.ApplicationGrantSCD = ''EXTERNAL.APPLICATION''
						</SQL>
					</Parameter>
				</Parameters>
			' as xml)
			, N'
				select
						ra.RegistrantAuditSID
				from
					dbo.RegistrantAudit ra
				join
					dbo.RegistrantAuditReview rar
						on  ra.RegistrantAuditSID = rar.RegistrantAuditSID
				where
					rar.PersonSID = [@ReviewerPersonSID]
			'
			,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'RegistrantAuditList'

		insert
			@setup
		(
			QueryCategorySID
			,QueryLabel
			,ToolTip
			,QueryParameters
			,QuerySQL
			,ApplicationPageSID
		)
		select
			 @queryCategorySID
			,N'Open audits without reviewer'
			,N'Returns all open audits without a reviewer assigned.'
			,null
			, N'
select distinct
	ra.RegistrantAuditSID
from
	dbo.RegistrantAudit																								 ra
cross apply dbo.fRegistrantAudit#CurrentStatus(ra.RegistrantAuditSID, -1) cs
left outer join
	dbo.RegistrantAuditReview rar on ra.RegistrantAuditSID = rar.RegistrantAuditSID
where
	rar.RegistrantAuditReviewSID is null and cs.FormStatusSCD <> ''NEW'' and cs.IsFinal = cast(0 as bit)'
			,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'RegistrantAuditList'

		insert
			@setup
		(
			QueryCategorySID
			,QueryLabel
			,ToolTip
			,QueryParameters
			,QuerySQL
			,ApplicationPageSID
		)
		select
			 @queryCategorySID
			,N'By type, status, & recommendation'
			,N'Returns all audits in the selected year with a matching type, status, or recommendation.'
			,cast('<Parameters>
  <Parameter ID="RegistrationYear" Label="Registration Year" Type="Numeric" IsMandatory="true" />
	<Parameter ID="AuditStatusSID" Label="Status" Type="Select" IsMandatory="False">
		<SQL>
			select
					fs.FormStatusSID   Value
				,fs.FormStatusLabel Label
			from
				sf.FormStatus fs
		</SQL>
	</Parameter>
	<Parameter ID="AuditTypeSID" Label="Type" Type="Select" IsMandatory="False">
		<SQL>
				select
					aut.AuditTypeSID		Value
				,	aut.AuditTypeLabel	Label
				from
					dbo.AuditType aut
				where
					aut.IsActive = 1
		</SQL>
	</Parameter>
	<Parameter ID="RecommendationSequence" Label="Recommendation" Type="Select" IsMandatory="False">
		<SQL>
				select
					cast(rcm.RecommendationSequence as int)	Value
				,	rcm.RecommendationLabel	Label
				from
					dbo.vRegistrantAuditReview#Recommendation rcm
		</SQL>
	</Parameter>
</Parameters>' as xml)
			, N'
select
	ra.RegistrantAuditSID
from
	dbo.vRegistrantAudit#Search ra
left join
	dbo.vRegistrantAuditReview#Recommendation rcm on ra.RecommendationLabel = rcm.RecommendationLabel
where
	ra.RegistrationYear = [@RegistrationYear]
and
	([@AuditStatusSID] is null or ra.FormStatusSID = [@AuditStatusSID])
and
	([@AuditTypeSID] is null or ra.AuditTypeSID = [@AuditTypeSID])
and
	([@RecommendationSequence] is null or rcm.RecommendationSequence = [@RecommendationSequence])'
			,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'RegistrantAuditList'

				insert
			@setup
		(
			 QueryCategorySID
			,QueryLabel
			,ToolTip
			,QueryParameters
			,QuerySQL
			,ApplicationPageSID
		)
		select
			@queryCategorySID
			,N'Low practice hours'
			,N'Get registrants who have low practice hours for a given number of years. '
			,cast('<Parameters>
  <Parameter ID="PracticeHours" Label="Include if less than [x] practice hours" Type="Numeric" IsMandatory="true" />
  <Parameter ID="Years" Label="in last [x] years" Type="Numeric" IsMandatory="true" />
  <Parameter ID="AuditYears" Label="Exclude if audited in last [x] years" Type="Numeric" IsMandatory="true" />
  <Parameter ID="ExcludeGradYearStart" Label="Exclude if graduated in or after (year)" Type="Numeric" IsMandatory="true" />
</Parameters>' as xml)
			,N'declare
@AuditCutoffYear int = (sf.fTodayYear() - [@AuditYears])
,@RegistrationCutoffYear int = year(dateadd(yy, [@Years] * -1, sf.fNow()))
,@ON bit = cast(1 as bit)

select distinct
		r.RegistrantSID
from
	dbo.Registrant r
left join
(
	select
			re.RegistrantSID
		,	sum(re.PracticeHours) SumHours
	from
		dbo.RegistrantEmployment re
	where
		re.RegistrationYear > @RegistrationCutoffYear
	group by
		re.RegistrantSID
) re on r.RegistrantSID = re.RegistrantSID
left join
(
	select
			rp.RegistrantSID
		,	sum(rp.OtherJurisdictionHours) SumHours
	from
		dbo.RegistrantPractice rp
	where
		rp.RegistrationYear > @RegistrationCutoffYear
	group by
		rp.RegistrantSID
) rp on r.RegistrantSID = rp.RegistrantSID
outer apply
(
	select (isnull(re.SumHours, 0) + isnull(rp.SumHours, 0)) TotalHours
) th
left outer join
  dbo.RegistrantAudit ra on re.RegistrantSID = ra.RegistrantSID 
		and ra.RegistrationYear >= @AuditCutoffYear
join
  dbo.vRegistrantCredential rc on r.RegistrantSID = rc.RegistrantSID 
		and year(rc.EffectiveTime) < [@ExcludeGradYearStart]
		and rc.IsCredentialAuthority = @ON
where
	ra.RegistrantAuditSID is null
and
	th.TotalHours between 1 and ([@PracticeHours] - 1)
and
	dbo.fRegistrant#IsEligibleForAudit(r.RegistrantSID, null, null) = @ON'
			,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'CreateAuditGroup'
			
		insert
			@setup
		(
			 QueryCategorySID
			,QueryLabel
			,ToolTip
			,QueryParameters
			,QuerySQL
			,ApplicationPageSID
		)
		select
			@queryCategorySID
			,N'Random'
			,N'Returns registrants who currently have an active registration, have had a registration in each of the last 2 years, have not graduated in the last [X] years and have not been audited in [X] years.'
			,cast('
				<Parameters>
					<Parameter ID="ExcludeGradYearStart" Label="Exclude if graduated in or after (year)" Type="Numeric" />
					<Parameter ID="ExcludeAuditYearStart" Label="Exclude if audited in or after (year)" Type="Numeric" />
				</Parameters>' as xml)
			,N'
				declare 
					 @ExpiryStart date = datefromparts(sf.fTodayYear() - 2, 1, 1)
					,@ExpiryYear1 int  = (sf.fTodayYear() - 1)
					,@ExpiryYear2 int = (sf.fTodayYear() - 2)
				select distinct
					y.RegistrantSID
				from
				(
				select
					x.RegistrantSID
					,dbo.fRegistrant#IsEligibleForAudit(x.RegistrantSID, null, null) IsEligible
				from
				(
				select distinct
					r.RegistrantSID
				from
					dbo.Registrant r
				join
					dbo.Registration rl on r.RegistrantSID = rl.RegistrantSID and rl.ExpiryTime >= @ExpiryStart and sf.fIsActive( rl.EffectiveTime, rl.ExpiryTime) = cast(1 as bit)
				join
					dbo.Registration rl1 on r.RegistrantSID = rl1.RegistrantSID and year(rl1.ExpiryTime) = @ExpiryYear1
				join
					dbo.Registration rl2 on r.RegistrantSID = rl2.RegistrantSID and year(rl2.ExpiryTime) = @ExpiryYear2
				join
					dbo.vRegistrantCredential rc on r.RegistrantSID = rc.RegistrantSID and year(rc.EffectiveTime) < [@ExcludeGradYearStart]
				left outer join
					dbo.RegistrantAudit ra on rc.RegistrantSID = ra.RegistrantSID and ra.RegistrationYear >= [@ExcludeAuditYearStart]
				where
					ra.RegistrantAuditSID is null
				) x
				) y
				where
					y.IsEligible = cast(1 as bit)'
			,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'CreateAuditGroup'

		insert
			@setup
		(
			 QueryCategorySID
			,QueryLabel
			,ToolTip
			,QueryParameters
			,QuerySQL
			,ApplicationPageSID
		)
		select
			@queryCategorySID
			,N'Manually selected for validation'
			,N'Gets registrants that have manually been selected for validation.'
			,cast('<Parameters>
					<Parameter ID="Year" Label="Year" Type="Numeric" />
				</Parameters>' as xml)
			,N'select
					r.RegistrantSID
				from
					dbo.Registrant r
				where
					r.DirectedAuditYearCompetence = [@Year]'
			,ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'CreateAuditGroup'

		insert
			sf.Query
		(
			 QueryCategorySID	
			,QueryCode
			,QueryLabel					
			,ToolTip						
			,QuerySQL						
			,QueryParameters
			,ApplicationPageSID
		) 
		select
			 s.QueryCategorySID	
			,'[NONE].' + ltrim(2000 + s.ID)
			,s.QueryLabel					
			,s.ToolTip						
			,s.QuerySQL				
			,s.QueryParameters		
			,s.ApplicationPageSID
		from
			@setup		s
		left outer join
			sf.vQuery	q	on s.QueryLabel = q.QueryLabel and s.ApplicationPageSID = q.ApplicationPageSID
		where
			q.QuerySID is null

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);

end;
GO
