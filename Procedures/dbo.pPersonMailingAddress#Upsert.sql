SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pPersonMailingAddress#Upsert]
	@PersonMailingAddressSID	 int							 output
 ,@RowGUID									 uniqueidentifier					-- pass sub-form ID here
 ,@PersonSID								 int							 = null -- required! if not passed value must be set in custom logic prior to insert
 ,@StreetAddress1						 nvarchar(75)			 = null -- required! if not passed value must be set in custom logic prior to insert
 ,@StreetAddress2						 nvarchar(75)			 = null
 ,@StreetAddress3						 nvarchar(75)			 = null
 ,@CitySID									 int							 = null -- required! if not passed value must be set in custom logic prior to insert
 ,@PostalCode								 varchar(10)			 = null
 ,@RegionSID								 int							 = null -- required! if not passed value must be set in custom logic prior to insert
 ,@EffectiveTime						 datetime					 = null -- default: sf.fNow()
 ,@IsAdminReviewRequired		 bit							 = null -- IGNORED - set by system according to who is logged in
 ,@LastVerifiedTime					 datetimeoffset(7) = null	-- IGNORED
 ,@ChangeLog								 xml							 = null -- IGNORED
 ,@UserDefinedColumns				 xml							 = null	-- IGNORED
 ,@PersonMailingAddressXID	 varchar(150)			 = null	-- IGNORED
 ,@LegacyKey								 nvarchar(50)			 = null	-- IGNORED
 ,@CreateUser								 nvarchar(75)			 = null -- default: suser_sname()
 ,@IsReselected							 tinyint					 = null -- when 1 all columns in entity view are returned, 2 PK only, 0 none
 ,@zContext									 xml							 = null -- other values defining context for the insert (if any)
 ,@CityName									 nvarchar(30)			 = null -- not a base table column (ignored)
 ,@StateProvinceSID					 int							 = null -- not a base table column (ignored)
 ,@CityIsDefault						 bit							 = null -- not a base table column (ignored)
 ,@CityIsActive							 bit							 = null -- not a base table column (ignored)
 ,@CityIsAdminReviewRequired bit							 = null -- not a base table column (ignored)
 ,@CityRowGUID							 uniqueidentifier	 = null -- not a base table column (ignored)
 ,@RegionLabel							 nvarchar(35)			 = null -- not a base table column (ignored)
 ,@RegionName								 nvarchar(50)			 = null -- not a base table column (ignored)
 ,@RegionIsDefault					 bit							 = null -- not a base table column (ignored)
 ,@RegionIsActive						 bit							 = null -- not a base table column (ignored)
 ,@RegionRowGUID						 uniqueidentifier	 = null -- not a base table column (ignored)
 ,@GenderSID								 int							 = null -- not a base table column (ignored)
 ,@NamePrefixSID						 int							 = null -- not a base table column (ignored)
 ,@FirstName								 nvarchar(30)			 = null -- not a base table column (ignored)
 ,@CommonName								 nvarchar(30)			 = null -- not a base table column (ignored)
 ,@MiddleNames							 nvarchar(30)			 = null -- not a base table column (ignored)
 ,@LastName									 nvarchar(35)			 = null -- not a base table column (ignored)
 ,@BirthDate								 date							 = null -- not a base table column (ignored)
 ,@DeathDate								 date							 = null -- not a base table column (ignored)
 ,@HomePhone								 varchar(25)			 = null -- not a base table column (ignored)
 ,@MobilePhone							 varchar(25)			 = null -- not a base table column (ignored)
 ,@IsTextMessagingEnabled		 bit							 = null -- not a base table column (ignored)
 ,@ImportBatch							 nvarchar(100)		 = null -- not a base table column (ignored)
 ,@PersonRowGUID						 uniqueidentifier	 = null -- not a base table column (ignored)
 ,@IsDeleteEnabled					 bit							 = null -- not a base table column (ignored)
 ,@HtmlAddress							 nvarchar(512)		 = null -- not a base table column (ignored)
 ,@IsCurrentAddress					 bit							 = null -- not a base table column (ignored)
 ,@CountrySID								 int							 = null -- not a base table column (ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pPersonMailingAddress#Upsert
Notice    : Copyright © 2017 Softworks Group Inc.
Summary   : Inserts or updates the mailing address based on provision of PK and whether address was changed (see Comments)
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund	| Sep	2017			|	Initial version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This procedure is a wrapper for the #Insert and #Update procedures on the table. The procedure is called during form processing 
(from sf.pForm#Post) to save values on changed addresses.  Typically, renewal forms, application forms and profile update forms 
allow address information to be entered and updated. 

The procedure calls the #Insert sproc to record a new address record whenever changes are detected, and when the first mailing 
address record is provided. If an existing address exists but no change to it is detected, then the procedure updates the 
LastVerifiedTime only.  The update to the last verified time is useful in advising admin that the registrant/applicant has 
confirmed their address at that point in time.

The procedure determines whether a change has occurred by comparing checksums on the new and old values of the address using a 
checksum. Where a change in address is detected, the #Insert procedure is called rather than #Update in order to store a history 
of addresses which is useful in tracking down delivery issues and in some cases, to evaluate eligibility for licensure.  If the 
change occurs within 1 hour of the previous update however, a new address is NOT stored.  In that scenario the change is assumed 
to be a correction of the previous update. 

If no primary key value is passed in, then the #Insert procedure is always called since no means of updating an existing record
has been provided.

Form Design
-----------
When configuring forms for address changes, be sure to include all 3 address lines, city and postal code.  The @EffectiveTime, 
which indicates when the address should start being used (in the user’s time zone), is optional and if not passed is assumed to be 
the current time.  

The RegionSID is also optional.  If not passed Region can be calculated based on postal code if the region mapping table has been 
configured. If that table is not configured and a RegionSID is not passed, then when a new record is inserted it is given the same 
RegionSID as the previous address record.  If Region is based on location, configuring the mapping table is recommended or 
otherwise include a drop-down list of regions on the form and make the value mandatory. 

-------------------------------------------------------------------------------------------------------------------------------- */
set nocount on;

begin
	declare
		@errorNo		 int						= 0								-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText	 nvarchar(4000)										-- message text (for business rule errors)
	 ,@ON					 bit						= cast(1 as bit)	-- constant for bit comparison and assignments
	 ,@OFF				 bit						= cast(0 as bit)	-- constant for bit comparison and assignments
	 ,@oldCheckSum int						= 0								-- used in detecting change to address; previous value
	 ,@newCheckSum int						= -1							-- used in detecting change to address; new value
	 ,@lastUpdate	 datetimeoffset										-- time of last address change 
	 ,@now				 datetimeoffset = sf.fNow();			-- current system time

	set @PersonMailingAddressSID = @PersonMailingAddressSID; -- populate output parameter in all code paths

	begin try
		-- look for changes from the previous address where are 
		-- primary key value is provided
		if @PersonMailingAddressSID is not null
		begin
			select
				@lastUpdate	 = pma.UpdateTime
			 ,@RegionSID	 = isnull(@RegionSID, pma.RegionSID)	-- retrieve existing region for new record if not otherwise passed
			 ,@oldCheckSum = checksum(pma.StreetAddress1, pma.StreetAddress2, pma.StreetAddress3, pma.CitySID, pma.PostalCode, pma.RegionSID, pma.EffectiveTime)
			 ,@newCheckSum =
					checksum(
										@StreetAddress1
									 ,@StreetAddress2
									 ,@StreetAddress3
									 ,@CitySID
									 ,@PostalCode
									 ,isnull(@RegionSID, pma.RegionSID)					-- where region is not passed, assume it is unchanged
									 ,isnull(@EffectiveTime, pma.EffectiveTime) -- where effective time is not passed, assume it is unchanged
									)
			from
				dbo.PersonMailingAddress pma
			where
				pma.PersonMailingAddressSID = @PersonMailingAddressSID;

			if @@rowcount = 0
			begin
				exec sf.pMessage#Get
					@MessageSCD = 'RecordNotFound'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
				 ,@Arg1 = 'Person-Mailing-Address'
				 ,@Arg2 = @PersonMailingAddressSID;

				raiserror(@errorText, 18, 1);
			end;
		end;

		-- where a previous address exists and is unchanged, 
		-- update the verified time only
		if @oldCheckSum = @newCheckSum
		begin
			exec @errorNo = dbo.pPersonMailingAddress#Update
				@PersonMailingAddressSID = @PersonMailingAddressSID
			 ,@LastVerifiedTime = @now;
		end;
		-- where a change was made but previous version was updated
		-- within last hour - update the existing record
		else if @PersonMailingAddressSID is not null
						and datediff(minute, @lastUpdate, sf.fNow()) <= 60 -- address is different but previous update was made in last hour (update only)
		begin
			exec @errorNo = dbo.pPersonMailingAddress#Update
				@PersonMailingAddressSID = @PersonMailingAddressSID
			 ,@PersonSID = @PersonSID
			 ,@StreetAddress1 = @StreetAddress1
			 ,@StreetAddress2 = @StreetAddress2
			 ,@StreetAddress3 = @StreetAddress3
			 ,@CitySID = @CitySID
			 ,@PostalCode = @PostalCode
			 ,@RegionSID = @RegionSID
			 ,@EffectiveTime = @EffectiveTime;
		end;
		else -- otherwise store the address as a new record
		begin
			exec @errorNo = dbo.pPersonMailingAddress#Insert
				@PersonSID = @PersonSID
			 ,@StreetAddress1 = @StreetAddress1
			 ,@StreetAddress2 = @StreetAddress2
			 ,@StreetAddress3 = @StreetAddress3
			 ,@CitySID = @CitySID
			 ,@PostalCode = @PostalCode
			 ,@RegionSID = @RegionSID
			 ,@EffectiveTime = @EffectiveTime;
		end;
	end try
	begin catch
		if @@trancount > 0 rollback;

		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);
end;
GO
