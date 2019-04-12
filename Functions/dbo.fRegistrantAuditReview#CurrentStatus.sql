SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fRegistrantAuditReview#CurrentStatus]
(
	@RegistrantAuditReviewSID int -- key of record to return status information for
 ,@FormTypeSID							int -- type of form to retrieve status for
)
returns table
/*********************************************************************************************************************************
Function	: Registrant Audit Review Current Status
Notice		: Copyright © 2017 Softworks Group Inc.
Summary		: Returns latest status information for a Registrant Audit Review
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Tim Edlund	| May 2017    |	Initial version
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This table function modularizes the logic required to determine the latest status of a Registrant Audit Review form.  Audit 
review forms have their statuses changed through the Registrant-Audit-Review-Status table.  Determining the current status of an 
audit review requires examining the status change records.  This information is required frequently throughout the form processing 
work-flow. 

CAUTION ! if NO status changes exist for a Registrant-Audit-Review, then NULL is returned. This is done to maximize performance of 
the function.  Where this function is being used in situations where all Registrant Audit Reviews must be included  in the result 
set, an outer apply is required.

Example
-------
!<TestHarness>
	<Test Name = "Select100" Description="Select a sample set of records from the function.">
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


	select top 100
		 x.*
	from
		dbo.RegistrantAuditReview rar
	join
		sf.FormVersion								fv		on rar.FormVersionSID = fv.FormVersionSID
	join
		sf.Form												f			on fv.FormSID = f.FormSID
	cross apply
		dbo.fRegistrantAuditReview#CurrentStatus(rar.RegistrantAuditReviewSID, f.FormTypeSID) x

	if @@rowcount = 0 raiserror( N'* ERROR: no sample data found to run test', 18, 1)
	if @@trancount > 0 rollback

]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
	
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
!</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.fRegistrantAuditReview#CurrentStatus'

-------------------------------------------------------------------------------------------------------------------------------- */

return
(
	select
		ras.RegistrantAuditReviewStatusSID
	 ,fs.FormStatusSID
	 ,fs.FormStatusSCD
	 ,fs.FormStatusLabel
	 ,(case when fo.FormOwnerSCD = 'ASSIGNEE' then foA.FormOwnerSID else fo.FormOwnerSID end)			FormOwnerSID
	 ,(case when fo.FormOwnerSCD = 'ASSIGNEE' then foA.FormOwnerSCD else fo.FormOwnerSCD end)			FormOwnerSCD
	 ,(case when fo.FormOwnerSCD = 'ASSIGNEE' then foA.FormOwnerLabel else fo.FormOwnerLabel end) FormOwnerLabel
	 ,ras.CreateTime
	 ,ras.CreateUser
	 ,isnull(fs.IsFinal, cast(0 as bit))																													IsFinal
	 ,(case when fs.IsFinal = cast(1 as bit) then cast(0 as bit)else cast(1 as bit)end)						IsInProgress
	from
		dbo.RegistrantAuditReviewStatus ras
	join
	(
		select top 1
			ras.RegistrantAuditReviewStatusSID CurrentRegistrantAuditReviewStatusSID -- isolate latest status record
		from
			dbo.RegistrantAuditReviewStatus ras
		where
			ras.RegistrantAuditReviewSID = @RegistrantAuditReviewSID
		order by
			ras.CreateTime desc
		 ,ras.RegistrantAuditReviewStatusSID desc
	)																	x on ras.RegistrantAuditReviewStatusSID = x.CurrentRegistrantAuditReviewStatusSID -- join to filter to latest status records only
	join
		sf.FormStatus										fs on ras.FormStatusSID									= fs.FormStatusSID -- join to the master status record
	join
		sf.FormOwner										fo on fs.FormOwnerSID										= fo.FormOwnerSID -- join to form owner to get label to apply to responsible party for next action on form
	join
		sf.FormType											ft on ft.FormTypeSID										= @FormTypeSID -- join through the form type to the form owner in case owner is "ASSIGNEE"
	join
		sf.FormOwner										foA on ft.FormOwnerSID									= foA.FormOwnerSID -- when owner is ASSIGNEE it is resolved to label used for the form type
	where
		ras.RegistrantAuditReviewSID = @RegistrantAuditReviewSID
);
GO
