SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pOrgContact#Upsert]
	@RowGUID								uniqueidentifier					-- pass sub-form ID here - used to determine if NEW row or UPDATE
 ,@OrgContactSID					int								output	-- new PK value of the record if inserted - otherwise the key of the row updated (do NOT pass)
 ,@OrgSID									int												-- key of the organization to add or update a contact record for
 ,@PersonSID							int												-- key of the organization to add or update a contact record for
 ,@EffectiveTime					datetime					= null	-- date (and time) when the relationship with the org started - defaults to current time in user timezone
 ,@ExpiryTime							datetime					= null	-- when the relationship with the org ends
 ,@IsAdminContact					bit								= 0			-- set to 1 to have the contact appear for selection in mailings to the org, and for general contact
 ,@TagList								xml								= null	-- default: CONVERT(xml,N'<Tags/>')
 ,@ChangeLog							xml								= null	-- default: CONVERT(xml,'<Changes />')
 ,@UserDefinedColumns			xml								= null
 ,@OrgContactXID					varchar(150)			= null
 ,@LegacyKey							nvarchar(50)			= null
 ,@ParentOrgSID						int								= null	-- not a base table column (default ignored)
 ,@OrgTypeSID							int								= null	-- not a base table column (default ignored)
 ,@OrgName								nvarchar(150)			= null	-- not a base table column (default ignored)
 ,@OrgLabel								nvarchar(35)			= null	-- not a base table column (default ignored)
 ,@StreetAddress1					nvarchar(75)			= null	-- not a base table column (default ignored)
 ,@StreetAddress2					nvarchar(75)			= null	-- not a base table column (default ignored)
 ,@StreetAddress3					nvarchar(75)			= null	-- not a base table column (default ignored)
 ,@CitySID								int								= null	-- not a base table column (default ignored)
 ,@PostalCode							varchar(10)				= null	-- not a base table column (default ignored)
 ,@RegionSID							int								= null	-- not a base table column (default ignored)
 ,@Phone									varchar(25)				= null	-- not a base table column (default ignored)
 ,@Fax										varchar(25)				= null	-- not a base table column (default ignored)
 ,@WebSite								varchar(250)			= null	-- not a base table column (default ignored)
 ,@IsEmployer							bit								= null	-- not a base table column (default ignored)
 ,@IsCredentialAuthority	bit								= null	-- not a base table column (default ignored)
 ,@OrgIsActive						bit								= null	-- not a base table column (default ignored)
 ,@IsAdminReviewRequired	bit								= null	-- not a base table column (default ignored)
 ,@LastVerifiedTime				datetimeoffset(7) = null	-- not a base table column (default ignored)
 ,@OrgRowGUID							uniqueidentifier	= null	-- not a base table column (default ignored)
 ,@GenderSID							int								= null	-- not a base table column (default ignored)
 ,@NamePrefixSID					int								= null	-- not a base table column (default ignored)
 ,@FirstName							nvarchar(30)			= null	-- not a base table column (default ignored)
 ,@CommonName							nvarchar(30)			= null	-- not a base table column (default ignored)
 ,@MiddleNames						nvarchar(30)			= null	-- not a base table column (default ignored)
 ,@LastName								nvarchar(35)			= null	-- not a base table column (default ignored)
 ,@BirthDate							date							= null	-- not a base table column (default ignored)
 ,@DeathDate							date							= null	-- not a base table column (default ignored)
 ,@HomePhone							varchar(25)				= null	-- not a base table column (default ignored)
 ,@MobilePhone						varchar(25)				= null	-- not a base table column (default ignored)
 ,@IsTextMessagingEnabled bit								= null	-- not a base table column (default ignored)
 ,@ImportBatch						nvarchar(100)			= null	-- not a base table column (default ignored)
 ,@PersonRowGUID					uniqueidentifier	= null	-- not a base table column (default ignored)
 ,@IsActive								bit								= null	-- not a base table column (default ignored)
 ,@IsPending							bit								= null	-- not a base table column (default ignored)
 ,@IsDeleteEnabled				bit								= null	-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pOrgContact#Upsert
Notice    : Copyright © 2017 Softworks Group Inc.
Summary   : Inserts or updates the organization contact based on the organization and person keys passed in
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund	| Sep	2017			|	Initial version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This procedure is a wrapper for the #Insert and #Update procedures on the table. The procedure is called during form processing 
(from sf.pForm#Post) to save values on new org-contact or employment records. Some renewal form configuration may wish to 
maintain an updateable table of employers for an individual which include starting and ending dates of employment.  These
values are not required for typical reporting but may be optionally configured through this table which is independent of
dbo.RegistrantEmployment where hours are reported. 

The procedure calls the #Insert sproc when the combination of @OrgSID and @PersonSID is not found, or it is found but only
on an expired record (expiry date is filled in and before the current time).  If a record is found, it the #Update procedure 
on the table is called, otherwise #Insert is called.

Form Design
-----------
When configuring renewal forms that include effective and expiry dates, join to dbo.OrgContact on the dblink setup for
dbo.RegistrantEmployment.  This will populate the effective time value where it exists.  Another dblink must be created for
dbo.OrgContact and established as an UPSERT type in order to see that this procedure is called.
-------------------------------------------------------------------------------------------------------------------------------- */
set nocount on;

begin
	declare
		@errorNo	 int					 = 0								-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText nvarchar(4000)										-- message text (for business rule errors)
	 ,@blankParm varchar(50)											-- tracks blank parameter names
	 ,@ON				 bit					 = cast(1 as bit)		-- constant for bit comparison and assignments
	 ,@OFF			 bit					 = cast(0 as bit);	-- constant for bit comparison and assignments

	set @OrgContactSID = null; -- populate output parameter in all code paths

	begin try

		-- check parameters
		
		if @RowGUID	is null set @blankParm = 'RowGUID'					
		if @PersonSID is null set @blankParm = 'PersonSID';
		if @OrgSID is null set @blankParm = 'OrgSID';

		if @blankParm is not null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = @blankParm;

			raiserror(@errorText, 18, 1);

		end;

		if not exists (select 1 from	sf.Person p where p.PersonSID = @PersonSID)
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'sf.Person'
			 ,@Arg2 = @PersonSID;

			raiserror(@errorText, 18, 1);
		end;

		if not exists (select 1 from	dbo.Org o where o.OrgSID = @OrgSID)
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'dbo.Org'
			 ,@Arg2 = @OrgSID;

			raiserror(@errorText, 18, 1);
		end;

		select
			@OrgContactSID = oc.OrgContactSID
		from
			dbo.OrgContact oc
		where
			oc.RowGUID = @RowGUID;

		if @OrgContactSID is not null
		begin

			exec dbo.pOrgContact#Update
				@OrgContactSID = @OrgContactSID
			 ,@EffectiveTime = @EffectiveTime -- if this is NULL sproc will re-assign current value
			 ,@ExpiryTime = @ExpiryTime
			 ,@IsAdminContact = @IsAdminContact;

			update -- update the row GUID on the new row to the sub-form ID value passed in
				dbo.OrgContact
			set
				RowGUID = @RowGUID
			where
				OrgContactSID = @OrgContactSID;

		end;
		else
		begin

			exec dbo.pOrgContact#Insert
				@OrgContactSID = @OrgContactSID output
			 ,@OrgSID = @OrgSID
			 ,@PersonSID = @PersonSID
			 ,@EffectiveTime = @EffectiveTime
			 ,@ExpiryTime = @ExpiryTime
			 ,@IsAdminContact = @IsAdminContact;

		end;
	end try
	begin catch
		if @@trancount > 0 rollback;

		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);
end;
GO
