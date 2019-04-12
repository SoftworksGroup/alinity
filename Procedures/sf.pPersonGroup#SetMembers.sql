SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pPersonGroup#SetMembers]																	
		@PersonGroupSID										int																	-- key of group to update members for
	, @PersonGroupLabel									nvarchar(35)												-- label to apply to new group (new group only)
	,	@PersonGroupMembers								xml																	-- list of persons to add/update in the group 
as
/*********************************************************************************************************************************
Procedure : Person Group - Set Members
Notice    : Copyright © 2017 Softworks Group Inc.
Summary   : Creates or updates a person group with the list of members provided
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|---------------------------------------------------------------------------------------------
				: Tim Edlund	| Jun 2017		| Initial Version

Comments	
--------
This procedure is called from the UI in 2 main scenarios: 1) To create a new group based on copying an existing group including 
smart groups (query-based groups), and 2) To update an existing group with additional members and/or changes to existing 
members.

The format of the @PersonGroupMembers XML is as follows:

<PersonGroupMembers>
		<PersonGroupMember PersonGroupMemberSID="1000001" PersonSID="1000001" Title="Manager" IsAdministrator="true" IsContributor="true" IsExpired="false" />
		<PersonGroupMember PersonGroupMemberSID="1000002" PersonSID="1000002" Title="Manager" IsAdministrator="true" IsContributor="true" IsExpired="true" />
		<PersonGroupMember PersonGroupMemberSID="-1" PersonSID="1000003" Title="" IsAdministrator="false" IsContributor="true" IsExpired="false" />
</PersonGroupMembers>

If a new group is being requested, then -1 must be passed as the @PersonGroupSID and a label/name to apply to the new group is
required (passed in @PersonGroupLabel).

When updating the member list on existing groups and a new member is to be added, then the PersonGroupMember SID parameter in the 
XML must be passed as -1.  Note that even when -1 is passed, the procedure must check to ensure a member record does not exist
for the given PersonSID which was previously expired.  If an expired group member record is found, it is reactivated.

Example
-------

As this procedure requires an XML parameter with references to existing record keys, test from UI.

-------------------------------------------------------------------------------------------------------------------------------- */

set nocount on

