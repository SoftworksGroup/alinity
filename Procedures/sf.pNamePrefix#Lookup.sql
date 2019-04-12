SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pNamePrefix#Lookup]
	 @NamePrefixLabel									nvarchar(35)													-- label of name prefix provided in the interface record
	,@NamePrefixSID										int							output								-- key of the sf.NamePrefix record found
as
/*********************************************************************************************************************************
Procedure	: Lookup Name Prefix
Notice		: Copyright © 2017 Softworks Group Inc. 
Summary		: Subroutine to lookup a NamePrefixSID based on a name prefix string value passed in
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)				| Month Year  | Change Summary
				 : ----------------	|	----------	| --------------
				 : Tim Edlund				| Apr 2017    | Initial version
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------

This procedure is used when processing staged data. It attempts to find a primary key value for the sf.NamePrefix table based
on a string identifier (label) passed in. The routine is called in conversion scenarios where the primary key value of the
target master table cannot be established on initial loading. The search is run against both the label and the LegacyKey 
column in the master table.   

Matching on Legacy Key
----------------------
Normal searches occur on the label and code columns but where modeling or the upgrade process in general have forced names to be 
changed, the key value from the old system can be placed into the LegacyKey column in the Alinity master table. Instead of filling 
in the code with the actual code value, e.g. "M", it can be set to the key value from the old system. This procedure will attempt 
to match it to the Legacy Key column in the master table and where found, the resulting key is used.  Legacy Key matches have a 
higher priority than other matches (in case the code matches on a different record).

Not Found (default not returned)
--------------------------------
If the value passed is not found nothing is returned. A default setting does not exist for this table.

Example:
--------

Note that all #Lookup procedures share very similar logic. While a single "sunny day" test scenario is provided below,
a detailed test harness examining results for all expected scenarios can be found in sf.pGender#Lookup.

<TestHarness>
	<Test Name="OneValidInput" IsDefault="true" Description="Calls lookup procedure with a valid input that will be found.">
		<SQLScript>
			<![CDATA[

declare
	 @namePrefixSID		int
	,@namePrefixLabel	nvarchar(35)

set @namePrefixLabel = 'Ms.'

exec sf.pNamePrefix#Lookup
	 @NamePrefixLabel			= @namePrefixLabel
	,@NamePrefixSID				= @namePrefixSID  output

select
	 @namePrefixLabel		[@NamePrefixLabel]
	,@NamePrefixSID			[@NamePrefixSID]
	,*
from
	sf.NamePrefix x
where
	x.NamePrefixSID = @namePrefixSID
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:01" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
		@ObjectName = 'sf.pNamePrefix#Lookup'
	,	@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

set nocount on
																																																																			
begin  

	declare
		 @errorNo                         int = 0                             -- 0 no error, <50000 SQL error, else business rule
		,@errorText                       nvarchar(4000)                      -- message text (for business rule errors)    
		,@ON                              bit = cast(1 as bit)                -- used on bit comparisons to avoid multiple casts
		,@OFF                             bit = cast(0 as bit)                -- used on bit comparisons to avoid multiple casts

	set @NamePrefixSID				= null																				-- initialize output values

	begin try

		if @NamePrefixLabel is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@NamePrefixLabel'

			raiserror(@errorText, 18, 1)
		end

		-- attempt the lookup on values

		select top (1)
			@NamePrefixSID = np.NamePrefixSID
		from
			sf.NamePrefix np
		where
			np.NamePrefixLabel						= @NamePrefixLabel										-- match name prefix on label or XID
		or 
			isnull(np.LegacyKey,'~')			= @NamePrefixLabel										-- or legacy key		
		order by																																												
			(																																		-- set priority for matched records
				case
					when isnull(np.LegacyKey,'~')	= @NamePrefixLabel	then 1
					when np.NamePrefixLabel				= @NamePrefixLabel	then 2
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
