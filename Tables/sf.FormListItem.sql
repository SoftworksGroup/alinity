SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[FormListItem] (
		[FormListItemSID]          [int] IDENTITY(1000001, 1) NOT NULL,
		[FormListSID]              [int] NOT NULL,
		[FormListItemCode]         [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FormListItemLabel]        [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FormListItemSequence]     [smallint] NOT NULL,
		[ToolTip]                  [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsActive]                 [bit] NOT NULL,
		[UserDefinedColumns]       [xml] NULL,
		[FormListItemXID]          [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                [bit] NOT NULL,
		[CreateUser]               [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]               [datetimeoffset](7) NOT NULL,
		[UpdateUser]               [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]               [datetimeoffset](7) NOT NULL,
		[RowGUID]                  [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                 [timestamp] NOT NULL,
		CONSTRAINT [uk_FormListItem_FormListSID_FormListItemCode]
		UNIQUE
		NONCLUSTERED
		([FormListSID], [FormListItemCode])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_FormListItem_FormListSID_FormListItemLabel]
		UNIQUE
		NONCLUSTERED
		([FormListSID], [FormListItemLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_FormListItem_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_FormListItem]
		PRIMARY KEY
		CLUSTERED
		([FormListItemSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Form List Item table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'FormListItem', 'CONSTRAINT', N'pk_FormListItem'
GO
ALTER TABLE [sf].[FormListItem]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_FormListItem]
	CHECK
	([sf].[fFormListItem#Check]([FormListItemSID],[FormListSID],[FormListItemCode],[FormListItemLabel],[FormListItemSequence],[ToolTip],[IsActive],[FormListItemXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[FormListItem]
CHECK CONSTRAINT [ck_FormListItem]
GO
ALTER TABLE [sf].[FormListItem]
	ADD
	CONSTRAINT [df_FormListItem_FormListItemSequence]
	DEFAULT ((0)) FOR [FormListItemSequence]
GO
ALTER TABLE [sf].[FormListItem]
	ADD
	CONSTRAINT [df_FormListItem_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [sf].[FormListItem]
	ADD
	CONSTRAINT [df_FormListItem_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[FormListItem]
	ADD
	CONSTRAINT [df_FormListItem_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[FormListItem]
	ADD
	CONSTRAINT [df_FormListItem_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[FormListItem]
	ADD
	CONSTRAINT [df_FormListItem_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[FormListItem]
	ADD
	CONSTRAINT [df_FormListItem_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[FormListItem]
	ADD
	CONSTRAINT [df_FormListItem_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[FormListItem]
	WITH CHECK
	ADD CONSTRAINT [fk_FormListItem_FormList_FormListSID]
	FOREIGN KEY ([FormListSID]) REFERENCES [sf].[FormList] ([FormListSID])
ALTER TABLE [sf].[FormListItem]
	CHECK CONSTRAINT [fk_FormListItem_FormList_FormListSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the form list system ID column in the Form List Item table match a form list system ID in the Form List table. It also ensures that records in the Form List table cannot be deleted if matching child records exist in Form List Item. Finally, the constraint blocks changes to the value of the form list system ID column in the Form List if matching child records exist in Form List Item.', 'SCHEMA', N'sf', 'TABLE', N'FormListItem', 'CONSTRAINT', N'fk_FormListItem_FormList_FormListSID'
GO
CREATE NONCLUSTERED INDEX [ix_FormListItem_FormListSID_FormListItemSID]
	ON [sf].[FormListItem] ([FormListSID], [FormListItemSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Form List SID foreign key column and avoids row contention on (parent) Form List updates', 'SCHEMA', N'sf', 'TABLE', N'FormListItem', 'INDEX', N'ix_FormListItem_FormListSID_FormListItemSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the form list item assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'FormListItem', 'COLUMN', N'FormListItemSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The form list this item is defined for', 'SCHEMA', N'sf', 'TABLE', N'FormListItem', 'COLUMN', N'FormListSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Code used to identify the list-item when referenced within a form.  DO NOT change this value without first ensuring any forms relying on it have been updated. This value must be unique within the form-list.', 'SCHEMA', N'sf', 'TABLE', N'FormListItem', 'COLUMN', N'FormListItemCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the form list item to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'TABLE', N'FormListItem', 'COLUMN', N'FormListItemLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this form list item record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'sf', 'TABLE', N'FormListItem', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the form list item | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'FormListItem', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'FormListItem', 'COLUMN', N'FormListItemXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'FormListItem', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'FormListItem', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the form list item | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'FormListItem', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this form list item record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'FormListItem', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the form list item | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'FormListItem', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the form list item record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'FormListItem', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the form list item record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'FormListItem', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'FormListItem', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the combination of values provided for the "Form List SID + Form List Item Code" columns is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'FormListItem', 'CONSTRAINT', N'uk_FormListItem_FormListSID_FormListItemCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the combination of values provided for the "Form List SID + Form List Item Label" columns is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'FormListItem', 'CONSTRAINT', N'uk_FormListItem_FormListSID_FormListItemLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'FormListItem', 'CONSTRAINT', N'uk_FormListItem_RowGUID'
GO
ALTER TABLE [sf].[FormListItem] SET (LOCK_ESCALATION = TABLE)
GO
