SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ComplaintEvent] (
		[ComplaintEventSID]         [int] IDENTITY(1000001, 1) NOT NULL,
		[ComplaintSID]              [int] NOT NULL,
		[ComplaintEventTypeSID]     [int] NOT NULL,
		[Description]               [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[DueDate]                   [date] NOT NULL,
		[CompleteTime]              [datetime] NULL,
		[UserDefinedColumns]        [xml] NULL,
		[ComplaintEventXID]         [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                 [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                 [bit] NOT NULL,
		[CreateUser]                [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                [datetimeoffset](7) NOT NULL,
		[UpdateUser]                [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                [datetimeoffset](7) NOT NULL,
		[RowGUID]                   [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                  [timestamp] NOT NULL,
		CONSTRAINT [uk_ComplaintEvent_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_ComplaintEvent]
		PRIMARY KEY
		CLUSTERED
		([ComplaintEventSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Complaint Event table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintEvent', 'CONSTRAINT', N'pk_ComplaintEvent'
GO
ALTER TABLE [dbo].[ComplaintEvent]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_ComplaintEvent]
	CHECK
	([dbo].[fComplaintEvent#Check]([ComplaintEventSID],[ComplaintSID],[ComplaintEventTypeSID],[Description],[DueDate],[CompleteTime],[ComplaintEventXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[ComplaintEvent]
CHECK CONSTRAINT [ck_ComplaintEvent]
GO
ALTER TABLE [dbo].[ComplaintEvent]
	ADD
	CONSTRAINT [df_ComplaintEvent_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[ComplaintEvent]
	ADD
	CONSTRAINT [df_ComplaintEvent_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[ComplaintEvent]
	ADD
	CONSTRAINT [df_ComplaintEvent_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[ComplaintEvent]
	ADD
	CONSTRAINT [df_ComplaintEvent_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[ComplaintEvent]
	ADD
	CONSTRAINT [df_ComplaintEvent_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[ComplaintEvent]
	ADD
	CONSTRAINT [df_ComplaintEvent_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[ComplaintEvent]
	WITH CHECK
	ADD CONSTRAINT [fk_ComplaintEvent_Complaint_ComplaintSID]
	FOREIGN KEY ([ComplaintSID]) REFERENCES [dbo].[Complaint] ([ComplaintSID])
ALTER TABLE [dbo].[ComplaintEvent]
	CHECK CONSTRAINT [fk_ComplaintEvent_Complaint_ComplaintSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the complaint system ID column in the Complaint Event table match a complaint system ID in the Complaint table. It also ensures that records in the Complaint table cannot be deleted if matching child records exist in Complaint Event. Finally, the constraint blocks changes to the value of the complaint system ID column in the Complaint if matching child records exist in Complaint Event.', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintEvent', 'CONSTRAINT', N'fk_ComplaintEvent_Complaint_ComplaintSID'
GO
ALTER TABLE [dbo].[ComplaintEvent]
	WITH CHECK
	ADD CONSTRAINT [fk_ComplaintEvent_ComplaintEventType_ComplaintEventTypeSID]
	FOREIGN KEY ([ComplaintEventTypeSID]) REFERENCES [dbo].[ComplaintEventType] ([ComplaintEventTypeSID])
ALTER TABLE [dbo].[ComplaintEvent]
	CHECK CONSTRAINT [fk_ComplaintEvent_ComplaintEventType_ComplaintEventTypeSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the complaint event type system ID column in the Complaint Event table match a complaint event type system ID in the Complaint Event Type table. It also ensures that records in the Complaint Event Type table cannot be deleted if matching child records exist in Complaint Event. Finally, the constraint blocks changes to the value of the complaint event type system ID column in the Complaint Event Type if matching child records exist in Complaint Event.', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintEvent', 'CONSTRAINT', N'fk_ComplaintEvent_ComplaintEventType_ComplaintEventTypeSID'
GO
CREATE NONCLUSTERED INDEX [ix_ComplaintEvent_ComplaintEventTypeSID_ComplaintEventSID]
	ON [dbo].[ComplaintEvent] ([ComplaintEventTypeSID], [ComplaintEventSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Complaint Event Type SID foreign key column and avoids row contention on (parent) Complaint Event Type updates', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintEvent', 'INDEX', N'ix_ComplaintEvent_ComplaintEventTypeSID_ComplaintEventSID'
GO
CREATE NONCLUSTERED INDEX [ix_ComplaintEvent_ComplaintSID_ComplaintEventSID]
	ON [dbo].[ComplaintEvent] ([ComplaintSID], [ComplaintEventSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Complaint SID foreign key column and avoids row contention on (parent) Complaint updates', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintEvent', 'INDEX', N'ix_ComplaintEvent_ComplaintSID_ComplaintEventSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the complaint event assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintEvent', 'COLUMN', N'ComplaintEventSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The complaint this event is defined for', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintEvent', 'COLUMN', N'ComplaintSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of complaint event', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintEvent', 'COLUMN', N'ComplaintEventTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the complaint event | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintEvent', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintEvent', 'COLUMN', N'ComplaintEventXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintEvent', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintEvent', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the complaint event | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintEvent', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this complaint event record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintEvent', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the complaint event | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintEvent', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the complaint event record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintEvent', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the complaint event record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintEvent', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintEvent', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintEvent', 'CONSTRAINT', N'uk_ComplaintEvent_RowGUID'
GO
ALTER TABLE [dbo].[ComplaintEvent] SET (LOCK_ESCALATION = TABLE)
GO
