SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pRegistrant#NextLearningPlan
(
	@RegistrantSID int = null -- identifier of registrant to return LP information for
 ,@PersonSID		 int = null -- alternate key for registrant - must pass one of these 2 parameters!
)
as
/*********************************************************************************************************************************
Sproc			: Registrant - Next Learning Plan
Notice		: Copyright © 2018 Softworks Group Inc.
Summary		: Returns a dataset of values to determine whether the last learning plan is valid
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-------------------------------------------------------------------------------------------
					: Tim Edlund  | Jun 2018		|	Initial version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------

This procedure is a wrapper for a function of the same name.  It is called by routines managing the creation and reporting on 
Registrant Learning Plans.  It reports on the last learning plan created for the registrant and also reports whether a new learning 
plan is now due to be created.  The function bases the year of the new learning plan on the last plan year and adds the Cycle-Length 
associated with the learning model of the current registration.

Either a RegistrantSID or PersonSID value may be passed.  The RegistrantSID has priority and if it is not passed, the RegistrantSID
is looked up based on the PersonSID.

Example
-------

<TestHarness>
	<Test Name = "Random10" Description="Returns the function values for 10 registrants selected at random.">
	<SQLScript>
	<![CDATA[

declare
	@registrantSID int
 ,@personSID		 int;

select top (1)
	@registrantSID = r.RegistrantSID
 ,@personSID		 = r.PersonSID
from
	dbo.Registrant r
order by
	newid();

if @@rowcount = 0 or @registrantSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	exec dbo.pRegistrant#NextLearningPlan
		@RegistrantSID = @registrantSID;

	exec dbo.pRegistrant#NextLearningPlan
		@PersonSID = @personSID;

end;

	]]>
	</SQLScript>
	<Assertions>
		<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
		<Assertion Type="ExecutionTime" Value="00:00:03" />
	</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.pRegistrant#NextLearningPlan'	
------------------------------------------------------------------------------------------------------------------------------- */

begin
	set nocount on;

	declare
		@errorNo	 int					 = 0											-- 0 no error, <50000 SQL error, else business rule
	 ,@tranCount int					 = @@trancount						-- determines whether a wrapping transaction exists
	 ,@sprocName nvarchar(128) = object_name(@@procid)	-- name of currently executing procedure
	 ,@xState		 int																		-- error state detected in catch block
	 ,@errorText nvarchar(4000);												-- message text (for business rule errors)

	begin try

		-- check parameters

		if @RegistrantSID is null and @PersonSID is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = '@RegistrantSID/@PersonSID';

			raiserror(@errorText, 18, 1);
		end;

		if @RegistrantSID is null -- lookup registrant based on person key
		begin

			select
				@RegistrantSID = r.RegistrantSID
			from
				dbo.Registrant r
			where
				r.PersonSID = @PersonSID;

		end;

		if not exists
		(
			select 1 from		dbo.Registrant r where r.RegistrantSID = @RegistrantSID
		)
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'dbo.Registrant'
			 ,@Arg2 = @RegistrantSID;

			raiserror(@errorText, 18, 1);
		end;

		select
			rnlp.LastPlanRegistrationYear
		 ,rnlp.NextPlanRegistrationYear
		 ,rnlp.IsNextPlanRequired
		 ,rnlp.CycleLengthYears
		from
			dbo.fRegistrant#NextLearningPlan(@RegistrantSID) rnlp;

	end try
	begin catch

		set @xState = xact_state();

		if @tranCount > 0 and @xState = 1
		begin
			rollback transaction @sprocName; -- committable wrapping trx exists: rollback to savepoint
		end;
		else if @xState <> 0 -- full rollback
		begin
			rollback;
		end;

		exec @errorNo = sf.pErrorRethrow; -- process message text and re-throw the error
	end catch;

	return (@errorNo);

end;
GO
