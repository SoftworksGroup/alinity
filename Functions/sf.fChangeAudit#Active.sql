SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fChangeAudit#Active]
(			
   @IsActive									bit																					-- new value of the IsActive column
	,@ChangeReason							nvarchar(4000)															-- reason for the change - may be passed as null
	,@OldChangeAudit						nvarchar(max)																-- previous value of the ChangeAudit column
)
returns nvarchar(max)
as
/*********************************************************************************************************************************
ScalarF	: Change Audit
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: Returns text to store in a Change Audit column for changes to the Active status of a record
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year | Change Summary
				: ------------|------------|----------------------------------------------------------------------------------------------
				: Tim Edlund  | Dec   2012 | Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
Change Audit columns are a common modeling technique used to document changes to key values on a record.  A common example is an
"IsActive" bit on a record.  A record - e.g. a User Account - may be activated and deactivated at various times in its history.
As an alternative to using Change Data Capture to record each record state, a ChangeAudit column on the record can be used to 
record the date, time, user and reasons for the changes.  This design is used, for example, on the ApplicationUser record in the 
framework itself. 

Note that this function expects to be passed the "new" value of the IsActive bit.  The function should only be called when the
bit value is changing from the value stored in the database.  The test for the change in value must be carried out by the
caller (see sf.pApplicationUser#Update for an example of typical logic).

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

<TestHarness>
  <Test Name="fChangeAuditActiveTest" IsDefault="true" Description="Exercises the fChangeAudit#Active() function with a randomly
	selected record.">
    <SQLScript>
      <![CDATA[ 
				declare
					@ApplicationUserSID int

				select 
					@ApplicationUserSID = ApplicationUserSID
				from
					sf.ApplicationUser au
				order by
					NewID()

				select 
						sf.fChangeAudit#Active
						(
						cast(case when au.IsActive = 0 then 1 else 0 end as bit)
						,N'A new change reason'
						,au.ChangeAudit
						)													ChangeAudit
				from
					sf.ApplicationUser au
				where
					au.ApplicationUserSID = @ApplicationUserSID
			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="RowCount" ResultSet="1" Value="1"/> 
      <Assertion Type="ExecutionTime" Value="00:00:01" />
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.fChangeAuditActiveTest'
------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		 @changeAudit							nvarchar(max)                               -- return value
		,@termLabelSCD						varchar(35)																	-- used to lookup description for change in sf.TermLabel
    ,@termLabel								nvarchar(35)                                -- label returned from sf.TermLabel
		,@now											datetime = sf.fNow()												-- current time adjusted for user timezone
		,@ON											bit = cast(1 as bit)												-- constant to simplify bit casting syntax
		,@OFF											bit = cast(0 as bit)												-- constant to simplify bit casting syntax

	-- derive the term label to lookup based on whether the 
	-- record is being activated or de-activated

	if @IsActive = @ON
	begin
		set @termLabelSCD = 'ACTIVATED'
	end
	else
	begin
		set @termLabelSCD = 'DEACTIVATED'
	end

  -- lookup term label code or provide default if supported
    
  select
    @termLabel = isnull(tl.TermLabel, tl.DefaultLabel)
  from
    sf.TermLabel tl
  where
    tl.TermLabelSCD = @termLabelSCD

  if @termLabel is null
  begin
    if @termLabelSCD = 'ACTIVATED'		set @termLabel = N'Activated by'
    if @termLabelSCD = 'DEACTIVATED'  set @termLabel = N'Deactivated by'
  end

  if @termLabel is null set @termLabel = cast(@termLabelSCD as nvarchar(35))

  -- string shows current date and time, label and the current user

  set @changeAudit = @termLabel + ' ' + sf.fApplicationUserSession#UserName() + ' on ' + cast(@now as nvarchar(19))

  set @changeAudit += char(13) + char(10) + isnull(@ChangeReason + char(13) + char(10), N'') + isnull(char(13) + char(10) + @OldChangeAudit,'')

	return(@changeAudit)	

end
GO
