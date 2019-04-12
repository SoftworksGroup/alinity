SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW sf.vFileSpace
as
/*********************************************************************************************************************************
View    : File Space
Notice  : Copyright © 2017 Softworks Group Inc.
Summary	: Returns details of files in each file group including space allocated, used and remaining
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + -----------------------------------------------------------------------------------
 				: Tim Edlund          | May 2017		|	Initial version
				: Tim Edlund					| Aug 2018		| Implemented override for PRIMARY file group name and re-ordered columns
				: Tim Edlund					| Nov 2018		| Implemented overrides to standard file group names to make more user friendly.
				: Tim Edlund					| Jan 2019		| Increased decimal buffer from 5 to 7 digits (supports up to 10 terabytes)
---------------------------------------------------------------------------------------------------------------------------------
Warning: This view is verified for SQL Server 2008 R2 through SQL 2014. Deployment on other versions may fail!
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This view returns details of space usage in physical files.  The space available for data in files is calculated as the space 
remaining in files up to the maximum size allowed for that file.  The current physical file is typically less than the maximum
size enabled on the file.  The view is intended for use in monitoring space available for data growth on a database.  Note that 
because a file may have growth remaining before hitting the maximum allocation does not mean the space is available on disk.  
The available disk space must also be checked to ensure file expansion is possible.

The Softworks standard for file sizing is NOT to allow unrestricted growth in files.  Where unrestricted growth is enabled on a 
file no information is returned on allocated size and percentage utilization.

Compatibility with other SQL Server versions
--------------------------------------------
This object references "sys" (system) views because of complexities in referencing system functions - like object_id() - in 
deployments for target databases.  Microsoft does not guarantee that sys view definitions will be compatible in SQL Server 
upgrades.  This view may not deploy successfully on databases other than the database version identified above.

Example
-------
!<TestHarness>
<Test Name = "Select" Description="Select all records from the view.">
<SQLScript>
<![CDATA[
select 
	* 
from 
	sf.vFileSpace fs
order by 
	1, 2
	
]]>
</SQLScript>
<Assertions>
	<Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
	<Assertion Type="ExecutionTime" Value="00:00:03" />
</Assertions>
</Test>
!</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.vFileSpace'
------------------------------------------------------------------------------------------------------------------------------- */

with
f
as
(
select
	fg.data_space_id
 ,f.file_id
 ,fg.name						 filegroup_name
 ,f.name						 logical_name
 ,f.physical_name
 ,f.size / 128.0		 size
 ,f.max_size / 128.0 max_size
from
	sys.database_files f
left outer join
	sys.filegroups		 fg on f.data_space_id = fg.data_space_id)
,
s
as
(select
		f.data_space_id
	,f.file_id
	,f.filegroup_name
	,f.physical_name
	,f.logical_name
	,f.size
	,f.max_size
	,convert(int, fileproperty(f.logical_name, 'spaceused')) / 128.0						used
	,max_size - convert(int, fileproperty(f.logical_name, 'spaceused')) / 128.0 free
 from
		f)
select
	x.DataSpaceID
 ,x.FileID
 ,x.FileGroup
 ,x.LogicalFileName
 ,x.FileName
 ,x.FilePath
 ,x.MaxFileSize
 ,x.CurrentFileSize
 ,(case when FileGroup = 'FileStreamData' then x.CurrentFileSize else x.UsedSpace end)												UsedSpace
 ,(case when FileGroup = 'FileStreamData' then (x.MaxFileSize - x.CurrentFileSize) else x.AvailableSpace end) AvailableSpace
 ,(case
		 when FileGroup = 'FileStreamData' then cast(round(((x.MaxFileSize - x.CurrentFileSize) / x.MaxFileSize) * 100.0, 1) as decimal(4, 1))
		 else x.PercentAvailable
	 end
	)																																																						PercentAvailable
from
(
	select
		isnull(data_space_id, 999)																																					 DataSpaceID
	 ,file_id																																															 FileID
	 ,logical_name																																												 LogicalFileName
	 ,physical_name																																												 FileName
	 ,left(physical_name, sf.fCharIndexLast('\', physical_name))																					 FilePath
	 ,cast((case when max_size < 0 then null else round(max_size, 0) end) as decimal(7, 0))								 MaxFileSize
	 ,cast(round(size, 0) as decimal(7, 0))																																 CurrentFileSize
	 ,cast(round(used, 0) as decimal(7, 0))																																 UsedSpace
	 ,cast((case when max_size < 0 then null else round(free, 0) end) as decimal(7, 0))										 AvailableSpace
	 ,cast((case when max_size < 0 then null else round(free * 100.0 / max_size, 1) end) as decimal(4, 1)) PercentAvailable
	 ,(case
			 when s.filegroup_name is null then 'Log'
			 when s.filegroup_name = 'PRIMARY' then 'System'
			 when s.filegroup_name = 'ApplicationIndexData' then 'Base Indexes'
			 when s.filegroup_name = 'ApplicationRowData' then 'Base Data'
			 when s.filegroup_name = 'FileStreamData' then 'Document Data'
			 when s.filegroup_name = 'FullTextIndexData' then 'Document Indexes'
			 else s.filegroup_name
		 end
		)																																																		 FileGroup
	from
		s
) x;
GO
