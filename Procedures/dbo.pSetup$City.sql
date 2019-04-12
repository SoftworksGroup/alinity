SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pSetup$City]
	 @SetupUser											nvarchar(75)											      -- user assigned to audit columns
	,@Language                      char(2)                                 -- language to install for
	,@Region                        varchar(10)         										-- locale (country) to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup sf.City data
Notice   : Copyright © 2012 Softworks Group Inc.
Summary  : Inserts starting values into sf.City if no records exist in the table
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year  | Change Summary
				 : ------------ | ----------- |-------------------------------------------------------------------------------------------
				 : Christian.T  | Mar		2012  | Initial Version
				 : Tim Edlund   | Apr   2012  | Updated to use row constructor method; updated documentation
				 : Cory Ng			| Nov		2012	| Change Newfoundland code from 'NF' to 'NL' to fix sample data break
				 : Cory Ng			| Oct		2014	| Stripped down list to only include a few from major English speaking countries
				 : Tim Edlund		| Feb		2015	| Modified logic so preexisting values are not changed. Added test harness.
----------------------------------------------------------------------------------------------------------------------------------

Comments  
--------
This procedure is responsible for creating sample data in the sf.City table. The data is only inserted if the table contains
no records.  Otherwise, the procedure makes no changes to the database.  The table will contain no records when the product
is first installed.

Keep in mind the pSetup (parent) procedure is run not only for installation, but also after each upgrade. This ensures any new
tables receive starting values. Tables like this one may be setup with whatever data makes sense to the end user and, therefore,
must not be modified during upgrades. This is achieved by avoiding execution if any records are found in the table. 

The procedure uses the SQL multi-row constructor syntax to insert values into a temporary table. 

The values from the temporary table are joined to the dbo.Country table and the dbo.StateProvince table in order to avoid hard 
coded references to specific identity column values for the primary key.  Identity values may not be consistent between 
installations.  An outer join is used to check for the existence of the City record so that only new records are inserted.

The @Region parameter is examined to set a "default city".  The Region can be set to a country abbreviation:
AUS, UK, USA or CAN and a major city in that country is then set as the initial default for addressing.

