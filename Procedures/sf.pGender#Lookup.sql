SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sf.pGender#Lookup
	@GenderSCD	 varchar(5) = null		-- code of Gender to lookup
 ,@GenderLabel nvarchar(35) = null	-- label of Gender to lookup
 ,@GenderSID	 int output						-- key of the sf.Gender record found
as
/*********************************************************************************************************************************
Procedure	: Lookup Gender
Notice		: Copyright © 2017 Softworks Group Inc. 
Summary		: Subroutine to lookup a GenderSID based on a name prefix string value passed in
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)				| Month Year  | Change Summary
				 : ----------------	|	----------	| --------------
				 : Tim Edlund				| Apr 2017    | Initial version
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------

This procedure is used when processing staged data. It attempts to find a primary key value for the sf.Gender table based
on a string identifier (label or code) passed in. The routine is called in conversion scenarios where the primary key value
of the target master table cannot be established on initial loading. The search is run against both the label and code columns
in the master table. 

Matching on Legacy Key
----------------------
Normal searches occur on the label and code columns but where modeling or the upgrade process in general have forced names to be 
changed, the key value from the old system can be placed into the LegacyKey column in the Alinity master table. Instead of filling 
in the code with the actual code value, e.g. "M", it can be set to the key value from the old system. This procedure will attempt 
to match it to the Legacy Key column in the master table and where found, the resulting key is used.  Legacy Key matches have a 
higher priority than other matches (in case the code matches on a different record).

Returns default GenderSCD = 'U'
--------------------------------
If a value is not found, then the procedure attempts to locate a gender code of "U" for "undefined". If the lack of a valid
gender prevents further processing, the error must be processed by the caller.

Example:
--------

<TestHarness>
	<Test Name="OneValidInput" IsDefault="true" Description="Calls lookup procedure with a valid input that will be found.">
		<SQLScript>
			<![CDATA[

declare
	@genderSID	 int
	,@genderSCD	 varchar(5)
	,@genderLabel nvarchar(35)

set @genderLabel = 'Female'

exec sf.pGender#Lookup
	@GenderSCD = @genderSCD
	,@GenderLabel = @genderLabel
	,@GenderSID = @genderSID output

select
	 @genderSCD	  [@GenderSCD]
	,@genderLabel [@GenderLabel]
	,@GenderSID	  [@GenderSID]
	,*
from
	sf.Gender x
where
	x.GenderSID = @genderSID

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:01" />
		</Assertions>
	</Test>
	<Test Name="MixedInputs" Description="Calls lookup procedure with inputs that are inconsistent. Tests priority setting on result.">
		<SQLScript>
			<![CDATA[

declare
	@genderSID	 int
	,@genderSCD	 varchar(5)
	,@genderLabel nvarchar(35)

set @genderSCD = 'm'
set @genderLabel = 'Female'

exec sf.pGender#Lookup
	@GenderSCD = @genderSCD
	,@GenderLabel = @genderLabel
	,@GenderSID = @genderSID output

select
	@genderSCD	  [@GenderSCD]
	,@genderLabel [@GenderLabel]
	,@GenderSID	  [@GenderSID]
	,*
from
	sf.Gender x
where
	x.GenderSID = @genderSID

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:01" />
		</Assertions>
	</Test>
	<Test Name="InavlidInputs" Description="Calls lookup procedure with multiple inputs that will NOT be found. Should return default.">
		<SQLScript>
			<![CDATA[

	declare
		@genderSID	 int
	 ,@genderSCD	 varchar(5)
	 ,@genderLabel nvarchar(35)

	set @genderSCD = 'X'
	set @genderLabel = 'Not-Found'

	exec sf.pGender#Lookup
		@GenderSCD = @genderSCD
	 ,@GenderLabel = @genderLabel
	 ,@GenderSID = @genderSID output

	select
		@genderSCD	 [@GenderSCD]
	 ,@genderLabel [@GenderLabel]
	 ,@GenderSID	 [@GenderSID]
	 ,*
	from
		sf.Gender x
	where
		x.GenderSID = @genderSID

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:01" />
		</Assertions>
	</Test>
	<Test Name="NullInputs" Description="Calls lookup procedure without inputs. Should return default.">
		<SQLScript>
			<![CDATA[

	declare
		@genderSID	 int
	 ,@genderSCD	 varchar(5)
	 ,@genderLabel nvarchar(35)

	exec sf.pGender#Lookup
		@GenderSCD = @genderSCD
	 ,@GenderLabel = @genderLabel
	 ,@GenderSID = @genderSID output

	select
		@genderSCD	 [@GenderSCD]
	 ,@genderLabel [@GenderLabel]
	 ,@GenderSID	 [@GenderSID]
	 ,*
	from
		sf.Gender x
	where
		x.GenderSID = @genderSID

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:01" />
		</Assertions>
	</Test>
	<Test Name="LegacyKeyPriority" Description="Calls lookup procedure with an input only found in the LegacyKey column. Should return Male.">
		<SQLScript>
			<![CDATA[

update sf .Gender set LegacyKey = '88888' where GenderSCD = 'M'

declare
	@genderSID	 int
	,@genderSCD	 varchar(5)
	,@genderLabel nvarchar(35)

set @genderSCD = '88888'

exec sf.pGender#Lookup
	 @GenderSCD = @genderSCD
	,@GenderLabel = @genderLabel
	,@GenderSID = @genderSID output

select
	 @genderSCD	  [@GenderSCD]
	,@genderLabel [@GenderLabel]
	,@GenderSID	  [@GenderSID]
	,*
from
	sf.Gender x
where
	x.GenderSID = @genderSID

update sf .Gender set LegacyKey = null where GenderSCD = 'M'

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:01" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.pGender#Lookup'
 ,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo	 int = 0					-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText nvarchar(4000);	-- message text (for business rule errors) 	 

	set @GenderSID = null; -- initialize output values

	begin try

		if @GenderLabel is null and @GenderSCD is null and not exists (select 1 from sf .Gender x where x.GenderSCD = 'U') -- ok to leave blank if default exists
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = '@GenderLabel/@GenderSCD';

			raiserror(@errorText, 18, 1);
		end;

		-- attempt the lookup on values

		select top (1)
			@GenderSID = g.GenderSID
		from
			sf.Gender g
		where
			g.GenderLabel								= @GenderLabel or g.GenderSCD = @GenderSCD -- match gender code or label
			or isnull(g.LegacyKey, '~') = @GenderSCD	-- or legacy key
		order by ( -- set priority for matched records
			case
				when isnull(g.LegacyKey, '~') = @GenderSCD then 1
				when g.GenderSCD = @GenderSCD then 2
				when g.GenderLabel = @GenderLabel then 3
				else 9
			end
						 );

		if @GenderSID is null
		begin
			select @GenderSID	 = g.GenderSID from sf.Gender g where g.GenderSCD = 'U';
		end;

	end try
	begin catch
		if @@trancount > 0 rollback;
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);

end;
GO
