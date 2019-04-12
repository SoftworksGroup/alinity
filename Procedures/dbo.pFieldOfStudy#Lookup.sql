SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pFieldOfStudy#Lookup
	@FieldOfStudyIdentifier nvarchar(35) = null -- identifier to lookup (see comments below)
 ,@FieldOfStudySID				int output					-- key of the dbo.FieldOfStudy record found
as
/*********************************************************************************************************************************
Procedure	: Lookup FieldOfStudy
Notice		: Copyright © 2019 Softworks Group Inc. 
Summary		: Subroutine to lookup a FieldOfStudySID based on an identifier passed in 
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Mar 2019		|	Initial version

Comments
--------
This procedure is used when processing staged data. It attempts to find a primary key value for the dbo.FieldOfStudy table based
on an identifier passed in.  The identifier must be passed in the @FieldOfStudyIdentifier parameter.  If the identifier is not
found, an error is NOT raised. The calling program must check the output value and determine if an error condition has occurred.

The following columns in the target table are searched for the value passed:

	FieldOfStudy name
	FieldOfStudy code
	Legacy Key

If this procedure is called with a blank search parameter, an error is returned. While a default FieldOfStudy may be defined in the 
table, it is not returned by this procedure and must be selected specifically by the caller. 

SID: Override
-------------
In some scenarios where staging tables are filled through conversion programming, the key value of the FieldOfStudy record 
may already have been looked up but it cannot be stored in the staging table because key columns are not included in the
structure for all possible records in repeating elements.  This table structure limitation exists, for example, in 
stg.RegistrantProfile where multiple FieldOfStudy records can be specified per row. In this case the key value can be 
passed in the @FieldOfStudyIdentifier parameter prefixed by "SID:".  The value will be verified through a lookup and,
if valid, returned through the output variable.

Add-on-the-fly NOT supported
----------------------------
If the value provided is not found, no adding-on-the-fly of that value to the master table is supported.  FieldOfStudy records
must be established through separate imports or user entry before staging records are processed to avoid generation of 
poor quality data.

Example:
--------
Note that all #Lookup procedures share very similar logic. While a single "sunny day" test scenario is provided below,
a detailed test harness examining results for all expected scenarios can be found in sf.pGender#Lookup.

<TestHarness>
	<Test Name="OneValidInput" IsDefault="true" Description="Calls lookup procedure with a valid input that will be found.">
		<SQLScript>
			<![CDATA[
declare
	@fieldOfStudySID				int
 ,@fieldOfStudyIdentifier nvarchar(50);

select top (1)
	@fieldOfStudyIdentifier = x.FieldOfStudyName
from
	dbo.FieldOfStudy x
order by
	newid();

if @@rowcount = 0 or @fieldOfStudyIdentifier is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	exec dbo.pFieldOfStudy#Lookup
		@FieldOfStudyIdentifier = @fieldOfStudyIdentifier
	 ,@FieldOfStudySID = @fieldOfStudySID output;

	select
		@fieldOfStudyIdentifier [@FieldOfStudyIdentifier]
	 ,@fieldOfStudySID				[@FieldOfStudySID]
	 ,x.FieldOfStudyName
	 ,x.LegacyKey
	from
		dbo.FieldOfStudy x
	where
		x.FieldOfStudySID = @fieldOfStudySID;

end
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:01" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pFieldOfStudy#Lookup'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo	 int = 0				-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText nvarchar(4000) -- message text (for business rule errors)    
	 ,@recordSID int;						-- buffer for "SID:" override lookup

	set @FieldOfStudySID = null; -- initialize output values

	begin try

		-- check parameters

		if @FieldOfStudyIdentifier is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = '@FieldOfStudyIdentifier';

			raiserror(@errorText, 18, 1);
		end;

		-- lookup the identifier

		if @FieldOfStudyIdentifier like 'SID:%'
		begin

			set @recordSID = cast(replace(@FieldOfStudyIdentifier, 'SID:', '') as int);

			select
				@FieldOfStudySID = x.FieldOfStudySID
			from
				dbo.FieldOfStudy x
			where
				x.FieldOfStudySID = @recordSID;

		end;
		else
		begin

			select
				@FieldOfStudySID = min(x.FieldOfStudySID)
			from
				dbo.FieldOfStudy x
			where
				x.FieldOfStudyName = @FieldOfStudyIdentifier or x.FieldOfStudyCode = @FieldOfStudyIdentifier or isnull(x.LegacyKey, N'!@#~') = @FieldOfStudyIdentifier;

		end;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);

end;
GO
