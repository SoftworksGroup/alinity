SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PaymentStatus] (
		[PaymentStatusSID]          [int] IDENTITY(1000001, 1) NOT NULL,
		[PaymentStatusSCD]          [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PaymentStatusLabel]        [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[Description]               [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IsPaid]                    [bit] NOT NULL,
		[PaymentStatusSequence]     [int] NOT NULL,
		[UserDefinedColumns]        [xml] NULL,
		[PaymentStatusXID]          [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                 [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                 [bit] NOT NULL,
		[CreateUser]                [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                [datetimeoffset](7) NOT NULL,
		[UpdateUser]                [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                [datetimeoffset](7) NOT NULL,
		[RowGUID]                   [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                  [timestamp] NOT NULL,
		CONSTRAINT [uk_PaymentStatus_PaymentStatusLabel]
		UNIQUE
		NONCLUSTERED
		([PaymentStatusLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_PaymentStatus_PaymentStatusSCD]
		UNIQUE
		NONCLUSTERED
		([PaymentStatusSCD])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_PaymentStatus_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_PaymentStatus]
		PRIMARY KEY
		CLUSTERED
		([PaymentStatusSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Payment Status table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'PaymentStatus', 'CONSTRAINT', N'pk_PaymentStatus'
GO
ALTER TABLE [dbo].[PaymentStatus]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_PaymentStatus]
	CHECK
	([dbo].[fPaymentStatus#Check]([PaymentStatusSID],[PaymentStatusSCD],[PaymentStatusLabel],[IsPaid],[PaymentStatusSequence],[PaymentStatusXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[PaymentStatus]
CHECK CONSTRAINT [ck_PaymentStatus]
GO
ALTER TABLE [dbo].[PaymentStatus]
	ADD
	CONSTRAINT [df_PaymentStatus_PaymentStatusSequence]
	DEFAULT ((0)) FOR [PaymentStatusSequence]
GO
ALTER TABLE [dbo].[PaymentStatus]
	ADD
	CONSTRAINT [df_PaymentStatus_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[PaymentStatus]
	ADD
	CONSTRAINT [df_PaymentStatus_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[PaymentStatus]
	ADD
	CONSTRAINT [df_PaymentStatus_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[PaymentStatus]
	ADD
	CONSTRAINT [df_PaymentStatus_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[PaymentStatus]
	ADD
	CONSTRAINT [df_PaymentStatus_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[PaymentStatus]
	ADD
	CONSTRAINT [df_PaymentStatus_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[PaymentStatus]
	ADD
	CONSTRAINT [df_PaymentStatus_IsPaid]
	DEFAULT (CONVERT([bit],(0))) FOR [IsPaid]
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table is used to set the status of payments. The initial status a payment is in, is driven by the Payment Type which also contains a FK. For example, credit card payments are created in a PENDING status and move to either DECLINED or APPROVED after payment processing is completed.  Manual checks are set to an initial status of APPROVED but if the cheque is later returned NSF (non-sufficient-funds), then the NSF (or DELCINED) status can be set on the payment which invalidates any payments applied to invoices from the amount.', 'SCHEMA', N'dbo', 'TABLE', N'PaymentStatus', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the payment status assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'PaymentStatus', 'COLUMN', N'PaymentStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the payment status | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'dbo', 'TABLE', N'PaymentStatus', 'COLUMN', N'PaymentStatusSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the payment status to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'PaymentStatus', 'COLUMN', N'PaymentStatusLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this status indicates the payment is in good standing and money was successfully received (or is assumed to be received as in the case of a check).', 'SCHEMA', N'dbo', 'TABLE', N'PaymentStatus', 'COLUMN', N'IsPaid'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the payment status | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'PaymentStatus', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'PaymentStatus', 'COLUMN', N'PaymentStatusXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'PaymentStatus', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'PaymentStatus', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the payment status | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'PaymentStatus', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this payment status record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'PaymentStatus', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the payment status | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'PaymentStatus', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the payment status record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'PaymentStatus', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the payment status record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'PaymentStatus', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'PaymentStatus', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Payment Status Label column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'PaymentStatus', 'CONSTRAINT', N'uk_PaymentStatus_PaymentStatusLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Payment Status SCD column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'PaymentStatus', 'CONSTRAINT', N'uk_PaymentStatus_PaymentStatusSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'PaymentStatus', 'CONSTRAINT', N'uk_PaymentStatus_RowGUID'
GO
ALTER TABLE [dbo].[PaymentStatus] SET (LOCK_ESCALATION = TABLE)
GO
