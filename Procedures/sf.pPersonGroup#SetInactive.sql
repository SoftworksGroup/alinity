SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pPersonGroup#SetInactive]																
		@PersonGroupSID										int																	-- key of group to set inactive
as
/*********************************************************************************************************************************
Procedure : Person Group - Set Inactive
Notice    : Copyright © 2017 Softworks Group Inc.
Summary   : Updates to an existing group to IsActive = OFF and expires all group members
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|---------------------------------------------------------------------------------------------
				: Tim Edlund	| Jun 2017		| Initial Version

Comments	
--------
This procedure is called from the UI and through the #Update sproc when the status of the group is being changed from Active to
Inactive (IsActive column).  Note that the procedure does NOT set the parent row IsActive column to 0.  This must be done
by the caller (the #Update sproc).

Example
-------

As this procedure will eliminate sample data, test from UI.

-------------------------------------------------------------------------------------------------------------------------------- */

set nocount on

begin

	declare
			@errorNo									int = 0																		-- 0 no error, <50000 SQL error, else business rule
		,	@errorText								nvarchar(4000)														-- message text (for business rule errors)
		,	@blankParm								varchar(50)																-- tracks if any required parameters are not provided 
		,	@ON												bit								= cast(1 as bit)				-- used on bit comparisons to avoid multiple casts
		,	@OFF											bit								= cast(0 as bit)				-- used on bit comparisons to avoid multiple casts 
		,	@isActive									bit																				-- tracks whether parent row is already marked inactive
		,	@nextSID									int																				-- key of next record to process
		, @expiryTime								datetime = sf.fNow()											-- time to set expiry of records to
		
	begin try

		-- check parameters

		if @PersonGroupSID	is null	set @blankParm	= '@PersonGroupSID'
		
		if @blankParm is not null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1          = @blankParm

			raiserror(@errorText, 18, 1)

		end

		select
			@isActive = pg.IsActive
		from
			sf.PersonGroup pg
		where
			pg.PersonGroupSID = @PersonGroupSID

		if @@rowcount = 0
		begin

			exec sf.pMessage#Get
					@MessageSCD  = 'RecordNotFound'
				,	@MessageText = @errorText output
				,	@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
				,	@Arg1        = 'sf.PersonGroup'
				,	@Arg2        = @PersonGroupSID
				
			raiserror(@errorText, 18, 1)

		end

		-- expire each non-expired member of the group

		begin transaction

		set @nextSID = -1

		while @nextSID is not null
		begin

			set @nextSID = null

			select
				@nextSID = min(pgm.PersonGroupMemberSID)
			from
				sf.PersonGroupMember pgm
			where
				pgm.PersonGroupSID = @PersonGroupSID
			and
			(
				sf.fIsActive(pgm.EffectiveTime, isnull(pgm.ExpiryTime, pgm.EffectiveTime)) = @ON
			or
				sf.fIsPending(pgm.EffectiveTime, isnull(pgm.ExpiryTime,pgm.EffectiveTime)) = @ON
			)

			if @nextSID is not null
			begin

				exec sf.pPersonGroupMember#Update
						@PersonGroupMemberSID = @nextSID
					,	@ExpiryTime						= @expiryTime 
		
			end

		end
		
		commit

	end try

	begin catch
		if @@trancount > 0 rollback
		exec @errorNo  = sf.pErrorRethrow
	end catch

	return (@errorNo)

end
GO
