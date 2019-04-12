SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pCity#Lookup]
	 @CityName								nvarchar(30)																	-- name of city to lookup
	,@StateProvinceSID				int						= null													-- key of parent stateProvince 
	,@CountrySID							int						= null													-- key of parent country - look for default state province
	,@IsAddEnabled						bit						= null													-- rule indicating if value not found can be added
	,@CitySID									int						output													-- key of the dbo.City record found or added
as
/*********************************************************************************************************************************
Procedure	: Lookup State Province
Notice		: Copyright © 2017 Softworks Group Inc. 
Summary		: Subroutine to lookup a city key based on a name - adds new record it if not found (conditional)
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-------------------------------------------------------------------------------------------
					: Tim Edlund	| Apr 2017		|	Initial version (re-write)
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------

This procedure is used when processing staged data. It attempts to find a primary key value for the dbo.City table based
on a string identifier (name) passed in. The routine is called in conversion scenarios where the primary key value of the
target master table cannot be established on initial loading. The search is run against the name and legacy key columns in 
the master table. 

if the @IsAddEnabled is ON (1) - then a record will be added by the procedure provided a StateProvinceSID is found. The 
state-province key value can be passed in or looked up as the default where it was not passed in.  

Matching on Legacy Key
----------------------
Normal searches occur on the name column but where modeling or the upgrade process in general have forced names to be changed, the 
key value from the old system can be placed into the LegacyKey column in the Alinity master table. Instead of filling in the 
CityName with the actual city, it can be set to the key value from the old system. This procedure will attempt to match the string
provided to the LegacyKey column in the master table and where found, the resulting key is used.  NOTE that this method must only
be used where @IsAddEnabled is passed as OFF. Do this by creating and setting an sf.ConfigParam "AutoAddCities" to (bit) 0 (the
default when not defined is 1).  Otherwise the procedure will add new records using the key value from the old system as the name!

Not Found (default not returned)
--------------------------------
If a value is not found and no record can be added, then nothing is returned. Even where a default city exists in the 
table, it must be selected by the caller.  This is done in order to establish whether the value(s) passed in resulted in a 
successful lookup or new record.

Example:
--------
<TestHarness>
	<Test Name="OneValidInput" IsDefault="true" Description="Calls lookup procedure with a valid input and default country.">
		<SQLScript>
			<![CDATA[
declare
	 @citySID							int
	,@cityName						nvarchar(30)
	,@isAddEnabled				bit
	,@countrySID					int
	,@stateProvinceSID		int

set @cityName				= 'Edmonton'
set @isAddEnabled		= 1

exec dbo.pCountry#Lookup
	 @ISOA3					= 'CAN'
	,@CountrySID		= @countrySID	output																		-- lookup country key first

exec dbo.pCity#Lookup
	 @CityName						= @cityName
	,@StateProvinceSID		= @stateProvinceSID
	,@CountrySID					= @countrySID
	,@IsAddEnabled				= @isAddEnabled
	,@CitySID							= @citySID  output

select
	 @cityName						[@CityName]
	,@stateProvinceSID		[@StateProvinceSID]
	,@countrySID					[@CountrySID]
	,@isAddEnabled				[@IsAddEnabled]
	,@CitySID							[@CitySID]
	,*
from
	dbo.City x
where
	x.CitySID = @citySID
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:01" />
		</Assertions>
	</Test>
	<Test Name="StateProvince" Description="Calls lookup procedure passing state province key - should find city.">
		<SQLScript>
			<![CDATA[
declare
	 @citySID							int
	,@cityName						nvarchar(30)
	,@isAddEnabled				bit
	,@countrySID					int
	,@stateProvinceSID		int

set @cityName						= 'Edmonton'
set @isAddEnabled				= 1

exec dbo.pStateProvince#Lookup
	 @StateProvinceCode		= 'AB'
	,@IsAddEnabled				= 0
	,@StateProvinceSID		= @stateProvinceSID output												-- lookup state-province key first

exec dbo.pCity#Lookup
	 @CityName						= @cityName
	,@StateProvinceSID		= @stateProvinceSID
	,@CountrySID					= @countrySID
	,@IsAddEnabled				= @isAddEnabled
	,@CitySID							= @citySID  output

select
	 @cityName						[@CityName]
	,@stateProvinceSID		[@StateProvinceSID]
	,@countrySID					[@CountrySID]
	,@isAddEnabled				[@IsAddEnabled]
	,@CitySID							[@CitySID]
	,*
from
	dbo.City x
where
	x.CitySID = @citySID
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:01" />
		</Assertions>
	</Test>
	<Test Name="BlockAdd" Description="Calls lookup procedure with value that won't be found but with add-rule turned off.">
		<SQLScript>
			<![CDATA[
declare
	 @citySID							int
	,@cityName						nvarchar(30)
	,@isAddEnabled				bit
	,@countrySID					int
	,@stateProvinceSID		int

set @cityName						= 'Add Me!'
set @isAddEnabled				= 0

exec dbo.pCountry#Lookup
	 @ISOA3					= 'CAN'
	,@CountrySID		= @countrySID	output																		-- lookup country key first

update dbo.StateProvince set IsDefault = cast(1 as bit) where StateProvinceCode = 'AB'

exec dbo.pCity#Lookup
	 @CityName						= @cityName
	,@StateProvinceSID		= @stateProvinceSID
	,@CountrySID					= @countrySID
	,@IsAddEnabled				= @isAddEnabled
	,@CitySID							= @citySID  output

select
	 @cityName						[@CityName]
	,@stateProvinceSID		[@StateProvinceSID]
	,@countrySID					[@CountrySID]
	,@isAddEnabled				[@IsAddEnabled]
	,@CitySID							[@CitySID]
	,*
from
	dbo.City x
where
	x.CitySID = @citySID
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="EmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:01" />
		</Assertions>
	</Test>
	<Test Name="AllowAdd" Description="Calls lookup procedure with inputs that will not be found with adding rule ON (row should be added).">
		<SQLScript>
			<![CDATA[
declare
	 @citySID							int
	,@cityName						nvarchar(30)
	,@isAddEnabled				bit
	,@countrySID					int
	,@stateProvinceSID		int

set @cityName						= 'Add Me!'
set @isAddEnabled				= 1

exec dbo.pCountry#Lookup
	 @ISOA3					= 'CAN'
	,@CountrySID		= @countrySID	output																		-- lookup country key first

update dbo.StateProvince set IsDefault = cast(1 as bit) where StateProvinceCode = 'AB'

exec dbo.pCity#Lookup
	 @CityName						= @cityName
	,@StateProvinceSID		= @stateProvinceSID
	,@CountrySID					= @countrySID
	,@IsAddEnabled				= @isAddEnabled
	,@CitySID							= @citySID  output

select
	 @cityName						[@CityName]
	,@stateProvinceSID		[@StateProvinceSID]
	,@countrySID					[@CountrySID]
	,@isAddEnabled				[@IsAddEnabled]
	,@CitySID							[@CitySID]
	,*
from
	dbo.City x
where
	x.CitySID = @citySID

delete dbo.City where CityName = 'Add Me!'
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:01" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pCity#Lookup'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

set nocount on
																																																																			
begin  

	declare
		 @errorNo                         int = 0                             -- 0 no error, <50000 SQL error, else business rule
		,@errorText                       nvarchar(4000)                      -- message text (for business rule errors)    
		,@ON                              bit = cast(1 as bit)                -- used on bit comparisons to avoid multiple casts
		,@OFF                             bit = cast(0 as bit)                -- used on bit comparisons to avoid multiple casts

	set @CitySID	= null																										-- initialize output values

	begin try

		-- check parameters

		if @CityName is null 
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@CityName'

			raiserror(@errorText, 18, 1)
		end

		-- lookup configuration value if not provided

		if @IsAddEnabled is null
		begin
			set @IsAddEnabled = isnull(convert(bit, sf.fConfigParam#Value('AutoAddCities')), '1')
		end

		-- attempt the lookup on values

		select top 1
			@CitySID = cty.CitySID
		from
			dbo.City cty
		where
			cty.StateProvinceSID = isnull(@StateProvinceSID,cty.StateProvinceSID)													-- filter by state-province if provided
		and
		(
			cty.CityName	= @CityName																																			-- then match on name
		or 
			isnull(cty.LegacyKey,'~')= @CityName																													-- or legacy key
		)
		order by
			(																																															-- set priority for matched records
				case
					when isnull(cty.LegacyKey,'~')= @CityName												then 1
					when cty.CityName							= @CityName												then 2
					else 9
				end
			)

		if @CitySID is null and @IsAddEnabled = @ON																											-- if enabled add new record
		begin

			if @StateProvinceSID is null and @CountrySID is not null
			begin

				select 
					@StateProvinceSID = x.StateProvinceSID 
				from 
					dbo.StateProvince x 
				where 
					x.IsDefault = @ON
				and
					x.CountrySID = @CountrySID

			end

			if @StateProvinceSID is not null
			begin

				exec dbo.pCity#Insert
					 @CityName							= @CityName
					,@StateProvinceSID			= @StateProvinceSID
					,@IsAdminReviewRequired = @ON
					,@CitySID								= @CitySID	output																								-- key of new row is returned

			end

		end

	end try

	begin catch
		if @@trancount > 0 rollback
		exec @errorNo = sf.pErrorRethrow																																-- catch the error, rollback if pending, and re-throw
	end catch

	return(@errorNo)

end
GO
