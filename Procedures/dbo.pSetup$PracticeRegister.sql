SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.[pSetup$PracticeRegister]
	@SetupUser nvarchar(75) -- user assigned to audit columns
 ,@Language	 char(2)			-- language to install for
 ,@Region		 varchar(10)	-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup dbo.PracticeRegister data
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : Initializes dbo.PracticeRegister table with starting/sample values
----------------------------------------------------------------------------------------------------------------------------------
History		: Author								| Month Year	| Change Summary
					: --------------------- + ----------- + --------------------------------------------------------------------------------
					: Tim Edlund						| Jun 2018		|	Initial version
					
Comments  
--------
This procedure populates the dbo.PracticeRegister table with starting values during the application installation process. The
procedure does not modify the table if any records are found in it.  The procedure only inserts the records where the
table is empty.

Records in this table can be added and deleted by end users and the Alinity Service Desk team to meet the requirements of the
client.  The records inserted by the procedure are examples only and may be replaced/modified as required.

Note that while the client and configurator can manage the records in the table as required, the application does depend
on the existence of 2 default register records:

1) A register must exist to assign new applicants to.  This is identified by the Is-Default bit. 
2) A default register to assign inactive members to. This is identified by the Is-Default-Active-Practice bit.

If no record is found for the required defaults, they are added by this procedure.  Also, the new-applicant register must have
their Is-Active-Practice bits set OFF.  If this is not the case this procedure updates them.

