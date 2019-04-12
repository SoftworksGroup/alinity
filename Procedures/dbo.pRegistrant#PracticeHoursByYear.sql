SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pRegistrant#PracticeHoursByYear
	@RegistrantSID					int = null														-- system ID for the member
 ,@PersonSID							int = null														-- alternate ID used to look up the member
 ,@RegistrationYearEnding smallint = null												-- the ending registration year (defaults to current year)
as
/*********************************************************************************************************************************
Sproc			: Registrant - Practice hours by year
Notice		: Copyright © 2019 Softworks Group Inc.
Summary		: Returns the practice hours per year for the member based on the practice hour requirement interval
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + -----------------------------------------------------------------------------------
 				: Cory Ng		          | Feb 2019		|	Initial version
				: Cory Ng							| Mar 2019		| Updated to return other jurisdiction hours as well

Comments	
--------
This procedure is a wrapper for the table function of the same name.  It returns practice hour information based on the practice
hour requirement interval.  See table function documentation for details.

Example
-------
<TestHarness>
  <Test Name = "AllForYear" IsDefault ="true" Description="Executes the function to return reason data for a year selected at random.">
    <SQLScript>
      <![CDATA[

		declare
			 @registrantSID int

		select top 1
			 @registrantSID = re.RegistrantSID
		from
			dbo.RegistrantEmployment re
		order by
			newid()

	exec dbo.pRegistrant#PracticeHoursByYear
		 @RegistrantSID = @registrantSID

		]]>
    </SQLScript>
    <Assertions>
			<Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
      <Assertion Type="ExecutionTime" Value="00:00:05"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.pRegistrant#PracticeHoursByYear'
 ,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare @errorNo int = 0; -- 0 no error, <50000 SQL error, else business rule

	begin try

		select
			--!<ColumnList DataSource="dbo.fRegistrant#PracticeHoursByYear" Alias="rph">
			 rph.RegistrationYear
			,rph.RegistrationYearLabel
			,rph.TotalHours
			,rph.OtherJurisdictionHours
		--!</ColumnList>
		from
			dbo.fRegistrant#PracticeHoursByYear(@RegistrantSID, @PersonSID, @RegistrationYearEnding) rph
		order by
			rph.RegistrationYear;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
