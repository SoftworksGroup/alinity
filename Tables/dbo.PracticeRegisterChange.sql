SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PracticeRegisterChange] (
		[PracticeRegisterChangeSID]      [int] IDENTITY(1000001, 1) NOT NULL,
		[PracticeRegisterSID]            [int] NOT NULL,
		[PracticeRegisterSectionSID]     [int] NOT NULL,
		[IsActive]                       [bit] NOT NULL,
		[ToolTip]                        [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsEnabledForRegistrant]         [bit] NOT NULL,
		[UserDefinedColumns]             [xml] NULL,
		[PracticeRegisterChangeXID]      [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                      [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                      [bit] NOT NULL,
		[CreateUser]                     [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                     [datetimeoffset](7) NOT NULL,
		[UpdateUser]                     [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                     [datetimeoffset](7) NOT NULL,
		[RowGUID]                        [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                       [timestamp] NOT NULL,
		CONSTRAINT [uk_PracticeRegisterChange_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_PracticeRegisterChange]
		PRIMARY KEY
		CLUSTERED
		([PracticeRegisterChangeSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Practice Register Change table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterChange', 'CONSTRAINT', N'pk_PracticeRegisterChange'
GO
ALTER TABLE [dbo].[PracticeRegisterChange]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_PracticeRegisterChange]
	CHECK
	([dbo].[fPracticeRegisterChange#Check]([PracticeRegisterChangeSID],[PracticeRegisterSID],[PracticeRegisterSectionSID],[IsActive],[ToolTip],[IsEnabledForRegistrant],[PracticeRegisterChangeXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[PracticeRegisterChange]
CHECK CONSTRAINT [ck_PracticeRegisterChange]
GO
ALTER TABLE [dbo].[PracticeRegisterChange]
	ADD
	CONSTRAINT [df_PracticeRegisterChange_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[PracticeRegisterChange]
	ADD
	CONSTRAINT [df_PracticeRegisterChange_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[PracticeRegisterChange]
	ADD
	CONSTRAINT [df_PracticeRegisterChange_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[PracticeRegisterChange]
	ADD
	CONSTRAINT [df_PracticeRegisterChange_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[PracticeRegisterChange]
	ADD
	CONSTRAINT [df_PracticeRegisterChange_IsEnabledForRegistrant]
	DEFAULT (CONVERT([bit],(0))) FOR [IsEnabledForRegistrant]
GO
ALTER TABLE [dbo].[PracticeRegisterChange]
	ADD
	CONSTRAINT [df_PracticeRegisterChange_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[PracticeRegisterChange]
	ADD
	CONSTRAINT [df_PracticeRegisterChange_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[PracticeRegisterChange]
	ADD
	CONSTRAINT [df_PracticeRegisterChange_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[PracticeRegisterChange]
	WITH CHECK
	ADD CONSTRAINT [fk_PracticeRegisterChange_PracticeRegisterSection_PracticeRegisterSectionSID]
	FOREIGN KEY ([PracticeRegisterSectionSID]) REFERENCES [dbo].[PracticeRegisterSection] ([PracticeRegisterSectionSID])
ALTER TABLE [dbo].[PracticeRegisterChange]
	CHECK CONSTRAINT [fk_PracticeRegisterChange_PracticeRegisterSection_PracticeRegisterSectionSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the practice register section system ID column in the Practice Register Change table match a practice register section system ID in the Practice Register Section table. It also ensures that records in the Practice Register Section table cannot be deleted if matching child records exist in Practice Register Change. Finally, the constraint blocks changes to the value of the practice register section system ID column in the Practice Register Section if matching child records exist in Practice Register Change.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterChange', 'CONSTRAINT', N'fk_PracticeRegisterChange_PracticeRegisterSection_PracticeRegisterSectionSID'
GO
ALTER TABLE [dbo].[PracticeRegisterChange]
	WITH CHECK
	ADD CONSTRAINT [fk_PracticeRegisterChange_PracticeRegister_PracticeRegisterSID]
	FOREIGN KEY ([PracticeRegisterSID]) REFERENCES [dbo].[PracticeRegister] ([PracticeRegisterSID])
ALTER TABLE [dbo].[PracticeRegisterChange]
	CHECK CONSTRAINT [fk_PracticeRegisterChange_PracticeRegister_PracticeRegisterSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the practice register system ID column in the Practice Register Change table match a practice register system ID in the Practice Register table. It also ensures that records in the Practice Register table cannot be deleted if matching child records exist in Practice Register Change. Finally, the constraint blocks changes to the value of the practice register system ID column in the Practice Register if matching child records exist in Practice Register Change.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterChange', 'CONSTRAINT', N'fk_PracticeRegisterChange_PracticeRegister_PracticeRegisterSID'
GO
CREATE NONCLUSTERED INDEX [ix_PracticeRegisterChange_PracticeRegisterSectionSID_PracticeRegisterChangeSID]
	ON [dbo].[PracticeRegisterChange] ([PracticeRegisterSectionSID], [PracticeRegisterChangeSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Practice Register Section SID foreign key column and avoids row contention on (parent) Practice Register Section updates', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterChange', 'INDEX', N'ix_PracticeRegisterChange_PracticeRegisterSectionSID_PracticeRegisterChangeSID'
GO
CREATE NONCLUSTERED INDEX [ix_PracticeRegisterChange_PracticeRegisterSID_PracticeRegisterChangeSID]
	ON [dbo].[PracticeRegisterChange] ([PracticeRegisterSID], [PracticeRegisterChangeSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Practice Register SID foreign key column and avoids row contention on (parent) Practice Register updates', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterChange', 'INDEX', N'ix_PracticeRegisterChange_PracticeRegisterSID_PracticeRegisterChangeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table records the changes in registrations Administrators and Members can make.  The "from" and "to" registrations are defined through the PracticeRegisterSID (representing the "from") and the PracticeRegisterSectionSID (representing the "to").  Note that the "from" is also specified in terms of the register only and not a section.  The "to" must be defined as a specific section - even if the default. Status changes can be made by Members only at renewal time and for reinstatement.  If a change is allowed for a Member to make (client portal) then the “Is Enabled For Registrant” value must be set on. If this value is not on (set to 1), then only Administrators will be allowed to apply this type of register change. The values in this table control options presented to the registrant for making status changes during the renewal/reinstatement period so eligible renewal mappings must be entered.  Eligible changes can be setup or expired in advance using Effective and Expiry times.   Note that the system assumes renewing to the same register and section (e.g. Active to Active) is always allowed provided the "Is-Renewal-Enabled" value is set on the Practice Register record.  The system does not assume the registrant can automatically change status to different sections in the same register so a mapping for each eligible change must be recorded here. When a registrant starts their renewal, the system checks to see whether any entries exist in this table.  If so, then it gives the registrant the option to select a status change.  Otherwise, no status change options are presented and the registrant is only allowed to renew to their existing register and section.  
While this table restricts the register changes that can be made by Administrators and Members, “System Administrators” can still make status changes that are not specifically mapped in this table.  An override button is provided in the user interface to allow SA’s to apply any new register-section on a registration change. ', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterChange', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the practice register change assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterChange', 'COLUMN', N'PracticeRegisterChangeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the practice register assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterChange', 'COLUMN', N'PracticeRegisterSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the practice register section assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterChange', 'COLUMN', N'PracticeRegisterSectionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this practice register change record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterChange', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Documentation about the scenarios this practice-register-change applies to - available as help text on selection. ', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterChange', 'COLUMN', N'ToolTip'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the practice register change | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterChange', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterChange', 'COLUMN', N'PracticeRegisterChangeXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterChange', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterChange', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the practice register change | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterChange', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this practice register change record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterChange', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the practice register change | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterChange', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the practice register change record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterChange', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the practice register change record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterChange', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterChange', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterChange', 'CONSTRAINT', N'uk_PracticeRegisterChange_RowGUID'
GO
ALTER TABLE [dbo].[PracticeRegisterChange] SET (LOCK_ESCALATION = TABLE)
GO
