SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pSetup$StateProvince]
	 @SetupUser											nvarchar(75)											      -- user assigned to audit columns
	,@Language                      char(2)                                 -- language to install for
	,@Region                        varchar(10)         										-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup dbo.StateProvince data
Notice   : Copyright © 2012 Softworks Group Inc.
Summary  : updates dbo.StateProvince master table with starting values for the application
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Tim Edlund		| Apr 2017			| Initial Version (re-write)
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------
This procedure is responsible for creating the initial data set in the dbo.StateProvince table and for updating it with missing 
values. The procedure includes states and provinces for a limited set of countries. Only missing country codes are added.  The 
routine avoids duplicates by checking for the state province name and code.  Note that if the parent country of the state-province 
is missing, then the record is not inserted.

The procedure also updates the Is-StateProvince-Required bit to ON where state-province values exist for a country. 

The values inserted into the temporary table are joined to the dbo.Country table on name in order to avoid hard coded references
to specific identity column values for the primary key.  Identity values may not be consistent between installations.  An outer 
join is used to check for the existence of the StateProvince record so that only new records are inserted.

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully. If no child records exist, previous set up data is deleted prior to test.">
		<SQLScript>
		<![CDATA[

			if	not exists (select 1 from dbo.City)
			begin
				delete from dbo.StateProvince
				dbcc checkident( 'dbo.StateProvince', reseed, 1000000) with NO_INFOMSGS
			end
			exec dbo.pSetup$StateProvince
				 @SetupUser = 'system@alinityapp.com'
				,@Language = 'EN'
				,@Region = 'CA'

			select 
				 x.CountryName
				,x.IsStateProvinceRequired
				,x.StateProvinceName
				,x.StateProvinceCode
			from 
				dbo.vStateProvince x
			order by
				 x.CountryName
				,x.StateProvinceName

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$StateProvince'
	,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */

set nocount on
																																																																			
begin  

	declare
		 @errorNo                           int = 0                           -- 0 no error, if < 50000 SQL error, else business rule
		,@errorText                         nvarchar(4000)                    -- message text (for business rule errors)
		,@ON																bit = cast(1 as bit)							-- used on bit comparisons to avoid multiple casts
		,@OFF																bit = cast(0 as bit)							-- used on bit comparisons to avoid multiple casts	
		,@sourceCount                       int                               -- count of rows in the source table
		,@targetCount                       int                               -- count of rows in the target table

	declare
		@sample                             table
		(
			 ID                               int           identity(1,1)
			,CountryName                      nvarchar(50)  not null
			,StateProvinceName                nvarchar(30)  not null
			,StateProvinceCode                nvarchar(5)   not null
		)
		
	begin try

		insert 
			@sample 
		(
			 CountryName
			,StateProvinceName
			,StateProvinceCode
		)
		values																																-- values are sorted alphabetically
			 (N'Australia', N'Australian Capital Territory', N'ACT')
			,(N'Australia', N'New South Wales', N'NSW')
			,(N'Australia', N'Northern Territory', N'NT')
			,(N'Australia', N'Queensland', N'QLD')
			,(N'Australia', N'South Australia', N'SA')
			,(N'Australia', N'Tasmania', N'TAS')
			,(N'Australia', N'Victoria', N'VIC')
			,(N'Australia', N'Western Australia', N'WA')
			,(N'Canada', N'Alberta', N'AB')
			,(N'Canada', N'British Columbia', N'BC')
			,(N'Canada', N'Manitoba', N'MB')
			,(N'Canada', N'New Brunswick', N'NB')
			,(N'Canada', N'Newfoundland and Labrador', N'NL')
			,(N'Canada', N'Northwest Territories', N'NT')
			,(N'Canada', N'Nova Scotia', N'NS')
			,(N'Canada', N'Nunavut', N'NU')
			,(N'Canada', N'Ontario', N'ON')
			,(N'Canada', N'Prince Edward Island', N'PE')
			,(N'Canada', N'Quebec', N'QC')
			,(N'Canada', N'Saskatchewan', N'SK')
			,(N'Canada', N'Yukon Territory', N'YT')
			,(N'Mexico', N'Aguascalientes', N'AG')
			,(N'Mexico', N'Baja California', N'BJ')
			,(N'Mexico', N'Baja California Sur', N'BS')
			,(N'Mexico', N'Campeche', N'CP')
			,(N'Mexico', N'Chiapas', N'CH')
			,(N'Mexico', N'Chihuahua', N'CI')
			,(N'Mexico', N'Coahuila', N'CU')
			,(N'Mexico', N'Colima', N'CL')
			,(N'Mexico', N'Distrito Federal', N'DF')
			,(N'Mexico', N'Durango', N'DG')
			,(N'Mexico', N'Guanajuato', N'GJ')
			,(N'Mexico', N'Guerrero', N'GR')
			,(N'Mexico', N'Hidalgo', N'HG')
			,(N'Mexico', N'Jalisco', N'JA')
			,(N'Mexico', N'Mexico', N'EM')
			,(N'Mexico', N'Michoacan', N'MH')
			,(N'Mexico', N'Morelos', N'MR')
			,(N'Mexico', N'Nayarit', N'NA')
			,(N'Mexico', N'Nuevo Leon', N'NL')
			,(N'Mexico', N'Oaxaca', N'OA')
			,(N'Mexico', N'Pueblo', N'PU')
			,(N'Mexico', N'Queretaro', N'QA')
			,(N'Mexico', N'Quintana Roo', N'QR')
			,(N'Mexico', N'San Luis Potosi', N'SL')
			,(N'Mexico', N'Sinaloa', N'SI')
			,(N'Mexico', N'Sonora', N'SO')
			,(N'Mexico', N'Tabasco', N'TA')
			,(N'Mexico', N'Tamaulipas', N' TM')
			,(N'Mexico', N'Tlaxcala', N'TL')
			,(N'Mexico', N'Veracruz', N'VZ')
			,(N'Mexico', N'Yucatan', N'YC')
			,(N'Mexico', N'Zacatecas', N'ZT')
			,(N'United Kingdom', N'England', N'ENG')
			,(N'United Kingdom', N'Isle of Man', N'IOM')
			,(N'United Kingdom', N'Northern Ireland', N'NIR')
			,(N'United Kingdom', N'Scotland', N'SCT')
			,(N'United Kingdom', N'Wales', N'WLS')
			,(N'United Kingdom', N'Channel Islands', N'CHA')
			,(N'United States', N'Alabama', N'AL')
			,(N'United States', N'Alaska', N'AK')
			,(N'United States', N'Arizona', N'AZ')
			,(N'United States', N'Arkansas', N'AR')
			,(N'United States', N'California', N'CA')
			,(N'United States', N'Connecticut', N'CT')
			,(N'United States', N'Delaware', N'DE')
			,(N'United States', N'District of Columbia', N'DC')
			,(N'United States', N'Florida', N'FL')
			,(N'United States', N'Georgia', N'GA')
			,(N'United States', N'Hawaii', N'HI')
			,(N'United States', N'Idaho', N'ID')
			,(N'United States', N'Illinois', N'IL')
			,(N'United States', N'Indiana', N'IN')
			,(N'United States', N'Iowa', N'IA')
			,(N'United States', N'Kansas', N'KS')
			,(N'United States', N'Kentucky', N'KY')
			,(N'United States', N'Louisiana', N'LA')
			,(N'United States', N'Maine', N'ME')
			,(N'United States', N'Maryland', N'MD')
			,(N'United States', N'Massachusetts', N'MA')
			,(N'United States', N'Michigan', N'MI')
			,(N'United States', N'Minnesota', N'MN')
			,(N'United States', N'Mississippi', N'MS')
			,(N'United States', N'Missouri', N'MO')
			,(N'United States', N'Montana', N'MT')
			,(N'United States', N'Nebraska', N'NE')
			,(N'United States', N'Nevada', N'NV')
			,(N'United States', N'New Hampshire', N'NH')
			,(N'United States', N'New Jersey', N'NJ')
			,(N'United States', N'New Mexico', N'NM')
			,(N'United States', N'New York', N'NY')
			,(N'United States', N'North Carolina', N'NC')
			,(N'United States', N'North Dakota', N'ND')
			,(N'United States', N'Ohio', N'OH')
			,(N'United States', N'Oklahoma', N'OK')
			,(N'United States', N'Oregon', N'OR')
			,(N'United States', N'Pennsylvania', N'PA')
			,(N'United States', N'Rhode Island', N'RI')
			,(N'United States', N'South Carolina', N'SC')
			,(N'United States', N'South Dakota', N'SD')
			,(N'United States', N'Tennessee', N'TN')
			,(N'United States', N'Texas', N'TX')
			,(N'United States', N'Utah', N'UT')
			,(N'United States', N'Vermont', N'VT')
			,(N'United States', N'Virginia', N'VA')
			,(N'United States', N'Washington', N'WA')
			,(N'United States', N'West Virginia', N'WV')
			,(N'United States', N'Wisconsin', N'WI')
			,(N'United States', N'Wyoming', N'WY')

		insert
			dbo.StateProvince
		(
			 StateProvinceName
			,StateProvinceCode
			,CountrySID
			,IsDisplayed
			,CreateUser
			,UpdateUser
		) 
		select
			 x.StateProvinceName
			,x.StateProvinceCode
			,c.CountrySID																												-- rows are only included if CountryName is found! (inner join)
			,@ON																																-- these countries always display state/province in addresses
			,@SetupUser
			,@SetupUser
		from
			@sample           x
		join
			dbo.Country       c			on x.CountryName = c.CountryName                                                                    -- to get the country FK, join on name
		left outer join
			dbo.StateProvince sp1		on c.CountrySID = sp1.CountrySID and x.StateProvinceName = sp1.StateProvinceName                    -- see if this row is already inserted
		left outer join
			dbo.StateProvince sp2		on c.CountrySID = sp2.CountrySID and x.StateProvinceCode = sp2.StateProvinceCode                    -- see if this row is already inserted
		where
			sp1.StateProvinceSID is null                                                                                                -- only insert rows not in existence
		and
			sp2.StateProvinceSID is null

		-- update the country table to require state provinces for 
		-- any countries which now have them

		update
			dbo.Country
		set
			 IsStateProvinceRequired = @ON
			,UpdateTime = sysdatetimeoffset()
		where
			CountrySID in (select distinct x.CountrySID from dbo.StateProvince x)

		-- check count of @sample table and the target table
		-- target should have at least as many rows as @sample

		select @sourceCount = count(1) from  @sample            
		select @targetCount = count(1) from  dbo.StateProvince

		if isnull(@targetCount,0) < @sourceCount
		begin

			exec sf.pMessage#Get
				 @MessageSCD    = 'SampleTooSmall'
				,@MessageText   = @errorText output
				,@DefaultText   = N'Insert of some sample records failed. Source table count is %1 but target table (%2) count is only %3. Check "JOIN" conditions.'
				,@Arg1          = @sourceCount
				,@Arg2          = 'dbo.StateProvince'
				,@Arg3          = @targetCount

			raiserror(@errorText, 18, 1)

		end
	end try

	begin catch
		exec @errorNo = sf.pErrorRethrow
	end catch

	return(@errorNo)

end
GO
