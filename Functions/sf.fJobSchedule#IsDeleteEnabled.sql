SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [sf].[fJobSchedule#IsDeleteEnabled]
	(
	@JobScheduleSID int
	)
returns bit
as
/*********************************************************************************************************************************
ScalarF : sf.fJobSchedule#IsDeleteEnabled
Notice  : Copyright © 2018 Softworks Group Inc.
Summary : Returns 1 (bit) when deletion of the record is allowed
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pIsDeleteEnabledFcnGen | Designer: Tim Edlund
Version : May 2018
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------

The function is called by the entity view to set a calculated bit column "IsDeleteEnabled". The column is typically bound to a
delete button on the UI.  The results of the function determine whether or not deletion should be allowed.  The function tests
one or more of the following factors: 1) whether the table contains a system code column in which case deletion is
not allowed, 2) the security granted to the logged in user, and, 3) the existence of child records.

When a child table is related through a foreign key with cascade delete, and all descendants of that table are also related with
cascade delete constraints, then the child table is not considered blocking and will not appear in the SELECT statement.

Table-specific logic can be added through tagged sections (pre and post check). An extended version of the function is not
supported.  Code implemented within code tags is part of the base product and applies to all client configurations.

Example
-------

select top (10)
   x.JobScheduleSID
  ,sf.fJobSchedule#IsDeleteEnabled(x.JobScheduleSID) IsDeleteEnabled
from
  sf.JobSchedule x
order by
  newid()

-------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		 @isDeleteEnabled                 bit																	-- return value
		,@ON                              bit = cast(1 as bit)								-- constant to eliminate repetitive casting syntax
		,@OFF                             bit = cast(0 as bit)								-- constant to eliminate repetitive casting syntax
	
	set @isDeleteEnabled = @ON																							-- set return value to ON then check for blocking conditions
	
	--! <PreCheck>
	--  insert pre-check logic here ...
	--! </PreCheck>
	
	if @isDeleteEnabled = @ON																								-- check for existence of child records
	begin
	
		if
		(
			select
				  count(x01.EmailTriggerSID)
				+ count(x02.ExportJobSID)
				+ count(x03.JobSID)
				+ count(x04.TaskTriggerSID)
				+ count(x05.TextTriggerSID)
			from
				sf.JobSchedule  x00
			left outer join
				  (select top (1) x.EmailTriggerSID, x.JobScheduleSID from sf.EmailTrigger x where isnull(x.JobScheduleSID, -1) = @JobScheduleSID) x01 on x00.JobScheduleSID =  x01.JobScheduleSID
			left outer join
				  (select top (1) x.ExportJobSID, x.JobScheduleSID from sf.ExportJob x where isnull(x.JobScheduleSID, -1) = @JobScheduleSID) x02 on x00.JobScheduleSID =  x02.JobScheduleSID
			left outer join
				  (select top (1) x.JobSID, x.JobScheduleSID from sf.Job x where isnull(x.JobScheduleSID, -1) = @JobScheduleSID) x03 on x00.JobScheduleSID =  x03.JobScheduleSID
			left outer join
				  (select top (1) x.TaskTriggerSID, x.JobScheduleSID from sf.TaskTrigger x where isnull(x.JobScheduleSID, -1) = @JobScheduleSID) x04 on x00.JobScheduleSID =  x04.JobScheduleSID
			left outer join
				  (select top (1) x.TextTriggerSID, x.JobScheduleSID from sf.TextTrigger x where isnull(x.JobScheduleSID, -1) = @JobScheduleSID) x05 on x00.JobScheduleSID =  x05.JobScheduleSID
			where
				x00.JobScheduleSID = @JobScheduleSID
		) > 0 set @isDeleteEnabled = @OFF
		
	end
	
	--! <PostCheck>
	if @isDeleteEnabled = @ON																								-- block unless current user inserted the row or is an administrator
	begin
	
		if
		(
			select
				x.CreateUser
			from
				sf.JobSchedule x
			where
				x.JobScheduleSID = @JobScheduleSID
			) <> sf.fApplicationUserSession#UserName() set @isDeleteEnabled = sf.fIsGranted('ADMIN.BASE')
	
	end
	--! </PostCheck>
	
	return(@isDeleteEnabled)
end

GO
