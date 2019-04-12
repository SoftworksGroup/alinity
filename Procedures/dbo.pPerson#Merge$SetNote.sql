SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pPerson#Merge$SetNote
	@PersonSID	 int						-- key of person to assign note to
 ,@PersonLabel nvarchar(75)		-- identifies the source or target person for the merge
 ,@ChangeLog	 nvarchar(max)	-- log of merge changes (for note content)
 ,@MergeNode	 varchar(10)		-- "SOURCE" or "TARGET" indicating side or merge operation to create note for
as
/*********************************************************************************************************************************
Sproc    : Person - Merge$SetNote
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : This procedure adds a dbo.PersonNote record documenting results of the merge operation
----------------------------------------------------------------------------------------------------------------------------------
History		: Author								| Month Year	| Change Summary
					: --------------------- + ----------- + --------------------------------------------------------------------------------
					: Tim Edlund						| May 2018		|	Initial version

Comments	
--------
This is a subroutine of pPerson#Merge responsible for inserting a dbo.PersonNote record to document results of the merge
operation.  A note is always added to the target record (the "to" person).  A note may be added to the source record if
it was not eliminated by the merge procedure.  The source record is not eliminated if active-practice registrations still
exist after the merge process (see also documentation in caller).

The @MergeNode indicates whether the note is being added to the SOURCE record or TARGET record.  Wording is changes slightly
depending on the node the note is being recorded for.

The procedure uses the "Change Log" text built up by the caller to record in the note content (after some stripping of status
text from the end.  The title of the note includes the PersonLabel content.  When the @MergeNode is "TARGET" the @PersonLabel must 
be set to the source person, and then to the target person when the @MergeNode is "SOURCE". 

This routine does not catch errors or commit transactions. These actions must be performed by the parent procedure. The 
transaction management is omitted since the caller may be invoked in "Preview" mode where all updates are rolled back.

Example
-------
Test this procedure through the parent.  Notes are NOT saved in Preview mode.
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo					 int			= 0										-- 0 no error, <50000 SQL error, else business rule
	 ,@personNoteTypeSID int														-- key of note type to insert
	 ,@noteTitle				 nvarchar(65)										-- title for new note
	 ,@i								 int;														-- string index

	set @noteTitle = N'Content Merged ' + (case when @MergeNode = 'SOURCE' then 'To' else 'From' end) + N': ' + @PersonLabel;

	-- remove note/messages from end of change log

	set @i = charindex('To force deletion', @ChangeLog); -- dependent on text content set in parent procedure!

	if @i > 0
	begin
		set @ChangeLog = left(@ChangeLog, @i - 1);
	end;

	set @i = charindex('Changes Saved', @ChangeLog); -- dependent on text content set in parent procedure!

	if @i > 0
	begin
		set @ChangeLog = left(@ChangeLog, @i - 1);
	end;

	-- the UI will display the note in HTML format so replace
	-- 2 space with non-breaking spaces

	set @ChangeLog = replace(@ChangeLog, N'  ', N'&nbsp;&nbsp;')

	-- add the "System" note type if it does not exist

	select
		@personNoteTypeSID = pnt.PersonNoteTypeSID
	from
		dbo.PersonNoteType pnt
	where
		pnt.PersonNoteTypeLabel = 'System';

	if @personNoteTypeSID is null
	begin

		exec dbo.pPersonNoteType#Insert
			@PersonNoteTypeSID = @personNoteTypeSID output
		 ,@PersonNoteTypeLabel = N'System'
		 ,@PersonNoteTypeCategory = N'System';

	end;

	-- finally insert the note

	exec dbo.pPersonNote#Insert
		@PersonSID = @PersonSID
	 ,@PersonNoteTypeSID = @personNoteTypeSID
	 ,@NoteTitle = @noteTitle
	 ,@NoteContent = @ChangeLog;

	return (@errorNo);
end;
GO
