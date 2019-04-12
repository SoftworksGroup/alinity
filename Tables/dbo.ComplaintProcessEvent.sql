SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ComplaintProcessEvent] (
		[ComplaintProcessEventSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[ComplaintProcessSID]          [int] NOT NULL,
		[ComplaintEventTypeSID]        [int] NOT NULL,
		[Description]                  [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[Sequence]                     [decimal](5, 1) NOT NULL,
		[TargetDurationDays]           [smallint] NOT NULL,
		[UserDefinedColumns]           [xml] NULL,
		[ComplaintProcessEventXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                    [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                    [bit] NOT NULL,
		[CreateUser]                   [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                   [datetimeoffset](7) NOT NULL,
		[UpdateUser]                   [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                   [datetimeoffset](7) NOT NULL,
		[RowGUID]                      [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                     [timestamp] NOT NULL,
		CONSTRAINT [uk_ComplaintProcessEvent_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_ComplaintProcessEvent]
		PRIMARY KEY
		CLUSTERED
		([ComplaintProcessEventSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Complaint Process Event table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintProcessEvent', 'CONSTRAINT', N'pk_ComplaintProcessEvent'
GO
ALTER TABLE [dbo].[ComplaintProcessEvent]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_ComplaintProcessEvent]
	CHECK
	([dbo].[fComplaintProcessEvent#Check]([ComplaintProcessEventSID],[ComplaintProcessSID],[ComplaintEventTypeSID],[Description],[Sequence],[TargetDurationDays],[ComplaintProcessEventXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[ComplaintProcessEvent]
CHECK CONSTRAINT [ck_ComplaintProcessEvent]
GO
ALTER TABLE [dbo].[ComplaintProcessEvent]
	ADD
	CONSTRAINT [df_ComplaintProcessEvent_Sequence]
	DEFAULT ((0.0)) FOR [Sequence]
GO
ALTER TABLE [dbo].[ComplaintProcessEvent]
	ADD
	CONSTRAINT [df_ComplaintProcessEvent_TargetDurationDays]
	DEFAULT ((0)) FOR [TargetDurationDays]
GO
ALTER TABLE [dbo].[ComplaintProcessEvent]
	ADD
	CONSTRAINT [df_ComplaintProcessEvent_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[ComplaintProcessEvent]
	ADD
	CONSTRAINT [df_ComplaintProcessEvent_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[ComplaintProcessEvent]
	ADD
	CONSTRAINT [df_ComplaintProcessEvent_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[ComplaintProcessEvent]
	ADD
	CONSTRAINT [df_ComplaintProcessEvent_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[ComplaintProcessEvent]
	ADD
	CONSTRAINT [df_ComplaintProcessEvent_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[ComplaintProcessEvent]
	ADD
	CONSTRAINT [df_ComplaintProcessEvent_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[ComplaintProcessEvent]
	WITH CHECK
	ADD CONSTRAINT [fk_ComplaintProcessEvent_ComplaintProcess_ComplaintProcessSID]
	FOREIGN KEY ([ComplaintProcessSID]) REFERENCES [dbo].[ComplaintProcess] ([ComplaintProcessSID])
ALTER TABLE [dbo].[ComplaintProcessEvent]
	CHECK CONSTRAINT [fk_ComplaintProcessEvent_ComplaintProcess_ComplaintProcessSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the complaint process system ID column in the Complaint Process Event table match a complaint process system ID in the Complaint Process table. It also ensures that records in the Complaint Process table cannot be deleted if matching child records exist in Complaint Process Event. Finally, the constraint blocks changes to the value of the complaint process system ID column in the Complaint Process if matching child records exist in Complaint Process Event.', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintProcessEvent', 'CONSTRAINT', N'fk_ComplaintProcessEvent_ComplaintProcess_ComplaintProcessSID'
GO
ALTER TABLE [dbo].[ComplaintProcessEvent]
	WITH CHECK
	ADD CONSTRAINT [fk_ComplaintProcessEvent_ComplaintEventType_ComplaintEventTypeSID]
	FOREIGN KEY ([ComplaintEventTypeSID]) REFERENCES [dbo].[ComplaintEventType] ([ComplaintEventTypeSID])
ALTER TABLE [dbo].[ComplaintProcessEvent]
	CHECK CONSTRAINT [fk_ComplaintProcessEvent_ComplaintEventType_ComplaintEventTypeSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the complaint event type system ID column in the Complaint Process Event table match a complaint event type system ID in the Complaint Event Type table. It also ensures that records in the Complaint Event Type table cannot be deleted if matching child records exist in Complaint Process Event. Finally, the constraint blocks changes to the value of the complaint event type system ID column in the Complaint Event Type if matching child records exist in Complaint Process Event.', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintProcessEvent', 'CONSTRAINT', N'fk_ComplaintProcessEvent_ComplaintEventType_ComplaintEventTypeSID'
GO
CREATE NONCLUSTERED INDEX [ix_ComplaintProcessEvent_ComplaintEventTypeSID_ComplaintProcessEventSID]
	ON [dbo].[ComplaintProcessEvent] ([ComplaintEventTypeSID], [ComplaintProcessEventSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Complaint Event Type SID foreign key column and avoids row contention on (parent) Complaint Event Type updates', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintProcessEvent', 'INDEX', N'ix_ComplaintProcessEvent_ComplaintEventTypeSID_ComplaintProcessEventSID'
GO
CREATE NONCLUSTERED INDEX [ix_ComplaintProcessEvent_ComplaintProcessSID_ComplaintProcessEventSID]
	ON [dbo].[ComplaintProcessEvent] ([ComplaintProcessSID], [ComplaintProcessEventSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Complaint Process SID foreign key column and avoids row contention on (parent) Complaint Process updates', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintProcessEvent', 'INDEX', N'ix_ComplaintProcessEvent_ComplaintProcessSID_ComplaintProcessEventSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the complaint process event assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintProcessEvent', 'COLUMN', N'ComplaintProcessEventSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The complaint process this event is defined for', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintProcessEvent', 'COLUMN', N'ComplaintProcessSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of complaint process event', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintProcessEvent', 'COLUMN', N'ComplaintEventTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of days to target the due date from the previous event or from the complaint open date if nothing previous', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintProcessEvent', 'COLUMN', N'TargetDurationDays'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the complaint process event | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintProcessEvent', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintProcessEvent', 'COLUMN', N'ComplaintProcessEventXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintProcessEvent', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintProcessEvent', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the complaint process event | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintProcessEvent', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this complaint process event record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintProcessEvent', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the complaint process event | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintProcessEvent', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the complaint process event record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintProcessEvent', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the complaint process event record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintProcessEvent', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintProcessEvent', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintProcessEvent', 'CONSTRAINT', N'uk_ComplaintProcessEvent_RowGUID'
GO
ALTER TABLE [dbo].[ComplaintProcessEvent] SET (LOCK_ESCALATION = TABLE)
GO
