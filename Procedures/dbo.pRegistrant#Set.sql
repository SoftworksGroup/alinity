SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pRegistrant#Set
	@UpdateRule											varchar(10) = 'NEWONLY'		-- setting of update rule - see comments below
 ,@PersonSID											int												-- key of person record to insert/update registration for (required!)
 ,@RegistrantNo										varchar(50)								-- mandatory: pass as '+' to add Registrant if none exists (otherwise error)
 ,@PracticeRegisterSectionSID			int = null								-- key of section to automatically assign registrant to an initial section
 ,@ArchivedTime										datetimeoffset(7) = null	-- see dbo.Registrant for column descriptions:
 ,@IsOnPublicRegistry							bit = null
 ,@DirectedAuditYearCompetence		smallint = null
 ,@DirectedAuditYearPracticeHours smallint = null
 ,@UpdateTime											datetimeoffset(7) = null	-- required if profile-update-rule is "LATEST"
 ,@LegacyKey											nvarchar(50) = null				-- key of registrant record in source/converted system 
 ,@RegistrantSID									int = null output					-- key of address record inserted or updated
as
/*********************************************************************************************************************************
Procedure : Registrant - Set
Notice    : Copyright © 2017 Softworks Group Inc.
Summary   : Applies registrant information from user-entered forms or staging records into main (DBO) tables
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Apr 2017		|	Initial version
				: Tim Edlund					| Mar 2019		| Modified logic to RAISE errors and added support for non-default applicant section

Comments
--------
This procedure supports adding or updating a registrant record (dbo.Registrant) from source data provided from forms or from the 
staging area "stg.RegistrantProfile" table.  The source data is passed into the procedure and the registrant record is updated or
created. 

The procedure requires a PersonSID to associate the Registrant with. All other parameters are optional and/or can be defaulted.
Because all values - except PersonSID - in dbo.Registrant are nullable or can be defaulted, the @RegistrantNo is treated as
a required parameter to confirm that an insert should occur.  The column should be set to "+" to force adding of a record if
an existing Registrant row for the PersonSID is not found.

Updating existing registrant is carried out where an existing record is found (lookup by PersonSID, RegistrantSID or 
RegistrantNo). The update will only occur, however if the setting of the @UpdateRule allows it (see below).

Update Rule
-----------
The content passed in will create new records if none are found but if an existing record is found, it will only be updated
based on the setting of the @UpdateRule - which if not passed is set to NEWONLY. The following settings are supported:

NEWONLY			-- existing records are never updated, but new records are added
LATEST			-- existing record overwritten if the @UpdateTime passed in is later than the existing record, new records are added
ALWAYS			-- existing record is always overwritten with information passed in, new records are added

The default setting is "NEWONLY", since the products are normally considered to be the repository of the most up-to-date
information. Note that the LATEST rule depends on the @UpdateTime parameter being passed in.  If the value is not provided an 
error is returned.

Errors Must Be Raised to the Caller
-----------------------------------
This procedure is often called in batch processing scenarios for sets of records stored in staging where an error on any 
individual record should not stop processing of remaining records. For that reason, errors raised by the procedure must be caught 
by the top-level calling procedure and handled.  The call to this procedure must be wrapped in a try-catch block. Failing to 
raise an error in this subroutine will generate a mismatch in the transaction count and the message: "Transaction count after 
EXECUTE indicates a mismatching number of BEGIN and COMMIT statements. Previous count = 1, current count = 0." The caller must 
determine whether errors should be raised to the application, or logged when executed in batch processes.

Example
-------
<TestHarness>
	<Test Name="Random" IsDefault="true" Description="Calls procedure to update legacy key to Test (change is rolled back).">
		<SQLScript>
			<![CDATA[

declare
	@personSID		int
 ,@registrantNo varchar(50);

select top (1)
	@personSID		= r.PersonSID
 ,@registrantNo = r.RegistrantNo
from
	dbo.Registrant r
order by
	newid();

if @@rowcount = 0 or @personSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	select
		r.RegistrantSID
	 ,r.PersonSID
	 ,r.RegistrantNo
	 ,r.LegacyKey
	 ,r.UpdateTime
	 ,r.UpdateUser
	from
		dbo.Registrant r
	where
		r.PersonSID = @personSID;

	begin transaction;

	exec dbo.pRegistrant#Set
		@UpdateRule = 'ALWAYS'
	 ,@PersonSID = @personSID
	 ,@RegistrantNo = @registrantNo
	 ,@LegacyKey = 'Test';
	select
		r.RegistrantSID
	 ,r.PersonSID
	 ,r.RegistrantNo
	 ,r.LegacyKey
	 ,r.UpdateTime
	 ,r.UpdateUser
	from
		dbo.Registrant r
	where
		r.PersonSID = @personSID;

	rollback;

end;
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1"/>
			<Assertion Type="RowCount" ResultSet="2" Value="1"/>
			<Assertion Type="ScalarValue" ResultSet="2" RowNo="1" ColumnNo="4" Value="Test"/>
			<Assertion Type="ExecutionTime" Value="00:00:04" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.Registrant#Set'
 ,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo						int							 = 0							-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText					nvarchar(4000)										-- message text (for business rule errors)
	 ,@blankParm					nvarchar(100)											-- error checking buffer for required parameters
	 ,@ON									bit							 = cast(1 as bit) -- constant for bit comparisons = 1
	 ,@existingUpdateTime datetimeoffset(7);								-- value of existing record update time (overwrite check input)

	set @RegistrantSID = @RegistrantSID; -- in/out (may be passed in to support updates)

	begin try

		-- check parameters

-- SQL Prompt formatting off
		if @RegistrantNo	is null set @blankParm = N'@RegistrantNo';
		if @PersonSID			is null set @blankParm = N'@PersonSID';
-- SQL Prompt formatting on

		if @blankParm is not null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = @blankParm;

			raiserror(@errorText, 18, 1);
		end;

		if @UpdateRule not in ('NEWONLY', 'LATEST', 'ALWAYS')
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'NotInList'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 provided "%2" is not valid. It must be one of: %3'
			 ,@Arg1 = 'update-rule-code'
			 ,@Arg2 = @UpdateRule
			 ,@Arg3 = '"NewOnly", "Latest", "Always"';

			raiserror(@errorText, 18, 1);
		end;

		-- check for an existing record

		if @RegistrantSID is null
		begin

			select
				@RegistrantSID			= r.RegistrantSID
			 ,@existingUpdateTime = r.UpdateTime
			from
				dbo.Registrant r
			where
				r.PersonSID = @PersonSID;

		end;

		if @RegistrantSID is null
		begin

			-- add the record; additional error checks are performed in the 
			-- constraint function and violations are reported to catch block

			exec dbo.pRegistrant#Insert
				@RegistrantSID = @RegistrantSID output
			 ,@PersonSID = @PersonSID
			 ,@RegistrantNo = @RegistrantNo
			 ,@PracticeRegisterSectionSID = @PracticeRegisterSectionSID -- if no registration exists, registrant is added to Applicant register where legacy key is NULL
			 ,@ArchivedTime = @ArchivedTime
			 ,@IsOnPublicRegistry = @IsOnPublicRegistry
			 ,@DirectedAuditYearCompetence = @DirectedAuditYearCompetence
			 ,@DirectedAuditYearPracticeHours = @DirectedAuditYearPracticeHours
			 ,@LegacyKey = @LegacyKey;

		end;
		else if @RegistrantNo is not null and @UpdateRule = 'LATEST' and @UpdateTime is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'LatestWithNoUpdateTime'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The update rule specified in the configuration is "LATEST" but no update time was provided from the source record.'
			 ,@SuppressCode = @ON;

			raiserror(@errorText, 16, 1);

		end;
		else if @RegistrantSID is not null and @UpdateRule = 'ALWAYS' -- case only applies where updates are ALWAYS performed
						or (@UpdateRule = 'LATEST' and @UpdateTime > @existingUpdateTime)
		begin

			exec dbo.pRegistrant#Update
				@RegistrantSID = @RegistrantSID
			 ,@PersonSID = @PersonSID
			 ,@RegistrantNo = @RegistrantNo
			 ,@ArchivedTime = @ArchivedTime
			 ,@IsOnPublicRegistry = @IsOnPublicRegistry
			 ,@DirectedAuditYearCompetence = @DirectedAuditYearCompetence
			 ,@DirectedAuditYearPracticeHours = @DirectedAuditYearPracticeHours
			 ,@LegacyKey = @LegacyKey;

		end;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);

end;
GO
