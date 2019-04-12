SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pForm#Delete$PersonDoc
	@FormRecordSID				int							-- key of the form record being deleted (e.g. RegistrantRenewalSID)
 ,@ApplicationEntitySCD nvarchar(257)		-- schema.tablename of form entity being deleted (e.g. 'dbo.RegistrantRenewal')
 ,@ContextsDeleted			int = 0 output	-- optional - count of person context records deleted by procedure
 ,@PersonDocsDeleted		int = 0 output	-- optional - count of person docs deleted by procedure
as
/*********************************************************************************************************************************
Sproc    : Form (Table) Delete - Person Documents
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : This procedure deletes (dbo) PersonDoc and PersonDocContext records for form records about to be deleted
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + -----------------------------------------------------------------------------------
 				: Tim Edlund          | Nov 2018		|	Initial version

Comments	
--------
This subroutine is designed to be called by form-entity deletion sprocs. For example, by pRegistrantRenewal#Delete.

When a member facing form is withdrawn and then a new form is created for the same registration year, the withdrawn form record
is deleted.  If the form record to be deleted had one or more documents associated with it, those documents require deletion
also.  This must be handled through special logic since no foreign key relationship exists between document-contexts and their
parent record.  The columns "EntitySID" and "ApplicationEntitySID" identify the record and table that relate to the document
and since several tables have these relationships, FK's are not used.

This procedure checks for documents related to the form record about to be deleted. 0, 1 or more than 1 document may be found.
For documents found, the procedure first deletes the context records connecting the document to the @FormRecordSID.  Only 
contexts in the correct table (@ApplicationEntitySCD) are deleted. If the parent document has no other contexts after that 
operation is complete, then the document is also deleted.  

Example:  If a renewal form is fully processed a PDF document for it will be generated and stored with a context. If that
form is later WITHDRAWN, and after that a new form is added, the WITHDRAWN renewal record will be deleted through 
(dbo)pRegistrantRenewal#Delete. This subroutine is called in the pre event to look for the context to the renewal record
about to be deleted. The procedure will delete that context and the PDF of the renewal so no other contexts exist.

Example
-------
<TestHarness>
  <Test Name = "Renewal" IsDefault ="true" Description="Executes the procedure for an orphanned renewal form record">
    <SQLScript>
      <![CDATA[
declare
	@formRecordSID				int
 ,@applicationEntitySCD nvarchar(257) = 'dbo.RegistrantRenewal'
 ,@contextsDeleted			int
 ,@personDocsDeleted		int;

select top (1)
	@formRecordSID = pdc.EntitySID
from
	dbo.PersonDocContext	pdc
join
	dbo.PersonDoc					pd on pdc.PersonDocSID				 = pd.PersonDocSID
join
	sf.ApplicationEntity	ae on pdc.ApplicationEntitySID = ae.ApplicationEntitySID and ae.ApplicationEntitySCD = @applicationEntitySCD
join
	sf.Person							p on pd.PersonSID							 = p.PersonSID
join
	dbo.Registrant				r on p.PersonSID							 = r.PersonSID
left outer join
	dbo.RegistrantRenewal frm on pdc.EntitySID					 = frm.RegistrantRenewalSID
where
	frm.RegistrantRenewalSID is null
order by
	newid();

if @@rowcount = 0 or @formRecordSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	exec dbo.pForm#Delete$PersonDoc
		@FormRecordSID = @formRecordSID
	 ,@ApplicationEntitySCD = @applicationEntitySCD
	 ,@ContextsDeleted = @contextsDeleted output
	 ,@PersonDocsDeleted = @personDocsDeleted output;

	select @contextsDeleted	 ContextsDeleted, @personDocsDeleted PersonDocsDeleted;

end;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:02"/>
    </Assertions>
  </Test>
  <Test Name = "Profile Update" Description="Executes the procedure for an orphanned profile update form record">
    <SQLScript>
      <![CDATA[
declare
	@formRecordSID				int
 ,@applicationEntitySCD nvarchar(257) = 'dbo.ProfileUpdate'
 ,@contextsDeleted			int
 ,@personDocsDeleted		int;

select top (1)
	@formRecordSID = pdc.EntitySID
from
	dbo.PersonDocContext	pdc
join
	dbo.PersonDoc					pd on pdc.PersonDocSID				 = pd.PersonDocSID
join
	sf.ApplicationEntity	ae on pdc.ApplicationEntitySID = ae.ApplicationEntitySID and ae.ApplicationEntitySCD = @applicationEntitySCD
join
	sf.Person							p on pd.PersonSID							 = p.PersonSID
join
	dbo.Registrant				r on p.PersonSID							 = r.PersonSID
left outer join
	dbo.ProfileUpdate frm on pdc.EntitySID					 = frm.ProfileUpdateSID
where
	frm.ProfileUpdateSID is null
order by
	newid();

if @@rowcount = 0 or @formRecordSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	exec dbo.pForm#Delete$PersonDoc
		@FormRecordSID = @formRecordSID
	 ,@ApplicationEntitySCD = @applicationEntitySCD
	 ,@ContextsDeleted = @contextsDeleted output
	 ,@PersonDocsDeleted = @personDocsDeleted output;

	select @contextsDeleted	 ContextsDeleted, @personDocsDeleted PersonDocsDeleted;

end;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:02"/>
    </Assertions>
  </Test>

</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pForm#Delete$PersonDoc'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo			int = 0					-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText		nvarchar(4000)	-- message text for business rule errors
	 ,@personDocSID int							-- key of next document to process
	 ,@maxRow				int							-- loop limit
	 ,@i						int;						-- loop index counter

	declare @work table (ID int not null identity(1, 1), PersonDocSID int not null);

	set @ContextsDeleted = 0;
	set @PersonDocsDeleted = 0;

	begin try

		if @FormRecordSID is null or @ApplicationEntitySCD is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = '@FormRecordSID/@ApplicationEntitySCD';

			raiserror(@errorText, 18, 1);
		end;

		if not exists
		(
			select
				1
			from
				sf.ApplicationEntity ae
			where
				ae.ApplicationEntitySCD = @ApplicationEntitySCD
		)
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'ObjectNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 "%2" was not found.'
			 ,@Arg1 = 'sf.ApplicationEntity'
			 ,@Arg2 = @ApplicationEntitySCD;

			raiserror(@errorText, 18, 1);
		end;

		-- load the work table with unique document identifiers
		-- associated with this form entity and record number

		insert
			@work (PersonDocSID)
		select distinct
			pdc.PersonDocSID
		from
			dbo.PersonDocContext pdc
		join
			sf.ApplicationEntity ae on pdc.ApplicationEntitySID = ae.ApplicationEntitySID and ae.ApplicationEntitySCD = @ApplicationEntitySCD
		where
			pdc.EntitySID = @FormRecordSID;

		set @maxRow = @@rowcount;
		set @i = 0;

		-- process each record

		while @i < @maxRow
		begin

			set @i += 1;

			select @personDocSID = w.PersonDocSID from @work w where w.ID = @i;

			delete -- delete the context records for the next document associated with the form record
			pdc
			from
				dbo.PersonDocContext pdc
			join
				sf.ApplicationEntity ae on pdc.ApplicationEntitySID = ae.ApplicationEntitySID and ae.ApplicationEntitySCD = @ApplicationEntitySCD
			where
				pdc.PersonDocSID = @personDocSID and pdc.EntitySID = @FormRecordSID;

			set @ContextsDeleted += @@rowcount;

			if not exists
			(
				select 1 from		dbo.PersonDocContext pdc where pdc.PersonDocSID = @personDocSID
			) -- if no contexts remain, delete the document
			begin
				delete dbo.PersonDoc where PersonDocSID = @personDocSID;
				set @PersonDocsDeleted += @@rowcount;
			end;

		end;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
