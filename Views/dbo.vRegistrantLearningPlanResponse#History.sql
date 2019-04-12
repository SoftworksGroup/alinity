SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vRegistrantLearningPlanResponse#History]
as
/*********************************************************************************************************************************
View    : RegistrantLearningPlan Response History
Notice  : Copyright © 2017 Softworks Group Inc.
Summary	: Returns all registrant app responses with labels for use on the history drop down in the UI
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim	Edlund	| Oct 2017      |	Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This view returns user labels and additional info for use on the admin UI for displaying historical responses. It is intended
to be called for a single RegistrantLearningPlan entity but should perform well for most queries.

Example
-------
!<TestHarness>
<Test Name = "Select100" Description="Select a sample set of records from the view.">
<SQLScript>
<![CDATA[
begin tran

	declare
			@RegistrantSID							int
		,	@PracticeRegisterSectionSID int
		,	@FormVersionSID							int
		, @RegistrationYear						int

		,	@RegistrantLearningPlanSID	int
		,	@FormOwnerSID								int
		, @i													int
		,	@MaxRows										int

	select top 1
		@RegistrantSID = r.RegistrantSID
	from
		dbo.Registrant r
	select top 1
		@PracticeRegisterSectionSID  = prs.PracticeRegisterSectionSID
	from
		dbo.PracticeRegister pr
	join
		dbo.PracticeRegisterSection prs on pr.PracticeRegisterSID = prs.PracticeRegisterSID
	where
		pr.IsDefault = 1
	and
		prs.IsDefault = 1

	select top 1
		@FormVersionSID = fv.FormVersionSID
	from
		sf.FormVersion fv

	select top 1
		@FormOwnerSID = fo.FormOwnerSID
	from
		sf.FormOwner fo

	select
		@RegistrationYear = year(sf.fNow())

	set @MaxRows = 100
	set @i = 0

	while @i < @MaxRows
	begin
		set @i += 1
		set @RegistrationYear += 1

		insert into dbo.RegistrantLearningPlan
		(
				RegistrantSID
			, RegistrationYear
			,	FormResponseDraft
			,	AdminComments
			, FormVersionSID
		)
		select
				@RegistrantSID
			,	@RegistrationYear
			, N'<FormResponses></FormResponses>'
			, N'<Comments></Comments>'
			, @FormVersionSID

		set @RegistrantLearningPlanSID = SCOPE_IDENTITY()

		insert into dbo.RegistrantLearningPlanResponse
		(
				RegistrantLearningPlanSID
			,	FormOwnerSID
			,	FormResponse
		)
		select
				@RegistrantLearningPlanSID
			,	@FormOwnerSID
			, N'<FormResponse> </FormResponse>'

	end

		select top 100
			 x.*
		from
			dbo.vRegistrantLearningPlanResponse#History x

	if @@rowcount < 0 raiserror( N'* ERROR: no sample data found to run test', 18, 1)

if @@TRANCOUNT > 0 rollback
]]>
</SQLScript>
<Assertions>
	<Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
	<Assertion Type="ExecutionTime" Value="00:00:05" />
</Assertions>
</Test>
!</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.vRegistrantLearningPlanResponse#History'

------------------------------------------------------------------------------------------------------------------------------- */

select
	rlp.RegistrantLearningPlanResponseSID
 ,rlp.RegistrantLearningPlanSID
 ,rlp.DisplayName
 ,rlp.FormOwnerLabel
 ,rlp.CreateTime
from
	dbo.vRegistrantLearningPlanResponse rlp;
GO
