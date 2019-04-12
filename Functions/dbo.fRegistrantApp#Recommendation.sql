SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fRegistrantApp#Recommendation 
(
	@RegistrantAppSID int -- key of record to return recommendation label for
)
returns nvarchar(30)
as
/*********************************************************************************************************************************
ScalarF		: Registrant Application Recommendation Label
Notice		: Copyright © 2017 Softworks Group Inc.
Summary		: Returns the recommendation term to display summarizing reviews on the application
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Jun 2017		|	Initial version
				: Tim Edlund					| Sep 2018		| Recommendation (button) label returned if all reviews agree.

Comments	
--------
This function returns a label value summarizing the status of reviews assigned to the application.  If no review form has been
configured for the Register associated with the application, then NULL is returned; otherwise a value is always returned.

Return values are:

NULL												- no review form is configured for the Register associated with the application
No Assignments							- no reviewers have been assigned
Pending											- at least one assigned review has no recommendation
Complete: Mixed							- all reviews have recommendations but recommendations are not all the same
Complete: [Recommendation]	- all reviews have the same recommendation so the recommendation button label is returned

An application may be assigned multiple reviews.  If all reviews (or if only 1 review) have the same recommendation, then that 
recommendation label is returned. All other labels in the list above are hard-coded.

Note that if no review forms have been configured for the parent record, then NULL is returned.  

Example
-------
!<TestHarness>
	<Test Name = "Simple" Description="Returns the extended columns for an instance of the entity at random.">
		<SQLScript>
			<![CDATA[

if not exists (select 1 from dbo .RegistrantAppReview appRvw)
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	select
		x.RegistrantAppSID
	 ,dbo.fRegistrantApp#Recommendation(x.RegistrantAppSID) RecommendationLabel
	from
	(
		select top (100)
			app.RegistrantAppSID
		from
			dbo.RegistrantApp app
		order by
			newid()
	) x;

end;

	]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:02" />
		</Assertions>
	</Test>
!</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.fRegistrantApp#Recommendation'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		@minRecommendationSID int						-- recommendation appearing on reviews (compared to max to look for difference)
	 ,@maxRecommendationSID int						-- recommendation appearing on reviews (compared to min to look for difference)
	 ,@recommendationCount	int						-- count of recommendations
	 ,@incomplete						int						-- count of outstanding (incomplete) reviews
	 ,@recommendationLabel	nvarchar(20); -- recommendation term to display summarizing reviews on the application

	-- inspect the recommendations on the review forms for the given application; find
	-- the most common recommendation but check also for null recommendations (incomplete)

	select
		@minRecommendationSID = min(rvw.RecommendationSID)
	 ,@maxRecommendationSID = max(rvw.RecommendationSID)
	 ,@recommendationCount	= count(1)
	 ,@incomplete						= sum(case when rvw.RecommendationSID is null then 1 else 0 end)
	from
		dbo.RegistrantAppReview																													 rvw
	outer apply dbo.fRegistrantAppReview#CurrentStatus(rvw.RegistrantAppReviewSID, -1) x
	where
		rvw.RegistrantAppSID = @RegistrantAppSID and x.FormStatusSCD <> 'WITHDRAWN' -- avoid withdrawn reviews
	group by
		rvw.RecommendationSID;

	if @@rowcount = 0 set @recommendationCount = 0;

	if @recommendationCount = 0 -- no reviews exist for this application														
	begin

		-- if no review form is configured for the Practice Register associated with the application
		-- then the returned status is NULL (callers can rely on NULL meaning that no reviews apply)

		if exists
		(
			select
				1
			from
				dbo.RegistrantApp						ra
			join
				dbo.PracticeRegisterSection prs on ra.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
			join
				dbo.PracticeRegisterForm		prf on prs.PracticeRegisterSID			 = prf.PracticeRegisterSID
			join
				sf.Form											f on prf.FormSID										 = f.FormSID
			join
				sf.FormType									ft on f.FormTypeSID									 = ft.FormTypeSID and ft.FormTypeSCD = 'APPLICATION.REVIEW'
			where
				ra.RegistrantAppSID = @RegistrantAppSID
		)
		begin
			set @recommendationLabel = N'No Assignments'; -- otherwise advise caller no reviewers are assigned
		end;
	end;
	else if @incomplete > 0 -- at least one assigned review is not complete - in process 
	begin
		set @recommendationLabel = N'Pending';
	end;
	else if @minRecommendationSID <> @maxRecommendationSID -- multiple recommendations were made
	begin
		set @recommendationLabel = N'Complete: Mixed';
	end;
	else
	begin

		-- all recommendations (may be only 1) are the same so show the label

		select
			@recommendationLabel = 'Complete: ' + r.ButtonLabel
		from
			dbo.Recommendation r
		where
			r.RecommendationSID = @minRecommendationSID;
	end;

	return (@recommendationLabel);

end;
GO
