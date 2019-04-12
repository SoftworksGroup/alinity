SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pSetup$SF#FormOwner]
	@SetupUser nvarchar(75) -- user assigned to audit columns
 ,@Language	 char(2)			-- language to install for
 ,@Region		 varchar(10)	-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup sf.FormOwner data
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : Updates the (sf) Form Owner master table with starting values for the application
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Tim Edlund		| Mar		2017    | Initial Version
				 : Tim Edlund		| Sep	2018			| Updated to overwrite custom labels due to redesign of #CurrentStatus functions
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------
This procedure synchronizes the sf.FormOwner table with the settings required by the current version of the application. 
If a record is missing it is added. Where the record exists, it is set to current values. Form-Statuses no longer used are
deleted from the table. One MERGE statement is used to carryout all operations.

Example:
--------

<TestHarness>
	<Test Name="Basic" IsAssignee="true" Description="Ensures sproc executes successfully.">
		<SQLScript>
		<![CDATA[
		
			exec dbo.pSetup$SF#FormOwner
				 @SetupUser = 'system@alinityapp.com'
				,@Language = 'EN'
				,@Region = 'CA'

			select * from sf.FormOwner

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$SF#FormOwner'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@OFF				 bit = cast(0 as bit) -- constants to reduce syntax required for bit casting
	 ,@ON					 bit = cast(1 as bit) -- bit = 1
	 ,@errorNo		 int = 0							-- 0 no error, if < 50000 SQL error, else business rule
	 ,@errorText	 nvarchar(4000)				-- message text (for business rule errors)
	 ,@sourceCount int									-- count of rows in the source table
	 ,@targetCount int;									-- count of rows in the target table

	declare @setup table
	(
		ID						 int					 identity(1, 1)
	 ,FormOwnerSCD	 varchar(25)	 not null
	 ,FormOwnerLabel nvarchar(35)	 not null
	 ,Description		 nvarchar(max) not null
	 ,IsAssignee		 bit					 not null
	);

	begin try

		insert
			@setup (FormOwnerSCD, FormOwnerLabel, IsAssignee, Description)
		values
		(
			'ASSIGNEE', N'Registrant/Applicant or Reviewer', @OFF
		 ,N'Indicates the person the form is assigned to needs to take the next action. This value is automatically resolved to: Applicant, Registrant, Supervisor or Reviewer based on the form type.'
		)
		 ,(
				'ADMIN', N'Administrator', @ON, N'Indicates the next action on the form is required by internal staff (administrators).'
			)
		 ,(
				'APPLICANT', N'Applicant', @ON
			 ,N'Indicates the next action on the form is required from the applicant. For example, the form has not been submitted yet or has been returned for corrections by the applicant.'
			)
		 ,(
				'REGISTRANT', N'Member', @ON
			 ,N'Indicates the next action on the form is required from the registrant. For example, a renewal form has not been submitted yet or has been returned for corrections by the registrant.'
			)
		 ,(
				'SUPERVISOR', N'Supervisor', @ON
			 ,N'Indicates the next action on the form is required from the supervisor. For example, the review form for an application has not been submitted yet or has been returned for corrections.'
			)
		 ,(
				'REVIEWER', N'Reviewer', @ON
			 ,N'Indicates the next action on the form is required from the reviewer or review team. For example, a Competence Review form has not been submitted by the committee members yet or has been returned to them for updates.'
			)
		 ,(
				'NONE', N'None', @OFF, N'Indicates the form is in a final status and no further action is required.  No owner applies.'
			);

		merge sf.FormOwner target
		using
		(
			select
				x.FormOwnerSCD
			 ,x.FormOwnerLabel
			 ,x.Description
			 ,x.IsAssignee
			 ,@SetupUser CreateUser
			 ,@SetupUser UpdateUser
			from
				@setup x
		) source
		on target.FormOwnerSCD = source.FormOwnerSCD
		when not matched by target then insert (FormOwnerSCD, FormOwnerLabel, Description, IsAssignee, CreateUser, UpdateUser)
																		values
																		(
																			source.FormOwnerSCD, source.FormOwnerLabel, source.Description, source.IsAssignee, @SetupUser, @SetupUser
																		)
		when matched then update set
												IsAssignee = source.IsAssignee
											 ,Description = source.Description
											 ,FormOwnerLabel = source.FormOwnerLabel	-- for this table user overrides of labels are NOT supported (see %#CurrentStatus functions)
											 ,UpdateUser = @SetupUser
		when not matched by source then delete;

		-- check count of @setup table and the target table
		-- target should have at least as many rows as @setup

		select @sourceCount	 = count(1) from @setup ;
		select @targetCount	 = count(1) from sf .FormOwner;

		if isnull(@targetCount, 0) <> @sourceCount
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'SetupNotSynchronized'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'Synchronization of setup codes not complete. Source table count is %1 but target table (%2) count is %3.'
			 ,@Arg1 = @sourceCount
			 ,@Arg2 = 'sf.FormOwner'
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
