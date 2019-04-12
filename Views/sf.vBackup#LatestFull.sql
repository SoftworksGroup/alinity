SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW sf.vBackup#LatestFull	
as
/*********************************************************************************************************************************
View    : Backup - Latest Full
Notice  : Copyright © 2018 Softworks Group Inc.
Summary	: Returns date-time and age (in days) of latest FULL backup for each database on the server
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Nov 2018		|	Initial version

Comments	
--------
This view is used to check for recent full-backups of the databases on the server. The view returns 1 record for each database. 
The view returns "OK" in the status label column if the backup is "recent".  Generally a full back-up is expected to occur
every 24 hours.  Test databases may not be backed up on weekends and so for databases ending in "Test" and other extensions a
time limit of 72 hours is implemented.

Limitations
-----------
On test servers the view will generate warnings for zDesign% databases and reporting server databases not backed up in more than
24 hours.  These are known not to be warning scenarios, however, the warnings are allowed to be generated to facilitate routine
checking of the view for user databases missing backups.  The warnings on the system/development databases show that the 
warning detection logic is working.

Example
-------
<TestHarness>
  <Test Name = "Default" IsDefault ="true" Description="Execute the view to return all records.">
    <SQLScript>
      <![CDATA[
select x.* from sf.vBackup#LatestFull x order by x.DBName
			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:30"/>
    </Assertions>
  </Test>  
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'sf.vBackup#LatestFull'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

select
	x.DBName
 ,x.LastBackupDate
 ,x.BackUpAgeInHours
 ,case
		when x.BackUpAgeInHours > 72 -- test DB's may not be backed over weekends so allow 72 as maximum
				 or
				 (
					 x.BackUpAgeInHours > 24 and x.DBName not like 'devV%' and right(x.DBName, 4) not in ('_STG', 'Test', 'Demo')
				 ) then 'WARNING'
		else 'OK'
	end BackupStatusCode
 ,case
		when x.BackUpAgeInHours > 72 -- test DB's may not be backed over weekends so allow 72 as maximum
				 or
				 (
					 x.BackUpAgeInHours > 24 and x.DBName not like 'devV%' and right(x.DBName, 4) not in ('_STG', 'Test', 'Demo')
				 ) then 'Database is missing a recent full backup! Most recent full backup taken ' + ltrim(x.BackUpAgeInHours) + ' hours ago.'
		else 'Database has a recent full backup (taken ' + ltrim(x.BackUpAgeInHours) + ' hours ago).'
	end BackupStatusLabel
from
(
	select
		bak.database_name																		 DBName
	 ,max(bak.backup_finish_date)													 LastBackupDate
	 ,datediff(hh, max(bak.backup_finish_date), getdate()) BackUpAgeInHours
	from
		msdb.dbo.backupset bak
	join
		sys.databases sysDB on bak.database_name = sysdb.name -- join to current DB names to avoid DB names in backup history but not on the server
	where
		bak.type = 'D'
	group by
		bak.database_name
	union
	select -- check for databases without any backup history 
		sysDB.name DBName
	 ,null			 LastBackupDate
	 ,9999			 BackupAgeInHours
	from
		sys.databases			 sysDB
	left outer join
		msdb.dbo.backupset bak on sysDB.name = bak.database_name
	where
		bak.database_name is null and sysDB.name <> 'tempdb'
) x;
GO
