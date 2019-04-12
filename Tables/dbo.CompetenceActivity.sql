SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CompetenceActivity] (
		[CompetenceActivitySID]       [int] IDENTITY(1000001, 1) NOT NULL,
		[CompetenceActivityLabel]     [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CompetenceActivityName]      [nvarchar](65) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UnitValue]                   [decimal](5, 2) NOT NULL,
		[HelpPrompt]                  [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsActive]                    [bit] NOT NULL,
		[UserDefinedColumns]          [xml] NULL,
		[CompetenceActivityXID]       [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                   [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                   [bit] NOT NULL,
		[CreateUser]                  [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                  [datetimeoffset](7) NOT NULL,
		[UpdateUser]                  [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                  [datetimeoffset](7) NOT NULL,
		[RowGUID]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                    [timestamp] NOT NULL,
		CONSTRAINT [uk_CompetenceActivity_CompetenceActivityLabel]
		UNIQUE
		NONCLUSTERED
		([CompetenceActivityLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_CompetenceActivity_CompetenceActivityName]
		UNIQUE
		NONCLUSTERED
		([CompetenceActivityName])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_CompetenceActivity_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_CompetenceActivity]
		PRIMARY KEY
		CLUSTERED
		([CompetenceActivitySID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Competence Activity table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceActivity', 'CONSTRAINT', N'pk_CompetenceActivity'
GO
ALTER TABLE [dbo].[CompetenceActivity]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_CompetenceActivity]
	CHECK
	([dbo].[fCompetenceActivity#Check]([CompetenceActivitySID],[CompetenceActivityLabel],[CompetenceActivityName],[UnitValue],[IsActive],[CompetenceActivityXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[CompetenceActivity]
CHECK CONSTRAINT [ck_CompetenceActivity]
GO
ALTER TABLE [dbo].[CompetenceActivity]
	ADD
	CONSTRAINT [df_CompetenceActivity_UnitValue]
	DEFAULT ((1.0)) FOR [UnitValue]
GO
ALTER TABLE [dbo].[CompetenceActivity]
	ADD
	CONSTRAINT [df_CompetenceActivity_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[CompetenceActivity]
	ADD
	CONSTRAINT [df_CompetenceActivity_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[CompetenceActivity]
	ADD
	CONSTRAINT [df_CompetenceActivity_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[CompetenceActivity]
	ADD
	CONSTRAINT [df_CompetenceActivity_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[CompetenceActivity]
	ADD
	CONSTRAINT [df_CompetenceActivity_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[CompetenceActivity]
	ADD
	CONSTRAINT [df_CompetenceActivity_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[CompetenceActivity]
	ADD
	CONSTRAINT [df_CompetenceActivity_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table records the master list of activities allowed by the organization for entry in learning plans and reporting of competence.  The activities in the list may be shared between types of competencies (sometimes called “Standards of Practice” or “Competency Bands”), or they may be unique for a single competency type.  The Unit Value defines the weighting in hours or credits for organization that use a Continuing-Education-Unit model.  For organizations that implement requirements using an Activity-Based model (which counts minimum activities required), set the Unit Value at 1.0.  To stop an out-of-date activity from being available for new assignments to competence types, mark it inactive (set IsActive = 0).  Note that when an activity is marked inactive, that prevents it from being available on new assignments but does not expiry it from existing Competence Types.  Fill in the expiry-time on the Competence-Type-Activity record to do that. ', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceActivity', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the competence activity assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceActivity', 'COLUMN', N'CompetenceActivitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the competence activity to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceActivity', 'COLUMN', N'CompetenceActivityLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the competence activity to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceActivity', 'COLUMN', N'CompetenceActivityName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'If the competence has a fixed value - e.g. "3 credits" -  enter it here.  Otherwise (when 0), the registrant will be able to enter the value of the item on their Learning Plan or Competency Claim.', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceActivity', 'COLUMN', N'UnitValue'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Help text to display to the end user explaining this Competence Type (may be referred to as a "Practice Standard" or "Competence Band".  HTML formatting is supported.', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceActivity', 'COLUMN', N'HelpPrompt'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this competence activity record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceActivity', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the competence activity | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceActivity', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceActivity', 'COLUMN', N'CompetenceActivityXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceActivity', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceActivity', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the competence activity | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceActivity', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this competence activity record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceActivity', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the competence activity | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceActivity', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the competence activity record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceActivity', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the competence activity record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceActivity', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceActivity', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Competence Activity Label column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceActivity', 'CONSTRAINT', N'uk_CompetenceActivity_CompetenceActivityLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Competence Activity Name column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceActivity', 'CONSTRAINT', N'uk_CompetenceActivity_CompetenceActivityName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceActivity', 'CONSTRAINT', N'uk_CompetenceActivity_RowGUID'
GO
ALTER TABLE [dbo].[CompetenceActivity] SET (LOCK_ESCALATION = TABLE)
GO
