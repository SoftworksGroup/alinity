SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pCountry#Lookup]
	 @CountryName											nvarchar(50)	= null									-- label of Country to lookup
	,@ISOA3														char(3)				= null									-- code of Country to lookup
	,@CountrySID											int						output									-- key of the dbo.Country record found
as
/*********************************************************************************************************************************
Procedure	: Lookup Country
Notice		: Copyright © 2017 Softworks Group Inc. 
Summary		: Subroutine to lookup a CountrySID based on a name or code passed in
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)				| Month Year  | Change Summary
				 : ----------------	|	----------	| --------------
				 : Tim Edlund				| Apr 2017    | Initial version
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------

This procedure is used when processing staged data. It attempts to find a primary key value for the dbo.Country table based
on a string identifier (name or code) passed in. The routine is called in conversion scenarios where the primary key value
of the target master table cannot be established on initial loading. The search is run against the name, ISOA3 and LegacyKey
columns in the master table. 

Matching on Legacy Key
----------------------
Normal searches occur on the name column but where modeling or the upgrade process in general have forced names to be changed, the 
key value from the old system can be placed into the LegacyKey column in the Alinity master table. Instead of filling in the ISOA3 
with the actual value, it can be set to the key value from the old system. This procedure will attempt to match it to the Legacy
Key column in the master table and where found, the resulting key is used.  Legacy Key matches have a higher priority than other
matches (in case the Name matches on a different record).

Not Found (default not returned)
--------------------------------
If this procedure is called with blank search parameters, an error is returned.  While a default Country may be defined in the 
table, it is not returned by this procedure and must be selected specifically by the caller.  Note also that adding is NOT
carried out by the procedure since the product ships with a complete Country list.

Example:
--------

Note that all #Lookup procedures share very similar logic. While a single "sunny day" test scenario is provided below,
a detailed test harness examining results for all expected scenarios can be found in sf.pGender#Lookup.

<TestHarness>
	<Test Name="OneValidInput" IsDefault="true" Description="Calls lookup procedure with a valid input that will be found.">
		<SQLScript>
			<![CDATA[

declare
	 @countrySID		int
	,@isoA3					char(3)
	,@countryName		nvarchar(50)

set @countryName = 'Canada'

exec dbo.pCountry#Lookup
	 @ISOA3					= @isoA3
	,@CountryName		= @countryName
	,@CountrySID		= @countrySID  output

select
	 @isoA3				[@ISOA3]
	,@countryName	[@CountryName]
	,@CountrySID	[@CountrySID]
	,*
from
	dbo.Country x
where
	x.CountrySID = @countrySID

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
	 @countrySID		int
	,@isoA3					varchar(5)
	,@countryName		nvarchar(50)

set @isoA3				= 'gbr'
set @countryName	= 'Mexico'

exec dbo.pCountry#Lookup
	 @ISOA3					= @isoA3
	,@CountryName		= @countryName
	,@CountrySID		= @countrySID  output

select
	 @isoA3						[@ISOA3]
	,@countryName			[@CountryName]
	,@CountrySID			[@CountrySID]
	,*
from
	dbo.Country x
where
	x.CountrySID = @countrySID

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:01" />
		</Assertions>
	</Test>

</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pCountry#Lookup'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

set nocount on
																																																																			
begin  

	declare
		 @errorNo                         int = 0                             -- 0 no error, <50000 SQL error, else business rule
		,@errorText                       nvarchar(4000)                      -- message text (for business rule errors)    
		,@ON                              bit = cast(1 as bit)                -- used on bit comparisons to avoid multiple casts
		,@OFF                             bit = cast(0 as bit)                -- used on bit comparisons to avoid multiple casts

	set @CountrySID				= null																						-- initialize output values

	begin try

		-- check parameters

		if @CountryName is null and @ISOA3 is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@CountryName/@ISOA3'

			raiserror(@errorText, 18, 1)
		end

		-- attempt the lookup on values

		select top 1
			@CountrySID = ctry.CountrySID
		from
			dbo.Country ctry
		where
			ctry.CountryName	= @CountryName
		or 
			isnull(ctry.ISOA3,'x') = @ISOA3																			-- match country code or label
		or 
			isnull(ctry.LegacyKey, '~')	= @ISOA3																-- or legacy key
		order by
			(																																		-- set priority for matched records
				case
					when isnull(ctry.LegacyKey,'~')= @ISOA3													then 1
					when ctry.ISOA3	= @ISOA3																				then 2
					when ctry.CountryName	= @CountryName														then 3
					else 9
				end
			)


	end try

	begin catch
		if @@trancount > 0 rollback
		exec @errorNo = sf.pErrorRethrow																			-- catch the error, rollback if pending, and re-throw
	end catch

	return(@errorNo)

end
GO