begin

	declare
			@errorNo									int = 0																		-- 0 no error, <50000 SQL error, else business rule
		,	@errorText								nvarchar(4000)														-- message text (for business rule errors)
		,	@blankParm								varchar(50)																-- tracks if any required parameters are not provided 
		,	@ON												bit								= cast(1 as bit)				-- used on bit comparisons to avoid multiple casts
		,	@OFF											bit								= cast(0 as bit)				-- used on bit comparisons to avoid multiple casts 
		,	@i												int								= 0											-- for loop
		,	@maxRows									int								= 0											-- max row for loop
		, @isNewGroup								bit								= cast(0 as bit)				-- tracks whether new group is added
		, @applicationUserSID				int																				-- user to be assigned to copied groups
		,	@personGroupMemberSID			int																				-- column values to set:
		, @personSID								int
		, @title										nvarchar(75)
		, @isAdministrator					bit
		,	@isContributor						bit
		, @isExpired								bit
		,	@expiryTime								datetime
		, @isActive									bit
		
	declare
		@members										table																			-- used during removal of persons who may not exist
		(
				ID												int	identity(1,1)
			,	PersonGroupMemberSID			int								not null
			,	PersonSID									int								not null
			, Title											nvarchar(75)			null
			, IsAdministrator						bit								not null default cast(0 as bit)
			,	IsContributor							bit								not null default cast(0 as bit)
			, IsExpired									bit								not null default cast(0 as bit)
		)  

	begin try

		-- check parameters

		if @PersonGroupMembers												is null set @blankParm	= '@PersonGroupMembers'
		if @PersonGroupSID														is null	set @blankParm	= '@PersonGroupSID'
		if @PersonGroupSID = -1 and @PersonGroupLabel is null set @blankParm	= '@PersonGroupLabel'

		if @blankParm is not null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1          = @blankParm

			raiserror(@errorText, 18, 1)

		end

		-- parse XML into work table for processing

		insert
			@members
		(
				PersonGroupMemberSID
			,	PersonSID
			, Title
			,	IsAdministrator
			,	IsContributor
			,	IsExpired
		)
		select
				Member.m.value('@PersonGroupMemberSID'	, 'int')					PersonGroupMemberSID
			, Member.m.value('@PersonSID'							, 'int')					PersonSID
			,	Member.m.value('@Title'									, 'nvarchar(75)') Title
			,	Member.m.value('@IsAdministrator'				, 'bit')					IsAdministrator
			, Member.m.value('@IsContributor'					, 'bit')					IsContributor
			, Member.m.value('@IsExpired'							, 'bit')					IsExpired
		from
			@PersonGroupMembers.nodes('//PersonGroupMember') Member(m)

		set @maxRows	= @@rowcount
		set @i				= 0

		-- add a new person group if requested

		begin transaction

		if @PersonGroupSID = -1
		begin

			set @applicationUserSID = sf.fApplicationUserSessionUserSID()

			exec sf.pPersonGroup#Insert
					@PersonGroupSID			= @PersonGroupSID			output
				,	@PersonGroupName		= @PersonGroupLabel													-- use the label for both name and label columns on add
				,	@PersonGroupLabel		= @PersonGroupLabel
				, @ApplicationUserSID	= @applicationUserSID


			set @isNewGroup = @ON

		end
		else if exists																												-- if is a smart group, remove query as its being converted to a manual list
		(
			select
				1
			from
				sf.PersonGroup pg
			where
				pg.PersonGroupSID = @PersonGroupSID
			and
				pg.QuerySID is not null
		)
		begin

			update
        sf.PersonGroup
      set
        QuerySID = null
      where
        PersonGroupSID = @PersonGroupSID

		end

		-- now process all member rows

		while @i < @maxRows
		begin

			set @i += 1
			set @expiryTime = null
			set @title = null

			select
					@personGroupMemberSID = m.PersonGroupMemberSID
				,	@personSID						= m.PersonSID
				, @title								= m.Title
				,	@isAdministrator			= m.IsAdministrator
				,	@isContributor				= m.IsContributor
				,	@isExpired						= m.IsExpired
			from
				@members m
			where
				m.ID = @i

			if @personGroupMemberSID = -1	and @isNewGroup = @OFF								-- new group member requested
			begin
				
				select 
					@personGroupMemberSID = pgm.PersonGroupMemberSID								-- resets SID to existing record
				from 
					sf.PersonGroupMember pgm 
				where 
					pgm.PersonGroupSID = @PersonGroupSID 
				and 
					pgm.PersonSID = @personSID

				if @@rowcount = 0 set @personGroupMemberSID = -1

			end

			if @personGroupMemberSID = -1 or @isNewGroup = @ON
			begin

				exec sf.pPersonGroupMember#Insert																	-- add new member record
					  @PersonGroupSID				= @PersonGroupSID
					,	@PersonSID						= @personSID		
					, @Title								= @title
					,	@IsAdministrator			=	@isAdministrator
					,	@IsContributor				=	@isContributor	

			end
			else
			begin

				set @isActive = case when @isExpired = @ON then @OFF else @ON end

				exec sf.pPersonGroupMember#Update																	-- and update the existing member record
						@PersonGroupMemberSID	= @personGroupMemberSID
					,	@PersonSID						= @personSID	
					, @Title								= @title
					,	@IsAdministrator			=	@isAdministrator
					,	@IsContributor				=	@isContributor	
					,	@IsActive							= @isActive		

			end

		end
		
		commit

    select
      @personGroupSID PersonGroupSID

	end try

	begin catch
		if @@trancount > 0 rollback
		exec @errorNo  = sf.pErrorRethrow
	end catch

	return (@errorNo)

end
GO
