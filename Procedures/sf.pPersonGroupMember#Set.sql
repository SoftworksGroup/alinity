SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sf.pPersonGroupMember#Set
	@UpdateRule						varchar(10) = 'NEWONLY'		-- setting of update rule - see comments below
 ,@PersonSID						int												-- key of person record to insert/update group membership for (required!)
 ,@PersonGroupLabel			nvarchar(65)							-- value to lookup person group record (FK)
 ,@Title								nvarchar(75) = null				-- optional values for person group assignment:
 ,@IsAdministrator			bit = null
 ,@IsContributor				bit = null
 ,@EffectiveTime				datetime = null
 ,@ExpiryTime						datetime = null
 ,@UpdateTime						datetimeoffset(7) = null	-- required if update rule is "LATEST"
 ,@LegacyKey						nvarchar(50) = null				-- key of person group record record in source/converted system 
 ,@PersonGroupMemberSID int = null output					-- key of person group member record inserted or updated
as
/*********************************************************************************************************************************
Procedure : Person Group Member - Set
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Applies person group information from user-entered forms or staging records into main (SF) tables
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Mar 2019		|	Initial version

Comments
--------
This procedure supports adding or updating person group assignments (sf.PersonGroupMember) from source data provided from forms 
or from the staging area (e.g. stg.RegistrantProfile).  The source data is passed into the procedure and the person group 
record is created where it does not already exist. 

The procedure requires a PersonSID to associate the person group with.  A PersonGroup identifier (label) which must be found in 
the master table is also required. All other parameters are optional and/or can be defaulted.  

For details on how look ups of identifiers in master tables is carried out, see the #Lookup subroutine documentation. 

Updating existing person groups is carried out where an existing record is found for the person and label passed in.  
The update will only occur, however if the setting of the @UpdateRule allows it (see below).

Update Rule
-----------
The content passed in will create new records if none are found but if an existing record is found, it will only be updated
based on the setting of the @UpdateRule - which if not passed is set to NEWONLY. The following settings are supported:

NEWONLY			-- existing records are never updated, but new records are added
LATEST			-- existing record overwritten if the @UpdateTime passed in is later than the existing record, new records are added
ALWAYS			-- existing record is always overwritten with information passed in, new records are added

The default setting is "NEWONLY", since the products are normally considered to be the repository of the most up-to-date
information. Note that the LATEST rule depends on the @UpdateTime parameter being passed in.  If the value is not provided an 
error is returned.

Errors Must Be Raised to the Caller
-----------------------------------
This procedure is often called in batch processing scenarios for sets of records stored in staging where an error on any 
individual record should not stop processing of remaining records. For that reason, errors raised by the procedure must be caught 
by the top-level calling procedure and handled.  The call to this procedure must be wrapped in a try-catch block. Failing to 
raise an error in this subroutine will generate a mismatch in the transaction count and the message: "Transaction count after 
EXECUTE indicates a mismatching number of BEGIN and COMMIT statements. Previous count = 1, current count = 0." The caller must 
determine whether errors should be raised to the application, or logged when executed in batch processes.

Example
-------
<TestHarness>
	<Test Name="Random" IsDefault="true" Description="Calls procedure to insert and then rollback a new person group assignment.">
		<SQLScript>
			<![CDATA[
declare
	@personSID						int
 ,@personGroupLabel			nvarchar(65)
 ,@title								nvarchar(75)
 ,@effectiveTime				datetime
 ,@expiryTime						datetime
 ,@personGroupMemberSID int

select top (1) -- locate a valid person group member assignment and extract parameter values
	@personSID				= pgm.PersonSID
 ,@personGroupLabel = N'SID:' + ltrim(pgm.PersonGroupSID)
 ,@title						= pgm.Title
 ,@effectiveTime		= pgm.EffectiveTime
 ,@expiryTime				= pgm.ExpiryTime
from
	sf.PersonGroupMember pgm
order by
	newid();

select top (1) -- isolate a person who does not have the qualifying person group identified above
	@personSID = p.PersonSID
from
	sf.Person						 p
left outer join
	sf.PersonGroupMember pgm on p.PersonSID = pgm.PersonSID and 'SID:' + ltrim(pgm.PersonGroupSID) = @personGroupLabel
where
	pgm.PersonGroupMemberSID is null
order by
	newid();

if @@rowcount = 0 or @personSID is null or @personGroupLabel is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	begin transaction;

	exec sf.pPersonGroupMember#Set
		@PersonSID = @personSID
	 ,@PersonGroupLabel = @personGroupLabel
	 ,@Title = @title
	 ,@EffectiveTime = @effectiveTime
	 ,@ExpiryTime = @expiryTime
	 ,@PersonGroupMemberSID = @personGroupMemberSID output

	select
	  @personGroupLabel				 PersonGroupLabel
	 ,@title									 Title
	 ,@personGroupMemberSID		 PersonGroupMemberSID
	 ,pgm.PersonGroupMemberSID InsertedPersonGroupMemberSID
	 ,pgm.PersonGroupLabel		 InsertedPersonGroupLabel
	 ,pgm.Title								 InsertedTitle
	 ,pgm.IsContributor
	 ,pgm.IsAdministrator
	from
		sf.vPersonGroupMember pgm
	where
		pgm.PersonGroupMemberSID = @personGroupMemberSID;

	rollback;

end;
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.pPersonGroupMember#Set'
 ,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo						int							 = 0							-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText					nvarchar(4000)										-- message text (for business rule errors)
	 ,@blankParm					nvarchar(100)											-- error checking buffer for required parameters
	 ,@ON									bit							 = cast(1 as bit) -- constant for bit comparisons = 1
	 ,@existingUpdateTime datetimeoffset(7)									-- value of existing record update time (overwrite check input)
	 ,@personGroupSID			int;															-- master table keys for new record (obtained via lookup):

	set @PersonGroupMemberSID = @PersonGroupMemberSID; -- in/out (may be passed in to support updates)

	begin try

		-- check parameters

-- SQL Prompt formatting off
		if @PersonGroupLabel	is null	set @blankParm = N'@PersonGroupLabel';
		if @PersonSID					is null	set @blankParm = N'@PersonSID';
-- SQL Prompt formatting on

		if @blankParm is not null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = @blankParm;

			raiserror(@errorText, 18, 1);
		end;

		if @UpdateRule not in ('NEWONLY', 'LATEST', 'ALWAYS')
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'NotInList'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 provided "%2" is not valid. It must be one of: %3'
			 ,@Arg1 = 'update-rule-code'
			 ,@Arg2 = @UpdateRule
			 ,@Arg3 = '"NewOnly", "Latest", "Always"';

			raiserror(@errorText, 18, 1);
		end;

		if @PersonGroupMemberSID is null
		begin

			-- lookup person group

			exec sf.pPersonGroup#Lookup
				@PersonGroupIdentifier = @PersonGroupLabel
			 ,@PersonGroupSID = @personGroupSID output;

			if @personGroupSID is null
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'MasterTableValueNotFound'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The identifier "%1" was not found in the %2 master table.  Correct the source value or add it to the master table before re-processing the record.'
				 ,@Arg1 = @PersonGroupLabel
				 ,@Arg2 = 'PersonGroup'
				 ,@SuppressCode = @ON;

				raiserror(@errorText, 16, 1);

			end;

			-- avoid creating duplicate where the record already exists

			select
				@PersonGroupMemberSID = pgm.PersonGroupMemberSID
			from
				sf.PersonGroupMember pgm
			where
				pgm.PersonSID = @PersonSID and pgm.PersonGroupSID = @personGroupSID;

			if @PersonGroupMemberSID is null
			begin

				-- add the record; additional error checks are performed in the 
				-- constraint function and violations are reported to catch block

				exec sf.pPersonGroupMember#Insert
					@PersonGroupMemberSID = @PersonGroupMemberSID output	-- int
				 ,@PersonSID = @PersonSID
				 ,@PersonGroupSID = @personGroupSID
				 ,@Title = @Title
				 ,@IsAdministrator = @IsAdministrator
				 ,@IsContributor = @IsContributor
				 ,@EffectiveTime = @EffectiveTime
				 ,@ExpiryTime = @ExpiryTime
				 ,@LegacyKey = @LegacyKey;

			end;

		end;

		-- process update scenarios 

		if @PersonGroupMemberSID is not null
		begin

			if @UpdateRule = 'LATEST' and @UpdateTime is null
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'LatestWithNoUpdateTime'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The update rule specified in the configuration is "LATEST" but no update time was provided from the source record.'
				 ,@SuppressCode = @ON;

				raiserror(@errorText, 16, 1);

			end;
			else if @UpdateRule = 'ALWAYS' or (@UpdateRule = 'LATEST' and @UpdateTime > @existingUpdateTime)
			begin

				exec sf.pPersonGroupMember#Update
					@PersonGroupMemberSID = @PersonGroupMemberSID
				 ,@PersonSID = @PersonSID
				 ,@PersonGroupSID = @personGroupSID
				 ,@Title = @Title
				 ,@IsAdministrator = @IsAdministrator
				 ,@IsContributor = @IsContributor
				 ,@EffectiveTime = @EffectiveTime
				 ,@ExpiryTime = @ExpiryTime
				 ,@LegacyKey = @LegacyKey;

			end;

		end;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);

end;
GO
