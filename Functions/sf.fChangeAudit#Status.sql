SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fChangeAudit#Status]
(			
   @StatusLabel								nvarchar(50)																-- new status value (label)
	,@ChangeReason							nvarchar(4000)															-- reason for the change - may be passed as null
	,@OldChangeAudit						nvarchar(max)																-- previous value of the ChangeAudit column
)
returns nvarchar(max)
as
/*********************************************************************************************************************************
ScalarF	: Change Audit - Status
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: Returns text to store in a Change Audit or Comment column for changes to a record's status
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year | Change Summary
				: ------------|------------|----------------------------------------------------------------------------------------------
				: Tim Edlund  | Mar   2013 | Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
Change Audit columns are a common modeling technique used to document changes to key values on a record.  This function supports
audit changes to a records "Status".  The function applies where status is not maintained in a child table but a simple text 
column (often named "ChangeAudit" or "Comments") stores the history of changes to status.  

Note that this function expects to be passed the "new" status value.  The function should only be called when the value is 
changing from the value stored in the database.  The test for the change in value must be carried out by the caller.

This function simplifies the creation of consistent explanatory text for each change.  A standard format documenting the
time, user and description of the change is created.  User supplied notes for the change, if any, must be passed in the 
@ChangeReason parameter. 

The function uses the sf.TermLabel table to lookup the change description. These label values can be configured to ensure a 
language-independent description is provided.  Defaults are provided - in English - where no configuration has been entered 
for a common term in sf.TermLabel. 

If there is prior content in the audit column, it must be passed @OldChangeAudit to allow a fully formatted replacement value for 
the column to be returned.  The latest change appears first in the string returned.  

Example
-------

select 
	 sf.fChangeAudit#Status
	 (
		 'NEWSTATUS'
		,N'A new change reason'
		,x.ChangeAudit
	 )													ChangeAudit
from
	dbo.SOME-TABLE x

<TestHarness>
  <Test Name="fChangeAuditStatusTest" IsDefault="true" Description="Ensures that the fChangeAudit#Status function 
	returns a result">
    <SQLScript>
      <![CDATA[
			  
			 select sf.fChangeAudit#Status
				 (
					 'NEWSTATUS'
					,N'A new change reason'
					,'Test'
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
	@ObjectName = 'sf.fChangeAudit#Status'
------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		 @changeAudit							nvarchar(max)                               -- return value
		,@termLabelSCD						varchar(35)																	-- used to lookup description for change in sf.TermLabel
    ,@termLabel								nvarchar(150)                               -- label returned from sf.TermLabel
		,@now											datetime = sf.fNow()												-- current time adjusted for user timezone

  -- lookup term label code for a status change
    
  select
    @termLabel = isnull(tl.TermLabel, tl.DefaultLabel)
  from
    sf.TermLabel tl
  where
    tl.TermLabelSCD = 'STATUS.CHANGED'

  if @termLabel is null
  begin
    set @termLabel = cast(N'Status changed to "' + @StatusLabel + '" by' as nvarchar(150))
  end
	else
	begin
		set @termLabel = cast(@termLabel + N' "' + @StatusLabel + '" by' as nvarchar(150))
	end

  -- string shows current date and time, label and the current user

  set @changeAudit = @termLabel + ' ' + sf.fApplicationUserSession#UserName() + ' on ' + cast(@now as nvarchar(19))

  set @changeAudit += char(13) + char(10) + isnull(@ChangeReason + char(13) + char(10), N'') + isnull(char(13) + char(10) + @OldChangeAudit,'')

	return(@changeAudit)	

end
GO
