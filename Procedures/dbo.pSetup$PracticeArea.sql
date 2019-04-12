SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.[pSetup$PracticeArea]
	@SetupUser nvarchar(75) -- user assigned to audit columns
 ,@Language	 char(2)			-- language to install for
 ,@Region		 varchar(10)	-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup dbo.PracticeArea data
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : Updates dbo.PracticeArea table with starting values for the application
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Tim Edlund		| Sep 2017			| Initial Version				 
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------
This procedure establishes some sample records in the dbo.PracticeArea for end users to work with on new configurations.
The records are only added if no records exist in the table.  The Employment Status table is maintained by end users and may
contain any values and coding. 

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully.">
		<SQLScript>
		<![CDATA[

		exec dbo.pSetup$PracticeArea 
			 @SetupUser = N'system@softworksgroup.com'
			,@Language  = 'en'
			,@Region		= 'can'
	
		select * from dbo.PracticeArea

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$PracticeArea'
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
		ID							 int					identity(1, 1)
	 ,PracticeAreaCode varchar(20)	not null
	 ,PracticeAreaName nvarchar(50) not null
	 ,IsDefault				 bit					not null
	);

	begin try

		if not exists (select 1 from	dbo.PracticeArea)
		begin

			insert
				@setup
			(
				PracticeAreaCode
			 ,PracticeAreaName
			 ,IsDefault
			)
			values
		  (
				'9999', 'Unknown', @ON
			)
			,(
				'1001', 'Addiction Services', @OFF
			)
		 ,(
				'1002', 'Ambulatory Care', @OFF
			)
		 ,(
				'1003', 'Community Health', @OFF
			)
		 ,(
				'1004', 'Critical / Intensive Care', @OFF
			)
		 ,(
				'1005', 'Emergency Care', @OFF
			)
		 ,(
				'1006', 'Geriatrics', @OFF
			)
		 ,(
				'1007', 'Home Care', @OFF
			)
		 ,(
				'1008', 'Maternal / Child', @OFF
			)
		 ,(
				'1009', 'Medical', @OFF
			)
		 ,(
				'1010', 'Mental Health', @OFF
			)
		 ,(
				'1011', 'Nursing In Several Clinical Areas', @OFF
			)
		 ,(
				'1012', 'Occupational Health', @OFF
			)
		 ,(
				'1013', 'Operating Room', @OFF
			)
		 ,(
				'1014', 'Orthopaedics', @OFF
			)
		 ,(
				'1015', 'Palliative Care', @OFF
			)
		 ,(
				'1016', 'Pediatrics', @OFF
			)
		 ,(
				'1017', 'Physicians / Clinic Office Nursing', @OFF
			)
		 ,(
				'1018', 'Physiotherapy', @OFF
			)
		 ,(
				'1019', 'Psychiatry Acute', @OFF
			)
		 ,(
				'1020', 'Rehabilitation', @OFF
			)
		 ,(
				'1021', 'Renal Dialysis / Nephrology', @OFF
			)
		 ,(
				'1022', 'Respiratory', @OFF
			)
		 ,(
				'1023', 'Self Employed', @OFF
			)
		 ,(
				'1024', 'Self Managed Care', @OFF
			)
		 ,(
				'1025', 'Surgical', @OFF
			)
		 ,(
				'1026', 'Other Client Care', @OFF
			)
		 ,(
				'1027', 'Young Adult Long Term', @OFF
			)
		 ,(
				'1028', 'Sub Acute', @OFF
			)
		 ,(
				'1029', 'Oncology', @OFF
			)
		 ,(
				'1030', 'Nursing Service', @OFF
			)
		 ,(
				'1031', 'Nursing Education', @OFF
			)
		 ,(
				'1032', 'Administration (other)', @OFF
			)
		 ,(
				'1033', 'Teaching - Students', @OFF
			)
		 ,(
				'1034', 'Education (other)', @OFF
			)
		 ,(
				'1035', 'Teaching - Employees', @OFF
			)
		 ,(
				'1036', 'Teaching - Patients/Clients', @OFF
			)
		 ,(
				'1037', 'Research Only', @OFF
			)
		 ,(
				'1038', 'Research (other)', @OFF
			)
		 ,(
				'1039', 'Public Health', @OFF
			)
		 ,(
				'1040', 'Primary Care Network/Clinic', @OFF
			)
		 ,(
				'9998', 'Other', @OFF
			)


			insert
				dbo.PracticeArea
			(
				PracticeAreaCode
			 ,PracticeAreaName
			 ,IsDefault
			 ,CreateUser
			 ,UpdateUser
			)
			select
				PracticeAreaCode
			 ,PracticeAreaName
			 ,IsDefault
			 ,@SetupUser
			 ,@SetupUser
			from
				@setup;

			-- check count of @setup table and the target table
			-- target should have exactly as many rows as @setup

			select	@sourceCount = count(1) from	@setup;
			select	@targetCount = count(1) from	dbo.PracticeArea;

			if isnull(@targetCount, 0) <> @sourceCount
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'SetupNotSynchronized'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'Synchronization of setup codes not complete. Source table count is %1 but target table (%2) count is %3.'
				 ,@Arg1 = @sourceCount
				 ,@Arg2 = 'dbo.PracticeArea'
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
