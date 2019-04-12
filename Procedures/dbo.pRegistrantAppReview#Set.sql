SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pRegistrantAppReview#Set
	@Apps			 xml	-- list of RegistrantAppSID's to assign reviewer(s) to
 ,@Reviewers xml	-- list of PersonSID's to assign as reviewers
as
/*********************************************************************************************************************************
Procedure : Registrant Application Review - Set (Reviewers)
Notice    : Copyright © 2017 Softworks Group Inc.
Summary   : Creates dbo.RegistrantAppReview records for the list of registrant application and review keys passed in
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Jun 2017		|	Initial version
				: Tim Edlund					| Sep 2018		| Added check to ensure main form not already finalized and performance tuning.

Comments	
--------
This procedure assigns one or more reviewers to one or more registrant application records. One or more reviewers may be assigned
to an application.  In some configurations, the reviewer is an employer supervisor confirming working status and/or skills of 
the registrant.  The list of reviewers to assign, and the list of applications to assign them to is identified using the xml 
parameters which have the following expected format:

<Apps>
		<RegistrantApp SID="1000001" />
		<RegistrantApp SID="1000011" />
		<RegistrantApp SID="1000123" />
</Apps>

<Reviewers>
		<Person SID="1000001" IsWithdrawn="true" />
		<Person SID="1000002" IsWithdrawn="false" />
		<Person SID="1000003" IsWithdrawn="false" />
</Reviewers>

If a single reviewer is being assigned to a single application record, then a single key value is included in each xml
parameter.

Existing Review Assignments
---------------------------
The caller may also pass keys of existing review assignments.  If the IsWithdrawn attribute is set ON, then the procedure
will delete the existing assignment if it is still in "NEW" status (form never submitted by reviewer). If the form has been
submitted by the reviewer, the status will be changed to "WITHDRAWN" unless the review is in a final status (e.g. "APPROVED" or
"REJECTED" - in which case no change in status is processed.  These rules are designed to preserve the application trail of review
findings.  If the keys of an existing assignment record are passed in but the IsWithdrawn attribute is OFF, the no change is
made to the existing record.

Example
-------

Test from front end.
-------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo								int						= 0								-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText							nvarchar(4000)									-- message text (for business rule errors)
	 ,@blankParm							nvarchar(100)										-- error checking buffer for required parameters
	 ,@ON											bit						= cast(1 as bit)	-- used on bit comparisons to avoid multiple casts
	 ,@OFF										bit						= cast(0 as bit)	-- used on bit comparisons to avoid multiple casts	
	 ,@a											int															-- loop index
	 ,@r											int															-- loop index
	 ,@maxRowsA								int															-- loop limit
	 ,@maxRowsR								int															-- loop limit
	 ,@applicationSID					int															-- key of next application record to assign
	 ,@personSID							int															-- key of next person to assign as a reviewer
	 ,@registrantAppReviewSID int															-- key of existing review record 
	 ,@isWithdrawn						bit															-- indicates whether existing assignment is being withdrawn
	 ,@mainStatusSCD					varchar(25)											-- status code of main form (application)
	 ,@mainStatusLabel				nvarchar(35)										-- status label of main form (application)
	 ,@isMainFinal						bit															-- whether existing main (application) record is in final form 
	 ,@reviewStatusSCD				varchar(25)											-- status of existing review record
	 ,@isReviewFinal					bit;														-- whether existing review record is in final form 

	declare @workA table -- table of application keys to process
	(ID int identity(1, 1), RegistrantAppSID int not null);

	declare @workR table -- table of reviewer keys to process
	(
		ID					int identity(1, 1)
	 ,PersonSID		int not null
	 ,IsWithdrawn bit not null default cast(0 as bit)
	);

	begin try

		-- check parameters

		if @Apps is null set @blankParm = N'@Apps';
		if @Reviewers is null set @blankParm = N'@Reviewers';

		if @blankParm is not null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = @blankParm;

			raiserror(@errorText, 18, 1);

		end;

		insert
			@workA (RegistrantAppSID)
		select
			RegistrantApp.ra.value('@SID', 'int')
		from
			@Apps.nodes('//RegistrantApp') RegistrantApp(ra);

		set @maxRowsA = @@rowcount;
		set @a = 0;

		if @maxRowsA = 0
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = '@Apps';

			raiserror(@errorText, 16, 1);

		end;

		insert
			@workR (PersonSID, IsWithdrawn)
		select
			Person.p.value('@SID', 'int')
		 ,Person.p.value('@IsWithdrawn', 'bit')
		from
			@Reviewers.nodes('//Person') Person(p);

		set @maxRowsR = @@rowcount;
		set @r = 0;

		if @@rowcount = 0
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = '@@Reviewers';

			raiserror(@errorText, 16, 1);

		end;

		-- commit all assignments as a single transaction
		-- (succeeds or all rollback)

		begin transaction;

		while @a < @maxRowsA -- first proceed through each application in the list passed
		begin

			set @a += 1;
			set @r = 0;

			while @r < @maxRowsR -- then through each reviewer 
			begin

				set @r += 1;
				set @applicationSID = null;
				set @personSID = null;
				set @registrantAppReviewSID = null;
				set @isReviewFinal = null;

				select
					@applicationSID					= a.RegistrantAppSID
				 ,@personSID							= r.PersonSID
				 ,@isWithdrawn						= r.IsWithdrawn
				 ,@registrantAppReviewSID = appRvw.RegistrantAppReviewSID
				 ,@reviewStatusSCD				= appRvw.RegistrantAppReviewStatusSCD
				 ,@isReviewFinal					= fs.IsFinal
				from
					@workA												a
				join
					@workR												r on r.ID																= @r
				left outer join
					dbo.vRegistrantAppReview			appRvw on a.RegistrantAppSID								= appRvw.RegistrantAppSID and r.PersonSID = appRvw.PersonSID
				left outer join
					dbo.RegistrantAppReviewStatus st on appRvw.RegistrantAppReviewStatusSID = st.RegistrantAppReviewStatusSID
				left outer join
					sf.FormStatus									fs on st.FormStatusSID								= fs.FormStatusSID
				where
					a.ID = @a;

				if @applicationSID is null
				begin

					exec sf.pMessage#Get
						@MessageSCD = 'BlankParameter'
					 ,@MessageText = @errorText output
					 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
					 ,@Arg1 = '@ApplicationSID';

					raiserror(@errorText, 18, 1);

				end;

				select
					@mainStatusSCD	 = cs.FormStatusSCD
				 ,@mainStatusLabel = cs.FormStatusLabel
				 ,@isMainFinal		 = cs.IsFinal
				from
					dbo.fRegistrantApp#CurrentStatus(@applicationSID, -1) cs;

				if @isMainFinal = @ON
				begin

					exec sf.pMessage#Get
						@MessageSCD = 'ReviewersNotAssignable'
					 ,@MessageText = @errorText output
					 ,@DefaultText = N'Reviewers cannot be assigned because the %1 is finalized (status is "%2").'
					 ,@Arg1 = 'application'
					 ,@Arg2 = @mainStatusLabel;

					raiserror(@errorText, 18, 1);

				end;

				if @registrantAppReviewSID is not null -- an assignment already exists for this person to the audit
				begin

					if @isWithdrawn = @ON -- if withdrawing, delete if NEW 
					begin

						if @reviewStatusSCD = 'NEW'
						begin

							exec dbo.pRegistrantAppReview#Delete
								@RegistrantAppReviewSID = @registrantAppReviewSID;

						end;
						else if @isReviewFinal = @OFF -- if review is in final status, do not update but otherwise
						begin -- change status to withdrawn

							exec dbo.pRegistrantAppReview#Update
								@RegistrantAppReviewSID = @registrantAppReviewSID
							 ,@NewFormStatusSCD = 'WITHDRAWN';

						end;
					end; -- if existing row found but not withdrawing - skip the record			

				end;
				else
				begin

					exec dbo.pRegistrantAppReview#Insert -- no assignment exists - insert a new review record
						@RegistrantAppSID = @applicationSID
					 ,@PersonSID = @personSID;	-- lookup of default form version is handled within the sproc

					if @mainStatusSCD <> 'INREVIEW'
					begin

						exec dbo.pRegistrantAppStatus#Insert -- if not already set; change status of main form to INREVIEW
							@RegistrantAppSID = @applicationSID
						 ,@FormStatusSCD = 'INREVIEW';

					end;

				end;

			end;

		end;

		commit; -- process succeeded, so commit all assignments

	end try
	begin catch
		if @@trancount > 0 rollback;
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);

end;
GO
