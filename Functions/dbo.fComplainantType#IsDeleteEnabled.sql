SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fComplainantType#IsDeleteEnabled]
	(
	@ComplainantTypeSID int
	)
returns bit
as
/*********************************************************************************************************************************
ScalarF : dbo.fComplainantType#IsDeleteEnabled
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : Returns 1 (bit) when deletion of the record is allowed
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pIsDeleteEnabledFcnGen | Designer: Tim Edlund
Version : March 2019
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
   x.ComplainantTypeSID
  ,dbo.fComplainantType#IsDeleteEnabled(x.ComplainantTypeSID) IsDeleteEnabled
from
  dbo.ComplainantType x
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
	
	if (select x.IsDefault from dbo.ComplainantType x where x.ComplainantTypeSID = @ComplainantTypeSID) = @ON set @isDeleteEnabled = @OFF	-- default records cannot be deleted
	
	if @isDeleteEnabled = @ON																								-- check for existence of child records
	begin
	
		if
		(
			select
				  count(x01.ComplaintSID)
			from
				dbo.ComplainantType x00
			left outer join
				  (select top (1) x.ComplaintSID, x.ComplainantTypeSID from dbo.Complaint x where x.ComplainantTypeSID = @ComplainantTypeSID) x01 on x00.ComplainantTypeSID =  x01.ComplainantTypeSID
			where
				x00.ComplainantTypeSID = @ComplainantTypeSID
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
				dbo.ComplainantType x
			where
				x.ComplainantTypeSID = @ComplainantTypeSID
			) <> sf.fApplicationUserSession#UserName() set @isDeleteEnabled = sf.fIsGranted('ADMIN.BASE')
	
	end
	--! </PostCheck>
	
	return(@isDeleteEnabled)
end
GO
