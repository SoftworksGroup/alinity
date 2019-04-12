SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrationYear#GetCurrent]
as
/*********************************************************************************************************************************
Sproc    : Registration Year - Get Current
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : Returns a single record and column containing the current Registration Year for the configuration
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)				| Month Year    | Change Summary
				 : ---------------- | ------------- |-------------------------------------------------------------------------------------
				 : Tim Edlund				| Sep 2017			| Initial version.
----------------------------------------------------------------------------------------------------------------------------------
 
Comments
--------
This procedure looks up the registration year for the configuration based on the current time in the client timezone.  The lookup
is accomplished using the fRegistrationYear() function.  See the function for details.

Example:
--------
 
<TestHarness>
	<Test Name = "Default" IsDefault ="true" Description="Tests basic operation of procedure.">
		<SQLScript>
			<![CDATA[

exec dbo.pRegistrationYear#GetCurrent

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="ExecutionTime" Value="00:00:01"/>
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName			= 'dbo.pRegistrationYear#GetCurrent'
	,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */
set nocount on;

begin
	declare
		@errorNo	 int = 0					-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText nvarchar(4000);	-- message text (for business rule errors)

	begin try

		select
			dbo.fRegistrationYear(sf.fNow()) RegistrationYear;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
