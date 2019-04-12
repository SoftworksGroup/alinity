SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fOrg#FullLabel]
(
	 @OrgSID											int																				-- the organization SID
)
returns nvarchar(max)
as 
/*********************************************************************************************************************************
Function: Organization - Full Label
Notice  : Copyright © 2016 Softworks Group Inc.
Summary	: Gets the full organization label including parent org names.
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year			| Change Summary
				: ------------|-----------------|-----------------------------------------------------------------------------------------
				: Cory Ng			| June 2016				|	Initial version
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This function combines the organizations names and all parent organization names into one string. The organizations are separated
with a dash with the highest level organization appearing first. The full label is used to show context of where the organization
lies within its parents. An example of the output is "Alberta Health Services - University of Alberta Hospital - Pediatrics".

Example
-------
<TestHarness>
<Test Name = "Simple" IsDefault="true" Description="Get a random org label.">
<SQLScript>
<![CDATA[
		select top 1
			 dbo.fOrg#FullLabel(o.OrgSID) FullOrgLabel
		from
			dbo.Org o
		order by
			newid()
]]>
</SQLScript>
<Assertions>
	<Assertion Type="ExecutionTime" Value="00:00:02" />
</Assertions>
</Test>
</TestHarness>

------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
	 @fullOrgLabel		nvarchar(max)																					-- the full org label
	,@currentOrgSID		int																										-- next parent org SID to look up name for

	select
		 @fullOrgLabel	= o.OrgName
		,@currentOrgSID = o.ParentOrgSID
	from
		dbo.Org o
	where
		o.OrgSID = @OrgSID

	-- loop through all parent organizations
	-- and prepend the org name

	while @currentOrgSID is not null																				
	begin

		select
			 @fullOrgLabel	= o.OrgName + ' - ' + @fullOrgLabel
			,@currentOrgSID = o.ParentOrgSID
		from	
			dbo.Org o
		where
			o.OrgSID = @currentOrgSID
	end

	return @fullOrgLabel

end
GO
