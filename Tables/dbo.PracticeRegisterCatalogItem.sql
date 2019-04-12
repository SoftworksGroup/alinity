SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PracticeRegisterCatalogItem] (
		[PracticeRegisterCatalogItemSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[PracticeRegisterSID]                [int] NOT NULL,
		[CatalogItemSID]                     [int] NOT NULL,
		[IsAppliedOnApplication]             [bit] NOT NULL,
		[IsAppliedOnApplicationApproval]     [bit] NOT NULL,
		[IsAppliedOnRenewal]                 [bit] NOT NULL,
		[IsAppliedOnReinstatement]           [bit] NOT NULL,
		[IsAppliedOnRegChange]               [bit] NOT NULL,
		[IsAppliedToPAPSubscribers]          [bit] NOT NULL,
		[PracticeRegisterSectionSID]         [int] NULL,
		[PracticeRegisterChangeSID]          [int] NULL,
		[FeeSequence]                        [smallint] NOT NULL,
		[EffectiveTime]                      [datetime] NOT NULL,
		[ExpiryTime]                         [datetime] NULL,
		[UserDefinedColumns]                 [xml] NULL,
		[PracticeRegisterCatalogItemXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                          [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                          [bit] NOT NULL,
		[CreateUser]                         [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                         [datetimeoffset](7) NOT NULL,
		[UpdateUser]                         [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                         [datetimeoffset](7) NOT NULL,
		[RowGUID]                            [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                           [timestamp] NOT NULL,
		CONSTRAINT [uk_PracticeRegisterCatalogItem_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_PracticeRegisterCatalogItem]
		PRIMARY KEY
		CLUSTERED
		([PracticeRegisterCatalogItemSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Practice Register Catalog Item table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterCatalogItem', 'CONSTRAINT', N'pk_PracticeRegisterCatalogItem'
GO
ALTER TABLE [dbo].[PracticeRegisterCatalogItem]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_PracticeRegisterCatalogItem]
	CHECK
	([dbo].[fPracticeRegisterCatalogItem#Check]([PracticeRegisterCatalogItemSID],[PracticeRegisterSID],[CatalogItemSID],[IsAppliedOnApplication],[IsAppliedOnApplicationApproval],[IsAppliedOnRenewal],[IsAppliedOnReinstatement],[IsAppliedOnRegChange],[IsAppliedToPAPSubscribers],[PracticeRegisterSectionSID],[PracticeRegisterChangeSID],[FeeSequence],[EffectiveTime],[ExpiryTime],[PracticeRegisterCatalogItemXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[PracticeRegisterCatalogItem]
CHECK CONSTRAINT [ck_PracticeRegisterCatalogItem]
GO
ALTER TABLE [dbo].[PracticeRegisterCatalogItem]
	ADD
	CONSTRAINT [df_PracticeRegisterCatalogItem_IsAppliedOnApplication]
	DEFAULT (CONVERT([bit],(1))) FOR [IsAppliedOnApplication]
GO
ALTER TABLE [dbo].[PracticeRegisterCatalogItem]
	ADD
	CONSTRAINT [df_PracticeRegisterCatalogItem_IsAppliedOnApplicationApproval]
	DEFAULT (CONVERT([bit],(0))) FOR [IsAppliedOnApplicationApproval]
GO
ALTER TABLE [dbo].[PracticeRegisterCatalogItem]
	ADD
	CONSTRAINT [df_PracticeRegisterCatalogItem_IsAppliedOnRenewal]
	DEFAULT (CONVERT([bit],(0))) FOR [IsAppliedOnRenewal]
GO
ALTER TABLE [dbo].[PracticeRegisterCatalogItem]
	ADD
	CONSTRAINT [df_PracticeRegisterCatalogItem_IsAppliedOnReinstatement]
	DEFAULT (CONVERT([bit],(0))) FOR [IsAppliedOnReinstatement]
GO
ALTER TABLE [dbo].[PracticeRegisterCatalogItem]
	ADD
	CONSTRAINT [df_PracticeRegisterCatalogItem_IsAppliedOnRegChange]
	DEFAULT (CONVERT([bit],(0))) FOR [IsAppliedOnRegChange]
GO
ALTER TABLE [dbo].[PracticeRegisterCatalogItem]
	ADD
	CONSTRAINT [df_PracticeRegisterCatalogItem_IsAppliedToPAPSubscribers]
	DEFAULT ((0)) FOR [IsAppliedToPAPSubscribers]
GO
ALTER TABLE [dbo].[PracticeRegisterCatalogItem]
	ADD
	CONSTRAINT [df_PracticeRegisterCatalogItem_FeeSequence]
	DEFAULT ((10)) FOR [FeeSequence]
GO
ALTER TABLE [dbo].[PracticeRegisterCatalogItem]
	ADD
	CONSTRAINT [df_PracticeRegisterCatalogItem_EffectiveTime]
	DEFAULT (CONVERT([datetime],[sf].[fToday]())) FOR [EffectiveTime]
GO
ALTER TABLE [dbo].[PracticeRegisterCatalogItem]
	ADD
	CONSTRAINT [df_PracticeRegisterCatalogItem_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[PracticeRegisterCatalogItem]
	ADD
	CONSTRAINT [df_PracticeRegisterCatalogItem_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[PracticeRegisterCatalogItem]
	ADD
	CONSTRAINT [df_PracticeRegisterCatalogItem_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[PracticeRegisterCatalogItem]
	ADD
	CONSTRAINT [df_PracticeRegisterCatalogItem_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[PracticeRegisterCatalogItem]
	ADD
	CONSTRAINT [df_PracticeRegisterCatalogItem_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[PracticeRegisterCatalogItem]
	ADD
	CONSTRAINT [df_PracticeRegisterCatalogItem_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[PracticeRegisterCatalogItem]
	WITH CHECK
	ADD CONSTRAINT [fk_PracticeRegisterCatalogItem_PracticeRegisterChange_PracticeRegisterChangeSID]
	FOREIGN KEY ([PracticeRegisterChangeSID]) REFERENCES [dbo].[PracticeRegisterChange] ([PracticeRegisterChangeSID])
ALTER TABLE [dbo].[PracticeRegisterCatalogItem]
	CHECK CONSTRAINT [fk_PracticeRegisterCatalogItem_PracticeRegisterChange_PracticeRegisterChangeSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the practice register change system ID column in the Practice Register Catalog Item table match a practice register change system ID in the Practice Register Change table. It also ensures that records in the Practice Register Change table cannot be deleted if matching child records exist in Practice Register Catalog Item. Finally, the constraint blocks changes to the value of the practice register change system ID column in the Practice Register Change if matching child records exist in Practice Register Catalog Item.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterCatalogItem', 'CONSTRAINT', N'fk_PracticeRegisterCatalogItem_PracticeRegisterChange_PracticeRegisterChangeSID'
GO
ALTER TABLE [dbo].[PracticeRegisterCatalogItem]
	WITH CHECK
	ADD CONSTRAINT [fk_PracticeRegisterCatalogItem_PracticeRegisterSection_PracticeRegisterSectionSID]
	FOREIGN KEY ([PracticeRegisterSectionSID]) REFERENCES [dbo].[PracticeRegisterSection] ([PracticeRegisterSectionSID])
ALTER TABLE [dbo].[PracticeRegisterCatalogItem]
	CHECK CONSTRAINT [fk_PracticeRegisterCatalogItem_PracticeRegisterSection_PracticeRegisterSectionSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the practice register section system ID column in the Practice Register Catalog Item table match a practice register section system ID in the Practice Register Section table. It also ensures that records in the Practice Register Section table cannot be deleted if matching child records exist in Practice Register Catalog Item. Finally, the constraint blocks changes to the value of the practice register section system ID column in the Practice Register Section if matching child records exist in Practice Register Catalog Item.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterCatalogItem', 'CONSTRAINT', N'fk_PracticeRegisterCatalogItem_PracticeRegisterSection_PracticeRegisterSectionSID'
GO
ALTER TABLE [dbo].[PracticeRegisterCatalogItem]
	WITH CHECK
	ADD CONSTRAINT [fk_PracticeRegisterCatalogItem_PracticeRegister_PracticeRegisterSID]
	FOREIGN KEY ([PracticeRegisterSID]) REFERENCES [dbo].[PracticeRegister] ([PracticeRegisterSID])
ALTER TABLE [dbo].[PracticeRegisterCatalogItem]
	CHECK CONSTRAINT [fk_PracticeRegisterCatalogItem_PracticeRegister_PracticeRegisterSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the practice register system ID column in the Practice Register Catalog Item table match a practice register system ID in the Practice Register table. It also ensures that records in the Practice Register table cannot be deleted if matching child records exist in Practice Register Catalog Item. Finally, the constraint blocks changes to the value of the practice register system ID column in the Practice Register if matching child records exist in Practice Register Catalog Item.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterCatalogItem', 'CONSTRAINT', N'fk_PracticeRegisterCatalogItem_PracticeRegister_PracticeRegisterSID'
GO
ALTER TABLE [dbo].[PracticeRegisterCatalogItem]
	WITH CHECK
	ADD CONSTRAINT [fk_PracticeRegisterCatalogItem_CatalogItem_CatalogItemSID]
	FOREIGN KEY ([CatalogItemSID]) REFERENCES [dbo].[CatalogItem] ([CatalogItemSID])
ALTER TABLE [dbo].[PracticeRegisterCatalogItem]
	CHECK CONSTRAINT [fk_PracticeRegisterCatalogItem_CatalogItem_CatalogItemSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the catalog item system ID column in the Practice Register Catalog Item table match a catalog item system ID in the Catalog Item table. It also ensures that records in the Catalog Item table cannot be deleted if matching child records exist in Practice Register Catalog Item. Finally, the constraint blocks changes to the value of the catalog item system ID column in the Catalog Item if matching child records exist in Practice Register Catalog Item.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterCatalogItem', 'CONSTRAINT', N'fk_PracticeRegisterCatalogItem_CatalogItem_CatalogItemSID'
GO
CREATE NONCLUSTERED INDEX [ix_PracticeRegisterCatalogItem_CatalogItemSID_PracticeRegisterCatalogItemSID]
	ON [dbo].[PracticeRegisterCatalogItem] ([CatalogItemSID], [PracticeRegisterCatalogItemSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Catalog Item SID foreign key column and avoids row contention on (parent) Catalog Item updates', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterCatalogItem', 'INDEX', N'ix_PracticeRegisterCatalogItem_CatalogItemSID_PracticeRegisterCatalogItemSID'
GO
CREATE NONCLUSTERED INDEX [ix_PracticeRegisterCatalogItem_PracticeRegisterChangeSID_PracticeRegisterCatalogItemSID]
	ON [dbo].[PracticeRegisterCatalogItem] ([PracticeRegisterChangeSID], [PracticeRegisterCatalogItemSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Practice Register Change SID foreign key column and avoids row contention on (parent) Practice Register Change updates', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterCatalogItem', 'INDEX', N'ix_PracticeRegisterCatalogItem_PracticeRegisterChangeSID_PracticeRegisterCatalogItemSID'
GO
CREATE NONCLUSTERED INDEX [ix_PracticeRegisterCatalogItem_PracticeRegisterSectionSID_PracticeRegisterCatalogItemSID]
	ON [dbo].[PracticeRegisterCatalogItem] ([PracticeRegisterSectionSID], [PracticeRegisterCatalogItemSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Practice Register Section SID foreign key column and avoids row contention on (parent) Practice Register Section updates', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterCatalogItem', 'INDEX', N'ix_PracticeRegisterCatalogItem_PracticeRegisterSectionSID_PracticeRegisterCatalogItemSID'
GO
CREATE NONCLUSTERED INDEX [ix_PracticeRegisterCatalogItem_PracticeRegisterSID_PracticeRegisterCatalogItemSID]
	ON [dbo].[PracticeRegisterCatalogItem] ([PracticeRegisterSID], [PracticeRegisterCatalogItemSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Practice Register SID foreign key column and avoids row contention on (parent) Practice Register updates', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterCatalogItem', 'INDEX', N'ix_PracticeRegisterCatalogItem_PracticeRegisterSID_PracticeRegisterCatalogItemSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'
This table describes the fees associated with applications, renewals and reinstatements on this register.  The prices and descriptions which appear on the invoice are defined as Catalog-Items but this table defines to which form types a fee applies and in which contexts. The context definition includes identifying whether the fee only applies as a “late fee”.  The timing of the late fee start is defined on the practice register record.

Where the fee applies to all sections in the specified register then the Practice-Register-Section-SID can be left null.  If a fee only applies to a section on the register the section key must be specified.  This is useful for example, where a surcharge is applied for applications from international grads which are more complex and require more administrative time.   Where a different fee applies to that section when changing from other registrations (Reinstatements and Admin registration changes), then a Practice-Register-Change-SID must be provided identifying the change (the "from->to") it applies to. If the fee does not vary based on the register they are coming from, the value may be left blank.  Note that the mapping is not used for Applications and generally not for Renewals.  

The IsPriorPaymentDeducted can be set to impact fee calculation so that amounts paid for the previous registration in that same registration year (if any) should be deducted from the amount owing.  If the person renewed as Active (e.g. paid $350) and switches to InActive shortly thereafter (e.g charge is $50), then turning this value on could result in a credit (refund scenario). Note that the calculation is based on the amount actually paid for the previous registration and not invoiced but unpaid amounts. Prorating fees is supported through the catalog pricing structure and is taken into consideration when previously paid fees in the same registration year should be deducted.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterCatalogItem', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the practice register catalog item assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterCatalogItem', 'COLUMN', N'PracticeRegisterCatalogItemSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The practice register this catalog item is defined for', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterCatalogItem', 'COLUMN', N'PracticeRegisterSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The catalog item assigned to this practice register', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterCatalogItem', 'COLUMN', N'CatalogItemSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this fee applies when an application is first initiated (separate fee(s) must be configured for application approval)', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterCatalogItem', 'COLUMN', N'IsAppliedOnApplication'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this fee applies when then application is approved ', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterCatalogItem', 'COLUMN', N'IsAppliedOnApplicationApproval'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this fee applies for renewal invoices (disabled if this register does not allow renewals)', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterCatalogItem', 'COLUMN', N'IsAppliedOnRenewal'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this fee applies for reinstatement transactions (disabled if this register does not allow reinstatements)', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterCatalogItem', 'COLUMN', N'IsAppliedOnReinstatement'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this fee applies for registration change. The amount can be refined through proration and deducting prior fees paid in the same registration year.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterCatalogItem', 'COLUMN', N'IsAppliedOnRegChange'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this fee applies only to Pre-Authorized Payment subscribers (this is typically used for an Admin Fee charged to PAP subsribers at Renewal time).', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterCatalogItem', 'COLUMN', N'IsAppliedToPAPSubscribers'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the practice register section assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterCatalogItem', 'COLUMN', N'PracticeRegisterSectionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the practice register change assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterCatalogItem', 'COLUMN', N'PracticeRegisterChangeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A value to control the display order of fees on the invoice.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterCatalogItem', 'COLUMN', N'FeeSequence'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the item becomes available for including on invoices.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterCatalogItem', 'COLUMN', N'EffectiveTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the item is no longer available for including on invoices.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterCatalogItem', 'COLUMN', N'ExpiryTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the practice register catalog item | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterCatalogItem', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterCatalogItem', 'COLUMN', N'PracticeRegisterCatalogItemXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterCatalogItem', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterCatalogItem', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the practice register catalog item | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterCatalogItem', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this practice register catalog item record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterCatalogItem', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the practice register catalog item | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterCatalogItem', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the practice register catalog item record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterCatalogItem', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the practice register catalog item record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterCatalogItem', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterCatalogItem', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterCatalogItem', 'CONSTRAINT', N'uk_PracticeRegisterCatalogItem_RowGUID'
GO
ALTER TABLE [dbo].[PracticeRegisterCatalogItem] SET (LOCK_ESCALATION = TABLE)
GO
