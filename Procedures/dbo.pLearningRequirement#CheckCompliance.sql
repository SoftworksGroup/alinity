SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pLearningRequirement#CheckCompliance]
	@RegistrantSID		int				-- registrant to check - PK value
 ,@RegistrationYear smallint	-- the registration year to check
as
/*********************************************************************************************************************************
Sproc    : Learning Requirement - Check Compliance
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : Checks a registrant's compliance with learning requirements for a given year
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year  | Change Summary
				 : ------------ | ------------|-------------------------------------------------------------------------------------------
				 : Tim Edlund		| Aug 2017		| Initial Version	
				 : Tim Edlund		| Nov 2017		| TODO: updates required for remodeling of learning plans to apply dynamic forms
																				THIS PROCEDURE WAS A SPIKE ONLY AND HAS BEEN MOSTLY COMMMENTED OUT PENDING FURTHER
																				ANLAYSIS AS TO WHETHER IT IS REQUIRED IN THE CURRENT FORM
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------
This procedure checks the count of learning activities and or total of continuing education units a registrant must achieve for 
the given registration year.  If a registrant has more than one registration (generally not supported), the highest ranked registration is 
chosen. Note that only registration types (practice registers) that have a Learning Model configured on them are considered.  If a 
register has a learning model but no requirements defined, then a configuration error is raised.

The procedure returns a data set with one row for each requirement which normalizes as one row per competence type.

** THIS IS A SPIKE ** TODO Tim - not tested.  CORY - please update the structure of the table returned as required to
return the content required for the UI.  Note also that the procedure is not handling the situation where no competence type
is specified in the requirement.  This can be handled with an additional update statement and calculation.

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully.">
		<SQLScript>
		<![CDATA[
		
exec dbo.pLearningRequirement#CheckCompliance @RegistrantSID = 1000105, @RegistrationYear = 2016

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pLearningRequirement#CheckCompliance'
	,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */
set nocount on;

begin
	declare
		@errorNo							int						= 0								-- 0 no error, if < 50000 SQL error, else business rule
	 ,@errorText						nvarchar(4000)									-- message text (for business rule errors)
	 ,@ON										bit						= cast(1 as bit)	-- constant for bit = 1 to reduce repetitive casting
	 ,@OFF									bit						= cast(0 as bit)	-- constant for bit = 0 to reduce repetitive casting
	 ,@practiceRegisterSID	int															-- register that applies for learning requirements
	 ,@cycleLengthYears			int															-- years allowed to achieve compliance 
	 ,@unitsReported				decimal(4, 1);									-- sum of units (e.g. hours, activities) reported in the cycle	

	declare @learningRequirements table -- the table value to return to the UI
	(
	ID										int						identity(1, 1)
 ,UnitTypeLabel					nvarchar(35)	not null
 ,CompetenceTypeSID			int						null
 ,CompetenceTypeLabel		nvarchar(35)	null
 ,MinimumRequired				decimal(4, 1)	not null
 ,MaximumAllowed				decimal(4, 1)	not null
 ,MaximumCarryOver			decimal(4, 1)	not null
 ,CycleLengthYears			int						not null
 ,UnitsReported					decimal(4, 1) not null default 0.0
 ,UnitsCarriedOver			decimal(4, 1) not null default 0.0
 ,UnitsCarriedForward		decimal(4, 1) not null default 0.0
 ,IsRequirementMet			bit						not null default cast(0 as bit)
	);

	begin try

		-- get registrant's highest ranked registration for the given year
		-- where a learning model is applied
		select
			@practiceRegisterSID	= x.PracticeRegisterSID
		from
		(
			select top 1
				pr.PracticeRegisterSID
			 ,pr.LearningModelSID
			 ,rl.RegistrationSID
			from
				dbo.Registration				rl
			join
				dbo.PracticeRegisterSection prs on rl.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
			join
				dbo.PracticeRegister				pr on prs.PracticeRegisterSID				 = pr.PracticeRegisterSID
																					and pr.LearningModelSID is not null
			where
				rl.RegistrantSID					 = @RegistrantSID
				and year(rl.EffectiveTime) = @RegistrationYear
			order by
				pr.RegisterRank
		) x;
