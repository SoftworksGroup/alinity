SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[GLAccount] (
		[GLAccountSID]                  [int] IDENTITY(1000001, 1) NOT NULL,
		[GLAccountCode]                 [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[GLAccountLabel]                [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IsRevenueAccount]              [bit] NOT NULL,
		[IsBankAccount]                 [bit] NOT NULL,
		[IsTaxAccount]                  [bit] NOT NULL,
		[IsPAPAccount]                  [bit] NOT NULL,
		[IsUnappliedPaymentAccount]     [bit] NOT NULL,
		[DeferredGLAccountCode]         [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsActive]                      [bit] NOT NULL,
		[UserDefinedColumns]            [xml] NULL,
		[GLAccountXID]                  [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                     [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                     [bit] NOT NULL,
		[CreateUser]                    [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                    [datetimeoffset](7) NOT NULL,
		[UpdateUser]                    [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                    [datetimeoffset](7) NOT NULL,
		[RowGUID]                       [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                      [timestamp] NOT NULL,
		CONSTRAINT [uk_GLAccount_GLAccountCode]
		UNIQUE
		NONCLUSTERED
		([GLAccountCode])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_GLAccount_GLAccountLabel]
		UNIQUE
		NONCLUSTERED
		([GLAccountLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_GLAccount_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_GLAccount]
		PRIMARY KEY
		CLUSTERED
		([GLAccountSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the GLAccount table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'GLAccount', 'CONSTRAINT', N'pk_GLAccount'
GO
ALTER TABLE [dbo].[GLAccount]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_GLAccount]
	CHECK
	([dbo].[fGLAccount#Check]([GLAccountSID],[GLAccountCode],[GLAccountLabel],[IsRevenueAccount],[IsBankAccount],[IsTaxAccount],[IsPAPAccount],[IsUnappliedPaymentAccount],[DeferredGLAccountCode],[IsActive],[GLAccountXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[GLAccount]
CHECK CONSTRAINT [ck_GLAccount]
GO
ALTER TABLE [dbo].[GLAccount]
	ADD
	CONSTRAINT [df_GLAccount_IsRevenueAccount]
	DEFAULT ((0)) FOR [IsRevenueAccount]
GO
ALTER TABLE [dbo].[GLAccount]
	ADD
	CONSTRAINT [df_GLAccount_IsBankAccount]
	DEFAULT ((0)) FOR [IsBankAccount]
GO
ALTER TABLE [dbo].[GLAccount]
	ADD
	CONSTRAINT [df_GLAccount_IsTaxAccount]
	DEFAULT ((0)) FOR [IsTaxAccount]
GO
ALTER TABLE [dbo].[GLAccount]
	ADD
	CONSTRAINT [df_GLAccount_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[GLAccount]
	ADD
	CONSTRAINT [df_GLAccount_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[GLAccount]
	ADD
	CONSTRAINT [df_GLAccount_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[GLAccount]
	ADD
	CONSTRAINT [df_GLAccount_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[GLAccount]
	ADD
	CONSTRAINT [df_GLAccount_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[GLAccount]
	ADD
	CONSTRAINT [df_GLAccount_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[GLAccount]
	ADD
	CONSTRAINT [df_GLAccount_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[GLAccount]
	ADD
	CONSTRAINT [df_GLAccount_IsPAPAccount]
	DEFAULT (CONVERT([bit],(0))) FOR [IsPAPAccount]
GO
ALTER TABLE [dbo].[GLAccount]
	ADD
	CONSTRAINT [df_GLAccount_IsUnappliedPaymentAccount]
	DEFAULT (CONVERT([bit],(0))) FOR [IsUnappliedPaymentAccount]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_GLAccount_IsUnappliedPaymentAccount]
	ON [dbo].[GLAccount] ([IsUnappliedPaymentAccount])
	WHERE (([IsUnappliedPaymentAccount]=(1)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Is Unapplied Payment Account value is not duplicated where the condition: "([IsUnappliedPaymentAccount]=(1))" is met', 'SCHEMA', N'dbo', 'TABLE', N'GLAccount', 'INDEX', N'ux_GLAccount_IsUnappliedPaymentAccount'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_GLAccount_LegacyKey]
	ON [dbo].[GLAccount] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'GLAccount', 'INDEX', N'ux_GLAccount_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the glaccount assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'GLAccount', 'COLUMN', N'GLAccountSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A code for the account used on transactions passed to an external accounting system (a "general ledger" account code)', 'SCHEMA', N'dbo', 'TABLE', N'GLAccount', 'COLUMN', N'GLAccountCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the glaccount to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'GLAccount', 'COLUMN', N'GLAccountLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this is account is for collecting revenue - e.g. from registrations, exams, or products provided by the College', 'SCHEMA', N'dbo', 'TABLE', N'GLAccount', 'COLUMN', N'IsRevenueAccount'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this account can accept payments (eligible for selection when creating payment batches)', 'SCHEMA', N'dbo', 'TABLE', N'GLAccount', 'COLUMN', N'IsBankAccount'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this is a liability account used to collect one or more tax types', 'SCHEMA', N'dbo', 'TABLE', N'GLAccount', 'COLUMN', N'IsTaxAccount'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The account where pre-authorized payments are deposited in the GL.  Note - this account must also be marked as a "bank account".', 'SCHEMA', N'dbo', 'TABLE', N'GLAccount', 'COLUMN', N'IsPAPAccount'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this account is used to record the liability of payments collected but which are not applied to any invoices.  Only one Unapplied Payment account is allowed. Setting this value on will un-set it on any other account that may have had the designation previously.', 'SCHEMA', N'dbo', 'TABLE', N'GLAccount', 'COLUMN', N'IsUnappliedPaymentAccount'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional account code applying to revenue accounts only to accrue revenue collected for the next registration year.  This account applies primarily to renewal transactions which collect funds in the current year for registrations which take effect the following year.  You can separate that revenue into different accounts based on filling out this code. If not filled in, the base revenue account is used.  Note that the Registration Year for which the funds are collected is available for report selection whether or not deferred accounts are used.', 'SCHEMA', N'dbo', 'TABLE', N'GLAccount', 'COLUMN', N'DeferredGLAccountCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this glaccount record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'TABLE', N'GLAccount', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the glaccount | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'GLAccount', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'GLAccount', 'COLUMN', N'GLAccountXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'GLAccount', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'GLAccount', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the glaccount | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'GLAccount', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this glaccount record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'GLAccount', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the glaccount | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'GLAccount', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the glaccount record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'GLAccount', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the glaccount record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'GLAccount', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'GLAccount', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the GLAccount Code column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'GLAccount', 'CONSTRAINT', N'uk_GLAccount_GLAccountCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the GLAccount Label column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'GLAccount', 'CONSTRAINT', N'uk_GLAccount_GLAccountLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'GLAccount', 'CONSTRAINT', N'uk_GLAccount_RowGUID'
GO
ALTER TABLE [dbo].[GLAccount] SET (LOCK_ESCALATION = TABLE)
GO
