SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fRegistrantAudit#LatestReviews]
(
	 @RegistrantAuditSID							int																-- key of record to check
)
returns  @registrantAudit#LatestReviews table
(
		RegistrantAuditReviewSID				INT
  , RegistrantAuditSID							INT
  , FormVersionSID									INT
  , PersonSID												INT
  , ReasonSID												INT
  , RecommendationSID								INT
  , FormResponseDraft								XML
  , FormTypeSID											INT
  , ReviewerComments								XML
  , ConfirmationDraft								NVARCHAR (MAX)
  , IsAutoApprovalEnabled						BIT
  , UserDefinedColumns							XML
  , RegistrantAuditReviewXID				VARCHAR (150)
  , LegacyKey												NVARCHAR (50)
  , IsDeleted												BIT
  , CreateUser											NVARCHAR (75)
  , CreateTime											DATETIMEOFFSET (7)
  , UpdateUser											NVARCHAR (75)
  , UpdateTime											DATETIMEOFFSET (7)
)
as
/*********************************************************************************************************************************
TableF		: Registrant Audit Latest Reviews
Notice		: Copyright © 2017 Softworks Group Inc.
Summary		: Returns a table of
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-------------------------------------------------------------------------------------------
					: Taylor N	  | Aug 2018		|	Initial version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------

This function is intended to return the latest, unwithdrawn, review recommendations for each reviewer associated with an audit. Since an 
audit can have the same user review it multiple times, or have an initial review withdrawn, this function is necessary in order to still 
have accurate final recommendations. Due to that, it is called from the fRegistrantAudit#Recommendation function.

Example
-------

<TestHarness>
	<Test Name = "Simple" Description="">
	<SQLScript>
	<![CDATA[

		select top 10
				rax.*				
		from 
			dbo.RegistrantAudit ra
		cross apply
			dbo.fRegistrantAudit#LatestReviews(ra.RegistrantAuditSID) rax
		order by
			newid()

	]]>
	</SQLScript>
	<Assertions>
		<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
		<Assertion Type="ExecutionTime" Value="00:00:02" />
	</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.fRegistrantAudit#LatestReviews'
	
------------------------------------------------------------------------------------------------------------------------------- */

begin

	insert 
		@registrantAudit#LatestReviews
		(
				RegistrantAuditReviewSID
			, RegistrantAuditSID
			, FormVersionSID
			, PersonSID
			, ReasonSID
			, RecommendationSID
			, FormResponseDraft
			, FormTypeSID
			, ReviewerComments
			, ConfirmationDraft
			, IsAutoApprovalEnabled
			, UserDefinedColumns
			, RegistrantAuditReviewXID
			, LegacyKey
			, IsDeleted
			, CreateUser
			, CreateTime
			, UpdateUser
			, UpdateTime
		)
		select
				mx.RegistrantAuditReviewSID
			, mx.RegistrantAuditSID
			, mx.FormVersionSID
			, mx.PersonSID
			, mx.ReasonSID
			, mx.RecommendationSID
			, mx.FormResponseDraft
			, mx.FormTypeSID
			, mx.ReviewerComments
			, mx.ConfirmationDraft
			, mx.IsAutoApprovalEnabled
			, mx.UserDefinedColumns
			, mx.RegistrantAuditReviewXID
			, mx.LegacyKey
			, mx.IsDeleted
			, mx.CreateUser
			, mx.CreateTime
			, mx.UpdateUser
			, mx.UpdateTime
		from
		(
			select
					rar.RegistrantAuditReviewSID
				, rar.RegistrantAuditSID
				, rar.FormVersionSID
				, rar.PersonSID
				, rar.ReasonSID
				, rar.RecommendationSID
				, rar.FormResponseDraft
				, f.FormTypeSID
				, rar.ReviewerComments
				, rar.ConfirmationDraft
				, rar.IsAutoApprovalEnabled
				, rar.UserDefinedColumns
				, rar.RegistrantAuditReviewXID
				, rar.LegacyKey
				, rar.IsDeleted
				, rar.CreateUser
				, rar.CreateTime
				, rar.UpdateUser
				, rar.UpdateTime
				,	row_number() over (partition by rar.PersonSID order by rar.CreateTime desc) RowNo
			from
				dbo.RegistrantAuditReview rar
			join
				sf.FormVersion						fv		on rar.FormVersionSID = fv.FormVersionSID
			join
				sf.Form										f			on fv.FormSID = f.FormSID
			cross apply
				dbo.fRegistrantAuditReview#CurrentStatus(rar.RegistrantAuditReviewSID, f.FormTypeSID) cs
			where
				rar.RegistrantAuditSID = @RegistrantAuditSID
			and
				cs.FormOwnerSCD <> 'WITHDRAWN'																					-- avoid withdrawn forms
		) mx
		where
			mx.RowNo = 1

	return

end
GO
