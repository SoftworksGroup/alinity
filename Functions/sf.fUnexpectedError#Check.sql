SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fUnexpectedError#Check]
	(
	 @UnexpectedErrorSID int
	,@MessageSCD         varchar(128)
	,@ProcName           nvarchar(128)
	,@LineNumber         int
	,@ErrorNumber        int
	,@MessageText        nvarchar(4000)
	,@ErrorSeverity      int
	,@ErrorState         int
	,@SPIDNo             int
	,@MachineName        nvarchar(128)
	,@DBUser             nvarchar(75)
	,@CallEvent          varchar(255)
	,@CallParameter      int
	,@CallSyntax         varchar(4000)
	,@UnexpectedErrorXID varchar(150)
	,@LegacyKey          nvarchar(50)
	,@IsDeleted          bit
	,@CreateUser         nvarchar(75)
	,@CreateTime         datetimeoffset(7)
	,@UpdateUser         nvarchar(75)
	,@UpdateTime         datetimeoffset(7)
	,@RowGUID            uniqueidentifier
	)
returns bit
as
/*********************************************************************************************************************************
ScalarF : sf.fUnexpectedError#Check
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : returns 1 (bit) when record values comply with business rules
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pCheckFcnGen | Designer: Tim Edlund
Version : March 2019
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
$AutoRules | Tim Edlund        ValueIsRequired.DBUser A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.ErrorNumber A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.ErrorSeverity A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.ErrorState A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.LineNumber A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.MachineName A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.MessageSCD A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.MessageText A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.ProcName A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.SPIDNo A value for "%1" is required.

Example
-------

select
	 UnexpectedErrorSID
	,sf.fUnexpectedError#Check
		(
		 UnexpectedErrorSID
		,MessageSCD
		,ProcName
		,LineNumber
		,ErrorNumber
		,MessageText
		,ErrorSeverity
		,ErrorState
		,SPIDNo
		,MachineName
		,DBUser
		,CallEvent
		,CallParameter
		,CallSyntax
		,UserDefinedColumns
		,UnexpectedErrorXID
		,LegacyKey
		,IsDeleted
		,CreateUser
		,CreateTime
		,UpdateUser
		,UpdateTime
		,RowGUID
		)                             IsValid
from
	sf.UnexpectedError

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
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'sf',N'UnexpectedError','ValueIsRequired.DBUser') = @ON and @DBUser is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.DBUser'
		set @columnNames        = N'DBUser'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'DBUser'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'sf',N'UnexpectedError','ValueIsRequired.ErrorNumber') = @ON and @ErrorNumber is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.ErrorNumber'
		set @columnNames        = N'ErrorNumber'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Error Number'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'sf',N'UnexpectedError','ValueIsRequired.ErrorSeverity') = @ON and @ErrorSeverity is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.ErrorSeverity'
		set @columnNames        = N'ErrorSeverity'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Error Severity'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'sf',N'UnexpectedError','ValueIsRequired.ErrorState') = @ON and @ErrorState is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.ErrorState'
		set @columnNames        = N'ErrorState'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Error State'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'sf',N'UnexpectedError','ValueIsRequired.LineNumber') = @ON and @LineNumber is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.LineNumber'
		set @columnNames        = N'LineNumber'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Line Number'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'sf',N'UnexpectedError','ValueIsRequired.MachineName') = @ON and @MachineName is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.MachineName'
		set @columnNames        = N'MachineName'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Machine Name'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'sf',N'UnexpectedError','ValueIsRequired.MessageSCD') = @ON and @MessageSCD is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.MessageSCD'
		set @columnNames        = N'MessageSCD'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Message SCD'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'sf',N'UnexpectedError','ValueIsRequired.MessageText') = @ON and @MessageText is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.MessageText'
		set @columnNames        = N'MessageText'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Message Text'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'sf',N'UnexpectedError','ValueIsRequired.ProcName') = @ON and @ProcName is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.ProcName'
		set @columnNames        = N'ProcName'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Proc Name'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'sf',N'UnexpectedError','ValueIsRequired.SPIDNo') = @ON and @SPIDNo is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.SPIDNo'
		set @columnNames        = N'SPIDNo'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'SPIDNo'
	end
	--!</Rule>
	
	--!<Rule Author="?Template | Mar 2019" Updates="None">
	if @errorMessageSCD is null --and sf.fBusinessRuleIsEnforced(N'sf',N'UnexpectedError','?SomeMessageCode.ColumnName') = 1-- check if rule is ON - REMOVE for mandatory rules
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
			,@UnexpectedErrorSID
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
