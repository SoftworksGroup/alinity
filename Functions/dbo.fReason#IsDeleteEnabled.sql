SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fReason#IsDeleteEnabled]
	(
	@ReasonSID int
	)
returns bit
as
/*********************************************************************************************************************************
ScalarF : dbo.fReason#IsDeleteEnabled
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
   x.ReasonSID
  ,dbo.fReason#IsDeleteEnabled(x.ReasonSID) IsDeleteEnabled
from
  dbo.Reason x
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
				  count(x01.ComplaintSID)
				+ count(x02.InvoiceSID)
				+ count(x03.InvoiceItemSID)
				+ count(x04.InvoicePaymentSID)
				+ count(x05.PaymentSID)
				+ count(x06.ProfileUpdateSID)
				+ count(x07.RegistrantAppSID)
				+ count(x08.RegistrantAppReviewSID)
				+ count(x09.RegistrantAuditSID)
				+ count(x10.RegistrantAuditReviewSID)
				+ count(x11.RegistrantLearningPlanSID)
				+ count(x12.RegistrantRenewalSID)
				+ count(x13.RegistrationSID)
				+ count(x14.RegistrationChangeSID)
				+ count(x15.ReinstatementSID)
			from
				dbo.Reason                 x00
			left outer join
				  (select top (1) x.ComplaintSID, x.ReasonSID from dbo.Complaint x where isnull(x.ReasonSID, -1) = @ReasonSID) x01 on x00.ReasonSID =  x01.ReasonSID
			left outer join
				  (select top (1) x.InvoiceSID, x.ReasonSID from dbo.Invoice x where isnull(x.ReasonSID, -1) = @ReasonSID) x02 on x00.ReasonSID =  x02.ReasonSID
			left outer join
				  (select top (1) x.InvoiceItemSID, x.ReasonSID from dbo.InvoiceItem x where isnull(x.ReasonSID, -1) = @ReasonSID) x03 on x00.ReasonSID =  x03.ReasonSID
			left outer join
				  (select top (1) x.InvoicePaymentSID, x.ReasonSID from dbo.InvoicePayment x where isnull(x.ReasonSID, -1) = @ReasonSID) x04 on x00.ReasonSID =  x04.ReasonSID
			left outer join
				  (select top (1) x.PaymentSID, x.ReasonSID from dbo.Payment x where isnull(x.ReasonSID, -1) = @ReasonSID) x05 on x00.ReasonSID =  x05.ReasonSID
			left outer join
				  (select top (1) x.ProfileUpdateSID, x.ReasonSID from dbo.ProfileUpdate x where isnull(x.ReasonSID, -1) = @ReasonSID) x06 on x00.ReasonSID =  x06.ReasonSID
			left outer join
				  (select top (1) x.RegistrantAppSID, x.ReasonSID from dbo.RegistrantApp x where isnull(x.ReasonSID, -1) = @ReasonSID) x07 on x00.ReasonSID =  x07.ReasonSID
			left outer join
				  (select top (1) x.RegistrantAppReviewSID, x.ReasonSID from dbo.RegistrantAppReview x where isnull(x.ReasonSID, -1) = @ReasonSID) x08 on x00.ReasonSID =  x08.ReasonSID
			left outer join
				  (select top (1) x.RegistrantAuditSID, x.ReasonSID from dbo.RegistrantAudit x where isnull(x.ReasonSID, -1) = @ReasonSID) x09 on x00.ReasonSID =  x09.ReasonSID
			left outer join
				  (select top (1) x.RegistrantAuditReviewSID, x.ReasonSID from dbo.RegistrantAuditReview x where isnull(x.ReasonSID, -1) = @ReasonSID) x10 on x00.ReasonSID =  x10.ReasonSID
			left outer join
				  (select top (1) x.RegistrantLearningPlanSID, x.ReasonSID from dbo.RegistrantLearningPlan x where isnull(x.ReasonSID, -1) = @ReasonSID) x11 on x00.ReasonSID =  x11.ReasonSID
			left outer join
				  (select top (1) x.RegistrantRenewalSID, x.ReasonSID from dbo.RegistrantRenewal x where isnull(x.ReasonSID, -1) = @ReasonSID) x12 on x00.ReasonSID =  x12.ReasonSID
			left outer join
				  (select top (1) x.RegistrationSID, x.ReasonSID from dbo.Registration x where isnull(x.ReasonSID, -1) = @ReasonSID) x13 on x00.ReasonSID =  x13.ReasonSID
			left outer join
				  (select top (1) x.RegistrationChangeSID, x.ReasonSID from dbo.RegistrationChange x where isnull(x.ReasonSID, -1) = @ReasonSID) x14 on x00.ReasonSID =  x14.ReasonSID
			left outer join
				  (select top (1) x.ReinstatementSID, x.ReasonSID from dbo.Reinstatement x where isnull(x.ReasonSID, -1) = @ReasonSID) x15 on x00.ReasonSID =  x15.ReasonSID
			where
				x00.ReasonSID = @ReasonSID
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
				dbo.Reason x
			where
				x.ReasonSID = @ReasonSID
			) <> sf.fApplicationUserSession#UserName() set @isDeleteEnabled = sf.fIsGranted('ADMIN.BASE')
	
	end
	--! </PostCheck>
	
	return(@isDeleteEnabled)
end
GO
