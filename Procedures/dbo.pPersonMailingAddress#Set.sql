SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pPersonMailingAddress#Set
	@PersonSID							 int									-- key of person record to insert/update address for (required!)
 ,@AutoAddCities					 bit = null						-- allow/disallow add-on-fly to dbo.City AND dbo.StateProvince
 ,@IsAdminReviewRequired	 bit = 1							-- indicates that any address added requires review by administrator
 ,@StreetAddress1					 nvarchar(75)					-- see dbo.PersonMailingAddress column descriptions:
 ,@StreetAddress2					 nvarchar(75) = null
 ,@StreetAddress3					 nvarchar(75) = null
 ,@CityName								 nvarchar(30)
 ,@StateProvinceName			 nvarchar(30) = null
 ,@StateProvinceCode			 nvarchar(5) = null
 ,@PostalCode							 varchar(10) = null
 ,@CountryName						 nvarchar(50) = null
 ,@CountryISOA3						 char(3) = null
 ,@EffectiveTime					 datetime = null			-- date and time the address should take effect
 ,@LegacyKey							 nvarchar(50) = null	-- key of mailing address record in source/converted system 
 ,@DefaultCountrySID			 int = null						-- default - will be looked up from table if not provided
 ,@DefaultStateProvinceSID int = null						-- default - will be looked up from table if not provided
 ,@CitySID								 int = null output
 ,@StateProvinceSID				 int = null output
 ,@CountrySID							 int = null output
 ,@PersonMailingAddressSID int = null output		-- key of address record inserted or updated
as

