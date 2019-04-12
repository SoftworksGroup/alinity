SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Reason] (
		[ReasonSID]              [int] IDENTITY(1000001, 1) NOT NULL,
		[ReasonGroupSID]         [int] NOT NULL,
		[ReasonName]             [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ReasonCode]             [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ReasonSequence]         [smallint] NOT NULL,
		[ToolTip]                [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsActive]               [bit] NOT NULL,
		[UserDefinedColumns]     [xml] NULL,
		[ReasonXID]              [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]              [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]              [bit] NOT NULL,
		[CreateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]             [datetimeoffset](7) NOT NULL,
		[UpdateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]             [datetimeoffset](7) NOT NULL,
		[RowGUID]                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]               [timestamp] NOT NULL,
		CONSTRAINT [uk_Reason_ReasonCode]
		UNIQUE
		NONCLUSTERED
		([ReasonCode])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_Reason_ReasonName_ReasonGroupSID]
		UNIQUE
		NONCLUSTERED
		([ReasonName], [ReasonGroupSID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_Reason_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_Reason]
		PRIMARY KEY
		CLUSTERED
		([ReasonSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Reason table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'Reason', 'CONSTRAINT', N'pk_Reason'
GO
ALTER TABLE [dbo].[Reason]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_Reason]
	CHECK
	([dbo].[fReason#Check]([ReasonSID],[ReasonGroupSID],[ReasonName],[ReasonCode],[ReasonSequence],[ToolTip],[IsActive],[ReasonXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[Reason]
CHECK CONSTRAINT [ck_Reason]
GO
ALTER TABLE [dbo].[Reason]
	ADD
	CONSTRAINT [df_Reason_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[Reason]
	ADD
	CONSTRAINT [df_Reason_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[Reason]
	ADD
	CONSTRAINT [df_Reason_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[Reason]
	ADD
	CONSTRAINT [df_Reason_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[Reason]
	ADD
	CONSTRAINT [df_Reason_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[Reason]
	ADD
	CONSTRAINT [df_Reason_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[Reason]
	ADD
	CONSTRAINT [df_Reason_ReasonSequence]
	DEFAULT ((0)) FOR [ReasonSequence]
GO
ALTER TABLE [dbo].[Reason]
	ADD
	CONSTRAINT [df_Reason_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[Reason]
	WITH CHECK
	ADD CONSTRAINT [fk_Reason_ReasonGroup_ReasonGroupSID]
	FOREIGN KEY ([ReasonGroupSID]) REFERENCES [dbo].[ReasonGroup] ([ReasonGroupSID])
ALTER TABLE [dbo].[Reason]
	CHECK CONSTRAINT [fk_Reason_ReasonGroup_ReasonGroupSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the reason group system ID column in the Reason table match a reason group system ID in the Reason Group table. It also ensures that records in the Reason Group table cannot be deleted if matching child records exist in Reason. Finally, the constraint blocks changes to the value of the reason group system ID column in the Reason Group if matching child records exist in Reason.', 'SCHEMA', N'dbo', 'TABLE', N'Reason', 'CONSTRAINT', N'fk_Reason_ReasonGroup_ReasonGroupSID'
GO
CREATE NONCLUSTERED INDEX [ix_Reason_ReasonGroupSID_ReasonSID]
	ON [dbo].[Reason] ([ReasonGroupSID], [ReasonSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Reason Group SID foreign key column and avoids row contention on (parent) Reason Group updates', 'SCHEMA', N'dbo', 'TABLE', N'Reason', 'INDEX', N'ix_Reason_ReasonGroupSID_ReasonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the reason assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'Reason', 'COLUMN', N'ReasonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The reason group assigned to this reason', 'SCHEMA', N'dbo', 'TABLE', N'Reason', 'COLUMN', N'ReasonGroupSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the reason to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'Reason', 'COLUMN', N'ReasonName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional code used to refer to this reason - most often applicable where reason coding is provided to external parties - e.g. Provider Directory, Workforce Planning authority, etc. ', 'SCHEMA', N'dbo', 'TABLE', N'Reason', 'COLUMN', N'ReasonCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this reason record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'TABLE', N'Reason', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the reason | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'Reason', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'Reason', 'COLUMN', N'ReasonXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'Reason', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'Reason', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the reason | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'Reason', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this reason record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'Reason', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the reason | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'Reason', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the reason record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'Reason', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the reason record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'Reason', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'Reason', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Reason Code column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'Reason', 'CONSTRAINT', N'uk_Reason_ReasonCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the combination of values provided for the "Reason Name + Reason Group SID" columns is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'Reason', 'CONSTRAINT', N'uk_Reason_ReasonName_ReasonGroupSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'Reason', 'CONSTRAINT', N'uk_Reason_RowGUID'
GO
ALTER TABLE [dbo].[Reason] SET (LOCK_ESCALATION = TABLE)
GO
