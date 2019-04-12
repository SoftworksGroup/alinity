SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sf.pDB#SetSGILogins
as
/*********************************************************************************************************************************
Procedure	: Set Softworks Group Inc Logins
Notice		: Copyright © 2017 Softworks Group Inc. 
Summary		: Adds logins to the sf.ApplicationUser table for current SGI staff and testers
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-------------------------------------------------------------------------------------------
					: Tim Edlund	| Nov 2017		|	Initial version 
					: Tim Edlund	| Jun 2018		| Added logic to delete former employee application user and person records
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
** DROP THIS PROCEDURE FROM PRODUCTION INSTANCES **

This procedure is intended for use on staging instances only.  It checks for the existence of Softworks staff and testing
login profiles on the current database's sf.ApplicationUser table.  Where logins are missing, they are added and assigned
System Administrator rights.  The password for all accounts created is the same:  "sgi@01374".

Maintenance Note
----------------
To change the staff list update the insert statement to the @work table in the code below.

------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo						int							= 0								-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText					nvarchar(4000)										-- message text (for business rule errors)  
	 ,@ON									bit							= cast(1 as bit)	-- constant for bit comparisons = 1
	 ,@serverName					varchar(50)			= @@servername		-- name of server
	 ,@personSID					int																-- key of person record added
	 ,@applicationUserSID int																-- key of application user record added
	 ,@saGrantSID					int																-- key of the sys admin grant
	 ,@firstName					nvarchar(30)											-- variables to hold profile values:
	 ,@lastName						nvarchar(35)
	 ,@userName						nvarchar(75)
	 ,@passwordString			varchar(15)
	 ,@emailAddress				varchar(150)
	 ,@rowGUID						uniqueidentifier									-- used as hash key for pwd encryption
	 ,@maxRows						int																-- loop limit
	 ,@i									int;															-- loop index

	declare @work table
	(
		ID						 int					identity(1, 1)
	 ,FirstName			 nvarchar(30) not null
	 ,LastName			 nvarchar(35) not null
	 ,UserName			 nvarchar(75) not null
	 ,PasswordString varchar(15)	not null default 'sgi@10374'
	);

	begin try

		if @serverName not like '%STGDB%' and @serverName not like '%Dev'
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'InvalidServer'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 operation is only permitted on staging and development servers. The procedure cannot be executed on server "%2"'
			 ,@Arg1 = 'Set-To-Mailinator'
			 ,@Arg2 = @serverName;

			raiserror(@errorText, 18, 1);

		end;

		-- lookup the SA grant 

		select
			@saGrantSID = ag.ApplicationGrantSID
		from
			sf.ApplicationGrant ag
		where
			ag.ApplicationGrantSCD = 'ADMIN.SYSADMIN';

		if @saGrantSID is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'sf.ApplicationGrant'
			 ,@Arg2 = 'ADMIN.SYSADMIN';

			raiserror(@errorText, 18, 1);
		end;

		-- load the work table with current staff and testing ID's

		insert
			@work (FirstName, LastName, UserName)
		values
			('Tim', 'Edlund', 'tim.e@softworks.ca')
		 ,('Kris', 'Dawson', 'kris.d@softworks.ca')
		 ,('Cory', 'Ng', 'cory.n@softworks.ca')
		 ,('Taylor', 'Napier', 'taylor.n@softworks.ca')
		 ,('Russell', 'Poirier', 'russell.p@softworks.ca')
		 ,('David', 'Campbell', 'david.c@softworks.ca')
		 ,('Karun', 'Kakulphimp', 'karun.k@softworks.ca')
		 ,('Anita', 'Antony', 'anita.a@softworks.ca');

		select @maxRows	 = count(1) from @work w ;
		set @i = 0;

		while @i < @maxRows
		begin

			set @i += 1;

			select
				@firstName			= w.FirstName
			 ,@lastName				= w.LastName
			 ,@userName				= w.UserName
			 ,@passwordString = w.PasswordString
			 ,@emailAddress		= cast(w.UserName as varchar(150))
			from
				@work w
			where
				w.ID = @i;

			if not exists
			(
				select 1 from		sf.ApplicationUser au where au.UserName = @userName
			) -- avoid adding the profile if it already exists
			begin

				exec sf.pPerson#Insert
					@PersonSID = @personSID output
				 ,@FirstName = @firstName
				 ,@LastName = @lastName
				 ,@PrimaryEmailAddress = @emailAddress;

				exec sf.pApplicationUser#Insert
					@ApplicationUserSID = @applicationUserSID output
				 ,@PersonSID = @personSID
				 ,@UserName = @userName;

				exec sf.pApplicationUserGrant#Insert
					@ApplicationUserSID = @applicationUserSID
				 ,@ApplicationGrantSID = @saGrantSID;

				select
					@rowGUID = au.RowGUID
				from
					sf.ApplicationUser au
				where
					au.ApplicationUserSID = @applicationUserSID;

				update
					sf.ApplicationUser
				set
					GlassBreakPassword = sf.fHashString(cast(@rowGUID as nvarchar(50)), @passwordString)
				where
					ApplicationUserSID = @applicationUserSID;

				if @@rowcount = 1
				begin
					print 'ok - created login: ' + @userName + '/' + @passwordString;
				end;

			end;

		end;

		-- remove access for former SGI staff who 
		-- remain in the database
		
		delete
		sf.ApplicationUserSession -- delete associated login sessions
		where
			ApplicationUserSID in
			(
				select
					au.ApplicationUserSID
				from
					sf.ApplicationUser au
				left outer join
					@work							 w on au.UserName = w.UserName
				where
					au.UserName like '%@softworks.ca' and w.UserName is null	
			);

		set @applicationUserSID = null;

		select top (1)
			@applicationUserSID = au.ApplicationUserSID
		from
			sf.ApplicationUser au
		join
			@work							 w on au.UserName = w.UserName
		where
			au.UserName like '%@softworks.ca'
		order by 
			newid();

		if @applicationUserSID is not null
		begin

			update	-- re-assign any groups to another softworks user
				x
			set
				x.ApplicationUserSID = @applicationUserSID
			from
				sf.ApplicationUser au
			join
				sf.PersonGroup		 x on au.ApplicationUserSID = x.ApplicationUserSID
			left outer join
				@work							 w on au.UserName						 = w.UserName
			where
				au.UserName like '%@softworks.ca' and w.UserName is null;

			update	-- re-assign any forms to another softworks user
				x
			set
				x.ApplicationUserSID = @applicationUserSID
			from
				sf.ApplicationUser au
			join
				sf.Form		 x on au.ApplicationUserSID = x.ApplicationUserSID
			left outer join
				@work							 w on au.UserName						 = w.UserName
			where
				au.UserName like '%@softworks.ca' and w.UserName is null;

			delete
			au
			from
				sf.ApplicationUser au
			left outer join
				@work							 w on au.UserName = w.UserName
			where
				au.UserName like '%@softworks.ca' and w.UserName is null; -- delete the login

			print 'ok - ' + ltrim(@@rowcount) + ' previous Softworks user record(s) deleted';

		end

		delete
		p
		from
		(
			select
				p.PersonSID
			from
				sf.Person							p
			join
				sf.PersonEmailAddress pea on p.PersonSID		= pea.PersonSID and pea.IsPrimary = @ON
			left outer join
				@work									w on pea.EmailAddress = w.UserName
			where
				pea.EmailAddress like '%@softworks.ca' and w.UserName is null
		)						x
		join
			sf.Person p on x.PersonSID = p.PersonSID
		where
			sf.fPerson#IsDeleteEnabled(p.PersonSID) = @ON;	-- only delete the person record if no other dependencies exist

		print 'ok - ' + ltrim(@@rowcount) + ' previous Softworks person record(s) deleted';

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);

end;
GO
