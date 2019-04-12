SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pRegistrantNo#Reset
	@DebugLevel int = 0 -- when 1 or higher debug output is written to console
as
/*********************************************************************************************************************************
Sproc    : Applicant No - Reset
Notice   : Copyright © 2019 Softworks Group Inc.
Summary  : This procedure resets the dbo.sRegistrant sequence to the current max value + 1 of numbers matching the template format
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

exec dbo.pRegistrantNo#Reset 
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
	 @ObjectName = 'dbo.pRegistrantNo#Reset'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo							int = 0 -- 0 no error, <50000 SQL error, else business rule
	 ,@registrantNoTemplate varchar(50)
	 ,@registrantNoMax			varchar(50)
	 ,@registrantNoNext			bigint
	 ,@registrantNoMinimum	bigint
	 ,@alterSeq							nvarchar(1000);

	begin try

		-- read configuration to get the format and minimum
		-- value for the applicant number

		set @registrantNoTemplate = cast(ltrim(rtrim(isnull(sf.fConfigParam#Value('RegistrantNoTemplate'), '[NONE]'))) as varchar(50));
		set @registrantNoMinimum = cast(ltrim(rtrim(isnull(sf.fConfigParam#Value('RegistrantNoMinimum'), '1001'))) as bigint);

		-- search for current maximum in the table matching 
		-- the pattern of the template

		set @registrantNoTemplate = replace(@registrantNoTemplate, '#', '[0-9]'); -- replace with regex symbols for digits

		select
			@registrantNoMax = max(r.RegistrantNo)
		from
			dbo.Registrant r
		where
			r.RegistrantNo like @registrantNoTemplate;

		set @registrantNoNext = cast(sf.fFormatString#StripNonNumerics(@registrantNoMax) as int) + 1; -- add one for new "next" value

		if @registrantNoNext < @registrantNoMinimum or @registrantNoMax is null -- if minimum is > than next value calculated, update it
		begin
			set @registrantNoNext = @registrantNoMinimum;
		end;

		-- format and execute statement to modify the sequence

		set @alterSeq =
			N'alter sequence dbo.sRegistrant' + N' restart with ' + ltrim(@registrantNoNext) + N'	increment by 1' + N' minvalue ' + ltrim(@registrantNoNext)
			+ N' maxvalue 9999999' + N'	no cache' ;

		if @DebugLevel > 0
		begin

			select
				@registrantNoTemplate RegistrantNoTemplate
			 ,@registrantNoMax			RegistrantNoMax
			 ,@registrantNoNext			RegistrantNoNext
			 ,@registrantNoMinimum	RegistrantNoMinimum
			 ,@alterSeq							AlterSeq;

		end;

		exec sp_executesql @stmt = @alterSeq;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
