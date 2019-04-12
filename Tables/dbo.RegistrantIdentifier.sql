SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RegistrantIdentifier] (
		[RegistrantIdentifierSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[RegistrantSID]               [int] NOT NULL,
		[IdentifierValue]             [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IdentifierTypeSID]           [int] NOT NULL,
		[EffectiveDate]               [date] NULL,
		[ExpiryDate]                  [date] NULL,
		[UserDefinedColumns]          [xml] NULL,
		[RegistrantIdentifierXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                   [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                   [bit] NOT NULL,
		[CreateUser]                  [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                  [datetimeoffset](7) NOT NULL,
		[UpdateUser]                  [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                  [datetimeoffset](7) NOT NULL,
		[RowGUID]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                    [timestamp] NOT NULL,
		CONSTRAINT [uk_RegistrantIdentifier_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_RegistrantIdentifier]
		PRIMARY KEY
		CLUSTERED
		([RegistrantIdentifierSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Registrant Identifier table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantIdentifier', 'CONSTRAINT', N'pk_RegistrantIdentifier'
GO
ALTER TABLE [dbo].[RegistrantIdentifier]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_RegistrantIdentifier]
	CHECK
	([dbo].[fRegistrantIdentifier#Check]([RegistrantIdentifierSID],[RegistrantSID],[IdentifierValue],[IdentifierTypeSID],[EffectiveDate],[ExpiryDate],[RegistrantIdentifierXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[RegistrantIdentifier]
CHECK CONSTRAINT [ck_RegistrantIdentifier]
GO
ALTER TABLE [dbo].[RegistrantIdentifier]
	ADD
	CONSTRAINT [df_RegistrantIdentifier_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[RegistrantIdentifier]
	ADD
	CONSTRAINT [df_RegistrantIdentifier_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[RegistrantIdentifier]
	ADD
	CONSTRAINT [df_RegistrantIdentifier_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[RegistrantIdentifier]
	ADD
	CONSTRAINT [df_RegistrantIdentifier_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[RegistrantIdentifier]
	ADD
	CONSTRAINT [df_RegistrantIdentifier_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[RegistrantIdentifier]
	ADD
	CONSTRAINT [df_RegistrantIdentifier_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[RegistrantIdentifier]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantIdentifier_Registrant_RegistrantSID]
	FOREIGN KEY ([RegistrantSID]) REFERENCES [dbo].[Registrant] ([RegistrantSID])
	ON DELETE CASCADE
ALTER TABLE [dbo].[RegistrantIdentifier]
	CHECK CONSTRAINT [fk_RegistrantIdentifier_Registrant_RegistrantSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the registrant system ID column in the Registrant Identifier table match a registrant system ID in the Registrant table. It also ensures that when a record in the Registrant table is deleted, matching child records in the Registrant Identifier table are deleted as well. Finally, the constraint blocks changes to the value of the registrant system ID column in the Registrant if matching child records exist in Registrant Identifier.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantIdentifier', 'CONSTRAINT', N'fk_RegistrantIdentifier_Registrant_RegistrantSID'
GO
ALTER TABLE [dbo].[RegistrantIdentifier]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantIdentifier_IdentifierType_IdentifierTypeSID]
	FOREIGN KEY ([IdentifierTypeSID]) REFERENCES [dbo].[IdentifierType] ([IdentifierTypeSID])
ALTER TABLE [dbo].[RegistrantIdentifier]
	CHECK CONSTRAINT [fk_RegistrantIdentifier_IdentifierType_IdentifierTypeSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the identifier type system ID column in the Registrant Identifier table match a identifier type system ID in the Identifier Type table. It also ensures that records in the Identifier Type table cannot be deleted if matching child records exist in Registrant Identifier. Finally, the constraint blocks changes to the value of the identifier type system ID column in the Identifier Type if matching child records exist in Registrant Identifier.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantIdentifier', 'CONSTRAINT', N'fk_RegistrantIdentifier_IdentifierType_IdentifierTypeSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantIdentifier_IdentifierTypeSID_RegistrantIdentifierSID]
	ON [dbo].[RegistrantIdentifier] ([IdentifierTypeSID], [RegistrantIdentifierSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Identifier Type SID foreign key column and avoids row contention on (parent) Identifier Type updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantIdentifier', 'INDEX', N'ix_RegistrantIdentifier_IdentifierTypeSID_RegistrantIdentifierSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantIdentifier_IdentifierValue]
	ON [dbo].[RegistrantIdentifier] ([IdentifierValue])
	INCLUDE ([RegistrantSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Improves performance of Registrant Identifier searches based on the Identifier Value column', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantIdentifier', 'INDEX', N'ix_RegistrantIdentifier_IdentifierValue'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantIdentifier_RegistrantSID_RegistrantIdentifierSID]
	ON [dbo].[RegistrantIdentifier] ([RegistrantSID], [RegistrantIdentifierSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Registrant SID foreign key column and avoids row contention on (parent) Registrant updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantIdentifier', 'INDEX', N'ix_RegistrantIdentifier_RegistrantSID_RegistrantIdentifierSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Registrant Identifiers are key values used to locate or confirm identify of the Registrant. These values are unique identifiers assigned by external systems or registries. The value of the ID in combination with their type (defined in the Identifier Type table), cannot be duplicated. ', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantIdentifier', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant identifier assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantIdentifier', 'COLUMN', N'RegistrantIdentifierSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The registrant this identifier is defined for', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantIdentifier', 'COLUMN', N'RegistrantSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of registrant identifier', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantIdentifier', 'COLUMN', N'IdentifierTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date this identifier became effective.  Applies to permit/licenses and temporary ID''s.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantIdentifier', 'COLUMN', N'EffectiveDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date after which the identifier ceases to be valid. Applies to permit/licenses and temporary ID''s.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantIdentifier', 'COLUMN', N'ExpiryDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the registrant identifier | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantIdentifier', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantIdentifier', 'COLUMN', N'RegistrantIdentifierXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantIdentifier', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantIdentifier', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the registrant identifier | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantIdentifier', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this registrant identifier record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantIdentifier', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the registrant identifier | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantIdentifier', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the registrant identifier record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantIdentifier', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registrant identifier record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantIdentifier', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantIdentifier', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantIdentifier', 'CONSTRAINT', N'uk_RegistrantIdentifier_RowGUID'
GO
ALTER TABLE [dbo].[RegistrantIdentifier] SET (LOCK_ESCALATION = TABLE)
GO
