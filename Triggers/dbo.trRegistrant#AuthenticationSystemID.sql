SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [trRegistrant#AuthenticationSystemID]
on dbo.Registrant
after insert, update
as
/*********************************************************************************************************************************
Table   : dbo.Registrant (after INSERT or UPDATE trigger)
Notice  : Copyright © 2017 Softworks Group Inc.
Summary : Updates the AuthenticationSystemID column in the ApplicationUser table with the current RegistrantNo

Comments
--------
This trigger ensures that current RegistrantNo is set into the AuthenticationSystemID column in application user.  This is done
to allow end users to enter their registrant-no as an alternative to their email address for logging in.  Whenever a change to 
the registrant no is detected, this trigger ensures the updated value is copied into the AuthenticationSystemID in their
user profile.

-------------------------------------------------------------------------------------------------------------------------------- */

begin

	if @@rowcount = 0 or trigger_nestlevel(@@procid) > 1 return

	set nocount on

	declare
			@errorNo                            int = 0													-- 0 no error, <50000 SQL error, else business rule
		,	@errorText                          nvarchar(4000)									-- message text (for business rule errors)
		,	@ON																	bit = cast(1 as bit)						-- constant to avoid multiple casts
		,	@OFF																bit = cast(0 as bit)						-- constant to avoid multiple casts
		,	@maxRow															int															-- loop limit - rows to process
		,	@i																	int	= 0													-- next row to process
		,	@pKey																int															-- next primary key value to process
		,	@oldRegistrantNo										nvarchar(50)										-- old RegistrantNo (deleted row)	
		,	@newRegistrantNo										nvarchar(50)										-- new RegistrantNo (inserted row)

	declare
		@work																	table
	(
			ID																	int					identity(1,1)
		,	PKey																int					not null
	)

	-- load work table with updated records
	-- and process each

	insert @work (PKey) select i.RegistrantSID from inserted	i
	set @maxRow = @@rowcount
	set @i = 0

	while @i < @maxRow
	begin

		set @i += 1
		set @newRegistrantNo = null
		set @oldRegistrantNo = null

		select
				@pKey	= w.PKey
		from
			@work w
		where
			w.ID = @i

		-- check if RegistrantNo has changed

		select 
				@oldRegistrantNo	= d.RegistrantNo 
		from 
			deleted		d 
		where 
			d.RegistrantSID = @pKey

		select 
				@newRegistrantNo	= i.RegistrantNo 
		from 
			inserted	i 
		where 
			i.RegistrantSID = @pKey

		if isnull(@oldRegistrantNo,'x') <> isnull(@newRegistrantNo, 'y')
		begin

			-- changes are detected so update the application user
			-- record if one exists for the associated person SID

			update
				au
			set
				au.AuthenticationSystemID = @newRegistrantNo
			from
				@work								w
			join
				dbo.Registrant			r	 on w.PKey = r.RegistrantSID
			join
				sf.ApplicationUser	au on r.PersonSID = au.PersonSID
			where
				w.ID = @i

		end
	
	end

end
GO
