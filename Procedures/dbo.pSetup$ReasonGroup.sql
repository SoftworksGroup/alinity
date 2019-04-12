SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pSetup$ReasonGroup]
	@SetupUser nvarchar(75) -- user assigned to audit columns
 ,@Language	 char(2)			-- language to install for
 ,@Region		 varchar(10)	-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup Reason Group data
Notice   : Copyright © 2012 Softworks Group Inc.
Summary  : Sets dbo.ReasonGroup master table with values expected by the application
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year  | Change Summary
				 : ------------ | ------------|-------------------------------------------------------------------------------------------
				 : Tim Edlund		| Jun 2017		| Initial Version				 
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------
This procedure synchronizes the dbo.ReasonGroup table with the settings required by the current version of the application. If
a record is missing it is added. Where the record exists, it is set to current values. Any extra records - those non longer 
required - are deleted. A single MERGE statement is used to carryout all operations. While descriptions of values in this table can
be updated by configurators and users, records cannot be added or deleted.  The list of SCD values is fixed and cannot be modified.

The procedure uses the SQL multi-row constructor syntax to insert values into a temporary table.

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully.">
		<SQLScript>
		<![CDATA[
		
			exec dbo.pSetup$ReasonGroup
				 @SetupUser = 'system@alinityapp.com'
				,@Language = 'EN'
				,@Region = 'CA'

			select * from dbo.ReasonGroup

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$ReasonGroup'
	,@DefaultTestOnly = 1
	------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo		 int					 = 0							-- 0 no error, if < 50000 SQL error, else business rule
	 ,@errorText	 nvarchar(4000)									-- message text (for business rule errors)
	 ,@ON					 bit					 = cast(1 as bit) -- constant to reduce repetitive casting
	 ,@OFF				 bit					 = cast(0 as bit) -- constant to reduce repetitive casting
	 ,@sourceCount int														-- count of rows in the source table
	 ,@targetCount int;														-- count of rows in the target table

	declare @setup table
	(
		ID							 int					not null identity(1, 1)
	 ,ReasonGroupSCD	 varchar(20)	not null
	 ,ReasonGroupLabel nvarchar(35) not null
	 ,IsLockedGroup		 bit					not null
	);

	begin try

		insert
			@setup
		(
			ReasonGroupSCD
		 ,ReasonGroupLabel
		 ,IsLockedGroup
		)
		values
		(
			'AUDIT.WITHDRAWN', N'Audit Exemption', @OFF
		)
	 ,(
			'AUDIT.FAILED', N'Audit Failed/Rejected', @OFF
		)
	 ,(
			'APP.WITHDRAWN', N'Application Withdrawn', @OFF
		)
	 ,(
			'APP.FAILED', N'Application Failed/Rejected', @OFF
		)
	 ,(
			'APP.BLOCK', N'Application Block Reasons', @OFF
		)
	 ,(
			'RENEWAL.FAILED', N'Renewal Failed/Rejected', @OFF
		)
	 ,(
			'RENEWAL.WITHDRAWN', N'Renewal Withdrawn', @OFF
		)
	 ,(
			'REGCHANGE.WITHDRAWN', N'Register Change Withdrawn', @OFF
		)
	 ,(
			'LPLAN.WITHDRAWN', N'Learning Plan Withdrawn', @ON
		)
	 ,(
			'PRFLUPDT.WITHDRAWN', N'Profile Update Withdrawn', @OFF
		)
	 ,(
			'REGCHANGE', N'Register Change Reasons', @OFF
		)
	 ,(
			'REGCHANGE.REGISTRANT', N'Registrant Register Change Reasons', @OFF
		)
	 ,(
			'AUTO.APPROVE.BLOCKED', N'Auto-Approval Block Reasons', @ON
		)
	 ,(
			'INVOICE.CANCEL', N'Reasons for cancelling invoices', @OFF
		)
	 ,(
			'PAYMENT.CANCEL', N'Reasons for cancelling payments', @ON
		)
	 ,(
			'PAYMENT.UNAPPLY', N'Reasons for removing payments', @ON	-- ensure the codes are not in mixed or lower case!
		)
	 ,(
			'PAYMENT.REFUND', N'Reasons for issuing refunds', @ON
		)
	 ,(
			'FEE.ADJUSTMENT', N'Reasons for changing fees', @OFF
		)
	 ,(
			'COMPLAINT.DISMISS', N'Reasons for dismissing a complaint', @OFF
		);

		merge dbo.ReasonGroup target
		using
		(
			select
				x.ReasonGroupSCD
			 ,x.ReasonGroupLabel
			 ,x.IsLockedGroup
			from
				@setup x
		) source
		on target.ReasonGroupSCD = source.ReasonGroupSCD
		when matched then
			update 
				set 		
						IsLockedGroup		= source.IsLockedGroup
					,	UpdateUser			= @SetupUser 
		when not matched by target then insert
																		(
																			ReasonGroupSCD
																		 ,ReasonGroupLabel
																		 ,IsLockedGroup
																		 ,CreateUser
																		 ,UpdateUser
																		)
																		values
																		(
																			source.ReasonGroupSCD, source.ReasonGroupLabel, source.IsLockedGroup, @SetupUser, @SetupUser
																		)
		when not matched by source then delete;

		-- check count of @setup table and the target table
		-- target should have exactly as many rows as @setup

		select	@sourceCount = count(1) from	@setup;
		select	@targetCount = count(1) from	dbo.ReasonGroup;

		if isnull(@targetCount, 0) <> @sourceCount
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'SetupNotSynchronized'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'Synchronization of setup codes not complete. Source table count is %1 but target table (%2) count is %3.'
			 ,@Arg1 = @sourceCount
			 ,@Arg2 = 'dbo.ReasonGroup'
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
