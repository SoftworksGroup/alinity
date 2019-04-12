SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sf.pPersonGroup#Copy
	@PersonGroupSID			int								-- key of the group to copy
 ,@PersonGroupName		nvarchar(65)			-- name for the new group
 ,@PersonGroupLabel		nvarchar(35)			-- label for the new group
 ,@ApplicationUserSID int = null				-- if not provided the currently authenticated user is used
 ,@NewPersonGroupSID	int = null output -- identity assigned to the new group
as
/*********************************************************************************************************************************
Procedure : Person Group Copy
Notice    : Copyright © 2018 Softworks Group Inc.
Summary   : Creates a new group copied from the provided group
----------------------------------------------------------------------------------------------------------------------------------
History		: Author	  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Kris Dawson	| Aug 2018		|	Initial version

Comments
--------
This procedure creates a brand new person group based on the group provided. If the group provided is a smart
group the new group will contain individual person group member records instead of a reference to the query,
in this way users can create a static group from a smart group.

Example:
--------
<TestHarness>
	<Test Name = "Default" IsDefault ="true" Description="Copies a random group">
		<SQLScript>
			<![CDATA[
declare 
	  @personGroupSID				int
	 ,@applicationUserSID		int
											
select
	@personGroupSID = pg.PersonGroupSID
from
	sf.PersonGroup pg
order by
	newid()

select
	 @applicationUserSID = au.ApplicationUserSID
from
	sf.ApplicationUser au
order by
	newid()

begin transaction

begin try

	exec sf.pPersonGroup#Copy
		 @PersonGroupSID = @personGroupSID
		,@PersonGroupName = N'_TEST GROUP COPY_'
		,@PersonGroupLabel = N'_TEST GROUP COPY_'
		,@ApplicationUserSID = @applicationUserSID
		,@NewPersonGroupSID	= @personGroupSID output

	select
		 PersonGroupSID
		,PersonGroupName
	from
		sf.PersonGroup
	where
		PersonGroupSID = @personGroupSID

	rollback

end try
begin catch

	if @@trancount > 0 rollback
	exec sf.pErrorRethrow

end catch
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05"/>
		</Assertions>
	</Test>
	<Test Name = "Static group" Description="Copies a group not based on a query">
		<SQLScript>
			<![CDATA[
declare 
	  @personGroupSID				int
	 ,@applicationUserSID		int
											
select
	@personGroupSID = pg.PersonGroupSID
from
	sf.PersonGroup pg
where
	pg.QuerySID is null
order by
	newid()

select
	 @applicationUserSID = au.ApplicationUserSID
from
	sf.ApplicationUser au
order by
	newid()

begin transaction

begin try

	exec sf.pPersonGroup#Copy
		 @PersonGroupSID = @personGroupSID
		,@PersonGroupName = N'_TEST GROUP COPY_'
		,@PersonGroupLabel = N'_TEST GROUP COPY_'
		,@ApplicationUserSID = @applicationUserSID
		,@NewPersonGroupSID	= @personGroupSID output

	select
		 PersonGroupSID
		,PersonGroupName
	from
		sf.PersonGroup
	where
		PersonGroupSID = @personGroupSID

	rollback

end try
begin catch

	if @@trancount > 0 rollback
	exec sf.pErrorRethrow

end catch
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05"/>
		</Assertions>
	</Test>
	<Test Name = "Smart group" Description="Copies a group based on a query">
		<SQLScript>
			<![CDATA[
declare 
	  @personGroupSID				int
	 ,@applicationUserSID		int
											
select
	@personGroupSID = pg.PersonGroupSID
from
	sf.PersonGroup pg
where
	pg.QuerySID is not null
order by
	newid()

select
	 @applicationUserSID = au.ApplicationUserSID
from
	sf.ApplicationUser au
order by
	newid()

begin transaction

begin try

	exec sf.pPersonGroup#Copy
		 @PersonGroupSID = @personGroupSID
		,@PersonGroupName = N'_TEST GROUP COPY_'
		,@PersonGroupLabel = N'_TEST GROUP COPY_'
		,@ApplicationUserSID = @applicationUserSID
		,@NewPersonGroupSID	= @personGroupSID output

	select
		 PersonGroupSID
		,PersonGroupName
	from
		sf.PersonGroup
	where
		PersonGroupSID = @personGroupSID

	rollback

end try
begin catch

	if @@trancount > 0 rollback
	exec sf.pErrorRethrow

end catch
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05"/>
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.pPersonGroup#Copy'
 ,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo									int						= 0								-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText								nvarchar(4000)									-- message text (for business rule errors)
	 ,@blankParm								varchar(100)										-- tracks blank values in required parameters
	 ,@ON												bit						= cast(1 as bit)	-- used on bit comparisons to avoid multiple casts
	 ,@tagList									xml
	 ,@isDocumentLibraryEnabled bit
	 ,@personGroupCategory			nvarchar(65)
	 ,@querySID									int
	 ,@userName									nvarchar(75);										-- user performing the copy  (for audit columns);

	declare @work table -- stores primary key values of members being copied from a smart group
	(PersonSID int not null);

	begin try

		-- check parameters

		if @ApplicationUserSID is null
		begin
			set @ApplicationUserSID = sf.fApplicationUserSessionUserSID();
		end;

		if @PersonGroupSID is null
		begin
			set @blankParm = '@PersonGroupSID';
		end;

		if len(isnull(@PersonGroupName, '')) = 0
		begin
			set @blankParm = '@PersonGroupName';
		end;

		if len(isnull(@PersonGroupLabel, '')) = 0
		begin
			set @blankParm = '@PersonGroupLabel';
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

		select
			@querySID									= pg.QuerySID
		 ,@tagList									= pg.TagList
		 ,@isDocumentLibraryEnabled = pg.IsDocumentLibraryEnabled
		 ,@personGroupCategory			= pg.PersonGroupCategory
		from
			sf.PersonGroup pg
		where
			pg.PersonGroupSID = @PersonGroupSID;

		if @@rowcount = 0
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'sf.PersonGroup'
			 ,@Arg2 = @PersonGroupSID;

			raiserror(@errorText, 18, 1);

		end;

		select
			@userName = au.UserName
		from
			sf.ApplicationUser au
		where
			au.ApplicationUserSID = @ApplicationUserSID;

		if @userName is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'sf.ApplicationUser'
			 ,@Arg2 = @ApplicationUserSID;

			raiserror(@errorText, 18, 1);

		end;

		-- add the group and get the new key

		exec sf.pPersonGroup#Insert
			@PersonGroupSID = @NewPersonGroupSID out
		 ,@PersonGroupName = @PersonGroupName
		 ,@PersonGroupLabel = @PersonGroupLabel
		 ,@TagList = @tagList
		 ,@IsDocumentLibraryEnabled = @isDocumentLibraryEnabled
		 ,@PersonGroupCategory = @personGroupCategory
		 ,@ApplicationUserSID = @ApplicationUserSID;

		if @querySID is not null
		begin

			insert @work ( PersonSID) exec sf.pQuery#Execute @QuerySID = @querySID;

			insert
				sf.PersonGroupMember (PersonGroupSID, PersonSID, CreateUser, UpdateUser)
			select @NewPersonGroupSID , x.PersonSID, @userName, @userName from @work x ;

		end;
		else
		begin

			insert
				sf.PersonGroupMember
			(
				PersonGroupSID
			 ,PersonSID
			 ,Title
			 ,IsAdministrator
			 ,IsContributor
			 ,EffectiveTime
			 ,ExpiryTime
			 ,IsReplacementRequiredAfterTerm
			 ,CreateUser
			 ,UpdateUser
			)
			select
				@NewPersonGroupSID
			 ,pgm.PersonSID
			 ,pgm.Title
			 ,pgm.IsAdministrator
			 ,pgm.IsContributor
			 ,pgm.EffectiveTime
			 ,pgm.ExpiryTime
			 ,pgm.IsReplacementRequiredAfterTerm
			 ,@userName
			 ,@userName
			from
				sf.vPersonGroupMember pgm
			where
				pgm.PersonGroupSID = @PersonGroupSID and (pgm.IsActive = @ON or pgm.IsReplacementRequired = @ON);

		end;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);

end;
GO
