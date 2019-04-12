SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Recommendation] (
		[RecommendationSID]          [int] IDENTITY(1000001, 1) NOT NULL,
		[RecommendationGroupSID]     [int] NOT NULL,
		[ButtonLabel]                [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[RecommendationSequence]     [smallint] NOT NULL,
		[ToolTip]                    [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsActive]                   [bit] NOT NULL,
		[UserDefinedColumns]         [xml] NULL,
		[RecommendationXID]          [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                  [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                  [bit] NOT NULL,
		[CreateUser]                 [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                 [datetimeoffset](7) NOT NULL,
		[UpdateUser]                 [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                 [datetimeoffset](7) NOT NULL,
		[RowGUID]                    [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                   [timestamp] NOT NULL,
		CONSTRAINT [uk_Recommendation_ButtonLabel_RecommendationGroupSID]
		UNIQUE
		NONCLUSTERED
		([ButtonLabel], [RecommendationGroupSID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_Recommendation_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_Recommendation]
		PRIMARY KEY
		CLUSTERED
		([RecommendationSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Recommendation table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'Recommendation', 'CONSTRAINT', N'pk_Recommendation'
GO
ALTER TABLE [dbo].[Recommendation]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_Recommendation]
	CHECK
	([dbo].[fRecommendation#Check]([RecommendationSID],[RecommendationGroupSID],[ButtonLabel],[RecommendationSequence],[ToolTip],[IsActive],[RecommendationXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[Recommendation]
CHECK CONSTRAINT [ck_Recommendation]
GO
ALTER TABLE [dbo].[Recommendation]
	ADD
	CONSTRAINT [df_Recommendation_RecommendationSequence]
	DEFAULT ((0)) FOR [RecommendationSequence]
GO
ALTER TABLE [dbo].[Recommendation]
	ADD
	CONSTRAINT [df_Recommendation_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[Recommendation]
	ADD
	CONSTRAINT [df_Recommendation_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[Recommendation]
	ADD
	CONSTRAINT [df_Recommendation_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[Recommendation]
	ADD
	CONSTRAINT [df_Recommendation_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[Recommendation]
	ADD
	CONSTRAINT [df_Recommendation_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[Recommendation]
	ADD
	CONSTRAINT [df_Recommendation_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[Recommendation]
	ADD
	CONSTRAINT [df_Recommendation_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[Recommendation]
	WITH CHECK
	ADD CONSTRAINT [fk_Recommendation_RecommendationGroup_RecommendationGroupSID]
	FOREIGN KEY ([RecommendationGroupSID]) REFERENCES [dbo].[RecommendationGroup] ([RecommendationGroupSID])
ALTER TABLE [dbo].[Recommendation]
	CHECK CONSTRAINT [fk_Recommendation_RecommendationGroup_RecommendationGroupSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the recommendation group system ID column in the Recommendation table match a recommendation group system ID in the Recommendation Group table. It also ensures that records in the Recommendation Group table cannot be deleted if matching child records exist in Recommendation. Finally, the constraint blocks changes to the value of the recommendation group system ID column in the Recommendation Group if matching child records exist in Recommendation.', 'SCHEMA', N'dbo', 'TABLE', N'Recommendation', 'CONSTRAINT', N'fk_Recommendation_RecommendationGroup_RecommendationGroupSID'
GO
CREATE NONCLUSTERED INDEX [ix_Recommendation_RecommendationGroupSID_RecommendationSID]
	ON [dbo].[Recommendation] ([RecommendationGroupSID], [RecommendationSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Recommendation Group SID foreign key column and avoids row contention on (parent) Recommendation Group updates', 'SCHEMA', N'dbo', 'TABLE', N'Recommendation', 'INDEX', N'ix_Recommendation_RecommendationGroupSID_RecommendationSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the recommendation assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'Recommendation', 'COLUMN', N'RecommendationSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The recommendation group assigned to this recommendation', 'SCHEMA', N'dbo', 'TABLE', N'Recommendation', 'COLUMN', N'RecommendationGroupSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the recommendation to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'Recommendation', 'COLUMN', N'ButtonLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this recommendation record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'TABLE', N'Recommendation', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the recommendation | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'Recommendation', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'Recommendation', 'COLUMN', N'RecommendationXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'Recommendation', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'Recommendation', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the recommendation | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'Recommendation', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this recommendation record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'Recommendation', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the recommendation | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'Recommendation', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the recommendation record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'Recommendation', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the recommendation record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'Recommendation', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'Recommendation', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the combination of values provided for the "Button Label + Recommendation Group SID" columns is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'Recommendation', 'CONSTRAINT', N'uk_Recommendation_ButtonLabel_RecommendationGroupSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'Recommendation', 'CONSTRAINT', N'uk_Recommendation_RowGUID'
GO
ALTER TABLE [dbo].[Recommendation] SET (LOCK_ESCALATION = TABLE)
GO
