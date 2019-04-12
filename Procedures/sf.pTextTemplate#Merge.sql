SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pTextTemplate#Merge]
	@TextTemplate							 nvarchar(max)		output				-- string with [@Column1] tokens to make replacements in
 ,@ApplicationEntitySCD			 varchar(50)										-- schema.table name of the source entity for replacements
 ,@RecordSID								 int														-- primary key value of the source of replacements
 ,@PersonEmailMessageRowGUID uniqueidentifier = null				-- GUID reference used in links for emails
 ,@PersonTextMessageRowGUID	 uniqueidentifier = null				-- GUID reference used in links for text messages
 ,@ReplacementSQL						 nvarchar(max)		= null output -- dynamic SQL string to retrieve replacement values 
as
/*********************************************************************************************************************************
Procedure : Note Template Merge
Notice    : Copyright © 2015 Softworks Group Inc.
Summary   : Wrapper for call to sf.TextTemplate#MergeWithMap. Loads mapping table content.
						
History   : Author(s)   | Month Year  | Change Summary
					: ------------|-------------|-------------------------------------------------------------------------------------------
					: Tim Edlund  | Oct 2015    | Initial version

Comments  
--------
This procedure is a wrapper for a revised version of this procedure which now accepts a table of merge tokens and their position
in the template.  The new procedure is sf.pTextTemplate#MergeWithMap which this procedure calls after first loading a mapping
table.  

This procedure is provided to minimize impact on routines which previously called #Merge and which do not parse and load a
token mapping table before making the call.  

Example
-------
<TestHarness>
	<Test Name="Demo" IsDefault="true" Description="Provides template string with several replacement tokens including one
	invalid one. Selects a sf.Person record at random for replacements and tests to ensure all tokens except the invalid one
	are replaced.">
		<SQLScript>
			<![CDATA[

				declare
						@string			nvarchar(max) 
					,@personSID		int

				select top (1) 
						@personSID = p.PersonSID
					,@string = N'The name is:[@FirstName] [@MiddleNames] [@LastName]. The record number is: #[@PersonSID] and it was'
					+ ' created [@CreateTime] and last updated by [@UpdateUser]. This [@InvalidToken] is not replaced!  The current '
					+ ' date is [@@Date] and the current time is [@@Time]'
				from 
					sf.Person p 
				order by 
					newid()
	 
				exec sf.pTextTemplate#Merge
						@TextTemplate							= @string output
					,@ApplicationEntitySCD			= 'sf.Person'
					,@RecordSID				= @personSID


			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1"/> 
			<Assertion Type="ScalarValue" ResultSet="1" RowNo="1" ColNo="1" Value="OK"/> 
			<Assertion Type="ExecutionTime" Value="00:00:02" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.pTextTemplate#Merge'

-------------------------------------------------------------------------------------------------------------------------------- */

set nocount on;

begin

	declare
		@errorNo	 int = 0				-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText nvarchar(4000) -- message text (for business rule errors)
	 ,@tokenMap	 sf.TokenMap;		-- map of tokens in template to speed up parse logic

	set @TextTemplate = @TextTemplate; -- populate in all code paths; input/output parameter
	set @ReplacementSQL = @ReplacementSQL;

	begin try

		-- other parameter checking is handled by #MergeWithMap

		if @TextTemplate is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = '@TextTemplate';

			raiserror(@errorText, 18, 1);
		end;

		-- loading mapping table

		insert
			@tokenMap (StartPosition, EndPosition, MergeToken)
		exec sf.pTextTemplate#GetMap @TextTemplate = @TextTemplate;

		-- call main merge sproc

		exec sf.pTextTemplate#MergeWithMap
			@TextTemplate = @TextTemplate output
		 ,@TokenMap = @tokenMap
		 ,@ApplicationEntitySCD = @ApplicationEntitySCD
		 ,@RecordSID = @RecordSID
		 ,@PersonEmailMessageRowGUID = @PersonEmailMessageRowGUID
		 ,@PersonTextMessageRowGUID = @PersonTextMessageRowGUID
		 ,@ReplacementSQL = @ReplacementSQL output;

	end try

	begin catch
		if @@trancount > 0 rollback;
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);

end;
GO
