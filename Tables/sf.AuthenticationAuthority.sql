SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[AuthenticationAuthority] (
		[AuthenticationAuthoritySID]       [int] IDENTITY(1000001, 1) NOT NULL,
		[AuthenticationAuthoritySCD]       [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[AuthenticationAuthorityLabel]     [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UsageNotes]                       [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsActive]                         [bit] NOT NULL,
		[IsDefault]                        [bit] NOT NULL,
		[UserDefinedColumns]               [xml] NULL,
		[AuthenticationAuthorityXID]       [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                        [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                        [bit] NOT NULL,
		[CreateUser]                       [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                       [datetimeoffset](7) NOT NULL,
		[UpdateUser]                       [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                       [datetimeoffset](7) NOT NULL,
		[RowGUID]                          [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                         [timestamp] NOT NULL,
		CONSTRAINT [uk_AuthenticationAuthority_AuthenticationAuthorityLabel]
		UNIQUE
		NONCLUSTERED
		([AuthenticationAuthorityLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_AuthenticationAuthority_AuthenticationAuthoritySCD]
		UNIQUE
		NONCLUSTERED
		([AuthenticationAuthoritySCD])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_AuthenticationAuthority_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_AuthenticationAuthority]
		PRIMARY KEY
		CLUSTERED
		([AuthenticationAuthoritySID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Authentication Authority table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'AuthenticationAuthority', 'CONSTRAINT', N'pk_AuthenticationAuthority'
GO
ALTER TABLE [sf].[AuthenticationAuthority]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_AuthenticationAuthority]
	CHECK
	([sf].[fAuthenticationAuthority#Check]([AuthenticationAuthoritySID],[AuthenticationAuthoritySCD],[AuthenticationAuthorityLabel],[IsActive],[IsDefault],[AuthenticationAuthorityXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[AuthenticationAuthority]
CHECK CONSTRAINT [ck_AuthenticationAuthority]
GO
ALTER TABLE [sf].[AuthenticationAuthority]
	ADD
	CONSTRAINT [df_AuthenticationAuthority_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [sf].[AuthenticationAuthority]
	ADD
	CONSTRAINT [df_AuthenticationAuthority_IsDefault]
	DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [sf].[AuthenticationAuthority]
	ADD
	CONSTRAINT [df_AuthenticationAuthority_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[AuthenticationAuthority]
	ADD
	CONSTRAINT [df_AuthenticationAuthority_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[AuthenticationAuthority]
	ADD
	CONSTRAINT [df_AuthenticationAuthority_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[AuthenticationAuthority]
	ADD
	CONSTRAINT [df_AuthenticationAuthority_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[AuthenticationAuthority]
	ADD
	CONSTRAINT [df_AuthenticationAuthority_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[AuthenticationAuthority]
	ADD
	CONSTRAINT [df_AuthenticationAuthority_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_AuthenticationAuthority_IsDefault]
	ON [sf].[AuthenticationAuthority] ([IsDefault])
	WHERE (([IsDefault]=(1)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure that only 1 record is marked as the default Authentication Authority', 'SCHEMA', N'sf', 'TABLE', N'AuthenticationAuthority', 'INDEX', N'ux_AuthenticationAuthority_IsDefault'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_AuthenticationAuthority_LegacyKey]
	ON [sf].[AuthenticationAuthority] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'AuthenticationAuthority', 'INDEX', N'ux_AuthenticationAuthority_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table stores the list of authentication methods, including federated login types, currently supported by the system (e.g. MICROSOFT, GOOGLE, LDAP.AD, etc).  The list cannot be updated by end users or configurators (no add or delete).  The label column can be updated by the end user to support client-specific terminology and language for display in drop-down lists.  For most configurations a default should not be specified, however, if a particular configuration wishes to restrict accepted authorities, this may be achieved by setting a default and marking other authorities as inactive.', 'SCHEMA', N'sf', 'TABLE', N'AuthenticationAuthority', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the authentication authority assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'AuthenticationAuthority', 'COLUMN', N'AuthenticationAuthoritySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the authentication authority | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'sf', 'TABLE', N'AuthenticationAuthority', 'COLUMN', N'AuthenticationAuthoritySCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the authentication authority to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'TABLE', N'AuthenticationAuthority', 'COLUMN', N'AuthenticationAuthorityLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A description of the authentication authority and the situations it applies to. ', 'SCHEMA', N'sf', 'TABLE', N'AuthenticationAuthority', 'COLUMN', N'UsageNotes'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this authentication authority record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'sf', 'TABLE', N'AuthenticationAuthority', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default authentication authority to assign when new records are added', 'SCHEMA', N'sf', 'TABLE', N'AuthenticationAuthority', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the authentication authority | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'AuthenticationAuthority', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'AuthenticationAuthority', 'COLUMN', N'AuthenticationAuthorityXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'AuthenticationAuthority', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'AuthenticationAuthority', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the authentication authority | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'AuthenticationAuthority', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this authentication authority record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'AuthenticationAuthority', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the authentication authority | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'AuthenticationAuthority', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the authentication authority record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'AuthenticationAuthority', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the authentication authority record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'AuthenticationAuthority', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'AuthenticationAuthority', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Authentication Authority Label column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'AuthenticationAuthority', 'CONSTRAINT', N'uk_AuthenticationAuthority_AuthenticationAuthorityLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Authentication Authority SCD column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'AuthenticationAuthority', 'CONSTRAINT', N'uk_AuthenticationAuthority_AuthenticationAuthoritySCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'AuthenticationAuthority', 'CONSTRAINT', N'uk_AuthenticationAuthority_RowGUID'
GO
ALTER TABLE [sf].[AuthenticationAuthority] SET (LOCK_ESCALATION = TABLE)
GO
