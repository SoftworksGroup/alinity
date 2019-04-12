SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE function dbo.fRegistrantRenewal#ReviewReasonsHTML
(
	@RegistrantRenewalSID int				-- key of record to return review reason for information for or -1 for all
 ,@RegistrationYear smallint	-- year of form records to return, or -1 for all or when first param is provided
)
returns nvarchar(max)
/*********************************************************************************************************************************
Function	: RegistrantRenewal - Review Reasons HTML
Notice		: Copyright © 2018 Softworks Group Inc.
Summary		: Returns the set of administrative Review Reasons in the form of an HTML unordered list
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Cory Ng             | Oct 2018		|	Initial version

Comments	
--------
This function formats the review reasons on the renewal and returns is as an HTML unordered list. The reasons are stored in an XML 
column on the profile update and the parsing for the the HTML is done in the function dbo.fRegistrantRenewal#ReviewReasons. This 
function is designed to be called through the forms for display the block reasons in the form.

Example
-------
<TestHarness>
  <Test Name = "AllForYear" IsDefault ="true" Description="Executes the function to return reason data for a year selected at random.">
    <SQLScript>
      <![CDATA[

declare @registrationYear smallint;

select top (1)
	@registrationYear = frm.RegistrationYear
from
	dbo.RegistrantRenewal frm
where
	frm.ReviewReasonList is not null
order by
	newid();

if @@rowcount = 0 or @registrationYear is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	print @registrationYear;

	select
		dbo.fRegistrantRenewal#ReviewReasonsHTML(-1, @registrationYear)

end;

		]]>
    </SQLScript>
    <Assertions>
			<Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
      <Assertion Type="ExecutionTime" Value="00:00:05"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.fRegistrantRenewal#ReviewReasonsHTML'
 ,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */
as
begin

	declare @reasonsHtml nvarchar(max);

	select
		@reasonsHtml = N'<ul>' + stuff((
																		 select
																				'<li title="' + isnull(r.ToolTip, '') + '">' + r.ReasonName + '</li>'
																		 from
																				dbo.fRegistrantRenewal#ReviewReasons(@RegistrantRenewalSID, @RegistrationYear) r
																		 for xml path(''), type
																	 ).value('(./text())[1]', 'varchar(max)')
																	 ,1
																	 ,0
																	 ,''
																	) + N'</ul>';

	return @reasonsHtml;
end;
GO
