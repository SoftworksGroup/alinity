SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW sf.vDataSource#Summary
as
/*********************************************************************************************************************************
View		: DataSource - Summary
Notice  : Copyright © 2018 Softworks Group Inc.
Summary	: Returns a record per data source summarizing the content it provides and location in the user interface
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund	| Aug 2018			|	Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This view is intended primarily to support reporting the available data sources in the system.  The view returns all data sources
which exist in the sf.DataSource table although most are not accessible unless the Database Management module is licensed. The
view also returns the name of the screen where the data source can be accessed.

Example
-------
<TestHarness>
  <Test Name = "All" IsDefault ="true" Description="Returns all content from the view">
    <SQLScript>
      <![CDATA[
select
	dss.DataSourceLabel [Data source]
 ,dss.DBObjectName		[View name]
 ,dss.ToolTip					Description
 ,dss.LastExecuted		[Last used]
 ,dss.LastExecuteUser [Last used by]
 ,dss.PageList				[Appears on]
from
	sf.vDataSource#Summary dss
order by
	dss.DataSourceLabel;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:05"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'sf.vDataSource#Summary'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

select
	ds.DataSourceSID
 ,ds.DataSourceLabel																				-- Data source
 ,ds.DBObjectName																						-- View name
 ,ds.ToolTip																								-- Description
 ,sf.fDTOffsetToClientDate(ds.LastExecuteTime) LastExecuted -- Last used
 ,ds.LastExecuteUser																				-- Last used by
 ,case
		when lic.IsLicensedForDBManagement = cast(1 as bit) then pgs.PageList
		when charindex(',', pgs.PageList) > 0 then replace(replace(pgs.PageList, ', Table management', ''), 'Table management,', '')
		else '[Requires DB Management Module]'
	end																					 PageList			-- Appears on
from
	sf.DataSource ds
left outer join
(
	select
		cast(count(1) as bit) IsLicensedForDBManagement
	from
		sf.vLicense#Module lm
	where
		lm.ModuleSCD = 'DBMANAGEMENT' and lm.TotalLicenses > 0
)								lic on 1 = 1
outer apply
(
	select
		substring((
								select
									', ' + ap.ApplicationPageLabel as [text()]
								from
									sf.DataSourceApplicationPage dsap
								join
									sf.ApplicationPage					 ap on dsap.ApplicationPageSID = ap.ApplicationPageSID
								where
									dsap.DataSourceSID = ds.DataSourceSID
								order by
									ap.ApplicationPageLabel
								for xml path('')
							)
							,3
							,1000
						 ) PageList
)								pgs;
GO
