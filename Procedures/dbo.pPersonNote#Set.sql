SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pPersonNote#Set
	@PersonNoteSID		 int = null output	-- optional return key from record inserted
 ,@PersonSID				 int								-- identifies the person to associate note with- ,@ReturnSelect			bit = 0						
 ,@NoteTitle				 nvarchar(65)				-- title for note
 ,@NoteContent			 nvarchar(max)			-- content of note to insert
 ,@PersonNoteTypeSID int = null					-- optionally identifies type of note to add (defaults to "System" note)
as
/*********************************************************************************************************************************
Sproc    : Person Note - Set (add system person note)
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : This procedure TODO: Tim Edlund
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + -----------------------------------------------------------------------------------
 				: Tim Edlund          | Sep 2018		|	Initial version

Comments	
--------
This procedure calls the dbo.pPersonNote#Insert sproc first adding a Person-Note-Type record for "System" if one does not already
exist and no note type parameter is passed.

Known Limitations
-----------------
This procedure does not validate the @PersonSID and @PersonNoteTypeSID parameters. Where these parameters are invalid, errors
are raised by the note #Insert sproc.

Example
-------
<TestHarness>
  <Test Name = "Random" IsDefault ="true" Description="Executes the procedure to insert a rest note for a person selected at random">
    <SQLScript>
      <![CDATA[

declare
	@personSID		 int
 ,@personNoteSID int;

select top (1)
	@personSID = p.PersonSID
from
	sf.Person					 p
join
	dbo.Registrant		 r on p.PersonSID	 = r.RegistrantSID
join
	sf.ApplicationUser au on p.PersonSID = au.PersonSID
where
	au.IsActive = 1
order by
	newid();

if @@rowcount = 0 or @personSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	exec dbo.pPersonNote#Set
		@PersonNoteSID = @personNoteSID output
	 ,@PersonSID = @personSID
	 ,@NoteTitle = 'Test Note'
	 ,@NoteContent = 'This is a test note record only.  It was created [@now].';

	select
		pn.PersonSID
	 ,pn.NoteTitle
	 ,pn.NoteContent
	 ,pn.CreateTime
	from
		dbo.PersonNote pn
	where
		pn.PersonNoteSID = @personNoteSID;

end;

		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:02:00"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pPersonNote#Set'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo	 int					 = 0											-- 0 no error, <50000 SQL error, else business rule
	 ,@tranCount int					 = @@trancount						-- determines whether a wrapping transaction exists
	 ,@sprocName nvarchar(128) = object_name(@@procid)	-- name of currently executing procedure
	 ,@xState		 int;																		-- error state detected in catch block	

	set @PersonNoteSID = null;

	begin try

		-- if a wrapping transaction exists set a save point to rollback to on a local error

		if @tranCount = 0 -- no outer transaction
		begin
			begin transaction;
		end;
		else -- outer transaction so create save point
		begin
			save transaction @sprocName;
		end;

		if @PersonNoteTypeSID is null
		begin

			select
				@PersonNoteTypeSID = pnt.PersonNoteTypeSID
			from
				dbo.PersonNoteType pnt
			where
				pnt.PersonNoteTypeLabel = 'System';

			if @PersonNoteTypeSID is null
			begin

				exec dbo.pPersonNoteType#Insert
					@PersonNoteTypeSID = @PersonNoteTypeSID output
				 ,@PersonNoteTypeLabel = N'System'
				 ,@PersonNoteTypeCategory = N'System';

			end;

		end;

		-- process standard replacements:

		set @NoteContent = replace(@NoteContent, '[@now]', format(sf.fNow(), 'dd-MMM-yyyy hh:mm tt'));

		-- insert the note

		exec dbo.pPersonNote#Insert
			@PersonNoteSID = @PersonNoteSID output
		 ,@PersonSID = @PersonSID
		 ,@PersonNoteTypeSID = @PersonNoteTypeSID
		 ,@NoteTitle = @NoteTitle
		 ,@NoteContent = @NoteContent;

		if @tranCount = 0 and xact_state() = 1 commit transaction;
	end try
	begin catch

		set @xState = xact_state();

		if @tranCount = 0 and (@xState = -1 or @xState = 1)
		begin
			rollback; -- rollback if any transaction is pending (committable or not)
		end;

		exec @errorNo = sf.pErrorRethrow;

	end catch;

	return (@errorNo);
end;
GO
