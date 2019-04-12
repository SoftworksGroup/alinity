SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pRecordAudit#Log]
(
	  @ApplicationPageURI					varchar(150)															-- reference to the page the audit is called from
	 ,@ContextGUID								uniqueidentifier	= null									-- ROWGuid of the target row (default ApplicationUser.RowGUID)
	 ,@AuditActionSCD							varchar(25)				= null									-- the audit action - must exist in sf.AuditAction 
	 ,@IsGlassBreak								bit								= 0											-- when 1 indicates glass-break setting was on for access
	 ,@ApplicationEntitySCD				varchar(50)				= null									-- required if ApplicationPage needs to be added-on-the-fly
)																																					-- and a @ContextGUID is specified
as
/*********************************************************************************************************************************
Procedure : Record Audit - Log
Notice    : Copyright © 2014 Softworks Group Inc.
Summary   : Inserts a record into sf.RecordAudit to log an auditable action if not a duplicate 
History   : Author(s)    | Month Year | Change Summary
					: -------------|------------|------------------------------------------------------------------------------------------
					: Tim Edlund   | Nov	2012  | Initial version
 
Comments  
--------
This procedure is used to update the audit log of the application.  It inserts records into the sf.RecordAudit table and in 
some ways is a wrapper for sf.pRecordAudit#Insert.  It allows inserts to be made with fewer parameters, and more importantly,
it avoids entry of multiple audit records for the same event.

Auditing of user actions and accesses is carried out to support analysis and report. Some systems require auditing to comply 
with legal requirements.  For other systems logging supports policies.  Following are some typical uses where audit logging 
is performed:

	o When the user accesses confidential information - e.g. patient case details, professional conduct cases, etc.
	o The user performs an event of security significance - e.g. enters glass break password, or assumes identity of another user
	o Executing menu options - to track the features/pages of a system that are being used by who and how often

Note that auditing is not automatically implemented by the framework. The application must be designed to call this procedure
when actions requiring auditing occur.

This procedure records the date and time of the action, the user performing it, and an identifier for the data row that 
is the context for the audit action (for example the "patient case", or "Contact" record).  

@ApplicationPageURI
-------------------
This parameter is always required and specifies the UI component the action is occurring from.  Where possible, user friendly
URI should be used. The value passed is looked up in the sf.ApplicationPage table. If the value is not found, an attempt
is made to add it on the fly, however, that add will only succeed if the associated @ApplicationEntitySCD is either passed
or, it assumed to be the sf.ApplicationEntitySCD table.  This assumption is made where the @ContextGUID is null.

@ContextGUID
------------
The context identifier is always a RowGUID to ensure uniqueness since the sf.RecordAudit is used to log all events and
contexts. The table the RowGUID relates to can be derived based on the relationship from ApplicationPage to 
ApplicationEntity. 

In some situations the only relevant data row context for the audit event is the user record - e.g. the user has failed 
authentication X times in a form-based authentication system.  Menu option logging is another example where the row
context for a menu action is not relevant.  When the @ContextGUID is not passed, it defaults to the RowGUID of the
logged in user account by default (sf.ApplicationUser.RowGUID).

An identifier for the current user performing the action is not required as a parameter since it is automatically looked 
up from context. 

@AuditActionSCD
---------------
If this value is not provided, the procedure will lookup the default record in sf.AuditAction where IsDefault = ON. If
no record is marked as the default, however, an error will occur.  In general this value should be explicitly passed.

@IsGlassBreak
-------------
Many systems support a feature to allow users to access normally restricted information in an emergency situation.  By entering
a glass-break password, records that would normally be filtered out of search results can be included.  When one of these records
is accessed, the audit event records the fact that the access occurred with the glass-break setting ON.  This value is then
stored into the audit record for reporting.  Typically records that were accessed with the glass-break setting ON are of more
interest in security audit scenarios.

@ApplicationEntitySCD
---------------------
This value is required to support adding-on-the-fly of new Application Page records (sf.ApplicationPage).  If no 
@ContextGUID value is provided, the procedure will default this value to 'sf.ApplicationUser'.  Always including the
value in calls to the procedure has the advantage of avoiding failures for new Application Page references.

Avoiding duplicate log entries
------------------------------
The UI calls the procedure every time an auditable action occurs.  If a user is moving from a detailed screen where an audit 
is called, to a dialog of some type - and back again repeatedly to the detail screen, we need to avoid having the system
create duplicate records for what is, in effect, the same event.  This procedure avoids that by first looking up the last 
audit record for the user and will only create a new audit record if one of the following rules apply:

1. No previous audit history exists
2. The last audit was not for the same RowGUID
3. The last audit was for a different application page
4. The last audit was for a different audit action
5. The last audit record was associated with a different user session

The 5th rule is used to ensure that if a user logs out and then logs back into the system and goes to the same 
record, a new audit record is created.

Using this criteria, if a user accesses detailed records for Patient A, then goes to look at Patient B for even 1 second, and 
then returns to Patient A; their audit log will show 2 events for Patient A with the 1 event for Patient B in-between them.

Add on the fly
--------------
It is necessary to ensure that the @AuditActionSCD parameter provided already be defined in sf.AuditAction.  These codes
cannot be added-on-the-fly.  

Example:
--------

declare                                                                   
	 @contextGUID			uniqueidentifier
	,@auditActionSCD	varchar(25)
	,@userName				nvarchar(75)
	,@pageURI					varchar(150)

select top (1)
	@userName = au.UserName
from
	sf.ApplicationUser au
where
	au.IsActive = 1
order by
	newid()

print @userName

exec sf.pApplicationUser#Authorize
	 @UserName	= @userName
	,@ipAddress = '10.0.0.1'
	
select top (1)
	@contextGUID = e.RowGUID
from
	dbo.Episode e
order by 
	newid()

select top (1)
	@auditActionSCD = aa.AuditActionSCD
from
	sf.AuditAction aa
order by
	newid()

select top (1)
	@pageURI = ap.ApplicationPageURI
from
	sf.ApplicationPage	ap
order by
	newid()

exec sf.pRecordAudit#Log																									-- 1st call
	 @ContextGUID					= @contextGUID
	,@AuditActionSCD			= @auditActionSCD
	,@ApplicationPageURI	= @pageURI

exec sf.pRecordAudit#Log																									-- 2nd call will not create a duplicate
	 @ContextGUID					= @contextGUID
	,@AuditActionSCD			= @auditActionSCD
	,@ApplicationPageURI	= @pageURI

select top 5
	 ra.RecordAuditSID
	,ra.UserName
	,ra.AuditActionName
	,ra.ContextGUID
from
	sf.vRecordAudit ra
order by
	ra.RecordAuditSID desc	

-------------------------------------------------------------------------------------------------------------------------------- */
 
