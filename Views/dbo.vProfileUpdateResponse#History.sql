SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vProfileUpdateResponse#History]
as
/*********************************************************************************************************************************
View    : ProfileUpdate Response History
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
to be called for a single ProfileUpdate entity but should perform well for most queries.

Example
-------
!<TestHarness>
<Test Name = "Select100" Description="Select a sample set of records from the view.">
<SQLScript>
<![CDATA[

declare
		@PersonSID					int
	,	@FormVersionSID			int

	,	@ProfileUpdateSID		int
	,	@FormOwnerSID				int
	, @i									int
	,	@MaxRows						int

select top 1
	@PersonSID = p.PersonSID
from
	sf.Person p

select top 1
	@FormVersionSID = fv.FormVersionSID
from
	sf.FormVersion fv

select top 1
	@FormOwnerSID = fo.FormOwnerSID
from
	sf.FormOwner fo


	insert into dbo.ProfileUpdate
	(
			PersonSID
		,	FormVersionSID
		,	FormResponseDraft
		,	AdminComments
	)
	select
			@PersonSID
		,	@FormVersionSID
		, N'<FormResponse></FormResponse>'
		, N'<AdminComment></AdminComment>'

	set @ProfileUpdateSID = SCOPE_IDENTITY()

	insert into dbo.ProfileUpdateResponse
	(
			ProfileUpdateSID
		,	FormOwnerSID
		,	FormResponse
	)
	select
			@ProfileUpdateSID
		,	@FormOwnerSID
		, N'<FormResponse> </FormResponse>'

select
	x.*
from
	dbo.vProfileUpdateResponse#History x;

if @@rowcount = 0 raiserror( N'* ERROR: no sample data found to run test', 18, 1)
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
	@ObjectName = 'dbo.vProfileUpdateResponse#History'

------------------------------------------------------------------------------------------------------------------------------- */

select
	pu.ProfileUpdateResponseSID
 ,pu.ProfileUpdateSID
 ,pu.DisplayName
 ,pu.FormOwnerLabel
 ,pu.CreateTime
from
	dbo.vProfileUpdateResponse pu;
GO
