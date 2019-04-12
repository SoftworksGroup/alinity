SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sf.pDBSpace#SummaryXML
as
/*********************************************************************************************************************************
Sproc    : DB Space - Summary XML (Statistics)
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : This procedure returns statistics information on disk space available for the database including warning text
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + -----------------------------------------------------------------------------------
 				: Tim Edlund          | Nov 2018		|	Initial version

Comments
--------
This procedure function summarizes results from sf.vDBSpace view as statistics for display in dashboard widgets
and reports.  The output format is XML.  See base view for detailed explanation of logic applied.

The procedure includes Message-Text and a Message-Icon where disk space is limited.  The threshold is defined
by a combination of % Available in any file group and an absolute amount of megabytes remaining.  See the
sf.vDBSpace#Warning view for details. If a threshold is not hit, the message/icon columns are not returned in the 
XML.

Maintenance note
----------------
This procedure includes a hard-coded list of space "Category" values expected from the sf.vDBSpace view.  If
the view does not return these values, either because of logic changes or because non-SGI-standard file
groups have been deployed, the statistics returned will not be accurate.  To check that all stats are being
reported, compare results with:

select
	x.*
from
	sf.vDBSpace x

Example
-------
<TestHarness>
  <Test Name = "Default" IsDefault ="true" Description="Executes the procedure to return XML document for current DB">
    <SQLScript>
      <![CDATA[
	exec sf.pDBSpace#SummaryXML
		]]>
    </SQLScript>
    <Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1" />
      <Assertion Type="ExecutionTime" Value="00:00:05"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.pDBSpace#SummaryXML'
 ,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare @errorNo int = 0; -- 0 no error, <50000 SQL error, else business rule

	begin try

		-- return summarized content as an XML document

		select
			Stats.MessageText
		 ,Stats.MessageIcon
		 ,StatGroup.Label
		 ,Stat.Label
		 ,cast(isnull(x.Value, 0) as decimal(4,1)) Value
		from
		(select 'All' Label) StatGroup
		cross apply
		(
			select
				'Base Storage' Label
			union
			select
				'Documents' Label
			union
			select
				'Free' Label
		)										 Stat
		left outer join
		(select dbsp.Category Label, dbsp.SpaceInGB Value from sf.vDBSpace dbsp)	 x on Stat.Label = x.Label
		outer apply
		(select dbsw.MessageText, dbsw.MessageIcon from sf.vDBSpace#Warning dbsw) Stats
		for xml auto, type;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
