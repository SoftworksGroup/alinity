SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pSetup$SF#TextTemplate]
	@SetupUser nvarchar(75) -- user assigned to audit columns
 ,@Language	 char(2)			-- language to install for
 ,@Region		 varchar(10)	-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup sf.TextTemplate data
Notice   : Copyright © 2012 Softworks Group Inc.
Summary  : updates sf.TextTemaplte master table with starting values for the application
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Cory Ng			| Jun	2016			|	Initial Version
				 : Tim Edlund		| Dec 2017			| Updated for consistency with language used in email templates addressing same objectives
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------
This procedure is responsible for creating sample data in the sf.TextTemplate table. The data is only inserted if the table contains
no records.  Otherwise, the procedure makes no changes to the database.  The table will contain no records when the product
is first installed.

Keep in mind the pSetup (parent) procedure is run not only for installation, but also after each upgrade. This ensures any new
tables receive starting values. Tables like this one may be setup with whatever data makes sense to the end user and, therefore,
must not be modified during upgrades. This is achieved by avoiding execution if any records are found in the table. 


<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="If no records exist in the text template table we'll reseed the ident and run the setup sproc">
		<SQLScript>
		<![CDATA[
			delete from sf.TextTemplate
			dbcc checkident( 'sf.TextTemplate', reseed, 1000000) with NO_INFOMSGS
		
			exec dbo.pSetup$SF#TextTemplate
				 @SetupUser = 'system@alinityapp.com'
				,@Language = 'EN'
				,@Region = 'AB'

			select * from sf.TextTemplate

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$SF#TextTemplate'
	,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */

set nocount on;

begin

	declare
		@errorNo							int						= 0								-- 0 no error, if < 50000 SQL error, else business rule
	 ,@errorText						nvarchar(4000)									-- message text (for business rule errors)
	 ,@ON										bit						= cast(1 as bit)	-- constant for bit = 1
	 ,@OFF									bit						= cast(0 as bit)	-- constant for bit = 0
	 ,@applicationEntitySID int;														-- required for merge field(s) context

	begin try

		select
			@applicationEntitySID
		from
			sf.ApplicationEntity ae
		where
			ae.ApplicationEntitySCD = 'sf.vPerson';

		if not exists
		(
			select
				1
			from
				sf.TextTemplate et
			where
				et.TextTemplateLabel = 'Applicant Invitation'
		)
		begin

			insert
				sf.TextTemplate
			(
				TextTemplateLabel
			 ,PriorityLevel
			 ,Body
			 ,LinkExpiryHours
			 ,UsageNotes
			 ,ApplicationEntitySID
			 ,CreateUser
			)
			values
			(
				'Applicant Invitation', 1, N'Hi [@FirstName]. Click the link to complete your Alinity™ sign-up: http://[@@UserRegistration]', 48
			 ,'This is an invitation text template to send to new users to allow them to verify their email address', @applicationEntitySID, @SetupUser
			);

		end;

		if not exists
		(
			select
				1
			from
				sf.TextTemplate et
			where
				et.TextTemplateLabel = 'Supervisor Invitation'
		)
		begin

			insert
				sf.TextTemplate
			(
				TextTemplateLabel
			 ,PriorityLevel
			 ,Body
			 ,LinkExpiryHours
			 ,UsageNotes
			 ,ApplicationEntitySID
			 ,CreateUser
			)
			values
			(
				'Supervisor Invitation', 1, N'Hi [@FirstName]. Click the link to complete your Alinity™ supervisor sign-up: http://[@@UserRegistration]', 48
			 ,'This is an invitation text template to send to supervisors who have been invited to use Alinity.', @applicationEntitySID, @SetupUser
			);

		end;

		if not exists
		(
			select
				1
			from
				sf.TextTemplate et
			where
				et.TextTemplateLabel = 'Password Reset Confirmation'
		)
		begin

			insert
				sf.TextTemplate
			(
				TextTemplateLabel
			 ,PriorityLevel
			 ,Body
			 ,IsApplicationUserRequired
			 ,LinkExpiryHours
			 ,ApplicationEntitySID
			 ,UsageNotes
			)
			select
				'Password Reset Confirmation'
			 ,1
			 ,N'Hi [@FirstName]. To reset your Alinity™ password click the link (ignore if you did not request a password reset): http://[@@PasswordReset]'
			 ,@OFF
			 ,48
			 ,@applicationEntitySID
			 ,'This text template is used when user''s request a password reset. The template contains a link back to the application that will allow the user to change their password.';

		end;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);

end;
GO
