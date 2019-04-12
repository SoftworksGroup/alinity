SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pOrg#SetBaseTypes
	@OrgSID			int = null		-- organization to set base types for (IsEmployer and/or IsCredentialAuthority) - null for ALL
 ,@UpdateUser nvarchar(75)	-- required: pass "SystemUser" if updating for all
as

/*********************************************************************************************************************************
Sproc   : Organization - Set Base Types
Notice  : Copyright © 2017 Softworks Group Inc.
Summary : This procedure sets the "IsEmployer" and "IsCredentialAuthority" bits
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Oct 2017		|	Initial version
				: Tim Edlund					| Dec 2018		| Added support for insurer role for organizations
 
Comments
--------
This is a utility procedure to set the "IsEmployer" and "IsCredentialAuthority" bits ON when employment records 
(dbo.RegistrantEmployment) and Registrant-Credential records are found referencing the organization record.  The procedure can be 
called for a specific Organization key value, or when left blank the values will be set for all organization records (dbo.Org).

The procedure is called from the #Insert/#Update EF sprocs of dbo.RegistrantEmployment and dbo.RegistrantCredential

Note that the procedure never turns the bits OFF.  Even when no employment/credential records exist the organization may still
need to be identified as an employer/credentialing authority for inclusion in drop-down lists on forms.  Turning off 
the bit must be done manually but a product query exists to identify organizations where one of these bits is on and no 
corresponding registrant records exist.

Example
-------
<TestHarness>
  <Test Name = "Default" IsDefault ="true" Description="Execute the procedure to update 1 organizations role settings.">
    <SQLScript>
      <![CDATA[
declare
	@orgSID	 int

select top 1 
	@orgSID = o.OrgSID
from
	dbo.Org o
order by
	newid()

exec dbo.pOrg#SetBaseTypes @OrgSID = @orgSID, @UpdateUser = 'SystemUser'

select
	o.OrgSID
 ,o.OrgName
 ,o.IsEmployer
 ,o.IsCredentialAuthority
 ,(select count(1) from dbo.RegistrantEmployment re where re.OrgSID = o.OrgSID)	EmploymentCount
 ,(select count(1) from dbo.RegistrantCredential rc where rc.OrgSID = o.OrgSID)	CredentialCount
from
	dbo.Org o
where
	o.OrgSID = @orgSID
			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:03"/>
    </Assertions>
  </Test>  
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pOrg#SetBaseTypes'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo	 int					 = 0								-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText nvarchar(4000)										-- message text for business rule errors
	 ,@ON				 bit					 = cast(1 as bit)		-- constant for bit comparisons = 1
	 ,@OFF			 bit					 = cast(0 as bit);	-- constant for bit comparison = 0

	begin try

		if isnull(@UpdateUser, 'x') = N'SystemUser'
		begin
			set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'), 75); -- override for "SystemUser"
		end

		if isnull(@UpdateUser, 'x') <> N'SystemUser'
		begin
			set @UpdateUser = sf.fApplicationUserSession#UserName(); -- application user - or DB user if no application session set
		end

		if @OrgSID is not null
		begin

			if not exists (select 1 from dbo .Org o where o.OrgSID = @OrgSID)
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'RecordNotFound'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
				 ,@Arg1 = 'dbo.Org'
				 ,@Arg2 = @OrgSID;

				raiserror(@errorText, 18, 1);
			end;
		end;

		update
			o
		set
			o.IsEmployer = case when o.IsEmployer = @ON then @ON else cast(x.EmployerCount as bit)end
		 ,o.IsCredentialAuthority = case when o.IsCredentialAuthority = @ON then @ON else cast(x.CredentialAuthorityCount as bit)end
		 ,o.UpdateUser = @UpdateUser
		 ,o.UpdateTime = sysdatetimeoffset()
		from
			dbo.Org o
		join
		(
			select
				o.OrgSID
			 ,(
					select count (1) from dbo.RegistrantEmployment re where re.OrgSID = o.OrgSID
				) EmployerCount
			 ,(
					select count (1) from dbo.RegistrantCredential rc where rc.OrgSID = o.OrgSID
				) CredentialAuthorityCount
			from
				dbo.Org o
			where
				(@OrgSID is null or o.OrgSID = @OrgSID)
		)					x on o.OrgSID = x.OrgSID
		where
			(@OrgSID is null or o.OrgSID = @OrgSID)
			and
			((x.EmployerCount						 > 0 and o.IsEmployer = @OFF) or (x.CredentialAuthorityCount > 0 and o.IsCredentialAuthority = @OFF));

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
