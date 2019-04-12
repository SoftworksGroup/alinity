SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[xApplicationUser#ApplicationGrants]
as
/*********************************************************************************************************************************
View    : Application User - Application Grants
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: View created for reference in the Entity Framework only - do not use for data access or reporting!
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year			| Change Summary
				: ------------|-----------------|-----------------------------------------------------------------------------------------
				: Tim Edlund	| July 2011				| Initial version

Comments	
--------
This view is used in constructing user interface components. The view does not provide actual data to the application. It is
used to define the structure for a manually created entity used to manage the many-to-many relationship between:

  sf.ApplicationUser 
  and 
  sf.ApplicationGrant 
  through
  sf.ApplicationUserGrant

The manually created entity used to manage the assignment records is not populated by this view but rather by a stored procedure:
  sf.pApplicationUser#GetApplicationGrants. 

The binding of the manually created entity to this view structure is necessary in order for validations to work correctly 
(otherwise a Complex Type could be used on its own).  The prefix "x" is used on the view name to indicate the view does not 
provide any data. 

Example
-------

select 
  * 
from 
  sf.xApplicationUser#ApplicationGrants

------------------------------------------------------------------------------------------------------------------------------- */
select
   x.ApplicationUserSID                                                                   -- PK of entity being managed
  ,cast(N'<tag></tag>' as xml)                                            Assignments     -- placeholder for XML containing rows assigned and not assigned
  ,sf.fNow()						                                                  EffectiveTime   -- placeholder for effective time of changes 
  ,cast(null as nvarchar(max))	                                          ChangeReason    -- placeholder for audit information describing change
from
  sf.ApplicationUser x
where
  0 = 1                                                                   -- THIS VIEW IS USED TO DEFINE STRUCTURE ONLY! 
GO
