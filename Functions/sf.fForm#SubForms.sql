SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fForm#SubForms]
(
	@FormSID int -- key of the form to return sub forms for
)
returns table
/*********************************************************************************************************************************
Function: Form - SubForms
Notice  : Copyright © 2017 Softworks Group Inc.
Summary  : This procedure returns a data set of form keys and presentation sequence for the given parent form
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)				| Month Year | Change Summary
				 : ---------------- | -----------|----------------------------------------------------------------------------------------
				 : Tim Edlund				| Dec 2017 	 | Initial version
				 : Cory Ng					| Jan 2018	 | Updated to support alternate languages for labels and names 
----------------------------------------------------------------------------------------------------------------------------------
 
Comments
--------
Form records (sf.Form) in the application can be configured into sets presented in the UI as wizard-style dialogs. The parent 
form's key (@FormSID) is passed as a parameter.  For example, if the “Renewal” the form may include Learning Plan and Profile
Update sub-forms. 

Normally the main form appears as the LAST form in the series.  This is accomplished through ordering established in the Sub Form 
Sequence column of sf.FormSubForm.  This column is typically set to values like 1, 2, 3 or 5, 10, 15. This function always assigns 
the value 100 to the main form.  This will generally cause the main form to appear last in the sequence, however, if it should 
appear first or in the middle of the set the Sub Form Sequence values can be assigned 101, 102, 103 etc. to achieve the desired 
ordering. 

It is not necessary for all forms to have sub-forms defined for them.  If no sub-form exists the function will return a single 
row only.

Call Syntax
-----------

-- this example returns output for a set of forms
-- (assuming at least one form set is configured)

declare @formSID int;
select top (1) @formSID = fsf.FormSID from sf.FormSubForm fsf order by newid();
select * from sf.fForm#SubForms

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

select * from sf.fForm#SubForms
------------------------------------------------------------------------------------------------------------------------------- */
as
return select
					x.FormSID
				,sf.fAltLanguage#Field(f.RowGUID, 'FormLabel', f.FormLabel, null)	FormLabel
				,sf.fAltLanguage#Field(f.RowGUID, 'FormName', f.FormName, null)		FormName
				,f.LatestVersionFormVersionSID FormVersionSID
				,f.FormTypeSID
				,f.FormTypeSCD
				,f.FormTypeLabel
				,x.FormSequence
			 from
				(
					select
						f.FormSID
					 ,100 FormSequence
					from
						sf.Form f
					where
						f.FormSID = @FormSID -- this select validates key value passed in
					union
					select
						fsf.SubFormSID			FormSID
					 ,fsf.SubFormSequence FormSequence
					from
						sf.FormSubForm fsf
					where
						fsf.FormSID = @FormSID -- retrieve sub-forms for the parent key
				)					x
			 join
				 sf.vForm f on x.FormSID = f.FormSID; -- join to view to obtain calculated values
GO
