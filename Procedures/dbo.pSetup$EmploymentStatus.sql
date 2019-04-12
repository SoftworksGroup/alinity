SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.[pSetup$EmploymentStatus]
	@SetupUser nvarchar(75) -- user assigned to audit columns
 ,@Language	 char(2)			-- language to install for
 ,@Region		 varchar(10)	-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup dbo.EmploymentStatus data
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : Updates dbo.EmploymentStatus table with starting values for the application
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Tim Edlund		| Sep 2017			| Initial Version				 
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------
This procedure establishes some sample records in the dbo.EmploymentStatus for end users to work with on new configurations.
The records are only added if no records exist in the table.  The Employment Status table is maintained by end users and may
contain any values and coding. 

The code values inserted correspond to a standard for Employment Statuses required by CIHI (as of 2017).

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully.">
		<SQLScript>
		<![CDATA[

		exec dbo.pSetup$EmploymentStatus 
			 @SetupUser = N'system@softworksgroup.com'
			,@Language  = 'en'
			,@Region		= 'can'
	
		select * from dbo.EmploymentStatus

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$EmploymentStatus'
	,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */

set nocount on;

begin

	declare
		@errorNo		 int					 = 0							-- 0 no error, if < 50000 SQL error, else business rule
	 ,@errorText	 nvarchar(4000)									-- message text (for business rule errors)
	 ,@OFF				 bit					 = cast(0 as bit) -- constant to refer to "false" bit value
	 ,@ON					 bit					 = cast(1 as bit) -- constant to refer to "true" bit value
	 ,@sourceCount int														-- count of rows in the source table
	 ,@targetCount int;														-- count of rows in the target table

	declare @setup table
	(
		ID										int					 identity(1, 1)
	 ,EmploymentStatusCode	varchar(20)	 not null
	 ,EmploymentStatusName nvarchar(50) not null
	 ,IsDefault							bit					 not null
	);

	begin try

		if not exists (select 1 from	dbo.EmploymentStatus)
		begin

			insert
				@setup
			(
				EmploymentStatusCode
			 ,EmploymentStatusName
			 ,IsDefault
			)
			values
			(
				'10', 'Regular employment in profession', @ON
			)
		 ,(
				'11', 'Casual employment in profession', @OFF
			)
		 ,(
				'20', 'Employed outside profession: Seeking in profession', @OFF
			)
		 ,(
				'21', 'Employed outside profession: Not seeking', @OFF
			)
		 ,(
				'30', 'Not Employed: Seeking employment', @OFF
			)
		 ,(
				'31', 'Not Employed: Not seeking', @OFF
			);

			insert
				dbo.EmploymentStatus
			(
				EmploymentStatusCode
			 ,EmploymentStatusName
			 ,IsDefault
			 ,CreateUser
			 ,UpdateUser
			)
			select
				EmploymentStatusCode
			 ,EmploymentStatusName
			 ,IsDefault
			 ,@SetupUser
			 ,@SetupUser
			from
				@setup;

			-- check count of @setup table and the target table
			-- target should have exactly as many rows as @setup

			select	@sourceCount = count(1) from	@setup;
			select
				@targetCount = count(1)
			from
				dbo.EmploymentStatus;

			if isnull(@targetCount, 0) <> @sourceCount
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'SetupNotSynchronized'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'Synchronization of setup codes not complete. Source table count is %1 but target table (%2) count is %3.'
				 ,@Arg1 = @sourceCount
				 ,@Arg2 = 'dbo.EmploymentStatus'
				 ,@Arg3 = @targetCount;

				raiserror(@errorText, 18, 1);
			end;

		end;

	end try

	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);

end;
GO
