SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fApplicationEntity#SID]
(			
	@ApplicationEntitySCD					varchar(50)																-- schema.table to return SID for eg. 'sf.ApplicationUser'
)
returns int
as
/*********************************************************************************************************************************
ScalarF	: (Get) Application Entity - SID
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: Returns the Application Entity system ID of the schema.tablename passed in
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year | Change Summary
				: ------------|------------|----------------------------------------------------------------------------------------------
				: Tim Edlund  | Dec		2012 |	Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function is used to provide a system ID of an ApplicationEntity record where the ApplicationEntitySCD (system code) is known.
The system code is the SchemaName.TableName value - e.g. "sf.ApplicationUser".  If the parameter passed in is not found in
the sf.ApplicationEntity table, then NULL is returned.

<TestHarness>
  <Test Name="UpdateOne" IsDefault="true" Description="Updates the document type system code to ??? on a record selected at 
	random.  Trigger should fire to ensure the system code is resynchronized to match the foreign key.">
    <SQLScript>
      <![CDATA[

			select sf.fApplicationEntity#SID('sf.ApplicationUser')

			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="RowCount" ResultSet="1" Value="1"/> 
      <Assertion Type="ExecutionTime" Value="00:00:01" />
    </Assertions>
  </Test>
</TestHarness>
exec sf.pUnitTest#Execute
	@ObjectName = 'sf.fApplicationEntity#SID'

------------------------------------------------------------------------------------------------------------------------------- */
begin

	declare
		@applicationEntitySID					int                                     -- return value
		
	select
		@applicationEntitySID = ae.ApplicationEntitySID
	from
		sf.ApplicationEntity ae
	where
		ae.ApplicationEntitySCD = @ApplicationEntitySCD

	return(@applicationEntitySID)	

end
GO
