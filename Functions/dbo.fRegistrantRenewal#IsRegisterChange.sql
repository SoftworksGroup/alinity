SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fRegistrantRenewal#IsRegisterChange] (@RegistrantRenewalSID int)
returns bit
as
/*********************************************************************************************************************************
ScalarF : Registrant Renewal - Is Register Change
Notice  : Copyright © 2017 Softworks Group Inc.
Summary : Returns 1 (bit) when the register the renewal is being made to is differen than the current registration
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-------------------------------------------------------------------------------------------
					: Tim Edlund  | Sep 2017		|	Initial version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------

The function is used in various locations in the renewal process to determine if a Register Change is being made. The register on 
the registration associated with the renewal is compared to the register the renewal is being made under.  If the register is changing, 
then 1 is returned.

Example
-------
<TestHarness>
	<Test Name="DifferentRegister" Description="Should be register change">
		<SQLScript>
			<![CDATA[
		declare
				@registrationSID								int
			,	@PracticeRegisterSectionSID					int
			,	@CurrentPracticeRegisterSID					int
			,	@FormVersionSID											int
			, @RegistrationYear										int

			,	@RegistrantRenewalSID								int
			,	@FormOwnerSID												int

		begin tran

		select top 1
				@registrationSID					= rl.RegistrationSID
			,	@CurrentPracticeRegisterSID		= prs.PracticeRegisterSID
		from
			dbo.Registration rl
		join
			dbo.PracticeRegisterSection prs on rl.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID

			select top 1
			 @PracticeRegisterSectionSID  = prs.PracticeRegisterSectionSID
			from
			 dbo.PracticeRegisterSection prs 
			join
				dbo.PracticeRegister pr on pr.PracticeRegisterSID = prs.PracticeRegisterSID and pr.IsActive = cast(1 as bit)
			where
			 prs.PracticeRegisterSID <> @CurrentPracticeRegisterSID
			and
				prs.IsActive = cast ( 1 as bit)
			order by
			 newid()

		select top 1
			@FormVersionSID = fv.FormVersionSID
		from
			sf.FormVersion fv

		select top 1
			@FormOwnerSID = fo.FormOwnerSID
		from
			sf.FormOwner fo

		select
			@RegistrationYear = year(sf.fNow())


		insert into dbo.RegistrantRenewal
		(
				RegistrationSID
			, RegistrationYear
			, PracticeRegisterSectionSID
			,	FormResponseDraft
			,	AdminComments
			, FormVersionSID
		)
		select
				@registrationSID
			,	@RegistrationYear
			,	@PracticeRegisterSectionSID 
			, N'<FormResponses></FormResponses>'
			, N'<Comments></Comments>'
			, @FormVersionSID 

		set @RegistrantRenewalSID = SCOPE_IDENTITY()

		select
			dbo.fRegistrantRenewal#IsRegisterChange(@RegistrantRenewalSID)

		if @@ROWCOUNT = 0 raiserror( N'* ERROR: no sample data found to run test', 18, 1)
		if @@trancount > 0 rollback

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1" />
			<Assertion Type="ScalarValue" ResultSet="1" Column="1" Row="1" Value="True" />
			<Assertion Type="ExecutionTime" Value="00:00:02"/>
		</Assertions>
	</Test>
	<Test Name="SameRegister" IsDefault="1" Description="Should not be a register change">
		<SQLScript>
			<![CDATA[
			
			declare
					@registrationSID								int
				,	@PracticeRegisterSectionSID					int
				,	@CurrentPracticeRegisterSID					int
				,	@FormVersionSID											int
				, @RegistrationYear										int

				,	@RegistrantRenewalSID								int
				,	@FormOwnerSID												int

			begin tran

			select top 1
					@registrationSID								= rl.RegistrationSID
				,	@CurrentPracticeRegisterSID = prs.PracticeRegisterSID
			from
				dbo.Registration rl
			join
				dbo.PracticeRegisterSection prs on rl.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID


			select top 1
			 @PracticeRegisterSectionSID  = prs.PracticeRegisterSectionSID
			from
			 dbo.PracticeRegisterSection prs 
			join
				dbo.PracticeRegister pr on pr.PracticeRegisterSID = prs.PracticeRegisterSID and pr.IsActive = cast(1 as bit)
			where
			 prs.PracticeRegisterSID = @CurrentPracticeRegisterSID
			and
				prs.IsActive = cast ( 1 as bit)
			order by
			 newid()

			select top 1
				@FormVersionSID = fv.FormVersionSID
			from
				sf.FormVersion fv

			select top 1
				@FormOwnerSID = fo.FormOwnerSID
			from
				sf.FormOwner fo

			select
				@RegistrationYear = year(sf.fNow())


			insert into dbo.RegistrantRenewal
			(
					RegistrationSID
				, RegistrationYear
				, PracticeRegisterSectionSID
				,	FormResponseDraft
				,	AdminComments
				, FormVersionSID
			)
			select
					@registrationSID
				,	@RegistrationYear
				,	@PracticeRegisterSectionSID 
				, N'<FormResponses></FormResponses>'
				, N'<Comments></Comments>'
				, @FormVersionSID 

			set @RegistrantRenewalSID = SCOPE_IDENTITY()

			select
				dbo.fRegistrantRenewal#IsRegisterChange(@RegistrantRenewalSID)

			if @@ROWCOUNT = 0 raiserror( N'* ERROR: no sample data found to run test', 18, 1)
			if @@trancount > 0 rollback

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1" />
			<Assertion Type="ScalarValue" ResultSet="1" Column="1" Row="1" Value="False" />
			<Assertion Type="ExecutionTime" Value="00:00:02"/>
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
  @ObjectName = 'dbo.fRegistrantRenewal#IsRegisterChange'
 ,@DefaultTestOnly = 1

-------------------------------------------------------------------------------------------------------------------------------- */
begin

	declare @isRegisterChange bit = cast(0 as bit); -- return value

	select
		@isRegisterChange = case when prR.PracticeRegisterSID <> prL.PracticeRegisterSID then cast(1 as bit)else @isRegisterChange end
	from
		dbo.RegistrantRenewal				rr
	join
		dbo.PracticeRegisterSection prsR on rr.PracticeRegisterSectionSID = prsR.PracticeRegisterSectionSID
	join
		dbo.PracticeRegister				prR on prsR.PracticeRegisterSID				= prR.PracticeRegisterSID
	join
		dbo.Registration				rl on rr.RegistrationSID					= rl.RegistrationSID
	join
		dbo.PracticeRegisterSection prsL on rl.PracticeRegisterSectionSID = prsL.PracticeRegisterSectionSID
	join
		dbo.PracticeRegister				prL on prsL.PracticeRegisterSID				= prL.PracticeRegisterSID
	where
		rr.RegistrantRenewalSID = @RegistrantRenewalSID;

	return (@isRegisterChange);
end;
GO
