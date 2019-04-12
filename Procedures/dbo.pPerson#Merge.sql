SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pPerson#Merge
	@PersonSIDFrom int			-- key of the person chosen as the duplicate (will be deleted or disabled)
 ,@PersonSIDTo	 int			-- key of the person chosen as the merge target (will be retained)
 ,@ForceDeletion bit = 0	-- when 1, all records including un-moved active-practice type registrations are deleted
 ,@PreviewOnly	 bit = 1	-- indicates that the change log should be returned but transactions rolled back without saving
 ,@DebugLevel		 int = 0	-- when > 0 additional output is sent to the console to trace progress and performance
as
/*********************************************************************************************************************************
Sproc    : Person - Merge
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : This procedure merges records from one Person to another to eliminate duplicates
----------------------------------------------------------------------------------------------------------------------------------
History		: Author	  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Tim Edlund	| May 2018		|	Initial version
					: Tim Edlund	| Jul 2018		| Modified logic to process delete action only where all records move or FORCE is set
					: Russ Poirier| Feb 2019		| Added update statement to set IsPotentialDuplicate flag to @OFF for target record
				
Comments	
--------
This procedure merges the data for one person to another by assigning top level keys to the target person of the merge through 
update statements.  

The top-level keys that are used in re-assignments are:
(sf)	Person ->  PersonSID
(sf)	ApplicationUser -> ApplicationUserSID
(dbo) Registrant -> RegistrantSID

When running merges it is possible the source PersonSID (the "from" key) will not have any associated sf.ApplicationUser
and/or dbo.Registrant record. This scenario is expected by the procedure and will not cause errors.

The subroutine returns a data set including a single column and row summarizing the details of records updated and deleted. The 
log text is only updated when at least 1 row is affected by the statement. This value should be displayed on the UI.

Preview-Only (Rollback)
-----------------------
When the preview mode is set the procedure executes normally but then rolls back the transaction at the end.  The text logging 
changes that will be made is returned for display on the UI.

Un-Movable Records
------------------
Some records cannot be moved where a duplicate would be created by moving them since the target Person may already have the 
record.  In other situations an exact duplicate does not exist but the target Person has a record in the same date range (e.g. 
a Registration or OrgContact record that exists is in the same time period as a record that would otherwise be moved.

Deleting of the un-movable records is carried out IF the "FORCE" parameter is used. Un-movable records are those where
updating to the new key would create a duplicate or violate another business rule.  For example, if both the source and
target person have registrations in the same time period. These records will only be deleted if the force-option is used.

Active-Registrations Remain
---------------------------
After the move process is run the procedure checks if any active-type registrations remain. If any do remain, they are only 
deleted where the @ForceDeletion is passed as 1.  This parameter should only be accessible to system-administrators. Normally
the history of any active-practice-registration should be retained for audit purposes. 

Person-Note Added
-----------------
When the procedure is run (not preview mode) a Person-Note record is created which stores the details of the merging operation.
A note is always record in the target ("To") person record and is also recorded in the source ("From") record where it has
not been moved/deleted.

Maintenance Notes
-----------------
The volume of code involved in processing the updates and deletes for merges is extremely large.  The majority of tables in the 
model are involved in this process.  As the model changes and grows, updates to the procedure is required. 2 subroutines: $Move 
and $Delete - are created to contain the required update and delete statements involved in the merge.  These procedures can be 
mostly generated based on dictionary views. See the documentation in the subroutines for details.  

Example
-------
<TestHarness>
  <Test Name = "Random" IsDefault ="true" Description="Executes merge in preview mode (rolls back) for 2 person records selected at random">
    <SQLScript>
      <![CDATA[
declare
	@personSIDFrom int
 ,@personSIDTo	 int
 ,@changeLog nvarchar(max);

select top (1)
	@personSIDFrom = p.PersonSID
from
	sf.Person							p
left outer join
	sf.ApplicationUser		au on p.PersonSID	 = au.PersonSID
left outer join
	sf.PersonEmailAddress pea on p.PersonSID = pea.PersonSID and pea.IsPrimary = 1
left outer join
	dbo.Registrant				r on p.PersonSID	 = r.PersonSID
where
	p.CreateUser not like 'setup%' and
																 (
																	 pea.EmailAddress is null or pea.EmailAddress like '%@mailinator.com'
																 ) -- restrict to mailinator addresses
	and
	(
		r.RegistrantSID is null or
														(
															select
																count(1)
															from
																dbo.Registration reg
															where
																reg.RegistrantSID = r.RegistrantSID
														) < 2 -- 1 or zero registrations
	)
order by
	newid();

select top (1)
	@personSIDTo = p.PersonSID
from
	sf.Person							p
left outer join
	sf.ApplicationUser		au on p.PersonSID	 = au.PersonSID
left outer join
	sf.PersonEmailAddress pea on p.PersonSID = pea.PersonSID and pea.IsPrimary = 1
left outer join
	dbo.Registrant				r on p.PersonSID	 = r.PersonSID
where
	p.PersonSID									<> @personSIDFrom
	and p.CreateUser not like 'setup%'
	and
	(
		pea.EmailAddress is null or pea.EmailAddress like '%@mailinator.com'
	) -- restrict to mailinator addresses
	and
	(
		r.RegistrantSID is null or
														(
															select
																count(1)
															from
																dbo.Registration reg
															where
																reg.RegistrantSID = r.RegistrantSID
														) > 4 -- 5 or more registrations
	)
order by
	newid();

if @personSIDFrom is null or @personSIDTo is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	exec dbo.pPerson#Merge
		@PersonSIDFrom = @personSIDFrom
	 ,@PersonSIDTo = @personSIDTo
	 ,@ForceDeletion = 1
	 ,@PreviewOnly = 1
	 ,@DebugLevel = 1;

end;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:05"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pPerson#Merge'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo								 int							 = 0											-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText							 nvarchar(4000)															-- message text for business rule errors
	 ,@tranCount							 int							 = @@trancount						-- determines whether a wrapping transaction exists
	 ,@procName								 nvarchar(128)		 = object_name(@@procid)	-- name of currently executing procedure
	 ,@xState									 int																				-- error state detected in catch block
	 ,@blankParm							 varchar(50)																-- tracks name of any required parameter not passed
	 ,@ON											 bit							 = cast(1 as bit)					-- constant for bit comparisons = 1
	 ,@OFF										 bit							 = cast(0 as bit)					-- constant for bit comparison = 0
	 ,@CRLF										 nchar(2)					 = char(13) + char(10)		-- constant for carriage return + line feed pair
	 ,@TAB										 nchar(2)					 = N'  '									-- constant for tab character
	 ,@changeLog							 nvarchar(max)															-- text document returned as data set to UI
	 ,@rowsAffected						 int																				-- tracks rows affected by each update/delete statement
	 ,@activeRegistrationCount int																				-- count of active-practice registrations after moves are complete
	 ,@mergeSource						 xml																				-- document written to user-defined-column of target records to trace source merge keys
	 ,@personLabelFrom				 nvarchar(75)																-- name and ID of person who will be eliminated by merge operation
	 ,@personLabelTo					 nvarchar(75)																-- name and ID of person who is target or the merge (persists after the merge)
	 ,@applicationUserSIDFrom	 int																				-- top level key (sf.ApplicationUser) to be reassigned (source to be updated)
	 ,@applicationUserSIDTo		 int																				-- top level (sf.ApplicationUser) key to be target of reassignment (target update value)
	 ,@registrantSIDFrom			 int																				-- top level key (dbo.Registrant) to be reassigned (source to be updated)
	 ,@registrantSIDTo				 int																				-- top level (dbo.Registrant) key to be target of reassignment (target update value)
	 ,@noteText								 nvarchar(1000)															-- additional notes to add to change log at end
	 ,@otherText							 nvarchar(1000)															-- content for "other" section in change log where required
	 ,@timeCheck							 datetimeoffset(7) = sysdatetimeoffset();		-- timing mark trace value for debug output

	begin try

		-- process DB changes as a transaction
		-- to enable partial rollback on error

		if @tranCount = 0
		begin

			if @DebugLevel > 1
			begin

				exec sf.pDebugPrint
					@DebugString = N'Initiating transaction (no save point)'
				 ,@TimeCheck = @timeCheck output;

			end;

			begin transaction; -- no wrapping transaction
		end;
		else
		begin

			if @DebugLevel > 1
			begin

				exec sf.pDebugPrint
					@DebugString = N'Initiating transaction (with save point)'
				 ,@TimeCheck = @timeCheck output;

			end;

			save transaction @procName; -- previous trx pending - create save point
		end;

		-- check parameters

		if @PersonSIDFrom is null
		begin
			set @blankParm = '@PersonSIDFrom';
		end;

		if @PersonSIDTo is null
		begin
			set @blankParm = '@PersonSIDTo';
		end;

		if @blankParm is not null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = @blankParm;

			raiserror(@errorText, 18, 1);
		end;

		select
			@personLabelFrom				= dbo.fRegistrant#Label(p.LastName, p.FirstName, p.MiddleNames, r.RegistrantNo, 'REGISTRATION')
		 ,@applicationUserSIDFrom = au.ApplicationUserSID
		 ,@registrantSIDFrom			= r.RegistrantSID
		from
			sf.Person					 p
		left outer join
			sf.ApplicationUser au on p.PersonSID = au.PersonSID
		left outer join
			dbo.Registrant		 r on p.PersonSID	 = r.PersonSID
		where
			p.PersonSID = @PersonSIDFrom;

		if @personLabelFrom is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'sf.Person'
			 ,@Arg2 = @PersonSIDFrom;

			raiserror(@errorText, 18, 1);
		end;

		select
			@personLabelTo				= dbo.fRegistrant#Label(p.LastName, p.FirstName, p.MiddleNames, r.RegistrantNo, 'REGISTRATION')
		 ,@applicationUserSIDTo = au.ApplicationUserSID
		 ,@registrantSIDTo			= r.RegistrantSID
		from
			sf.Person					 p
		join
			sf.ApplicationUser au on p.PersonSID = au.PersonSID
		left outer join
			dbo.Registrant		 r on p.PersonSID	 = r.PersonSID
		where
			p.PersonSID = @PersonSIDTo;

		if @personLabelTo is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'sf.Person'
			 ,@Arg2 = @PersonSIDTo;

			raiserror(@errorText, 18, 1);
		end;

		set @changeLog = N'Source (duplicate): ' + @personLabelFrom;
		set @changeLog += @CRLF + N'Target ->>>>>>>>>>: ' + @personLabelTo;

		if @DebugLevel > 0
		begin
			set @changeLog = replace(@changeLog, 'DETAILS (Preview)', ''); -- shorten to fit in name references
			set @changeLog += @CRLF + '@PersonSIDFrom = ' + ltrim(@PersonSIDFrom) + @CRLF + '@PersonSIDTo = ' + ltrim(@PersonSIDTo);
		end;

		if @DebugLevel > 1
		begin

			exec sf.pDebugPrint
				@DebugString = @changeLog
			 ,@TimeCheck = @timeCheck output;

		end;

		-- create form extension document to store details
		-- of the merge operation to write to moved record

		-- SQL Prompt formatting off
		set @mergeSource = 
				cast(
					replace(
					replace(
					replace(
					replace(
					replace(
					replace(
N'<FormExtension>
	<Sections>
		<Section ID="MRG%1">
			<Label>Merged From: %2</Label>
			<Row>
				<Cell>
					<Field ID="MergeAudit" Type="Text" Value="%3">
						<Label>Merge audit</Label>
					</Field>
					<Field ID="PersonSID" Type="Numeric" Value="%4">
						<Label>Person key</Label>
					</Field>
					<Field ID="ApplicationUserSID" Type="Numeric" Value="%5">
						<Label>User key</Label>
					</Field>					
					<Field ID="RegistrantSID" Type="Numeric" Value="%6">
						<Label>Registrant key</Label>
					</Field>
				</Cell>
			</Row>
		</Section>
	</Sections>
</FormExtension>' 
					,'%1', format(sysdatetime(), 'yyyyMMddHHmm'))
					,'%2', @personLabelFrom)
					,'%3', format(sf.fNow(),'d-MMM-yyyy HH\:mm') + ' ' + sf.fApplicationUserSession#UserName())
					,'%4', @PersonSIDFrom)
					,'%5', @applicationUserSIDFrom)
					,'%6', @registrantSIDFrom)
				as xml)
		-- SQL Prompt formatting on

		-- process the re-assignments of the parent keys
		-- ("Move" operations)

		exec dbo.pPerson#Merge$Move
			@PersonSIDFrom = @PersonSIDFrom
		 ,@PersonSIDTo = @PersonSIDTo
		 ,@ApplicationUserSIDFrom = @applicationUserSIDFrom
		 ,@ApplicationUserSIDTo = @applicationUserSIDTo
		 ,@RegistrantSIDFrom = @registrantSIDFrom
		 ,@RegistrantSIDTo = @registrantSIDTo
		 ,@MergeSource = @mergeSource
		 ,@ChangeLog = @changeLog output
		 ,@DebugLevel = @DebugLevel;

		-- determine if any active-practice type registrations 
		-- remain; if so these block deletion unless Forced is ON

		if @ForceDeletion = @ON
		begin
			set @activeRegistrationCount = 0; -- enables deletion to occur even if active registrations remain
		end;
		else if @registrantSIDTo is not null
		begin

			select
				@activeRegistrationCount = count(1)
			from
				dbo.Registration						reg
			join
				dbo.PracticeRegisterSection prs on reg.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
			join
				dbo.PracticeRegister				pr on prs.PracticeRegisterSID					= pr.PracticeRegisterSID and pr.IsActivePractice = @ON
			where
				reg.RegistrantSID = @registrantSIDFrom;

			if @activeRegistrationCount > 0 -- if changing the text below update pPerson#Merge$SetNote!
			begin

				set @noteText =
					ltrim(@activeRegistrationCount) + N' Active-practice registration(s) could not be moved to target due to overlapping periods. '
					+ N'The remaining registration details for the source record are not deleted to preserve history on the Register. To force '
					+ N'deletion of these records, apply the "Force delete" option.';

			end;

		end;
		else
		begin
			set @activeRegistrationCount = 1; -- set to 1 to bypass since no "TO" person exists
		end;

		if @activeRegistrationCount = 0 -- do not attempt to delete records if active registrations exist unless FORCE option was called (above)
		begin

			exec dbo.pPerson#Merge$Delete
				@PersonSIDFrom = @PersonSIDFrom
			 ,@ChangeLog = @changeLog output
			 ,@DebugLevel = @DebugLevel;

		end;

		-- process final updates to ensure the "From" records
		-- in the merge are disabled if not-deleted

		update
			sf.ApplicationUser
		set
			IsActive = @OFF
		where
			PersonSID = @PersonSIDFrom and IsActive = @ON;

		set @rowsAffected = @@rowcount;

		if @rowsAffected > 0
		begin
			set @otherText = @TAB + N'Account login disabled for source record';
		end;

		update
			sf.Person
		set
			IsTextMessagingEnabled = @OFF
		where
			PersonSID = @PersonSIDFrom and IsTextMessagingEnabled = @ON;

		set @rowsAffected = @@rowcount;

		if @rowsAffected > 0
		begin
			set @otherText = isnull(@otherText + @CRLF, '') + @TAB + N'Text messaging disabled for source record';
		end;

		if @registrantSIDFrom is not null
		begin

			update
				dbo.Registrant
			set
				IsOnPublicRegistry = @OFF
			 ,DirectedAuditYearCompetence = null
			 ,DirectedAuditYearPracticeHours = null
			where
				RegistrantSID = @registrantSIDFrom and IsOnPublicRegistry = @ON;

			set @rowsAffected = @@rowcount;

			if @rowsAffected > 0
			begin
				set @otherText = isnull(@otherText + @CRLF, '') + @TAB + N'Public directory disabled for source record';
			end;

		end;

		if @otherText is not null
		begin
			set @changeLog += @CRLF + @CRLF + N'Other' + @CRLF + @otherText;
		end;

		if @noteText is not null
		begin
			set @changeLog += @CRLF + @CRLF + N'Note!' + @CRLF + N'-----' + @CRLF + @noteText;
		end;

		-- where preview mode is specified updated the
		-- the text for appropriate wording and rollback

		if @PreviewOnly = @ON
		begin

			set @changeLog += @CRLF + @CRLF + N'*** PREVIEW ONLY - No Changes Were Saved ***';

			if @DebugLevel > 1
			begin

				exec sf.pDebugPrint
					@DebugString = 'Rolling back for preview mode'
				 ,@TimeCheck = @timeCheck output;

			end;

			set @xState = xact_state();

			if @tranCount > 0 and @xState = 1
			begin
				rollback transaction @procName; -- rollback to save point
			end;
			else if @xState <> 0 -- full rollback
			begin
				rollback;
			end;

		end;
		else -- otherwise save a note to the record(s) and save the changes
		begin

			if @DebugLevel > 1
			begin

				exec sf.pDebugPrint
					@DebugString = 'Saving notes'
				 ,@TimeCheck = @timeCheck output;

			end;

			exec dbo.pPerson#Merge$SetNote
				@PersonSID = @PersonSIDTo
			 ,@PersonLabel = @personLabelFrom
			 ,@ChangeLog = @changeLog
			 ,@MergeNode = 'TARGET';

			if exists (select 1 from sf .Person p where p.PersonSID = @PersonSIDFrom)
			begin

				exec dbo.pPerson#Merge$SetNote
					@PersonSID = @PersonSIDFrom
				 ,@PersonLabel = @personLabelTo
				 ,@ChangeLog = @changeLog
				 ,@MergeNode = 'SOURCE';	-- only add note to source if it was not eliminated by deletion

			end;

			-- set the IsPotentialDuplicate flag on the sf.ApplicationUser record to @OFF for the @PersonSIDTo ID

			update
				sf.ApplicationUser
			set
				IsPotentialDuplicate = @OFF
			where
				PersonSID = @PersonSIDTo;

			if @DebugLevel > 1
			begin

				exec sf.pDebugPrint
					@DebugString = 'Committing transaction'
				 ,@TimeCheck = @timeCheck output;

			end;

			if @tranCount = 0 and xact_state() = 1
			begin
				commit;
				set @changeLog += @CRLF + @CRLF + N'Changes Saved'; -- if changing this text update pPerson#Merge$SetNote!
			end;

		end;

		if @DebugLevel > 0
		begin
			print @CRLF + @CRLF;
			exec sf.pLinePrint @TextToPrint = @changeLog;
		end;

		select @changeLog	 ChangeLog; -- always return the ChangeLog text

	end try
	begin catch

		-- if a transaction was pending at start of routine 
		-- perform partial rollback to save point

		set @xState = xact_state();

		if @tranCount > 0 and @xState = 1
		begin
			rollback transaction @procName; -- rollback to save point
		end;
		else if @xState <> 0 -- full rollback
		begin
			rollback;
		end;

		-- print the change log to trace position 
		-- of error (debugging support)

		if @DebugLevel > 0
		begin
			print @CRLF + @CRLF;
			exec sf.pLinePrint @TextToPrint = @changeLog;
		end;

		exec @errorNo = sf.pErrorRethrow; -- process message text and re-throw the error

	end catch;

	return (@errorNo);
end;
GO
