SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fEmailMessage#Check]
	(
	 @EmailMessageSID           int
	,@SenderEmailAddress        varchar(150)
	,@SenderDisplayName         nvarchar(75)
	,@PriorityLevel             tinyint
	,@Subject                   nvarchar(120)
	,@FileTypeSCD               varchar(8)
	,@FileTypeSID               int
	,@IsApplicationUserRequired bit
	,@ApplicationUserSID        int
	,@MessageLinkSID            int
	,@LinkExpiryHours           int
	,@ApplicationEntitySID      int
	,@ApplicationGrantSID       int
	,@IsGenerateOnly            bit
	,@MergedTime                datetimeoffset(7)
	,@QueuedTime                datetimeoffset(7)
	,@CancelledTime             datetimeoffset(7)
	,@ArchivedTime              datetimeoffset(7)
	,@PurgedTime                datetimeoffset(7)
	,@EmailMessageXID           varchar(150)
	,@LegacyKey                 nvarchar(50)
	,@IsDeleted                 bit
	,@CreateUser                nvarchar(75)
	,@CreateTime                datetimeoffset(7)
	,@UpdateUser                nvarchar(75)
	,@UpdateTime                datetimeoffset(7)
	,@RowGUID                   uniqueidentifier
	)
returns bit
as
/*********************************************************************************************************************************
ScalarF : sf.fEmailMessage#Check
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : returns 1 (bit) when record values comply with business rules
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pCheckFcnGen | Designer: Tim Edlund
Version : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------

The function is designed to be incorporated into a check constraint on the table.  The standard for enforcing business rules,
except those that apply only on DELETE, is to use a check constraint.  A single check constraint is implemented on each table.
The constraint checks business rules by calling this function which is passed all the columns of the table. The shell of this
function was generated by an SGI studio procedure.  The function requires customization by a developer to implement validation
logic unique to this table.  Some rules may have been "auto-generated" based on column naming conventions.

The function is designed to be called through a check constraint or through a select statement for batch checking records.  In
both cases all columns of the table (not entity view) must be passed to the function.

In order to support re-generation of functions from DB Studio, the logic for each rule must be implemented with comment based
"XML tagging".  The <BusinessRules> and </BusinessRules> tag pair must enclose the content of all rules and then each individual
rule must be enclosed in a <Rule> ... </Rule> tag pair. The rule name and author information is parsed by the generator inserted
into the business rule index for reference in the documentation header (below).

The function contains "base" rules and "optional rules". A function of the same name in the "ext" schema may contain rules that
apply to this client configuration only. All base rules in the function are enforced on 100% of client configurations while optional
rules can be turned off by setting the "IsEnforced" bit = 0 for the rule in the sf.BusinessRule configuration table through the UI.
Base rules do not check the status of the IsEnforced bit. The enforcement of optional rules must be ON by default. See template.

To Add New Business Rules
-------------------------
o Copy the template (at bottom) to create new rule.
o Include the name of the first column involved in the rule as last segment in @errorMessageSCD
o If rule is optional, call sf.fBusinessRuleIsEnforced with same @errorMessageSCD (include the ".ColumnName")
o Update "Author" value on copied from template to your name - otherwise rule will be overwritten on regeneration!
o Do not change "$AutoRules" syntax - otherwise updates to auto-rules are not generated.
o Remove call to sf.fBusinessRuleIsEnforced from copied template if rule is MANDATORY.
o Prefix MessageSCD with "MBR." if rule is MANDATORY (only).
o Nest IF block to avoid testing rules that do not apply based on preconditions (to improve performance).
o Ensure test of all rules are defined in the test harness project.
o Check performance and resolve as required.

Rule Added By                  MessageCode.Column & Text
------------------------------ ----------------------------------------------------------------------------------------------------
$AutoRules | Tim Edlund        MBR.InvalidEmailAddress.SenderEmailAddress The email address is not a valid format. Ensure the addre
$AutoRules | Tim Edlund        MBR.AssignmentToInactiveParent.ApplicationUserSID The %1 is marked inactive. Assign an active %1.
$AutoRules | Tim Edlund        MBR.AssignmentToInactiveParent.FileTypeSID The %1 is marked inactive. Assign an active %1.
$AutoRules | Tim Edlund        ValueIsRequired.ApplicationEntitySID A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.ApplicationGrantSID A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.ApplicationUserSID A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.ArchivedTime A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CancelledTime A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.MergedTime A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.MessageLinkSID A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.PurgedTime A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.QueuedTime A value for "%1" is required.
Tim Edlund | Apr 2015          MBR.NoMailToSend.MergedTime (see source for message text)
Tim Edlund | Apr 2015          MBR.InvalidDateOrder.MergedTime (see source for message text)
Tim Edlund | Apr 2015          MBR.InvalidDateOrder.QueuedTime (see source for message text)
Tim Edlund | Apr 2015          MBR.MissingEmail.QueuedTime (see source for message text)
Tim Edlund | Dec 2018          EmailBodyTooLarge.Body'; (see source for message text)

Example
-------

select
	 EmailMessageSID
	,SenderDisplayName
	,FileTypeSCD
	,sf.fEmailMessage#Check
		(
		 EmailMessageSID
		,SenderEmailAddress
		,SenderDisplayName
		,PriorityLevel
		,Subject
		,Body
		,FileTypeSCD
		,FileTypeSID
		,RecipientList
		,IsApplicationUserRequired
		,ApplicationUserSID
		,MessageLinkSID
		,LinkExpiryHours
		,ApplicationEntitySID
		,ApplicationGrantSID
		,IsGenerateOnly
		,MergedTime
		,QueuedTime
		,CancelledTime
		,ArchivedTime
		,PurgedTime
		,UserDefinedColumns
		,EmailMessageXID
		,LegacyKey
		,IsDeleted
		,CreateUser
		,CreateTime
		,UpdateUser
		,UpdateTime
		,RowGUID
		)                             IsValid
from
	sf.EmailMessage

-------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		 @errorText                       nvarchar(4000)  = N'1'							-- text for errors or returns TRUE when valid
		,@checkFcn                        nvarchar(128)   = object_name(@@procid)												-- name of currently executing function
		,@columnNames                     nvarchar(500)												-- column(s) with error - if multiple separate with commas
		,@errorMessageSCD                 varchar(75)													-- message code to lookup on error
		,@defaultMessageText              nvarchar(1000)											-- message text to return if no override in sf.Message
		,@arg1                            nvarchar(1000)											-- replacement text for "%1" in the message text
		,@arg2                            nvarchar(1000)											-- replacement text for "%2" in the message text
		,@arg3                            nvarchar(1000)											-- replacement text for "%3" in the message text
		,@arg4                            nvarchar(1000)											-- replacement text for "%4" in the message text
		,@arg5                            nvarchar(1000)											-- replacement text for "%5" in the message text
		,@recentAccessHours               smallint														-- configuration value for "recent" insert threshold
		,@isInsert                        bit             = 0									-- 1 if record appears to be an insert (see logic below)
		,@isUpdate                        bit             = 0									-- 1 if not a "new" record
		,@isRecentInsert                  bit             = 0									-- 1 if record was inserted within RECENT hours
		,@ON                              bit             = cast(1 as bit)		-- a constant to reduce repetitive cast syntax in bit comparisons
		,@OFF                             bit             = cast(0 as bit)		-- a constant to reduce repetitive cast syntax in bit comparisons

	-- get configuration value or default to 24 hours

	set @recentAccessHours = isnull(convert(smallint, sf.fConfigParam#Value('RecentAccessHours')), 24)

	if datediff(hour, @CreateTime, sysdatetimeoffset()) > @recentAccessHours-- older than "recent" hours - update only
	begin
		set @isUpdate = @ON
	end
	else if datediff(second, @CreateTime, sysdatetimeoffset()) <= 2					-- record is only 2 seconds old - assume INSERT
	begin
		set @isInsert       = @ON
		set @isRecentInsert = @ON
	end
	else																																		-- record inserted within configured "recent" hours
	begin
		set @isUpdate       = @ON
		set @isRecentInsert = @ON
	end
	
	--!<BusinessRules>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and @SenderEmailAddress is not null and sf.fIsValidEmail(@SenderEmailAddress) = @OFF			-- call framework function to check email address
	begin
		set @errorMessageSCD    = 'MBR.InvalidEmailAddress.SenderEmailAddress'
		set @columnNames        = N'SenderEmailAddress'
		
		set @defaultMessageText = N'The email address is not a valid format. Ensure the address does not contain spaces.'
		                        + 'An "@" sign must separate the username and the domain. Example: john.doe@softworksgroup.com"'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @isInsert = @ON																											-- applies when inserting
	begin
		if (select x.IsActive from sf.ApplicationUser x where x.ApplicationUserSID = @ApplicationUserSID) = @OFF						-- and parent row is inactive
		begin
			set @errorMessageSCD    = 'MBR.AssignmentToInactiveParent.ApplicationUserSID'
			set @columnNames        = N'ApplicationUserSID'
			set @defaultMessageText = N'The %1 is marked inactive. Assign an active %1.'
			set @arg1               = N'application user'
		end
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @isInsert = @ON																											-- applies when inserting
	begin
		if (select x.IsActive from sf.FileType x where x.FileTypeSID = @FileTypeSID) = @OFF							-- and parent row is inactive
		begin
			set @errorMessageSCD    = 'MBR.AssignmentToInactiveParent.FileTypeSID'
			set @columnNames        = N'FileTypeSID'
			set @defaultMessageText = N'The %1 is marked inactive. Assign an active %1.'
			set @arg1               = N'file type'
		end
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'sf',N'EmailMessage','ValueIsRequired.ApplicationEntitySID') = @ON and @ApplicationEntitySID is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.ApplicationEntitySID'
		set @columnNames        = N'ApplicationEntitySID'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Application Entity'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'sf',N'EmailMessage','ValueIsRequired.ApplicationGrantSID') = @ON and @ApplicationGrantSID is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.ApplicationGrantSID'
		set @columnNames        = N'ApplicationGrantSID'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Application Grant'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'sf',N'EmailMessage','ValueIsRequired.ApplicationUserSID') = @ON and @ApplicationUserSID is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.ApplicationUserSID'
		set @columnNames        = N'ApplicationUserSID'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Application User'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'sf',N'EmailMessage','ValueIsRequired.ArchivedTime') = @ON and @ArchivedTime is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.ArchivedTime'
		set @columnNames        = N'ArchivedTime'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Archived Time'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'sf',N'EmailMessage','ValueIsRequired.CancelledTime') = @ON and @CancelledTime is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CancelledTime'
		set @columnNames        = N'CancelledTime'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Cancelled Time'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'sf',N'EmailMessage','ValueIsRequired.MergedTime') = @ON and @MergedTime is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.MergedTime'
		set @columnNames        = N'MergedTime'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Merged Time'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'sf',N'EmailMessage','ValueIsRequired.MessageLinkSID') = @ON and @MessageLinkSID is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.MessageLinkSID'
		set @columnNames        = N'MessageLinkSID'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Message Link'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'sf',N'EmailMessage','ValueIsRequired.PurgedTime') = @ON and @PurgedTime is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.PurgedTime'
		set @columnNames        = N'PurgedTime'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Purged Time'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'sf',N'EmailMessage','ValueIsRequired.QueuedTime') = @ON and @QueuedTime is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.QueuedTime'
		set @columnNames        = N'QueuedTime'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Queued Time'
	end
	--!</Rule>
	
	--!<Rule Author="Tim Edlund | Apr 2015" Updates="None">
	if @errorMessageSCD is null and @MergedTime is not null
	begin

		if (select count(1) from sf.PersonEmailMessage pem where pem.EmailMessageSID = @EmailMessageSID) = 0
		begin
			set @errorMessageSCD      = 'MBR.NoMailToSend.MergedTime'
			set @columnNames          = N'MergedTime'
			set @defaultMessageText   = N'The message cannot be sent because the recipient list is empty'
		end

	end
	--!</Rule>
	
	--!<Rule Author="Tim Edlund | Apr 2015" Updates="None">
	if @errorMessageSCD is null and @QueuedTime is not null and (@MergedTime is null or @MergedTime > @QueuedTime)
	begin
		set @errorMessageSCD      = 'MBR.InvalidDateOrder.MergedTime'
		set @columnNames          = N'MergedTime, QueuedTime'
		set @defaultMessageText   = N'The %1 cannot be set before the %2 on the %3'
		set @arg1                 = N'queued time'
		set @arg2                 = N'merged time'
		set @arg3                 = N'message'
	end
	--!</Rule>
	
	--!<Rule Author="Tim Edlund | Apr 2015" Updates="None">
	if @errorMessageSCD is null and @ArchivedTime is not null and (@QueuedTime is null or @QueuedTime > @ArchivedTime)
	begin
		set @errorMessageSCD      = 'MBR.InvalidDateOrder.QueuedTime'
		set @columnNames          = N'QueuedTime, ArchivedTime'
		set @defaultMessageText   = N'The %1 cannot be set before the %2 on the %3'
		set @arg1                 = N'archived time'
		set @arg2                 = N'queued time'
		set @arg3                 = N'message'
	end
	--!</Rule>
	
	--!<Rule Author="Tim Edlund | Apr 2015" Updates="None">
	if @errorMessageSCD is null and @QueuedTime is not null and @ArchivedTime is null
	begin

		if (select count(1) from sf.PersonEmailMessage pem where pem.EmailMessageSID = @EmailMessageSID and (pem.EmailAddress is null or pem.Body is null)) > 0
		begin
			set @errorMessageSCD      = 'MBR.MissingEmail.QueuedTime'
			set @columnNames          = N'QueuedTime'
			set @defaultMessageText   = N'The message cannot be queued before current email addresses and message content has been saved to recipient records (this is a program error)'
		end

	end
	--!</Rule>
	
	--!<Rule Author="Tim Edlund | Dec 2018" Updates="None">

	declare @maxEmailMessageSize  smallint
	set @maxEmailMessageSize = isnull(convert(smallint, sf.fConfigParam#Value('MaxEmailMessageSize')), 75)				-- get limit (days) from configuration or default to 0

	if @errorMessageSCD is null and @MergedTime is null
	begin

		declare @emailMessageSize smallint = null;

		select
			@emailMessageSize = (datalength(em.Body) / 1024)
		from
			sf.EmailMessage em
		where
			em.EmailMessageSID = @EmailMessageSID;

		if @emailMessageSize > @maxEmailMessageSize
		begin
			set @errorMessageSCD		= 'EmailBodyTooLarge.Body';
			set @columnNames				= N'Body';
			set @defaultMessageText = N'The email message size (%1K) is larger than the recommended maximum size (%2K). Avoid embedding images - use image links instead.';
			set @arg1								= @emailMessageSize
			set @arg2								= @maxEmailMessageSize

		end;

	end;
	--!</Rule>
	
	--!<Rule Author="?Template | Apr 2019" Updates="None">
	if @errorMessageSCD is null --and sf.fBusinessRuleIsEnforced(N'sf',N'EmailMessage','?SomeMessageCode.ColumnName') = 1	-- check if rule is ON - REMOVE for mandatory rules
	and 1 = 0
	begin
		set @errorMessageSCD      = '?SomeMessageCode.ColumnName'
		set @columnNames          = N'?ColumnName1, ?ColumnName2'
		set @defaultMessageText   = N'?Some default message text ...'
		set @arg1                 = N'?SomeReplacementValue'
	end
	--!</Rule>
	
	--!</BusinessRules>
	
	if @errorMessageSCD is not null
	begin
	
		set @errorText = sf.fCheckConstraintErrorString
			(
			 @errorMessageSCD
			,@defaultMessageText
			,@columnNames
			,@EmailMessageSID
			,@arg1
			,@arg2
			,@arg3
			,@arg4
			,@arg5
			)
	
	end
	
	-- cast returns TRUE if no errors (@errorText=1) but throws an exception for processing by sf.pErrorRethrow otherwise
	
	return cast(@errorText as bit)
end
GO
