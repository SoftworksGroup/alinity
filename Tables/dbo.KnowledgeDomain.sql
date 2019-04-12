SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[KnowledgeDomain] (
		[KnowledgeDomainSID]       [int] IDENTITY(1000001, 1) NOT NULL,
		[KnowledgeDomainLabel]     [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IsDefault]                [bit] NOT NULL,
		[IsActive]                 [bit] NOT NULL,
		[UserDefinedColumns]       [xml] NULL,
		[KnowledgeDomainXID]       [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                [bit] NOT NULL,
		[CreateUser]               [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]               [datetimeoffset](7) NOT NULL,
		[UpdateUser]               [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]               [datetimeoffset](7) NOT NULL,
		[RowGUID]                  [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                 [timestamp] NOT NULL,
		CONSTRAINT [uk_KnowledgeDomain_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_KnowledgeDomain_KnowledgeDomainLabel]
		UNIQUE
		NONCLUSTERED
		([KnowledgeDomainLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_KnowledgeDomain]
		PRIMARY KEY
		CLUSTERED
		([KnowledgeDomainSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Knowledge Domain table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'KnowledgeDomain', 'CONSTRAINT', N'pk_KnowledgeDomain'
GO
ALTER TABLE [dbo].[KnowledgeDomain]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_KnowledgeDomain]
	CHECK
	([dbo].[fKnowledgeDomain#Check]([KnowledgeDomainSID],[KnowledgeDomainLabel],[IsDefault],[IsActive],[KnowledgeDomainXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[KnowledgeDomain]
CHECK CONSTRAINT [ck_KnowledgeDomain]
GO
ALTER TABLE [dbo].[KnowledgeDomain]
	ADD
	CONSTRAINT [df_KnowledgeDomain_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[KnowledgeDomain]
	ADD
	CONSTRAINT [df_KnowledgeDomain_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[KnowledgeDomain]
	ADD
	CONSTRAINT [df_KnowledgeDomain_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[KnowledgeDomain]
	ADD
	CONSTRAINT [df_KnowledgeDomain_IsDefault]
	DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [dbo].[KnowledgeDomain]
	ADD
	CONSTRAINT [df_KnowledgeDomain_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[KnowledgeDomain]
	ADD
	CONSTRAINT [df_KnowledgeDomain_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[KnowledgeDomain]
	ADD
	CONSTRAINT [df_KnowledgeDomain_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[KnowledgeDomain]
	ADD
	CONSTRAINT [df_KnowledgeDomain_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_KnowledgeDomain_IsDefault]
	ON [dbo].[KnowledgeDomain] ([IsDefault])
	WHERE (([IsDefault]=(1)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure that only 1 record is marked as the default Knowledge Domain', 'SCHEMA', N'dbo', 'TABLE', N'KnowledgeDomain', 'INDEX', N'ux_KnowledgeDomain_IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The Knowledge Domain table is used to classify questions according to the area of competence they are targeted to evaluate. The classifications can be set according to the analytical goals of the organization but the application ships with a standard set.  If a category should no longer be included on new questions it can be marked inactive.  If analysis by Knowledge Domain is not of interest, content can be reduced to a single default record the application automatically applies as new records are created.', 'SCHEMA', N'dbo', 'TABLE', N'KnowledgeDomain', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the knowledge domain assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'KnowledgeDomain', 'COLUMN', N'KnowledgeDomainSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the knowledge domain to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'KnowledgeDomain', 'COLUMN', N'KnowledgeDomainLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default knowledge domain to assign when new records are added', 'SCHEMA', N'dbo', 'TABLE', N'KnowledgeDomain', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this knowledge domain record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'TABLE', N'KnowledgeDomain', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the knowledge domain | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'KnowledgeDomain', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'KnowledgeDomain', 'COLUMN', N'KnowledgeDomainXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'KnowledgeDomain', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'KnowledgeDomain', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the knowledge domain | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'KnowledgeDomain', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this knowledge domain record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'KnowledgeDomain', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the knowledge domain | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'KnowledgeDomain', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the knowledge domain record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'KnowledgeDomain', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the knowledge domain record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'KnowledgeDomain', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'KnowledgeDomain', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'KnowledgeDomain', 'CONSTRAINT', N'uk_KnowledgeDomain_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Knowledge Domain Label column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'KnowledgeDomain', 'CONSTRAINT', N'uk_KnowledgeDomain_KnowledgeDomainLabel'
GO
ALTER TABLE [dbo].[KnowledgeDomain] SET (LOCK_ESCALATION = TABLE)
GO
