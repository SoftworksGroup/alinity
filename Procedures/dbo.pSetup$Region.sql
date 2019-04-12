SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pSetup$Region]
	 @SetupUser											nvarchar(75)											      -- user assigned to audit columns
	,@Language                      char(2)                                 -- language to install for
	,@Region                        varchar(10)         										-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup dbo.Region data
Notice   : Copyright © 2012 Softworks Group Inc.
Summary  : Updates dbo.Region table with starting values for the application
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Tim Edlund		| Nov	2016			| Initial Version				 
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------
This procedure ensures a default starting record exists in the dbo.Region table for startup of the application.  If any records
are found in the table, then no additional insert is made.

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully. Previous setup data is NOT deleted prior to 
	the test so the test is that 1 default record exists in the table.">
		<SQLScript>
		<![CDATA[

		exec dbo.pSetup$Region 
			 @SetupUser = N'system@softworksgroup.com'
			,@Language  = 'en'
			,@Region		= 'can'
	
		select * from dbo.Region

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$Region'
	,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */

set nocount on
																																																																			
begin  

	declare
		 @errorNo                           int = 0                           -- 0 no error, if < 50000 SQL error, else business rule
		,@errorText                         nvarchar(4000)                    -- message text (for business rule errors)
		,@OFF																bit = cast(0 as bit)							-- constant to refer to "false" bit value
		,@ON																bit = cast(1 as bit)							-- constant to refer to "true" bit value

	declare
		@setup															table
		(
			 ID																int           identity(1,1)
			,RegionName												varchar(50)		not null
			,RegionLabel											nvarchar(35)	not null
			,IsDefault												bit						not null
		)

	begin try
	
		if not exists (select 1 from dbo.Region)
		begin

			insert
				@setup
			(
				 RegionName
				,RegionLabel
				,IsDefault
			)
			values
				 ('Area 0 - Out of Province/Country'								,'Out of Province/Country'					,@ON)
				,('Area 1 - South Zone (Lethbridge & Medicine Hat)'	,'South(Lethbridge & Medicine Hat)'	,@OFF)
				,('Area 2 - Calgary Zone'														,'Calgary'													,@OFF)
				,('Area 3 - Central Zone'														,'Central(Red Deer)'								,@OFF)
				,('Area 4 - Edmonton Zone'													,'Edmonton'													,@OFF)
				,('Area 5 - North Zone'															,'North'														,@OFF)

			insert 
				dbo.Region 
			(
				 RegionName
				,RegionLabel
				,IsDefault
				,CreateUser
				,UpdateUser
			)
			select 
				 x.RegionName
				,x.RegionLabel
				,x.IsDefault
				,@SetupUser
				,@SetupUser
			from
				@setup x

		end

		-- ensure a default is set in the table

		if not exists(select 1 from dbo.Region x where x.IsDefault = @ON)
		begin

			update 
				dbo.Region
			set
				 IsDefault = @ON
				,UpdateUser = @SetupUser
				,UpdateTime = sysdatetimeoffset()
			where
				RegionSID = (select min(RegionSID) from dbo.Region)

		end

	end try

	begin catch
		exec @errorNo = sf.pErrorRethrow
	end catch
		
	return(@errorNo)

end
GO
