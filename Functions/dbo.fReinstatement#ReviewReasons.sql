SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fReinstatement#ReviewReasons
(
	@ReinstatementSID int				-- key of record to return review reasons for or -1 for all
 ,@RegistrationYear smallint	-- year of form records to return, or -1 for all or when first param is provided
)
returns table
/*********************************************************************************************************************************
Function	: Reinstatement - Review Reasons
Notice		: Copyright © 2018 Softworks Group Inc.
Summary		: Returns the set of administrative Review Reasons (if any) associated with reinstatement forms
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Oct 2018		|	Initial version

Comments	
--------
This table function parses the "ReasonList" column on the reinstatement record and returns the reason information for each key stored 
within the XML column.  If the ReasonList is null then NO RECORDs are returned. The function returns as many records as there
are ReasonSID values stored in the XML assuming those key values are found in the dbo.Reason master table.

The function is a data source for queries and is also called to support display of review reasons on the user interface.  The 
function requires either a Reinstatement year (typically current year) and/or a specific form record to return review reasons 
for.  If only 1 parameter is provided, then the other parameter must be passed as -1.  DO NOT PASS AS NULL.

Normalization 
-------------
This table function will return from 0 to many records.  If a reinstatement record has no review reasons then no record is returned.
For that reason be sure to OUTER APPLY to this function if the reinstatement record is required in the final data set whether or not
review reasons are associated.  The function may also include 1 or more than 1 record where multiple review reason keys have
been stored in the XML.

Limitations
-----------
A form may be finalized (APPROVED or REJECTED) with the ReasonList column still containing content.  This table function will
return the associated reason records even for finalized forms.  This may not be desired by the caller and if so, call the
#CurrentStatus function to either select where "IsReviewRequired = 1" or where the form owner is "Admin".  The #CurrentStatus
function avoids returning those values where the form has already been finalized.

Referential integrity is not enforced between the ReasonSID values stored in the XML and the current state of the dbo.Reason
table. If a key is stored in the XML column for a reason that is deleted from the table afterward, a record for that row
will not be returned.

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
	dbo.Reinstatement frm
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
		x.*
	from
		dbo.fReinstatement#ReviewReasons(-1, @registrationYear) x
	order by
		x.ReinstatementSID
	 ,x.ReasonSequence;

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
	@ObjectName = 'dbo.fReinstatement#ReviewReasons'
 ,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */
as
return
(
	select
		x.ReinstatementSID
	 ,x.ReasonSID
	 ,rsn.ReasonGroupSID
	 ,rsn.ReasonName
	 ,rsn.ReasonCode
	 ,rsn.ReasonSequence
	 ,rsn.ToolTip
	from
	(
		select
			frm.ReinstatementSID
		 ,reason.node.value('@SID', 'int') ReasonSID
		from
		(
			select
				frm.ReinstatementSID
			from
				dbo.Reinstatement frm
			where
				(@ReinstatementSID = -1 or frm.ReinstatementSID = @ReinstatementSID) and (@RegistrationYear = -1 or frm.RegistrationYear = @RegistrationYear)
		)																												 f
		join
			dbo.Reinstatement																			 frm on f.ReinstatementSID = frm.ReinstatementSID
		outer apply frm.ReviewReasonList.nodes('Reasons/Reason') as reason(node)
	)						 x
	join
		dbo.Reason rsn on x.ReasonSID = rsn.ReasonSID
);
GO
