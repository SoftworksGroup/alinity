SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pRegistrant#Lookup
	@RegistrantNo		 varchar(50)	-- registrant number to lookup
 ,@LastNameToMatch nvarchar(35) -- alternate lookup key to (sf) Person
 ,@EmailAddress		 varchar(150) -- alternate lookup key to (sf) Person
 ,@FirstName			 nvarchar(30) -- alternate lookup key to (sf) Person (with last name + birthdate)
 ,@BirthDate			 date					-- alternate lookup key to (sf) Person (with first name + birthdate)
 ,@LegacyKey			 nvarchar(50) -- legacy key of either (sf) Person or (dbo) Registrant 
 ,@PersonSID			 int output		-- key of person record found
 ,@RegistrantSID	 int output		-- key of registrant record found - if any
as
/*********************************************************************************************************************************
Procedure	: Lookup Registrant (and Person)
Notice		: Copyright © 2019 Softworks Group Inc. 
Summary		: Subroutine to lookup a(n) PersonSID and RegistrantSID based on an identifiers passed in 
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Apr 2019		|	Initial version

Comments
--------
This procedure is used when processing staged data. It attempts to find a primary key value for the sf.Person and dbo.Registrant 
tables based on identifiers passed in.  The identifiers include the @RegistrantNo and @LegacyKey - which are unique identifiers,
and, the first, last and birthdate values which can be used in combination to locate a record.  The @PersonSID key can be passed 
explicitly if available as another method to lookup/check-for a Registrant record.

Note that the procedure verifies the lookup with the @LastNameToMatch parameter which is always required. Where a value is looked 
up successfully using identifiers other than the last name, the last name is compared to the record found to ensure there is a
match.  If a match is not found, then an error is raised.

For the lookup based on last name + first name + birth date, both the first-name and common-name fields are checked for the
@FirstName parameter value.

No Record Found
---------------
It is possible, and expected, that the values provided will not result in a record being found in the (sf) Person or (dbo) 
Registrant table.  The caller is responsible for checking the output parameters and either raise an error if a successful lookup 
was required, or, to add the record if new record insertions are a supported option in the caller.

Add-on-the-fly NOT supported
----------------------------
Where a record is not found through the lookup, it will not be added.  Person and Registrant records must be created by the 
caller. 

Example:
--------
<TestHarness>
	<Test Name="Random" IsDefault="true" Description="Calls lookup procedure to find by registrant number.">
		<SQLScript>
			<![CDATA[
declare
	@registrantNo		 varchar(50)
 ,@lastNameToMatch nvarchar(35)
 ,@firstName			 nvarchar(30)
 ,@birthDate			 date
 ,@legacyKey			 nvarchar(50)
 ,@personSID			 int
 ,@registrantSID	 int;

select top (1)
	@registrantNo		 = r.RegistrantNo
 ,@lastNameToMatch = p.LastName
from
	dbo.Registrant r
join
	sf.Person			 p on r.PersonSID = p.PersonSID
order by
	newid();

if @@rowcount = 0 or @registrantNo is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin
	exec dbo.pRegistrant#Lookup
		@RegistrantNo = @registrantNo
	 ,@LastNameToMatch = @lastNameToMatch
	 ,@FirstName = @firstName
	 ,@BirthDate = @birthDate
	 ,@LegacyKey = @legacyKey
	 ,@PersonSID = @personSID output					-- key of person record found
	 ,@RegistrantSID = @registrantSID output; -- key of registrant record found - if any

	select
		@registrantNo	 [@RegistrantNo]
	 ,@personSID		 [@PersonSID]
	 ,@registrantSID [@RegistrantSID];
end;
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:01" />
		</Assertions>
	</Test>
	<Test Name="ByName" Description="Calls lookup procedure to find by name and birth date.">
		<SQLScript>
			<![CDATA[
declare
	@registrantNo		 varchar(50)
 ,@lastNameToMatch nvarchar(35)
 ,@firstName			 nvarchar(30)
 ,@birthDate			 date
 ,@legacyKey			 nvarchar(50)
 ,@personSID			 int
 ,@registrantSID	 int;

select top (1)
	@firstName			 = p.FirstName 
 ,@birthDate			 = p.BirthDate
 ,@lastNameToMatch = p.LastName
from
	dbo.Registrant r
join
	sf.Person			 p on r.PersonSID = p.PersonSID
where
	p.BirthDate is not null
order by
	newid();

if @@rowcount = 0 or @birthDate is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin
	exec dbo.pRegistrant#Lookup
		@RegistrantNo = @registrantNo
	 ,@LastNameToMatch = @lastNameToMatch
	 ,@FirstName = @firstName
	 ,@BirthDate = @birthDate
	 ,@LegacyKey = @legacyKey
	 ,@PersonSID = @personSID output					-- key of person record found
	 ,@RegistrantSID = @registrantSID output; -- key of registrant record found - if any

	select
		@firstName			 [@firstName]
	 ,@lastNameToMatch [@LastNameToMatch]
	 ,@birthDate			 [@birthDate]
	 ,@personSID			 [@PersonSID]
	 ,@registrantSID	 [@RegistrantSID];
end;
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:01" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pRegistrant#Lookup'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */
begin
	set nocount on;

	declare
		@errorNo	 int					 = 0							-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText nvarchar(4000)									-- message text (for business rule errors)
	 ,@ON				 bit					 = cast(1 as bit) -- constant for bit comparisons = 1
	 ,@lastName	 nvarchar(35);									-- last name on record looked up to check for match 

	set @PersonSID = @PersonSID; -- may be passed as in/out parameter;
	set @RegistrantSID = @RegistrantSID;

	begin try

		-- check parameters
		set @LastNameToMatch = ltrim(rtrim(@LastNameToMatch));
		set @LegacyKey = ltrim(rtrim(@LegacyKey));

		if @LastNameToMatch is null
		begin
			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = 'LastNameToMatch';

			raiserror(@errorText, 18, 1);
		end;

		if @PersonSID is null
			 and @RegistrantSID is null
			 and @LegacyKey is null
			 and @RegistrantNo is null
			 and @EmailAddress is null
			 and (@FirstName is null or @BirthDate is null)
		begin
			exec sf.pMessage#Get
				@MessageSCD = 'InsufficientLookupParameters'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'Not enough parameters were provided to lookup the %1 record. The minimum values required: %2'
			 ,@Arg1 = 'Person and Registrant'
			 ,@Arg2 = 'Registrant# or Email Address or Last Name + First Name + Date-of-Birth or Legacy Key or System Identifier'

			raiserror(@errorText, 18, 1);
		end;

		-- lookup the identifiers; starting with legacy key where provided
		if @PersonSID is null and @LegacyKey is not null
		begin
			select @PersonSID	 = p.PersonSID from sf.Person p where p.LegacyKey = @LegacyKey;
		end;

		if @RegistrantSID is null and @LegacyKey is not null
		begin
			select
				@RegistrantSID = r.RegistrantSID
			from
				dbo.Registrant r
			where
				r.LegacyKey = @LegacyKey;
		end;

		-- next lookup by reg# where provided
		if @RegistrantSID is null and @RegistrantNo is not null
		begin
			select
				@RegistrantSID = r.RegistrantSID
			from
				dbo.Registrant r
			where
				r.RegistrantNo = @RegistrantNo;
		end;

		-- use registrant key to locate person
		if @RegistrantSID is not null and @PersonSID is null
		begin
			select
				@PersonSID = r.PersonSID
			from
				dbo.Registrant r
			where
				r.RegistrantSID = @RegistrantSID;
		end;

		-- alternate lookup on person: by email address
		if @PersonSID is null and @EmailAddress is not null
		begin
			select
				@PersonSID = p.PersonSID
			from
				sf.Person							p
			join
				sf.PersonEmailAddress pea on p.PersonSID = pea.PersonSID and pea.IsActive = @ON
			where
				pea.EmailAddress = @EmailAddress;
		end;

		-- alternate lookup on person: by name and birthdate
		if @PersonSID is null and @FirstName is not null and @BirthDate is not null
		begin
			select
				@PersonSID = p.PersonSID
			from
				sf.Person p
			where
				p.LastName = @LastNameToMatch and p.BirthDate = @BirthDate and (p.FirstName = @FirstName or p.CommonName = @FirstName);
		end;

		-- use person key to locate registrant
		if @PersonSID is not null and @RegistrantSID is null
		begin
			select
				@RegistrantSID = r.RegistrantSID
			from
				dbo.Registrant r
			where
				r.PersonSID = @PersonSID;
		end;

		-- where person is found ensure name matches the one provided
		if @PersonSID is not null
		begin
			select @lastName = p .LastName from sf.Person p where p.PersonSID = @PersonSID;

			if @lastName is null
			begin
				exec sf.pMessage#Get
					@MessageSCD = 'RecordNotFound'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
				 ,@Arg1 = 'sf.Person'
				 ,@Arg2 = @PersonSID;

				raiserror(@errorText, 16, 1);
			end;

			if @LastNameToMatch <> @lastName
			begin
				exec sf.pMessage#Get
					@MessageSCD = 'Mismatch'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The %1 found does not match the %2 provided: "%3" vs "%4". Update the %2 in the source data and/or check for mismatched values.'
				 ,@Arg1 = 'person record'
				 ,@Arg2 = 'name'
				 ,@Arg3 = @lastName
				 ,@Arg4 = @LastNameToMatch;

				raiserror(@errorText, 16, 1);
			end;
		end;

		-- finally where both keys are found or provided
		-- ensure they point to same person
		if @PersonSID is not null and @RegistrantSID is not null
		begin
			if not exists
			(
				select
					1
				from
					dbo.Registrant r
				where
					r.RegistrantSID = @RegistrantSID and r.PersonSID = @PersonSID
			)
			begin
				exec sf.pMessage#Get
					@MessageSCD = 'RegPersonKeyConflict'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The person identified on the registration record (key=%1) does does not match the person record found (key= %2).'
				 ,@Arg1 = @RegistrantSID
				 ,@Arg2 = @PersonSID;

				raiserror(@errorText, 18, 1);
			end;
		end;
	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);
end;
GO
