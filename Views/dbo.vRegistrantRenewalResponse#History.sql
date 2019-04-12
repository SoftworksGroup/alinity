SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vRegistrantRenewalResponse#History]
as
/*********************************************************************************************************************************
View    : Registrant Renewal Response History
Notice  : Copyright © 2017 Softworks Group Inc.
Summary	: Returns all registrant app responses with labels for use on the history drop down in the UI
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim	Edlund	| Aug 2017      |	Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This view returns user labels and additional info for use on the admin UI for displaying historical responses. It is intended
to be called for a single RegistrantRenewal entity but should perform well for most queries.


Example
-------
!<TestHarness>
<Test Name = "Select100" Description="Select a sample set of records from the view.">
<SQLScript>
<![CDATA[
begin tran

	declare
			@RegistrationSID				int
		,	@PracticeRegisterSectionSID int
		,	@FormVersionSID							int
		, @RegistrationYear						int

		,	@RegistrantRenewalSID				int
		,	@FormOwnerSID								int

	select top 1
		@RegistrationSID = rl.RegistrationSID
	from
		dbo.Registration rl

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


	insert into dbo.RegistrantRenewal
	(
			RegistrationSID
		, RegistrationYear
		, PracticeRegisterSectionSID
		,	FormResponseDraft
		,	AdminComments
		, FormVersionSID
	)
	select
			@RegistrationSID
		,	@RegistrationYear
		,	@PracticeRegisterSectionSID
		, N'<FormResponses></FormResponses>'
		, N'<Comments></Comments>'
		, @FormVersionSID

	set @RegistrantRenewalSID = SCOPE_IDENTITY()

	insert into dbo.RegistrantRenewalResponse
	(
			RegistrantRenewalSID
		,	FormOwnerSID
		,	FormResponse
	)
	select
			@RegistrantRenewalSID
		,	@FormOwnerSID
		, N'<FormResponse> </FormResponse>'

		select top 100
			 x.*
		from
			dbo.vRegistrantRenewalResponse#History x

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
	@ObjectName = 'dbo.vRegistrantRenewalResponse#History'

------------------------------------------------------------------------------------------------------------------------------- */

select
	 rar.RegistrantRenewalResponseSID
	,rar.RegistrantRenewalSID
	,rar.DisplayName
	,rar.FormOwnerLabel
	,rar.CreateTime
from
	dbo.vRegistrantRenewalResponse rar
GO
