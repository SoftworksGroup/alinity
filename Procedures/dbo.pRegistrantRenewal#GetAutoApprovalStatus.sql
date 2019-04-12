SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrantRenewal#GetAutoApprovalStatus]
	@RegistrantRenewalSID int -- key of the renewal to get auto-approval status for
as
/*********************************************************************************************************************************
Sproc    : Registrant Renewal - Get Auto Approval Status
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : This procedure is a wrapper for the table function dbo.fRegistrantRenewal#AutoApprovalStatus
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)				| Month Year | Change Summary
				 : ---------------- | -----------|----------------------------------------------------------------------------------------
				 : Tim Edlund				| Oct 2017 	 | Initial version.
----------------------------------------------------------------------------------------------------------------------------------
 
Comments
--------
This procedure is a wrapper for the table function dbo.fRegistrantRenewal#AutoApprovalStatus. It allows the same data returned
by the function to be processed through an import to the Entity Framework layer in the UI tier.

Known Limitations
-----------------
When the structure of the data returned by the function changes, the select list in this procedure must be updated manually.
Column tagging regeneration does not work with table-value functions.

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Gets the auto approval status for a random renewal.">
		<SQLScript>
		<![CDATA[

			declare @registrantRenewalSID int;

      select top 1
	      @registrantRenewalSID = rr.RegistrantRenewalSID
      from
	      dbo.RegistrantRenewal rr
      order by
	      newid();

      exec dbo.pRegistrantRenewal#GetAutoApprovalStatus 
	      @RegistrantRenewalSID = @registrantRenewalSID

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pRegistrantRenewal#GetAutoApprovalStatus'
	,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */
set nocount on;

begin
	declare
		@errorNo	 int					 = 0							-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText nvarchar(4000)									-- message text for business rule errors

	begin try

		-- check parameters

		if @RegistrantRenewalSID is null
		begin
			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = '@RegistrantRenewalSID';

			raiserror(@errorText, 18, 1);
		end;

		select
			aas.RegistrantRenewalSID
		 ,aas.RegistrantSID
		 ,aas.RegistrationYear
		 ,aas.FormStatusSID
		 ,aas.FormStatusSCD
		 ,aas.FormStatusLabel
		 ,aas.FormOwnerSCD
		 ,aas.FormOwnerLabel
		 ,aas.FormIsFinal
		 ,aas.CreateUser
		 ,aas.CreateTime
		 ,aas.InvoiceSID
		 ,aas.IsRenewalAutoApprovalBlocked
		 ,aas.IsAutoApprovalEnabled
		 ,aas.HasOpenAudit
		 ,aas.RenewalEndTime
		 ,aas.ReasonSID
		 ,aas.ReasonCode
		 ,aas.ReasonName
		 ,aas.SystemReasonCode
		 ,aas.IsAutoApprovalPending
		from
			dbo.fRegistrantRenewal#AutoApprovalStatus(@RegistrantRenewalSID) aas;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
