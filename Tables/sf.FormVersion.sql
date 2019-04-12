SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[FormVersion] (
		[FormVersionSID]         [int] IDENTITY(1000001, 1) NOT NULL,
		[FormSID]                [int] NOT NULL,
		[VersionNo]              [smallint] NOT NULL,
		[RevisionNo]             [smallint] NOT NULL,
		[FormDefinition]         [xml] NOT NULL,
		[IsSaveDisplayed]        [bit] NOT NULL,
		[ApprovedTime]           [datetimeoffset](7) NULL,
		[ChangeNotes]            [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[UserDefinedColumns]     [xml] NULL,
		[FormVersionXID]         [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]              [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]              [bit] NOT NULL,
		[CreateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]             [datetimeoffset](7) NOT NULL,
		[UpdateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]             [datetimeoffset](7) NOT NULL,
		[RowGUID]                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]               [timestamp] NOT NULL,
		CONSTRAINT [uk_FormVersion_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_FormVersion_FormSID_RevisionNo]
		UNIQUE
		NONCLUSTERED
		([FormSID], [RevisionNo])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_FormVersion]
		PRIMARY KEY
		CLUSTERED
		([FormVersionSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Form Version table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'FormVersion', 'CONSTRAINT', N'pk_FormVersion'
GO
ALTER TABLE [sf].[FormVersion]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_FormVersion]
	CHECK
	([sf].[fFormVersion#Check]([FormVersionSID],[FormSID],[VersionNo],[RevisionNo],[IsSaveDisplayed],[ApprovedTime],[FormVersionXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[FormVersion]
CHECK CONSTRAINT [ck_FormVersion]
GO
ALTER TABLE [sf].[FormVersion]
	ADD
	CONSTRAINT [df_FormVersion_VersionNo]
	DEFAULT ((0)) FOR [VersionNo]
GO
ALTER TABLE [sf].[FormVersion]
	ADD
	CONSTRAINT [df_FormVersion_RevisionNo]
	DEFAULT ((1001)) FOR [RevisionNo]
GO
ALTER TABLE [sf].[FormVersion]
	ADD
	CONSTRAINT [df_FormVersion_IsSaveDisplayed]
	DEFAULT (CONVERT([bit],(1))) FOR [IsSaveDisplayed]
GO
ALTER TABLE [sf].[FormVersion]
	ADD
	CONSTRAINT [df_FormVersion_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[FormVersion]
	ADD
	CONSTRAINT [df_FormVersion_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[FormVersion]
	ADD
	CONSTRAINT [df_FormVersion_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[FormVersion]
	ADD
	CONSTRAINT [df_FormVersion_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[FormVersion]
	ADD
	CONSTRAINT [df_FormVersion_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[FormVersion]
	ADD
	CONSTRAINT [df_FormVersion_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[FormVersion]
	WITH CHECK
	ADD CONSTRAINT [fk_FormVersion_Form_FormSID]
	FOREIGN KEY ([FormSID]) REFERENCES [sf].[Form] ([FormSID])
	ON DELETE CASCADE
ALTER TABLE [sf].[FormVersion]
	CHECK CONSTRAINT [fk_FormVersion_Form_FormSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the form system ID column in the Form Version table match a form system ID in the Form table. It also ensures that when a record in the Form table is deleted, matching child records in the Form Version table are deleted as well. Finally, the constraint blocks changes to the value of the form system ID column in the Form if matching child records exist in Form Version.', 'SCHEMA', N'sf', 'TABLE', N'FormVersion', 'CONSTRAINT', N'fk_FormVersion_Form_FormSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_FormVersion_FormSID_VersionNo]
	ON [sf].[FormVersion] ([FormSID], [VersionNo])
	WHERE (([VersionNo]<>(0)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the combination of values provided for the "Form SID + Version No" columns is not duplicated where the condition: "([VersionNo]<>(0))" is met', 'SCHEMA', N'sf', 'TABLE', N'FormVersion', 'INDEX', N'ux_FormVersion_FormSID_VersionNo'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_FormVersion_LegacyKey]
	ON [sf].[FormVersion] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'FormVersion', 'INDEX', N'ux_FormVersion_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table keeps a record of each version of a form that is approved.  This table is part of the dynamic form framework used by Softworks applications. The content (fields), layout, styling and validation of a form are specified in the “Form Definition” column in this table.  When a new version of the form is created, a new version number is assigned and that version becomes available for use whenever a new instance of the form is created.  The form definition is stored as XML and may be created either through the Form Designer provided by the application, or by trained configurators using XML editors.  The XML document is processed by the Softworks Forms Rendering engine to create the form on screen for completion and/or review.  Some advanced features of the Forms Rendering Engine may only be available outside the Forms Designer.  The responses for a dynamic form – the content the user enters – is stored in tables in the DBO schema created specifically for the form type identified.  The table the response value binds to is defined within the XML.  Each form may update multiple tables.', 'SCHEMA', N'sf', 'TABLE', N'FormVersion', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the form version assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'FormVersion', 'COLUMN', N'FormVersionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The form this version is defined for', 'SCHEMA', N'sf', 'TABLE', N'FormVersion', 'COLUMN', N'FormSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The version number of the form - e.g. 1, 2, 3, 999.  When a new version of the form is approved the version number moves up to the next whole number.  | Revision numbers are always 0 for approved versions of the form.', 'SCHEMA', N'sf', 'TABLE', N'FormVersion', 'COLUMN', N'VersionNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A number assigned as changes are made and saved between approved Versions of the form.  | Revision enable users to back to a previous state of the form and edit from that point.  When a form version is Approved, the form is saved, the version number is updated to the next whole number, and the revision number is set to 0. ', 'SCHEMA', N'sf', 'TABLE', N'FormVersion', 'COLUMN', N'RevisionNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document specifying the design of the form including: content (fields), layout, style (fonts, colors, etc.) and validations.  |  The XML document may be created by Forms Designer module in the application or by manual editing of XML. ', 'SCHEMA', N'sf', 'TABLE', N'FormVersion', 'COLUMN', N'FormDefinition'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether the Save/Save-For-Later button is displayed (otherwise only Submit is allowed) | Note that other business rules may also impact whether the Save button option is displayed', 'SCHEMA', N'sf', 'TABLE', N'FormVersion', 'COLUMN', N'IsSaveDisplayed'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time this version of the form was approved for use in production.  | This value is blank for revisions of the form saved between production versions.', 'SCHEMA', N'sf', 'TABLE', N'FormVersion', 'COLUMN', N'ApprovedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional description of changes made in this revision of the form (must be entered by the Form author).', 'SCHEMA', N'sf', 'TABLE', N'FormVersion', 'COLUMN', N'ChangeNotes'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the form version | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'FormVersion', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'FormVersion', 'COLUMN', N'FormVersionXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'FormVersion', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'FormVersion', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the form version | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'FormVersion', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this form version record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'FormVersion', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the form version | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'FormVersion', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the form version record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'FormVersion', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the form version record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'FormVersion', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'FormVersion', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'FormVersion', 'CONSTRAINT', N'uk_FormVersion_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the combination of values provided for the "Form SID + Revision No" columns is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'FormVersion', 'CONSTRAINT', N'uk_FormVersion_FormSID_RevisionNo'
GO
SET ANSI_PADDING ON
GO
CREATE PRIMARY XML INDEX [xp_FormVersion_FormDefinition]
	ON [sf].[FormVersion] ([FormDefinition])
GO
EXEC sp_addextendedproperty N'MS_Description', N'A primary XML index to support fast parsing of the Form Definition (XML) column', 'SCHEMA', N'sf', 'TABLE', N'FormVersion', 'INDEX', N'xp_FormVersion_FormDefinition'
GO
ALTER TABLE [sf].[FormVersion] SET (LOCK_ESCALATION = TABLE)
GO
