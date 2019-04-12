SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pPersonGroup#MarkReviewed]
	 @PersonGroupSID												int						= null						-- person group to be marked as reviewed
	,@LastReviewUser												nvarchar(75)	= null						-- reviewer of the record
as
/*********************************************************************************************************************************
Procedure : Person Group - Mark Reviewed
Notice    : Copyright © 2017 Softworks Group Inc.
Summary   : Sets the last review time and user for a Person Group record
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Ti Edlund		| Jun 2017			|	Initial version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This procedure sets LastReviewTime and LastReviewUser for a Person Group record. Records must be marked reviewed periodically
to allow the organization to determine groups which are no longer required.  This procedure is used to avoid differences
between the local/web server time and the database time which could cause issues with date comparisons.

Example
-------

declare
	@PersonGroupSID  int

select top (1)
	@PersonGroupSID = x.PersonGroupSID
from
	sf.vPersonGroup x
order by
	newid()

select 
	 LastReviewUser
	,LastReviewTime
from
	sf.PersonGroup
where
	PersonGroupSID = @PersonGroupSID

exec sf.pPersonGroup#MarkReviewed
	 @PersonGroupSID	= @PersonGroupSID
	,@LastReviewUser	= N'test@softworks.ca'

select 
	 LastReviewUser
	,LastReviewTime
from
	sf.PersonGroup
where
	PersonGroupSID = @PersonGroupSID

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

		if len(ltrim(rtrim(@LastReviewUser))) = 0 set @LastReviewUser = null	-- ensure blanks are not used to bypass review user requirement!

		if @PersonGroupSID	is null set @blankParm = '@PersonGroupSID'
		if @LastReviewUser	is null	set @blankParm = '@LastReviewUser'
		
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

		exec sf.pPersonGroup#Update
			 @PersonGroupSID = @PersonGroupSID
			,@LastReviewUser = @LastReviewUser
			,@LastReviewTime = @lastReviewTime

		-- check the row count to ensure the record exists

		if @@rowcount = 0
		begin

			exec sf.pMessage#Get
				 @MessageSCD    = 'RecordNotFound'
				,@MessageText   = @errorText output
				,@DefaultText   = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
				,@Arg1          = 'PersonGroup'
				,@Arg2					= @PersonGroupSID

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
