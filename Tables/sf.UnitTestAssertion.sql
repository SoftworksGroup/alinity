SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[UnitTestAssertion] (
		[UnitTestAssertionSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[UnitTestSID]              [int] NOT NULL,
		[AssertionType]            [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[Value]                    [nvarchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ResultSet]                [tinyint] NOT NULL,
		[RowNo]                    [int] NOT NULL,
		[ColumnNo]                 [int] NOT NULL,
		[UserDefinedColumns]       [xml] NULL,
		[UnitTestAssertionXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                [bit] NOT NULL,
		[CreateUser]               [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]               [datetimeoffset](7) NOT NULL,
		[UpdateUser]               [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]               [datetimeoffset](7) NOT NULL,
		[RowGUID]                  [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                 [timestamp] NOT NULL,
		CONSTRAINT [uk_UnitTestAssertion_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		WITH FILLFACTOR=90
		ON [ApplicationIndexData],
		CONSTRAINT [pk_UnitTestAssertion]
		PRIMARY KEY
		CLUSTERED
		([UnitTestAssertionSID])
	WITH FILLFACTOR=90
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Unit Test Assertion table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'UnitTestAssertion', 'CONSTRAINT', N'pk_UnitTestAssertion'
GO
ALTER TABLE [sf].[UnitTestAssertion]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_UnitTestAssertion]
	CHECK
	([sf].[fUnitTestAssertion#Check]([UnitTestAssertionSID],[UnitTestSID],[AssertionType],[Value],[ResultSet],[RowNo],[ColumnNo],[UnitTestAssertionXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[UnitTestAssertion]
CHECK CONSTRAINT [ck_UnitTestAssertion]
GO
ALTER TABLE [sf].[UnitTestAssertion]
	ADD
	CONSTRAINT [df_UnitTestAssertion_ResultSet]
	DEFAULT ((0)) FOR [ResultSet]
GO
ALTER TABLE [sf].[UnitTestAssertion]
	ADD
	CONSTRAINT [df_UnitTestAssertion_RowNo]
	DEFAULT ((0)) FOR [RowNo]
GO
ALTER TABLE [sf].[UnitTestAssertion]
	ADD
	CONSTRAINT [df_UnitTestAssertion_ColumnNo]
	DEFAULT ((0)) FOR [ColumnNo]
GO
ALTER TABLE [sf].[UnitTestAssertion]
	ADD
	CONSTRAINT [df_UnitTestAssertion_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[UnitTestAssertion]
	ADD
	CONSTRAINT [df_UnitTestAssertion_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[UnitTestAssertion]
	ADD
	CONSTRAINT [df_UnitTestAssertion_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[UnitTestAssertion]
	ADD
	CONSTRAINT [df_UnitTestAssertion_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[UnitTestAssertion]
	ADD
	CONSTRAINT [df_UnitTestAssertion_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[UnitTestAssertion]
	ADD
	CONSTRAINT [df_UnitTestAssertion_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[UnitTestAssertion]
	WITH CHECK
	ADD CONSTRAINT [fk_UnitTestAssertion_UnitTest_UnitTestSID]
	FOREIGN KEY ([UnitTestSID]) REFERENCES [sf].[UnitTest] ([UnitTestSID])
	ON DELETE CASCADE
ALTER TABLE [sf].[UnitTestAssertion]
	CHECK CONSTRAINT [fk_UnitTestAssertion_UnitTest_UnitTestSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the unit test system ID column in the Unit Test Assertion table match a unit test system ID in the Unit Test table. It also ensures that when a record in the Unit Test table is deleted, matching child records in the Unit Test Assertion table are deleted as well. Finally, the constraint blocks changes to the value of the unit test system ID column in the Unit Test if matching child records exist in Unit Test Assertion.', 'SCHEMA', N'sf', 'TABLE', N'UnitTestAssertion', 'CONSTRAINT', N'fk_UnitTestAssertion_UnitTest_UnitTestSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_UnitTestAssertion_LegacyKey]
	ON [sf].[UnitTestAssertion] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'UnitTestAssertion', 'INDEX', N'ux_UnitTestAssertion_LegacyKey'
GO
CREATE NONCLUSTERED INDEX [ix_UnitTestAssertion_UnitTestSID_UnitTestAssertionSID]
	ON [sf].[UnitTestAssertion] ([UnitTestSID], [UnitTestAssertionSID])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Unit Test SID foreign key column and avoids row contention on (parent) Unit Test updates', 'SCHEMA', N'sf', 'TABLE', N'UnitTestAssertion', 'INDEX', N'ix_UnitTestAssertion_UnitTestSID_UnitTestAssertionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table stores the assertions (expected results) for testing syntax established in the sf.UnitTest table.  Tests may be specified to include one or more results in this table.  The "TestType" value must match one of the test types supported in the current version of Visual Studio database unit testing framework.  The SQL Syntax for tests and their assertions is typically extracted from the source code for the various objects by the procedure: sf.pUnitTest#Extract.', 'SCHEMA', N'sf', 'TABLE', N'UnitTestAssertion', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the unit test assertion assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'UnitTestAssertion', 'COLUMN', N'UnitTestAssertionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The unit test this assertion is defined for', 'SCHEMA', N'sf', 'TABLE', N'UnitTestAssertion', 'COLUMN', N'UnitTestSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of condition as defined in the Microsoft Visual Studio database unit testing framework: "NotEmpty ResultSet", "EmptyResultSet", ExecutionTime", "DataCheckSum", "Inconclusive", "RowCount", "ScalarValue".   Note that the "Expected Schema" condition is NOT supported.  Naming of this value must be exactly as defined in the MS tool set except that spaces within the names must be eliminated.', 'SCHEMA', N'sf', 'TABLE', N'UnitTestAssertion', 'COLUMN', N'AssertionType'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The value or result of the test.  The value depends on the type of test - for example, for "Scalar Value" this will be the value in the expected column. For a "Row Count" test this will be the number of rows expected.  For Scalar Value tests where NULL is expected, enter "NULL" as the value.', 'SCHEMA', N'sf', 'TABLE', N'UnitTestAssertion', 'COLUMN', N'Value'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Used to indicate which data set is being referred to when checking the test "Value" parameter for agreement.  For example, if 2 data sets are being returned the first is specified with "1" and the second by "2". ', 'SCHEMA', N'sf', 'TABLE', N'UnitTestAssertion', 'COLUMN', N'ResultSet'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Used to indicate which row within the data set is being referred to when checking the test "Value" parameter for agreement.  For example, to indicate the value in the 1st row returned should be checked, set to "1". ', 'SCHEMA', N'sf', 'TABLE', N'UnitTestAssertion', 'COLUMN', N'RowNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Used to indicate which column in the row and data set is being referred to when checking the test "Value" parameter for agreement.  For example, to indicate the value in the 1st column should be checked, set to "1".', 'SCHEMA', N'sf', 'TABLE', N'UnitTestAssertion', 'COLUMN', N'ColumnNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the unit test assertion | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'UnitTestAssertion', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'UnitTestAssertion', 'COLUMN', N'UnitTestAssertionXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'UnitTestAssertion', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'UnitTestAssertion', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the unit test assertion | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'UnitTestAssertion', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this unit test assertion record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'UnitTestAssertion', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the unit test assertion | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'UnitTestAssertion', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the unit test assertion record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'UnitTestAssertion', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the unit test assertion record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'UnitTestAssertion', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'UnitTestAssertion', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'UnitTestAssertion', 'CONSTRAINT', N'uk_UnitTestAssertion_RowGUID'
GO
ALTER TABLE [sf].[UnitTestAssertion] SET (LOCK_ESCALATION = TABLE)
GO
