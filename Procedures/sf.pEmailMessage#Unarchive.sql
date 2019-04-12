SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pEmailMessage#Unarchive]
	 @EmailMessageSID							int																				-- key of the email message to archive
as
/*********************************************************************************************************************************
Procedure : Email Message - Unarchive
Notice    : Copyright © 2012 Softworks Group Inc.
Summary   : Unarchives the email message
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Cory Ng			| Mar 2017			|	Initial version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This procedure removes the archived time for the email message. This procedure avoids calling the API update procedure as there 
are dependencies to sending emails which violates business rules if archive time is set.

Example
-------

<TestHarness>
	<Test Name="Simple" IsDefault="true" Description="Unarchive a random sent email">
		<SQLScript>
			<![CDATA[
			
declare
	@emailMessageSID		int

select top (1)
	@emailMessageSID = em.EmailMessageSID
from
	sf.vEmailMessage em
where
	em.IsArchived = 1
order by
	newid()

exec sf.pEmailMessage#Unarchive
	 @EmailMessageSID = @emailMessageSID


		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="ExecutionTime" Value="00:00:02" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName			= 'sf.pEmailMessage#Unarchive'
	,@DefaultTestOnly = 1

-------------------------------------------------------------------------------------------------------------------------------- */

set nocount on

begin

	declare
		 @errorNo											int = 0																	-- 0 no error, <50000 SQL error, else business rule
		,@errorText                   nvarchar(4000)													-- message text (for business rule errors)
		,@ON													bit = cast(1 as bit)										-- constant for bit comparisons
		,@OFF													bit = cast(0 as bit)										-- constant for bit comparisons
		,@today												datetimeoffset(7) = sysdatetimeoffset()	-- today's date
		,@updateUser									nvarchar(75) = suser_sname()						-- current logged in user
		
	
	begin try

		-- check parameters

		if @EmailMessageSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD    = 'BlankParameter'
				,@MessageText   = @errorText output
				,@DefaultText   = N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1          = '@EmailMessageSID'

			raiserror(@errorText, 18, 1)
		end

		if not exists (
			select
				1
			from
				sf.vEmailMessage em
			where
				em.EmailMessageSID = @EmailMessageSID
			and
				em.IsArchived = @ON
		)
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RecordNotFound'
				,@MessageText = @errorText output
				,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
				,@Arg1        = 'archived email message'
				,@Arg2				= @EmailMessageSID

			raiserror(@errorText, 18, 1)

		end

		update
			sf.EmailMessage
		set
			 ArchivedTime = null
			,UpdateUser		= @updateUser
			,UpdateTime		= @today
		where
			EmailMessageSID = @EmailMessageSID

	end try

	begin catch

		if @@trancount > 0 rollback
		exec @errorNo = sf.pErrorRethrow                                      -- catch the error, rollback if pending, and re-throw

	end catch

	return(@errorNo)

end
GO
