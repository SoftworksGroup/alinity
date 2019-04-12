SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ReasonGroup] (
		[ReasonGroupSID]         [int] IDENTITY(1000001, 1) NOT NULL,
		[ReasonGroupSCD]         [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ReasonGroupLabel]       [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IsLockedGroup]          [bit] NOT NULL,
		[UserDefinedColumns]     [xml] NULL,
		[ReasonGroupXID]         [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]              [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]              [bit] NOT NULL,
		[CreateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]             [datetimeoffset](7) NOT NULL,
		[UpdateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]             [datetimeoffset](7) NOT NULL,
		[RowGUID]                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]               [timestamp] NOT NULL,
		CONSTRAINT [uk_ReasonGroup_ReasonGroupLabel]
		UNIQUE
		NONCLUSTERED
		([ReasonGroupLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_ReasonGroup_ReasonGroupSCD]
		UNIQUE
		NONCLUSTERED
		([ReasonGroupSCD])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_ReasonGroup_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_ReasonGroup]
		PRIMARY KEY
		CLUSTERED
		([ReasonGroupSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Reason Group table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'ReasonGroup', 'CONSTRAINT', N'pk_ReasonGroup'
GO
ALTER TABLE [dbo].[ReasonGroup]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_ReasonGroup]
	CHECK
	([dbo].[fReasonGroup#Check]([ReasonGroupSID],[ReasonGroupSCD],[ReasonGroupLabel],[IsLockedGroup],[ReasonGroupXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[ReasonGroup]
CHECK CONSTRAINT [ck_ReasonGroup]
GO
ALTER TABLE [dbo].[ReasonGroup]
	ADD
	CONSTRAINT [df_ReasonGroup_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[ReasonGroup]
	ADD
	CONSTRAINT [df_ReasonGroup_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[ReasonGroup]
	ADD
	CONSTRAINT [df_ReasonGroup_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[ReasonGroup]
	ADD
	CONSTRAINT [df_ReasonGroup_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[ReasonGroup]
	ADD
	CONSTRAINT [df_ReasonGroup_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[ReasonGroup]
	ADD
	CONSTRAINT [df_ReasonGroup_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[ReasonGroup]
	ADD
	CONSTRAINT [df_ReasonGroup_IsLockedGroup]
	DEFAULT (CONVERT([bit],(0))) FOR [IsLockedGroup]
GO
EXEC sp_addextendedproperty N'MS_Description', N'This is a master table used across the application to record lists of reason values.  Reasons for cancelling records, rejecting forms, blocking auto approval of renewals, and various other situations where reasons are required, are constrained to specific values through reason lists. This table defines each category or reason list.  The actual reason values are recorded in the dbo.Reason table.  Normally the items on each reason list can be set uniquely for each configuration but in a few cases, the coding of the specific reasons is depended on by the product to take certain actions.  In those situation the "Is-Locked-Group" column is set ON which prevents the codes in the child reason records to be edited.  The label (descriptive) value that appears in drop-down lists to users can still be edited.', 'SCHEMA', N'dbo', 'TABLE', N'ReasonGroup', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the reason group assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'ReasonGroup', 'COLUMN', N'ReasonGroupSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the reason group | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'dbo', 'TABLE', N'ReasonGroup', 'COLUMN', N'ReasonGroupSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the reason group to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'ReasonGroup', 'COLUMN', N'ReasonGroupLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if the group code reasons is reserved by the system and cannot have its members or codes altered.  The application requires that some groups exist with known code values.  Adding and deleting reasons from these groups, or changing their codes - is blocked by the application.  End users can still change the description of the reasons including customizing them for language.', 'SCHEMA', N'dbo', 'TABLE', N'ReasonGroup', 'COLUMN', N'IsLockedGroup'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the reason group | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'ReasonGroup', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'ReasonGroup', 'COLUMN', N'ReasonGroupXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'ReasonGroup', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'ReasonGroup', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the reason group | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'ReasonGroup', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this reason group record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'ReasonGroup', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the reason group | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'ReasonGroup', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the reason group record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'ReasonGroup', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the reason group record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'ReasonGroup', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'ReasonGroup', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Reason Group Label column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'ReasonGroup', 'CONSTRAINT', N'uk_ReasonGroup_ReasonGroupLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Reason Group SCD column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'ReasonGroup', 'CONSTRAINT', N'uk_ReasonGroup_ReasonGroupSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'ReasonGroup', 'CONSTRAINT', N'uk_ReasonGroup_RowGUID'
GO
ALTER TABLE [dbo].[ReasonGroup] SET (LOCK_ESCALATION = TABLE)
GO
