SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[UnitTest] (
		[UnitTestSID]            [int] IDENTITY(1000001, 1) NOT NULL,
		[SchemaName]             [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ObjectName]             [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TestName]               [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UsageNotes]             [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[SQLScript]              [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ObjectType]             [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IsDefault]              [bit] NOT NULL,
		[UserDefinedColumns]     [xml] NULL,
		[UnitTestXID]            [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]              [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]              [bit] NOT NULL,
		[CreateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]             [datetimeoffset](7) NOT NULL,
		[UpdateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]             [datetimeoffset](7) NOT NULL,
		[RowGUID]                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]               [timestamp] NOT NULL,
		CONSTRAINT [uk_UnitTest_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_UnitTest_SchemaName_ObjectName_TestName]
		UNIQUE
		NONCLUSTERED
		([SchemaName], [ObjectName], [TestName])
		WITH FILLFACTOR=90
		ON [ApplicationIndexData],
		CONSTRAINT [pk_UnitTest]
		PRIMARY KEY
		CLUSTERED
		([UnitTestSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Unit Test table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'UnitTest', 'CONSTRAINT', N'pk_UnitTest'
GO
ALTER TABLE [sf].[UnitTest]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_UnitTest]
	CHECK
	([sf].[fUnitTest#Check]([UnitTestSID],[SchemaName],[ObjectName],[TestName],[ObjectType],[IsDefault],[UnitTestXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[UnitTest]
CHECK CONSTRAINT [ck_UnitTest]
GO
ALTER TABLE [sf].[UnitTest]
	ADD
	CONSTRAINT [df_UnitTest_SchemaName]
	DEFAULT (N'dbo') FOR [SchemaName]
GO
ALTER TABLE [sf].[UnitTest]
	ADD
	CONSTRAINT [df_UnitTest_IsDefault]
	DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [sf].[UnitTest]
	ADD
	CONSTRAINT [df_UnitTest_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[UnitTest]
	ADD
	CONSTRAINT [df_UnitTest_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[UnitTest]
	ADD
	CONSTRAINT [df_UnitTest_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[UnitTest]
	ADD
	CONSTRAINT [df_UnitTest_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[UnitTest]
	ADD
	CONSTRAINT [df_UnitTest_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[UnitTest]
	ADD
	CONSTRAINT [df_UnitTest_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_UnitTest_LegacyKey]
	ON [sf].[UnitTest] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'UnitTest', 'INDEX', N'ux_UnitTest_LegacyKey'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_UnitTest_SchemaName_ObjectName_IsDefault]
	ON [sf].[UnitTest] ([SchemaName], [ObjectName], [IsDefault])
	WHERE (([IsDefault]=CONVERT([bit],(1),(0))))
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the combination of values provided for the "Schema Name + Object Name + Is Default" columns is not duplicated where the condition: "([IsDefault]=CONVERT([bit],(1),(0)))" is met', 'SCHEMA', N'sf', 'TABLE', N'UnitTest', 'INDEX', N'ux_UnitTest_SchemaName_ObjectName_IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table stores SQL Syntax and referencing information to conduct automated unit tests on database objects: views, stored procedures and functions.  Tests may be specified to include one or more results in the sf.UnitTestAssertion table.  The SQL Syntax for tests is typically extracted from the source code for the various objects by a framework procedure: sf.pUnitTest#Extract.  To run a test that has been extracted and stored into this table - use sf.pUnitTest#Execute.  NOTE - for PRODUCTION deployments this table should be truncated (or droppred) to prevent execution of tests.  ', 'SCHEMA', N'sf', 'TABLE', N'UnitTest', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the unit test assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'UnitTest', 'COLUMN', N'UnitTestSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name of the database schema where the object to be tested exists - e.g. "dbo", "sf", "ext", etc.', 'SCHEMA', N'sf', 'TABLE', N'UnitTest', 'COLUMN', N'SchemaName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name of the view, procedure or function to test - without schema prefix - e.g. "vApplicationUser", "pApplicationUser#Authorize", etc.', 'SCHEMA', N'sf', 'TABLE', N'UnitTest', 'COLUMN', N'ObjectName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A brief name to distinguish this test from others created for the object.  No spaces or special characters other than underscores. Test names follow this format: schema_objectname_testname.  For example in "sf_ApplicationUser_Authorize_ValidUser" the "ValidUser" component is the test name.', 'SCHEMA', N'sf', 'TABLE', N'UnitTest', 'COLUMN', N'TestName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Comments describing what is being tested or how to interpret or debug results.', 'SCHEMA', N'sf', 'TABLE', N'UnitTest', 'COLUMN', N'UsageNotes'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The actual TSQL code that executes the test.  NOTE - all requirements of the test must be met within the code block because pre and post test scripts are not executed through this framework.', 'SCHEMA', N'sf', 'TABLE', N'UnitTest', 'COLUMN', N'SQLScript'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of database object the test applies to:  view, procedure or function.', 'SCHEMA', N'sf', 'TABLE', N'UnitTest', 'COLUMN', N'ObjectType'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default unit test to assign when new records are added', 'SCHEMA', N'sf', 'TABLE', N'UnitTest', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the unit test | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'UnitTest', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'UnitTest', 'COLUMN', N'UnitTestXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'UnitTest', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'UnitTest', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the unit test | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'UnitTest', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this unit test record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'UnitTest', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the unit test | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'UnitTest', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the unit test record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'UnitTest', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the unit test record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'UnitTest', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'UnitTest', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'UnitTest', 'CONSTRAINT', N'uk_UnitTest_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the combination of values provided for the "Schema Name + Object Name + Test Name" columns is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'UnitTest', 'CONSTRAINT', N'uk_UnitTest_SchemaName_ObjectName_TestName'
GO
ALTER TABLE [sf].[UnitTest] SET (LOCK_ESCALATION = TABLE)
GO
