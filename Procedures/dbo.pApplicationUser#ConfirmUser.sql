SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pApplicationUser#ConfirmUser
(
	@PersonEmailMessageGUID uniqueidentifier				-- identifier of the email message being confirmed
 ,@AppPassword						varbinary(8000) = null	-- password of the user
 ,@GenderSID							int = null							-- the key of the gender
 ,@BirthDate							date = null							-- the birth date
 ,@HomePhone							varchar(25) = null			-- the home phone
 ,@MobilePhone						varchar(25) = null			-- the mobile phone
 ,@IsTextMessagingEnabled bit = null							-- indicates if the user wants to be notified via SMS
 ,@FirstName							nvarchar(30) = null			-- the first name
 ,@LastName								nvarchar(30) = null			-- the last name
)
as
/*********************************************************************************************************************************
Procedure: Application User - Confirm user (account)
Notice   : Copyright © 2015 Softworks Group Inc.
Summary  : Confirms the email and activates the user referenced in the email
----------------------------------------------------------------------------------------------------------------------------------
History	 : Author							 | Month Year	 | Change Summary
				 : ------------------- + ----------- + -----------------------------------------------------------------------------------
 				 : Cory Ng						 | May 2016		 | Initial version
				 : Cory Ng						 | Sep 2016		 | Added IsTextMessageEnabled as a parameter
				 : Tim Edlund					 | Mar 2019		 | Documentation and format updated to latest standards

Comments
--------					
This procedure is used to confirm an email-based user account. The procedure is invoked after the user has clicked a link 
confirming their email address and establishing a password. The application user must already be created and all grants that 
should be activated on confirmation should have been created as well with the effective and expiry times set. The user is created in 
an "inactive" status, and this procedure activates them when confirmed. 

Example:
--------
Run the process from the user interface to test.
-------------------------------------------------------------------------------------------------------------------------------- */

begin
	set nocount on;

	declare
		@errorNo							 int					 = 0							-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText						 nvarchar(4000)									-- message text (for business rule errors)    
	 ,@blankParm						 varchar(50)										-- tracks if any required parameters are not provided     
	 ,@ON										 bit					 = cast(1 as bit) -- used on bit comparisons to avoid multiple casts
	 ,@personSID						 int														-- key of the person record
	 ,@applicationUserSID		 int														-- the key of the user being confirmed
	 ,@personEmailMessageSID int														-- the key of the message being confirmed
	 ,@registrantNo					 varchar(50);										-- available as an alternate login on some configurations

	begin try

		-- check parameters

		if @PersonEmailMessageGUID is null
			set @blankParm = 'PersonEmailMessageGUID';

		if @blankParm is not null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = @blankParm;

			raiserror(@errorText, 18, 1);

		end;

		-- get the details from the email record

		select
			@personEmailMessageSID = pem.PersonEmailMessageSID
		 ,@personSID						 = pem.PersonSID
		 ,@applicationUserSID		 = au.ApplicationUserSID
		 ,@FirstName						 = isnull(@FirstName, p.FirstName)
		 ,@LastName							 = isnull(@LastName, p.LastName)
		 ,@registrantNo					 = r.RegistrantNo
		from
			sf.PersonEmailMessage pem
		join
			sf.Person							p on pem.PersonSID	= p.PersonSID
		join
			sf.Gender							g on p.GenderSID		= g.GenderSID
		join
			sf.ApplicationUser		au on pem.PersonSID = au.PersonSID
		left outer join
			dbo.Registrant				r on p.PersonSID		= r.PersonSID
		where
			pem.RowGUID = @PersonEmailMessageGUID;

		if @@rowcount = 0
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'Person Email Message'
			 ,@Arg2 = @PersonEmailMessageGUID;

			raiserror(@errorText, 18, 1);

		end;

		exec sf.pPerson#Update
			@PersonSID = @personSID
		 ,@FirstName = @FirstName
		 ,@LastName = @LastName
		 ,@GenderSID = @GenderSID
		 ,@BirthDate = @BirthDate
		 ,@MobilePhone = @MobilePhone
		 ,@HomePhone = @HomePhone
		 ,@IsTextMessagingEnabled = @IsTextMessagingEnabled;

		-- activate the user and set their password

		exec sf.pApplicationUser#Update
			@ApplicationUserSID = @applicationUserSID
		 ,@AuthenticationSystemID = @registrantNo
		 ,@IsActive = @ON -- ensure account is activated to be ready for login
		 ,@GlassBreakPassword = @AppPassword;

		-- confirm the email message

		exec sf.pPersonEmailMessage#Update
			@PersonEmailMessageSID = @personEmailMessageSID -- update confirmed time on the email message record
		 ,@IsConfirmed = @ON;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);

end;
GO
