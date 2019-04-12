SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pRegistration#SetCardPrintedTime
	@Registrations	 xml							-- list of registrations to mark with as having card printed
 ,@CardPrintedTime datetime = null	-- time to record cards as being printed on the registrations (defaults to current time)
as
/*********************************************************************************************************************************
Procedure : Registration - Cancel Batch
Notice    : Copyright © 2018 Softworks Group Inc.
Summary   : Sets Card-Printed-Time on batch of dbo.Registration records
----------------------------------------------------------------------------------------------------------------------------------
History		: Author(s)  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Tim Edlund	| Sep 2018		|	Initial version

Comments	
--------
This procedure sets the Card-Printed-Time on (dbo) Registration records to the value provided. If no @CardPrintedTime is passed 
then the current time (in the user timezone) is applied.

The list of registration record primary keys to set the time for is passed in the XML parameter.  The procedure supports the 
multi-select mode in the UI where a query is run (e.g. "Cards not printed") and resulting records are pinned then the 
"Set card print date" action is applied against the set.

This list of records to process is identified using xml in the following format:

<Registrations>
		<Registration SID="1000001" />
		<Registration SID="1000011" />
		<Registration SID="1000123" />
</Registrations>

If a single registration is being processed, the pRegistration#Update procedure can be used instead.

Limitations
-----------
This procedure does not call the EF sproc pRegistration#Update.  All updates to the Card-Printed-Time column are processed as a 
single update statement.  Any custom logic reacting to the setting of the column in an extended version of the EF sproc will
NOT be executed since no sproc call occurs.

Example
-------

<TestHarness>
  <Test Name = "All" IsDefault ="true" Description="Returns all content from the view">
    <SQLScript>
      <![CDATA[
declare
	@registrationSID1 int
 ,@registrationSID2 int
 ,@now							datetime = sf.fNow()
 ,@registrations		xml			 = N'
<Registrations>
		<Registration SID="[1]" />
		<Registration SID="[2]" />
</Registrations>';

select top (1)
	@registrationSID1 = reg.RegistrationSID
from
	dbo.fRegistrant#LatestRegistration(-1, null) reg
where
	reg.IsActivePractice = 1 and reg.CardPrintedTime is null
order by 
  newid();

select top (1)
	@registrationSID2 = reg.RegistrationSID
from
	dbo.fRegistrant#LatestRegistration(-1, null) reg
where
	reg.IsActivePractice = 1 and reg.CardPrintedTime is null and reg.RegistrationSID <> @registrationSID1
order by 
  newid();

if @registrationSID1 is null or @registrationSID2 is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin
	set @registrations = cast(replace(replace(cast(@registrations as nvarchar(max)), '[1]', ltrim(@registrationSID1)), '[2]', ltrim(@registrationSID2)) as xml);

	exec dbo.pRegistration#SetCardPrintedTime
		@Registrations = @registrations
	 ,@CardPrintedTime = @now;

	select
		reg.RegistrationLabel
	from
		dbo.vRegistration reg
	where
		reg.CardPrintedTime = @now;

end;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:05"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pRegistration#SetCardPrintedTime'
	,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo		int							 = 0																			-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText	nvarchar(4000)																						-- message text (for business rule errors)
	 ,@blankParm	nvarchar(100)																							-- error checking buffer for required parameters
	 ,@updateTime datetimeoffset(7)= sysdatetimeoffset()										-- update time for change to record
	 ,@updateUser nvarchar(75)		 = sf.fApplicationUserSession#UserName()	-- user calling the procedure
	 ,@maxRows		int;																											-- record count to process

	declare @work table -- table of keys to process
	(ID int identity(1, 1), RegistrationSID int not null);

	begin try

		-- check parameters

		if @Registrations is null
		begin
			set @blankParm = N'@Registrations';
		end;

		if @blankParm is not null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = @blankParm;

			raiserror(@errorText, 18, 1);

		end;

		if @CardPrintedTime is null
		begin
			set @CardPrintedTime = sf.fNow();
		end;

		insert
			@work -- parse XML key values into table for processing
		(RegistrationSID)
		select
			Registration.rc.value('@SID', 'int')
		from
			@Registrations.nodes('//Registration') Registration(rc);

		set @maxRows = @@rowcount;

		if @maxRows = 0
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = '@Registrations';

			raiserror(@errorText, 16, 1);

		end;

		update
			reg
		set
			reg.CardPrintedTime = @CardPrintedTime
		 ,reg.UpdateTime = @updateTime
		 ,reg.UpdateUser = @updateUser
		from
			@work						 w
		join
			dbo.Registration reg on w.RegistrationSID = reg.RegistrationSID
		where
			reg.CardPrintedTime is null
		or
			reg.CardPrintedTime <> @CardPrintedTime

	end try
	begin catch

		if @@trancount > 0 rollback;
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw

	end catch;

	return (@errorNo);

end;
GO
