SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fRegistrant#HasOpenAudit]
(
	 @RegistrantSID									int																			-- primary key of Registrant to check
)
returns bit
as
/*********************************************************************************************************************************
TableF	: Registrant - Has Open Audit
Notice  : Copyright © 2017 Softworks Group Inc.
Summary	: Checks a registrant to determine if an audit is currently open for them 
-----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)				| Month Year  | Change Summary
				 : ----------------	|	----------	| --------------
				 : Tim Edlund				| May 2017    | Initial version
-----------------------------------------------------------------------------------------------------------------------------------
Comments

The function is called by the UI to establish whether an audit is currently open for the registrant. If it is, an icon
reflecting the fact is typically displayed.  Note that this function is designed to return the results quickly and does not 
provide details on the type of audit - or even if multiple audits are open.

<TestHarness>
	<Test Name = "Simple" Description="Returns open audit results for 10 registrants selected at random.">
	<SQLScript>
	<![CDATA[

		select top 100
			 r.RegistrantSID
			,dbo.fRegistrant#HasOpenAudit(r.RegistrantSID)												HasOpenAudit
		from 
			dbo.Registrant r

	]]>
	</SQLScript>
	<Assertions>
		<Assertion Type="ExecutionTime" Value="00:00:01" />
	</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.fRegistrant#HasOpenAudit'

------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		 @hasOpenAudit									bit																		-- return value
		,@ON														bit				= cast(1 as bit)						-- used on bit comparisons to avoid multiple casts
		,@OFF														bit				= cast(0 as bit)						-- used on bit comparisons to avoid multiple casts

	select	
		@hasOpenAudit = cast(isnull(count(1),0) as bit)	
	from
		dbo.Registrant											reg
	join
		dbo.RegistrantAudit									ra on reg.RegistrantSID = ra.RegistrantSID
	cross apply
		dbo.fRegistrantAudit#CurrentStatus(ra.RegistrantAuditSID, -1)	cs 
	where
		reg.RegistrantSID = @RegistrantSID
	and
		isnull(cs.IsFinal, @OFF) = @OFF

	return(@hasOpenAudit)

end
GO
