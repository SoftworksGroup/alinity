SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fComplaint#Check]
	(
	 @ComplaintSID                int
	,@ComplaintNo                 varchar(50)
	,@RegistrantSID               int
	,@ComplaintTypeSID            int
	,@ComplainantTypeSID          int
	,@ApplicationUserSID          int
	,@OpenedDate                  date
	,@ConductStartDate            date
	,@ConductEndDate              date
	,@ComplaintSeveritySID        int
	,@IsDisplayedOnPublicRegistry bit
	,@ClosedDate                  date
	,@DismissedDate               date
	,@ReasonSID                   int
	,@FileExtension               varchar(5)
	,@ComplaintXID                varchar(150)
	,@LegacyKey                   nvarchar(50)
	,@IsDeleted                   bit
	,@CreateUser                  nvarchar(75)
	,@CreateTime                  datetimeoffset(7)
	,@UpdateUser                  nvarchar(75)
	,@UpdateTime                  datetimeoffset(7)
	,@RowGUID                     uniqueidentifier
	)
returns bit
as
/*********************************************************************************************************************************
ScalarF : dbo.fComplaint#Check
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
$AutoRules | Tim Edlund        MBR.AssignmentToInactiveParent.ApplicationUserSID The %1 is marked inactive. Assign an active %1.
$AutoRules | Tim Edlund        MBR.AssignmentToInactiveParent.ComplainantTypeSID The %1 is marked inactive. Assign an active %1.
$AutoRules | Tim Edlund        MBR.AssignmentToInactiveParent.ComplaintSeveritySID The %1 is marked inactive. Assign an active %1.
$AutoRules | Tim Edlund        MBR.AssignmentToInactiveParent.ComplaintTypeSID The %1 is marked inactive. Assign an active %1.
$AutoRules | Tim Edlund        MBR.AssignmentToInactiveParent.ReasonSID The %1 is marked inactive. Assign an active %1.
$AutoRules | Tim Edlund        ValueIsRequired.ClosedDate A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.DismissedDate A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.ReasonSID A value for "%1" is required.
Tim Edlund | Jan 2019          MBR.MemberMismatch.RegistrantSID'; (see source for message text)
Tim Edlund | Jan 2019          MBR.OpenedBeforeEvent.OpenedDate'; (see source for message text)
Tim Edlund | Jan 2019          MBR.ClosingWhenIncomplete.ClosedDate'; (see source for message text)
Tim Edlund | Mar 2019          MBR.ClosingWithoutSummary.ClosedDate'; (see source for message text)
Tim Edlund | Jan 2019          MBR.ClosedBeforeEvent.ClosedDate'; (see source for message text)

Example
-------

select
	 ComplaintSID
	,ComplaintNo
	,dbo.fComplaint#Check
		(
		 ComplaintSID
		,ComplaintNo
		,RegistrantSID
		,ComplaintTypeSID
		,ComplainantTypeSID
		,ApplicationUserSID
		,OpenedDate
		,ConductStartDate
		,ConductEndDate
		,ComplaintSummary
		,ComplaintSeveritySID
		,OutcomeSummary
		,IsDisplayedOnPublicRegistry
		,ClosedDate
		,DismissedDate
		,ReasonSID
		,TagList
		,FileExtension
		,UserDefinedColumns
		,ComplaintXID
		,LegacyKey
		,IsDeleted
		,CreateUser
		,CreateTime
		,UpdateUser
		,UpdateTime
		,RowGUID
		)                             IsValid
from
	dbo.Complaint

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
		if (select x.IsActive from sf.ApplicationUser x where x.ApplicationUserSID = @ApplicationUserSID) = @OFF					-- and parent row is inactive
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
		if (select x.IsActive from dbo.ComplainantType x where x.ComplainantTypeSID = @ComplainantTypeSID) = @OFF					-- and parent row is inactive
		begin
			set @errorMessageSCD    = 'MBR.AssignmentToInactiveParent.ComplainantTypeSID'
			set @columnNames        = N'ComplainantTypeSID'
			set @defaultMessageText = N'The %1 is marked inactive. Assign an active %1.'
			set @arg1               = N'complainant type'
		end
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @isInsert = @ON																											-- applies when inserting
	begin
		if (select x.IsActive from dbo.ComplaintSeverity x where x.ComplaintSeveritySID = @ComplaintSeveritySID) = @OFF		-- and parent row is inactive
		begin
			set @errorMessageSCD    = 'MBR.AssignmentToInactiveParent.ComplaintSeveritySID'
			set @columnNames        = N'ComplaintSeveritySID'
			set @defaultMessageText = N'The %1 is marked inactive. Assign an active %1.'
			set @arg1               = N'complaint severity'
		end
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @isInsert = @ON																											-- applies when inserting
	begin
		if (select x.IsActive from dbo.ComplaintType x where x.ComplaintTypeSID = @ComplaintTypeSID) = @OFF								-- and parent row is inactive
		begin
			set @errorMessageSCD    = 'MBR.AssignmentToInactiveParent.ComplaintTypeSID'
			set @columnNames        = N'ComplaintTypeSID'
			set @defaultMessageText = N'The %1 is marked inactive. Assign an active %1.'
			set @arg1               = N'complaint type'
		end
	end
	--!</Rule>
	
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
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'dbo',N'Complaint','ValueIsRequired.ClosedDate') = @ON and @ClosedDate is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.ClosedDate'
		set @columnNames        = N'ClosedDate'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Closed Date'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'dbo',N'Complaint','ValueIsRequired.DismissedDate') = @ON and @DismissedDate is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.DismissedDate'
		set @columnNames        = N'DismissedDate'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Dismissed Date'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'dbo',N'Complaint','ValueIsRequired.ReasonSID') = @ON and @ReasonSID is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.ReasonSID'
		set @columnNames        = N'ReasonSID'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Reason'
	end
	--!</Rule>
	
	--!<Rule Author="Tim Edlund | Jan 2019" Updates="None">
	if @errorMessageSCD is null and exists(select 1 from dbo.ComplaintContact cc where cc.ComplaintSID = @ComplaintSID)
	begin

		if not exists
		(
			select
				1
			from
				dbo.Complaint						 c
			join
				dbo.Registrant r on c.RegistrantSID = r.RegistrantSID
			join
				dbo.ComplaintContact		 cc on c.ComplaintSID							 = cc.ComplaintSID
			join
				dbo.ComplaintContactRole ccr on cc.ComplaintContactRoleSID = ccr.ComplaintContactRoleSID and ccr.ComplaintContactRoleSCD = 'MEMBER'
			where
				c.ComplaintSID = @ComplaintSID
			and
				r.PersonSID = cc.PersonSID
		)
		begin
			set @errorMessageSCD = 'MBR.MemberMismatch.RegistrantSID';
			set @columnNames = N'RegistrantSID';
			set @defaultMessageText = N'The member identified on the complaint must be the same as the member identified in the contact list. Add a new complaint to change the investigated member.';
		end;

	end;
	--!</Rule>
	
	--!<Rule Author="Tim Edlund | Jan 2019" Updates="None">
	if @errorMessageSCD is null
	begin

		if exists
		(
			select
				1
			from
				dbo.ComplaintEvent ce
			where
				ce.ComplaintSID = @ComplaintSID and (ce.DueDate < @OpenedDate or ce.CompleteTime < @OpenedDate)
		)
		begin
			set @errorMessageSCD = 'MBR.OpenedBeforeEvent.OpenedDate';
			set @columnNames = N'OpenedDate';
			set @defaultMessageText =	N'The open date cannot precede the due date or completion date for any associated event. Review events before setting this date.';
		end;

	end;
	--!</Rule>
	
	--!<Rule Author="Tim Edlund | Jan 2019" Updates="None">
	if @errorMessageSCD is null and @ClosedDate is not null	
	begin

		if exists
		(
			select
				1
			from
				dbo.ComplaintEvent ce
			where
				ce.ComplaintSID = @ComplaintSID and ce.CompleteTime is null
		)
		begin
			set @errorMessageSCD = 'MBR.ClosingWhenIncomplete.ClosedDate';
			set @columnNames = N'ClosedDate';
			set @defaultMessageText =	N'The complaint cannot be closed when one or more events remain incomplete. Close or delete remaining events first.';
		end;

	end;
	--!</Rule>
	
	--!<Rule Author="Tim Edlund | Mar 2019" Updates="None">
	if @errorMessageSCD is null and @ClosedDate is not null
	begin

		if exists
		(
			select
				1
			from
				dbo.Complaint c
			where
				c.ComplaintSID = @ComplaintSID and c.OutcomeSummary is null
		)
		begin
			set @errorMessageSCD = 'MBR.ClosingWithoutSummary.ClosedDate';
			set @columnNames = N'ClosedDate';
			set @defaultMessageText =	N'The complaint cannot be closed until the outcome has been documented. Fill-in the complaint outcome summary first.';
		end;

	end;
	--!</Rule>
	
	--!<Rule Author="Tim Edlund | Jan 2019" Updates="None">
	if @errorMessageSCD is null and @ClosedDate is not null
	begin

		if exists
		(
			select
				1
			from
				dbo.ComplaintEvent ce
			where
				ce.ComplaintSID = @ComplaintSID and (ce.CompleteTime > @ClosedDate)
		)
		begin
			set @errorMessageSCD = 'MBR.ClosedBeforeEvent.ClosedDate';
			set @columnNames = N'ClosedDate';
			set @defaultMessageText =	N'The closed date cannot be before the last event completion date. Review events before setting this date.';
		end;

	end;
	--!</Rule>
	
	--!<Rule Author="?Template | Apr 2019" Updates="None">
	if @errorMessageSCD is null --and sf.fBusinessRuleIsEnforced(N'dbo',N'Complaint','?SomeMessageCode.ColumnName') = 1	-- check if rule is ON - REMOVE for mandatory rules
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
				r.RoutineName = 'fComplaint#Check'
		)
		begin
		
			select @errorText = ext.fComplaint#Check
				(
				 @ComplaintSID
				,@ComplaintNo
				,@RegistrantSID
				,@ComplaintTypeSID
				,@ComplainantTypeSID
				,@ApplicationUserSID
				,@OpenedDate
				,@ConductStartDate
				,@ConductEndDate
				,@ComplaintSeveritySID
				,@IsDisplayedOnPublicRegistry
				,@ClosedDate
				,@DismissedDate
				,@ReasonSID
				,@FileExtension
				,@ComplaintXID
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
			,@ComplaintSID
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
