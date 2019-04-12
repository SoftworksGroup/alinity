SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fRegistrantAudit#Recommendation]
(
	 @RegistrantAuditSID			int																						-- key of record to check
)
returns  nvarchar(20)
as
/*********************************************************************************************************************************
ScalarF		: Registrant Audit Recommendation Label
Notice		: Copyright © 2017 Softworks Group Inc.
Summary		: Returns the recommendation term to display summarizing reviews on the audit
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-------------------------------------------------------------------------------------------
					: Tim Edlund  | Jun 2017		|	Initial version
					: Robin Payne	| Jan	2018		| Fixed Test Harness
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------

This function is called by the dbo.fRegistrantAudit#Ext function and search view to return a value summarizing the status of 
reviews assigned to the audit.  An audit may be assigned multiple reviews.  If the reviews have different recommendations, the 
function will return the recommendation applied most often.  If reviews are outstanding (incomplete) however, no recommendation 
is returned and a status of "PENDING" is returned instead.  If no reviews are assigned yet, then "NOT.ASSIGNED" is returned.  
The actual labels returned are looked up to use configuration-specific language if available in sf.TermLabel.

Note that the UI tier (or db caller) should check to see if any review forms are configured for the audit record before calling
the function to maximize performance.

Example
-------
<TestHarness>
	<Test Name = "Simple" Description="Returns the extended columns for an instance of the entity at random.">
	<SQLScript>
	<![CDATA[
	begin tran
	
	declare
				@RegistrationYear							int
			,	@FormStatusSID								int
			,	@FormVersionSID								int
			,	@AuditTypeSID									int
			,	@PersonSID										int
			, @ReasonSID										int
			,	@ReviewerSID									int
			,	@RecommendationSID						int
			,	@RegistrantSID								int
			,	@RegistrantAuditSID						int
			, @RegistrantAuditReviewSID			int
	
	set @RegistrationYear = year(sf.fnow())
	
	select top 1
		@FormStatusSID = fs.FormStatusSID 
	from
		sf.FormStatus fs
	
	select top 1
		@formVersionSID = fv.FormVersionSID
	from 
		sf.FormVersion fv
	
	select top 1
		@AuditTypeSID = at.AuditTypeSID
	from
		dbo.AuditType at
	
	select top 1
		@PersonSID = p.PersonSID
	from
		sf.Person p
	
	select top 1
		@ReviewerSID = p.PersonSID
	from
		sf.Person p
	where
		p.personsid <> @PersonSID
	
	select top 1
		@ReasonSID = r.ReasonSID
	from
		dbo.Reason r
	
	select top 1
		@RecommendationSID = r.RecommendationSID
	from
		dbo.Recommendation r
	
	insert into dbo.Registrant
	(
			PersonSID
		,	RegistrantNo
	)
	select
			@PersonSID
		, left(newid(), 50)
	
	set @RegistrantSID = scope_identity()
	
	
	
	insert into dbo.RegistrantAudit
	(
			RegistrantSID
		,	AuditTypeSID
		,	RegistrationYear
		,	FormVersionSID
	)
	select
			@RegistrantSID
		,	@AuditTypeSID
		,	@RegistrationYear
		, @FormVersionSID
	
	set @RegistrantAuditSID = scope_identity()
	
	insert into dbo.RegistrantAuditReview
	(
			RegistrantAuditSID
		,	FormVersionSID
		, PersonSID
		,	ReasonSID
		,	RecommendationSID
	)
	select
			@RegistrantAuditSID
		,	@FormVersionSID
		, @ReviewerSID
		, @ReasonSID
		,	@RecommendationSID
	
	set @RegistrantAuditReviewSID = scope_identity()
	
	insert into dbo.RegistrantAuditReviewStatus 
	(
			RegistrantAuditReviewSID
		, FormStatusSID
	)
	select
			@RegistrantAuditReviewSID
		, @FormStatusSID
	
	select top 10
				dbo.fRegistrantAudit#Recommendation(ra.RegistrantAuditSID) recommendation
			, ra.*
	from 
		dbo.RegistrantAudit ra
	order by
		newid()
	
	if @@rowcount = 0 raiserror( N'* ERROR: no sample data found to run test', 18, 1)
	if @@trancount > 0 rollback


	]]>
	</SQLScript>
	<Assertions>
		<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
		<Assertion Type="ExecutionTime" Value="00:00:02" />
	</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.fRegistrantAudit#Recommendation'
	
------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		 @ON												  bit							= cast(1 as bit)				-- constant to eliminate repetitive casting syntax
		,@OFF												  bit							= cast(0 as bit)				-- constant to eliminate repetitive casting syntax
		,@recommendationSID						int																			-- recommendation appearing on reviews
		,@recommendationCount					int																			-- count of recommendations
		,@incomplete									int																			-- count of outstanding (incomplete) reviews
		,@recommendationLabel					nvarchar(20)														-- recommendation term to display summarizing reviews on the application
		,@termLabelSCD								varchar(35)															-- used to lookup description for change in sf.TermLabel

	-- inspect the recommendations on the review forms for the given audit; find
	-- the most common recommendation but check also for null recommendations (incomplete)
	
	select top 1
			@recommendationSID		= x.RecommendationSID
		,	@recommendationCount	= x.RecommendationCount
		,	@incomplete						= x.Incomplete
	from
	(
	select
			rar.RecommendationSID
		, count(1)																														RecommendationCount
		,	sum(case when rar.RecommendationSID is null then 1 else 0 end)			Incomplete
	from
		dbo.fRegistrantAudit#LatestReviews(@RegistrantAuditSID) rar
	cross apply
		dbo.fRegistrantAuditReview#CurrentStatus(rar.RegistrantAuditReviewSID, rar.FormTypeSID) x
	where
		x.IsFinal = @OFF																											-- avoid withdrawn forms
	group by
		rar.RecommendationSID
	) x
	order by
			x.Incomplete						desc
		,	x.RecommendationCount desc

	if @@rowcount = 0 set @recommendationCount = 0

	if @recommendationCount = 0																							-- no reviews exist for this application														
	begin
		set @termLabelSCD = 'NOT.ASSIGNED'
	end
	else if @incomplete > 0																									-- at least one assigned review is not complete - in process 
	begin
		set @termLabelSCD = 'PENDING'
	end
	else																																		-- check if another recommendation has been made the same number of times
	begin
	
		if @recommendationCount =
		(
		select
			count(1)
		from
			dbo.fRegistrantAudit#LatestReviews(@RegistrantAuditSID) rar
		cross apply
			dbo.fRegistrantAuditReview#CurrentStatus(rar.RegistrantAuditReviewSID, rar.FormTypeSID) x
		where
			x.IsFinal = @OFF																										-- avoid withdrawn forms
		and
			isnull(rar.RecommendationSID, -1) <> @recommendationSID							-- avoid the recommendation already identified
		) 
		begin
			set @termLabelSCD = 'MIXED'																					-- different recommendations have equal counts
		end
		else
		begin
			set @termLabelSCD = '*'																							-- one recommendation has highest count
		end

	end
	
	-- lookup the label for the term identified above; use recommendation
	-- label if one recommendation has a higher count than any other-

	if @termLabelSCD = '*'
	begin
		select @recommendationLabel = r.ButtonLabel from dbo.Recommendation r where r.RecommendationSID = @recommendationSID	
	end
	else
	begin
		set @recommendationLabel = cast(sf.fProperCase(sf.fObjectNameSpaced(@termLabelSCD)) as nvarchar(20))

		select
			@recommendationLabel = sf.fTermLabel(@termLabelSCD, @recommendationLabel)
		from
			sf.TermLabel tl
		where
			tl.TermLabelSCD = @termLabelSCD

	end

	return(@recommendationLabel)

end
GO
