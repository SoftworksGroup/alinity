SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sf.pPersonGroupMember#Upsert
	@PersonGroupMemberSID						int output					-- identity value assigned to the new record
 ,@RowGUID												uniqueidentifier		-- sub-form ID here
 ,@PersonGroupSID									int									-- required: group to assign/remove member from
 ,@PersonSID											int									-- required: person to assign/remove 
 ,@IsActive												bit									-- required: when 1 person is assigned to group, 0 to remove
 ,@Title													nvarchar(75) = null -- remaining columns are not required but must be maintained for call syntax compatibility with #Insert/#Update							
 ,@IsAdministrator								bit = null
 ,@IsContributor									bit = null
 ,@EffectiveTime									datetime = null
 ,@ExpiryTime											datetime = null
 ,@IsReplacementRequiredAfterTerm bit = null
 ,@ReplacementClearedDate					date = null
 ,@UserDefinedColumns							xml = null
 ,@PersonGroupMemberXID						varchar(150) = null
 ,@LegacyKey											nvarchar(50) = null
 ,@CreateUser											nvarchar(75) = null
 ,@IsReselected										tinyint = null
 ,@zContext												xml = null
 ,@GenderSID											int = null
 ,@NamePrefixSID									int = null
 ,@FirstName											nvarchar(30) = null
 ,@CommonName											nvarchar(30) = null
 ,@MiddleNames										nvarchar(30) = null
 ,@LastName												nvarchar(35) = null
 ,@BirthDate											date = null
 ,@DeathDate											date = null
 ,@HomePhone											varchar(25) = null
 ,@MobilePhone										varchar(25) = null
 ,@IsTextMessagingEnabled					bit = null
 ,@ImportBatch										nvarchar(100) = null
 ,@PersonRowGUID									uniqueidentifier = null
 ,@PersonGroupName								nvarchar(65) = null
 ,@PersonGroupLabel								nvarchar(35) = null
 ,@PersonGroupCategory						nvarchar(65) = null
 ,@ApplicationUserSID							int = null
 ,@IsPreference										bit = null
 ,@IsDocumentLibraryEnabled				bit = null
 ,@QuerySID												int = null
 ,@LastReviewUser									nvarchar(75) = null
 ,@LastReviewTime									datetimeoffset(7) = null
 ,@SmartGroupCount								int = null
 ,@SmartGroupCountTime						datetimeoffset(7) = null
 ,@PersonGroupIsActive						bit = null
 ,@PersonGroupRowGUID							uniqueidentifier = null
 ,@IsPending											bit = null
 ,@IsDeleteEnabled								bit = null
 ,@DisplayName										nvarchar(65) = null
 ,@EmailAddress										varchar(150) = null
 ,@PhoneNumber										varchar(25) = null
 ,@IsTermExpired									bit = null
 ,@TermLabel											nvarchar(4000) = null
 ,@IsReplacementRequired					bit = null
