SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pForm#GetSubForms]
	@FormSID int -- key of the form to return sub forms for
as
/*********************************************************************************************************************************
Sproc    : Form - Get Sub-Forms
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : This procedure returns a data set of form keys and presentation sequence for the given parent form
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)				| Month Year | Change Summary
				 : ---------------- | -----------|----------------------------------------------------------------------------------------
				 : Tim Edlund				| Dec 2017 	 | Initial version.
----------------------------------------------------------------------------------------------------------------------------------
 
Comments
--------
Form records (sf.Form) in the application can be configured into sets presented in the UI as wizard-style dialogs. The parent 
form's key (@FormSID) is passed as a parameter.  This form defines the name of the form-set AND defines the status of the form-set.  
For example, if the main form is “Renewal” the form set is referred to by that name and the status of the overall process is set 
by the status of the Renewal form.  Normally the main form appears as the LAST form in the series.  This is accomplished through 
ordering established in the Sub Form Sequence column of sf.FormSubForm.  This column is typically set to values like 1, 2, 3 or 
5, 10, 15. 

This procedure always assigns the value 100 to the main form.  This will generally cause the main form to appear last in the 
sequence, however, if it should appear first or in the middle of the set the Sub Form Sequence values can be assigned 101, 102, 
103 etc. to achieve the desired ordering. It is not necessary for all forms to have sub-forms defined for them.  If no sub-form 
exists the procedure will return a single row only.

Call Syntax
-----------

-- this example returns output for a set of forms
-- (assuming at least one form set is configured)

declare @formSID int;
select top (1) @formSID = fsf.FormSID from sf.FormSubForm fsf order by newid();
exec sf.pForm#GetSubForms @FormSID = @formSID;

-- this example finds a form that has no sub-forms
-- to ensure a single record is returned

declare @formSID int;

select top (1)
	@formSID = f.FormSID
from
	sf.Form				 f
left outer join
	sf.FormSubForm fsf on f.FormSID = fsf.FormSID
where
	fsf.FormSID is null
order by
	newid();

exec sf.pForm#GetSubForms @FormSID = @formSID;
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo	 int = 0				-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText nvarchar(4000) -- message text for business rule errors
	 ,@blankParm varchar(50);		-- tracks name of any required parameter not passed

	begin try

		-- check parameters
		if @FormSID is null set @blankParm = '@FormSID';

		if @blankParm is not null
		begin
			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = @blankParm;

			raiserror(@errorText, 18, 1);
		end;

		-- return the forms and sequences for the parent form provided

		select
			fsf.FormSID
		 ,fsf.FormLabel
		 ,fsf.FormName
		 ,fsf.FormVersionSID
		 ,fsf.FormTypeSID
		 ,fsf.FormTypeSCD
		 ,fsf.FormTypeLabel
		 ,fsf.FormSequence
		from
			sf.fForm#SubForms(@FormSID) fsf
		order by
			fsf.FormSequence;

		if @@rowcount = 0
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'sf.Form'
			 ,@Arg2 = @FormSID;

			raiserror(@errorText, 18, 1);
		end;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
