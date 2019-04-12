SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.[pRegistrantPractice#Upsert]
	@RegistrantPracticeSID	int output		-- key value of record inserted or updated
 ,@RowGUID								nvarchar(50)	-- pass sub-form ID here 
 ,@EmploymentStatusSID		int
 ,@RegistrationYear				smallint = null
 ,@PlannedRetirementDate	date = null
 ,@OtherJurisdiction			nvarchar(100) = null
 ,@TotalPracticeHours			int = null
 ,@OtherJurisdictionHours int = null
 ,@PersonSID							int = null
 ,@RegistrantSID					int = null
 ,@OrgSID									int = null
 ,@InsurancePolicyNo			varchar(25) = null
 ,@InsuranceCertificateNo	varchar(25) = null
 ,@InsuranceAmount				decimal(11, 2) = null
as
/*********************************************************************************************************************************
Sproc    : Registrant Practice Upsert
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : This procedure is called by Profile Update Forms via the sf.Form#Post procedure to insert and update registrant practice
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)				| Month Year | Change Summary
				 : ---------------- | -----------|----------------------------------------------------------------------------------------
				 : Taylor Napier		| Jun 2018 	 | Initial version.
				 : Russell Poirier	|	Apr 2019	 | Set @RegistrantPracticeSID to null for multiple upsert calls from forms (if all are 
																					 inserts). Added @TotalPracticeHours as a parameter.
----------------------------------------------------------------------------------------------------------------------------------

Comments
--------
This procedure handles writing data from the Registrant Practice form area of profile update forms into the database.  The target
table is dbo.RegistrantPractice.

In order to establish whether the practice being passed already exists in the database, the GUID from the form row must be
passed into the procedure.  This value is then looked up against the RowGUID column in the RegistrantPractice  table to
determine if it already exists.  If an existing record is not found, then one is inserted and the RowGUID passed in is written
to the RowGUID column on the new record.

The procedure returns the primary key of the registrant practice record inserted or updated as an output variable (optional).

Known Limitations
-----------------
The GUID value provided by the sub-form must be unique across the database.  If this is not the case a duplicate key error
will occur.  This procedure cannot be called in non-sub-form contexts.

Call Syntax
-----------

 -- this example updates an existing row
 -- without making any changes

declare
	@rowGUID									 uniqueidentifier
 ,@PlannedRetirementDate		 date
 ,@RegistrantSID						 int
 ,@RegistrantPracticeSID		 int;

select top (1)
	@rowGUID									 = rp.RowGUID
 ,@PlannedRetirementDate		 = rp.PlannedRetirementDate
 ,@RegistrantSID						 = rp.RegistrantSID
 ,@RegistrantPracticeSID		 = rp.RegistrantPracticeSID
from
	dbo.RegistrantPractice rp
order by
	newid();

exec dbo.pRegistrantPractice#Upsert
	@RowGUID = @rowGUID
 ,@PlannedRetirementDate = @PlannedRetirementDate
 ,@RegistrantSID = @RegistrantSID
 ,@RegistrantPracticeSID = @RegistrantPracticeSID output;


select
	lpa.RegistrantPracticeSID
 ,lpa.RegistrantSID
 ,lpa.PlannedRetirementDate
 ,lpa.RowGUID
from
	dbo.RegistrantPractice rp
where
	rp.RegistrantPracticeSID = @RegistrantPracticeSID;

------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo	 int = 0				-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText nvarchar(4000) -- message text for business rule errors
	 ,@blankParm varchar(50);		-- tracks name of any required parameter not passed

	set @RegistrantPracticeSID = null; -- initialize output parameters in all code paths (analysis validation)


	begin try

		-- ensure registrantSID is set if not passed in

		if @RegistrantSID is null and @PersonSID is not null
		begin
			select
				@RegistrantSID = RegistrantSID
			from
				dbo.Registrant
			where
				PersonSID = @PersonSID;
		end;

		-- check parameters

		if @RegistrationYear is null
			set @RegistrationYear = dbo.fRegistrationYear#Current();

-- SQL Prompt formatting off
		if @RowGUID							is null set @blankParm = '@RowGUID'
		if @EmploymentStatusSID is null set @blankParm = '@RegistrantLearningPlanSID'
		if @RegistrantSID				is null	set @blankParm = '@RegistrantSID'
		if @RegistrationYear		is null	set @blankParm = '@RegistrationYear'
-- SQL Prompt formatting on

		if @blankParm is not null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = @blankParm;

			raiserror(@errorText, 18, 1);
		end;

		-- look for existing record based on the registrant and year

		select
			@RegistrantPracticeSID = RegistrantPracticeSID
		from
			dbo.RegistrantPractice
		where
			RegistrantSID = @RegistrantSID and RegistrationYear = @RegistrationYear;

		if @RegistrantPracticeSID is null -- record does not exist, add it
		begin

			exec dbo.pRegistrantPractice#Insert
				@RegistrantPracticeSID = @RegistrantPracticeSID output
			 ,@RegistrationYear = @RegistrationYear
			 ,@RegistrantSID = @RegistrantSID
			 ,@EmploymentStatusSID = @EmploymentStatusSID
			 ,@PlannedRetirementDate = @PlannedRetirementDate
			 ,@OtherJurisdiction = @OtherJurisdiction
			 ,@TotalPracticeHours = @TotalPracticeHours
			 ,@OtherJurisdictionHours = @OtherJurisdictionHours
			 ,@OrgSID = @OrgSID
			 ,@InsurancePolicyNo = @InsurancePolicyNo
			 ,@InsuranceCertificateNo	= @InsuranceCertificateNo
			 ,@InsuranceAmount = @InsuranceAmount

		end;
		else -- otherwise record was found so update existing row
		begin

			exec dbo.pRegistrantPractice#Update
				@RegistrantPracticeSID = @RegistrantPracticeSID
			 ,@RegistrationYear = @RegistrationYear
			 ,@RegistrantSID = @RegistrantSID
			 ,@EmploymentStatusSID = @EmploymentStatusSID
			 ,@PlannedRetirementDate = @PlannedRetirementDate
			 ,@OtherJurisdiction = @OtherJurisdiction
			 ,@TotalPracticeHours = @TotalPracticeHours
			 ,@OtherJurisdictionHours = @OtherJurisdictionHours
			 ,@OrgSID = @OrgSID
			 ,@InsurancePolicyNo = @InsurancePolicyNo
			 ,@InsuranceCertificateNo	= @InsuranceCertificateNo
			 ,@InsuranceAmount = @InsuranceAmount

		end;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
