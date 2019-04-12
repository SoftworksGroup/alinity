SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vApplicationEntity#Ext]
as
/*********************************************************************************************************************************
View    : sf.vApplicationEntity#Ext
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : extends the sf.ApplicationEntity base entity with calculated values, entity properties and columns from related tables
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This view includes the primary key of the table but no other content from the base entity. Descriptive columns from parent tables
and a set of columns required by the Entity Framework (EF) are provided. The content of this view is joined with the table columns
to provide complete attribution of the entity in the view vApplicationEntity (referred to as the "entity" view in SGI documentation).

Columns required to support the EF include constants passed by client and middle tier modules into the table API procedures as
parameters. These values control the insert/update/delete behaviour of the sprocs. For example: the IsNullApplied bit is set ON
in the view so that update procedures overwrite column values when matching parameters are NULL on calls from the client tier.
The default for this column in the call signature of the sproc is 0 (off) so that calls from the back-end do not overwrite with
null values.  The zContext XML value is always null but is required for binding to sproc calls using EF and RIA.

You can add additional columns, joins and examples of calling syntax, by placing them between the code tag pairs provided.  Items
placed within code tag pairs are preserved on regeneration.  Note that all additions to this view become part of the base product
and deploy for all client configurations.  This view is NOT an extension point for client-specific configurations.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 ae.ApplicationEntitySID
	,sf.fApplicationEntity#IsDeleteEnabled(ae.ApplicationEntitySID)         IsDeleteEnabled						--# Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)
	,cast(1 as tinyint)                                                     IsReselected							-- parameter for sproc calls through EF - reselects row as dataset
	,cast(1 as bit)                                                         IsNullApplied							-- parameter for sproc calls through EF - writes null parameter values
	,cast(null as xml)                                                      zContext									-- parameter for sproc calls through EF - utility parameter for customization
  --! <MoreColumns>
  ,zt.SchemaName                                                          BaseTableSchemaName
  ,zt.TableName                                                           BaseTableName
  ,zt.ObjectID                                                            BaseTableObjectID
  ,zt.[Description]                                                       BaseTableDescription
	,ztrc.TotalRows
  ,isnull(zbre.BusinessRuleErrorCount,0)                                  BusinessRuleErrorCount
  ,isnull(zbr.PendingBusinessRuleCount,0)                                 PendingBusinessRuleCount
  ,isnull(zbr.ClientBusinessRuleCount,0)                                  ClientBusinessRuleCount
  ,isnull(zbr.MandatoryBusinessRuleCount,0)                               MandatoryBusinessRuleCount
  ,isnull(zbr.OptionalBusinessRuleCount,0)                                OptionalBusinessRuleCount
,isnull(zbr.BusinessRuleCount,0)                                        BusinessRuleCount
  ,cast
  (
    case			when zcc.ConstraintName is not null then 1
      else 0
    end
    as bit
  )                    IsConstraintEnabled
 ,cast
  (    case
      when zr.RoutineName is not null then 1
      else 0
    end
    as bit
  )                                                                       IsCheckFunctionDeployed
 ,cast
  (
    case
      when zrx.RoutineName is not null then 1
      else 0
    end
    as bit
  )                                                                       IsExtCheckFunctionDeployed
 ,zrx.SchemaAndRoutineName																								ExtendedFunctionName																		-- #The name of the stored procedure (function) to enforce business rules. A table check constraint uses this function to apply the logic.
 ,cast
  (
    case
      when zcc.ConstraintName is null         then 'x'										-- if no constraint,all BRs on table are turned off																										
      when zr.RoutineName     is null         then 'x'										-- no check function in place - BR are turned off
      when zrx.RoutineName    is null																			-- no extension routine and no rules are defined in main routine (nothing to check)
        and zbr.ClientBusinessRuleCount > 0   then 'x'										
      when zbre.BusinessRuleErrorCount  > 0   then 'e'										-- errors exist from last check
      else                                         'v'										-- entity is verified
    end
    as char(1)
  )                                                                       DataStatus																							--#Defines the status of business rules on the table: (x) disabled or none exist, (e) errors exist, (v) verified (data complies)
 ,cast
  (
    case
      when zcc.ConstraintName is null         then 'NoConstraint'
      when zr.RoutineName     is null         then 'NoBaseFunction'
      when zrx.RoutineName    is null
        and zbr.ClientBusinessRuleCount > 0   then 'NoExtFunction'
      when zbre.BusinessRuleErrorCount  > 0   then 'Errors'
      else                                         'Valid'
    end
    as nvarchar(15)
  )                                                                       DataStatusLabel								-- TODO: technical debt | Feb 2017
 ,cast
  (
    case
      when zcc.ConstraintName is null         then  'The check constraint enforcing business rules is missing!  Run verify to correct.'
      when zr.RoutineName     is null         then  'The base check function for this entity is missing.  Contact support.'
      when zrx.RoutineName    is null
        and zbr.ClientBusinessRuleCount > 0   then  'Client specific rules are defined but no extended function exists. Contact support.'
      when zbre.BusinessRuleErrorCount  > 0   then  ltrim(zbre.BusinessRuleErrorCount) + ' Error(s) exist(s).  Correct error(s) and run verify.'
      else                                          'No errors are reported for the data in this entity.'
    end
    as nvarchar(150)
  )                                                                       DataStatusNote
 ,replace(ae.ApplicationEntitySCD,'.','')                                 ReflectionApplicationEntitySCD  -- used in business rule fix window for reflection - can't have punctuation
	--! </MoreColumns>
from
	sf.ApplicationEntity ae
--! <MoreJoins>
left outer join
  sf.vTable zt					 on ae.ApplicationEntitySCD = zt.SchemaAndTableName                         -- provides relationship to the base table of the entity
left outer join
	sf.vTableRowCount ztrc on zt.SchemaName = ztrc.SchemaName and zt.TableName = ztrc.TableName				-- provides row count
left outer join
  (
  select
     y.ApplicationEntitySID
    ,isnull(count(1),0)                                                   BusinessRuleErrorCount    -- all errors for the entity
  from
    sf.BusinessRuleError x
  join
    sf.BusinessRule       y on x.BusinessRuleSID = y.BusinessRuleSID
  group by
    y.ApplicationEntitySID
  ) zbre on ae.ApplicationEntitySID = zbre.ApplicationEntitySID
left outer join
  (
  select
     x.ApplicationEntitySID                                                                         -- counts of rules by type
    ,sum(case when x.BusinessRuleStatus = 'p'  or x.BusinessRuleStatus = '!'
        then 1 else 0  end)                                               PendingBusinessRuleCount  -- include "in-process" in pending count
    ,sum(case when m.MessageSCD like 'CBR.%' then 1 else 0  end)          ClientBusinessRuleCount   -- client-specific rule count
    ,sum(case when m.MessageSCD like 'MBR.%' then 1 else 0  end)     MandatoryBusinessRuleCount
    ,sum
(
      case when m.MessageSCD not like 'CBR.%' and m.MessageSCD not like 'MBR.%'
      then 1 else 0  end
   )         OptionalBusinessRuleCount
    ,count(1)                                                             BusinessRuleCount
  from
    sf.BusinessRule x  join
    sf.[Message]    m on x.MessageSID = m.MessageSID
  group by
    x.ApplicationEntitySID
  ) zbr on ae.ApplicationEntitySID = zbr.ApplicationEntitySID
left outer join
  sf.vCheckConstraint         zcc
  on
    zt.SchemaAndTableName = zcc.SchemaAndTableName
  and
    N'ck_' + zt.TableName =  zcc.ConstraintName                                                     -- determine if constraint is deployed/exists
left outer join
  sf.vRoutine                 zr
  on
  zt.SchemaName + N'.f' + zt.TableName + N'#Check' =  zr.SchemaAndRoutineName                       -- determine if BASE check function is deployed
left outer join
  sf.vRoutine                 zrx
  on
  N'ext.f' + zt.TableName + N'#Check' =  zrx.SchemaAndRoutineName                                   -- determine if EXTended check function is deployed
--! </MoreJoins>
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the application entity assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'VIEW', N'vApplicationEntity#Ext', 'COLUMN', N'ApplicationEntitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'sf', 'VIEW', N'vApplicationEntity#Ext', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vApplicationEntity#Ext', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vApplicationEntity#Ext', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vApplicationEntity#Ext', 'COLUMN', N'zContext'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Defines the status of business rules on the table: (x) disabled or none exist, (e) errors exist, (v) verified (data complies)', 'SCHEMA', N'sf', 'VIEW', N'vApplicationEntity#Ext', 'COLUMN', N'DataStatus'
GO