/*
		-- if this registrant has no licenses, or none with a learning
		-- model applied then an empty data set is returned (not an error)
		if @practiceRegisterSID is not null
		begin

			-- retrieve the requirements for the relevant practice register
			-- and registration year; one row for each competence type specified
			insert
				@learningRequirements
			(
			  CompetenceTypeSID			-- and then data for each requirement
			 ,CompetenceTypeLabel
			 ,UnitTypeLabel
			 ,MinimumRequired
			 ,MaximumAllowed
			 ,MaximumCarryOver
			 ,CycleLengthYears
			)
			select
		    lr.CompetenceTypeSID
			 ,ct.CompetenceTypeLabel
			 ,ut.UnitTypeLabel
			 ,lr.Minimum
			 ,lr.Maximum
			 ,lr.MaximumCarryOver
			 ,lr.CycleLengthYears
			from
			(
				select -- isolate the requirements for the given registration year
					lr.CompetenceTypeSID
				 ,max(lr.StartingRegistrationYear) StartingRegistrationYear
				from
					dbo.LearningRequirement lr
				join
					dbo.LearningRequirement
				where
					lr.PracticeRegisterSID					= @practiceRegisterSID
					and lr.StartingRegistrationYear <= @RegistrationYear
				group by
					lr.CompetenceTypeSID
			)													x
			join
				dbo.LearningRequirement lr on lr.PracticeRegisterSID							= @practiceRegisterSID
																			and x.StartingRegistrationYear			= lr.StartingRegistrationYear
																			and isnull(x.CompetenceTypeSID, -1) = isnull(lr.CompetenceTypeSID, -1)
			left outer join
				dbo.CompetenceType			ct on lr.CompetenceTypeSID								= ct.CompetenceTypeSID
			join
				dbo.PracticeRegister		pr on lr.PracticeRegisterSID							= pr.PracticeRegisterSID
			join
				sf.UnitType							ut	on pr.UnitTypeSID											= ut.UnitTypeSID;

			-- if no requirements were found for the registration, then a configuration error 
			-- exists since a learning model is defined for the practice register
			if @@rowcount = 0
			begin
				exec sf.pMessage#Get
					@MessageSCD = 'LearningRequirementsMissing'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'No Learning Requirements have been configured for the practice register (%1) and registration year %2.'
				 ,@Arg1 = @practiceRegisterSID
				 ,@Arg2 = @RegistrationYear;

				raiserror(@errorText, 18, 1);
			end;

			-- next update the result table with reported learning for 
			-- each of the competence types specified in requirements;
			update
				lr
			set
				lr.UnitsReported = case when x.Units > lr.MaximumAllowed then lr.MaximumAllowed else x.Units end
			from
				@learningRequirements lr
			join
			(
				select
					c.CompetenceTypeSID
				 ,sum(lpi.UnitValue) Units
				from
					dbo.RegistrantLearningPlan rlp
				join
					dbo.LearningPlanItem			 lpi on rlp.RegistrantLearningPlanSID = lpi.RegistrantLearningPlanSID
				join
					dbo.Competence						 c on lpi.CompetenceSID								= c.CompetenceSID
				join
					@learningRequirements			 lr on c.CompetenceTypeSID						= lr.CompetenceTypeSID
				where
					rlp.RegistrantSID				 = @RegistrantSID
					and rlp.RegistrationYear >= (@RegistrationYear - lr.CycleLengthYears + 1)
					and rlp.RegistrationYear <= @RegistrationYear
				group by
					c.CompetenceTypeSID
			)												x on lr.CompetenceTypeSID = x.CompetenceTypeSID;

			-- process another update for the requirement where no competence type is specified
			-- which allows any other competence type to be the category for learning
			select
				@cycleLengthYears = lr.CycleLengthYears
			from
				@learningRequirements lr
			where
				lr.CompetenceTypeSID is null;

			if @@rowcount > 0
			begin
				select
					@unitsReported = cast(isnull(sum(lpi.UnitValue), 0) as decimal(4, 1))
				from
					dbo.RegistrantLearningPlan rlp
				join
					dbo.LearningPlanItem			 lpi on rlp.RegistrantLearningPlanSID = lpi.RegistrantLearningPlanSID
				join
					dbo.Competence						 c on lpi.CompetenceSID								= c.CompetenceSID
				left outer join
					@learningRequirements			 lr on c.CompetenceTypeSID						= lr.CompetenceTypeSID
				where
					rlp.RegistrantSID				 = @RegistrantSID
					and rlp.RegistrationYear >= (@RegistrationYear - @cycleLengthYears + 1)
					and rlp.RegistrationYear <= @RegistrationYear
					and lr.CompetenceTypeSID is null;

				update
					@learningRequirements
				set
					UnitsReported = case when @unitsReported > MaximumAllowed then MaximumAllowed else @unitsReported end
				where
					CompetenceTypeSID is null;
			end;

			-- next calculate the carry over amounts available from
			-- the previous cycle; first where competence type is specified

			update
				lr
			set
				lr.UnitsCarriedOver = case when x.Units > lr.MaximumCarryOver then lr.MaximumCarryOver else x.Units end
			from
				@learningRequirements lr
			join
			(
				select
					c.CompetenceTypeSID
				 ,sum(lpi.UnitValue) Units
				from
					dbo.RegistrantLearningPlan rlp
				join
					dbo.LearningPlanItem			 lpi on rlp.RegistrantLearningPlanSID = lpi.RegistrantLearningPlanSID
				join
					dbo.Competence						 c on lpi.CompetenceSID								= c.CompetenceSID
				join
					@learningRequirements			 lr on c.CompetenceTypeSID						= lr.CompetenceTypeSID
				where
					rlp.RegistrantSID				 = @RegistrantSID
					and rlp.RegistrationYear >= (@RegistrationYear - (2 * lr.CycleLengthYears) + 1)
					and rlp.RegistrationYear <= (@RegistrationYear - lr.CycleLengthYears + 1)
				group by
					c.CompetenceTypeSID
			)												x on lr.CompetenceTypeSID = x.CompetenceTypeSID;

			select
				@unitsReported = cast(isnull(sum(lpi.UnitValue), 0) as decimal(4, 1))
			from
				dbo.RegistrantLearningPlan rlp
			join
				dbo.LearningPlanItem			 lpi on rlp.RegistrantLearningPlanSID = lpi.RegistrantLearningPlanSID
			join
				dbo.Competence						 c on lpi.CompetenceSID								= c.CompetenceSID
			left outer join
				@learningRequirements			 lr on c.CompetenceTypeSID						= lr.CompetenceTypeSID
			where
				rlp.RegistrantSID				 = @RegistrantSID
				and rlp.RegistrationYear >= (@RegistrationYear - (2 * lr.CycleLengthYears) + 1)
				and rlp.RegistrationYear <= (@RegistrationYear - lr.CycleLengthYears + 1)
				and lr.CompetenceTypeSID is null;

			update
				@learningRequirements
			set
				UnitsCarriedOver = case when @unitsReported > MaximumCarryOver then MaximumCarryOver else @unitsReported end
			where
				CompetenceTypeSID is null;

			-- update compliance and the units available to
			-- carry forward into the next cycle
			update
				@learningRequirements
			set
				IsRequirementMet = case
														 when UnitsReported >= MinimumRequired
														 then @ON
														 when UnitsReported + UnitsCarriedOver >= MinimumRequired
														 then @ON
														 else @OFF
													 end
			 ,UnitsCarriedForward = case
																when (UnitsReported - MinimumRequired) > MaximumCarryOver
																then MaximumCarryOver
																when (UnitsReported - MinimumRequired) > 0.0
																then (UnitsReported - MinimumRequired)
																else 0.0
															end;
		end;
*/
		select
			ID
		 ,UnitTypeLabel
		 ,CompetenceTypeSID
		 ,CompetenceTypeLabel
		 ,MinimumRequired
		 ,MaximumAllowed
		 ,MaximumCarryOver
		 ,CycleLengthYears
		 ,UnitsReported
		 ,UnitsCarriedOver
		 ,UnitsCarriedForward
		 ,IsRequirementMet
		from
			@learningRequirements;
	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
