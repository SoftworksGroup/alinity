SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fTaskQueueSubscriber]
(
	@TaskQueueSubscriberSID	 int
)
returns table
return
/*********************************************************************************************************************************
TableFcn: Returns the Task Queue Subscriber (entity) for a given SID value
Notice  : Copyright ©2014 Softworks Group Inc.
Summary	: Returns one record from the vTaskQueueSubscriber entity view matching the primary key value passed in
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund  | June	2014    |	Initial Version
				:	Adam Panter	|	June 	2014		| Updating test to create a Task Queue first
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function is used in calls from product schemas (DBO) requiring task view subscriber details to show in drop-down lists for
task assignments. The function is located in the framework to support automatic updating on regeneration of EF objects based on
use of the XML-style tags surrounding the column list (see syntax below)

Example
-------

<TestHarness>
  <Test Name="SunnyDay" IsDefault="true" Description="Selects a columns for a random Task Queue Subscriber entity record.">
    <SQLScript>
      <![CDATA[

declare
	 @effectiveTime						datetimeoffset
	,@taskQueueSID						int
	,@label										nvarchar(25)

set @effectiveTime					= getdate()
set @label									= 'Test' + Cast(@effectiveTime as nvarchar)

exec sf.pTaskQueue#Insert
	 @TaskQueueLabel					= @label
	,@UsageNotes							= 'Test'
	,@IsOpenSubscription			= 0
	,@ApplicationUserSID			= 1000001
	,@IsDailySummaryEmailed		= 0

select top (1)
	@taskQueueSID = TaskQueueSID
from
	sf.TaskQueue

exec sf.pTaskQueueSubscriber#insert
	 @EffectiveTime						= @effectiveTime
	,@IsNewTaskEmailed				=	0
	,@IsDailySummaryEmailed		=	0
	,@TaskQueueSID						= @taskQueueSID
	,@ApplicationUserSID			= 1000001

declare
	@sid				int

select top (1)
	@sid = tqs.TaskQueueSubscriberSID
from
	sf.TaskQueueSubscriber tqs
order by
	newid()

select
	*
from
	sf.fTaskQueueSubscriber(@sid)

]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="RowCount" ResultSet="1" Value="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:01" />
    </Assertions>
  </Test>
  <Test Name="NotFound" Description="Tests to ensure no record is returned if the SID is invalid. This should not return an error.">
    <SQLScript>
      <![CDATA[

select
	*
from
	sf.fTaskQueueSubscriber(-1)

]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="RowCount" ResultSet="1" Value="0"/>
      <Assertion Type="ExecutionTime" Value="00:00:01" />
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute @ObjectName = 'sf.fTaskQueueSubscriber'

------------------------------------------------------------------------------------------------------------------------------- */

select
   --!<ColumnList DataSource="sf.vTaskQueueSubscriber" Alias="tqs">
    tqs.TaskQueueSubscriberSID
   ,tqs.TaskQueueSID
   ,tqs.ApplicationUserSID
   ,tqs.EffectiveTime
   ,tqs.ExpiryTime
   ,tqs.IsNewTaskEmailed
   ,tqs.IsDailySummaryEmailed
   ,tqs.ChangeAudit
   ,tqs.UserDefinedColumns
   ,tqs.TaskQueueSubscriberXID
   ,tqs.LegacyKey
   ,tqs.IsDeleted
   ,tqs.CreateUser
   ,tqs.CreateTime
   ,tqs.UpdateUser
   ,tqs.UpdateTime
   ,tqs.RowGUID
   ,tqs.RowStamp
   ,tqs.PersonSID
   ,tqs.CultureSID
   ,tqs.AuthenticationAuthoritySID
   ,tqs.UserName
   ,tqs.LastReviewTime
   ,tqs.LastReviewUser
   ,tqs.IsPotentialDuplicate
   ,tqs.IsTemplate
   ,tqs.GlassBreakPassword
   ,tqs.LastGlassBreakPasswordChangeTime
   ,tqs.ApplicationUserIsActive
   ,tqs.AuthenticationSystemID
   ,tqs.ApplicationUserRowGUID
   ,tqs.TaskQueueLabel
   ,tqs.TaskQueueCode
   ,tqs.IsAutoAssigned
   ,tqs.IsOpenSubscription
   ,tqs.TaskQueueApplicationUserSID
   ,tqs.TaskQueueIsActive
   ,tqs.TaskQueueIsDefault
   ,tqs.TaskQueueRowGUID
   ,tqs.IsActive
   ,tqs.IsPending
   ,tqs.ChangeReason
   ,tqs.IsDeleteEnabled
   ,tqs.IsReselected
   ,tqs.IsNullApplied
   ,tqs.zContext
   ,tqs.ApplicationUserDisplayName
  --!</ColumnList>
from
	sf.vTaskQueueSubscriber tqs
where
	tqs.TaskQueueSubscriberSID = @TaskQueueSubscriberSID
GO
