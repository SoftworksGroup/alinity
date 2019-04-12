SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fChangeAudit#Comment]
(			
	 @NewComment								nvarchar(4000)															-- new comment to apply to the column - required
	,@PreviousComments					nvarchar(max)																-- previous value of the comment column (may be null)
)
returns nvarchar(max)
as
/*********************************************************************************************************************************
ScalarF	: Change Audit - Comment
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: Returns text to store in a Comment column with current user ID and date-time stamps
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year | Change Summary
				: ------------|------------|----------------------------------------------------------------------------------------------
				: Tim Edlund  | Mar   2013 | Initial Version
				: Tim Edlund  | May   2014 | Updated format to replace "or" word between ID and date time with a "|" character for
																		 better language independence.
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
Comment columns are a common modeling technique used to document changes or progressions to a records history.  This function 
supports maintaining history by providing a consistent way to format new comments into pre-existing ones - incorporating the 
current user identity and datetime with the new comment. 

Note that this function expects to be passed the "new" status value.  The value of @PreviousComments can be passed as NULL
for situations where no previous comment exists.  The latest comment appears first in the string returned.  

Example
-------

select 
	 sf.fChangeAudit#Comment
	 (
		 N'A new comment'
		,x.Comments
	 )													Comments
from
	dbo.SOME-TABLE  x



<TestHarness>
	<Test Name="fChangeAuditCommentTest" IsDefault="true" Description="Ensures that the fChangeAudit#Comment function 
	returns a result">
		<SQLScript>
			<![CDATA[
				
				select 
					sf.fChangeAudit#Comment
						(
							 N'Comment'
							,N'Test'
						) 

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1"/> 
			<Assertion Type="ExecutionTime" Value="00:00:01" />
		</Assertions>
	</Test>
</TestHarness>


exec sf.pUnitTest#Execute
	@ObjectName = 'sf.fChangeAudit#Comment'
------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		 @changeAudit							nvarchar(max)                               -- return value
		,@now											datetime = sf.fNow()												-- current time adjusted for user timezone

	-- string shows current date and time, label and the current user

	set @changeAudit = sf.fApplicationUserSession#UserName() + ' | ' + cast(@now as nvarchar(19))
	set @changeAudit += char(13) + char(10) + isnull(@NewComment + char(13) + char(10), N'') + isnull(char(13) + char(10) + @PreviousComments,'')
	return(@changeAudit)	

end
GO
