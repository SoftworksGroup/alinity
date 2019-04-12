SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fInvoiceItem#IsDeleteEnabled]
	(
	@InvoiceItemSID int
	)
returns bit
as
/*********************************************************************************************************************************
ScalarF : dbo.fInvoiceItem#IsDeleteEnabled
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
   x.InvoiceItemSID
  ,dbo.fInvoiceItem#IsDeleteEnabled(x.InvoiceItemSID) IsDeleteEnabled
from
  dbo.InvoiceItem x
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
	-- Tim Edlund | Mar 2019
	-- Always block deletion of invoice lines which contain the late fee. To waive the
	-- late fee, the administrator must put in an adjustment.  Otherwise, when the late
	-- fee procedure runs again, it will re-add the fee.

	if exists
	(
		select
			1
		from
			dbo.InvoiceItem ii
		join
			dbo.CatalogItem ci on ii.CatalogItemSID = ci.CatalogItemSID and ci.IsLateFee = @ON
		where
			ii.InvoiceItemSID = @InvoiceItemSID
	)
	begin
		set @isDeleteEnabled = @OFF;
	end;
	--! </PreCheck>
	
	--! <PostCheck>
	if @isDeleteEnabled = @ON -- block unless current user inserted the row or is an administrator
	begin

		if
		(
			select
				x.CreateUser
			from
				dbo.InvoiceItem x
			where
				x.InvoiceItemSID = @InvoiceItemSID
		) <> sf.fApplicationUserSession#UserName()
			set @isDeleteEnabled = sf.fIsGranted('admin.base');

	end;
	--! </PostCheck>
	
	return(@isDeleteEnabled)
end
GO
