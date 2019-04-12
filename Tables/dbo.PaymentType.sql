SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PaymentType] (
		[PaymentTypeSID]                 [int] IDENTITY(1000001, 1) NOT NULL,
		[PaymentTypeSCD]                 [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PaymentTypeLabel]               [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PaymentTypeCategory]            [nvarchar](65) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[GLAccountSID]                   [int] NOT NULL,
		[PaymentStatusSID]               [int] NOT NULL,
		[IsReferenceRequired]            [bit] NOT NULL,
		[DepositDateLagDays]             [smallint] NOT NULL,
		[IsRefundExcludedFromGL]         [bit] NOT NULL,
		[ExcludeDepositFromGLBefore]     [date] NULL,
		[IsDefault]                      [bit] NOT NULL,
		[IsActive]                       [bit] NOT NULL,
		[UserDefinedColumns]             [xml] NULL,
		[PaymentTypeXID]                 [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                      [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                      [bit] NOT NULL,
		[CreateUser]                     [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                     [datetimeoffset](7) NOT NULL,
		[UpdateUser]                     [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                     [datetimeoffset](7) NOT NULL,
		[RowGUID]                        [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                       [timestamp] NOT NULL,
		CONSTRAINT [uk_PaymentType_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_PaymentType_PaymentTypeSCD]
		UNIQUE
		NONCLUSTERED
		([PaymentTypeSCD])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_PaymentType_PaymentTypeLabel]
		UNIQUE
		NONCLUSTERED
		([PaymentTypeLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_PaymentType]
		PRIMARY KEY
		CLUSTERED
		([PaymentTypeSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Payment Type table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'PaymentType', 'CONSTRAINT', N'pk_PaymentType'
GO
ALTER TABLE [dbo].[PaymentType]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_PaymentType]
	CHECK
	([dbo].[fPaymentType#Check]([PaymentTypeSID],[PaymentTypeSCD],[PaymentTypeLabel],[PaymentTypeCategory],[GLAccountSID],[PaymentStatusSID],[IsReferenceRequired],[DepositDateLagDays],[IsRefundExcludedFromGL],[ExcludeDepositFromGLBefore],[IsDefault],[IsActive],[PaymentTypeXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[PaymentType]
CHECK CONSTRAINT [ck_PaymentType]
GO
ALTER TABLE [dbo].[PaymentType]
	ADD
	CONSTRAINT [df_PaymentType_IsReferenceRequired]
	DEFAULT (CONVERT([bit],(0))) FOR [IsReferenceRequired]
GO
ALTER TABLE [dbo].[PaymentType]
	ADD
	CONSTRAINT [df_PaymentType_DepositDateLagDays]
	DEFAULT ((1)) FOR [DepositDateLagDays]
GO
ALTER TABLE [dbo].[PaymentType]
	ADD
	CONSTRAINT [df_PaymentType_IsRefundExcludedFromGL]
	DEFAULT (CONVERT([bit],(1))) FOR [IsRefundExcludedFromGL]
GO
ALTER TABLE [dbo].[PaymentType]
	ADD
	CONSTRAINT [df_PaymentType_IsDefault]
	DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [dbo].[PaymentType]
	ADD
	CONSTRAINT [df_PaymentType_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[PaymentType]
	ADD
	CONSTRAINT [df_PaymentType_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[PaymentType]
	ADD
	CONSTRAINT [df_PaymentType_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[PaymentType]
	ADD
	CONSTRAINT [df_PaymentType_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[PaymentType]
	ADD
	CONSTRAINT [df_PaymentType_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[PaymentType]
	ADD
	CONSTRAINT [df_PaymentType_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[PaymentType]
	ADD
	CONSTRAINT [df_PaymentType_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[PaymentType]
	WITH CHECK
	ADD CONSTRAINT [fk_PaymentType_GLAccount_GLAccountSID]
	FOREIGN KEY ([GLAccountSID]) REFERENCES [dbo].[GLAccount] ([GLAccountSID])
ALTER TABLE [dbo].[PaymentType]
	CHECK CONSTRAINT [fk_PaymentType_GLAccount_GLAccountSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the glaccount system ID column in the Payment Type table match a glaccount system ID in the GLAccount table. It also ensures that records in the GLAccount table cannot be deleted if matching child records exist in Payment Type. Finally, the constraint blocks changes to the value of the glaccount system ID column in the GLAccount if matching child records exist in Payment Type.', 'SCHEMA', N'dbo', 'TABLE', N'PaymentType', 'CONSTRAINT', N'fk_PaymentType_GLAccount_GLAccountSID'
GO
ALTER TABLE [dbo].[PaymentType]
	WITH CHECK
	ADD CONSTRAINT [fk_PaymentType_PaymentStatus_PaymentStatusSID]
	FOREIGN KEY ([PaymentStatusSID]) REFERENCES [dbo].[PaymentStatus] ([PaymentStatusSID])
ALTER TABLE [dbo].[PaymentType]
	CHECK CONSTRAINT [fk_PaymentType_PaymentStatus_PaymentStatusSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the payment status system ID column in the Payment Type table match a payment status system ID in the Payment Status table. It also ensures that records in the Payment Status table cannot be deleted if matching child records exist in Payment Type. Finally, the constraint blocks changes to the value of the payment status system ID column in the Payment Status if matching child records exist in Payment Type.', 'SCHEMA', N'dbo', 'TABLE', N'PaymentType', 'CONSTRAINT', N'fk_PaymentType_PaymentStatus_PaymentStatusSID'
GO
CREATE NONCLUSTERED INDEX [ix_PaymentType_GLAccountSID_PaymentTypeSID]
	ON [dbo].[PaymentType] ([GLAccountSID], [PaymentTypeSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the GLAccount SID foreign key column and avoids row contention on (parent) GLAccount updates', 'SCHEMA', N'dbo', 'TABLE', N'PaymentType', 'INDEX', N'ix_PaymentType_GLAccountSID_PaymentTypeSID'
GO
CREATE NONCLUSTERED INDEX [ix_PaymentType_PaymentStatusSID_PaymentTypeSID]
	ON [dbo].[PaymentType] ([PaymentStatusSID], [PaymentTypeSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Payment Status SID foreign key column and avoids row contention on (parent) Payment Status updates', 'SCHEMA', N'dbo', 'TABLE', N'PaymentType', 'INDEX', N'ix_PaymentType_PaymentStatusSID_PaymentTypeSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_PaymentType_IsDefault]
	ON [dbo].[PaymentType] ([IsDefault])
	WHERE (([IsDefault]=(1)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure that only 1 record is marked as the default Payment Type', 'SCHEMA', N'dbo', 'TABLE', N'PaymentType', 'INDEX', N'ux_PaymentType_IsDefault'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_PaymentType_LegacyKey]
	ON [dbo].[PaymentType] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'PaymentType', 'INDEX', N'ux_PaymentType_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Describes the type of payment, e.g. Cheque, credit card, cash.  The list of payment types supported is fixed by the application.  It is possible to mark a type in-active if not being used.  For online payment types, a record exists for each supported processor (e.g. Moneris, BeanStream, etc.).  The GL Account on the table is user updatable and controls the GLCode copied to the Payment record when a payment of this type is created.', 'SCHEMA', N'dbo', 'TABLE', N'PaymentType', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the payment type assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'PaymentType', 'COLUMN', N'PaymentTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the payment type | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'dbo', 'TABLE', N'PaymentType', 'COLUMN', N'PaymentTypeSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the payment type to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'PaymentType', 'COLUMN', N'PaymentTypeLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional grouping or category label to organize these types', 'SCHEMA', N'dbo', 'TABLE', N'PaymentType', 'COLUMN', N'PaymentTypeCategory'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the glaccount assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'PaymentType', 'COLUMN', N'GLAccountSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The status of the payment type', 'SCHEMA', N'dbo', 'TABLE', N'PaymentType', 'COLUMN', N'PaymentStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates that the payment reference field must be filled in when checked.  This is normally required for check/cheque payment types.', 'SCHEMA', N'dbo', 'TABLE', N'PaymentType', 'COLUMN', N'IsReferenceRequired'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of days ahead of the date the transaction is recorded, payments of this type are expected to appear on the bank statement.', 'SCHEMA', N'dbo', 'TABLE', N'PaymentType', 'COLUMN', N'DepositDateLagDays'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if refunds processed on this payment type should be exlcuded from reporting to external general ledgers. This value should be checked if refunds for this payment type are initiated in your GL program (typically as checks/cheques).', 'SCHEMA', N'dbo', 'TABLE', N'PaymentType', 'COLUMN', N'IsRefundExcludedFromGL'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Allows deposits for this payment type to be excluded from reporting to external GL when the transaction occurs prior to this date.  Typically only applies to PAP bank accounts for conversion period.', 'SCHEMA', N'dbo', 'TABLE', N'PaymentType', 'COLUMN', N'ExcludeDepositFromGLBefore'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default payment type to assign when new records are added', 'SCHEMA', N'dbo', 'TABLE', N'PaymentType', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this payment type record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'TABLE', N'PaymentType', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the payment type | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'PaymentType', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'PaymentType', 'COLUMN', N'PaymentTypeXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'PaymentType', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'PaymentType', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the payment type | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'PaymentType', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this payment type record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'PaymentType', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the payment type | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'PaymentType', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the payment type record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'PaymentType', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the payment type record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'PaymentType', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'PaymentType', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'PaymentType', 'CONSTRAINT', N'uk_PaymentType_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Payment Type SCD column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'PaymentType', 'CONSTRAINT', N'uk_PaymentType_PaymentTypeSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Payment Type Label column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'PaymentType', 'CONSTRAINT', N'uk_PaymentType_PaymentTypeLabel'
GO
ALTER TABLE [dbo].[PaymentType] SET (LOCK_ESCALATION = TABLE)
GO
