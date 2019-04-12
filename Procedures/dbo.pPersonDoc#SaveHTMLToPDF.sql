SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pPersonDoc#SaveHTMLToPDF]
	  @PersonDocSID							int																				-- key of the email message to archive
	 ,@DocumentContent					varbinary(max)														-- the PDF binary
as
/*********************************************************************************************************************************
Procedure : Person Doc - Save HTML to PDF
Notice    : Copyright © 2018 Softworks Group Inc.
Summary   : Save the PDF binary and sets the HTML content to null (called after PDF conversion)
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Kris Dawson	| Nov 2018			|	Initial version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This procedure stores the PDF binary and nulls out the  content that was used to generate it.

Example
-------

<TestHarness>
	<Test Name="Simple" IsDefault="true" Description="Save an empty binary">
		<SQLScript>
			<![CDATA[
declare
	@personSID						int
 ,@personDocSID					int;

select top (1) @personSID	 = p.PersonSID from sf.Person p order by newid();

if @personSID is null
begin

	raiserror('** ERROR: insufficient data to run test', 18, 1);

end;
else
begin

	exec dbo.pPersonDoc#Insert
		@PersonDocSID = @personDocSID output
	 ,@PersonSID = @personSID
	 ,@DocumentHTML = '<div>some HTML</div>'
	 ,@DocumentTitle = 'My Test Document'
	 ,@FileTypeSCD = '.PDF'
	 ,@ReportEntitySID = '1000001';

	exec dbo.pPersonDoc#SaveHTMLToPdf @PersonDocSID = @personDocSID, @DocumentContent = 0x0

	delete from dbo.PersonDoc where PersonDocSID = @personDocSID; -- clean-up after test
end;
		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="ExecutionTime" Value="00:00:02" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName			= 'dbo.pPersonDoc#SaveHTMLToPDF'
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

		if @PersonDocSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD    = 'BlankParameter'
				,@MessageText   = @errorText output
				,@DefaultText   = N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1          = '@PersonDocSID'

			raiserror(@errorText, 18, 1)
		end

		if not exists (
			select
				1
			from
				dbo.PersonDoc pd
			where
				pd.PersonDocSID = @PersonDocSID
		)
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RecordNotFound'
				,@MessageText = @errorText output
				,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
				,@Arg1        = 'person doc'
				,@Arg2				= @PersonDocSID

			raiserror(@errorText, 18, 1)

		end

		update
			dbo.PersonDoc
		set
			 DocumentContent = @DocumentContent
			,DocumentHTML = null
			,UpdateUser		= @updateUser
			,UpdateTime		= @today
		where
			PersonDocSID = @PersonDocSID

	end try

	begin catch

		if @@trancount > 0 rollback
		exec @errorNo = sf.pErrorRethrow                                      -- catch the error, rollback if pending, and re-throw

	end catch

	return(@errorNo)

end
GO