set nocount on
 
begin
 
	declare
		 @errorNo															int = 0                         -- 0 no error, <50000 SQL error, else business rule
		,@errorText														nvarchar(4000)                  -- message text (for business rule errors)    
		,@blankParm														varchar(50)											-- tracks if any required parameters are not provided   
		,@auditActionSID											int															-- system ID associated with the action code passed in
		,@applicationUserSID									int															-- system id of the currently logged in user
		,@applicationUserSessionSID						int															-- system id of the current login session
		,@lastAuditApplicationUserSessionSID	int															-- user session assigned on last audit record for user
		,@lastAuditContextGUID								uniqueidentifier								-- row GUID assigned on last audit record for user
		,@lastAuditActionSCD									varchar(25)											-- action assigned on last audit record for user
		,@lastApplicationPageURI							varchar(150)										-- page URI assigned on last audit record (don't use SID)
		,@isAuditRequired											bit															-- tracks whether insert of RecordAudit is required
		,@ON																	bit = cast(1 as bit)            -- constant used on bit comparisons to avoid multiple casts
		,@OFF																	bit = cast(0 as bit)            -- constant used on bit comparisons to avoid multiple casts 
		
	begin try
	
		-- check parameters

		if @AuditActionSCD is null
		begin

			select
				@AuditActionSCD = aa.AuditActionSCD
			from
				sf.AuditAction aa
			where
				aa.IsDefault = @ON

		end

		if @AuditActionSCD			is null set @blankParm = 'AuditActionSCD'
		if @ApplicationPageURI  is null set @blankParm = 'ApplicationPageURI'

		if @blankParm is not null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= @blankParm

			raiserror(@errorText, 18, 1)
		
		end   

		select 
			@auditActionSID = aa.AuditActionSID
		from 
			sf.AuditAction  aa
		where 
			aa.AuditActionSCD = @AuditActionSCD 

		if @auditActionSID is null
		begin

			exec sf.pMessage#Get 
				 @messageSCD  = 'ParameterNotFound'
				,@MessageText = @errorText output
				,@DefaultText = N'A parameter (%1) provided to the database procedure is invalid. A(n) "%2" record with a key value of "%3" could not be found.'
				,@Arg1        = '@AuditActionSCD'
				,@Arg2        = 'sf.AuditAction'
				,@Arg3        = @AuditActionSCD

			raiserror(@errorText, 18, 1)

		end

		set @isAuditRequired						= @OFF
		set @applicationUserSID					= sf.fApplicationUserSessionUserSID()	-- current user identifier
		set @applicationUserSessionSID	= sf.fApplicationUserSessionSID()			-- current user session identifier

		if @ContextGUID is null																								-- if no context provided, assume current user record
		begin

			select
				@ContextGUID = au.RowGUID
			from
				sf.ApplicationUser au
			where
				au.ApplicationUserSID = @applicationUserSID

			set @ApplicationEntitySCD = 'sf.ApplicationUser'										-- will support add-on-the-fly of ApplicationPageURI

		end

		-- store details from last audit record for this user

		select
			 @lastAuditApplicationUserSessionSID	= ra.ApplicationUserSessionSID
			,@lastAuditContextGUID								= ra.ContextGUID
			,@lastAuditActionSCD									= aa.AuditActionSCD
			,@lastApplicationPageURI							= ap.ApplicationPageURI
		from	
			sf.RecordAudit			ra
		join
			sf.AuditAction			aa	on ra.AuditActionSID = aa.AuditActionSID
		join
			sf.ApplicationPage	ap	on ra.ApplicationPageSID = ap.ApplicationPageSID
		join
			(
			select																															-- isolate last audit record for the current user
				 max(ra.RecordAuditSID)		MaxRecordAuditSID
			from	
				sf.ApplicationUserSession aus
			join
				sf.RecordAudit						ra																				
				on 
				aus.ApplicationUserSessionSID = ra.ApplicationUserSessionSID
			where
				aus.ApplicationUserSID = @applicationUserSID											
			) x on ra.RecordAuditSID = x.MaxRecordAuditSID											

		if @@rowcount	= 0 set @isAuditRequired = @ON																										-- if no audit history for user, audit 

		if @isAuditRequired = @OFF																						
		begin
			if @lastAuditContextGUID <> @ContextGUID set @isAuditRequired = @ON														-- if the row GUID is not the same - audit
		end

		if @isAuditRequired = @OFF																																			
		begin
			if @lastApplicationPageURI <> @ApplicationPageURI set @isAuditRequired = @ON									-- if the page is not the same - audit
		end

		if @isAuditRequired = @OFF																							
		begin
			if @lastAuditActionSCD <> @AuditActionSCD set @isAuditRequired = @ON													-- if the action is not the same - audit
		end

		if @isAuditRequired = @OFF																							
		begin
			if @lastAuditApplicationUserSessionSID <> @applicationUserSessionSID	set @isAuditRequired = @ON -- if the session is not the same - audit
		end

		-- insert the audit row where required

		if @isAuditRequired = @ON
		begin

			exec sf.pRecordAudit#Insert
				 @ApplicationUserSessionSID		= @applicationUserSessionSID				
				,@ApplicationPageURI					= @ApplicationPageURI								-- other SIDs are looked up based on codes in sproc
				,@AuditActionSID							= @auditActionSID
				,@IsGlassBreak								= @IsGlassBreak
				,@ContextGUID									= @ContextGUID

		end

	end try
 
	begin catch
		exec @errorNo = sf.pErrorRethrow                                      -- catch the error, rollback if pending, and re-throw
	end catch
 
	return(@errorNo)
 
end
GO
