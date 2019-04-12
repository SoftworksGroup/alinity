SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RegistrantEmploymentPracticeArea] (
		[RegistrantEmploymentPracticeAreaSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[RegistrantEmploymentSID]                 [int] NOT NULL,
		[PracticeAreaSID]                         [int] NOT NULL,
		[IsPrimary]                               [bit] NOT NULL,
		[UserDefinedColumns]                      [xml] NULL,
		[RegistrantEmploymentPracticeAreaXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                               [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                               [bit] NOT NULL,
		[CreateUser]                              [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                              [datetimeoffset](7) NOT NULL,
		[UpdateUser]                              [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                              [datetimeoffset](7) NOT NULL,
		[RowGUID]                                 [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                                [timestamp] NOT NULL,
		CONSTRAINT [uk_RegistrantEmploymentPracticeArea_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_RegistrantEmploymentPracticeArea]
		PRIMARY KEY
		CLUSTERED
		([RegistrantEmploymentPracticeAreaSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Registrant Employment Practice Area table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmploymentPracticeArea', 'CONSTRAINT', N'pk_RegistrantEmploymentPracticeArea'
GO
ALTER TABLE [dbo].[RegistrantEmploymentPracticeArea]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_RegistrantEmploymentPracticeArea]
	CHECK
	([dbo].[fRegistrantEmploymentPracticeArea#Check]([RegistrantEmploymentPracticeAreaSID],[RegistrantEmploymentSID],[PracticeAreaSID],[IsPrimary],[RegistrantEmploymentPracticeAreaXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[RegistrantEmploymentPracticeArea]
CHECK CONSTRAINT [ck_RegistrantEmploymentPracticeArea]
GO
ALTER TABLE [dbo].[RegistrantEmploymentPracticeArea]
	ADD
	CONSTRAINT [df_RegistrantEmploymentPracticeArea_IsPrimary]
	DEFAULT (CONVERT([bit],(0))) FOR [IsPrimary]
GO
ALTER TABLE [dbo].[RegistrantEmploymentPracticeArea]
	ADD
	CONSTRAINT [df_RegistrantEmploymentPracticeArea_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[RegistrantEmploymentPracticeArea]
	ADD
	CONSTRAINT [df_RegistrantEmploymentPracticeArea_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[RegistrantEmploymentPracticeArea]
	ADD
	CONSTRAINT [df_RegistrantEmploymentPracticeArea_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[RegistrantEmploymentPracticeArea]
	ADD
	CONSTRAINT [df_RegistrantEmploymentPracticeArea_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[RegistrantEmploymentPracticeArea]
	ADD
	CONSTRAINT [df_RegistrantEmploymentPracticeArea_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[RegistrantEmploymentPracticeArea]
	ADD
	CONSTRAINT [df_RegistrantEmploymentPracticeArea_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[RegistrantEmploymentPracticeArea]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantEmploymentPracticeArea_PracticeArea_PracticeAreaSID]
	FOREIGN KEY ([PracticeAreaSID]) REFERENCES [dbo].[PracticeArea] ([PracticeAreaSID])
ALTER TABLE [dbo].[RegistrantEmploymentPracticeArea]
	CHECK CONSTRAINT [fk_RegistrantEmploymentPracticeArea_PracticeArea_PracticeAreaSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the practice area system ID column in the Registrant Employment Practice Area table match a practice area system ID in the Practice Area table. It also ensures that records in the Practice Area table cannot be deleted if matching child records exist in Registrant Employment Practice Area. Finally, the constraint blocks changes to the value of the practice area system ID column in the Practice Area if matching child records exist in Registrant Employment Practice Area.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmploymentPracticeArea', 'CONSTRAINT', N'fk_RegistrantEmploymentPracticeArea_PracticeArea_PracticeAreaSID'
GO
ALTER TABLE [dbo].[RegistrantEmploymentPracticeArea]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantEmploymentPracticeArea_RegistrantEmployment_RegistrantEmploymentSID]
	FOREIGN KEY ([RegistrantEmploymentSID]) REFERENCES [dbo].[RegistrantEmployment] ([RegistrantEmploymentSID])
ALTER TABLE [dbo].[RegistrantEmploymentPracticeArea]
	CHECK CONSTRAINT [fk_RegistrantEmploymentPracticeArea_RegistrantEmployment_RegistrantEmploymentSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the registrant employment system ID column in the Registrant Employment Practice Area table match a registrant employment system ID in the Registrant Employment table. It also ensures that records in the Registrant Employment table cannot be deleted if matching child records exist in Registrant Employment Practice Area. Finally, the constraint blocks changes to the value of the registrant employment system ID column in the Registrant Employment if matching child records exist in Registrant Employment Practice Area.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmploymentPracticeArea', 'CONSTRAINT', N'fk_RegistrantEmploymentPracticeArea_RegistrantEmployment_RegistrantEmploymentSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantEmploymentPracticeArea_PracticeAreaSID_RegistrantEmploymentPracticeAreaSID]
	ON [dbo].[RegistrantEmploymentPracticeArea] ([PracticeAreaSID], [RegistrantEmploymentPracticeAreaSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Practice Area SID foreign key column and avoids row contention on (parent) Practice Area updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmploymentPracticeArea', 'INDEX', N'ix_RegistrantEmploymentPracticeArea_PracticeAreaSID_RegistrantEmploymentPracticeAreaSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantEmploymentPracticeArea_RegistrantEmploymentSID_RegistrantEmploymentPracticeAreaSID]
	ON [dbo].[RegistrantEmploymentPracticeArea] ([RegistrantEmploymentSID], [RegistrantEmploymentPracticeAreaSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Registrant Employment SID foreign key column and avoids row contention on (parent) Registrant Employment updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmploymentPracticeArea', 'INDEX', N'ix_RegistrantEmploymentPracticeArea_RegistrantEmploymentSID_RegistrantEmploymentPracticeAreaSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_RegistrantEmploymentPracticeArea_RegistrantEmploymentSID_IsPrimary]
	ON [dbo].[RegistrantEmploymentPracticeArea] ([RegistrantEmploymentSID], [IsPrimary])
	WHERE (([IsPrimary]=CONVERT([bit],(1),(0))))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the combination of values provided for the "Registrant Employment SID + Is Primary" columns is not duplicated where the condition: "([IsPrimary]=CONVERT([bit],(1),(0)))" is met', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmploymentPracticeArea', 'INDEX', N'ux_RegistrantEmploymentPracticeArea_RegistrantEmploymentSID_IsPrimary'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table records the areas of primary focus or responsibility the member has in their work setting.  A new Registrant-Employment record is recorded at each renewal and the area of practice is recorded here. More than one area of practice may exist for a work setting and all are reported in this table.  For some external reporting requirements only 1 area-of-responsibility can be reported and this is identified using the Is-Primary (=1) column.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmploymentPracticeArea', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant employment practice area assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmploymentPracticeArea', 'COLUMN', N'RegistrantEmploymentPracticeAreaSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant employment assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmploymentPracticeArea', 'COLUMN', N'RegistrantEmploymentSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the practice area assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmploymentPracticeArea', 'COLUMN', N'PracticeAreaSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the registrant employment practice area | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmploymentPracticeArea', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmploymentPracticeArea', 'COLUMN', N'RegistrantEmploymentPracticeAreaXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmploymentPracticeArea', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmploymentPracticeArea', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the registrant employment practice area | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmploymentPracticeArea', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this registrant employment practice area record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmploymentPracticeArea', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the registrant employment practice area | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmploymentPracticeArea', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the registrant employment practice area record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmploymentPracticeArea', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registrant employment practice area record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmploymentPracticeArea', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmploymentPracticeArea', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantEmploymentPracticeArea', 'CONSTRAINT', N'uk_RegistrantEmploymentPracticeArea_RowGUID'
GO
ALTER TABLE [dbo].[RegistrantEmploymentPracticeArea] SET (LOCK_ESCALATION = TABLE)
GO
