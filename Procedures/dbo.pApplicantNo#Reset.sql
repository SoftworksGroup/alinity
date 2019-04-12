SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pApplicantNo#Reset
	@DebugLevel int = 0 -- when 1 or higher debug output is written to console
as
/*********************************************************************************************************************************
Sproc    : Applicant No - Reset
Notice   : Copyright © 2019 Softworks Group Inc.
Summary  : This procedure resets the dbo.sApplicant sequence to the current max value + 1 of numbers matching the template format
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Mar 2019		|	Initial version

Comments	
--------
This is a utility procedure to reset the applicant number sequence to one value higher than the last applicant number used. 
Applicant numbers are stored in the dbo.Registrant.RegistrantNo column which also stores registrant numbers. In order to determine
the highest applicant number used, the system matches the format of applicant numbers using the applicant-number-template
stored in the configuration.

Known Limitations
-----------------
The applicant and registrant number templates must be different in order for the procedure to reset values correctly.

Example
-------
<TestHarness>
  <Test Name = "Simple" IsDefault ="true" Description="Executes the procedure to reset the sequence.">
    <SQLScript>
      <![CDATA[

exec dbo.pApplicantNo#Reset 
	 @DebugLevel = 1

		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:05:00"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pApplicantNo#Reset'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo						 int = 0	-- 0 no error, <50000 SQL error, else business rule
	 ,@applicantNoTemplate varchar(50)
	 ,@applicantNoMax			 varchar(50)
	 ,@applicantNoNext		 bigint
	 ,@applicantNoMinimum	 bigint
	 ,@alterSeq						 nvarchar(1000);

	begin try

		-- read configuration to get the format and minimum
		-- value for the applicant number

		set @applicantNoTemplate = cast(ltrim(rtrim(isnull(sf.fConfigParam#Value('ApplicantNoTemplate'), '[NONE]'))) as varchar(50));
		set @applicantNoMinimum = cast(ltrim(rtrim(isnull(sf.fConfigParam#Value('ApplicantNoMinimum'), '1001'))) as bigint);

		-- search for current maximum in the table matching 
		-- the pattern of the template

		set @applicantNoTemplate = replace(@applicantNoTemplate, '#', '[0-9]'); -- replace with regex symbols for digits

		select
			@applicantNoMax = max(r.RegistrantNo)
		from
			dbo.Registrant r
		where
			r.RegistrantNo like @applicantNoTemplate;

		set @applicantNoNext = cast(sf.fFormatString#StripNonNumerics(@applicantNoMax) as int) + 1; -- add one for new "next" value

		if @applicantNoNext < @applicantNoMinimum or @applicantNoMax is null -- if minimum is > than next value calculated, update it
		begin
			set @applicantNoNext = @applicantNoMinimum;
		end;

		-- format and execute statement to modify the sequence

		set @alterSeq =
			N'alter sequence dbo.sApplicant' + N' restart with ' + ltrim(@applicantNoNext) + N'	increment by 1' + N' minvalue ' + ltrim(@applicantNoNext)
			+ N' maxvalue 9999999' + N'	no cache';

		if @DebugLevel > 0
		begin

			select
				@applicantNoTemplate ApplicantNoTemplate
			 ,@applicantNoMax			 ApplicantNoMax
			 ,@applicantNoNext		 ApplicantNoNext
			 ,@applicantNoMinimum	 ApplicantNoMinimum
			 ,@alterSeq						 AlterSeq;

		end;

		exec sp_executesql @stmt = @alterSeq;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
