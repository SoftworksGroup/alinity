SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fChangeAudit#Assignment]
(			
   @EffectiveTime             datetime																		-- datetime the change is effective - current time if null
	,@ExpiryTime								datetime																		-- datetime of expiry when action is expired
	,@ChangeReason							nvarchar(4000)															-- reason for the change - may be passed as null
	,@OldChangeAudit						nvarchar(max)																-- previous value of the ChangeAudit column
)
returns nvarchar(max)
as
/*********************************************************************************************************************************
ScalarF	: Change Audit
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: Returns text to store in a Change Audit column for changes to assignment terms on a record
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year | Change Summary
				: ------------|------------|----------------------------------------------------------------------------------------------
				: Tim Edlund  | Jul   2012 | Initial Version
					Tim Edlund	| Nov		2012 | Updated formatting to exclude effective time when same as action date
					Tim Edlund	| Dec		2012 | Updated to return formatting including previous value of the column. Remove @termLabelSCD
																		 as parameter and changed it to be derived. Changed parameters to expect datetime
																		 rather than date types.  Renamed from fChangeAudit.
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
Change Audit columns are a common modeling technique used to document the enabling and disabling of associative entities where 
multiple records are not used in the design (and no Change Data Capture is applied).  A common example is a "term" record - for 
example a person's membership on a committee. The associative entity between the Person and Committee record is typically an 
assignment with an Effective and and Expiry column for that person's term on the committee. If the record is expired but the 
person becomes a committee member a second time, the Effective can be reset and a Change Audit column can be used to document
the sequence of changes being made.  This design is used, for example, in assigning grants to users in the framework itself. 

Note that this function expects datetime data types for the effective and expiry parameters.  Modelling in the tables should 
support these data types since grants and assignments should take effect and be expired immediately as users apply these
actions in the UI.

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
  <Test Name="fChangeAuditAssignmentTest" IsDefault="true" Description="Exercises the fChangeAudit#Assignment() test with 
	a randomly selected ApplicationUserGrant record">
    <SQLScript>
      <![CDATA[

 					declare
						@ApplicationUserGrantSID int

					select 
						@ApplicationUserGrantSID = ApplicationUserGrantSID
					from
						sf.ApplicationUserGrant au			 
					order by
						NewID()
			
					select 
						 sf.fChangeAudit#Assignment
						 (
							sf.fNow()		
							,sf.fNow() + 2																														
							,N'A new change reason'
							,aug.ChangeAudit
						 )													ChangeAudit
					from
						sf.ApplicationUserGrant aug

					where
						aug.ApplicationUserGrantSID = @ApplicationUserGrantSID

			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="RowCount" ResultSet="1" Value="1"/> 
      <Assertion Type="ExecutionTime" Value="00:00:01" />
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.fChangeAudit#Assignment'
------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		 @changeAudit            nvarchar(max)                                -- return value
		,@termLabelSCD           varchar(35)																	-- used to lookup description for change in sf.TermLabel
    ,@termLabel              nvarchar(35)                                 -- label returned from sf.TermLabel
		,@now										 datetime = sf.fNow()													-- current time adjusted for user timezone

  -- default the effective time to today if not provided

  if @EffectiveTime is null set @EffectiveTime = @now

	-- derive the term label to lookup based on whether an expiry
	-- is being passed and whether prior audit contents exist

	if @ExpiryTime = @EffectiveTime																					-- when expiring future dated assignment/grant
	begin
		set @termLabelSCD = 'CANCELLED'
	end
	else if @ExpiryTime <= @now																							-- expire now
	begin
		set @termLabelSCD = 'EXPIRED'
	end
	else if @OldChangeAudit is null																					-- no prior content = first assignment
	begin
		set @termLabelSCD = 'ASSIGNED'
	end
	else
	begin
		set @termLabelSCD = 'REACTIVATED'
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
    if @termLabelSCD = 'CANCELLED'    set @termLabel = N'Cancelled by'
    if @termLabelSCD = 'ASSIGNED'     set @termLabel = N'Assigned by'
    if @termLabelSCD = 'EXPIRED'      set @termLabel = N'Expired by'         
    if @termLabelSCD = 'REACTIVATED'  set @termLabel = N'Reactivated by'
  end

  if @termLabel is null set @termLabel = cast(@termLabelSCD as nvarchar(35))

  -- string shows current datetime, label and the current user

  set @changeAudit = @termLabel + ' ' + sf.fApplicationUserSession#UserName() + ' on ' + cast(@now as nvarchar(19))

	-- if the effective time is not the current time (or close to it), include 
	-- the effective time for the change in the description, otherwise use the 
	-- "effective immediately" message

	if abs(datediff(minute, @EffectiveTime, @now)) <= 30										-- time difference > 30 (delay time in UI)
	or @termLabelSCD = 'CANCELLED'																					-- cancellations are always effective immediately
	begin

		set @termLabel = null
  
		select
			@termLabel = isnull(tl.TermLabel, tl.DefaultLabel)
		from
			sf.TermLabel tl
		where
			tl.TermLabelSCD = 'EFFECTIVE.IMMEDIATELY'

		if @termLabel is null set @termLabel = N'effective immediately'
		set @changeAudit += N' ' + @termlabel

	end
	else
	begin
		set @termLabel = null
  
		select
			@termLabel = isnull(tl.TermLabel, tl.DefaultLabel)
		from
			sf.TermLabel tl
		where
			tl.TermLabelSCD = 'EFFECTIVE'

		if @termLabel is null set @termLabel = N'effective'
		set @changeAudit += N' ' + @termlabel + ' ' + cast(@EffectiveTime as nvarchar(19))

	end

  set @changeAudit += char(13) + char(10) + isnull(@ChangeReason + char(13) + char(10), N'') + isnull(char(13) + char(10) + @OldChangeAudit,'')

	return(@changeAudit)	

end
GO
