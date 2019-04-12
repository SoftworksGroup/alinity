SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.[pSetup$OrgType]
	@SetupUser nvarchar(75) -- user assigned to audit columns
 ,@Language	 char(2)			-- language to install for
 ,@Region		 varchar(10)	-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup dbo.OrgType data
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : Updates dbo.OrgType table with starting values for the application
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Tim Edlund		| Sep 2017			| Initial Version				 
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------
This procedure establishes some sample records in the dbo.OrgType for end users to work with on new configurations.
The records are only added if no records exist in the table.  The Organization Type table is maintained by end users and may
contain any values and coding. 

The code values inserted correspond to a standard for Organization Types required by CIHI (as of 2017).  Note that the code
prefix '99' is reserved for non-employer types of organizations.  (Duplicate codes are not permitted.)

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully.">
		<SQLScript>
		<![CDATA[

		exec dbo.pSetup$OrgType 
			 @SetupUser = N'system@softworksgroup.com'
			,@Language  = 'en'
			,@Region		= 'can'
	
		select * from dbo.OrgType

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$OrgType'
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
		ID					int					 identity(1, 1)
	 ,OrgTypeCode varchar(20)	 not null
	 ,OrgTypeName nvarchar(50) not null
	 ,IsDefault		bit					 not null
	);

	begin try

		if not exists (select 1 from dbo .OrgType)
		begin

-- SQL Prompt formatting off
			insert
				@setup (OrgTypeName, OrgTypeCode, IsDefault)
			values
				(N'None', '0', @ON)
			 ,(N'Placeholder (required for conversion)', 'S!PLACEHOLDER ', @OFF)
			 ,(N'Hospital (General/Maternal/Paediatric/Psychiatry)', '1', @OFF)
			 ,(N'Mental Health Centre', '2', @OFF)
			 ,(N'Nursing Stations (Outposts or Clinics)', '3', @OFF)
			 ,(N'Rehabilitation/Convalescent Centre', '4', @OFF)
			 ,(N'Nursing Home/Long Term Care', '5', @OFF)
			 ,(N'Home Care Agency', '6', @OFF)
			 ,(N'Community Health/Health Centre', '7', @OFF)
			 ,(N'Business/Industry/Occupational Health Centre', '8', @OFF)
			 ,(N'Private Nursing Agency/Private Duty', '9', @OFF)
			 ,(N'Self-Employed', '10', @OFF)
			 ,(N'Physician''s Office/Family Practice Unit', '11', @OFF)
			 ,(N'Educational Institution', '12', @OFF)
			 ,(N'Association/Government', '13', @OFF)
			 ,(N'Other', '14', @OFF)
			 ,(N'Education', '99.01', @OFF)
			 ,(N'Hearing Facility', '99.02', @OFF)
			 ,(N'Writing Centre', '99.03', @OFF)
			 ,(N'Stakeholder', '99.04', @OFF);
-- SQL Prompt formatting on

			insert
				dbo.OrgType (OrgTypeCode, OrgTypeName, IsDefault, CreateUser, UpdateUser)
			select OrgTypeCode , OrgTypeName, IsDefault, @SetupUser, @SetupUser from @setup ;

			-- check count of @setup table and the target table
			-- target should have exactly as many rows as @setup

			select @sourceCount	 = count(1) from @setup ;
			select @targetCount	 = count(1) from dbo .OrgType;

			if isnull(@targetCount, 0) <> @sourceCount
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'SetupNotSynchronized'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'Synchronization of setup codes not complete. Source table count is %1 but target table (%2) count is %3.'
				 ,@Arg1 = @sourceCount
				 ,@Arg2 = 'dbo.OrgType'
				 ,@Arg3 = @targetCount;

				raiserror(@errorText, 18, 1);
			end;
		end;

		-- ensure required system codes are in place in the table

		if not exists
		(
			select 1 from		dbo.OrgType ot where ot.OrgTypeCode = 'S!PLACEHOLDER'
		)
		begin

			insert
				dbo.OrgType (OrgTypeName, OrgTypeCode)
			values
			(
				N'Placeholder (required for conversion)', 'S!PLACEHOLDER'
			);

		end;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);

end;
GO
