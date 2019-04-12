SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vRegistrantAppResponse#History]
as
/*********************************************************************************************************************************
View    : Registrant Application Response History
Notice  : Copyright © 2017 Softworks Group Inc.
Summary	: Returns all registrant app responses with labels for use on the history drop down in the UI
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Kris + Tim	| Mar 2017      |	Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This view returns user labels and additional info for use on the admin UI for displaying historical responses. It is intended
to be called for a single RegistrantApp entity but should perform well for most queries.


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

	,	@RegistrantAppSID		int
	,	@FormOwnerSID				int
	, @i									int
	,	@MaxRows						int

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

set @MaxRows = 100
set @i = 0
while @i < @MaxRows
begin
	set @i += 1

	insert into dbo.RegistrantApp
	(
			RegistrantSID
		,	PracticeRegisterSectionSID
		, RegistrationYear
		,	FormResponseDraft
		,	AdminComments
		, FormVersionSID
	)
	select
			@RegistrantSID
		,	@PracticeRegisterSectionSID
		,	Year(sf.fnow())
		, N'<FormResponse></FormResponse>'
		, N'<AdminComment></AdminComment>'
		, @FormVersionSID

	set @RegistrantAppSID = SCOPE_IDENTITY()

	insert into dbo.RegistrantAppResponse
	(
			RegistrantAppSID
		,	FormOwnerSID
		,	FormResponse
	)
	select
			@RegistrantAppSID
		,	@FormOwnerSID
		, N'<FormResponse> </FormResponse>'
end


	select top 100
		 x.*
	from
		dbo.vRegistrantAppResponse#History x

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
	@ObjectName = 'dbo.vRegistrantAppResponse#History'

------------------------------------------------------------------------------------------------------------------------------- */

select
	 rar.RegistrantAppResponseSID
	,rar.RegistrantAppSID
	,rar.DisplayName
	,rar.FormOwnerLabel
	,rar.CreateTime
from
	dbo.vRegistrantAppResponse rar
GO
