SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pSetup$PaymentStatus]
	@SetupUser nvarchar(75) -- user assigned to audit columns
 ,@Language	 char(2)			-- language to install for
 ,@Region		 varchar(10)	-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup dbo.PaymentStatus data
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : Updates the (dbo) Payment Status master table with starting values for the application
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Tim Edlund		| Sep		2017    | Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------
This procedure synchronizes the dbo.PaymentStatus table with the settings required by the current version of the application. 
If a record is missing it is added. Where the record exists, it is set to current values. Payment-Statuses no longer used are
deleted from the table. One MERGE statement is used to carryout all operations.

Example:
--------

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes succesdboully.">
		<SQLScript>
		<![CDATA[
		
			exec dbo.pSetup$PaymentStatus
				 @SetupUser = 'system@alinityapp.com'
				,@Language = 'EN'
				,@Region = 'CA'

			select * from dbo.PaymentStatus order by PaymentStatusSequence

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'sf.pSetup$PaymentStatus'
	,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo		 int					 = 0	-- 0 no error, if < 50000 SQL error, else business rule
	 ,@errorText	 nvarchar(4000)			-- message text (for business rule errors)
	 ,@OFF				 bit					 = cast(0 as bit)
	 ,@ON					 bit					 = cast(1 as bit)
	 ,@sourceCount int								-- count of rows in the source table
	 ,@targetCount int;								-- count of rows in the target table

	declare @setup table
	(
		ID										int						identity(1, 1)
	 ,PaymentStatusSCD			varchar(25)		not null
	 ,PaymentStatusLabel		nvarchar(35)	not null
	 ,PaymentStatusSequence int						not null
	 ,[Description]					nvarchar(max) not null
	 ,IsPaid								bit						not null
	);

	begin try
		insert
			@setup
		( PaymentStatusSCD
		 ,PaymentStatusLabel
		 ,PaymentStatusSequence
		 ,IsPaid
		 ,[Description]
		)
		values
		(
			'PENDING'
		 ,N'Pending (in process)'
		 ,100
		 ,@OFF
		 ,N'This status applies to online payments which are being processed. After processing the normal statuses are APPROVED or DECLINED.'
		)
	 ,(
			'APPROVED'
		 ,N'Approved'
		 ,110
		 ,@ON
		 ,N'This status indicates the payment has been successfully processed when submitted online, or is otherwise assumed to be approved as in the case of a check which has not yet cleared the bank.'
		)
	 ,(
			'DECLINED'
		 ,N'Declined'
		 ,115
		 ,@OFF
		 ,N'This status indicates the payment was declined by the bank or the card processor. The reason for the decline - if provided - is stored in the payment record.'
		)
	 ,(
			'CANCELLED'
		 ,N'Cancelled (revoked)'
		 ,999
		 ,@OFF
		 ,N'This status indicates that a pending payment transaction is being revoked.  This status should only be applied whether neither an APPROVED or DECLINED result has been received from the payment processor.'
		)

		merge dbo.PaymentStatus target
		using
		( select
				x.PaymentStatusSCD
			 ,x.PaymentStatusLabel
			 ,x.PaymentStatusSequence
			 ,x.[Description]
			 ,x.IsPaid
			 ,@SetupUser CreateUser
			 ,@SetupUser UpdateUser
			from
				@setup x
		) source
		on target.PaymentStatusSCD = source.PaymentStatusSCD
		when not matched by target then
			insert
			( PaymentStatusSCD
			 ,PaymentStatusLabel
			 ,PaymentStatusSequence
			 ,[Description]
			 ,IsPaid
			 ,CreateUser
			 ,UpdateUser
			)
			values
			(
				source.PaymentStatusSCD
			 ,source.PaymentStatusLabel
			 ,source.PaymentStatusSequence
			 ,source.[Description]
			 ,source.IsPaid
			 ,@SetupUser
			 ,@SetupUser
			)
		when matched then update set
												IsPaid = source.IsPaid
											 ,PaymentStatusSequence = source.PaymentStatusSequence
											 ,[Description] = source.[Description]
											 ,UpdateUser = @SetupUser
		when not matched by source then delete;

		-- check count of @setup table and the target table
		-- target should have at least as many rows as @setup
		select	@sourceCount = count(1) from	@setup;

		select	@targetCount = count(1) from	dbo.PaymentStatus;

		if isnull(@targetCount, 0) <> @sourceCount
		begin
			exec sf.pMessage#Get
				@MessageSCD = 'SetupNotSynchronized'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'Synchronization of setup codes not complete. Source table count is %1 but target table (%2) count is %3.'
			 ,@Arg1 = @sourceCount
			 ,@Arg2 = 'dbo.PaymentStatus'
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
