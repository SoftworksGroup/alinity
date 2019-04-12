SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pRegistrantAuditReview#Set
	@Audits		 xml	-- list of RegistrantAuditSID's to assign reviewer(s) to
 ,@Reviewers xml	-- list of PersonSID's to assign as reviewers
as
/*********************************************************************************************************************************
Procedure : Registrant Audit Review - Set (Reviewers)
Notice    : Copyright © 2017 Softworks Group Inc.
Summary   : Creates dbo.RegistrantAuditReview records for the list of registrant audit and review keys passed in
-----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)				| Month Year  | Change Summary
				 : ----------------	|	----------	| --------------
				 : Tim Edlund				| May 2017    | Initial version
				 : Taylor Napier		| Aug	2018		| Allow multiple reviews by the same user if the previous review is in a final status
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure assigns one or more reviewers to one or more registrant audit records. The assignment of reviewers to audit records
is typically accomplished using teams of 2 reviewers, who are the assigned to a list of audits selected randomly through a user
interface component.  The list of reviewers to assign, and the list of audits to assign them to is identified using the xml
parameters which have the following expected format:

<Audits>
		<RegistrantAudit SID="1000001" />
		<RegistrantAudit SID="1000011" />
		<RegistrantAudit SID="1000123" />
</Audits>

<Reviewers>
		<Person SID="1000001" IsWithdrawn="true" />
		<Person SID="1000002" IsWithdrawn="false" />
		<Person SID="1000003" IsWithdrawn="false" />
</Reviewers>

If a single reviewer is being assigned to a single audit record, then a single key value is included in each xml
parameter.

Existing Review Assignments
---------------------------
The caller may also pass keys of existing review assignments.  If the IsWithdrawn attribute is set ON, then the procedure
will delete the existing assignment if it is still in "NEW" status (form never submitted by reviewer). If the keys of an
existing assignment record are passed in but the IsWithdrawn attribute is OFF, the no change is made to the existing record.

Example
-------

Test from front end (UI).
-------------------------------------------------------------------------------------------------------------------------------- */

set nocount on;

begin

	declare
		@errorNo									int						= 0								-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText								nvarchar(4000)									-- message text (for business rule errors)
	 ,@blankParm								nvarchar(100)										-- error checking buffer for required parameters
	 ,@ON												bit						= cast(1 as bit)	-- used on bit comparisons to avoid multiple casts
	 ,@a												int															-- loop index
	 ,@r												int															-- loop index
	 ,@maxRowsA									int															-- loop limit
	 ,@maxRowsR									int															-- loop limit
	 ,@auditSID									int															-- key of next audit record to assign
	 ,@personSID								int															-- key of next person to assign as a reviewer
	 ,@registrantAuditReviewSID int															-- key of existing review record
	 ,@isWithdrawn							bit															-- indicates whether existing assignment is being withdrawn
	 ,@reviewStatusSCD					varchar(25)											-- status of existing review record
	 ,@isFinalStatus						bit;														-- whether existing review record is in final form

	declare @workA table -- table of audit keys to process
	(ID int identity(1, 1), RegistrantAuditSID int not null);

	declare @workR table -- table of reviewer keys to process
	(
		ID					int identity(1, 1)
	 ,PersonSID		int not null
	 ,IsWithdrawn bit not null default cast(0 as bit)
	);

	begin try

		-- check parameters

		if @Audits is null set @blankParm = N'@Audits';
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
			@workA (RegistrantAuditSID)
		select
			RegistrantAudit.ra.value('@SID', 'int')
		from
			@Audits.nodes('//RegistrantAudit') RegistrantAudit(ra);

		set @maxRowsA = @@rowcount;
		set @a = 0;

		if @maxRowsA = 0
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = '@Audits';

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

		while @a < @maxRowsA -- first proceed through each audit in the list passed
		begin

			set @a += 1;
			set @r = 0;

			while @r < @maxRowsR -- then through each reviewer
			begin

				set @r += 1;
				set @auditSID = null;
				set @personSID = null;
				set @registrantAuditReviewSID = null;
				set @isFinalStatus = null;

				select top(1)		-- if there are multiple reviews for this audit/person combo, get the latest
					@auditSID									= a.RegistrantAuditSID
				 ,@personSID								= r.PersonSID
				 ,@isWithdrawn							= r.IsWithdrawn
				 ,@registrantAuditReviewSID = ar.RegistrantAuditReviewSID
				 ,@reviewStatusSCD					= ar.RegistrantAuditReviewStatusSCD
				 ,@isFinalStatus						= fs.IsFinal
				from
					@workA													a
				join
					@workR													r on r.ID																	= @r
				left outer join
					dbo.vRegistrantAuditReview			ar on a.RegistrantAuditSID								= ar.RegistrantAuditSID and r.PersonSID = ar.PersonSID
				left outer join
					dbo.RegistrantAuditReviewStatus rars on ar.RegistrantAuditReviewStatusSID = rars.RegistrantAuditReviewStatusSID
				left outer join
					sf.FormStatus										fs on rars.FormStatusSID									= fs.FormStatusSID
				where
					a.ID = @a
				order by
					ar.CreateTime desc;


				if @registrantAuditReviewSID is not null -- an assignment already exists for this person to the audit
				begin

					if @isWithdrawn = @ON -- if withdrawing, delete if NEW
					begin

						if @reviewStatusSCD = 'NEW'
						begin

							exec dbo.pRegistrantAuditReview#Delete
								@RegistrantAuditReviewSID = @registrantAuditReviewSID;

						end;
						else
						begin -- otherwise, change status to withdrawn

							exec dbo.pRegistrantAuditReview#Update
								@RegistrantAuditReviewSID = @registrantAuditReviewSID
							 ,@NewFormStatusSCD = 'WITHDRAWN';

						end;
					end;
					else if @isFinalStatus = @ON -- if they've already completed their previous review, allow another to be added
					begin

						exec dbo.pRegistrantAuditReview#Insert -- insert a new review record for an additional round of reviews
							@RegistrantAuditSID = @auditSID
						 ,@PersonSID = @personSID;	-- lookup of default form version is handled within the sproc

						if not exists
						(
							select
								1
							from
								dbo.fRegistrantAudit#Ext(@auditSID) x
							where
								isnull(x.FormStatusSCD, '~') = 'INREVIEW'
						)
						begin

							exec dbo.pRegistrantAuditStatus#Insert -- if not already set; change status of main form to INREVIEW
								@RegistrantAuditSID = @auditSID
							 ,@FormStatusSCD = 'INREVIEW';

						end;

					end; -- if existing row found but not in a final status - skip the record

				end;
				else
				begin

					exec dbo.pRegistrantAuditReview#Insert -- no assignment exists - insert a new review record
						@RegistrantAuditSID = @auditSID
					 ,@PersonSID = @personSID;	-- lookup of default form version is handled within the sproc

					if not exists
					(
						select
							1
						from
							dbo.fRegistrantAudit#Ext(@auditSID) x
						where
							isnull(x.FormStatusSCD, '~') = 'INREVIEW'
					)
					begin

						exec dbo.pRegistrantAuditStatus#Insert -- if not already set; change status of main form to INREVIEW
							@RegistrantAuditSID = @auditSID
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
