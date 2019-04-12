SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fInvoicePayment#Check]
	(
	 @InvoicePaymentSID  int
	,@InvoiceSID         int
	,@PaymentSID         int
	,@AmountApplied      decimal(11,2)
	,@AppliedDate        date
	,@GLPostingDate      date
	,@CancelledTime      datetimeoffset(7)
	,@ReasonSID          int
	,@InvoicePaymentXID  varchar(150)
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
ScalarF : dbo.fInvoicePayment#Check
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
$AutoRules | Tim Edlund        MBR.AssignmentToInactiveParent.ReasonSID The %1 is marked inactive. Assign an active %1.
$AutoRules | Tim Edlund        ValueIsRequired.CancelledTime A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.GLPostingDate A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.ReasonSID A value for "%1" is required.
Tim Edlund | Nov 2018          MBR.PeriodIsLocked.GLPostingDate'; (see source for message text)

Example
-------

select
	 InvoicePaymentSID
	,dbo.fInvoicePayment#Check
		(
		 InvoicePaymentSID
		,InvoiceSID
		,PaymentSID
		,AmountApplied
		,AppliedDate
		,GLPostingDate
		,CancelledTime
		,ReasonSID
		,UserDefinedColumns
		,InvoicePaymentXID
		,LegacyKey
		,IsDeleted
		,CreateUser
		,CreateTime
		,UpdateUser
		,UpdateTime
		,RowGUID
		)                             IsValid
from
	dbo.InvoicePayment

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
	if @isInsert = @ON																											-- applies when inserting
	begin
		if (select x.IsActive from dbo.Reason x where x.ReasonSID = @ReasonSID) = @OFF									-- and parent row is inactive
		begin
			set @errorMessageSCD    = 'MBR.AssignmentToInactiveParent.ReasonSID'
			set @columnNames        = N'ReasonSID'
			set @defaultMessageText = N'The %1 is marked inactive. Assign an active %1.'
			set @arg1               = N'reason'
		end
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'dbo',N'InvoicePayment','ValueIsRequired.CancelledTime') = @ON and @CancelledTime is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CancelledTime'
		set @columnNames        = N'CancelledTime'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Cancelled Time'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'dbo',N'InvoicePayment','ValueIsRequired.GLPostingDate') = @ON and @GLPostingDate is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.GLPostingDate'
		set @columnNames        = N'GLPostingDate'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'GLPosting Date'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'dbo',N'InvoicePayment','ValueIsRequired.ReasonSID') = @ON and @ReasonSID is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.ReasonSID'
		set @columnNames        = N'ReasonSID'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Reason'
	end
	--!</Rule>
	
	--!<Rule Author="Tim Edlund | Nov 2018" Updates="None">
	if @errorMessageSCD is null and @GLPostingDate is not null and @isInsert = @ON -- note that rule for checking this for updates is in #Update procedure
	begin

		declare @acctgTrxLockedDate date;

		set @acctgTrxLockedDate = cast(isnull(sf.fConfigParam#Value('AcctgTrxLockedDate'), '20000101') as date);

		if @GLPostingDate <= @acctgTrxLockedDate
		begin

			set @errorMessageSCD = 'MBR.PeriodIsLocked.GLPostingDate';
			set @columnNames = N'GLPostingDate';
			set @defaultMessageText = N'The %1 date provided "%2" is invalid because the accounting period is locked. The locked period ends: %3.';
			set @arg1 = N'?SomeReplacementValue';
			set @arg1 = 'GL posting';
			set @arg2 = @GLPostingDate;
			set @arg3 = @acctgTrxLockedDate;

		end;

	end;
	--!</Rule>
	
	--!<Rule Author="?Template | Apr 2019" Updates="None">
	if @errorMessageSCD is null --and sf.fBusinessRuleIsEnforced(N'dbo',N'InvoicePayment','?SomeMessageCode.ColumnName') = 1-- check if rule is ON - REMOVE for mandatory rules
	and 1 = 0
	begin
		set @errorMessageSCD      = '?SomeMessageCode.ColumnName'
		set @columnNames          = N'?ColumnName1, ?ColumnName2'
		set @defaultMessageText   = N'?Some default message text ...'
		set @arg1                 = N'?SomeReplacementValue'
	end
	--!</Rule>
	
	--!</BusinessRules>
	
	-- if no base-product business rules were violated, run the extended version of the
	-- function if it exists
	
	if @errorMessageSCD is null
	begin
	
		if exists
		(
			select
				1
			from
				sf.vRoutine r
			where
				r.SchemaName = 'ext'
			and
				r.RoutineName = 'fInvoicePayment#Check'
		)
		begin
		
			select @errorText = ext.fInvoicePayment#Check
				(
				 @InvoicePaymentSID
				,@InvoiceSID
				,@PaymentSID
				,@AmountApplied
				,@AppliedDate
				,@GLPostingDate
				,@CancelledTime
				,@ReasonSID
				,@InvoicePaymentXID
				,@LegacyKey
				,@IsDeleted
				,@CreateUser
				,@CreateTime
				,@UpdateUser
				,@UpdateTime
				,@RowGUID
				)
		
		end
	
	end
	
	-- if the extended function returned error text it will already be formatted otherwise check
	-- for a message code value and format the error information for processing by sf.pErrorRethrow
	
	if @errorText not like N'<err>%' and @errorMessageSCD is not null
	begin
	
		set @errorText = sf.fCheckConstraintErrorString
			(
			 @errorMessageSCD
			,@defaultMessageText
			,@columnNames
			,@InvoicePaymentSID
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
