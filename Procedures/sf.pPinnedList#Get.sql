SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sf.pPinnedList#Get
	@PropertyName				varchar(100)	-- registrant name, # or email to search for (NOT combined with filters)
 ,@ApplicationUserSID int = null		-- key of the logged in user (will be looked up if not provided)
as
/*********************************************************************************************************************************
Procedure: Pinned Records - Get
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : This procedure returns the record keys (SID's) for records pinned by the user
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Aug 2018		|	Initial version

Comments	
--------
This is a support procedure for searches where the list of records previously pinned by the user must be retrieved. The pinned 
records are looked up in the user's profile. If an application user key is not provided, then the key for the currently logged in
user is looked up. The name of the pinned property must be provided. The procedure returns an empty record set if no pinned records 
are found for the user and property name. 

Known Limitations
-----------------
The property name cannot be validated by the procedure. No sort order is provided in the record set returned.

Example
-------
<TestHarness>
  <Test Name = "Random" IsDefault ="true" Description="Executes the procedure for a pinned property and user 
	selected at random">
    <SQLScript>
      <![CDATA[
declare
	@propertyName				varchar(100)
 ,@applicationUserSID int;

select top (1)
	@propertyName				= aupp.PropertyName
 ,@applicationUserSID = aupp.ApplicationUserSID
from
	sf.ApplicationUserProfileProperty aupp
where
	aupp.PropertyName like 'pinned%'
order by
	newid();

if @@rowcount = 0 or @propertyName is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	exec sf.pPinnedList#Get
		@PropertyName = @propertyName
	 ,@ApplicationUserSID = @applicationUserSID;

end;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:0:03"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'sf.pPinnedList#Get'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */
begin

	declare
		@errorNo		int = 0 -- 0 no error, <50000 SQL error, else business rule
	 ,@pinnedList xml;		-- document for interim storage of pinned records

	begin try

		if @ApplicationUserSID is null
		begin
			set @ApplicationUserSID = sf.fApplicationUserSessionUserSID();
		end;

		select
			@pinnedList = aupp.PropertyValue
		from
			sf.ApplicationUserProfileProperty aupp
		where
			aupp.ApplicationUserSID = @ApplicationUserSID and aupp.PropertyName = @PropertyName;

		select
			EntitySID.r.value('.', 'int') EntitySID -- return pinned rows if any, or empty record set					
		from
			@pinnedList.nodes('//EntitySID') as EntitySID(r);

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);

end;
GO
