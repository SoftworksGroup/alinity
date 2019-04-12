SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fTaskQueueSubscriber#Check]
	(
	 @TaskQueueSubscriberSID int
	,@TaskQueueSID           int
	,@ApplicationUserSID     int
	,@EffectiveTime          datetime
	,@ExpiryTime             datetime
	,@IsNewTaskEmailed       bit
	,@IsDailySummaryEmailed  bit
	,@TaskQueueSubscriberXID varchar(150)
	,@LegacyKey              nvarchar(50)
	,@IsDeleted              bit
	,@CreateUser             nvarchar(75)
	,@CreateTime             datetimeoffset(7)
	,@UpdateUser             nvarchar(75)
	,@UpdateTime             datetimeoffset(7)
	,@RowGUID                uniqueidentifier
	)
returns bit
as
/*********************************************************************************************************************************
ScalarF : sf.fTaskQueueSubscriber#Check
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
$AutoRules | Tim Edlund        MBR.DateSequenceReversed.EffectiveTime The "%1" must be dated before the "%2" or left blank if unkno
$AutoRules | Tim Edlund        MBR.AssignmentToInactiveParent.ApplicationUserSID The %1 is marked inactive. Assign an active %1.
$AutoRules | Tim Edlund        MBR.AssignmentToInactiveParent.TaskQueueSID The %1 is marked inactive. Assign an active %1.
$AutoRules | Tim Edlund        BackDatingLimit.EffectiveTime The "%1" cannot be backdated. The backdating limit set is %2 day(s).
$AutoRules | Tim Edlund        FutureDatingLimit.ExpiryTime The "%1" cannot be future dated more than %2 day(s).

Example
-------

select
	 TaskQueueSubscriberSID
	,sf.fTaskQueueSubscriber#Check
		(
		 TaskQueueSubscriberSID
		,TaskQueueSID
		,ApplicationUserSID
		,EffectiveTime
		,ExpiryTime
		,IsNewTaskEmailed
		,IsDailySummaryEmailed
		,ChangeAudit
		,UserDefinedColumns
		,TaskQueueSubscriberXID
		,LegacyKey
		,IsDeleted
		,CreateUser
		,CreateTime
		,UpdateUser
		,UpdateTime
		,RowGUID
		)                             IsValid
from
	sf.TaskQueueSubscriber

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
	if @errorMessageSCD is null and @ExpiryTime < @EffectiveTime						-- effective and expiry look reversed
	begin
		set @errorMessageSCD    = 'MBR.DateSequenceReversed.EffectiveTime'
		set @columnNames        = N'EffectiveTime,ExpiryTime'
		set @defaultMessageText = N'The "%1" must be dated before the "%2" or left blank if unknown.'
		set @arg1               = N'Effective Time'
		set @arg2               = N'Expiry Time'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fIsActive(@EffectiveTime, @ExpiryTime) = @ON and @isInsert = @ON													-- applies to active assignments when inserting
	begin
		if (select x.IsActive from sf.ApplicationUser x where x.ApplicationUserSID = @ApplicationUserSID) = @OFF									-- and parent row is inactive
		begin
			set @errorMessageSCD    = 'MBR.AssignmentToInactiveParent.ApplicationUserSID'
			set @columnNames        = N'ApplicationUserSID'
			set @defaultMessageText = N'The %1 is marked inactive. Assign an active %1.'
			set @arg1               = N'application user'
		end
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fIsActive(@EffectiveTime, @ExpiryTime) = @ON and @isInsert = @ON													-- applies to active assignments when inserting
	begin
		if (select x.IsActive from sf.TaskQueue x where x.TaskQueueSID = @TaskQueueSID) = @OFF					-- and parent row is inactive
		begin
			set @errorMessageSCD    = 'MBR.AssignmentToInactiveParent.TaskQueueSID'
			set @columnNames        = N'TaskQueueSID'
			set @defaultMessageText = N'The %1 is marked inactive. Assign an active %1.'
			set @arg1               = N'task queue'
		end
	end
	--!</Rule>
	
	declare @backDateLimit  smallint
	set @backDateLimit = isnull(convert(smallint, sf.fConfigParam#Value('BackDatingLimit')), 0)				-- get limit (days) from configuration or default to 0
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'sf',N'TaskQueueSubscriber','BackDatingLimit.EffectiveTime') = @ON
	and datediff(day, @EffectiveTime, sf.fDTOffsetToClientDateTime(@CreateTime)) > @backDateLimit
	begin
		set @errorMessageSCD    = 'BackDatingLimit.EffectiveTime'
		set @columnNames        = N'EffectiveTime'
		set @defaultMessageText = N'The "%1" cannot be backdated. The backdating limit set is %2 day(s).'
		set @arg1               = N'Effective Time'
		set @arg2               = cast(@backDateLimit as nvarchar(10))
	end
	--!</Rule>
	
	declare @futureDateLimit smallint
	set @futureDateLimit = isnull(convert(smallint, sf.fConfigParam#Value('FutureDatingLimit')), 30)	-- get limit (days) from configuration or default to 30
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'sf',N'TaskQueueSubscriber','FutureDatingLimit.ExpiryTime') = @ON
	and datediff(day, sf.fNow(), @ExpiryTime) > @futureDateLimit
	begin
		set @errorMessageSCD    = 'FutureDatingLimit.ExpiryTime'
		set @columnNames        = N'ExpiryTime'
		set @defaultMessageText = N'The "%1" cannot be future dated more than %2 day(s).'
		set @arg1               = N'Expiry Time'
		set @arg2               = cast(@futureDateLimit as nvarchar(10))
	end
	--!</Rule>
	
	--!<Rule Author="?Template | Apr 2019" Updates="None">
	if @errorMessageSCD is null --and sf.fBusinessRuleIsEnforced(N'sf',N'TaskQueueSubscriber','?SomeMessageCode.ColumnName') = 1-- check if rule is ON - REMOVE for mandatory rules
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
			,@TaskQueueSubscriberSID
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
