SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pSetup$SF#UnitType]
	 @SetupUser											nvarchar(75)											      -- user assigned to audit columns
	,@Language                      char(2)                                 -- language to install for
	,@Region                        varchar(10)                             -- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup sf.UnitType data
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : Updates sf.UnitType master table with starting values for the application when empty
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Tim Edlund		| Apr			2017  | Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------
This procedure is responsible for creating the default records for the sf.UnitType table. 

The data is only inserted if the table contains no records.  Otherwise, the procedure makes no changes to the database.  
The table will contain no records when the product is first installed.

Keep in mind the pSetup (parent) procedure is run not only for installation, but also after each upgrade. This ensures any new
tables receive starting values. Tables like this one may be setup with whatever data makes sense to the end user and, therefore,
must not be modified during upgrades. This is achieved by avoiding execution if any records are found in the table. 


<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully. If no child records exist, previous set up data is deleted prior to test.">
		<SQLScript>
		<![CDATA[		

			exec dbo.pSetup$SF#UnitType
				 @SetupUser = 'system@alinityapp.com'
				,@Language = 'EN'
				,@Region = 'CA'

			select * from sf.UnitType

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'sf.pSetup$SF#UnitType'
	,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */

set nocount on
																																																																			
begin  

	declare
		 @errorNo                           int = 0                           -- 0 no error, if < 50000 SQL error, else business rule
		,@errorText                         nvarchar(4000)                    -- message text (for business rule errors)
		,@ON																bit = cast(1 as bit)							-- constant for bit = 1
		,@OFF																bit = cast(0 as bit)							-- constant for bit = 0

	begin try

		if not exists (select top 1 ut.UnitTypeSID from sf.UnitType ut)
		begin
		
			insert
				sf.UnitType
			(
				 UnitTypeLabel
				,IsDefault
				,CreateUser
				,UpdateUser
			) 
			values                   
				 (N'Hours'								,@ON	,@SetupUser ,@SetupUser)
				,(N'Education Credits'		,@OFF	,@SetupUser ,@SetupUser)

		end

	end try

	begin catch
		exec @errorNo = sf.pErrorRethrow
	end catch

	return(@errorNo)

end
GO
