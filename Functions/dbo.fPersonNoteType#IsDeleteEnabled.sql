SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fPersonNoteType#IsDeleteEnabled]
	(
	@PersonNoteTypeSID int
	)
returns bit
as
/*********************************************************************************************************************************
ScalarF : dbo.fPersonNoteType#IsDeleteEnabled
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : Returns 1 (bit) when deletion of the record is allowed
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pIsDeleteEnabledFcnGen | Designer: Tim Edlund
Version : April 2019
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
   x.PersonNoteTypeSID
  ,dbo.fPersonNoteType#IsDeleteEnabled(x.PersonNoteTypeSID) IsDeleteEnabled
from
  dbo.PersonNoteType x
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
	
	if (select x.IsDefault from dbo.PersonNoteType x where x.PersonNoteTypeSID = @PersonNoteTypeSID) = @ON set @isDeleteEnabled = @OFF-- default records cannot be deleted
	
	if @isDeleteEnabled = @ON																								-- check for existence of child records
	begin
	
		if
		(
			select
				  count(x01.PersonNoteSID)
			from
				dbo.PersonNoteType x00
			left outer join
				  (select top (1) x.PersonNoteSID, x.PersonNoteTypeSID from dbo.PersonNote x where x.PersonNoteTypeSID = @PersonNoteTypeSID) x01 on x00.PersonNoteTypeSID =  x01.PersonNoteTypeSID
			where
				x00.PersonNoteTypeSID = @PersonNoteTypeSID
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
				dbo.PersonNoteType x
			where
				x.PersonNoteTypeSID = @PersonNoteTypeSID
			) <> sf.fApplicationUserSession#UserName() set @isDeleteEnabled = sf.fIsGranted('ADMIN.BASE')
	
	end
	--! </PostCheck>
	
	return(@isDeleteEnabled)
end
GO
