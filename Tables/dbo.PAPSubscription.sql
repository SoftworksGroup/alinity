SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PAPSubscription] (
		[PAPSubscriptionSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[PersonSID]              [int] NOT NULL,
		[InstitutionNo]          [varchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TransitNo]              [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[AccountNo]              [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[WithdrawalAmount]       [decimal](11, 2) NOT NULL,
		[EffectiveTime]          [datetime] NOT NULL,
		[CancelledTime]          [datetime] NULL,
		[UserDefinedColumns]     [xml] NULL,
		[PAPSubscriptionXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]              [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]              [bit] NOT NULL,
		[CreateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]             [datetimeoffset](7) NOT NULL,
		[UpdateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]             [datetimeoffset](7) NOT NULL,
		[RowGUID]                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]               [timestamp] NOT NULL,
		CONSTRAINT [uk_PAPSubscription_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_PAPSubscription]
		PRIMARY KEY
		CLUSTERED
		([PAPSubscriptionSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the PAPSubscription table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'PAPSubscription', 'CONSTRAINT', N'pk_PAPSubscription'
GO
ALTER TABLE [dbo].[PAPSubscription]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_PAPSubscription]
	CHECK
	([dbo].[fPAPSubscription#Check]([PAPSubscriptionSID],[PersonSID],[InstitutionNo],[TransitNo],[AccountNo],[WithdrawalAmount],[EffectiveTime],[CancelledTime],[PAPSubscriptionXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[PAPSubscription]
CHECK CONSTRAINT [ck_PAPSubscription]
GO
ALTER TABLE [dbo].[PAPSubscription]
	ADD
	CONSTRAINT [df_PAPSubscription_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[PAPSubscription]
	ADD
	CONSTRAINT [df_PAPSubscription_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[PAPSubscription]
	ADD
	CONSTRAINT [df_PAPSubscription_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[PAPSubscription]
	ADD
	CONSTRAINT [df_PAPSubscription_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[PAPSubscription]
	ADD
	CONSTRAINT [df_PAPSubscription_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[PAPSubscription]
	ADD
	CONSTRAINT [df_PAPSubscription_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[PAPSubscription]
	WITH CHECK
	ADD CONSTRAINT [fk_PAPSubscription_SF_Person_PersonSID]
	FOREIGN KEY ([PersonSID]) REFERENCES [sf].[Person] ([PersonSID])
ALTER TABLE [dbo].[PAPSubscription]
	CHECK CONSTRAINT [fk_PAPSubscription_SF_Person_PersonSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the person system ID column in the PAPSubscription table match a person system ID in the Person table. It also ensures that records in the Person table cannot be deleted if matching child records exist in PAPSubscription. Finally, the constraint blocks changes to the value of the person system ID column in the Person if matching child records exist in PAPSubscription.', 'SCHEMA', N'dbo', 'TABLE', N'PAPSubscription', 'CONSTRAINT', N'fk_PAPSubscription_SF_Person_PersonSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_PAPSubscription_PersonSID]
	ON [dbo].[PAPSubscription] ([PersonSID])
	WHERE (([CancelledTime] IS NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Person SID value is not duplicated where the condition: "([CancelledTime] IS NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'PAPSubscription', 'INDEX', N'ux_PAPSubscription_PersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table records the list of people who are enrolled in the pre-authorized-payment program.  Bank account details are recorded for each person and these are exported to a file to provide to the host bank when a new batch is created.  A history of subscription records is maintained so that if someone goes onto PAP, is removed from the program (cancelled), and returns to it later - then multiple records are stored.  Only 1 current subscription record is valid for an individual even if banking information is different.  The banking information must also be unique for active subscriptions.', 'SCHEMA', N'dbo', 'TABLE', N'PAPSubscription', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the papsubscription assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'PAPSubscription', 'COLUMN', N'PAPSubscriptionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person record  this papsubscription is based on', 'SCHEMA', N'dbo', 'TABLE', N'PAPSubscription', 'COLUMN', N'PersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The monetary value of the payment', 'SCHEMA', N'dbo', 'TABLE', N'PAPSubscription', 'COLUMN', N'WithdrawalAmount'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The amount of funds to withdraw from the account.  ', 'SCHEMA', N'dbo', 'TABLE', N'PAPSubscription', 'COLUMN', N'EffectiveTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the papsubscription | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'PAPSubscription', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'PAPSubscription', 'COLUMN', N'PAPSubscriptionXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'PAPSubscription', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'PAPSubscription', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the papsubscription | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'PAPSubscription', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this papsubscription record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'PAPSubscription', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the papsubscription | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'PAPSubscription', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the papsubscription record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'PAPSubscription', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the papsubscription record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'PAPSubscription', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'PAPSubscription', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'PAPSubscription', 'CONSTRAINT', N'uk_PAPSubscription_RowGUID'
GO
ALTER TABLE [dbo].[PAPSubscription] SET (LOCK_ESCALATION = TABLE)
GO
