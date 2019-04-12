SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pProfileUpdate#ReviewReasons
	@ProfileUpdateSID int				-- key of record to return review reasons for or -1 for all
 ,@RegistrationYear smallint	-- year of form records to return, or -1 for all or when first param is provided
as
/*********************************************************************************************************************************
Sproc    : Registrant Profile Update - Review Reasons
Notice		: Copyright © 2018 Softworks Group Inc.
Summary		: Returns the set of administrative Review Reasons (if any) associated with profile update forms
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + -----------------------------------------------------------------------------------
 				: Tim Edlund          | Oct 2018		|	Initial version

Comments	
--------
This procedure is a wrapper for the table function of the same name.  It returns reason information for each key stored
within the "ReviewReasonList" XML column for the table.  See table function documentation for details.

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
	dbo.ProfileUpdate frm
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

	exec dbo.pProfileUpdate#ReviewReasons
		 @ProfileUpdateSID = -1
		,@RegistrationYear = @registrationYear

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
	@ObjectName = 'dbo.pProfileUpdate#ReviewReasons'
 ,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare @errorNo int = 0; -- 0 no error, <50000 SQL error, else business rule

	begin try

		select
			--!<ColumnList DataSource="dbo.fProfileUpdate#ReviewReasons" Alias="rsn">
			 rsn.ProfileUpdateSID
			,rsn.ReasonSID
			,rsn.ReasonGroupSID
			,rsn.ReasonName
			,rsn.ReasonCode
			,rsn.ReasonSequence
			,rsn.ToolTip
		--!</ColumnList>
		from
			dbo.fProfileUpdate#ReviewReasons(@ProfileUpdateSID, @RegistrationYear) rsn;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
