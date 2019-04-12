SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pCity#DuplicateCheck]
	 @CityName												varchar(30)                           -- name of the city to check
	,@StateProvinceSID						    int               = null              -- key of state/province city belongs in (optional)
as
/*********************************************************************************************************************************
Procedure City Duplicate Check
Notice    Copyright © 2010-2014 Softworks Group Inc.
Summary   Returns list of Cities which match or partially match the parameters provided
-----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)			| Month Year	| Change Summary
				 : ---------------|-------------|------------------------------------------------------------------------------------------
				 : Tim Edlund			| Jan	2014		| Initial version
				 : Adam Panter		| June 2014		| Updating Test Assertions
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------

This procedure supports a wizard-styled UI where the user has entered values to establish a new City record. The routine
assists the user in avoiding the creation of a duplicate record. The parameter values are used to search against possible matches 
in dbo.City.

When potential matches are found, they are returned to the caller (the UI) at which point the user may choose to inspect an
existing City record or apply the parameters entered into a new City record. 

When no rows are returned by this procedure then the values entered are unique and a new City record should be created. This
procedure does NOT call the pCity#Insert to actually insert the record.

The procedure returns records which fully or partially match the city name.  If a state-province key is provided, and matching
city names are located there, then a higher "rank" score is returned.  The data set also includes a even/odd column to support
striping grid rows in the UI for easier reading.  Note that the UI should also highlight ("box") the number of characters in 
matching city and state province names so that the user can see the portion of the name that matches the string entered.  

<TestHarness>																														-- tags used by test harness generator - DO NOT REMOVE
<Test Name="PartialMatch" >																							-- key word "Test" followed by name for test 
	<SQLScript>
		<![CDATA[
declare
	 @cityName								varchar(50)
	,@stateProvinceSID				int
  
select top 1																															-- select a row that will be found at random
	 @cityName						= left(c.CityName,3)
	,@stateProvinceSID		= c.StateProvinceSID
from
	dbo.vCity c
order by
	newid()

print @cityName																														-- print search string to console for comparison

exec dbo.pCity#DuplicateCheck																							-- call procedure to return the data set
	 @CityName						= @cityName
	,@StateProvinceSID		= @stateProvinceSID
]]>
	</SQLScript>
	<Assertions>
	  <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
	  <Assertion Type="ExecutionTime" Value="00:00:01" />
	</Assertions>
	</Test>

	<Test Name = "ExactMatch" Description="Ensures an exact match on city name and province comes back as a duplicate">
	<SQLScript>
	<![CDATA[

declare
	@cityName								varchar(50)
	,@stateProvinceSID				int

select top 1
	 @cityName						= c.CityName
	,@stateProvinceSID		= c.StateProvinceSID
from
	dbo.vCity c
order by
	newid()

print @cityName

exec dbo.pCity#DuplicateCheck
	 @CityName						= @cityName
	,@StateProvinceSID		= @stateProvinceSID

	]]>
	</SQLScript>
	<Assertions>
	  <Assertion Type="RowCount" ResultSet="1" Value="1" />
	  <Assertion Type="ExecutionTime" Value="00:00:01" />
	</Assertions>
	</Test>

	<Test Name = "BlankCityName" Description="Ensures the procedure returns an error if the city name is passed in as NULL">
	<SQLScript>
	<![CDATA[
begin try

	exec dbo.pCity#DuplicateCheck
			@CityName = NULL
			,@StateProvinceSID = 1000001

end try
begin catch

	select 
		'ERROR'						TestResult
		,error_number()		ErrorNo
		,error_message()	ErrorMessage

end catch
	]]>
</SQLScript>
<Assertions>
	<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="1" Value="ERROR" />
	<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="2" Value="50000" />
  <Assertion Type="ExecutionTime" Value="00:00:02" />
</Assertions>
</Test>

<Test Name="InvalidStateProvince" Description="Ensures the procedure returns an error if the state/province SID passed in is invalid">
<SQLScript>
<![CDATA[
begin try

	exec dbo.pCity#DuplicateCheck
			@CityName = N'Calgary'
			,@StateProvinceSID = -1

end try
begin catch

	select 
		'ERROR'						TestResult
		,error_number()		ErrorNo
		,error_message()	ErrorMessage

end catch
]]>
</SQLScript>
<Assertions>
	<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="1" Value="ERROR"/>
	<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="2" Value="50000" />
  <Assertion Type="ExecutionTime" Value="00:00:02" />
</Assertions>
</Test>
</TestHarness>

exec sf.pUnitTest#Execute																								-- add the tests defined here to the test harness
		@ObjectName = N'dbo.pCity#DuplicateCheck'

-------------------------------------------------------------------------------------------------------------------------------- */