as
/*********************************************************************************************************************************
Procedure : sf.pPersonGroupMember#Upsert
Notice    : Copyright © 2018 Softworks Group Inc.
Summary   : Inserts or updates the person's membership in the group
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Sep 2018		|	Initial version

Comments	
--------
This procedure is a wrapper for the #Insert and #Update procedures on the (sf) Person Group Member table. The procedure is called 
during form processing (from sf.pForm#Post) to save values on changed group memberships.  The procedure is applied most often
on "Preference" related groups where the end user can assign and un-assign themselves through an update to their profile. 

The procedure calls the #Insert sproc to record a new assignment records whenever the @IsActive bit is passed as ON and no
active membership already exists.  If an existing group membership exists but no change to it is detected, then the procedure 
updates the UpdateTime only.  The update to the time may be useful in establishing when confirmation of a preference was last
received from the person.

In order for the #Insert procedure to be called no primary key value should be passed.  Even without the key, however, the
procedure checks for an active membership in the group for the person identified before creating a new record.

Form Design
-----------
When configuring forms for group assignments, be sure the check-box on the form where the user indicates they want to 
be included in the group is bound to the "@IsActive" parameter.  The group and person keys are always required.

Example
-------
<TestHarness>
  <Test Name = "Random" IsDefault ="true" Description="Assigns a (new) person to a Preference group selected at random">
    <SQLScript>
      <![CDATA[
declare
	@personGroupSID				int
 ,@personSID						int
 ,@personGroupMemberSID int
 ,@rowGuid							uniqueidentifier = newid();

select top (1)
	@personGroupSID = pg.PersonGroupSID
from
	sf.PersonGroup pg
where
	pg.IsPreference = 1
order by
	newid();

select top (1)
	@personSID = p.PersonSID
from
	sf.Person						 p
left outer join
	sf.PersonGroupMember pgm on pgm.PersonGroupSID = @personGroupSID and p.PersonSID = pgm.PersonSID
where
	pgm.PersonGroupMemberSID is null
order by
	newid();

if @personGroupSID is null or @personSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	exec sf.pPersonGroupMember#Upsert
		@PersonGroupMemberSID = @personGroupMemberSID output
	 ,@RowGUID = @rowGUID
	 ,@PersonGroupSID = @personGroupSID
	 ,@PersonSID = @personSID
	 ,@IsActive = 1;

	select
		pgm.*
	from
		sf.PersonGroupMember pgm
	where
		pgm.PersonGroupMemberSID = @personGroupMemberSID;

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
	 @ObjectName = 'sf.pPersonGroupMember#Upsert'
	,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */

begin
	set nocount on;

	declare
		@errorNo					int						= 0											-- 0 no error, <50000 SQL error, else business rule
	 ,@tranCount				int						= @@trancount						-- determines whether a wrapping transaction exists
	 ,@sprocName				nvarchar(128) = object_name(@@procid) -- name of currently executing procedure
	 ,@xState						int																		-- error state detected in catch block
	 ,@errorText				nvarchar(4000)												-- message text (for business rule errors)
	 ,@isExistingActive bit						= cast(0 as bit)				-- indicates whether current assignment is active
	 ,@ON								bit						= cast(1 as bit)				-- constant for bit comparison and assignments
	 ,@OFF							bit						= cast(0 as bit);				-- constant for bit comparison and assignments

	set @PersonGroupMemberSID = null; -- initialize output parameter

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

		if @PersonGroupSID is null or @PersonSID is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = '@PersonGroupSID\@PersonSID';

			raiserror(@errorText, 18, 1);

		end;

		if @PersonGroupMemberSID is not null
		begin

			select
				@isExistingActive = sf.fIsActive(pgm.EffectiveTime, pgm.ExpiryTime)
			from
				sf.PersonGroupMember pgm
			where
				pgm.PersonGroupMemberSID = @PersonGroupMemberSID;

			if @@rowcount = 0
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'RecordNotFound'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
				 ,@Arg1 = 'sf.PersonGroupMember'
				 ,@Arg2 = @PersonGroupMemberSID;

				raiserror(@errorText, 18, 1);

			end;
		end;
		else if @PersonGroupMemberSID is null
		begin

			select
				@PersonGroupMemberSID = pgm.PersonGroupMemberSID
			 ,@isExistingActive			= sf.fIsActive(pgm.EffectiveTime, pgm.ExpiryTime)
			from
				sf.PersonGroupMember pgm
			where
				pgm.PersonSID = @PersonSID and pgm.PersonGroupSID = @PersonGroupSID;

		end;

		if @IsActive = @ON
		begin

			if @PersonGroupMemberSID is null or @isExistingActive = @OFF
			begin

				exec sf.pPersonGroupMember#Insert
					@PersonGroupMemberSID = @PersonGroupMemberSID output
				 ,@PersonGroupSID = @PersonGroupSID
				 ,@PersonSID = @PersonSID;

			end;

		end;
		else if @IsActive = @OFF
		begin

			if @isExistingActive = @ON
			begin

				exec sf.pPersonGroupMember#Update
					@PersonGroupMemberSID = @PersonGroupMemberSID
				 ,@IsActive = @IsActive;

			end;
		end;

	 if @trancount = 0 and xact_state() = 1 commit transaction

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
