SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE  [sf].[pApplicationUser#GetApplicationGrants]
(
	 @ApplicationUserSID  int                                               -- application user to return grant information for
)   
as
/*********************************************************************************************************************************
Procedure : Application User - Get Grants
Notice    : Copyright © 2014 Softworks Group Inc.
Summary   : Returns XML of all application grants for the given user and the status of each (granted or not), organized by module
History   : Author(s)			| Month Year  | Change Summary
					: --------------|-------------|-----------------------------------------------------------------------------------------
					: Tim Edlund		| Jul		2012  | Initial version
					: Tim Edlund		| Nov		2012	| Documentation updated and minor updates for standards.
					: Tim Edlund		| Dec		2012	| Updated to use datetime values for effective/expiry instead of dates
 
Comments  
--------
This procedure is used to support updating Application User Grants in the user interface.  The procedure returns an XML document 
including all grants available in the system and the status of whether or not that grant is currently in effect for the user. A
check box/on-off style UI can then be provided where the status of the grant can be updated in the "IsActiveNew" virtual column
returned.

The XML returned is hierarchical so that each grant appears within the module it applies to. Where the grant is active - or where 
the grant was active but is now expired, the PK of the associated ApplicationUserGrantSID is provided. 

Example:
--------

<TestHarness>
  <Test Name="Simple" IsDefault="true" Description="Selects a user at random and returns their active grants">
    <SQLScript>
      <![CDATA[
 
			declare
				@applicationUserSID   int
 
			select top (1)
				@applicationUserSID = au.ApplicationUserSID
			from
				sf.ApplicationUser au
			order by 
				newid()
 
			exec sf.pApplicationUser#GetApplicationGrants
				@ApplicationUserSID = @applicationUserSID
 
			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:03" />
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.pApplicationUser#GetApplicationGrants'
-------------------------------------------------------------------------------------------------------------------------------- */
 
set nocount on
 
begin
 
	declare
		 @errorNo                         int = 0                             -- 0 no error, <50000 SQL error, else business rule
		,@errorText                       nvarchar(4000)                      -- message text (for business rule errors)    
		,@blankParm												varchar(50)													-- tracks if any required parameters are not provided     
		,@ON															bit = cast(1 as bit)                -- used on bit comparisons to avoid multiple casts
		,@OFF															bit = cast(0 as bit)                -- used on bit comparisons to avoid multiple casts 
		
	begin try
	
		-- check parameters

		if @ApplicationUserSID  is null set @blankParm = 'ApplicationUserSID'

		if @blankParm is not null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= @blankParm

			raiserror(@errorText, 18, 1)
		
		end   
		
		if not exists( select 1 from sf.ApplicationUser where ApplicationUserSID = @ApplicationUserSID)
		begin

			exec sf.pMessage#Get 
				 @MessageSCD  = 'ParameterNotFound'
				,@MessageText = @errorText output
				,@DefaultText = N'A parameter (%1) provided to the database procedure is invalid. A(n) "%2" record with a key value of "%3" could not be found.'
				,@Arg1        = 'ApplicationUserSID'
				,@Arg2        = 'ApplicationUser'
				,@Arg3        = @ApplicationUserSID

			raiserror(@errorText, 18, 1)

		end
		
		-- return the data as XML
		-- note that table ALIAS names are full to make the XML returned more readable

		select
			 @ApplicationUserSID			                                          ApplicationUserSID				-- user grants are returned for
			,sf.fNow()																													EffectiveTime						  -- default for UI (current time in user timezone)
			,cast(null as nvarchar(max))	                                      ChangeReason						  -- default for change reason in the UI
			,(
				select
					 Module.ModuleName 
					,Module.ModuleSCD 
					,ApplicationGrant.ApplicationGrantSID       
					,ApplicationGrant.ApplicationGrantName
					,ApplicationGrant.ApplicationGrantSCD      
					,ApplicationGrant.UsageNotes
					,case
						when ApplicationUserGrant.ChangeAudit is null then null
						else ApplicationUserGrant.ChangeAudit + N''																							-- must use expression to avoid sub-table tag!
					 end																														ChangeAudit								-- read-only: to show history of changes in the UI
					,isnull(ApplicationUserGrant.IsActive, @OFF)										IsActiveNew   
					,isnull(ApplicationUserGrant.IsActive, @OFF)										IsActiveOld
					,isnull(ApplicationUserGrant.IsPending, @OFF)										IsPending
					,case
						when ApplicationUserGrant.EffectiveTime is null then null
						else cast(ApplicationUserGrant.EffectiveTime as date)																		-- must use expression to avoid sub-table tag!
					 end																														EffectiveTime			
				from
					sf.ApplicationUser        au
				cross join
					sf.vApplicationGrant      ApplicationGrant
				join
					sf.vLicense#Module        Module             
					on
					ApplicationGrant.ModuleSCD = Module.ModuleSCD
				left outer join
					sf.vApplicationUserGrant	ApplicationUserGrant
					on 
					ApplicationGrant.ApplicationGrantSID = ApplicationUserGrant.ApplicationGrantSID 
					and 
					ApplicationUserGrant.ApplicationUserSID = @ApplicationUserSID
				where
					au.ApplicationUserSID = @ApplicationUserSID
				order by 
					1, 3, 5
				for xml auto, type, elements, root('ApplicationGrants')
			)	                                                                  ApplicationGrants					-- encapsulate as sub-select in order to provide a column name

	end try
 
	begin catch
		exec @errorNo = sf.pErrorRethrow                                      -- catch the error, rollback if pending, and re-throw
	end catch
 
	return(@errorNo)
 
end
GO
