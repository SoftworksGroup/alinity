SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PAPBatch] (
		[PAPBatchSID]            [int] IDENTITY(1000001, 1) NOT NULL,
		[BatchID]                [varchar](12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[BatchSequence]          [int] NULL,
		[WithdrawalDate]         [date] NOT NULL,
		[ExportFile]             [varbinary](max) NULL,
		[LockedTime]             [datetimeoffset](7) NULL,
		[ProcessedTime]          [datetimeoffset](7) NULL,
		[UserDefinedColumns]     [xml] NULL,
		[PAPBatchXID]            [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]              [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]              [bit] NOT NULL,
		[CreateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]             [datetimeoffset](7) NOT NULL,
		[UpdateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]             [datetimeoffset](7) NOT NULL,
		[RowGUID]                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]               [timestamp] NOT NULL,
		CONSTRAINT [uk_PAPBatch_BatchID]
		UNIQUE
		NONCLUSTERED
		([BatchID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_PAPBatch_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_PAPBatch]
		PRIMARY KEY
		CLUSTERED
		([PAPBatchSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the PAPBatch table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'PAPBatch', 'CONSTRAINT', N'pk_PAPBatch'
GO
ALTER TABLE [dbo].[PAPBatch]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_PAPBatch]
	CHECK
	([dbo].[fPAPBatch#Check]([PAPBatchSID],[BatchID],[BatchSequence],[WithdrawalDate],[LockedTime],[ProcessedTime],[PAPBatchXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[PAPBatch]
CHECK CONSTRAINT [ck_PAPBatch]
GO
ALTER TABLE [dbo].[PAPBatch]
	ADD
	CONSTRAINT [df_PAPBatch_WithdrawalDate]
	DEFAULT (dateadd(day,(1),[sf].[fToday]())) FOR [WithdrawalDate]
GO
ALTER TABLE [dbo].[PAPBatch]
	ADD
	CONSTRAINT [df_PAPBatch_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[PAPBatch]
	ADD
	CONSTRAINT [df_PAPBatch_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[PAPBatch]
	ADD
	CONSTRAINT [df_PAPBatch_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[PAPBatch]
	ADD
	CONSTRAINT [df_PAPBatch_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[PAPBatch]
	ADD
	CONSTRAINT [df_PAPBatch_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[PAPBatch]
	ADD
	CONSTRAINT [df_PAPBatch_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_PAPBatch_BatchSequence]
	ON [dbo].[PAPBatch] ([BatchSequence])
	WHERE (([BatchSequence] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Batch Sequence value is not duplicated where the condition: "([BatchSequence] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'PAPBatch', 'INDEX', N'ux_PAPBatch_BatchSequence'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table is created when a file of banking information is generated for  the host bank to process payments.  The file is created and along with it detailed transactions for current subscribers to the PAP program.  The file is then exported to the bank for processing.  A report is then provided by the bank on the transactions processed and an Admin must indicate which, if any, transactions in the batch have been declined/rejected.  Once this is done the batch can be approved.  The approval process applies the payments - creating one Payment record for each line of the batch and applying the payments to outstanding invoices where a matching amount is found.', 'SCHEMA', N'dbo', 'TABLE', N'PAPBatch', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the papbatch assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'PAPBatch', 'COLUMN', N'PAPBatchSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A sequential number assigned when batch export is generated (required by some financial institutions)', 'SCHEMA', N'dbo', 'TABLE', N'PAPBatch', 'COLUMN', N'BatchSequence'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time the batch is marked locked.  This is set automatically when the export file to the bank is generated but can be unlocked to regenerate the file.', 'SCHEMA', N'dbo', 'TABLE', N'PAPBatch', 'COLUMN', N'LockedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time the transactions are procssed into payment records.  After this time the batch can no longer be edited.', 'SCHEMA', N'dbo', 'TABLE', N'PAPBatch', 'COLUMN', N'ProcessedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the papbatch | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'PAPBatch', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'PAPBatch', 'COLUMN', N'PAPBatchXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'PAPBatch', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'PAPBatch', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the papbatch | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'PAPBatch', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this papbatch record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'PAPBatch', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the papbatch | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'PAPBatch', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the papbatch record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'PAPBatch', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the papbatch record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'PAPBatch', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'PAPBatch', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Batch ID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'PAPBatch', 'CONSTRAINT', N'uk_PAPBatch_BatchID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'PAPBatch', 'CONSTRAINT', N'uk_PAPBatch_RowGUID'
GO
ALTER TABLE [dbo].[PAPBatch] SET (LOCK_ESCALATION = TABLE)
GO