/*********************************************************************************************************************************
Procedure: Person Mailing Address - Set
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : Applies mailing address information from user-entered forms or staging records into main (DBO) tables
----------------------------------------------------------------------------------------------------------------------------------
History	 : Author							 | Month Year	| Change Summary
				 : ------------------- + ---------- + ------------------------------------------------------------------------------------
 				 : Tim Edlund          | Apr 2017		|	Initial version
				 : Tim Edlund					 | Mar 2019		| Modified logic to RAISE errors and suppressed code values in error messages

Comments
--------
This procedure supports adding or updating a mailing address from source data provided in user-entered forms (e.g. a renewal) or 
from the staging area "stg.PersonProfile" table.  The source data is passed into the procedure and the address is created.

The procedure requires a PersonSID to associate the new address with, and also at least one line of Street Address and a City
Name.  All other parameters are optional and/or can be defaulted.

Updating existing addresses is only carried out where a specific key value for an existing address is passed in.  The value may
be specified in either the @PersonMailingAddressSID or in the @LegacyKey.  The legacy key value is looked up in the legacy key
column in the dbo.PersonMailingAddress record to obtain the resulting key. Updating existing addresses, is however, unusual since
the database structure allows for addresses to be inserted with different effective dates. This creates a log of all address 
changes and supports "future dated" address changes.  If no @EffectiveTime for the address is passed in, then it is defaulted to 
the current date and time (in the end-user timezone).

Exact Address Match - Cancels Add
---------------------------------
If the address provided is identical to the current address in effect, and no effective date is provided, then the procedure
avoids creating the new address.  

Addressing Master Table Lookup
------------------------------
The procedure provides parameters for the primary key values of master tables - e.g. Country, StateProvince and City - however 
these  values will be looked up by the procedure based on the name/label and code values passed in. The Country table does not
support adding since it is shipped with a complete list of countries in the world and will not generally change.  The other
master tables do allow add-on-the-fly through this procedure provided the Update Rule for master tables is set to allow it.

Rule for Adding to Master Tables
--------------------------------
When AutoAddCities is enabled, the procedure will add new state province and city records where they don't exist in order to 
allow new addresses to be created. New master table records are automatically marked for review by administrators when added
through this method.  Note that updates to existing master table records is not supported (only adding).

Note also that countries not found do NOT result in new records being created in dbo.Country.  This is because the product 
ships with a full country list and values not found are likely to be errors that should be corrected at source.

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
	<Test Name="Random" IsDefault="true" Description="Calls procedure to update 2nd line of street address, city, province
	and postal code of record selected at random.">
		<SQLScript>
			<![CDATA[

declare
	@personSID				 int
 ,@cityName					 nvarchar(30)
 ,@streetAddress1		 nvarchar(75)
 ,@stateProvinceName nvarchar(30);

select top (1)
	@cityName					 = cty.CityName
 ,@stateProvinceName = cty.StateProvinceName
from
	dbo.vCity cty
where
	cty.IsActive = 1
order by
	newid();

select top (1)
	@streetAddress1 = pmac.StreetAddress1
 ,@personSID			= pmac.PersonSID
from
	dbo.vPersonMailingAddress#Current pmac
where
	pmac.CityName <> @cityName
order by
	newid();

if @@rowcount = 0 or @personSID is null or @cityName is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	select
		pmac.StreetAddress1
	 ,pmac.StreetAddress2
	 ,pmac.CityName
	 ,pmac.StateProvinceCode
	 ,pmac.PostalCode
	from
		dbo.vPersonMailingAddress#Current pmac
	where
		pmac.PersonSID = @personSID;

	begin transaction;

	exec dbo.pPersonMailingAddress#Set
		@PersonSID = @personSID
	 ,@StreetAddress1 = @streetAddress1
	 ,@StreetAddress2 = 'Test'
	 ,@CityName = @cityName
	 ,@StateProvinceName = @stateProvinceName
	 ,@PostalCode = 'X0X 0X0';

	select
		pmac.StreetAddress1
	 ,pmac.StreetAddress2
	 ,pmac.CityName
	 ,pmac.StateProvinceCode
	 ,pmac.PostalCode
	from
		dbo.vPersonMailingAddress#Current pmac
	where
		pmac.PersonSID = @personSID;

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
	@ObjectName = 'dbo.pPersonMailingAddress#Set'
 ,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo		 int					 = 0							-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText	 nvarchar(4000)									-- message text (for business rule errors)
	 ,@blankParm	 nvarchar(100)									-- error checking buffer for required parameters
	 ,@ON					 bit					 = cast(1 as bit) -- used on bit comparisons to avoid multiple casts
	 ,@newCheckSum int;														-- buffer for new value of checksum

	set @PersonMailingAddressSID = @PersonMailingAddressSID; -- in/out may be passed in
	set @CountrySID = @CountrySID;
	set @StateProvinceSID = @StateProvinceSID;
	set @CitySID = @CitySID;

	begin try

		-- check parameters

-- SQL Prompt formatting off
		if @StreetAddress1	is null	set @blankParm = N'@StreetAddress1';
		if @CityName				is null set @blankParm = N'@CityName';
		if @PersonSID				is null set @blankParm = N'@PersonSID';
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

		-- lookup configuration setting if not provided

		if @AutoAddCities is null
		begin
			set @AutoAddCities = isnull(convert(bit, sf.fConfigParam#Value('AutoAddCities')), '1');
		end;

		-- check for legacy key 

		if @PersonMailingAddressSID is null and @LegacyKey is not null
		begin

			select
				@PersonMailingAddressSID = pma.PersonMailingAddressSID
			from
				dbo.PersonMailingAddress pma
			where
				isnull(pma.LegacyKey, 'x') = @LegacyKey;

		end;

		-- lookup defaults for country and state province if not passed in

		if @DefaultCountrySID is null
		begin

			select
				@DefaultCountrySID = ctry.CountrySID
			from
				dbo.Country ctry
			where
				ctry.IsDefault = @ON;

		end;

		if @DefaultCountrySID is not null and @DefaultStateProvinceSID is null
		begin

			select
				@DefaultStateProvinceSID = sp.StateProvinceSID
			from
				dbo.StateProvince sp
			where
				sp.CountrySID = @DefaultCountrySID and sp.IsDefault = @ON;

		end;

		-- city, state-province and country have a cascading relationship 
		-- so attempt to find parent key where child key is provided (edge case)

		if @StateProvinceSID is null and @CitySID is not null
		begin

			select
				@StateProvinceSID = x.StateProvinceSID
			from
				dbo.City x
			where
				x.CitySID = @CitySID;

		end;

		if @CountrySID is null and @StateProvinceSID is not null
		begin

			select
				@CountrySID = x.CountrySID
			from
				dbo.StateProvince x
			where
				x.StateProvinceSID = @StateProvinceSID;

		end;

		-- if a country value is provided, attempt to look it up

		if @CountrySID is null and (@CountryName is not null or @CountryISOA3 is not null)
		begin

			exec dbo.pCountry#Lookup
				@CountryName = @CountryName
			 ,@ISOA3 = @CountryISOA3
			 ,@CountrySID = @CountrySID output;

			if @CountrySID is null
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'MasterTableValueNotProvided'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The value provided for "%1" is missing or invalid. Correct the source value or add it to the master table before re-processing the record.'
				 ,@Arg1 = 'Country'
				 ,@SuppressCode = @ON;

				raiserror(@errorText, 16, 1);
			end;

		end;

		if @CountrySID is null and @CountryName is null and @CountryISOA3 is null
		begin
			set @CountrySID = @DefaultCountrySID; -- assign default if not passed

			if @CountrySID is null
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'ConfigurationNotComplete'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The configuration setting for "%1" is missing or invalid.'
				 ,@Arg1 = 'Default Country'
				 ,@SuppressCode = @ON;

				raiserror(@errorText, 16, 1);
			end;
		end;

		-- if a country was found and a stateProvince value is provided, attempt to look it up

		if @CountrySID is not null
		begin

			if @StateProvinceSID is null and (@StateProvinceName is not null or @StateProvinceCode is not null)
			begin

				exec dbo.pStateProvince#Lookup
					@StateProvinceName = @StateProvinceName
				 ,@StateProvinceCode = @StateProvinceCode
				 ,@CountrySID = @CountrySID
				 ,@IsAddEnabled = @AutoAddCities
				 ,@StateProvinceSID = @StateProvinceSID output;

				if @StateProvinceSID is null
				begin

					exec sf.pMessage#Get
						@MessageSCD = 'MasterTableValueNotProvided'
					 ,@MessageText = @errorText output
					 ,@DefaultText = N'The value provided for "%1" is missing or invalid. Correct the source value or add it to the master table before re-processing the record.'
					 ,@Arg1 = 'State/Province'
					 ,@SuppressCode = @ON;

					raiserror(@errorText, 16, 1);
				end;

			end;

			if @StateProvinceSID is null and @StateProvinceName is null and @StateProvinceCode is null -- assign default if not passed
			begin
				set @StateProvinceSID = @DefaultStateProvinceSID;

				if @StateProvinceSID is null
				begin

					exec sf.pMessage#Get
						@MessageSCD = 'ConfigurationNotComplete'
					 ,@MessageText = @errorText output
					 ,@DefaultText = N'The configuration setting for "%1" is missing or invalid.'
					 ,@Arg1 = 'Default State/Province'
					 ,@SuppressCode = @ON;

					raiserror(@errorText, 16, 1);

				end;
			end;
		end;

		-- if a StateProvince was found and a city value is provided, attempt to look it up

		if @StateProvinceSID is not null
		begin

			if @CitySID is null
			begin

				exec dbo.pCity#Lookup
					@CityName = @CityName
				 ,@StateProvinceSID = @StateProvinceSID
				 ,@CountrySID = @CountrySID
				 ,@IsAddEnabled = @AutoAddCities
				 ,@CitySID = @CitySID output;

				if @CitySID is null
				begin

					exec sf.pMessage#Get
						@MessageSCD = 'MasterTableValueNotProvided'
					 ,@MessageText = @errorText output
					 ,@DefaultText = N'The value provided for "%1" is missing or invalid. Correct the source value or add it to the master table before re-processing the record.'
					 ,@Arg1 = 'City'
					 ,@SuppressCode = @ON;

					raiserror(@errorText, 16, 1);
				end;

			end;

		end;

		-- lookups are complete so if no errors, add the record if it is new
		-- or update it if a key was found (avoid action if a duplicate)

		set @newCheckSum = checksum(@StreetAddress1, @StreetAddress2, @StreetAddress3, @CitySID);

		if not exists
		(
			select
				1
			from
				dbo.fPersonMailingAddress#Current(@PersonSID) pma
			where
				checksum(pma.StreetAddress1, pma.StreetAddress2, pma.StreetAddress3, pma.CitySID) = @newCheckSum and (@EffectiveTime is null)
		)
		begin

			if @PersonMailingAddressSID is null
			begin

				-- add the record; additional error checks are performed in the 
				-- constraint function and violations are reported to catch block

				exec dbo.pPersonMailingAddress#Insert
					@PersonMailingAddressSID = @PersonMailingAddressSID output
				 ,@PersonSID = @PersonSID
				 ,@StreetAddress1 = @StreetAddress1
				 ,@StreetAddress2 = @StreetAddress2
				 ,@StreetAddress3 = @StreetAddress3
				 ,@CitySID = @CitySID
				 ,@PostalCode = @PostalCode
				 ,@EffectiveTime = @EffectiveTime
				 ,@IsAdminReviewRequired = @IsAdminReviewRequired
				 ,@LegacyKey = @LegacyKey;

			end;
			else if @PersonMailingAddressSID is not null
			begin

				exec dbo.pPersonMailingAddress#Update
					@PersonMailingAddressSID = @PersonMailingAddressSID
				 ,@PersonSID = @PersonSID
				 ,@StreetAddress1 = @StreetAddress1
				 ,@StreetAddress2 = @StreetAddress2
				 ,@StreetAddress3 = @StreetAddress3
				 ,@CitySID = @CitySID
				 ,@PostalCode = @PostalCode
				 ,@EffectiveTime = @EffectiveTime
				 ,@IsAdminReviewRequired = @IsAdminReviewRequired
				 ,@LegacyKey = @LegacyKey;

			end;

		end;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);

end;
GO
