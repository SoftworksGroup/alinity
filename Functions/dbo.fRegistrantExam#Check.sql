SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fRegistrantExam#Check]
	(
	 @RegistrantExamSID     int
	,@RegistrantSID         int
	,@ExamSID               int
	,@ExamDate              date
	,@ExamResultDate        date
	,@PassingScore          int
	,@Score                 int
	,@ExamStatusSID         int
	,@SchedulingPreferences nvarchar(1000)
	,@AssignedLocation      varchar(15)
	,@ExamReference         varchar(25)
	,@ExamOfferingSID       int
	,@InvoiceSID            int
	,@ConfirmedTime         datetimeoffset(7)
	,@CancelledTime         datetimeoffset(7)
	,@ProcessedTime         datetimeoffset(7)
	,@RegistrantExamXID     varchar(150)
	,@LegacyKey             nvarchar(50)
	,@IsDeleted             bit
	,@CreateUser            nvarchar(75)
	,@CreateTime            datetimeoffset(7)
	,@UpdateUser            nvarchar(75)
	,@UpdateTime            datetimeoffset(7)
	,@RowGUID               uniqueidentifier
	)
returns bit
as
/*********************************************************************************************************************************
ScalarF : dbo.fRegistrantExam#Check
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
$AutoRules | Tim Edlund        ValueIsRequired.AssignedLocation A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.CancelledTime A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.ConfirmedTime A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.ExamDate A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.ExamOfferingSID A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.ExamReference A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.ExamResultDate A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.InvoiceSID A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.PassingScore A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.ProcessedTime A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.SchedulingPreferences A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.Score A value for "%1" is required.
Tim Edlund | Mar 2019          MBR.ExamOfferingMisMatch.ExamSID'; (see source for message text)
Tim Edlund | Mar 2019          MBR.RequiredWhen.ExamDate (see source for message text)
Tim Edlund | Mar 2019          MBR.RequiredWhen.ExamStatusSID (see source for message text)

Example
-------

select
	 RegistrantExamSID
	,dbo.fRegistrantExam#Check
		(
		 RegistrantExamSID
		,RegistrantSID
		,ExamSID
		,ExamDate
		,ExamResultDate
		,PassingScore
		,Score
		,ExamStatusSID
		,SchedulingPreferences
		,AssignedLocation
		,ExamReference
		,ExamOfferingSID
		,InvoiceSID
		,ConfirmedTime
		,CancelledTime
		,ExamConfiguration
		,ExamResponses
		,ProcessedTime
		,ProcessingComments
		,UserDefinedColumns
		,RegistrantExamXID
		,LegacyKey
		,IsDeleted
		,CreateUser
		,CreateTime
		,UpdateUser
		,UpdateTime
		,RowGUID
		)                             IsValid
from
	dbo.RegistrantExam

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
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'dbo',N'RegistrantExam','ValueIsRequired.AssignedLocation') = @ON and @AssignedLocation is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.AssignedLocation'
		set @columnNames        = N'AssignedLocation'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Assigned Location'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'dbo',N'RegistrantExam','ValueIsRequired.CancelledTime') = @ON and @CancelledTime is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.CancelledTime'
		set @columnNames        = N'CancelledTime'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Cancelled Time'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'dbo',N'RegistrantExam','ValueIsRequired.ConfirmedTime') = @ON and @ConfirmedTime is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.ConfirmedTime'
		set @columnNames        = N'ConfirmedTime'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Confirmed Time'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'dbo',N'RegistrantExam','ValueIsRequired.ExamDate') = @ON and @ExamDate is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.ExamDate'
		set @columnNames        = N'ExamDate'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Exam Date'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'dbo',N'RegistrantExam','ValueIsRequired.ExamOfferingSID') = @ON and @ExamOfferingSID is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.ExamOfferingSID'
		set @columnNames        = N'ExamOfferingSID'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Exam Offering'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'dbo',N'RegistrantExam','ValueIsRequired.ExamReference') = @ON and @ExamReference is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.ExamReference'
		set @columnNames        = N'ExamReference'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Exam Reference'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'dbo',N'RegistrantExam','ValueIsRequired.ExamResultDate') = @ON and @ExamResultDate is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.ExamResultDate'
		set @columnNames        = N'ExamResultDate'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Exam Result Date'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'dbo',N'RegistrantExam','ValueIsRequired.InvoiceSID') = @ON and @InvoiceSID is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.InvoiceSID'
		set @columnNames        = N'InvoiceSID'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Invoice'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'dbo',N'RegistrantExam','ValueIsRequired.PassingScore') = @ON and @PassingScore is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.PassingScore'
		set @columnNames        = N'PassingScore'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Passing Score'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'dbo',N'RegistrantExam','ValueIsRequired.ProcessedTime') = @ON and @ProcessedTime is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.ProcessedTime'
		set @columnNames        = N'ProcessedTime'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Processed Time'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'dbo',N'RegistrantExam','ValueIsRequired.SchedulingPreferences') = @ON and @SchedulingPreferences is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.SchedulingPreferences'
		set @columnNames        = N'SchedulingPreferences'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Scheduling Preferences'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'dbo',N'RegistrantExam','ValueIsRequired.Score') = @ON and @Score is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.Score'
		set @columnNames        = N'Score'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Score'
	end
	--!</Rule>
	
	--!<Rule Author="Tim Edlund | Mar 2019" Updates="None">
	if @errorMessageSCD is null and @ExamOfferingSID is not null
	begin

		if not exists
		(
			select
				1
			from
				dbo.ExamOffering eo
			where
				eo.ExamOfferingSID = @ExamOfferingSID and eo.ExamSID = @ExamSID
		)
		begin
			set @errorMessageSCD = 'MBR.ExamOfferingMisMatch.ExamSID';
			set @columnNames = N'ExamSID,ExamOfferingSID';
			set @defaultMessageText = N'The exam identified for this result ("%1") does not match the exam on the selected offering/sitting ("%2%).';

			select @arg1 = ex.ExamName from dbo.Exam ex where ex.ExamSID = @ExamSID;

			select
				@arg2 = ex.ExamName
			from
				dbo.ExamOffering eo
			join
				dbo.Exam				 ex on eo.ExamSID = ex.ExamSID
			where
				eo.ExamOfferingSID = @ExamOfferingSID;

		end;
	end;
	--!</Rule>
	
	--!<Rule Author="Tim Edlund | Mar 2019" Updates="None">
	if @errorMessageSCD is null and @ExamDate is null and @ExamResultDate is not null
	begin
		set @errorMessageSCD      = 'MBR.RequiredWhen.ExamDate'
		set @columnNames          = N'ExamDate, ExamResultDate'
		set @defaultMessageText   = N'A(n) %1 must be provided when a(n) %2 is filled in.'
		set @arg1                 = N'exam date'
		set @arg2									= N'result date'
	end
	--!</Rule>
	
	--!<Rule Author="Tim Edlund | Mar 2019" Updates="None">
	if @errorMessageSCD is null and @ExamResultDate is null
	begin

		if exists(select 1 from dbo.ExamStatus es where es.ExamStatusSID = @ExamStatusSID and es.ExamStatusSCD in ('PASSED', 'FAILED', 'NOT.TAKEN'))
		begin
			set @errorMessageSCD      = 'MBR.RequiredWhen.ExamStatusSID'
			set @columnNames          = N'ExamStatusSID, ExamResultDate'
			set @defaultMessageText   = N'A(n) %1 must be provided when a(n) %2 is filled in.'
			set @arg1                 = N'result date'
			set @arg2									= N'exam result '
		end

	end
	--!</Rule>
	
	--!<Rule Author="?Template | Apr 2019" Updates="None">
	if @errorMessageSCD is null --and sf.fBusinessRuleIsEnforced(N'dbo',N'RegistrantExam','?SomeMessageCode.ColumnName') = 1-- check if rule is ON - REMOVE for mandatory rules
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
				r.RoutineName = 'fRegistrantExam#Check'
		)
		begin
		
			select @errorText = ext.fRegistrantExam#Check
				(
				 @RegistrantExamSID
				,@RegistrantSID
				,@ExamSID
				,@ExamDate
				,@ExamResultDate
				,@PassingScore
				,@Score
				,@ExamStatusSID
				,@SchedulingPreferences
				,@AssignedLocation
				,@ExamReference
				,@ExamOfferingSID
				,@InvoiceSID
				,@ConfirmedTime
				,@CancelledTime
				,@ProcessedTime
				,@RegistrantExamXID
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
			,@RegistrantExamSID
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
