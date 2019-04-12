SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sf.pPersonMailingPreference#Upsert
	@PersonMailingPreferenceSID int = null output		-- key value of record inserted or updated
 ,@MailingPreferenceSID				int = null
 ,@EffectiveTime							datetime = null
 ,@ExpiryTime									datetime = null
 ,@RowGUID										nvarchar(50) = null -- pass GUID of existing row here or NULL to lookup by person and preference keys
 ,@PersonSID									int = null
 ,@IsActive										bit = 1							-- pass to EF sproc to set expiry time based on bit when no ExpiryTime passed

as
/*********************************************************************************************************************************
Sproc    : Person Mailing Preference Upsert
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : Procedure called by through sf.Form#Post to insert and update person mailing preference records
----------------------------------------------------------------------------------------------------------------------------------
History		: Author	  				| Month Year	| Change Summary
					: ----------------- + ----------- + ------------------------------------------------------------------------------------
					: Tim Edlund				| Jul 2018		|	Initial version (revised from version originally developed by Russ Poirier)

Comments	
--------
This procedure handles writing data from the email consent form area of profile update forms to the database.  The target
table is sf.PersonMailingPreference.

In order to establish whether the email consent being passed already exists in the database, the lookup will be performed based
on the PersonSID and MailingPreferenceSID passed in if neither is null, or, the GUID from the form row is used.  If an existing 
record is not found, then one is inserted and the RowGUID passed in is written to the RowGUID column on the new record.

The procedure returns the primary key of the person mailing preference record inserted or updated as an output 
variable (optional).

Known Limitations
-----------------
The GUID value provided by the sub-form must be unique in the target table.  If this is not the case a duplicate key error
will occur.  This procedure cannot be called in non-sub-form contexts.

Example
-------
<TestHarness>
  <Test Name = "Random" IsDefault ="true" Description="Finds a non-expired records at random, expires it and re-enables it.">
    <SQLScript>
      <![CDATA[
declare
	@personMailingPreferenceSID int																			-- key value of record inserted or updated
 ,@rowGUID										nvarchar(50)														-- pass sub-form ID here
 ,@personSID									int
 ,@mailingPreferenceSID				int
 ,@expiryTime									datetime = dateadd(day, -1, sf.fNow()); -- set expiry time to yesterday 

select top (1)
	@rowGUID										= pmp.RowGUID
 ,@personMailingPreferenceSID = pmp.PersonMailingPreferenceSID
 ,@personSID									= pmp.PersonSID
 ,@mailingPreferenceSID				= pmp.MailingPreferenceSID
from
	sf.PersonMailingPreference pmp
where
	pmp.ExpiryTime is null and pmp.EffectiveTime < @expiryTime
order by
	newid();	-- find an existing record at random that is not expired

if @@rowcount = 0 or @rowGUID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	begin transaction; -- avoid making any permanent changes to the database

	exec sf.pPersonMailingPreference#Upsert
		@RowGUID = @rowGUID -- test looking up by rowguid
	 ,@ExpiryTime = @expiryTime
	 ,@IsActive = 0
	 ,@PersonMailingPreferenceSID = @personMailingPreferenceSID output;

	select
		pmp.PersonMailingPreferenceSID
	 ,pmp.MailingPreferenceSID
	 ,pmp.PersonSID
	 ,pmp.EffectiveTime
	 ,pmp.ExpiryTime	-- this value should not be null!
	 ,pmp.RowGUID
	 ,(case when pmp.PersonMailingPreferenceSID = @personMailingPreferenceSID then 'UPDATED ROW' else 'Pre-existing' end) Comment
	from
		sf.PersonMailingPreference pmp
	where
		pmp.PersonSID = @personSID
	order by
		pmp.PersonMailingPreferenceSID desc;

	-- now update the row again to active

	exec sf.pPersonMailingPreference#Upsert
		@PersonSID = @personSID
	 ,@MailingPreferenceSID = @mailingPreferenceSID
	 ,@expiryTime = null
	 ,@IsActive = 1;

	select
		pmp.PersonMailingPreferenceSID
	 ,pmp.MailingPreferenceSID
	 ,pmp.PersonSID
	 ,pmp.EffectiveTime
	 ,pmp.ExpiryTime	-- this value should null!
	 ,pmp.RowGUID
	 ,(case when pmp.PersonMailingPreferenceSID = @personMailingPreferenceSID then 'UPDATED ROW' else 'Pre-existing' end) Comment
	from
		sf.PersonMailingPreference pmp
	where
		pmp.PersonSID = @personSID
	order by
		pmp.PersonMailingPreferenceSID desc;

	if @@trancount = 1 and xact_state() = 1
	begin
		rollback;
	end;

end;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="NotEmptyResultSet" ResultSet="2"/>
      <Assertion Type="ExecutionTime" Value="00:00:04"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName			= 'sf.pPersonMailingPreference#Upsert'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo	 int					 = 0											-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText nvarchar(4000)													-- message text for business rule errors
	 ,@tranCount int					 = @@trancount						-- determines whether a wrapping transaction exists
	 ,@sprocName nvarchar(128) = object_name(@@procid)	-- name of currently executing procedure
	 ,@xState		 int;																		-- error state detected in catch block

	set @PersonMailingPreferenceSID = @PersonMailingPreferenceSID; -- initialize output parameters in all code paths (analysis validation)

	begin try

		-- use a transaction so that any additional updates implemented through the extended
		-- procedure or through table-specific logic succeed or fail as a logical unit

		if @tranCount = 0 -- no outer transaction
		begin
			begin transaction;
		end;
		else -- outer transaction so create save point
		begin
			save transaction @sprocName;
		end;

		-- check parameters

		if @RowGUID is null and
												(
													@PersonSID is null and @MailingPreferenceSID is null
												)
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = 'RowGUID/PersonSID + PreferenceSID';

			raiserror(@errorText, 18, 1);
		end;

		-- look for existing record

		if @PersonSID is not null and @MailingPreferenceSID is not null -- look up by person and preference where provided
		begin

			select
				@PersonMailingPreferenceSID = pmp.PersonMailingPreferenceSID
			 ,@EffectiveTime							= isnull(@EffectiveTime, pmp.EffectiveTime)
			from
				sf.PersonMailingPreference pmp
			where
				pmp.PersonSID = @PersonSID and pmp.MailingPreferenceSID = @MailingPreferenceSID;

		end;
		else -- lookup by the rowguid and retrieve parameters that may not have been provided
		begin

			select
				@PersonMailingPreferenceSID = PersonMailingPreferenceSID
			 ,@PersonSID									= isnull(@PersonSID, pmp.PersonSID)
			 ,@MailingPreferenceSID				= isnull(@MailingPreferenceSID, pmp.MailingPreferenceSID)
			 ,@EffectiveTime							= isnull(@EffectiveTime, pmp.EffectiveTime)
			from
				sf.PersonMailingPreference pmp
			where
				pmp.RowGUID = @RowGUID;

		end;

		if @PersonMailingPreferenceSID is null -- record does not exist or is being re-enabled, add it
		begin

			exec sf.pPersonMailingPreference#Insert
				@PersonMailingPreferenceSID = @PersonMailingPreferenceSID output
			 ,@PersonSID = @PersonSID
			 ,@MailingPreferenceSID = @MailingPreferenceSID
			 ,@EffectiveTime = @EffectiveTime
			 ,@ExpiryTime = @ExpiryTime
			 ,@IsActive = @IsActive;

		end;
		else -- otherwise record was found so update existing row
		begin

			exec sf.pPersonMailingPreference#Update
				@PersonMailingPreferenceSID = @PersonMailingPreferenceSID
			 ,@PersonSID = @PersonSID
			 ,@MailingPreferenceSID = @MailingPreferenceSID
			 ,@EffectiveTime = @EffectiveTime
			 ,@ExpiryTime = @ExpiryTime
			 ,@IsActive = @IsActive;

		end;

		if @tranCount = 0 and xact_state() = 1
		begin
			commit transaction;
		end;

	end try
	begin catch
		set @xState = xact_state();

		if @tranCount > 0 and @xState = 1
		begin
			rollback transaction @sprocName; -- committable wrapping trx exists: rollback to savepoint
		end;
		else if @xState <> 0 -- full rollback
		begin
			rollback;
		end;

		exec @errorNo = sf.pErrorRethrow; -- process message text and re-throw the error
	end catch;

	return (@errorNo);
end;
GO
