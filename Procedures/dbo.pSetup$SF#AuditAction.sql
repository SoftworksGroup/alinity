SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pSetup$SF#AuditAction]
	@SetupUser nvarchar(75) -- user assigned to audit columns
 ,@Language	 char(2)			-- language to install for
 ,@Region		 varchar(10)	-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup sf.AuditAction data
Notice   : Copyright © 2012 Softworks Group Inc.
Summary  : updates sf.AuditAction master table with starting values for the application
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Tim Edlund		| Nov 2012			| Initial Version				 
				 : Christian T	| April 2014		| Added test harness
				 : Richard K		| April 2015		| Updated to avoid overwriting user changes to AuditActionName, UsageNote
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------
This procedure synchronizes the sf.AuditAction table with the settings required by the current version of the application. If
a record is missing it is added. Where the record exists, it is set to current values. Records no longer used are deleted from
the table. One MERGE statement is used to carryout all operations.

The procedure uses the SQL multi-row constructor syntax to insert values into a temporary table.

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully. If no child records exist, previous set up data is deleted prior to test.">
		<SQLScript>
		<![CDATA[
		
			if	not exists (select 1 from sf.RecordAudit where AuditActionSID is not null)
			begin
				delete from sf.AuditAction
				dbcc checkident( 'sf.AuditAction', reseed, 1000000) with NO_INFOMSGS
			end

			exec dbo.pSetup$SF#AuditAction
				 @SetupUser = 'system@alinityapp.com'
				,@Language = 'EN'
				,@Region = 'CA'

			select * from sf.AuditAction

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$SF#AuditAction'
	,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo		 int					 = 0								-- 0 no error, if < 50000 SQL error, else business rule
	 ,@errorText	 nvarchar(4000)										-- message text (for business rule errors)
	 ,@sourceCount int															-- count of rows in the source table
	 ,@targetCount int															-- count of rows in the target table
	 ,@ON					 bit					 = cast(1 as bit)		-- constant for boolean comparisons
	 ,@OFF				 bit					 = cast(0 as bit);	-- constant for bit comparison = 0

	declare @setup table
	(
		ID							int						not null identity(1, 1)
	 ,AuditActionSCD	varchar(25)		not null
	 ,AuditActionName nvarchar(50)	not null
	 ,IsDefault				bit						not null
	 ,UsageNotes			nvarchar(max) not null
	);

	begin try

		insert
			@setup
		(
			AuditActionSCD
		 ,AuditActionName
		 ,IsDefault
		 ,UsageNotes
		)
		values
		(
			'MENU.OPTION.ACCESS', N'Menu Option Access', @ON, N'This event is logged whenever a user executes a menu option from the landing page.'
		)
			--,('LICENSE.ACCESS'	, N'License Access',cast( 0 as bit), N'This event is logged whenever a user accesses a licensees registration information.')

		merge sf.AuditAction target
		using (
						select
							x.AuditActionSCD
						 ,x.AuditActionName
						 ,x.IsDefault
						 ,x.UsageNotes
						from
							@setup x
					) source
		on target.AuditActionSCD = source.AuditActionSCD
		when not matched by target then insert
																		(
																			AuditActionSCD
																		 ,AuditActionName
																		 ,IsDefault
																		 ,UsageNotes
																		 ,CreateUser
																		 ,UpdateUser
																		)
																		values
																		(
																			source.AuditActionSCD, source.AuditActionName, source.IsDefault, source.UsageNotes, @SetupUser, @SetupUser
																		)
		when matched then update set
												IsDefault = source.IsDefault
											 ,UpdateUser = @SetupUser
		when not matched by source then delete;

		-- check count of @setup table and the target table
		-- target should have at least as many rows as @setup

		select @sourceCount = count(1) from @setup;
		select @targetCount = count(1) from sf.AuditAction;

		if isnull(@targetCount, 0) <> @sourceCount
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'SetupNotSynchronized'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'Synchronization of setup codes not complete. Source table count is %1 but target table (%2) count is %3.'
			 ,@Arg1 = @sourceCount
			 ,@Arg2 = 'sf.AuditAction'
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
