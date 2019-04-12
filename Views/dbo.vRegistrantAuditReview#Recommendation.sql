SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vRegistrantAuditReview#Recommendation]
as
/*********************************************************************************************************************************
View		: Registrant Audit Review - Recommendation
Notice  : Copyright © 2017 Softworks Group Inc.
Summary	: Returns statistical information for registrant audits
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund	| Jun 2017			|	Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This view is intended for use in the UI to filter registrant audits by the status of their associated review forms.  The view
obtains the list of recommendations from the dbo.Recommendation table for the group = 'AUDIT.REVIEW' but also adds specific
labels for types assigned by the system when recommendations are mixed, or are not complete.  Those values may have 
configuration specific overrides recorded in the sf.Termlabel table but are otherwise assigned default values.
------------------------------------------------------------------------------------------------------------------------------- */
select
	x.RecommendationLabel
	,isnull(row_number() over(order by x.RecommendationSequence),0) as RecommendationSequence
from
(
	select 
			sf.fTermLabel('NOT.ASSIGNED', 'Not Assigned') RecommendationLabel
		,	-3																						RecommendationSequence	
	union
	select 
			sf.fTermLabel('PENDING', 'Pending')						RecommendationLabel
		,	-2																						RecommendationSequence
	union
	select
			sf.fTermLabel('MIXED', 'Mixed')								RecommendationLabel
		,	-1																						RecommendationSequence
	union
	(
		select
				r.ButtonLabel		RecommendationLabel
			,	r.RecommendationSequence
		from
			dbo.RecommendationGroup rg 
		join
			dbo.Recommendation			r		on rg.RecommendationGroupSID = r.RecommendationGroupSID
		where
			rg.RecommendationGroupSCD = 'AUDIT.REVIEW'
	)
) x
GO
