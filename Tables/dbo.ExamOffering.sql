SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ExamOffering] (
		[ExamOfferingSID]          [int] IDENTITY(1000001, 1) NOT NULL,
		[ExamSID]                  [int] NOT NULL,
		[OrgSID]                   [int] NOT NULL,
		[ExamTime]                 [datetime] NULL,
		[SeatingCapacity]          [int] NULL,
		[CatalogItemSID]           [int] NULL,
		[BookingCutOffDate]        [date] NULL,
		[VendorExamOfferingID]     [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[UserDefinedColumns]       [xml] NULL,
		[ExamOfferingXID]          [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                [bit] NOT NULL,
		[CreateUser]               [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]               [datetimeoffset](7) NOT NULL,
		[UpdateUser]               [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]               [datetimeoffset](7) NOT NULL,
		[RowGUID]                  [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                 [timestamp] NOT NULL,
		CONSTRAINT [uk_ExamOffering_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_ExamOffering_ExamSID_ExamTime_OrgSID]
		UNIQUE
		NONCLUSTERED
		([ExamSID], [ExamTime], [OrgSID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_ExamOffering]
		PRIMARY KEY
		CLUSTERED
		([ExamOfferingSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Exam Offering table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'ExamOffering', 'CONSTRAINT', N'pk_ExamOffering'
GO
ALTER TABLE [dbo].[ExamOffering]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_ExamOffering]
	CHECK
	([dbo].[fExamOffering#Check]([ExamOfferingSID],[ExamSID],[OrgSID],[ExamTime],[SeatingCapacity],[CatalogItemSID],[BookingCutOffDate],[VendorExamOfferingID],[ExamOfferingXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[ExamOffering]
CHECK CONSTRAINT [ck_ExamOffering]
GO
ALTER TABLE [dbo].[ExamOffering]
	ADD
	CONSTRAINT [df_ExamOffering_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[ExamOffering]
	ADD
	CONSTRAINT [df_ExamOffering_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[ExamOffering]
	ADD
	CONSTRAINT [df_ExamOffering_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[ExamOffering]
	ADD
	CONSTRAINT [df_ExamOffering_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[ExamOffering]
	ADD
	CONSTRAINT [df_ExamOffering_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[ExamOffering]
	ADD
	CONSTRAINT [df_ExamOffering_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[ExamOffering]
	WITH CHECK
	ADD CONSTRAINT [fk_ExamOffering_Org_OrgSID]
	FOREIGN KEY ([OrgSID]) REFERENCES [dbo].[Org] ([OrgSID])
ALTER TABLE [dbo].[ExamOffering]
	CHECK CONSTRAINT [fk_ExamOffering_Org_OrgSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the org system ID column in the Exam Offering table match a org system ID in the Org table. It also ensures that records in the Org table cannot be deleted if matching child records exist in Exam Offering. Finally, the constraint blocks changes to the value of the org system ID column in the Org if matching child records exist in Exam Offering.', 'SCHEMA', N'dbo', 'TABLE', N'ExamOffering', 'CONSTRAINT', N'fk_ExamOffering_Org_OrgSID'
GO
ALTER TABLE [dbo].[ExamOffering]
	WITH CHECK
	ADD CONSTRAINT [fk_ExamOffering_Exam_ExamSID]
	FOREIGN KEY ([ExamSID]) REFERENCES [dbo].[Exam] ([ExamSID])
ALTER TABLE [dbo].[ExamOffering]
	CHECK CONSTRAINT [fk_ExamOffering_Exam_ExamSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the exam system ID column in the Exam Offering table match a exam system ID in the Exam table. It also ensures that records in the Exam table cannot be deleted if matching child records exist in Exam Offering. Finally, the constraint blocks changes to the value of the exam system ID column in the Exam if matching child records exist in Exam Offering.', 'SCHEMA', N'dbo', 'TABLE', N'ExamOffering', 'CONSTRAINT', N'fk_ExamOffering_Exam_ExamSID'
GO
ALTER TABLE [dbo].[ExamOffering]
	WITH CHECK
	ADD CONSTRAINT [fk_ExamOffering_CatalogItem_CatalogItemSID]
	FOREIGN KEY ([CatalogItemSID]) REFERENCES [dbo].[CatalogItem] ([CatalogItemSID])
ALTER TABLE [dbo].[ExamOffering]
	CHECK CONSTRAINT [fk_ExamOffering_CatalogItem_CatalogItemSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the catalog item system ID column in the Exam Offering table match a catalog item system ID in the Catalog Item table. It also ensures that records in the Catalog Item table cannot be deleted if matching child records exist in Exam Offering. Finally, the constraint blocks changes to the value of the catalog item system ID column in the Catalog Item if matching child records exist in Exam Offering.', 'SCHEMA', N'dbo', 'TABLE', N'ExamOffering', 'CONSTRAINT', N'fk_ExamOffering_CatalogItem_CatalogItemSID'
GO
CREATE NONCLUSTERED INDEX [ix_ExamOffering_CatalogItemSID_ExamOfferingSID]
	ON [dbo].[ExamOffering] ([CatalogItemSID], [ExamOfferingSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Catalog Item SID foreign key column and avoids row contention on (parent) Catalog Item updates', 'SCHEMA', N'dbo', 'TABLE', N'ExamOffering', 'INDEX', N'ix_ExamOffering_CatalogItemSID_ExamOfferingSID'
GO
CREATE NONCLUSTERED INDEX [ix_ExamOffering_OrgSID_ExamOfferingSID]
	ON [dbo].[ExamOffering] ([OrgSID], [ExamOfferingSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Org SID foreign key column and avoids row contention on (parent) Org updates', 'SCHEMA', N'dbo', 'TABLE', N'ExamOffering', 'INDEX', N'ix_ExamOffering_OrgSID_ExamOfferingSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_ExamOffering_VendorExamOfferingID]
	ON [dbo].[ExamOffering] ([VendorExamOfferingID])
	WHERE (([VendorExamOfferingID] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Vendor Exam Offering ID value is not duplicated where the condition: "([VendorExamOfferingID] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'ExamOffering', 'INDEX', N'ux_ExamOffering_VendorExamOfferingID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The Exam Offering record is required to record exam results for members.  Recording exam results is a function of the base Registration module.  Booking exams online and paying for them is also possible through the base modules. Where the exam is a physical sitting, the Exam Time and Seating Capacity and a cut-off date need to be filled in.  The cut off date defines the date after which further booking is not allowed. Exam Offering records are also required for exams configured through the Alinity Jurisprudence module for online delivery.  When a new version of the exam is published, the Expiry Time value is automatically set to prevent the old version of the exam from being offered.  ', 'SCHEMA', N'dbo', 'TABLE', N'ExamOffering', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the exam offering assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'ExamOffering', 'COLUMN', N'ExamOfferingSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The exam this offering is defined for', 'SCHEMA', N'dbo', 'TABLE', N'ExamOffering', 'COLUMN', N'ExamSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The org assigned to this exam offering', 'SCHEMA', N'dbo', 'TABLE', N'ExamOffering', 'COLUMN', N'OrgSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date the exam was taken', 'SCHEMA', N'dbo', 'TABLE', N'ExamOffering', 'COLUMN', N'ExamTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The catalog item assigned to this exam offering', 'SCHEMA', N'dbo', 'TABLE', N'ExamOffering', 'COLUMN', N'CatalogItemSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional and unique identifier provided by the vendor/service to identify the exam offering | This value can be used when importing exam candidates to automatically book or associate a result with the exam offering ', 'SCHEMA', N'dbo', 'TABLE', N'ExamOffering', 'COLUMN', N'VendorExamOfferingID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the exam offering | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'ExamOffering', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'ExamOffering', 'COLUMN', N'ExamOfferingXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'ExamOffering', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'ExamOffering', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the exam offering | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'ExamOffering', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this exam offering record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'ExamOffering', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the exam offering | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'ExamOffering', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the exam offering record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'ExamOffering', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the exam offering record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'ExamOffering', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'ExamOffering', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'ExamOffering', 'CONSTRAINT', N'uk_ExamOffering_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the combination of values provided for the "Exam SID + Exam Time + Org SID" columns is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'ExamOffering', 'CONSTRAINT', N'uk_ExamOffering_ExamSID_ExamTime_OrgSID'
GO
ALTER TABLE [dbo].[ExamOffering] SET (LOCK_ESCALATION = TABLE)
GO
