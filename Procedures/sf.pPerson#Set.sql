SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sf.pPerson#Set
	@UpdateRule							varchar(10) = null				-- setting of person tables update rule - see comments below
 ,@LastName								nvarchar(35) = null				-- values of next record to process (see table doc for details):
 ,@FirstName							nvarchar(30) = null				-- see sf.Person column descriptions:
 ,@CommonName							nvarchar(30) = null
 ,@MiddleNames						nvarchar(30) = null
 ,@EmailAddress						varchar(150) = null
 ,@HomePhone							varchar(25) = null
 ,@MobilePhone						varchar(25) = null
 ,@IsTextMessagingEnabled bit = null
 ,@SignatureImage					varbinary(max) = null
 ,@IdentityPhoto					varbinary(max) = null
 ,@GenderCode							varchar(5) = null
 ,@GenderLabel						nvarchar(35) = null
 ,@NamePrefixLabel				nvarchar(35) = null
 ,@BirthDate							date = null
 ,@DeathDate							date = null
 ,@UserName								nvarchar(75) = null
 ,@Password								nvarchar(50) = null
 ,@AuthenticationSystemID varchar(50) = null
 ,@ApplicationGrantSID1		int = null								-- optional grants to assign to new application user records created:
 ,@ApplicationGrantSID2		int = null
 ,@ApplicationGrantSID3		int = null
 ,@NamePrefixSID					int = null								-- key in name-prefix master table looked up or added
 ,@GenderSID							int = null								-- key in gender master table looked up or added
 ,@PersonXID							varchar(150) = null				-- external ID to assign
 ,@LegacyKey							nvarchar(50) = null				-- key of person record in source/converted system 
 ,@UpdateTime							datetimeoffset(7) = null	-- required if profile-update-rule is "LATEST"
 ,@SourceFileName					nvarchar(100) = null			-- name of file or source of data
 ,@PersonSID							int = null output					-- key of person record inserted or updated
 ,@PersonEmailAddressSID	int = null output					-- key of person email address inserted or updated
 ,@ApplicationUserSID			int = null output					-- key of application user record inserted (no updates)
 ,@ReturnResultSet				bit = 0										-- set to 1 to have output values returned as a dataset
 ,@DebugLevel							tinyint = 0								-- when > 0 causes debug statements and timing marks to print
