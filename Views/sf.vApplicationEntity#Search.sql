SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vApplicationEntity#Search]
as
/*********************************************************************************************************************************
View			: Application entity Search
Notice		: Copyright © 2018 Softworks Group Inc.
Summary		: Returns columns required for display and filtering on the business rules search screens
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Kris Dawson	| Aug 2018    |	Initial version

Comments	
--------
This view returns a sub-set of the full ApplicationEntity entity.

Example
-------
!<TestHarness>
<Test Name = "Select100" Description="Select a sample set of records from the view.">
<SQLScript>
<![CDATA[

	select top (100)
		 x.*
	from
		sf.vApplicationEntity#Search x
	order by
		newid()

]]>
</SQLScript>
<Assertions>
	<Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
	<Assertion Type="ExecutionTime" Value="00:00:05" />
</Assertions>
</Test>
!</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.vApplicationEntity#Search'

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 ae.ApplicationEntitySID
	,ae.ApplicationEntitySCD
	,ae.ApplicationEntityName
	,isnull(zbr.BusinessRuleCount,0)                                        BusinessRuleCount
	,isnull(zbre.BusinessRuleErrorCount,0)                                  BusinessRuleErrorCount
	,cast
  (
    case							
      when zbre.BusinessRuleErrorCount  > 0   then 'e'										-- errors exist from last check
      else                                         'v'										-- entity is verified
    end
    as char(1)
  )                                                                       DataStatus		
	,zt.[Description]                                                       BaseTableDescription
from
	sf.ApplicationEntity ae
left outer join
  sf.vTable zt					 on ae.ApplicationEntitySCD = zt.SchemaAndTableName                         -- provides relationship to the base table of the entity
left outer join
  (
  select
     y.ApplicationEntitySID
    ,isnull(count(1),0)                                                   BusinessRuleErrorCount    -- all errors for the entity
  from
    sf.BusinessRuleError x
  join
    sf.BusinessRule       y on x.BusinessRuleSID = y.BusinessRuleSID
  group by
    y.ApplicationEntitySID
  ) zbre on ae.ApplicationEntitySID = zbre.ApplicationEntitySID
left outer join
  (
  select
     x.ApplicationEntitySID                                                                         -- counts of rules by type
    ,sum(case when x.BusinessRuleStatus = 'p'  or x.BusinessRuleStatus = '!'
        then 1 else 0  end)                                               PendingBusinessRuleCount  -- include "in-process" in pending count
    ,sum(case when m.MessageSCD like 'CBR.%' then 1 else 0  end)          ClientBusinessRuleCount   -- client-specific rule count
    ,sum(case when m.MessageSCD like 'MBR.%' then 1 else 0  end)     MandatoryBusinessRuleCount
    ,sum
	 (
      case when m.MessageSCD not like 'CBR.%' and m.MessageSCD not like 'MBR.%'
      then 1 else 0  end
   )         OptionalBusinessRuleCount
    ,count(1)                                                             BusinessRuleCount
  from
    sf.BusinessRule x  join
    sf.[Message]    m on x.MessageSID = m.MessageSID
  group by
    x.ApplicationEntitySID
  ) zbr on ae.ApplicationEntitySID = zbr.ApplicationEntitySID
GO
