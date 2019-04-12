SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pForm#Approve$SetPersonDoc
	@PersonSID						int						-- person to attach document to
 ,@ConfirmationDraft		nvarchar(max) -- HTML version of document to store (for pickup by PDF generation service)
 ,@PersonDocTypeSCD			varchar(15)		-- code identifying the type of document - e.g. "RENEWAL"
 ,@ApplicationEntitySCD nvarchar(257) -- schema and table name of context entity - e.g. "dbo.RegistrantRenewal"
 ,@FormRecordSID				int						-- key of the form record to associate with e new document
 ,@Title								nvarchar(100) -- title to assign to the document (do not include current time suffix)
 ,@IsPrimary						bit = 1				-- pass as 0 for review forms, always primary for main form types
 ,@SubFormRecordSID			int = null		-- required when IsPrimary = 0 to identify sub-form to truncate draft content
as
/*********************************************************************************************************************************
Sproc    : Form Approve - Set Person Doc
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : This procedure inserts a (dbo) PersonDoc and PersonDocContext record with the HTML required for PDF generation
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Nov 2018		|	Initial version
				: Cory Ng							| Dec 2018		| Fixed bug where application entity SID was not being looked up

Comments	
--------
This procedure is called by member form #Approve sprocs (e.g. dbo.pRegistrantRenewal#Approve) to save the HTML version of the
approved form to the (dbo) PersonDoc table.  A context record (dbo) PersonDocContext is also inserted with the context pointing
to the form entity and form record number.

The procedure is part of the PDF generation sub-system used by Alinity forms.  Because creation of PDF documents is relatively 
slow (2-4 seconds) and PDF's are not generally required immediately after approval, the application creates the PDF through
a background service. This procedure sets up the record with the HTML content required for the service to generate the PDF.

Is Primary
---------
When the context is set for the document the primary setting should always be used except for review forms.  Review forms,
for example an audit-review, has its context set to the parent record (dbo.RegistrantAudit) and since the main audit form
will also be established as the primary person-document for that entity record, the review form must be inserted as
non-primary.

Optimization
------------
This version of the procedure avoids duplicating insert of the same document by checking first for the context and document. This
SELECT may be remove-able after the revised PDF sub-system is completely implemented.  The logic allows the insertion of the PDF 
to be carried out directly by the front-end (old method) while still support insert of the document by the back end (new method).

Example
-------

This procedure can only be tested through the Approve process:

<TestHarness>
	<Test Name="Simple" IsDefault="true" Description="Approve a Renewal form in submitted status at random">
		<SQLScript>
			<![CDATA[
			
declare
	@registrantRenewalSID		int

select top 1
	@registrantRenewalSID = rr.RegistrantRenewalSID
from
	dbo.vRegistrantRenewal rr
where
	rr.FormStatusSCD = 'SUBMITTED'
order by
	newid()

exec dbo.pRegistrantRenewal#Approve
	 @RegistrantRenewalSID = @registrantRenewalSID

select
	x.DocumentTitle
 ,x.ApplicationEntitySID
 ,x.EntitySID
from
	dbo.vPersonDoc x
where
	x.EntitySID = @registrantRenewalSID

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1"/>
			<Assertion Type="ExecutionTime" Value="6" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pForm#Approve$SetPersonDoc'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo							 int					 = 0							-- 0 no error, <50000 SQL error, else business rule
	 ,@blankParm						 varchar(50)										-- tracks if any required parameters are not provided
	 ,@errorText						 nvarchar(4000)									-- message text for business rule errors
	 ,@ON										 bit					 = cast(1 as bit) -- constant for bit comparisons = 1
	 ,@OFF									 bit					 = cast(0 as bit) -- constant for bit comparison = 0
	 ,@applicationEntitySID	 int;														-- key of the entity for context

	begin try

-- SQL Prompt formatting off
		if @PersonSID							is null set @blankParm = '@PersonSID';
		if @ConfirmationDraft			is null set @blankParm = '@ConfirmationDraft';
		if @PersonDocTypeSCD			is null set @blankParm = '@PersonDocTypeSID';
		if @ApplicationEntitySCD	is null set @blankParm = '@ApplicationEntitySCD'
		if @FormRecordSID					is null set @blankParm = '@FormRecordSID'
		if @Title								  is null set @blankParm = '@Title'
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

		if @IsPrimary is null -- default to primary if passed as NULL
		begin
			set @IsPrimary = @ON;
		end;

		if @IsPrimary = @OFF and @SubFormRecordSID is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = '@SubFormRecordSID';

			raiserror(@errorText, 18, 1);
		end;

		select
			@applicationEntitySID = ae.ApplicationEntitySID
		from
			sf.ApplicationEntity ae
		where
			ae.ApplicationEntitySCD = @ApplicationEntitySCD;

		if @applicationEntitySID is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'sf.ApplicationEntity'
			 ,@Arg2 = @ApplicationEntitySCD;

			raiserror(@errorText, 18, 1);

		end;

		-- call the EF sproc to insert both the HTML document
		-- and a context record to the main form entity (passed through)
		-- if not already inserted (by the front end)

		if not exists
		(
			select
				1
			from
				dbo.PersonDocContext pdc
			join
				dbo.PersonDoc				 pd on pdc.PersonDocSID = pd.PersonDocSID and pd.PersonSID = @PersonSID
			where
				pdc.ApplicationEntitySID = @applicationEntitySID and pdc.EntitySID = @FormRecordSID and pdc.IsPrimary = @IsPrimary
		)
		begin

			exec dbo.pPersonDoc#Insert
				@PersonSID = @PersonSID
			 ,@PersonDocTypeSCD = @PersonDocTypeSCD
			 ,@DocumentTitle = @Title
			 ,@DocumentHTML = @ConfirmationDraft
			 ,@FileTypeSCD = '.PDF'
			 ,@ApplicationEntitySID = @applicationEntitySID
			 ,@EntitySID = @FormRecordSID
			 ,@IsPrimary = @IsPrimary
			 ,@ShowToRegistrant = @ON;

			-- with the document saved, remove the duplicate content 
			-- from the source record to conserve space; note that
			-- audit columns are intentionally NOT modified (sys update)

			if @ApplicationEntitySCD = 'dbo.RegistrantRenewal'
			begin

				update
					dbo.RegistrantRenewal
				set
					ConfirmationDraft = null
				where
					RegistrantRenewalSID = @FormRecordSID;

			end;
			else if @ApplicationEntitySCD = 'dbo.RegistrantApp'
			begin

				if @SubFormRecordSID is null
				begin

					update
						dbo.RegistrantApp
					set
						ConfirmationDraft = null
					where
						RegistrantAppSID = @FormRecordSID;

				end;
				else
				begin

					update
						dbo.RegistrantAppReview
					set
						ConfirmationDraft = null
					where
						RegistrantAppSID = @SubFormRecordSID;

				end;

			end;
			else if @ApplicationEntitySCD = 'dbo.Reinstatement'
			begin

				update
					dbo.Reinstatement
				set
					ConfirmationDraft = null
				where
					ReinstatementSID = @FormRecordSID;

			end;
			else if @ApplicationEntitySCD = 'dbo.ProfileUpdate'
			begin

				update
					dbo.ProfileUpdate
				set
					ConfirmationDraft = null
				where
					ProfileUpdateSID = @FormRecordSID;

			end;
			else if @ApplicationEntitySCD = 'dbo.RegistrantLearningPlan'
			begin

				update
					dbo.RegistrantLearningPlan
				set
					ConfirmationDraft = null
				where
					RegistrantLearningPlanSID = @FormRecordSID;

			end;
			else if @ApplicationEntitySCD = 'dbo.RegistrantAudit'
			begin

				if @SubFormRecordSID is null
				begin

					update
						dbo.RegistrantAudit
					set
						ConfirmationDraft = null
					where
						RegistrantAuditSID = @FormRecordSID;

				end;
				else
				begin

					update
						dbo.RegistrantAuditReview
					set
						ConfirmationDraft = null
					where
						RegistrantAuditSID = @SubFormRecordSID;

				end;
			end;
			else
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'NotInList'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The %1 provided "%2" is not valid. It must be one of: %3'
				 ,@Arg1 = 'Entity'
				 ,@Arg2 = @ApplicationEntitySCD
				 ,@Arg3 = 'dbo.RegistrantRenewal, dbo.RegistrantApp, dbo.Reinstatement, dbo.ProfileUpdate, dbo.RegistrantLearningPlan, dbo.RegistrantAudit';

				raiserror(@errorText, 18, 1);
			end;
		end;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
