SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pSetup$PaymentType]
	@SetupUser nvarchar(75) -- user assigned to audit columns
 ,@Language	 char(2)			-- language to install for
 ,@Region		 varchar(10)	-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup dbo.PaymentType data
Notice   : Copyright © 2012 Softworks Group Inc.
Summary  : Updates dbo.PaymentType master table with starting values for the application
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Richard K	 	| Aug 2015			| Initial Version				 
				 : Tim Edlund		| Sep 2017			| Revised to support specific payment processors. 				
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------
This procedure synchronizes the dbo.PaymentType table with the settings required by the current version of the application. If
a record is missing it is added. Where the record exists, it is set to current values.One MERGE statement is used to carryout all 
operations.

The procedure uses the SQL multi-row constructor syntax to insert values into a temporary table.

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully. If no child records exist, previous set up 
	data is deleted prior to test.">
		<SQLScript>
		<![CDATA[
		
			if	not exists (select 1 from dbo.Payment)
			begin
				delete from dbo.PaymentType
				dbcc checkident( 'dbo.PaymentType', reseed, 1000000) with NO_INFOMSGS
			end

			exec dbo.pSetup$PaymentType
				 @SetupUser = 'system@alinityapp.com'
				,@Language = 'EN'
				,@Region = 'CA'

			select * from dbo.PaymentType

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$PaymentType'
	,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo					 int					 = 0							-- 0 no error, if < 50000 SQL error, else business rule
	 ,@errorText				 nvarchar(4000)									-- message text (for business rule errors)
	 ,@ON								 bit					 = cast(1 as bit) -- a constant to reduce repetitive cast syntax in bit comparisons
	 ,@OFF							 bit					 = cast(0 as bit) -- a constant to reduce repetitive cast syntax in bit comparisons
	 ,@sourceCount			 int														-- count of rows in the source table
	 ,@targetCount			 int														-- count of rows in the target table
	 ,@approvedStatusSID int														-- key of APPROVED status 
	 ,@pendingStatusSID	 int														-- key of APPROVED status 
	 ,@glAccountSID			 int														-- default bank account to assign to all payment types on insert
	 ,@defaultSCD				 varchar(15);										-- system code of current default record	

	declare @setup table
	(
		ID										 int					identity(1, 1)
	 ,GLAccountSID					 int					not null
	 ,PaymentTypeLabel			 nvarchar(35) not null
	 ,PaymentTypeSCD				 varchar(15)	not null
	 ,PaymentStatusSID			 int					not null
	 ,IsRefundExcludedFromGL bit					not null
	 ,IsDefault							 bit					not null default cast(0 as bit)
	);

	begin try

		select
			@approvedStatusSID = ps.PaymentStatusSID
		from
			dbo.PaymentStatus ps
		where
			ps.PaymentStatusSCD = 'APPROVED';

		select
			@pendingStatusSID = ps.PaymentStatusSID
		from
			dbo.PaymentStatus ps
		where
			ps.PaymentStatusSCD = 'PENDING';

		select
			@glAccountSID = gla.GLAccountSID
		from
			dbo.GLAccount gla
		where
			gla.IsBankAccount = @ON;

		select
			@defaultSCD = pt.PaymentTypeSCD
		from
			dbo.PaymentType pt
		where
			pt.IsDefault = @ON; -- retrieve current default if any

		if @defaultSCD is null
		begin
			set @defaultSCD = 'CHECK';
		end;

-- SQL Prompt formatting off
		insert
			@setup (GLAccountSID, PaymentTypeLabel, PaymentTypeSCD, PaymentStatusSID,IsRefundExcludedFromGL) 
			values 
		 (@glAccountSID, N'Check/Cheque', 'CHECK', @approvedStatusSID, @ON)
		,(@glAccountSID, N'Online (Moneris)', 'PP.MONERIS', @pendingStatusSID, @OFF)
		,(@glAccountSID, N'Virtual Terminal (Moneris)', 'VT.MONERIS', @approvedStatusSID, @OFF)
		,(@glAccountSID, N'Online (Bambora)','PP.BAMBORA',@pendingStatusSID, @OFF)
		,(@glAccountSID, N'Virtual Terminal (Bambora)', 'VT.BAMBORA', @approvedStatusSID, @OFF)
		,(@glAccountSID, N'POS Machine', 'POS', @approvedStatusSID, @ON)
		,(@glAccountSID, N'Pre-authorized Payment', 'PAP', @approvedStatusSID, @ON)
		,(@glAccountSID, N'Cash (currency)', 'CASH', @approvedStatusSID, @ON)
		,(@glAccountSID, N'Money Order', 'MONEY.ORDER', @approvedStatusSID,@ON)
		,(@glAccountSID, N'Interac E-transfer (Email)','E.TRANSFER',@approvedStatusSID,@ON);
-- SQL Prompt formatting on

		if not exists (select 1 from dbo .PaymentType pt where pt.IsDefault = @ON)
		begin
			update dbo .PaymentType set IsDefault = @ON where PaymentTypeSCD = @defaultSCD;
		end;

		update @setup	 set IsDefault = @ON where PaymentTypeSCD = @defaultSCD;

		merge dbo.PaymentType target
		using
		(
			select
				x.GLAccountSID
			 ,x.PaymentTypeLabel
			 ,x.PaymentTypeSCD
			 ,x.PaymentStatusSID
			 ,x.IsRefundExcludedFromGL
			 ,x.IsDefault
			from
				@setup x
		) source
		on target.PaymentTypeSCD = source.PaymentTypeSCD
		when not matched by target then
			insert
			(
				GLAccountSID
			 ,PaymentTypeLabel
			 ,PaymentTypeSCD
			 ,PaymentStatusSID
			 ,IsRefundExcludedFromGL
			 ,IsDefault
			 ,CreateUser
			 ,UpdateUser
			)
			values
			(
				source.GLAccountSID, source.PaymentTypeLabel, source.PaymentTypeSCD, source.PaymentStatusSID, source.IsRefundExcludedFromGL, source.IsDefault
			 ,@SetupUser, @SetupUser
			)
		when matched then update set
												target.PaymentStatusSID = source.PaymentStatusSID
											 ,target.IsRefundExcludedFromGL = source.IsRefundExcludedFromGL
											 ,target.IsDefault = source.IsDefault
											 ,UpdateUser = @SetupUser
		when not matched by source then delete;

		-- check count of @setup table and the target table
		-- target should have exactly as many rows as @setup
		select @sourceCount	 = count(1) from @setup ;

		select @targetCount	 = count(1) from dbo .PaymentType;

		if isnull(@targetCount, 0) <> @sourceCount
		begin
			exec sf.pMessage#Get
				@MessageSCD = 'SetupNotSynchronized'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'Synchronization of setup codes not complete. Source table count is %1 but target table (%2) count is %3.'
			 ,@Arg1 = @sourceCount
			 ,@Arg2 = 'dbo.PaymentType'
			 ,@Arg3 = @targetCount;

			raiserror(@errorText, 18, 1);
		end;
	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
