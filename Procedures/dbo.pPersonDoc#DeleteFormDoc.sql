SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pPersonDoc#DeleteFormDoc]
	@PersonSID		 int							-- key of the app to approve
 ,@PersonDocGUID uniqueidentifier -- GUID of the document to check for deletion
as
/*********************************************************************************************************************************
Procedure : Registrant Audit - Delete Doc
Notice    : Copyright © 2012 Softworks Group Inc.
Summary   : Deletes the PersonDoc row for the GUID passed if the document is not referenced in dbo.RegistrantAuditResponse history
----------------------------------------------------------------------------------------------------------------------------------
History		: Author	  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Tim Edlund	| Jun 2017		|	Initial version
					: Kris Dawson | Jun 2017    | Added clause to restrict inner select to only urls with entity guid (prevents cast error)
					: Tim Edlund	| Jun 2018		| Changed FK reference in Registrant App from RegistrantSID to RegistrationSID 

Comments	
--------
This procedure is passed a document reference for deletion.  The procedure is called from the UI when a registrant or 
administrator has deleted a document from a form.  The document can only be deleted from the context and person-document tables
if it is not referenced in other contexts (other form types), and, the document is not referenced in the history of form
responses.

The procedure runs these checks starting with checking for existence of another context, and then proceeding through checking
each form response history table.  If no references are found, the deletion of the document context and the document itself
are carried out.

The procedure must check multiple form types because it is possible that an existing document in the Person-Doc library will
be referenced in more than one form type. 

Maintenance Note: A new form types that can accept documents are added to the application, this procedure must be updated
to check for document references within then. This procedure relies on the format of storing document references to be
the same in each form type.  

Example
-------

<TestHarness>
	<Test Name="Simple" IsDefault="true" Description="Check/delete a person document at random">
		<SQLScript>
			<![CDATA[
			
declare
		@personSID			int
	,	@personDocGUID	uniqueidentifier

select top 1
		@personSID			= pd.PersonSID
	,	@personDocGUID	= pdc.RowGUID
from
	dbo.PersonDocContext	pdc
join
	dbo.PersonDoc					pd	on pdc.PersonDocSID = pd.PersonDocSID
order by
	newid()

exec dbo.pPersonDoc#DeleteFormDoc
	 @PersonSID = @personSID
	,@PersonDocGUID = @personDocGUID

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="ExecutionTime" Value="3" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName			= 'dbo.pPersonDoc#DeleteFormDoc'
	,@DefaultTestOnly = 1
	
-------------------------------------------------------------------------------------------------------------------------------- */

set nocount on;