set nocount on

begin

  declare
 		 @errorNo                         int = 0															-- 0 no error, <50000 SQL error, else business rule
		,@errorText                       nvarchar(4000)											-- message text (for business rule errors)
		,@blankParm												varchar(50)													-- tracks if any required parameters are not provided
		,@cityNamePartial									nvarchar(31)												-- adds like operator - % - to search criteria provided
		,@cityNameMatchLen								int																	-- length of search string on city name

	begin try
		
		-- check parameters

		if @CityName  is null set @blankParm = 'CityName'

		if @blankParm is not null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= @blankParm

			raiserror(@errorText, 18, 1)
		
		end    

		if @StateProvinceSID is not null and not exists( select 1 from dbo.StateProvince sp where sp.StateProvinceSID = @StateProvinceSID )
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'RecordNotFound'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'The "%1" record was not found. Record ID = %2. The record may have been deleted or the identifier is invalid.'
				,@Arg1					= N'State/Province'
				,@Arg2					= @StateProvinceSID

			raiserror(@errorText, 18, 1)
		
		end  

		-- format the values for searching

		set @CityName						= ltrim(rtrim(@CityName))																								-- remove extraneous spaces
		if right(@CityName, 1)	= '%' set @CityName = left(@CityName, len(@CityName - 1))								-- trim wild card if provided	
		set @cityNameMatchLen = len(@CityName)

		set @cityNamePartial = @CityName + N'%'																													-- store partial string search

    -- return matches

    select
				 z.CitySID
				,z.IsActive
        ,z.CityName
        ,z.StateProvinceName
				,z.CountryName
			  ,z.CityNameMatchLen
			  ,z.StateProvinceMatchLen
				,z.RankOrder	
      ,cast(case when (row_number() over (order by z.RankOrder desc, z.CityName desc))%2 = 0 then 1 else 0 end as bit) IsEven                      -- for striping every other line in UI
    from
    (
		  select
				 x.CitySID
				,x.IsActive
        ,x.CityName
        ,x.StateProvinceName
				,x.CountryName
			  ,x.CityNameMatchLen
			  ,x.StateProvinceMatchLen
				,x.RankOrder	
		    from
		    (
          select
						 c.CitySID
						,c.IsActive
            ,c.CityName
            ,sp.StateProvinceName
						,ctry.CountryName
            ,case																																																		              -- assign points on matches for rank order
				      when c.CityName = @CityName and c.StateProvinceSID = isnull(@StateProvinceSID,0)						then 6
				      when c.CityName like @cityNamePartial and c.StateProvinceSID = isnull(@StateProvinceSID,0)	then 5
							when c.CityName = @CityName	and @StateProvinceSID is null																		then 4																									 
							when c.CityName like @cityNamePartial and @StateProvinceSID is null													then 3
							when c.CityName = @CityName																																	then 2
							when c.CityName like @cityNamePartial																												then 1
				      else 0
			       end																																		                                              RankOrder

						,case
								when c.CityName like @cityNamePartial																											then @cityNameMatchLen
								else 0
							end																																																									CityNameMatchLen

			      ,case																																																	                
				      when c.StateProvinceSID = @StateProvinceSID																									then len(sp.StateProvinceName)
				      else 0
			       end																																		                                              StateProvinceMatchLen

		      from
			      dbo.City					c
					join
						dbo.StateProvince	sp on c.StateProvinceSID = sp.StateProvinceSID
					join
						dbo.Country				ctry on sp.CountrySID = ctry.CountrySID
					where
						c.CityName like @cityNamePartial
	      ) x
    ) z
	  order by
       z.RankOrder    desc	
		  ,z.CityName			desc

	end try

	begin catch
		exec @errorNo = sf.pErrorRethrow																			-- catch the error, rollback if pending, and re-throw
	end catch

	return(@errorNo)

end
GO
