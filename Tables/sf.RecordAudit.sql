SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[RecordAudit] (
		[RecordAuditSID]                [int] IDENTITY(1000001, 1) NOT NULL,
		[ApplicationUserSessionSID]     [int] NOT NULL,
		[ApplicationPageSID]            [int] NOT NULL,
		[AuditActionSID]                [int] NOT NULL,
		[IsGlassBreak]                  [bit] NOT NULL,
		[ContextGUID]                   [uniqueidentifier] NOT NULL,
		[UserDefinedColumns]            [xml] NULL,
		[RecordAuditXID]                [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                     [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                     [bit] NOT NULL,
		[CreateUser]                    [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                    [datetimeoffset](7) NOT NULL,
		[UpdateUser]                    [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                    [datetimeoffset](7) NOT NULL,
		[RowGUID]                       [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                      [timestamp] NOT NULL,
		CONSTRAINT [uk_RecordAudit_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_RecordAudit]
		PRIMARY KEY
		CLUSTERED
		([RecordAuditSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Record Audit table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'RecordAudit', 'CONSTRAINT', N'pk_RecordAudit'
GO
ALTER TABLE [sf].[RecordAudit]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_RecordAudit]
	CHECK
	([sf].[fRecordAudit#Check]([RecordAuditSID],[ApplicationUserSessionSID],[ApplicationPageSID],[AuditActionSID],[IsGlassBreak],[ContextGUID],[RecordAuditXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[RecordAudit]
CHECK CONSTRAINT [ck_RecordAudit]
GO
ALTER TABLE [sf].[RecordAudit]
	ADD
	CONSTRAINT [df_RecordAudit_IsGlassBreak]
	DEFAULT ((0)) FOR [IsGlassBreak]
GO
ALTER TABLE [sf].[RecordAudit]
	ADD
	CONSTRAINT [df_RecordAudit_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[RecordAudit]
	ADD
	CONSTRAINT [df_RecordAudit_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[RecordAudit]
	ADD
	CONSTRAINT [df_RecordAudit_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[RecordAudit]
	ADD
	CONSTRAINT [df_RecordAudit_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[RecordAudit]
	ADD
	CONSTRAINT [df_RecordAudit_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[RecordAudit]
	ADD
	CONSTRAINT [df_RecordAudit_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[RecordAudit]
	WITH CHECK
	ADD CONSTRAINT [fk_RecordAudit_ApplicationPage_ApplicationPageSID]
	FOREIGN KEY ([ApplicationPageSID]) REFERENCES [sf].[ApplicationPage] ([ApplicationPageSID])
ALTER TABLE [sf].[RecordAudit]
	CHECK CONSTRAINT [fk_RecordAudit_ApplicationPage_ApplicationPageSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the application page system ID column in the Record Audit table match a application page system ID in the Application Page table. It also ensures that records in the Application Page table cannot be deleted if matching child records exist in Record Audit. Finally, the constraint blocks changes to the value of the application page system ID column in the Application Page if matching child records exist in Record Audit.', 'SCHEMA', N'sf', 'TABLE', N'RecordAudit', 'CONSTRAINT', N'fk_RecordAudit_ApplicationPage_ApplicationPageSID'
GO
ALTER TABLE [sf].[RecordAudit]
	WITH CHECK
	ADD CONSTRAINT [fk_RecordAudit_ApplicationUserSession_ApplicationUserSessionSID]
	FOREIGN KEY ([ApplicationUserSessionSID]) REFERENCES [sf].[ApplicationUserSession] ([ApplicationUserSessionSID])
ALTER TABLE [sf].[RecordAudit]
	CHECK CONSTRAINT [fk_RecordAudit_ApplicationUserSession_ApplicationUserSessionSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the application user session system ID column in the Record Audit table match a application user session system ID in the Application User Session table. It also ensures that records in the Application User Session table cannot be deleted if matching child records exist in Record Audit. Finally, the constraint blocks changes to the value of the application user session system ID column in the Application User Session if matching child records exist in Record Audit.', 'SCHEMA', N'sf', 'TABLE', N'RecordAudit', 'CONSTRAINT', N'fk_RecordAudit_ApplicationUserSession_ApplicationUserSessionSID'
GO
ALTER TABLE [sf].[RecordAudit]
	WITH CHECK
	ADD CONSTRAINT [fk_RecordAudit_AuditAction_AuditActionSID]
	FOREIGN KEY ([AuditActionSID]) REFERENCES [sf].[AuditAction] ([AuditActionSID])
ALTER TABLE [sf].[RecordAudit]
	CHECK CONSTRAINT [fk_RecordAudit_AuditAction_AuditActionSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the audit action system ID column in the Record Audit table match a audit action system ID in the Audit Action table. It also ensures that records in the Audit Action table cannot be deleted if matching child records exist in Record Audit. Finally, the constraint blocks changes to the value of the audit action system ID column in the Audit Action if matching child records exist in Record Audit.', 'SCHEMA', N'sf', 'TABLE', N'RecordAudit', 'CONSTRAINT', N'fk_RecordAudit_AuditAction_AuditActionSID'
GO
CREATE NONCLUSTERED INDEX [ix_RecordAudit_ApplicationPageSID_RecordAuditSID]
	ON [sf].[RecordAudit] ([ApplicationPageSID], [RecordAuditSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Application Page SID foreign key column and avoids row contention on (parent) Application Page updates', 'SCHEMA', N'sf', 'TABLE', N'RecordAudit', 'INDEX', N'ix_RecordAudit_ApplicationPageSID_RecordAuditSID'
GO
CREATE NONCLUSTERED INDEX [ix_RecordAudit_ApplicationUserSessionSID_RecordAuditSID]
	ON [sf].[RecordAudit] ([ApplicationUserSessionSID], [RecordAuditSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Application User Session SID foreign key column and avoids row contention on (parent) Application User Session updates', 'SCHEMA', N'sf', 'TABLE', N'RecordAudit', 'INDEX', N'ix_RecordAudit_ApplicationUserSessionSID_RecordAuditSID'
GO
CREATE NONCLUSTERED INDEX [ix_RecordAudit_AuditActionSID_RecordAuditSID]
	ON [sf].[RecordAudit] ([AuditActionSID], [RecordAuditSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Audit Action SID foreign key column and avoids row contention on (parent) Audit Action updates', 'SCHEMA', N'sf', 'TABLE', N'RecordAudit', 'INDEX', N'ix_RecordAudit_AuditActionSID_RecordAuditSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_RecordAudit_LegacyKey]
	ON [sf].[RecordAudit] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'RecordAudit', 'INDEX', N'ux_RecordAudit_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The Record Audit table is used to track auditing events such as accessing personal information, exporting data from the system or use of menu options.  The specific events to be audited are components of system design and cannot be changed by the user.  The event list is stored in Audit Event.  When an audit event is recorded - e.g. "Access" to a patient record - the application page the action took place from is identified along with the application user and date time.  The specific record accessed is identified through the "ContextGUID" value.', 'SCHEMA', N'sf', 'TABLE', N'RecordAudit', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the record audit assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'RecordAudit', 'COLUMN', N'RecordAuditSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the application user session assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'RecordAudit', 'COLUMN', N'ApplicationUserSessionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The page assigned to this record audit', 'SCHEMA', N'sf', 'TABLE', N'RecordAudit', 'COLUMN', N'ApplicationPageSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The audit action assigned to this record audit', 'SCHEMA', N'sf', 'TABLE', N'RecordAudit', 'COLUMN', N'AuditActionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates that the access to the record occurred after the user had invoked the "glass-break" option for unrestricted searching | Note that this does not mean the record would not have been accessible without glass-break', 'SCHEMA', N'sf', 'TABLE', N'RecordAudit', 'COLUMN', N'IsGlassBreak'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A system reference (global unique identifier) to the record that is the subject of the audit | This value points to the specific person/patient record that was accessed or was otherwise the subject of the audit.', 'SCHEMA', N'sf', 'TABLE', N'RecordAudit', 'COLUMN', N'ContextGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the record audit | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'RecordAudit', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'RecordAudit', 'COLUMN', N'RecordAuditXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'RecordAudit', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'RecordAudit', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the record audit | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'RecordAudit', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this record audit record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'RecordAudit', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the record audit | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'RecordAudit', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the record audit record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'RecordAudit', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the record audit record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'RecordAudit', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'RecordAudit', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'RecordAudit', 'CONSTRAINT', N'uk_RecordAudit_RowGUID'
GO
ALTER TABLE [sf].[RecordAudit] SET (LOCK_ESCALATION = TABLE)
GO
