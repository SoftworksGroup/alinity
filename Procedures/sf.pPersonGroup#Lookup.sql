SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sf.pPersonGroup#Lookup
	@PersonGroupIdentifier nvarchar(65) = null	-- identifier to lookup (see comments below)
 ,@PersonGroupSID				 int output						-- key of the sf.PersonGroup record found
as
/*********************************************************************************************************************************
Procedure	: Lookup PersonGroup
Notice		: Copyright © 2019 Softworks Group Inc. 
Summary		: Subroutine to lookup a(n) PersonGroupSID based on an identifier passed in 
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Mar 2019		|	Initial version

Comments
--------
This procedure is used when processing staged data. It attempts to find a primary key value for the sf.PersonGroup table based
on an identifier passed in.  The identifier must be passed in the @PersonGroupIdentifier parameter.  If the identifier is not
found, an error is NOT raised.  The calling program must check the output value and determine if an error condition has occurred.

The following columns in the target table are searched for the value passed:

	PersonGroup Label
	PersonGroup Name
	Legacy Key

If this procedure is called with a blank search parameter, an error is returned. While a default Person Group may be defined in the 
table, it is not returned by this procedure and must be selected specifically by the caller. 

SID: Override
-------------
In some scenarios where staging tables are filled through conversion programming, the key value of the Person Group record 
may already have been looked up but it cannot be stored in the staging table because key columns are not included in the
structure for all possible records in repeating elements.  This table structure limitation exists, for example, in 
stg.RegistrantProfile where multiple Person Group records can be specified per row. In this case the key value can be 
passed in the @PersonGroupIdentifier parameter prefixed by "SID:".  The value will be verified through a lookup and,
if valid, returned through the output variable.

Add-on-the-fly NOT supported
----------------------------
If the value provided is not found, no adding-on-the-fly of that value to the master table is supported.  Person Group records
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
	@personGroupSID				 int
 ,@personGroupIdentifier nvarchar(65);

select top (1)
	@personGroupIdentifier = x.PersonGroupLabel
from
	sf.PersonGroup x
order by
	newid();

if @@rowcount = 0 or @personGroupIdentifier is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	exec sf.pPersonGroup#Lookup
		@PersonGroupIdentifier = @personGroupIdentifier
	 ,@PersonGroupSID = @personGroupSID output;

	select
		@personGroupIdentifier [@PersonGroupIdentifier]
	 ,@personGroupSID				 [@PersonGroupSID]
	 ,x.PersonGroupLabel
	 ,x.LegacyKey
	from
		sf.PersonGroup x
	where
		x.PersonGroupSID = @personGroupSID;

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
	 @ObjectName = 'sf.pPersonGroup#Lookup'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo	 int = 0				-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText nvarchar(4000) -- message text (for business rule errors)    
	 ,@recordSID int;						-- buffer for "SID:" override lookup

	set @PersonGroupSID = null; -- initialize output values

	begin try

		-- check parameters

		if @PersonGroupIdentifier is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = '@PersonGroupIdentifier';

			raiserror(@errorText, 18, 1);
		end;

		-- lookup the identifier

		if @PersonGroupIdentifier like 'SID:%'
		begin

			set @recordSID = cast(replace(@PersonGroupIdentifier, 'SID:', '') as int);

			select
				@PersonGroupSID = x.PersonGroupSID
			from
				sf.PersonGroup x
			where
				x.PersonGroupSID = @recordSID;

		end;
		else
		begin

			select
				@PersonGroupSID = min(x.PersonGroupSID)
			from
				sf.PersonGroup x
			where
				x.PersonGroupLabel = @PersonGroupIdentifier or x.PersonGroupName = @PersonGroupIdentifier or isnull(x.LegacyKey, N'!@#~') = @PersonGroupIdentifier;

		end;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);

end;
GO
