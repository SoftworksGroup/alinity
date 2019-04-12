SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fRegistrantEmployment#Rank (@RegistrantEmploymentSID int)
returns int
as
/*********************************************************************************************************************************
ScalarFcn	: Employment Rank
Notice		: Copyright © 2018 Softworks Group Inc.
Summary		: Returns the rank of the employment record within the registration year based on highest practice hours 
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-------------------------------------------------------------------------------------------
					: Tim Edlund  | Aug 2017		|	Initial version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------

This function supports a the EmploymentRank calculated column on the dbo.RegistrantEmployment table.  It calculates the rank
of each employment record for the registrant from highest practice hours to lowest practice hours within a registration year.
The rank of employment is used for ordering records and for reporting to external parties including CIHI and Provincial Provider
Registries.  Indexing the column along with RegistrationYear and RegistrantSID can greatly improve performance of exports.

Note that in order to persist the calculated column supported by this function, the row_number() and ranking commands in 
SQL Server cannot be used since they are not deterministic.  The algorithm increments the rank until the selected 
record key is hit at which point the @stop variable is set on.  That variable is then read to stop incrementing after
the selected row is hit.  Processing through remaining rows after @stop is set is avoided through use of the variable
in the WHERE clause.

Example
-------

<TestHarness>
	<Test Name = "Random10" Description="Returns ranking for 10 employment records selected at random.">
	<SQLScript>
	<![CDATA[
select
	re.RegistrantEmploymentSID
 ,re.RegistrantSID
 ,re.RegistrationYear
 ,re.PracticeHours
 ,dbo.fRegistrantEmployment#Rank(re.RegistrantEmploymentSID) EmploymentRank
from
(
	select top (10)
		re.RegistrantEmploymentSID
	from
		dbo.RegistrantEmployment re
	order by
		newid()
)													 x
join
	dbo.RegistrantEmployment re on x.RegistrantEmploymentSID = re.RegistrantEmploymentSID;
	]]>
	</SQLScript>
	<Assertions>
		<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
		<Assertion Type="ExecutionTime" Value="00:00:01" />
	</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.fRegistrantEmployment#Rank'
	,@DefaultTestOnly = 1	
------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		@employmentRank int = 1
	 ,@stop						bit = cast(0 as bit)
	 ,@ON							bit = cast(1 as bit)	-- constant for bit comparisons = 1
	 ,@OFF						bit = cast(0 as bit)	-- constant for bit comparison = 0

	select
		@stop						= (case when @stop = @OFF and re.RegistrantEmploymentSID = @RegistrantEmploymentSID then @ON else @stop end)
	 ,@employmentRank = (case when @stop = @OFF then @employmentRank + 1 else @employmentRank end)
	from
	(
		select
			re.RegistrantSID
		 ,re.RegistrationYear
		from
			dbo.RegistrantEmployment re
		where
			re.RegistrantEmploymentSID = @RegistrantEmploymentSID
	)													 x
	join
		dbo.RegistrantEmployment re on x.RegistrantSID = re.RegistrantSID and x.RegistrationYear = re.RegistrationYear
	where	
		@stop = @OFF
	order by
		re.PracticeHours desc
	 ,re.CreateTime desc;

	return (@employmentRank);

end;
GO
