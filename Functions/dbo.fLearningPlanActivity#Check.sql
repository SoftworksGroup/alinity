SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fLearningPlanActivity#Check]
	(
	 @LearningPlanActivitySID      int
	,@RegistrantLearningPlanSID    int
	,@CompetenceTypeActivitySID    int
	,@UnitValue                    decimal(5,2)
	,@CarryOverUnitValue           decimal(5,2)
	,@ActivityDate                 date
	,@LearningClaimTypeSID         int
	,@LearningPlanActivityCategory nvarchar(65)
	,@PlannedCompletion            date
	,@OrgSID                       int
	,@IsSubjectToReview            bit
	,@IsArchived                   bit
	,@LearningPlanActivityXID      varchar(150)
	,@LegacyKey                    nvarchar(50)
	,@IsDeleted                    bit
	,@CreateUser                   nvarchar(75)
	,@CreateTime                   datetimeoffset(7)
	,@UpdateUser                   nvarchar(75)
	,@UpdateTime                   datetimeoffset(7)
	,@RowGUID                      uniqueidentifier
	)
returns bit
as
/*********************************************************************************************************************************
ScalarF : dbo.fLearningPlanActivity#Check
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
$AutoRules | Tim Edlund        MBR.AssignmentToInactiveParent.LearningClaimTypeSID The %1 is marked inactive. Assign an active %1.
$AutoRules | Tim Edlund        MBR.AssignmentToInactiveParent.OrgSID The %1 is marked inactive. Assign an active %1.
$AutoRules | Tim Edlund        ValueIsRequired.ActivityDate A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.LearningPlanActivityCategory A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.OrgSID A value for "%1" is required.
$AutoRules | Tim Edlund        ValueIsRequired.PlannedCompletion A value for "%1" is required.
Tim Edlund | May 2018          DateNotInCEPeriod.ActivityDate'; (see source for message text)
Tim Edlund | Jul 2018          MBR.ArchiveInvalid.IsSubjectToReview'; (see source for message text)
Tim Edlund | Jul 2018          MBR.ArchiveInvalid.IsWithdraw; (see source for message text)
Tim Edlund | Oct 2018          CannotBeNegative (see source for message text)
Tim Edlund | Oct 2018          CannotBeNegative (see source for message text)
Tim Edlund | Oct 2018          CarryOverExceedsBase (see source for message text)
Tim Edlund | Oct 2018          CarryOverExceedsMax (see source for message text)

Example
-------

select
	 LearningPlanActivitySID
	,dbo.fLearningPlanActivity#Check
		(
		 LearningPlanActivitySID
		,RegistrantLearningPlanSID
		,CompetenceTypeActivitySID
		,UnitValue
		,CarryOverUnitValue
		,ActivityDate
		,LearningClaimTypeSID
		,LearningPlanActivityCategory
		,ActivityDescription
		,PlannedCompletion
		,OrgSID
		,IsSubjectToReview
		,IsArchived
		,UserDefinedColumns
		,LearningPlanActivityXID
		,LegacyKey
		,IsDeleted
		,CreateUser
		,CreateTime
		,UpdateUser
		,UpdateTime
		,RowGUID
		)                             IsValid
from
	dbo.LearningPlanActivity

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
		if (select x.IsActive from dbo.LearningClaimType x where x.LearningClaimTypeSID = @LearningClaimTypeSID) = @OFF							-- and parent row is inactive
		begin
			set @errorMessageSCD    = 'MBR.AssignmentToInactiveParent.LearningClaimTypeSID'
			set @columnNames        = N'LearningClaimTypeSID'
			set @defaultMessageText = N'The %1 is marked inactive. Assign an active %1.'
			set @arg1               = N'learning claim type'
		end
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @isInsert = @ON																											-- applies when inserting
	begin
		if (select x.IsActive from dbo.Org x where x.OrgSID = @OrgSID) = @OFF	-- and parent row is inactive
		begin
			set @errorMessageSCD    = 'MBR.AssignmentToInactiveParent.OrgSID'
			set @columnNames        = N'OrgSID'
			set @defaultMessageText = N'The %1 is marked inactive. Assign an active %1.'
			set @arg1               = N'org'
		end
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'dbo',N'LearningPlanActivity','ValueIsRequired.ActivityDate') = @ON and @ActivityDate is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.ActivityDate'
		set @columnNames        = N'ActivityDate'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Activity Date'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'dbo',N'LearningPlanActivity','ValueIsRequired.LearningPlanActivityCategory') = @ON and @LearningPlanActivityCategory is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.LearningPlanActivityCategory'
		set @columnNames        = N'LearningPlanActivityCategory'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Learning Plan Activity Category'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'dbo',N'LearningPlanActivity','ValueIsRequired.OrgSID') = @ON and @OrgSID is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.OrgSID'
		set @columnNames        = N'OrgSID'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Org'
	end
	--!</Rule>
	
	--!<Rule Author="$AutoRules | Tim Edlund">
	if @errorMessageSCD is null and sf.fBusinessRuleIsEnforced(N'dbo',N'LearningPlanActivity','ValueIsRequired.PlannedCompletion') = @ON and @PlannedCompletion is null
	begin
		set @errorMessageSCD    = 'ValueIsRequired.PlannedCompletion'
		set @columnNames        = N'PlannedCompletion'
		set @defaultMessageText = N'A value for "%1" is required.'
		set @arg1               = N'Planned Completion'
	end
	--!</Rule>
	
	--!<Rule Author="Tim Edlund | May 2018" Updates="None">
	if @errorMessageSCD is null and @ActivityDate is not null
	begin

		if not exists
		(
			select
				1
			from
				dbo.LearningPlanActivity		 lpa
			join
				dbo.RegistrantLearningPlan	 rlp on lpa.RegistrantLearningPlanSID = rlp.RegistrantLearningPlanSID
			join
				dbo.RegistrationSchedule		 rs on rs.IsDefault										= @ON
			join
				dbo.RegistrationScheduleYear rsy on rs.RegistrationScheduleSID		= rsy.RegistrationScheduleSID and rsy.RegistrationYear = rlp.RegistrationYear
			where
				lpa.LearningPlanActivitySID = @LearningPlanActivitySID and @ActivityDate between rsy.CECollectionStartTime and rsy.CECollectionEndTime
		--select
		--	1
		--from
		--	dbo.LearningPlanActivity	 lpa
		--join
		--	dbo.vRegistrantLearningPlan rlp on lpa.RegistrantLearningPlanSID = rlp.RegistrantLearningPlanSID
		--where
		--	lpa.LearningPlanActivitySID = @LearningPlanActivitySID and (@registrationYear between rlp.RegistrationYear and rlp.CycleEndRegistrationYear)
		)
		begin

			set @arg1 = format(@ActivityDate, 'dd-MMM-yyyy')

			select
				 @arg2 = format(rsy.CECollectionStartTime, 'dd-MMM-yyyy') + N' to ' + format(rsy.CECollectionEndTime, 'dd-MMM-yyyy')
			from
				dbo.LearningPlanActivity		 lpa
			join
				dbo.RegistrantLearningPlan	 rlp on lpa.RegistrantLearningPlanSID = rlp.RegistrantLearningPlanSID
			join
				dbo.RegistrationSchedule		 rs on rs.IsDefault										= @ON
			join
				dbo.RegistrationScheduleYear rsy on rs.RegistrationScheduleSID		= rsy.RegistrationScheduleSID and rsy.RegistrationYear = rlp.RegistrationYear
			where
				lpa.LearningPlanActivitySID = @LearningPlanActivitySID;

			set @errorMessageSCD = 'DateNotInCEPeriod.ActivityDate';
			set @columnNames = N'ActivityDate';
			set @defaultMessageText = N'The activity date "%1" is not within the Continuing Education collection period (%2)';
		end;
	end;
	--!</Rule>
	
	--!<Rule Author="Tim Edlund | Jul 2018" Updates="None">
	if @errorMessageSCD is null and @IsSubjectToReview = @ON and @IsArchived = @ON
	begin
		set @errorMessageSCD = 'MBR.ArchiveInvalid.IsSubjectToReview';
		set @columnNames = N'IsArchived,IsSubjectToReview';
		set @defaultMessageText = N'This activity has been marked for review so cannot also be set to "%1".';
		set @arg1 = N'archived status.';
	end;
	--!</Rule>
	
	--!<Rule Author="Tim Edlund | Jul 2018" Updates="None">
	if @errorMessageSCD is null and @IsSubjectToReview = @ON
	begin

		if exists
		(
			select
				1
			from
				dbo.LearningPlanActivity lpa
			join
				dbo.LearningClaimType		 lct on lpa.LearningClaimTypeSID = lct.LearningClaimTypeSID
			where
				lpa.LearningPlanActivitySID = @LearningPlanActivitySID and lct.IsWithdrawn = @ON
		)
		begin
			set @errorMessageSCD = 'MBR.ArchiveInvalid.IsWithdrawn';
			set @columnNames = N'IsArchived,IsWithdrawn';
			set @defaultMessageText = N'This activity has been marked for review so cannot also be set to "%1".';
			set @arg1 = N'withdrawn status';
		end;

	end;
	--!</Rule>
	
	--!<Rule Author="Tim Edlund | Oct 2018" Updates="None">
	if @errorMessageSCD is null and @UnitValue < 0.0
	begin
		set @errorMessageSCD      = 'CannotBeNegative'
		set @columnNames          = N'CarryOverUnitValue'
		set @defaultMessageText   = N'The %1 cannot be less than 0.'
		set @arg1                 = 'education units/hours'
	end
	--!</Rule>
	
	--!<Rule Author="Tim Edlund | Oct 2018" Updates="None">
	if @errorMessageSCD is null and @CarryOverUnitValue < 0.0
	begin
		set @errorMessageSCD      = 'CannotBeNegative'
		set @columnNames          = N'CarryOverUnitValue'
		set @defaultMessageText   = N'The %1 cannot be less than 0.'
		set @arg1                 = 'carry over education units/hours'
	end
	--!</Rule>
	
	--!<Rule Author="Tim Edlund | Oct 2018" Updates="None">
	if @errorMessageSCD is null and @CarryOverUnitValue > @UnitValue
	begin
		set @errorMessageSCD      = 'CarryOverExceedsBase'
		set @columnNames          = N'CarryOverUnitValue, UnitValue'
		set @defaultMessageText   = N'The carry over amount (%1) cannot exceed the units/hours originally claimed (%2).'
		set @arg1                 = @CarryOverUnitValue
		set @arg2									= @UnitValue
	end
	--!</Rule>
	
	--!<Rule Author="Tim Edlund | Oct 2018" Updates="None">
	if @errorMessageSCD is null and @CarryOverUnitValue > 0.0
	begin

		declare
			@learningRequirementSID				int
			,@availableCarryOverUnits			decimal(5, 2)
			,@maxCarryOverForRequirement	decimal(5, 2);

		select
			@learningRequirementSID = lrct.LearningRequirementSID -- get requirement associated with the activity
		from
			dbo.CompetenceTypeActivity						cta
		join
			dbo.LearningRequirementCompetenceType lrct on cta.CompetenceTypeSID = lrct.CompetenceTypeSID
		where
			cta.CompetenceTypeActivitySID = @CompetenceTypeActivitySID;

		select
			 @availableCarryOverUnits			= max(st.AvailableCarryOverUnits) -- get available carry over units for this requirement
		from
			dbo.fRegistrantLearningPlan#RequirementsStatus(@RegistrantLearningPlanSID) st;

		if @CarryOverUnitValue > @availableCarryOverUnits
		begin

			select
				 @maxCarryOverForRequirement	= lr.MaximumCarryOver
			from
				dbo.LearningRequirement lr
			where
				lr.LearningRequirementSID = @learningRequirementSID;

			set @errorMessageSCD = 'CarryOverNotAvailable'
			set @columnNames = N'CarryOverUnitValue';
			set @defaultMessageText = N'The carry over amount "%1" units/hours is not valid. Your available carry over for the requirement is "%2". (The maximum carry over allowed for the requirement is "%3".)';
			set @arg1 = @CarryOverUnitValue;
			set @arg2 = @availableCarryOverUnits;
			set @arg3 = @maxCarryOverForRequirement;
		end;

	end;

	--!<Rule Author="Tim Edlund | Oct 2018" Updates="None">
	if @errorMessageSCD is null and @CarryOverUnitValue > 0.0
	begin

		declare
			@maxCarryOverUnits decimal(5, 2)
		 ,@totalCarryOverUnits	 decimal(5, 2);

		select
			@maxCarryOverUnits = lm.MaximumCarryOver
		from
			dbo.RegistrantLearningPlan rlp
		join
			dbo.LearningModel					 lm on rlp.LearningModelSID = lm.LearningModelSID;

		if @maxCarryOverUnits = 0.0
		begin
			set @errorMessageSCD = 'CarryOverNotAllowed'
			set @columnNames = N'CarryOverUnitValue, UnitValue';
			set @defaultMessageText = N'Carrying over education units/hours to the next year or cycle is not permitted.';
		end;
		else if @maxCarryOverUnits < 999.9
		begin

			select
				@totalCarryOverUnits = sum(lpa.CarryOverUnitValue)
			from
				dbo.LearningPlanActivity lpa
			where
				lpa.RegistrantLearningPlanSID = @RegistrantLearningPlanSID;

			if @totalCarryOverUnits > @maxCarryOverUnits
			begin
				set @errorMessageSCD = 'CarryOverExceedsMax'
				set @columnNames = N'CarryOverUnitValue, UnitValue';
				set @defaultMessageText = N'The maximum education units/hours that can be carried over to the next year or cycle is %1 (all categories). Your current total is %2.  Please reduce carry over.';
				set @arg1 = @maxCarryOverUnits;
				set @arg2 = @totalCarryOverUnits;
			end;
		end;
	end;
	--!</Rule>
	
	--!<Rule Author="?Template | Apr 2019" Updates="None">
	if @errorMessageSCD is null --and sf.fBusinessRuleIsEnforced(N'dbo',N'LearningPlanActivity','?SomeMessageCode.ColumnName') = 1-- check if rule is ON - REMOVE for mandatory rules
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
				r.RoutineName = 'fLearningPlanActivity#Check'
		)
		begin
		
			select @errorText = ext.fLearningPlanActivity#Check
				(
				 @LearningPlanActivitySID
				,@RegistrantLearningPlanSID
				,@CompetenceTypeActivitySID
				,@UnitValue
				,@CarryOverUnitValue
				,@ActivityDate
				,@LearningClaimTypeSID
				,@LearningPlanActivityCategory
				,@PlannedCompletion
				,@OrgSID
				,@IsSubjectToReview
				,@IsArchived
				,@LearningPlanActivityXID
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
			,@LearningPlanActivitySID
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
