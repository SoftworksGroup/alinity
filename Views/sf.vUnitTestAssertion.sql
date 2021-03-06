SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vUnitTestAssertion]
as
/*********************************************************************************************************************************
View    : sf.vUnitTestAssertion
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for sf.UnitTestAssertion - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the sf.UnitTestAssertion table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to sf.vUnitTestAssertionExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See sf.vUnitTestAssertionExt documentation for details. To add additional content to this view, customize
the sf.vUnitTestAssertionExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 uta.UnitTestAssertionSID
	,uta.UnitTestSID
	,uta.AssertionType
	,uta.Value
	,uta.ResultSet
	,uta.RowNo
	,uta.ColumnNo
	,uta.UserDefinedColumns
	,uta.UnitTestAssertionXID
	,uta.LegacyKey
	,uta.IsDeleted
	,uta.CreateUser
	,uta.CreateTime
	,uta.UpdateUser
	,uta.UpdateTime
	,uta.RowGUID
	,uta.RowStamp
	,utax.SchemaName
	,utax.ObjectName
	,utax.TestName
	,utax.ObjectType
	,utax.UnitTestIsDefault
	,utax.UnitTestRowGUID
	,utax.IsDeleteEnabled
	,utax.IsReselected
	,utax.IsNullApplied
	,utax.zContext
from
	sf.UnitTestAssertion      uta
join
	sf.vUnitTestAssertion#Ext utax	on uta.UnitTestAssertionSID = utax.UnitTestAssertionSID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'sf.UnitTestAssertion', 'SCHEMA', N'sf', 'VIEW', N'vUnitTestAssertion', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the unit test assertion assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'VIEW', N'vUnitTestAssertion', 'COLUMN', N'UnitTestAssertionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The unit test this assertion is defined for', 'SCHEMA', N'sf', 'VIEW', N'vUnitTestAssertion', 'COLUMN', N'UnitTestSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of condition as defined in the Microsoft Visual Studio database unit testing framework: "NotEmpty ResultSet", "EmptyResultSet", ExecutionTime", "DataCheckSum", "Inconclusive", "RowCount", "ScalarValue".   Note that the "Expected Schema" condition is NOT supported.  Naming of this value must be exactly as defined in the MS tool set except that spaces within the names must be eliminated.', 'SCHEMA', N'sf', 'VIEW', N'vUnitTestAssertion', 'COLUMN', N'AssertionType'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The value or result of the test.  The value depends on the type of test - for example, for "Scalar Value" this will be the value in the expected column. For a "Row Count" test this will be the number of rows expected.  For Scalar Value tests where NULL is expected, enter "NULL" as the value.', 'SCHEMA', N'sf', 'VIEW', N'vUnitTestAssertion', 'COLUMN', N'Value'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Used to indicate which data set is being referred to when checking the test "Value" parameter for agreement.  For example, if 2 data sets are being returned the first is specified with "1" and the second by "2". ', 'SCHEMA', N'sf', 'VIEW', N'vUnitTestAssertion', 'COLUMN', N'ResultSet'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Used to indicate which row within the data set is being referred to when checking the test "Value" parameter for agreement.  For example, to indicate the value in the 1st row returned should be checked, set to "1". ', 'SCHEMA', N'sf', 'VIEW', N'vUnitTestAssertion', 'COLUMN', N'RowNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Used to indicate which column in the row and data set is being referred to when checking the test "Value" parameter for agreement.  For example, to indicate the value in the 1st column should be checked, set to "1".', 'SCHEMA', N'sf', 'VIEW', N'vUnitTestAssertion', 'COLUMN', N'ColumnNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the unit test assertion | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'VIEW', N'vUnitTestAssertion', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'VIEW', N'vUnitTestAssertion', 'COLUMN', N'UnitTestAssertionXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'VIEW', N'vUnitTestAssertion', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'VIEW', N'vUnitTestAssertion', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the unit test assertion | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'VIEW', N'vUnitTestAssertion', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this unit test assertion record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'VIEW', N'vUnitTestAssertion', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the unit test assertion | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'VIEW', N'vUnitTestAssertion', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the unit test assertion record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'VIEW', N'vUnitTestAssertion', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the unit test assertion record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vUnitTestAssertion', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'VIEW', N'vUnitTestAssertion', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name of the database schema where the object to be tested exists - e.g. "dbo", "sf", "ext", etc.', 'SCHEMA', N'sf', 'VIEW', N'vUnitTestAssertion', 'COLUMN', N'SchemaName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name of the view, procedure or function to test - without schema prefix - e.g. "vApplicationUser", "pApplicationUser#Authorize", etc.', 'SCHEMA', N'sf', 'VIEW', N'vUnitTestAssertion', 'COLUMN', N'ObjectName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A brief name to distinguish this test from others created for the object.  No spaces or special characters other than underscores. Test names follow this format: schema_objectname_testname.  For example in "sf_ApplicationUser_Authorize_ValidUser" the "ValidUser" component is the test name.', 'SCHEMA', N'sf', 'VIEW', N'vUnitTestAssertion', 'COLUMN', N'TestName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of database object the test applies to:  view, procedure or function.', 'SCHEMA', N'sf', 'VIEW', N'vUnitTestAssertion', 'COLUMN', N'ObjectType'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default unit test to assign when new records are added', 'SCHEMA', N'sf', 'VIEW', N'vUnitTestAssertion', 'COLUMN', N'UnitTestIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the unit test record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vUnitTestAssertion', 'COLUMN', N'UnitTestRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'sf', 'VIEW', N'vUnitTestAssertion', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vUnitTestAssertion', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vUnitTestAssertion', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vUnitTestAssertion', 'COLUMN', N'zContext'
GO
