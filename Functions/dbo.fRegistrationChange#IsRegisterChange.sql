SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fRegistrationChange#IsRegisterChange] (@registrationChangeSID int)
returns bit
as
/*********************************************************************************************************************************
ScalarF : RegistrationChange - Is Register Change
Notice  : Copyright © 2017 Softworks Group Inc.
Summary : Returns 1 (bit) when the register the registration change is being made to is differen than the current registration
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-------------------------------------------------------------------------------------------
					: Tim Edlund  | Apr 2018		|	Initial version
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
The function is used in various locations in the registration change process to determine if a Register Change is being made.
The register on the registration associated with the registration change is compared to the register the registration change is being 
made under.  If the register is changing, then 1 is returned.

Example
-------
<TestHarness>
	<Test Name="DifferentRegister" Description="Should be register change">
		<SQLScript>
			<![CDATA[
		declare
			 @RegistrationSID								int
			,@practiceRegisterSectionSID					int
			,@currentPracticeRegisterSID					int
			,@formVersionSID											int
			,@registrationYear										int
			,@registrationChangeSID								int
			,@formOwnerSID												int

		begin tran

		select top 1
				@RegistrationSID					= rl.RegistrationSID
			,	@currentPracticeRegisterSID		= prs.PracticeRegisterSID
		from
			dbo.Registration rl
		join
			dbo.PracticeRegisterSection prs on rl.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID

		select top 1
			@practiceRegisterSectionSID  = prs.PracticeRegisterSectionSID
		from
			dbo.PracticeRegisterSection prs 
		join
			dbo.PracticeRegister pr on pr.PracticeRegisterSID = prs.PracticeRegisterSID and pr.IsActive = cast(1 as bit)
		where
			prs.PracticeRegisterSID <> @currentPracticeRegisterSID
		and
			prs.IsActive = cast ( 1 as bit)
		order by
			newid()

		select top 1
			@formVersionSID = fv.FormVersionSID
		from
			sf.FormVersion fv

		select top 1
			@formOwnerSID = fo.FormOwnerSID
		from
			sf.FormOwner fo

		select
			@registrationYear = year(sf.fNow())


		insert into dbo.RegistrationChange
		(
				RegistrationSID
			, RegistrationYear
			, PracticeRegisterSectionSID
			,	FormResponseDraft
			,	AdminComments
			, FormVersionSID
		)
		select
			 @RegistrationSID
			,@registrationYear
			,@practiceRegisterSectionSID 
			,N'<FormResponses></FormResponses>'
			,N'<Comments></Comments>'
			,@formVersionSID 

		set @registrationChangeSID = SCOPE_IDENTITY()

		select
			dbo.fRegistrationChange#IsRegisterChange(@registrationChangeSID)

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
				 @RegistrationSID								int
				,@practiceRegisterSectionSID					int
				,@currentPracticeRegisterSID					int
				,@formVersionSID											int
				,@registrationYear										int
				,@registrationChangeSID								int
				,@formOwnerSID												int

			begin tran

			select top 1
				 @RegistrationSID				= rl.RegistrationSID
				,@currentPracticeRegisterSID = prs.PracticeRegisterSID
			from
				dbo.Registration rl
			join
				dbo.PracticeRegisterSection prs on rl.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID

			select top 1
				@practiceRegisterSectionSID  = prs.PracticeRegisterSectionSID
			from
				dbo.PracticeRegisterSection prs 
			join
				dbo.PracticeRegister pr on pr.PracticeRegisterSID = prs.PracticeRegisterSID and pr.IsActive = cast(1 as bit)
			where
				prs.PracticeRegisterSID = @currentPracticeRegisterSID
			and
				prs.IsActive = cast ( 1 as bit)
			order by
				newid()

			select top 1
				@formVersionSID = fv.FormVersionSID
			from
				sf.FormVersion fv

			select top 1
				@formOwnerSID = fo.FormOwnerSID
			from
				sf.FormOwner fo

			select
				@registrationYear = year(sf.fNow())

			insert into dbo.RegistrationChange
			(
				 RegistrationSID
				,RegistrationYear
				,PracticeRegisterSectionSID
				,FormResponseDraft
				,AdminComments
				,FormVersionSID
			)
			select
				 @RegistrationSID
				,@registrationYear
				,@practiceRegisterSectionSID 
				,N'<FormResponses></FormResponses>'
				,N'<Comments></Comments>'
				,@formVersionSID 

			set @registrationChangeSID = SCOPE_IDENTITY()

			select
				dbo.fRegistrationChange#IsRegisterChange(@registrationChangeSID)

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
  @ObjectName = 'dbo.fRegistrationChange#IsRegisterChange'
 ,@DefaultTestOnly = 1

-------------------------------------------------------------------------------------------------------------------------------- */
begin

	declare @isRegisterChange bit = cast(0 as bit); -- return value

	select
		@isRegisterChange = case when prRC.PracticeRegisterSID <> prL.PracticeRegisterSID then cast(1 as bit)else @isRegisterChange end
	from
		dbo.RegistrationChange			rc
	join
		dbo.PracticeRegisterSection prsRC on rc.PracticeRegisterSectionSID = prsRC.PracticeRegisterSectionSID
	join
		dbo.PracticeRegister				prRC on prsRC.PracticeRegisterSID			 = prRC.PracticeRegisterSID
	join
		dbo.Registration				rl on rc.RegistrationSID					 = rl.RegistrationSID
	join
		dbo.PracticeRegisterSection prsL on rl.PracticeRegisterSectionSID	 = prsL.PracticeRegisterSectionSID
	join
		dbo.PracticeRegister				prL on prsL.PracticeRegisterSID				 = prL.PracticeRegisterSID
	where
		rc.RegistrationChangeSID = @registrationChangeSID;

	return (@isRegisterChange);
end;
GO
