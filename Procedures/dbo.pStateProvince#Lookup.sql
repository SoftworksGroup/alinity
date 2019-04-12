SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pStateProvince#Lookup]
	 @StateProvinceName								nvarchar(30)	= null									-- name of state-province to lookup
	,@StateProvinceCode								nvarchar(5)		= null									-- code of state-province to lookup
	,@CountrySID											int						= null									-- key of parent country (for adding of new record)
	,@IsAddEnabled										bit						= null									-- rule indicating if value not found can be added
	,@StateProvinceSID								int							output								-- key of the dbo.StateProvince record found or added
as
/*********************************************************************************************************************************
Procedure	: Lookup State Province
Notice		: Copyright © 2016 Softworks Group Inc. 
Summary		: Subroutine to lookup a state-province key based on a name or code - adds new record it if not found (conditional)
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-------------------------------------------------------------------------------------------
					: Tim Edlund	| Apr 2017		|	Initial version (re-write)
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------

This procedure is used when processing staged data. It attempts to find a primary key value for the dbo.StateProvince table based
on a string identifier (name or code) passed in. The routine is called in conversion scenarios where the primary key value of the
target master table cannot be established on initial loading. The search is run against the name, code, and legacy-key columns 
in the master table.

if the @IsAddEnabled is ON (1) - then a record will be added by the procedure provided a CountrySID is found. The Country
key value can be passed in or looked up as the default where it was not passed in.

Matching on Legacy Key
----------------------
Normal searches occur on the name and code columns but where modeling or the upgrade process in general have forced names to be 
changed, the key value from the old system can be placed into the LegacyKey column in the Alinity master table. Instead of filling 
in the code with the actual value (e.g "AB"), it can be set to the key value from the old system. This procedure will attempt to 
match the code to the LegacyKey column in the master table and where found, the resulting key is used. Legacy Key matches have a 
higher priority than other matches (in case the Name matches on a different record).  NOTE that this method must only
be used where @IsAddEnabled is passed as OFF. Do this by creating and setting an sf.ConfigParam "AutoAddCities" to (bit) 0 (the
default when not defined is 1).  Otherwise the procedure will add new records using the key value from the old system as the name!

Not Found (default not returned)
--------------------------------
If the value passed is not found and no record can be added, then nothing is returned. Even where a default state-province exists 
in the table, it must be selected by the caller.  This is done in order to establish whether the value(s) passed in resulted in a 
successful lookup or new record!  

Example:
--------
<TestHarness>
	<Test Name="OneValidInput" IsDefault="true" Description="Calls lookup procedure with a valid input that will be found.">
		<SQLScript>
			<![CDATA[
declare
	 @stateProvinceSID		int
	,@stateProvinceCode		nvarchar(5)
	,@stateProvinceName		nvarchar(30)
	,@isAddEnabled				bit
	,@countrySID					int

set @stateProvinceName	= 'Alberta'
set @isAddEnabled				= 1

exec dbo.pCountry#Lookup
	 @ISOA3					= 'CAN'
	,@CountrySID		= @countrySID  output																		-- lookup country key first

exec dbo.pStateProvince#Lookup
	 @StateProvinceCode		= @stateProvinceCode
	,@StateProvinceName		= @stateProvinceName
	,@IsAddEnabled				= @isAddEnabled
	,@StateProvinceSID		= @stateProvinceSID  output

select
	 @stateProvinceCode	[@StateProvinceCode]
	,@stateProvinceName	[@StateProvinceName]
	,@countrySID				[@CountrySID]
	,@isAddEnabled			[@IsAddEnabled]
	,@StateProvinceSID	[@StateProvinceSID]
	,*
from
	dbo.StateProvince x
where
	x.StateProvinceSID = @stateProvinceSID
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:01" />
		</Assertions>
	</Test>
	<Test Name="MixedInputs" Description="Calls lookup procedure with inputs that are inconsistent. Tests priority setting on result.">
		<SQLScript>
			<![CDATA[
declare
	 @stateProvinceSID			int
	,@stateProvinceCode			nvarchar(5)
	,@stateProvinceName			nvarchar(30)
	,@isAddEnabled					bit
	,@countrySID						int

set @stateProvinceCode	= 'SK'
set @stateProvinceName	= 'Alberta'
set @isAddEnabled				= 1

exec dbo.pCountry#Lookup
	 @ISOA3					= 'CAN'
	,@CountrySID		= @countrySID  output

exec dbo.pStateProvince#Lookup
	 @StateProvinceCode		= @stateProvinceCode
	,@StateProvinceName		= @stateProvinceName
	,@IsAddEnabled				= @isAddEnabled
	,@StateProvinceSID		= @stateProvinceSID  output

select
	 @stateProvinceCode	[@StateProvinceCode]
	,@stateProvinceName	[@StateProvinceName]
	,@countrySID				[@CountrySID]
	,@isAddEnabled			[@IsAddEnabled]
	,@StateProvinceSID	[@StateProvinceSID]
	,*
from
	dbo.StateProvince x
where
	x.StateProvinceSID = @stateProvinceSID
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
	 @stateProvinceSID			int
	,@stateProvinceCode			nvarchar(5)
	,@stateProvinceName			nvarchar(30)
	,@isAddEnabled					bit
	,@countrySID						int

set @stateProvinceName	= 'DO NOT ADD ME'
set @isAddEnabled				= '0

exec dbo.pStateProvince#Lookup
	 @StateProvinceCode		= @stateProvinceCode
	,@StateProvinceName		= @stateProvinceName
	,@IsAddEnabled				= @isAddEnabled
	,@StateProvinceSID		= @stateProvinceSID  output

select
	 @stateProvinceCode	[@StateProvinceCode]
	,@stateProvinceName	[@StateProvinceName]
	,@countrySID				[@CountrySID]
	,@isAddEnabled			[@IsAddEnabled]
	,@StateProvinceSID	[@StateProvinceSID]
	,*
from
	dbo.StateProvince x
where
	x.StateProvinceSID = @stateProvinceSID
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
	 @stateProvinceSID			int
	,@stateProvinceCode			nvarchar(5)
	,@stateProvinceName			nvarchar(30)
	,@isAddEnabled					bit
	,@countrySID						int

set @stateProvinceName	= 'OK ADD ME'
set @isAddEnabled				= 1

exec dbo.pStateProvince#Lookup
	 @StateProvinceCode		= @stateProvinceCode
	,@StateProvinceName		= @stateProvinceName
	,@IsAddEnabled				= @isAddEnabled
	,@StateProvinceSID		= @stateProvinceSID  output

select
	 @stateProvinceCode	[@StateProvinceCode]
	,@stateProvinceName	[@StateProvinceName]
	,@countrySID				[@CountrySID]
	,@isAddEnabled			[@IsAddEnabled]
	,@StateProvinceSID	[@StateProvinceSID]
	,*
from
	dbo.StateProvince x
where
	x.StateProvinceSID = @stateProvinceSID

delete dbo.StateProvince where StateProvinceName = @stateProvinceName
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:01" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pStateProvince#Lookup'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

set nocount on
																																																																			
begin  

	declare
		 @errorNo                         int = 0                             -- 0 no error, <50000 SQL error, else business rule
		,@errorText                       nvarchar(4000)                      -- message text (for business rule errors)    
		,@ON                              bit = cast(1 as bit)                -- used on bit comparisons to avoid multiple casts
		,@OFF                             bit = cast(0 as bit)                -- used on bit comparisons to avoid multiple casts

	set @StateProvinceSID	= null																						-- initialize output values

	begin try

		-- check parameters

		if @StateProvinceName is null and @StateProvinceCode is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@CountryName/@StateProvinceCode'

			raiserror(@errorText, 18, 1)
		end

		-- lookup configuration value if not provided

		if @IsAddEnabled is null
		begin
			set @IsAddEnabled = isnull(convert(bit, sf.fConfigParam#Value('AutoAddCities')), '1')
		end

		-- attempt the lookup on values

		select top 1
			@StateProvinceSID = sp.StateProvinceSID
		from
			dbo.vStateProvince sp
		where
			sp.CountrySID = isnull(@CountrySID,sp.CountrySID)																							-- filter by country if provided
		and
	(
			sp.StateProvinceName	= @StateProvinceName
		or 
			isnull(sp.StateProvinceCode,'x') = @StateProvinceCode																					-- match state-province code or name
		or 
			isnull(sp.LegacyKey,'~')= @StateProvinceCode																									-- or legacy key
		)
		order by
			(																																															-- set priority for matched records - higher priority set for matches in default country
				case
					when isnull(sp.LegacyKey,'~')= @StateProvinceCode								then 1
					when sp.StateProvinceCode	= @StateProvinceCode									then 2
					when sp.StateProvinceName	= @StateProvinceName									then 3
					else 9
				end
			)

		if @StateProvinceSID is null and @IsAddEnabled = @ON																						-- add new master record if enabled
		begin

			if @CountrySID is null select @CountrySID = x.CountrySID from dbo.Country x where x.IsDefault = @ON

			if @CountrySID is not null
			begin

				if @StateProvinceCode is null set @StateProvinceCode	= left(@StateProvinceName,5)
				if @StateProvinceName is null set @StateProvinceName	= @StateProvinceCode

				exec dbo.pStateProvince#Insert
					 @StateProvinceName			= @StateProvinceName
					,@StateProvinceCode			= @stateProvinceCode
					,@CountrySID						= @CountrySID
					,@IsAdminReviewRequired = @ON
					,@StateProvinceSID			= @StateProvinceSID	output																				-- key of new row is returned

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
