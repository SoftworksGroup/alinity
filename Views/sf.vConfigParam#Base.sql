SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW sf.vConfigParam#Base
as
/*********************************************************************************************************************************
View    : Config Param - Base
Notice  : Copyright © 2018 Softworks Group Inc.
Summary	: Returns base columns (no-XML) for the (sf) ConfigParam table
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Nov 2018		|	Initial version

Comments	
--------
This view is used to compare configuration parameter values between the TEST and PRODUCTION versions of the application to
check for missing values and differences in settings.  The table cannot be used since XML columns are not supported
in distributed transactions (even where not in the SELECT list).

------------------------------------------------------------------------------------------------------------------------------- */
select
	cp.ConfigParamSID
 ,cp.ConfigParamSCD
 ,cp.ConfigParamName
 ,cp.ParamValue
 ,cp.DefaultParamValue
 ,cp.DataType
 ,cp.MaxLength
 ,cp.IsReadOnly
 ,cp.UsageNotes
 ,cp.CreateUser
 ,cp.CreateTime
 ,cp.UpdateUser
 ,cp.UpdateTime
from
	sf.ConfigParam cp;
GO
