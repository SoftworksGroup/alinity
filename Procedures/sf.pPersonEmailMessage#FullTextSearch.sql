SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sf.pPersonEmailMessage#FullTextSearch
	@PersonSID		int						-- the person whose documents will be searched
 ,@SearchString nvarchar(255) -- string to search by
as
/*********************************************************************************************************************************
Procedure PersonEmailMessage - Full text search
Notice    Copyright © 2010-2017 Softworks Group Inc.
Summary   Returns list of PersonEmailMessage ids that match the search string
-----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)			| Month Year	| Change Summary
				 : ---------------|-------------|------------------------------------------------------------------------------------------
				 : Kris Dawson		| Feb 2017		| Initial version
				 : Tim Edlund			| Apr	2019		| Applied security filter on ApplicationGrantSID in sf.EmailMessage

Comments
--------
This procedure is used by the email widget on person details to perform full text searches against the content of the
email PDFs stored in sf.PersonEmailMessage. It returns a list of SIDs that match the provided search string so that the UI can
filter the list of items shown client-side without having to reload the entire record set. 

<TestHarness>																														-- tags used by test harness generator - DO NOT REMOVE
<Test Name="Default" IsDefault="true">																	-- key word "Test" followed by name for test 
	<SQLScript>
		<![CDATA[
declare @personSID int;

select top (1) @personSID	 = PersonSID from sf.Person order by newid();

exec sf.pPersonEmailMessage#FullTextSearch
	@PersonSID = @personSID
 ,@SearchString = 'alberta';
	]]>
</SQLScript>
<Assertions>	
  <Assertion Type="ExecutionTime" Value="00:00:03" />
</Assertions>
</Test>
</TestHarness>

exec sf.pUnitTest#Execute																								
	 @ObjectName = N'sf.pPersonEmailMessage#FullTextSearch'
	,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */
begin
	set nocount on;

	declare
		@errorNo	 int					 = 0																			-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText nvarchar(4000)																					-- message text (for business rule errors)
	 ,@blankParm nvarchar(100)																					-- error checking buffer for required parameters
	 ,@ON				 bit					 = cast(1 as bit)													-- constant for bit comparisons = 1
	 ,@userName	 nvarchar(75)	 = sf.fApplicationUserSession#UserName(); -- sf.ApplicationUser UserName for the current user

	begin try

		-- check parameters
		if @SearchString is null or @SearchString = ''
			set @blankParm = N'SearchString';

		if @PersonSID is null set @blankParm = N'PersonSID';

		if @SearchString is null
		begin
			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = @blankParm;

			raiserror(@errorText, 18, 1);
		end;

		-- add quotes and "*" for compatibility with the "contains" full-text operator
		if right(@SearchString, 1) <> '*'
		begin
			set @SearchString += '*';
		end;

		set @SearchString = replace(@SearchString, '"', ''); -- strip double quotes then re-add at ends
		set @SearchString = '"' + @SearchString + '"';

		select
			pem.PersonEmailMessageSID
		from
			sf.PersonEmailMessage pem
		join
			sf.EmailMessage				em on pem.EmailMessageSID		 = em.EmailMessageSID
		left outer join
			sf.ApplicationGrant		ag on em.ApplicationGrantSID = ag.ApplicationGrantSID
		where
			(
				ag.ApplicationGrantSID is null or sf.fIsGrantedToUserName(ag.ApplicationGrantSCD, @userName) = @ON
			)
			and pem.PersonSID																																							 = @PersonSID
			and contains((pem.EmailDocument, pem.Subject), @SearchString);
	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);
end;
GO
