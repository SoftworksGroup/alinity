SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fProfileUpdate#StatusSummary
(
	@RegistrationYear smallint	-- the registration year to include in the analysis
)
returns table
/*********************************************************************************************************************************
Function: Profile Update - Status Summary
Notice  : Copyright © 2018 Softworks Group Inc.
Summary	: Returns reporting/statistical data on Profile Updates (excluding WITHDRAWN)
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Oct 2018		|	Initial version

Comments	
--------
This function supports reporting on the status of Profile Updates in a given registration year. @RegistrationYear is a 
required parameter and cannot be replaced with -1 to return results for all years in the same query. The function returns one row 
for each status along with the count of forms in that status.  The content returned also includes the form owner. This makes it 
possible to produce reports that first group by the "next to act" party and then the statuses within those sections. For 
Profile Updates 3 next-to-act parties  are possible:  Member, Administrator and None (form is closed status).

Note that any Profile Updates in the "WITHDRAWN" status are explicitly excluded from the statistics returned.

Maintenance Notes
----------------- 
The data set returned by this function is identical to the data sets returned by other functions following the same naming 
convention and which support reporting on other form types.  Do not modify this function in such as way that the resulting data 
set will be unique.  If changes to the data set are required, apply them consistently through all functions of this type.

Example
-------
<TestHarness>
  <Test Name = "RandomYear" IsDefault ="true" Description="Returns status records for a year selected at random.">
    <SQLScript>
      <![CDATA[
declare @registrationYear smallint;

select top (1)
	@registrationYear = frm.RegistrationYear
from
	dbo.ProfileUpdate																												 frm
cross apply dbo.fProfileUpdate#CurrentStatus(frm.ProfileUpdateSID, -1) cs
where
	cs.FormStatusSCD <> 'WITHDRAWN'
order by
	newid();

if @@rowcount = 0 or @registrationYear is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	print @registrationYear

	select
		x.FormStatusSID
	 ,x.FormStatusSCD
	 ,x.FormStatusLabel
	 ,x.FormCount
	 ,x.FormOwnerSCD
	 ,x.FormOwnerLabel
	 ,x.NextToActGroup
	 ,x.FormStatusSequence
	from
		dbo.fProfileUpdate#StatusSummary(@registrationYear) x
	order by
		 x.NextToActGroup
		,x.FormStatusSequence;

end;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:10"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.fProfileUpdate#StatusSummary'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */
as
return
(
	select
		fs.FormStatusSID
	 ,x.FormStatusSCD
	 ,x.FormStatusLabel
	 ,fo.FormOwnerSID
	 ,x.FormOwnerSCD
	 ,x.FormOwnerLabel
	 ,x.FormCount
	 ,(case x.FormOwnerSCD when 'NONE' then x.FormOwnerLabel when 'ADMIN' then fo.FormOwnerLabel else 'Member' end) NextToActGroup
	 ,fs.FormStatusSequence
	from
	(
		select
			cs.FormStatusSCD
		 ,cs.FormStatusLabel
		 ,cs.FormOwnerSCD
		 ,cs.FormOwnerLabel
		 ,count(1) FormCount
		from
			dbo.fProfileUpdate#CurrentStatus(-1, @RegistrationYear) cs
		where
			cs.FormStatusSCD <> 'WITHDRAWN'
		group by
			cs.FormStatusSCD
		 ,cs.FormStatusLabel
		 ,cs.FormOwnerSCD
		 ,cs.FormOwnerLabel
	)								x
	join
		sf.FormStatus fs on x.FormStatusSCD = fs.FormStatusSCD
	left outer join
		sf.FormOwner	fo on x.FormOwnerSCD	= fo.FormOwnerSCD
);
GO