The procedure also performs quality checking with respect to the child sections each register has.  First, it ensures at least 1
Practice-Register-Section record exists for each parent register. It also ensures that at least one child section is marked as
the default for the register.  If a default is not found, the record with the lowest key value is assigned.

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully.">
		<SQLScript>
		<![CDATA[

		exec dbo.pSetup$PracticeRegister 
			 @SetupUser = N'system@softworksgroup.com'
			,@Language  = 'en'
			,@Region		= 'can'
	
		select * from dbo.PracticeRegister
		select * from dbo.PracticeRegisterSection

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$PracticeRegister'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo								 int					 = 0											-- 0 no error, if < 50000 SQL error, else business rule
	 ,@ON											 bit					 = cast(1 as bit)					-- constant for bit comparisons = 1
	 ,@OFF										 bit					 = cast(0 as bit)					-- constant for bit comparison = 0
	 ,@tranCount							 int					 = @@trancount						-- determines whether a wrapping transaction exists
	 ,@procName								 nvarchar(128) = object_name(@@procid)	-- name of currently executing procedure
	 ,@xState									 int																		-- error state detected in catch block
	 ,@practiceRegisterTypeSID int																		-- key of register type for adding default/sample records
	 ,@practiceRegisterSID		 int																		-- key of register used for checking for existence of required records
	 ,@learningModelSID				 int;																		-- key of default learning model

	begin try

		-- process DB changes as a transaction
		-- to enable partial rollback on error

		if @tranCount = 0
		begin
			begin transaction; -- no wrapping transaction
		end;
		else
		begin
			save transaction @procName; -- previous trx pending - create save point
		end;

		if not exists (select 1 from dbo.PracticeRegister)
		begin

			select
				@practiceRegisterTypeSID = prt.PracticeRegisterTypeSID
			from
				dbo.PracticeRegisterType prt
			where
				prt.PracticeRegisterTypeSCD = 'PERPETUAL';

			select
				@learningModelSID = lm.LearningModelSID
			from
				dbo.LearningModel lm
			where
				lm.IsDefault = @ON;

			exec dbo.pPracticeRegister#Insert
				@PracticeRegisterTypeSID = @practiceRegisterTypeSID
			 ,@PracticeRegisterName = N'Applicants'
			 ,@PracticeRegisterLabel = N'Applicants'
			 ,@IsActivePractice = @OFF
			 ,@IsPublicRegistryEnabled = @OFF
			 ,@IsRenewalEnabled = @OFF
			 ,@IsDefault = @ON
			 ,@CreateUser = @SetupUser;
			select
				@practiceRegisterTypeSID = prt.PracticeRegisterTypeSID
			from
				dbo.PracticeRegisterType prt
			where
				prt.PracticeRegisterTypeSCD = 'FIXED.ANNUAL';

			exec dbo.pPracticeRegister#Insert
				@PracticeRegisterTypeSID = @practiceRegisterTypeSID
			 ,@PracticeRegisterName = N'Active'
			 ,@PracticeRegisterLabel = N'Active'
			 ,@LearningModelSID = @learningModelSID
			 ,@CreateUser = @SetupUser;

			exec dbo.pPracticeRegister#Insert
				@PracticeRegisterTypeSID = @practiceRegisterTypeSID
			 ,@PracticeRegisterName = N'Associate'
			 ,@PracticeRegisterLabel = N'Associate'
			 ,@IsActivePractice = @OFF
			 ,@IsPublicRegistryEnabled = @OFF
			 ,@IsRenewalEnabled = @OFF
			 ,@CreateUser = @SetupUser;

			exec dbo.pPracticeRegister#Insert
				@PracticeRegisterTypeSID = @practiceRegisterTypeSID
			 ,@PracticeRegisterName = N'Student'
			 ,@PracticeRegisterLabel = N'Student'
			 ,@IsActivePractice = @OFF
			 ,@IsPublicRegistryEnabled = @OFF
			 ,@IsRenewalEnabled = @OFF
			 ,@CreateUser = @SetupUser;



			select
				@practiceRegisterTypeSID = prt.PracticeRegisterTypeSID
			from
				dbo.PracticeRegisterType prt
			where
				prt.PracticeRegisterTypeSCD = 'PERPETUAL';

			exec dbo.pPracticeRegister#Insert
				@PracticeRegisterTypeSID = @practiceRegisterTypeSID
			 ,@PracticeRegisterName = N'Inactive'
			 ,@PracticeRegisterLabel = N'Inactive'
			 ,@IsActivePractice = @OFF
			 ,@IsPublicRegistryEnabled = @OFF
			 ,@IsRenewalEnabled = @OFF
			 ,@CreateUser = @SetupUser;


		end;

		-- ensure a new applicant register (default register) exists or
		-- insert it; if exists ensure it is marked as inactive practice

		select
			@practiceRegisterSID = pr.PracticeRegisterSID
		from
			dbo.PracticeRegister pr
		where
			pr.IsDefault = @ON;

		if @practiceRegisterSID is null
		begin

			select
				@practiceRegisterTypeSID = prt.PracticeRegisterTypeSID
			from
				dbo.PracticeRegisterType prt
			where
				prt.PracticeRegisterTypeSCD = 'PERPETUAL';

			exec dbo.pPracticeRegister#Insert
				@PracticeRegisterTypeSID = @practiceRegisterTypeSID
			 ,@PracticeRegisterName = N'Applicants'
			 ,@PracticeRegisterLabel = N'Applicants'
			 ,@IsActivePractice = @OFF
			 ,@IsPublicRegistryEnabled = @OFF
			 ,@IsRenewalEnabled = @OFF
			 ,@IsDefault = @ON
			 ,@CreateUser = @SetupUser;


		end;
		else
		begin

			update
				dbo.PracticeRegister
			set
				IsActivePractice = @OFF
			 ,IsRenewalEnabled = @OFF
			 ,UpdateUser = @SetupUser
			 ,UpdateTime = sysdatetimeoffset()
			where
				PracticeRegisterSID = @practiceRegisterSID and (IsActivePractice = @ON or IsRenewalEnabled = @ON);

		end;

		-- perform same actions for the default inactive register

		set @practiceRegisterSID = null;

		select
			@practiceRegisterSID = pr.PracticeRegisterSID
		from
			dbo.PracticeRegister pr
		where
			pr.IsDefault = @ON;

		if @practiceRegisterSID is null
		begin

			select
				@practiceRegisterTypeSID = prt.PracticeRegisterTypeSID
			from
				dbo.PracticeRegisterType prt
			where
				prt.PracticeRegisterTypeSCD = 'PERPETUAL';

			exec dbo.pPracticeRegister#Insert
				@PracticeRegisterTypeSID = @practiceRegisterTypeSID
			 ,@PracticeRegisterName = N'Inactive'
			 ,@PracticeRegisterLabel = N'Inactive'
			 ,@IsActivePractice = @OFF
			 ,@IsPublicRegistryEnabled = @OFF
			 ,@IsRenewalEnabled = @OFF
			 ,@IsDefault = @ON
			 ,@CreateUser = @SetupUser;


		end;
		else
		begin

			update
				dbo.PracticeRegister
			set
				IsActivePractice = @OFF
			 ,IsRenewalEnabled = @OFF
			 ,UpdateUser = @SetupUser
			 ,UpdateTime = sysdatetimeoffset()
			where
				PracticeRegisterSID = @practiceRegisterSID and (IsActivePractice = @ON or IsRenewalEnabled = @ON);

		end;

		-- ensure a default practice register section exists for any
		-- new registers that might have been created by this procedure

		insert
			dbo.PracticeRegisterSection
		(
			PracticeRegisterSID
		 ,PracticeRegisterSectionLabel
		 ,IsDefault
		 ,CreateUser
		 ,UpdateUser
		)
		select
			pr.PracticeRegisterSID
		 ,pr.PracticeRegisterLabel + ' Default'
		 ,@ON
		 ,@SetupUser
		 ,@SetupUser
		from
			dbo.PracticeRegister				pr
		left outer join
			dbo.PracticeRegisterSection prs on prs.PracticeRegisterSID = pr.PracticeRegisterSID
		where
			pr.IsActive = @ON and prs.PracticeRegisterSID is null;

		-- finally ensure each register has one of its sections
		-- marked as the default

		update
			z
		set
			z.IsDefault = @ON
			,z.UpdateTime = sysdatetimeoffset()
		from
		(
			select
				prs.PracticeRegisterSID
			from
				dbo.PracticeRegister				pr
			left outer join
				dbo.PracticeRegisterSection prs on prs.PracticeRegisterSID = pr.PracticeRegisterSID and prs.IsDefault = @ON
			where
				pr.IsActive = @ON and prs.PracticeRegisterSID is null -- isolates active registers with NO DEFAULT section
		)															x
		join
		(
			select
				prs.PracticeRegisterSID
			 ,min(prs.PracticeRegisterSectionSID) PracticeRegisterSectionSID
			from
				dbo.PracticeRegisterSection prs
			group by
				prs.PracticeRegisterSID
		)															y on x.PracticeRegisterSID				= y.PracticeRegisterSID -- isolates the first section for each register
		join
			dbo.PracticeRegisterSection z on y.PracticeRegisterSectionSID = z.PracticeRegisterSectionSID -- main table to receive updates
		where	
			z.IsDefault = @OFF

		if @tranCount = 0 and xact_state() = 1 -- if no wrapping transaction and committable
		begin
			commit;
		end;

	end try
	begin catch

		-- if a transaction was pending at start of routine 
		-- perform partial rollback to save point

		set @xState = xact_state();

		if @tranCount > 0 and (@xState = -1 or @xState = 1)
		begin
			rollback transaction @procName; -- rollback to save point
		end;
		else if (@xState = -1 or @xState = 1) -- full rollback since no previous trx was pending
		begin
			rollback;
		end;

		exec @errorNo = sf.pErrorRethrow; -- process message text and re-throw the error
	end catch;

	return (@errorNo);

end;
GO
