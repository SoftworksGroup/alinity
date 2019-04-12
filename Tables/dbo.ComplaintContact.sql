SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ComplaintContact] (
		[ComplaintContactSID]         [int] IDENTITY(1000001, 1) NOT NULL,
		[ComplaintSID]                [int] NOT NULL,
		[PersonSID]                   [int] NOT NULL,
		[ComplaintContactRoleSID]     [int] NOT NULL,
		[EffectiveTime]               [datetime] NOT NULL,
		[ExpiryTime]                  [datetime] NULL,
		[UserDefinedColumns]          [xml] NULL,
		[ComplaintContactXID]         [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                   [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                   [bit] NOT NULL,
		[CreateUser]                  [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                  [datetimeoffset](7) NOT NULL,
		[UpdateUser]                  [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                  [datetimeoffset](7) NOT NULL,
		[RowGUID]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                    [timestamp] NOT NULL,
		CONSTRAINT [uk_ComplaintContact_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_ComplaintContact]
		PRIMARY KEY
		CLUSTERED
		([ComplaintContactSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Complaint Contact table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintContact', 'CONSTRAINT', N'pk_ComplaintContact'
GO
ALTER TABLE [dbo].[ComplaintContact]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_ComplaintContact]
	CHECK
	([dbo].[fComplaintContact#Check]([ComplaintContactSID],[ComplaintSID],[PersonSID],[ComplaintContactRoleSID],[EffectiveTime],[ExpiryTime],[ComplaintContactXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[ComplaintContact]
CHECK CONSTRAINT [ck_ComplaintContact]
GO
ALTER TABLE [dbo].[ComplaintContact]
	ADD
	CONSTRAINT [df_ComplaintContact_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[ComplaintContact]
	ADD
	CONSTRAINT [df_ComplaintContact_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[ComplaintContact]
	ADD
	CONSTRAINT [df_ComplaintContact_EffectiveTime]
	DEFAULT ([sf].[fNow]()) FOR [EffectiveTime]
GO
ALTER TABLE [dbo].[ComplaintContact]
	ADD
	CONSTRAINT [df_ComplaintContact_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[ComplaintContact]
	ADD
	CONSTRAINT [df_ComplaintContact_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[ComplaintContact]
	ADD
	CONSTRAINT [df_ComplaintContact_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[ComplaintContact]
	ADD
	CONSTRAINT [df_ComplaintContact_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[ComplaintContact]
	WITH CHECK
	ADD CONSTRAINT [fk_ComplaintContact_Complaint_ComplaintSID]
	FOREIGN KEY ([ComplaintSID]) REFERENCES [dbo].[Complaint] ([ComplaintSID])
ALTER TABLE [dbo].[ComplaintContact]
	CHECK CONSTRAINT [fk_ComplaintContact_Complaint_ComplaintSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the complaint system ID column in the Complaint Contact table match a complaint system ID in the Complaint table. It also ensures that records in the Complaint table cannot be deleted if matching child records exist in Complaint Contact. Finally, the constraint blocks changes to the value of the complaint system ID column in the Complaint if matching child records exist in Complaint Contact.', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintContact', 'CONSTRAINT', N'fk_ComplaintContact_Complaint_ComplaintSID'
GO
ALTER TABLE [dbo].[ComplaintContact]
	WITH CHECK
	ADD CONSTRAINT [fk_ComplaintContact_SF_Person_PersonSID]
	FOREIGN KEY ([PersonSID]) REFERENCES [sf].[Person] ([PersonSID])
ALTER TABLE [dbo].[ComplaintContact]
	CHECK CONSTRAINT [fk_ComplaintContact_SF_Person_PersonSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the person system ID column in the Complaint Contact table match a person system ID in the Person table. It also ensures that records in the Person table cannot be deleted if matching child records exist in Complaint Contact. Finally, the constraint blocks changes to the value of the person system ID column in the Person if matching child records exist in Complaint Contact.', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintContact', 'CONSTRAINT', N'fk_ComplaintContact_SF_Person_PersonSID'
GO
ALTER TABLE [dbo].[ComplaintContact]
	WITH CHECK
	ADD CONSTRAINT [fk_ComplaintContact_ComplaintContactRole_ComplaintContactRoleSID]
	FOREIGN KEY ([ComplaintContactRoleSID]) REFERENCES [dbo].[ComplaintContactRole] ([ComplaintContactRoleSID])
ALTER TABLE [dbo].[ComplaintContact]
	CHECK CONSTRAINT [fk_ComplaintContact_ComplaintContactRole_ComplaintContactRoleSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the complaint contact role system ID column in the Complaint Contact table match a complaint contact role system ID in the Complaint Contact Role table. It also ensures that records in the Complaint Contact Role table cannot be deleted if matching child records exist in Complaint Contact. Finally, the constraint blocks changes to the value of the complaint contact role system ID column in the Complaint Contact Role if matching child records exist in Complaint Contact.', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintContact', 'CONSTRAINT', N'fk_ComplaintContact_ComplaintContactRole_ComplaintContactRoleSID'
GO
CREATE NONCLUSTERED INDEX [ix_ComplaintContact_ComplaintContactRoleSID_ComplaintContactSID]
	ON [dbo].[ComplaintContact] ([ComplaintContactRoleSID], [ComplaintContactSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Complaint Contact Role SID foreign key column and avoids row contention on (parent) Complaint Contact Role updates', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintContact', 'INDEX', N'ix_ComplaintContact_ComplaintContactRoleSID_ComplaintContactSID'
GO
CREATE NONCLUSTERED INDEX [ix_ComplaintContact_ComplaintSID_ComplaintContactSID]
	ON [dbo].[ComplaintContact] ([ComplaintSID], [ComplaintContactSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Complaint SID foreign key column and avoids row contention on (parent) Complaint updates', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintContact', 'INDEX', N'ix_ComplaintContact_ComplaintSID_ComplaintContactSID'
GO
CREATE NONCLUSTERED INDEX [ix_ComplaintContact_PersonSID_ComplaintContactSID]
	ON [dbo].[ComplaintContact] ([PersonSID], [ComplaintContactSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Person SID foreign key column and avoids row contention on (parent) Person updates', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintContact', 'INDEX', N'ix_ComplaintContact_PersonSID_ComplaintContactSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the complaint contact assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintContact', 'COLUMN', N'ComplaintContactSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The complaint this contact is defined for', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintContact', 'COLUMN', N'ComplaintSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person record  this complaint contact is based on', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintContact', 'COLUMN', N'PersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the complaint contact role assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintContact', 'COLUMN', N'ComplaintContactRoleSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date the person was assigned to the complaint case', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintContact', 'COLUMN', N'EffectiveTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date the person''s assignment to the case ended', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintContact', 'COLUMN', N'ExpiryTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the complaint contact | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintContact', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintContact', 'COLUMN', N'ComplaintContactXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintContact', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintContact', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the complaint contact | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintContact', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this complaint contact record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintContact', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the complaint contact | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintContact', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the complaint contact record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintContact', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the complaint contact record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintContact', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintContact', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintContact', 'CONSTRAINT', N'uk_ComplaintContact_RowGUID'
GO
ALTER TABLE [dbo].[ComplaintContact] SET (LOCK_ESCALATION = TABLE)
GO
