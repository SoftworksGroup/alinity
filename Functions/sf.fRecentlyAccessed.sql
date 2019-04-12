SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fRecentlyAccessed]
(
	@ApplicationEntitySCD						varchar(50)
)
returns @recentlyAccessed table
(
	ContextGUID									uniqueidentifier
)
as
/*********************************************************************************************************************************
TableF	: Recently Accessed
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: Returns a table of RowGUID values for the entity passed in which have been recently accessed by the current user
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund  | Sep	  2011	  |	Initial Version
				:	Tim Edlund	|	July  2012 		| Added default for 'dbo' schema if not provided in the EntitySCD
				: Tim	Edlund	| Nov		2012		| Updated for changes in structure to the audit tables.
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------

Recently accessed searches are helpful to allow a user to get back to a record they have recently looked at but can no longer 
remember search criteria for.  The feature is similar to "recent documents" in Word, Excel and other common applications.

The function searches content stored in the sf.RecordAudit table which is used logging access to primary tables in the application.  
The log is typically updated when a detail form of some type is accessed.  The GUID of the record being accessed is written into the 
log along with the Application User SID, time and the identifier for the entity being accessed (e.g. "Person").  

Note that auditing is not automatic; it must be explicitly performed by application code and therefore returning recently
accessed roles will only apply on tables which are being actively audited by the application.  This will typically be tables
containing personal information only:  e.g. Patient, Contact, etc.

This function looks for Audit Actions (sf.AuditAction) where the action system code contains the key word "Access".  The word 
may appear in any position in the code to be included.  This ensures that rows involved in other auditable events - e.g. Export - 
are not included in recently accessed search results.

This table function retrieves the SIDs that were accessed "recently" for the application entity passed in. The determination
of the current user is done by accessing the user context information.  The timeframe for "recently accessed" can be set as a 
configuration value in sf.ConfigParam (RecentAccessHours). If no configuration is set, then 24 hours is used.

This function will not return any content if the user session has not been set!  

Example
-------

declare																							-- recent searches requires context to be set
	 @userName							nvarchar(75)
	,@applicationEntitySCD	varchar(128)
	
select top (1)																				-- select user with recent access at random
	 @userName						 = ra.UserName							-- this example requires sample data!
	,@applicationEntitySCD = ra.ApplicationEntitySCD
from
	sf.vRecordAudit ra
and
	datediff(hour, ra.CreateTime, sysdatetimeoffset()) <= 24
order by
	newid()
	
if @userName is null 
begin
	Select 'No users with recent access/not logged - can''t run the example' Error
end
else
begin	

	exec sf.pUserSession#Set						-- the next search requires a session to be set
		 @UserName	= @userName
		,@IPAddress = '10.0.0.1'
		
	select
		*
	from
		sf.fRecentlyAccessed( @applicationEntitySCD )
	
end

------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		 @userSID														int = sf.fApplicationUserSessionUserSID()										-- application user id of the current user
		,@oldestAccessDate									datetimeoffset																							-- oldest time to qualify for recently accessed
		,@applicationEntitySID							int																													-- key of the @ApplicationEntitySCD referenced

  if charindex('.', @ApplicationEntitySCD) = 0 
	begin
		set @ApplicationEntitySCD = cast('dbo.' + @ApplicationEntitySCD as varchar(50))									-- assume dbo if no schema provided
	end

	select
		@applicationEntitySID = ae.ApplicationEntitySID
	from
		sf.ApplicationEntity ae
	where
		ae.ApplicationEntitySCD = @ApplicationEntitySCD

	set @oldestAccessDate  = sf.fRecentAccessCutOff()																									-- calculate date for qualifying records
	
	insert
		@recentlyAccessed
	select distinct
		ra.ContextGUID																																									-- use distinct to avoid returning same row multiple times
	from
		sf.RecordAudit						ra
	join
		sf.ApplicationPage        ap     on ra.ApplicationPageSID = ap.ApplicationPageSID
	join
		sf.ApplicationUserSession aus    on ra.ApplicationUserSessionSID = aus.ApplicationUserSessionSID
	where
		ap.ApplicationEntitySID = @applicationEntitySID
	and
		aus.ApplicationUserSID	= @userSID
	and
		ra.CreateTime						>= @oldestAccessDate

	return

end
GO
