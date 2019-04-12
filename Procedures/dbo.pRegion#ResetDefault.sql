SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegion#ResetDefault]
	 @OrgCount										int = 0		output													-- count of Org records updated
	,@PersonMailingAddressCount		int = 0		output													-- count of Person-Mailing-Address records updated
	,@PreviousDefaultSID					int	= null																-- previous default key - re-assigns to current key
	,@CurrentDefaultSID						int = null																-- current default key - identifies records to update
	,@ReturnSelect								bit = 1																		-- controls whether or not to return counts of updates
as
/*********************************************************************************************************************************
Procedure : Region Reset Default Record
Notice    : Copyright © 2017 Softworks Group Inc.
Summary   : Updates dbo.Org and dbo.PersonMailingAddress records to a new default Region value
History   : Author(s)   | Month Year | Change Summary
          : ------------|------------|-----------------------------------------------------------------------------------------
          : Tim Edlund	| Jan	2017	 | Initial version
					
Comments
--------
This procedure should be executed when the default Region for the system has changed. It is also called by the 
pRegionMapping#Reassign procedure to fill-in blank Region values that don't match any mappings defined in the dbo.RegionMapping
table. The default Region is assigned to those records.  If no default has been defined for the Region table, then an error 
is returned.

When @ReturnSelect is passed as ON, the procedure returns a single row dataset with the number of records updated in each 
target table formatted as a result message.

If the output parameters for the target tables contain current values, they are not reset.  The number of records which
are assigned the default value are added to any previous total.  This allows this procedure to be called from the 
pRegionMapping#Reassign procedure to ensure any null RegionSID's remaining after mapping are set to the default value.

If the @PreviousDefaultSID not passed (or NULL), then the procedure does not attempt to change any existing records
that have the default value.  If this parameter is passed but the @CurrentDefaultSID is not passed, then the procedure
looks up the current default setting.

When the @PreviousDefaultSID is passed, then the procedure first changes ALL existing records that used the previous
default key to the new key value. Immediately after that, it runs the pRegionMapping#Reassign procedure. This is 
necessary to ensure that any records that used the old default - and should continue to use it based on postal
code mapping - are set to the correct value.  If no dbo.RegionMapping records are defined in the table, this step
is skipped. 

WARNING: On configurations with large numbers of target table records, it may be necessary to call this procedure as a 
background or scheduled basis in order to avoid timing out in the web client application.

Extended logic not applied (EF sprocs called)!
----------------------------------------------
Note that the EF update sprocs are NOT used by the procedure to avoid updating the audit columns on the target tables, and to 
improve performance.  This leaves open the possibility that extended logic defined for the target tables is not executed. This
decision may need to be reviewed based on change to product design.

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully.">
		<SQLScript>
		<![CDATA[

			exec dbo.pRegion#ResetDefault

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:03:00" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pRegion#ResetDefault
	,@DefaultTestOnly = 1

-------------------------------------------------------------------------------------------------------------------------------- */

set nocount on

begin

  declare
     @errorNo                         int = 0                             -- 0 no error, <50000 SQL error, else business rule
    ,@errorText                       nvarchar(4000)                      -- message text (for business rule errors)
    ,@ON                              bit = cast(1 as bit)                -- used on bit comparisons to avoid multiple casts
    ,@OFF                             bit = cast(0 as bit)                -- used on bit comparisons to avoid multiple casts
		,@i																int	= 0															-- loop index - next key value to process
		,@resultMessage										nvarchar(4000)											-- buffer to hold result message of process	
		,@updateUser											nvarchar(75)												-- capture user executing the procedure											

	set @OrgCount										= @OrgCount															-- self assign to avoid non-initialization coding error
	set @PersonMailingAddressCount	= @PersonMailingAddressCount

  begin try

		-- if a previous default value is provided but no current value,
		-- then look it up; return error if not configured

		if @PreviousDefaultSID is not null and @CurrentDefaultSID is null
		begin

			select
				@CurrentDefaultSID = r.RegionSID
			from
				dbo.Region r
			where
				r.IsDefault = @ON

			if @CurrentDefaultSID is null
			begin

				exec sf.pMessage#Get
					 @MessageSCD  = 'ConfigurationNotComplete'
					,@MessageText = @errorText output
					,@DefaultText = N'The configuration setting for "%1" is missing or invalid.'
					,@Arg1        = 'Default Region'

				raiserror(@errorText, 17, 1)
			end
		end

		if @PreviousDefaultSID is null set @PreviousDefaultSID = -1						-- simplify update statement by setting parameter to a non-key value
		set @updateUser = sf.fApplicationUserSession#UserName()								-- application user - or DB user if no application session set

		-- update the target tables where the default has changed
		-- or is currently NULL

		update
			dbo.Org 
		set 
			 RegionSID = @CurrentDefaultSID
			,UpdateTime = sysdatetimeoffset()
			,UpdateUser = @updateUser
		where
			RegionSID is null or RegionSID = @PreviousDefaultSID

		set @OrgCount += @@rowcount																						-- increment the count of records updated in this target

		update
			dbo.PersonMailingAddress
		set 
			 RegionSID = @CurrentDefaultSID
			,UpdateTime = sysdatetimeoffset()
			,UpdateUser = @updateUser
		where
			RegionSID is null or RegionSID = @PreviousDefaultSID

		set @personMailingAddressCount += @@rowcount

		-- if a previous default value was reset, then reassign mappings
		-- to ensure defaults are only applied where no mapping exists

		if @PreviousDefaultSID > 0
		begin

			exec dbo.pRegionMapping#Reassign
				@ReturnSelect = @OFF

		end

		if @ReturnSelect = @ON																								-- avoid hard-coding result text by using message record
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RegionResetDefault'
				,@MessageText = @resultMessage output
				,@DefaultText = N'%1 organization records and %2 (person) mailing address records were updated to the new default Region.'
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
