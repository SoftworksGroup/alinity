SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.[pSetup$RequirementStatus]
	@SetupUser nvarchar(75) -- user assigned to audit columns
 ,@Language	 char(2)			-- language to install for
 ,@Region		 varchar(10)	-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup Requirement Status values
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : Updates the (dbo) Requirement Status master table with the values expected by the application
----------------------------------------------------------------------------------------------------------------------------------
History		: Author	  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Tim Edlund	| Apr 2018		|	Initial version

Comments	
--------
This procedure synchronizes the dbo.RequirementStatus table with the settings required by the current version of the application. 
If a record is missing it is added. Where the record exists, it is set to current values. Requirement-Statuses no longer used are
deleted from the table. One MERGE statement is used to carryout all operations.

Example:
--------

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully.">
		<SQLScript>
		<![CDATA[
		
			exec dbo.pSetup$RequirementStatus
				 @SetupUser = 'system@alinityapp.com'
				,@Language = 'EN'
				,@Region = 'CA'

			select * from dbo.RequirementStatus order by RequirementStatusSequence

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$RequirementStatus'
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
		ID												int						identity(1, 1)
	 ,RequirementStatusSCD			varchar(25)		not null
	 ,RequirementStatusLabel		nvarchar(35)	not null
	 ,RequirementStatusSequence int						not null
	 ,Description								nvarchar(max) not null
	 ,IsFinal										bit						not null
	 ,IsDefault									bit						not null
	);

	begin try

		insert
			@setup
		(
			RequirementStatusSCD
		 ,RequirementStatusLabel
		 ,RequirementStatusSequence
		 ,IsFinal
		 ,IsDefault
		 ,Description
		)
		values
		(
			'PENDING', N'Pending', 100, @OFF, @ON
		 ,N'This status indicates a response is still required for the requirement from the member or, if a response has been made, that the review/decision on the response is still pending.'
		)
		 ,(
				'MET', N'Requirement Is Met', 110, @ON, @OFF
			 ,N'This status indicates the requirement has been successfully met. The requirement will no longer block approval of the registration.'
			)
		 ,(
				'FAILED', N'Failed (not met)', 115, @ON, @OFF
			 ,N'This status indicates that either a response was not received for the requirement in a timely manner, or the response was determined to be insufficient to meet the requirement. A failed requirement blocks approval of the registration.'
			)
		 ,(
				'NA', N'Not Applicable', 999, @ON, @OFF
			 ,N'This status indicates the requirement should not be applied to this particular member case.  The requirement will not block approval of the registration.'
			);

		merge dbo.RequirementStatus target
		using (
						select
							x.RequirementStatusSCD
						 ,x.RequirementStatusLabel
						 ,x.RequirementStatusSequence
						 ,x.Description
						 ,x.IsFinal
						 ,x.IsDefault
						 ,@SetupUser CreateUser
						 ,@SetupUser UpdateUser
						from
							@setup x
					) source
		on target.RequirementStatusSCD = source.RequirementStatusSCD
		when not matched by target then
			insert
			(
				RequirementStatusSCD
			 ,RequirementStatusLabel
			 ,RequirementStatusSequence
			 ,Description
			 ,IsFinal
			 ,IsDefault
			 ,CreateUser
			 ,UpdateUser
			)
			values
			(
				source.RequirementStatusSCD, source.RequirementStatusLabel, source.RequirementStatusSequence, source.Description, source.IsFinal, source.IsDefault
			 ,@SetupUser, @SetupUser
			)
		when matched then update set
												IsFinal = source.IsFinal
											 ,IsDefault = source.IsDefault
											 ,RequirementStatusSequence = source.RequirementStatusSequence
											 ,Description = source.Description
											 ,UpdateUser = @SetupUser
		when not matched by source then delete;

		-- check count of @setup table and the target table
		-- target should have at least as many rows as @setup

		select @sourceCount	 = count(1) from @setup ;

		select @targetCount	 = count(1) from dbo.RequirementStatus;

		if isnull(@targetCount, 0) <> @sourceCount
		begin
			exec sf.pMessage#Get
				@MessageSCD = 'SetupNotSynchronized'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'Synchronization of setup codes not complete. Source table count is %1 but target table (%2) count is %3.'
			 ,@Arg1 = @sourceCount
			 ,@Arg2 = 'dbo.RequirementStatus'
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