as
/*********************************************************************************************************************************
Procedure: Person - Set
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : Applies person profile information from user-entered forms or conversion records into sf.Person table
----------------------------------------------------------------------------------------------------------------------------------
History	 : Author							| Month Year	| Change Summary
				 : ------------------ + ----------- + ------------------------------------------------------------------------------------
 				 : Tim Edlund         | Apr 2017		|	Initial version
				 : Taylor Napier			| Feb 2018		| Removed the requirement for an @emailAddress to be included for new profiles
				 : Tim Edlund					| May 2018		| Added support for partial rollback where pending transaction exists on entry
				 : Tim Edlund					| Mar 2019		| Modified logic to RAISE errors and added support for initial grants and result set

Comments	
--------
This procedure supports creating or updating a person profile from source data provided in user-entered forms (e.g. application)
or from data captured in the staging (stg) schema. The source data is passed into the procedure and the profile is created if 
one is not found, or updated if existing records exist.

The profile is made up of 4 records: sf.Person, sf.PersonEmailAddress, sf.ApplicationUser and sf.ApplicationUserGrant.  All 
parameters are optional since the procedure may be called where the sf.Person row exists and existing columns there or in the 
other 3 tables are being updated.  To create a new person profile, values for the mandatory and non-defaulted columns for the tables 
must be provided. 

The procedure also provides parameters for the primary key values of master tables - e.g. Gender and Name-Prefix - however these 
values will be looked up by the procedure based on the name/label and code values passed in. The master tables which 
parent the person profile are normally fixed and DO NOT support add-on-the-fly through this procedure. This restriction is
implemented to control data quality on this specific set of master tables.

A PersonSID is also provided as a parameter but if a value is not passed for it, the procedure checks for an existing person
profile based on looking up a person key, legacy key, an email address, or a combination of name + birth date (see code for
details). The key value found or added, is returned as an output variable.

Update Rule for Existing Profile Table Records
----------------------------------------------
The procedure creates a new profile where no match is found to existing records on the content passed in (person key, legacy 
key, email address, or name + birth date).  Where a matching profile is found, it will be updated based on the setting of the 
@UpdateRule.  If this value is not passed directly as a parameter, it is looked up as a configuration value.  The 
following settings are supported:

ALWAYS			-- existing record is always overwritten with information passed in
NEWONLY			-- existing records are never updated
LATEST			-- existing record overwritten if the @UpdateTime passed in is later than the existing record

The default setting is "NEWONLY", since the product database is normally considered to be the repository of the most up-to-date
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
	<Test Name="UpdatePerson" IsDefault="true" Description="Calls procedure to update middle name and phone number on Person record.">
		<SQLScript>
			<![CDATA[

declare
	@profileUpdateRule varchar(10) = 'ALWAYS'
 ,@legacyKey				 nvarchar(50)
 ,@middleNames			 nvarchar(30)
 ,@homePhone				 varchar(25)
 ,@mobilePhone			 varchar(25);

select top (1)
	@legacyKey	 = p.LegacyKey
 ,@middleNames = N'Test'
 ,@homePhone	 = p.HomePhone
 ,@mobilePhone = '555-555-5555'
from
	sf.Person p
where
	p.LegacyKey is not null
order by
	newid();

if @@rowcount = 0 or @legacyKey is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	select
		p.LegacyKey
	 ,p.MiddleNames
	 ,p.HomePhone
	 ,p.MobilePhone
	from
		sf.Person p
	where
		p.LegacyKey = @legacyKey;

	begin transaction;

	exec sf.pPerson#Set
		@UpdateRule = @profileUpdateRule
	 ,@LegacyKey = @legacyKey
	 ,@MiddleNames = @middleNames
	 ,@HomePhone = @homePhone
	 ,@MobilePhone = @mobilePhone;

	select
		p.LegacyKey
	 ,p.MiddleNames
	 ,p.HomePhone
	 ,p.MobilePhone
	from
		sf.Person p
	where
		p.LegacyKey = @legacyKey;

	rollback; -- undo changes from test
end;
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1"/>
			<Assertion Type="RowCount" ResultSet="2" Value="1"/>
			<Assertion Type="ScalarValue" ResultSet="2" RowNo="1" ColumnNo="2" Value="Test"/>
			<Assertion Type="ExecutionTime" Value="00:00:04" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.pPerson#Set'
 ,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo						 int							= 0								-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText					 nvarchar(max)											-- processing comments/error text 
	 ,@ON									 bit							= cast(1 as bit)	-- used on bit comparisons to avoid multiple casts
	 ,@OFF								 bit							= cast(0 as bit)	-- constant for bit comparison = 0
	 ,@applicationGrantSID int																-- buffer for assigning next grant passed in by caller
	 ,@i									 int																-- loop incrementer
	 ,@isActive						 bit																-- indicates whether accounts should be deactivated on creation
	 ,@timeCheck					 datetimeoffset(7)									-- used to debug time elapsed between subroutines
	 ,@debugString				 nvarchar(70);											-- string to track progress through procedure

	set @PersonSID = @PersonSID; -- initialize output variables - in/out may be passed in
	set @PersonEmailAddressSID = @PersonEmailAddressSID; -- in/out may be passed in
	set @ApplicationUserSID = @ApplicationUserSID; -- in/out may be passed in

	begin try

		if @DebugLevel > 1
		begin
			set @debugString = N'Checking parameters (' + object_name(@@procid) + N')';

			exec sf.pDebugPrint
				@DebugString = @debugString
			 ,@TimeCheck = @timeCheck output;

		end;

		-- lookup configuration setting if not provided

		if @UpdateRule is null
		begin
			set @UpdateRule = isnull(convert(varchar(10), sf.fConfigParam#Value('ProfileUpdateRule')), 'NEWONLY');
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

		if @DebugLevel > 1
		begin

			exec sf.pDebugPrint
				@DebugString = N'Checking for existing keys'
			 ,@TimeCheck = @timeCheck output;

		end;

		-- the sf.Person record will be updated by the procedure if it already exists
		-- if no key value passed in, then attempt to lookup based on several criteria

		if @PersonSID is null and @LegacyKey is not null
		begin

			select
				@PersonSID = p.PersonSID
			from
				sf.Person p
			where
				isnull(p.LegacyKey, 'x') = @LegacyKey;	-- check for legacy key 

		end;

		if @PersonSID is null and @EmailAddress is not null
		begin

			select
				@PersonSID = pea.PersonSID
			from
				sf.PersonEmailAddress pea
			where
				pea.EmailAddress = @EmailAddress; -- check for existing email address (must be unique!)

		end;

		if @PersonSID is null and @LastName is not null and @FirstName is not null and @BirthDate is not null -- match on name + birth date
		begin

			select
				@PersonSID = p.PersonSID
			from
				sf.vPerson p
			where
				p.LastName = @LastName and p.BirthDate = @BirthDate and (p.FirstName = @FirstName or p.CommonName = @FirstName);

		end;

		-- check for existing email address based on the person key but only where
		-- an email address is provided

		if @EmailAddress is not null
		begin

			if @PersonEmailAddressSID is null and @PersonSID is not null
			begin

				select
					@PersonEmailAddressSID = pea.PersonEmailAddressSID
				from
					sf.PersonEmailAddress pea
				where
					pea.PersonSID = @PersonSID and pea.IsPrimary = @ON;

			end;

		end;
		else
		begin
			set @PersonEmailAddressSID = null; -- prevent updating if no email address provided!
		end;

		-- check for application user record; no updates are allowed so finding
		-- a record blocks insert

		if @ApplicationUserSID is null
		begin

			select
				@ApplicationUserSID = au.ApplicationUserSID
			from
				sf.ApplicationUser au
			where
				au.PersonSID = @PersonSID;

		end;

		if @DebugLevel > 1
		begin

			exec sf.pDebugPrint
				@DebugString = N'Processing master lookups'
			 ,@TimeCheck = @timeCheck output;

		end;

		-- look-up Name Prefix if provided - if not found return error
		-- note that adding to master table is NOT supported 

		if @NamePrefixSID is null and @NamePrefixLabel is not null
		begin

			exec sf.pNamePrefix#Lookup
				@NamePrefixLabel = @NamePrefixLabel
			 ,@NamePrefixSID = @NamePrefixSID output; -- name prefix is not mandatory but must be valid where provided (no add)

			if @NamePrefixSID is null
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'MasterTableValueNotProvided'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The value provided for "%1" is missing or invalid. Correct the source value or add it to the master table before re-processing the record.'
				 ,@Arg1 = 'Name Prefix';

				raiserror(@errorText, 16, 1);
			end;

		end;

		-- look-up Gender if provided - if not found return error
		-- note that adding to master table is NOT supported 

		if @GenderSID is null and (@GenderCode is not null or @GenderLabel is not null)
		begin

			exec sf.pGender#Lookup
				@GenderSCD = @GenderCode
			 ,@GenderLabel = @GenderLabel
			 ,@GenderSID = @GenderSID output;

		end;

		-- if a new record needs to be added, and given GenderSID is mandatory, 
		-- check for "Undefined" gender as default

		if @PersonSID is null
		begin

			if @GenderSID is null
			begin
				select @GenderSID	 = x.GenderSID from sf.Gender x where x.GenderSCD = 'U';
			end;

			if @GenderSID is null -- avoid error on insert and document in processing comments
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'MasterTableValueNotProvided'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The value provided for "%1" is missing or invalid. Correct the source value or add it to the master table before re-processing the record.'
				 ,@Arg1 = 'Gender'
				 ,@SuppressCode = @ON;

				raiserror(@errorText, 16, 1);

			end;
			else if @LastName is null or @FirstName is null -- required columns	
			begin -- note that configuration-specific rules may turn on other mandatory checks at INSERT!

				exec sf.pMessage#Get
					@MessageSCD = 'RequiredValueNotProvided'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'A required value was not provided for one or more fields: "%1".'
				 ,@Arg1 = 'Last Name, First Name, Email Address'
				 ,@SuppressCode = @ON;

				raiserror(@errorText, 16, 1);

			end;
		end;

		-- lookups are complete so add the record if it is new;
		-- if it exists, update it if configuration settings allow it

		if @SourceFileName is null
		begin
			set @SourceFileName = cast(convert(varchar(8), sf.fToday(), 112) + '.' + sf.fApplicationUserSession#UserName() as nvarchar(50));
		end;

		if @PersonSID is null
		begin

			if @DebugLevel > 1
			begin

				exec sf.pDebugPrint
					@DebugString = N'Inserting person'
				 ,@TimeCheck = @timeCheck output;

			end;

			-- add the record; additional error checks are performed in the 
			-- constraint function and violations are reported to catch block

			exec sf.pPerson#Insert
				@PersonSID = @PersonSID output
			 ,@GenderSID = @GenderSID
			 ,@NamePrefixSID = @NamePrefixSID
			 ,@FirstName = @FirstName
			 ,@CommonName = @CommonName
			 ,@MiddleNames = @MiddleNames
			 ,@LastName = @LastName
			 ,@BirthDate = @BirthDate
			 ,@DeathDate = @DeathDate
			 ,@HomePhone = @HomePhone
			 ,@MobilePhone = @MobilePhone
			 ,@IsTextMessagingEnabled = @IsTextMessagingEnabled
			 ,@SignatureImage = @SignatureImage
			 ,@IdentityPhoto = @IdentityPhoto
			 ,@ImportBatch = @SourceFileName
			 ,@LegacyKey = @LegacyKey
			 ,@PersonXID = @PersonXID
			 ,@PrimaryEmailAddressSID = @PersonEmailAddressSID	-- email address insert/updates handle in parent sproc
			 ,@PrimaryEmailAddress = @EmailAddress;

			select
				@PersonEmailAddressSID = pea.PersonEmailAddressSID
			from
				sf.PersonEmailAddress pea
			where
				pea.PersonSID = @PersonSID; -- retrieve key for output variable

		end;
		else if @PersonSID is not null and @UpdateRule = 'LATEST' and @UpdateTime is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'LatestWithNoUpdateTime'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The update rule specified in the configuration is "LATEST" but no update time was provided from the source record.'
			 ,@SuppressCode = @ON;

			raiserror(@errorText, 16, 1);

		end;
		else if @PersonSID is not null -- where person record does exist
						and @UpdateRule = 'ALWAYS' -- and profile updates are always to be applied (configuration setting)
						or
						(
							@UpdateRule = 'LATEST' -- only latest update so inspect update time
							and @UpdateTime > (select x.UpdateTime from sf.Person x where x.PersonSID = @PersonSID)
						)
		begin

			if @DebugLevel > 1
			begin

				exec sf.pDebugPrint
					@DebugString = N'Updating person'
				 ,@TimeCheck = @timeCheck output;

			end;

			exec sf.pPerson#Update
				@PersonSID = @PersonSID
			 ,@GenderSID = @GenderSID
			 ,@NamePrefixSID = @NamePrefixSID
			 ,@FirstName = @FirstName
			 ,@CommonName = @CommonName
			 ,@MiddleNames = @MiddleNames
			 ,@LastName = @LastName
			 ,@BirthDate = @BirthDate
			 ,@DeathDate = @DeathDate
			 ,@HomePhone = @HomePhone
			 ,@MobilePhone = @MobilePhone
			 ,@IsTextMessagingEnabled = @IsTextMessagingEnabled
			 ,@SignatureImage = @SignatureImage
			 ,@IdentityPhoto = @IdentityPhoto
			 ,@ImportBatch = @SourceFileName
			 ,@LegacyKey = @LegacyKey
			 ,@PersonXID = @PersonXID
			 ,@PrimaryEmailAddressSID = @PersonEmailAddressSID
			 ,@PrimaryEmailAddress = @EmailAddress;

		end;

		-- add an application user if required values are provided and a record 
		-- does not already exist

		if @ApplicationUserSID is null and @PersonSID is not null and @UserName is not null
		begin

			if @DebugLevel > 1
			begin

				exec sf.pDebugPrint
					@DebugString = N'Inserting application user'
				 ,@TimeCheck = @timeCheck output;

			end;

			-- if no password is provided, disable the account on insert; 
			-- it will automatically activate on confirmation by user

			if @Password is null -- no password -> disable account
			begin
				set @isActive = @OFF;
			end;
			else -- otherwise allo system default to apply
			begin
				set @isActive = null;
			end;

			exec sf.pApplicationUser#Insert
				@ApplicationUserSID = @ApplicationUserSID output	-- insert the user into the local database
			 ,@PersonSID = @PersonSID
			 ,@UserName = @UserName
			 ,@Password = @Password															-- encryption handled within this sproc (where password provided)
			 ,@AuthenticationSystemID = @AuthenticationSystemID -- may contain primary ID from previous system to use as alternate login
			 ,@IsActive = @isActive															-- pass as NULL to use system default for activation
			 ,@LegacyKey = @LegacyKey;													-- set the legacy key on the app user to the same as that on sf.Person


			if @DebugLevel > 1 and coalesce(@ApplicationGrantSID1, @ApplicationGrantSID2, @ApplicationGrantSID3) is not null
			begin

				exec sf.pDebugPrint
					@DebugString = N'Applying user grants'
				 ,@TimeCheck = @timeCheck output;

			end;

			set @i = 0;

			while @i < 3
			begin
				set @i += 1;

				set @applicationGrantSID = null;
				if @i = 1 set @applicationGrantSID = @ApplicationGrantSID1;
				if @i = 2 set @applicationGrantSID = @ApplicationGrantSID2;
				if @i = 3 set @applicationGrantSID = @ApplicationGrantSID3;

				if @applicationGrantSID is not null
				begin

					exec sf.pApplicationUserGrant#Insert
						@ApplicationUserSID = @ApplicationUserSID
					 ,@ApplicationGrantSID = @applicationGrantSID;

				end;

			end;

		end;

		if @DebugLevel > 1
		begin

			exec sf.pDebugPrint
				@DebugString = N'Updates complete'
			 ,@TimeCheck = @timeCheck output;

		end;

		if @ReturnResultSet = @ON
		begin

			select
				@PersonSID						 PersonSID
			 ,@PersonEmailAddressSID PersonEmailAddressSID
			 ,@ApplicationUserSID		 ApplicationUserSID;

		end;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);

end;
GO
