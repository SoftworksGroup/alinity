SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fPerson#IsExamEligible]
(
  @PersonSID  int
)
returns bit
as
/*********************************************************************************************************************************
Function : Person - Is Exam Eligible
Notice    : Copyright © 2017 Softworks Group Inc.
Summary	  : Returns whether or not the registrant is eligible to write an exam
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|---------------------------------------------------------------------------------------------
				: Cory Ng   	| Apr	2018		|	Initial version
----------------------------------------------------------------------------------------------------------------------------------

Comments
--------
This function is written specifically to support V5 jurisprudence functionality before we have the exam module completed and
configured. This procedure will likely be removed once the module is in place.

The function will always return true but relies on a client specific sproc to determine if the person is eligible.

------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		 @isEligible  bit = cast(1 as bit)                                    -- indicates if person is eligible to write an exam

	if exists(select 1 from sf.vRoutine r where r.SchemaName = 'ext' and r.RoutineName = 'fPerson#IsExamEligible')
	begin
		set @isEligible = ext.fPerson#IsExamEligible(@PersonSID)
	end

	return(@isEligible)

end
GO
