SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pApplicationUser#MarkReviewed]
	 @ApplicationUserSID										int						= null						-- application user to be marked as reviewed
	,@LastReviewUser												nvarchar(75)	= null						-- reviewer of the record
as
/*********************************************************************************************************************************
Procedure : Application User - Mark Reviewed
Notice    : Copyright © 2012 Softworks Group Inc.
Summary   : Sets the last review time and user for an application user entity
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Kris Dawson	| Aug		2013		|	Initial version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This procedure sets LastReviewTime and LastReviewUser for an ApplicationUser. This procedure is used to avoid differences
between the local/web server time and the database time which could cause issues with the future dating rule.

Example
-------

declare
	@applicationUserSID  int

select top (1)
	@applicationUserSID = x.ApplicationUserSID
from
	sf.vApplicationUser x
order by
	newid()

select 
	 LastReviewUser
	,LastReviewTime
from
	sf.ApplicationUser
where
	ApplicationUserSID = @applicationUserSID

exec sf.pApplicationUser#MarkReviewed
	 @ApplicationUserSID	= @applicationUserSID
	,@LastReviewUser			= N'kris.d@sgi'

select 
	 LastReviewUser
	,LastReviewTime
from
	sf.ApplicationUser
where
	ApplicationUserSID = @applicationUserSID

-------------------------------------------------------------------------------------------------------------------------------- */

set nocount on

begin

	declare
		 @errorNo															int = 0                         -- 0 no error, <50000 SQL error, else business rule
		,@errorText                           nvarchar(4000)                  -- message text (for business rule errors)
		,@blankParm														varchar(128)										-- tracks NULL parameters passed into procedure
		,@lastReviewTime											datetimeoffset(7)

	begin try

		-- check parameters

		if len(ltrim(rtrim(@LastReviewUser))) = 0 set @LastReviewUser = null														-- ensure blanks are not used to bypass review user requirement!

		if @ApplicationUserSID	is null set @blankParm = '@ApplicationUserSID'
		if @LastReviewUser			is null	set @blankParm = '@LastReviewUser'
		
		if @blankParm is not null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= @blankParm

			raiserror(@errorText, 18, 1)
		end

		-- update the record

		set @lastReviewTime = sysdatetimeoffset()

		exec sf.pApplicationUser#Update
			 @ApplicationUserSID = @ApplicationUserSID
			,@LastReviewUser = @LastReviewUser
			,@LastReviewTime = @lastReviewTime

		-- check the row count to ensure the record exists

		if @@rowcount = 0
		begin

			exec sf.pMessage#Get
				 @MessageSCD    = 'RecordNotFound'
				,@MessageText   = @errorText output
				,@DefaultText   = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
				,@Arg1          = 'ApplicationUser'
				,@Arg2					= @ApplicationUserSID

			raiserror(@errorText, 18, 1)

		end

	end try

	begin catch
		if @@trancount > 0 rollback
		exec @errorNo = sf.pErrorRethrow                                      -- catch the error, rollback if pending, and re-throw
	end catch

	return(@errorNo)

end
GO
