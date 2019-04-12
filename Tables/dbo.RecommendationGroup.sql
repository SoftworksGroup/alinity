SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RecommendationGroup] (
		[RecommendationGroupSID]       [int] IDENTITY(1000001, 1) NOT NULL,
		[RecommendationGroupSCD]       [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[RecommendationGroupLabel]     [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UserDefinedColumns]           [xml] NULL,
		[RecommendationGroupXID]       [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                    [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                    [bit] NOT NULL,
		[CreateUser]                   [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                   [datetimeoffset](7) NOT NULL,
		[UpdateUser]                   [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                   [datetimeoffset](7) NOT NULL,
		[RowGUID]                      [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                     [timestamp] NOT NULL,
		CONSTRAINT [uk_RecommendationGroup_RecommendationGroupLabel]
		UNIQUE
		NONCLUSTERED
		([RecommendationGroupLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_RecommendationGroup_RecommendationGroupSCD]
		UNIQUE
		NONCLUSTERED
		([RecommendationGroupSCD])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_RecommendationGroup_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_RecommendationGroup]
		PRIMARY KEY
		CLUSTERED
		([RecommendationGroupSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Recommendation Group table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'RecommendationGroup', 'CONSTRAINT', N'pk_RecommendationGroup'
GO
ALTER TABLE [dbo].[RecommendationGroup]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_RecommendationGroup]
	CHECK
	([dbo].[fRecommendationGroup#Check]([RecommendationGroupSID],[RecommendationGroupSCD],[RecommendationGroupLabel],[RecommendationGroupXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[RecommendationGroup]
CHECK CONSTRAINT [ck_RecommendationGroup]
GO
ALTER TABLE [dbo].[RecommendationGroup]
	ADD
	CONSTRAINT [df_RecommendationGroup_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[RecommendationGroup]
	ADD
	CONSTRAINT [df_RecommendationGroup_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[RecommendationGroup]
	ADD
	CONSTRAINT [df_RecommendationGroup_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[RecommendationGroup]
	ADD
	CONSTRAINT [df_RecommendationGroup_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[RecommendationGroup]
	ADD
	CONSTRAINT [df_RecommendationGroup_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[RecommendationGroup]
	ADD
	CONSTRAINT [df_RecommendationGroup_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the recommendation group assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RecommendationGroup', 'COLUMN', N'RecommendationGroupSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the recommendation group | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'dbo', 'TABLE', N'RecommendationGroup', 'COLUMN', N'RecommendationGroupSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the recommendation group to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'RecommendationGroup', 'COLUMN', N'RecommendationGroupLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the recommendation group | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'RecommendationGroup', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'RecommendationGroup', 'COLUMN', N'RecommendationGroupXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'RecommendationGroup', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'RecommendationGroup', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the recommendation group | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RecommendationGroup', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this recommendation group record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RecommendationGroup', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the recommendation group | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RecommendationGroup', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the recommendation group record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RecommendationGroup', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the recommendation group record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'RecommendationGroup', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'RecommendationGroup', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Recommendation Group Label column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RecommendationGroup', 'CONSTRAINT', N'uk_RecommendationGroup_RecommendationGroupLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Recommendation Group SCD column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RecommendationGroup', 'CONSTRAINT', N'uk_RecommendationGroup_RecommendationGroupSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RecommendationGroup', 'CONSTRAINT', N'uk_RecommendationGroup_RowGUID'
GO
ALTER TABLE [dbo].[RecommendationGroup] SET (LOCK_ESCALATION = TABLE)
GO
