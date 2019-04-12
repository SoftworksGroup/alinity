SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PracticeRegisterRestriction] (
		[PracticeRegisterRestrictionSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[PracticeRegisterSID]                [int] NOT NULL,
		[PracticeRestrictionSID]             [int] NOT NULL,
		[PracticeRegisterSectionSID]         [int] NULL,
		[EffectiveTime]                      [datetime] NOT NULL,
		[ExpiryTime]                         [datetime] NULL,
		[UserDefinedColumns]                 [xml] NULL,
		[PracticeRegisterRestrictionXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                          [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                          [bit] NOT NULL,
		[CreateUser]                         [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                         [datetimeoffset](7) NOT NULL,
		[UpdateUser]                         [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                         [datetimeoffset](7) NOT NULL,
		[RowGUID]                            [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                           [timestamp] NOT NULL,
		CONSTRAINT [uk_PracticeRegisterRestriction_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_PracticeRegisterRestriction]
		PRIMARY KEY
		CLUSTERED
		([PracticeRegisterRestrictionSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Practice Register Restriction table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterRestriction', 'CONSTRAINT', N'pk_PracticeRegisterRestriction'
GO
ALTER TABLE [dbo].[PracticeRegisterRestriction]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_PracticeRegisterRestriction]
	CHECK
	([dbo].[fPracticeRegisterRestriction#Check]([PracticeRegisterRestrictionSID],[PracticeRegisterSID],[PracticeRestrictionSID],[PracticeRegisterSectionSID],[EffectiveTime],[ExpiryTime],[PracticeRegisterRestrictionXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[PracticeRegisterRestriction]
CHECK CONSTRAINT [ck_PracticeRegisterRestriction]
GO
ALTER TABLE [dbo].[PracticeRegisterRestriction]
	ADD
	CONSTRAINT [df_PracticeRegisterRestriction_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[PracticeRegisterRestriction]
	ADD
	CONSTRAINT [df_PracticeRegisterRestriction_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[PracticeRegisterRestriction]
	ADD
	CONSTRAINT [df_PracticeRegisterRestriction_EffectiveTime]
	DEFAULT (CONVERT([datetime],[sf].[fToday]())) FOR [EffectiveTime]
GO
ALTER TABLE [dbo].[PracticeRegisterRestriction]
	ADD
	CONSTRAINT [df_PracticeRegisterRestriction_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[PracticeRegisterRestriction]
	ADD
	CONSTRAINT [df_PracticeRegisterRestriction_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[PracticeRegisterRestriction]
	ADD
	CONSTRAINT [df_PracticeRegisterRestriction_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[PracticeRegisterRestriction]
	ADD
	CONSTRAINT [df_PracticeRegisterRestriction_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[PracticeRegisterRestriction]
	WITH CHECK
	ADD CONSTRAINT [fk_PracticeRegisterRestriction_PracticeRegister_PracticeRegisterSID]
	FOREIGN KEY ([PracticeRegisterSID]) REFERENCES [dbo].[PracticeRegister] ([PracticeRegisterSID])
ALTER TABLE [dbo].[PracticeRegisterRestriction]
	CHECK CONSTRAINT [fk_PracticeRegisterRestriction_PracticeRegister_PracticeRegisterSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the practice register system ID column in the Practice Register Restriction table match a practice register system ID in the Practice Register table. It also ensures that records in the Practice Register table cannot be deleted if matching child records exist in Practice Register Restriction. Finally, the constraint blocks changes to the value of the practice register system ID column in the Practice Register if matching child records exist in Practice Register Restriction.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterRestriction', 'CONSTRAINT', N'fk_PracticeRegisterRestriction_PracticeRegister_PracticeRegisterSID'
GO
ALTER TABLE [dbo].[PracticeRegisterRestriction]
	WITH CHECK
	ADD CONSTRAINT [fk_PracticeRegisterRestriction_PracticeRegisterSection_PracticeRegisterSectionSID]
	FOREIGN KEY ([PracticeRegisterSectionSID]) REFERENCES [dbo].[PracticeRegisterSection] ([PracticeRegisterSectionSID])
ALTER TABLE [dbo].[PracticeRegisterRestriction]
	CHECK CONSTRAINT [fk_PracticeRegisterRestriction_PracticeRegisterSection_PracticeRegisterSectionSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the practice register section system ID column in the Practice Register Restriction table match a practice register section system ID in the Practice Register Section table. It also ensures that records in the Practice Register Section table cannot be deleted if matching child records exist in Practice Register Restriction. Finally, the constraint blocks changes to the value of the practice register section system ID column in the Practice Register Section if matching child records exist in Practice Register Restriction.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterRestriction', 'CONSTRAINT', N'fk_PracticeRegisterRestriction_PracticeRegisterSection_PracticeRegisterSectionSID'
GO
ALTER TABLE [dbo].[PracticeRegisterRestriction]
	WITH CHECK
	ADD CONSTRAINT [fk_PracticeRegisterRestriction_PracticeRestriction_PracticeRestrictionSID]
	FOREIGN KEY ([PracticeRestrictionSID]) REFERENCES [dbo].[PracticeRestriction] ([PracticeRestrictionSID])
ALTER TABLE [dbo].[PracticeRegisterRestriction]
	CHECK CONSTRAINT [fk_PracticeRegisterRestriction_PracticeRestriction_PracticeRestrictionSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the practice restriction system ID column in the Practice Register Restriction table match a practice restriction system ID in the Practice Restriction table. It also ensures that records in the Practice Restriction table cannot be deleted if matching child records exist in Practice Register Restriction. Finally, the constraint blocks changes to the value of the practice restriction system ID column in the Practice Restriction if matching child records exist in Practice Register Restriction.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterRestriction', 'CONSTRAINT', N'fk_PracticeRegisterRestriction_PracticeRestriction_PracticeRestrictionSID'
GO
CREATE NONCLUSTERED INDEX [ix_PracticeRegisterRestriction_PracticeRegisterSectionSID_PracticeRegisterRestrictionSID]
	ON [dbo].[PracticeRegisterRestriction] ([PracticeRegisterSectionSID], [PracticeRegisterRestrictionSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Practice Register Section SID foreign key column and avoids row contention on (parent) Practice Register Section updates', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterRestriction', 'INDEX', N'ix_PracticeRegisterRestriction_PracticeRegisterSectionSID_PracticeRegisterRestrictionSID'
GO
CREATE NONCLUSTERED INDEX [ix_PracticeRegisterRestriction_PracticeRegisterSID_PracticeRegisterRestrictionSID]
	ON [dbo].[PracticeRegisterRestriction] ([PracticeRegisterSID], [PracticeRegisterRestrictionSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Practice Register SID foreign key column and avoids row contention on (parent) Practice Register updates', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterRestriction', 'INDEX', N'ix_PracticeRegisterRestriction_PracticeRegisterSID_PracticeRegisterRestrictionSID'
GO
CREATE NONCLUSTERED INDEX [ix_PracticeRegisterRestriction_PracticeRestrictionSID_PracticeRegisterRestrictionSID]
	ON [dbo].[PracticeRegisterRestriction] ([PracticeRestrictionSID], [PracticeRegisterRestrictionSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Practice Restriction SID foreign key column and avoids row contention on (parent) Practice Restriction updates', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterRestriction', 'INDEX', N'ix_PracticeRegisterRestriction_PracticeRestrictionSID_PracticeRegisterRestrictionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table is used to automatically create conditions-on-practice when a change in registration occurs.  One or more conditions-on-practice can be associated with the register.  When the member is assigned to that register, or optionally only a specific section in that register, the condition-on-practice is assigned to their registration.  The table structure includes effective and expiry dates so that conditions to automatically apply can be setup to take effect or expire in the future (when the new policy applies).  Once the conditions are assigned to a registration, Administrators can manually override them by expiring them or adding additional conditions as may be appropriate for that members situation.  Note that if the practice-section is specified on the record, then only registrations changing to that section will receive the condition.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterRestriction', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the practice register restriction assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterRestriction', 'COLUMN', N'PracticeRegisterRestrictionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The practice register this restriction is defined for', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterRestriction', 'COLUMN', N'PracticeRegisterSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the practice restriction assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterRestriction', 'COLUMN', N'PracticeRestrictionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the practice register section assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterRestriction', 'COLUMN', N'PracticeRegisterSectionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the condition-on-practice becomes available for applying on registration changes to this register/section.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterRestriction', 'COLUMN', N'EffectiveTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the condition no longer automatically applies to changes to this register/section.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterRestriction', 'COLUMN', N'ExpiryTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the practice register restriction | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterRestriction', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterRestriction', 'COLUMN', N'PracticeRegisterRestrictionXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterRestriction', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterRestriction', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the practice register restriction | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterRestriction', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this practice register restriction record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterRestriction', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the practice register restriction | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterRestriction', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the practice register restriction record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterRestriction', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the practice register restriction record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterRestriction', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterRestriction', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterRestriction', 'CONSTRAINT', N'uk_PracticeRegisterRestriction_RowGUID'
GO
ALTER TABLE [dbo].[PracticeRegisterRestriction] SET (LOCK_ESCALATION = TABLE)
GO
