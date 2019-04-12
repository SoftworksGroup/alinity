SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fPersonDocContext#HasPrimary]
(
	@EntitySID						int -- primary key of form record to check for document existence (e.g. RegistrantAuditSID)
 ,@ApplicationEntitySCD varchar(50) -- schema.tablename of entity for the context (e.g. 'dbo.RegistantAudit')
)
returns bit
as
/*********************************************************************************************************************************
TableF	: Person Document Context -  Has Primary Document
Notice  : Copyright © 2017 Softworks Group Inc.
Summary	: Checks the person document context table to check for existence of the primary document
-----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)				| Month Year  | Change Summary
				 : ----------------	|	----------	| --------------
				 : Tim Edlund				| Nov 2017    | Initial version
-----------------------------------------------------------------------------------------------------------------------------------
Comments

The function is called by form entity views and search sprocs to determine if the final PDF document for the form has been
generated. The key of the form record and the schema.tablename for the entity must be provided.

<TestHarness>
	<Test Name = "Simple" Description="Returns PDF exist results for 1000 renewals selected at random.">
	<SQLScript>
	<![CDATA[

select top 1000
	rr.RegistrantRenewalSID
 ,dbo.fPersonDocContext#HasPrimary(rr.RegistrantRenewalSID, 'dbo.RegistrantRenewal') HasPrimary
from
	dbo.RegistrantRenewal rr

	]]>
	</SQLScript>
	<Assertions>
		<Assertion Type="ExecutionTime" Value="00:00:01" />
	</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.fPersonDocContext#HasPrimary'

------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		@hasPrimary bit										-- return value
	 ,@ON					bit = cast(1 as bit)	-- used on bit comparisons to avoid multiple casts
	 ,@OFF				bit = cast(0 as bit); -- used on bit comparisons to avoid multiple casts

	select
		@hasPrimary = cast(isnull(count(1), 0) as bit)
	from
		dbo.PersonDocContext pdc
	where
		pdc.EntitySID								 = @EntitySID and pdc.IsPrimary = @ON -- search for primary document type for the entity only
		and pdc.ApplicationEntitySID =
		(
			select
				ae.ApplicationEntitySID
			from
				sf.ApplicationEntity ae
			where
				ae.ApplicationEntitySCD = @ApplicationEntitySCD
		);

	return (@hasPrimary);

end;
GO