begin

	declare
		@errorNo						 int					 = 0							-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText					 nvarchar(4000)									-- message text (for business rule errors)
	 ,@blankParm					 varchar(50)										-- tracks if any required parameters are not provided
	 ,@ON									 bit					 = cast(1 as bit) -- constant for bit comparisons
	 ,@OFF								 bit					 = cast(0 as bit) -- constant for bit comparisons
	 ,@isDeleteAllowed		 bit					 = cast(1 as bit) -- tracks whether deletion is to be processed
	 ,@contextCount				 int														-- count of context records referencing the document
	 ,@personDocContextSID int														-- key of context record to delete (if allowed)no other references)
	 ,@personDocSID				 int;														-- key of document record to delete (if allowed)

	begin try

		-- check parameters

		if @PersonDocGUID is null
			set @blankParm = '@PersonDocGUID';
		if @PersonSID is null set @blankParm = '@PersonSID';

		if @blankParm is not null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = @blankParm;

			raiserror(@errorText, 18, 1);

		end;

		-- if the document is referenced in a second context
		-- it cannot be deleted (check first - fastest search)

		select
			@personDocContextSID = pdc.PersonDocContextSID
		 ,@personDocSID				 = pd.PersonDocSID
		from
			dbo.PersonDoc				 pd
		left outer join
			dbo.PersonDocContext pdc on pd.PersonDocSID = pdc.PersonDocSID
		where
			pd.RowGUID = @PersonDocGUID;

		set @contextCount = @@rowcount;

		if @contextCount > 1 -- if more than 1 context; deletion not allowed
		begin
			set @isDeleteAllowed = @OFF;
		end;

		-- if there is no context record nor document record, either the
		-- GUID is invalid or the form is out of sync with the DB but
		-- there is nothing to delete so stop searching (edge case)

		if @personDocContextSID is null and @personDocSID is null
			set @isDeleteAllowed = @OFF;

		if @isDeleteAllowed = @ON and @personDocSID is not null
		begin

			-- look for references to the document GUID in registrant app response history

			if exists
			(
				select
					1
				from
				(
					select
						cast(substring(dr.DocReference, charindex('EntityGuid,', dr.DocReference) + 11, 50) as uniqueidentifier) PersonDocGUID
					from
					(
						select
							docResponse.dr.value('@Value', 'nvarchar(1000)') DocReference
						from
							dbo.Registrant																 r
						join
							dbo.Registration															 reg on r.RegistrantSID = reg.RegistrantSID
						join
							dbo.RegistrantApp															 ra on reg.RegistrationSID = ra.RegistrationSID
						join
							dbo.RegistrantAppResponse											 rar on ra.RegistrantAppSID = rar.RegistrantAppSID
						cross apply rar.FormResponse.nodes('//Response') docResponse(dr)
						where
							r.PersonSID = @PersonSID and docResponse.dr.value('@Value', 'nvarchar(1000)') like 'data:%;EntityGuid,%'
					)																									dr
					join
					(select distinct ft .MimeType from sf.FileType ft) ft on dr.DocReference like 'data:' + ft.MimeType + '%'
				) x
				where
					x.PersonDocGUID = @PersonDocGUID
			)
				set @isDeleteAllowed = @OFF;

		end;

		if @isDeleteAllowed = @ON and @personDocSID is not null
		begin

			-- look for references to the document GUID in registrant app review response history

			if exists
			(
				select
					1
				from
				(
					select
						cast(substring(dr.DocReference, charindex('EntityGuid,', dr.DocReference) + 11, 50) as uniqueidentifier) PersonDocGUID
					from
					(
						select
							docResponse.dr.value('@Value', 'nvarchar(1000)') DocReference
						from
							dbo.Registrant																	r
						join
							dbo.Registration																reg on r.RegistrantSID = reg.RegistrantSID
						join
							dbo.RegistrantApp																ra on reg.RegistrationSID = ra.RegistrationSID
						join
							dbo.RegistrantAppReview													rar on ra.RegistrantAppSID = rar.RegistrantAppSID
						join
							dbo.RegistrantAppReviewResponse									rarr on rar.RegistrantAppReviewSID = rarr.RegistrantAppReviewSID
						cross apply rarr.FormResponse.nodes('//Response') docResponse(dr)
						where
							r.PersonSID = @PersonSID and docResponse.dr.value('@Value', 'nvarchar(1000)') like 'data:%;EntityGuid,%'
					)																									dr
					join
					(select distinct ft .MimeType from sf.FileType ft) ft on dr.DocReference like 'data:' + ft.MimeType + '%'
				) x
				where
					x.PersonDocGUID = @PersonDocGUID
			)
				set @isDeleteAllowed = @OFF;

		end;

		if @isDeleteAllowed = @ON and @personDocSID is not null
		begin

			-- look for references to the document GUID in registrant audit response history

			if exists
			(
				select
					1
				from
				(
					select
						cast(substring(dr.DocReference, charindex('EntityGuid,', dr.DocReference) + 11, 50) as uniqueidentifier) PersonDocGUID
					from
					(
						select
							docResponse.dr.value('@Value', 'nvarchar(1000)') DocReference
						from
							dbo.Registrant																 r
						join
							dbo.RegistrantAudit														 ra on r.RegistrantSID = ra.RegistrantSID
						join
							dbo.RegistrantAuditResponse										 rar on ra.RegistrantAuditSID = rar.RegistrantAuditSID
						cross apply rar.FormResponse.nodes('//Response') docResponse(dr)
						where
							r.PersonSID = @PersonSID and docResponse.dr.value('@Value', 'nvarchar(1000)') like 'data:%;EntityGuid,%'
					)																									dr
					join
					(select distinct ft .MimeType from sf.FileType ft) ft on dr.DocReference like 'data:' + ft.MimeType + '%'
				) x
				where
					x.PersonDocGUID = @PersonDocGUID
			)
				set @isDeleteAllowed = @OFF;

		end;

		if @isDeleteAllowed = @ON and @personDocSID is not null
		begin

			-- look for references to the document GUID in registrant audit review response history

			if exists
			(
				select
					1
				from
				(
					select
						cast(substring(dr.DocReference, charindex('EntityGuid,', dr.DocReference) + 11, 50) as uniqueidentifier) PersonDocGUID
					from
					(
						select
							docResponse.dr.value('@Value', 'nvarchar(1000)') DocReference
						from
							dbo.Registrant																	r
						join
							dbo.RegistrantAudit															ra on r.RegistrantSID = ra.RegistrantSID
						join
							dbo.RegistrantAuditReview												rar on ra.RegistrantAuditSID = rar.RegistrantAuditSID
						join
							dbo.RegistrantAuditReviewResponse								rarr on rar.RegistrantAuditReviewSID = rarr.RegistrantAuditReviewSID
						cross apply rarr.FormResponse.nodes('//Response') docResponse(dr)
						where
							r.PersonSID = @PersonSID and docResponse.dr.value('@Value', 'nvarchar(1000)') like 'data:%;EntityGuid,%'
					)																									dr
					join
					(select distinct ft .MimeType from sf.FileType ft) ft on dr.DocReference like 'data:' + ft.MimeType + '%'
				) x
				where
					x.PersonDocGUID = @PersonDocGUID
			)
				set @isDeleteAllowed = @OFF;

		end;

		-- when deletion is allowed, delete the context and
		-- document rows provided they exist in the table

		if @isDeleteAllowed = @ON
		begin

			begin transaction;

			if @personDocContextSID is not null -- missing rows are an edge case- form out of sync with db!
			begin

				exec dbo.pPersonDocContext#Delete
					@PersonDocContextSID = @personDocContextSID;

			end;

			if @personDocSID is not null
			begin

				exec dbo.pPersonDoc#Delete
					@PersonDocSID = @personDocSID;

			end;

			commit;

		end;

	end try
	begin catch

		if @@trancount > 0 rollback;
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw

	end catch;

	return (@errorNo);

end;
GO
