SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegionMapping#Reassign]
	 @ReturnSelect								bit = 1																		-- controls whether or not to return counts of updates
as
/*********************************************************************************************************************************
Procedure : Region Mapping - Re-assign (for changes to mapping values)
Notice    : Copyright © 2017 Softworks Group Inc.
Summary   : Re-assigns Region key values to dbo.Org and dbo.PersonMailingAddress tables based on postal code 
History   : Author(s)   | Month Year | Change Summary
          : ------------|------------|-----------------------------------------------------------------------------------------
          : Tim Edlund 	| Jan	2017	 | Initial version (reviewed and test by Cory Ng)
						
Comments
--------
This procedure should be executed when mappings in the dbo.RegionMapping table have changed, or for new deployments where
the RegionSID value has not been filled in from the conversion process.  The procedure assigns Region key values to the
target tables (see below) based on matches between postal code values and templates (masks) entered into the RegionMapping
table.  These key values are stored and not derived, in order to improve reporting performance.

When @ReturnSelect is passed as ON, the procedure returns a single row dataset with the number of records updated in each 
target table formatted as a result message.

Region values can be used to create geographic groups based on postal/zip codes.  A mask postal code value, which may include
embedded wild card characters, is entered into the dbo.Region table.  The mask value is then compared to all postal codes
in the target tables (dbo.Org, dbo.PersonMailingAddress) and matching records are assigned the associated region. This allows
Region groupings to be as fined grained as areas within cities and towns, or as course and groups of countries.  

After processing the last assigned time is set to a configuration parameter. This value is compared to the time the last
region mapping was updated and prompts the user to run this procedure.

WARNING: On configurations with large numbers of target table records, it may be necessary to call this procedure as a 
background or scheduled basis in order to avoid timing out in the web client application.

Extended logic not applied (EF sprocs called)!
----------------------------------------------
Note that the EF update sprocs are NOT used by the procedure to improve performance.  This leaves open the possibility 
that extended logic defined for the target tables is not executed, however, such logic is not expected to apply
to setting of the Region key which is a derivable value. This decision may need to be reviewed based on change to 
product design.

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully.">
		<SQLScript>
		<![CDATA[

			exec dbo.pRegionMapping#Reassign

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:03:00" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pRegionMapping#Reassign'
	,@DefaultTestOnly = 1

-------------------------------------------------------------------------------------------------------------------------------- */

set nocount on

begin

  declare
     @errorNo                         int = 0                             -- 0 no error, <50000 SQL error, else business rule
    ,@errorText                       nvarchar(4000)                      -- message text (for business rule errors)
    ,@ON                              bit = cast(1 as bit)                -- used on bit comparisons to avoid multiple casts
    ,@OFF                             bit = cast(0 as bit)                -- used on bit comparisons to avoid multiple casts
		,@orgCount												int = 0															-- count of records updated in each target table:
		,@personMailingAddressCount				int	= 0		
		,@resultMessage										nvarchar(4000)											-- buffer to hold result message of process		
		,@updateUser											nvarchar(75)												-- capture user executing the procedure	
		,@reassignTimeConfigParamSID			int																	-- identifier for the reassign time config-param
		,@currentDTOString								varchar(35)													-- current datetimeoffset for storage in config-param

  begin try

		select
			@reassignTimeConfigParamSID = cp.ConfigParamSID
		from
			sf.ConfigParam cp
		where
			cp.ConfigParamSCD = 'LastRegionReassignTime'

		if @reassignTimeConfigParamSID is null																
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'ConfigurationNotComplete'
				,@MessageText = @errorText output
				,@DefaultText = N'The configuration setting for "%1" is missing or invalid.'
				,@Arg1        = 'Last region reassign time'

			raiserror(@errorText, 17, 1)

		end

		set @updateUser = sf.fApplicationUserSession#UserName()								-- application user - or DB user if no application session set

	  -- the update uses a cross apply to isolate the most granular
		-- matched region mapping for each org

		update
			o
		set
			o.RegionSID = rm.RegionSID
		 ,o.UpdateUser = @updateUser
		 ,o.UpdateTime = sysdatetimeoffset()
		from                                                                  
		 dbo.Org o
		cross apply																														-- if no matching masks are found, then Org is not updated
		(
			select top 1																												-- isolate the best matching mask (can be more than one!)
				x.RegionSID 
			from 
				dbo.RegionMapping x 
			where 
				isnull(o.PostalCode, '~') like x.PostalCodeMask + '%' 
			order by len(x.PostalCodeMask) desc																	-- isolate the longest (most granular) matching mask
		) rm
		where 
			o.RegionSID <> rm.RegionSID																					-- avoid updating the row if the correct region is already set

		set @orgCount = @@rowcount

		-- repeat the process for the Person-Mailing-Address table

		update																																-- (see comments above - same logic)
			pma
		set
			pma.RegionSID = rm.RegionSID
		 ,pma.UpdateUser = @updateUser
		 ,pma.UpdateTime = sysdatetimeoffset()
		from                                                                                                                             
		 dbo.PersonMailingAddress pma
		cross apply																														-- if no matching masks are found, then Org is not updated
		(
			select top 1																												-- isolate the best matching mask (can be more than one!)
				x.RegionSID 
			from 
				dbo.RegionMapping x 
			where 
				isnull(pma.PostalCode, '~') like x.PostalCodeMask + '%' 
			order by len(x.PostalCodeMask) desc																	-- isolate the longest (most granular) matching mask
		) rm
		where 
			pma.RegionSID <> rm.RegionSID																				-- avoid updating the row if the correct region is already set

		set @personMailingAddressCount = @@rowcount

		-- when the procedure is used in conversion scenarios, it is possible
		-- blank Region keys will still exist so call another procedure to
		-- assign the default region on any NULL values remaining

		if exists (select 1 from dbo.Org									o		where o.RegionSID		is null)
		or exists (select 1 from dbo.PersonMailingAddress pma where pma.RegionSID is null)
		begin

			exec dbo.pRegion#ResetDefault								
				 @OrgCount									= @orgCount										output
				,@PersonMailingAddressCount = @personMailingAddressCount	output
				,@ReturnSelect							= @OFF																-- WARNING: do NOT pass "@PreviousDefaultSID" to avoid recursion

		end
			
		set @currentDTOString = cast(sysdatetimeoffset() as varchar(35))

		exec sf.pConfigParam#Update																						-- update last reassign time
			 @ConfigParamSID	= @reassignTimeConfigParamSID
			,@ParamValue			= @currentDTOString

		if @ReturnSelect = @ON																								-- avoid hard-coding result text by using message record
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RegionMappingReassignResult'
				,@MessageText = @resultMessage output
				,@DefaultText = N'%1 organization records and %2 (person) mailing address records were updated with new region values.'
				,@Arg1        = @orgCount
				,@Arg2				= @personMailingAddressCount
				
			select
				@resultMessage ResultMessage
		end

  end try

  begin catch
    exec @errorNo = sf.pErrorRethrow                                      -- catch the error, rollback if pending, and re-throw
  end catch

  return(@errorNo)

end
GO