Example:
--------
<TestHarness>
	<Test Name="Simple" IsDefault="true" Description="Execute procedure and checks table contents.">
		<SQLScript>
			<![CDATA[
			
exec dbo.pSetup$City 
	 @SetupUser = N'system@softworksgroup.com'
	,@Language  = 'en'
	,@Region		= 'can'
	
select * from dbo.City

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:02" />
		</Assertions>
	</Test>

	<Test Name="NoChange" Description="Delete 1 record, call the procedure then search for the deleted record. The
	procedure should not run so should not re-add the deleted record.">
		<SQLScript>
			<![CDATA[
declare
	@cityName nvarchar(30)

select top 1																									
	@cityName = x.CityName
from
	dbo.City x
where
	x.IsDefault = 0
order by
	newid()

delete																												
	City
where
	CityName = @cityName

exec dbo.pSetup$City																					
	 @SetupUser = N'system@softworksgroup.com'
	,@Language  = 'en'
	,@Region		= 'can'

select * from dbo.City x where x.CityName = @cityName
		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="EmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:02" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName			= 'dbo.pSetup$City'
	,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */

set nocount on
																																																																			
begin  

	declare
		 @errorNo                           int = 0                           -- 0 no error, if < 50000 SQL error, else business rule
		,@id                                int                               -- id of @sample row to update

	declare
		@sample                             table
		(
			 ID                               int           identity(1,1)
			,CountryName                      nvarchar(50)  not null
			,StateProvinceCode                nvarchar(5)   not null
			,CityName                         nvarchar(30)  not null
			,DefaultAreaCode									char(3)				null
			,IsDefault                        bit           not null            default cast(0 as bit)
		)
		
	begin try

		if not exists( select 1 from dbo.City )																-- only insert sample cities if table is empty
		begin

			insert 
				@sample 
			(
				 CountryName
				,StateProvinceCode
				,CityName
			)
			values                                                              -- values are sorted alphabetically
				 (N'Australia', N'NSW', N'Sydney')
				,(N'Australia', N'VIC', N'Melbourne')
				,(N'Australia', N'QLD', N'Brisbane')
				,(N'Australia', N'WA', N'Perth')
				,(N'Australia', N'SA', N'Adelaide')
				,(N'Canada', N'ON', N'Toronto')
				,(N'Canada', N'QC', N'Montreal')
				,(N'Canada', N'BC', N'Vancouver')
				,(N'Canada', N'AB', N'Calgary')
				,(N'Canada', N'AB', N'Edmonton')
				,(N'United Kingdom', N'ENG', N'London')
				,(N'United Kingdom', N'ENG', N'Birmingham')
				,(N'United Kingdom', N'SCT', N'Glasgow')
				,(N'United Kingdom', N'ENG', N'Liverpool')
				,(N'United Kingdom', N'ENG', N'Bristol')
				,(N'United Kingdom', N'ENG', N'Sheffield')
				,(N'United Kingdom', N'ENG', N'Manchester')
				,(N'United Kingdom', N'ENG', N'Leeds')
				,(N'United Kingdom', N'SCT', N'Edinburgh')
				,(N'United Kingdom', N'ENG', N'Leicester')
				,(N'United States', N'NY', N'New York')
				,(N'United States', N'CA', N'Los Angeles')
				,(N'United States', N'IL', N'Chicago')
				,(N'United States', N'TX', N'Houston')
				,(N'United States', N'PA', N'Philadelphia')
				,(N'United States', N'AZ', N'Phoenix')
				,(N'United States', N'TX', N'San Antonio')
				,(N'United States', N'CA', N'San Diego')
				,(N'United States', N'TX', N'Dallas')
				,(N'United States', N'CA', N'San Jose')
				,(N'United States', N'TX', N'Austin')
				,(N'United States', N'IN', N'Indianapolis')
				,(N'United States', N'FL', N'Jacksonville')
				,(N'United States', N'CA', N'San Francisco')
				,(N'United States', N'OH', N'Columbus')
				,(N'United States', N'NC', N'Charlotte')
				,(N'United States', N'TX', N'Fort Worth')
				,(N'United States', N'MI', N'Detroit')
				,(N'United States', N'TX', N'El Paso')
				,(N'United States', N'TN', N'Memphis')
				,(N'United States', N'WA', N'Seattle')
				,(N'United States', N'CO', N'Denver')
				,(N'United States', N'DC', N'Washington')
				,(N'United States', N'MA', N'Boston')
				,(N'United States', N'TN', N'Nashville')
		
			-- establish a default city based on region

			if @Region = 'AUS'
			begin
				select @id = s.ID from @sample s where s.CityName = N'Melbourne'
			end
			else if @Region = 'UK' 
			begin
				select @id = s.ID from @sample s where s.CityName = N'London'
			end
			else if @Region = 'CAN' 
			begin
				select @id = s.ID from @sample s where s.CityName = N'Toronto'
			end
			else if @Region = 'USA' 
			begin
				select @id = s.ID from @sample s where s.CityName = N'New York'
			end

			if @id is not null update @sample set IsDefault = cast(1 as bit) where ID = @id

			-- now insert to the target table

			insert
				dbo.City
			(
				 CityName
				,StateProvinceSID
				,IsDefault
				,CreateUser
				,UpdateUser
			) 
			select
				 x.CityName
				,sp.StateProvinceSID
				,x.IsDefault
				,@SetupUser
				,@SetupUser
			from
				@sample           x
			join
				dbo.Country       c   on x.CountryName = c.CountryName                                                                    -- to get the state province FK, join on name
			join
				dbo.StateProvince sp  on sp.CountrySID = c.CountrySID and x.StateProvinceCode = sp.StateProvinceCode                      -- and then on StateProvince code
			left outer join
				dbo.City          cty on sp.StateProvinceSID = cty.StateProvinceSID and x.CityName = cty.CityName
			where
				cty.CitySID is null

		end

	end try

	begin catch
		exec @errorNo = sf.pErrorRethrow
	end catch

	return(@errorNo)

end
GO
