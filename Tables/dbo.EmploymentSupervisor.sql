SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EmploymentSupervisor] (
		[EmploymentSupervisorSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[RegistrantEmploymentSID]     [int] NOT NULL,
		[PersonSID]                   [int] NOT NULL,
		[ExpiryTime]                  [datetime] NULL,
		[UserDefinedColumns]          [xml] NULL,
		[EmploymentSupervisorXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                   [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                   [bit] NOT NULL,
		[CreateUser]                  [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                  [datetimeoffset](7) NOT NULL,
		[UpdateUser]                  [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                  [datetimeoffset](7) NOT NULL,
		[RowGUID]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                    [timestamp] NOT NULL,
		CONSTRAINT [uk_EmploymentSupervisor_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_EmploymentSupervisor]
		PRIMARY KEY
		CLUSTERED
		([EmploymentSupervisorSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Employment Supervisor table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentSupervisor', 'CONSTRAINT', N'pk_EmploymentSupervisor'
GO
ALTER TABLE [dbo].[EmploymentSupervisor]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_EmploymentSupervisor]
	CHECK
	([dbo].[fEmploymentSupervisor#Check]([EmploymentSupervisorSID],[RegistrantEmploymentSID],[PersonSID],[ExpiryTime],[EmploymentSupervisorXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[EmploymentSupervisor]
CHECK CONSTRAINT [ck_EmploymentSupervisor]
GO
ALTER TABLE [dbo].[EmploymentSupervisor]
	ADD
	CONSTRAINT [df_EmploymentSupervisor_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[EmploymentSupervisor]
	ADD
	CONSTRAINT [df_EmploymentSupervisor_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[EmploymentSupervisor]
	ADD
	CONSTRAINT [df_EmploymentSupervisor_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[EmploymentSupervisor]
	ADD
	CONSTRAINT [df_EmploymentSupervisor_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[EmploymentSupervisor]
	ADD
	CONSTRAINT [df_EmploymentSupervisor_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[EmploymentSupervisor]
	ADD
	CONSTRAINT [df_EmploymentSupervisor_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[EmploymentSupervisor]
	WITH CHECK
	ADD CONSTRAINT [fk_EmploymentSupervisor_SF_Person_PersonSID]
	FOREIGN KEY ([PersonSID]) REFERENCES [sf].[Person] ([PersonSID])
ALTER TABLE [dbo].[EmploymentSupervisor]
	CHECK CONSTRAINT [fk_EmploymentSupervisor_SF_Person_PersonSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the person system ID column in the Employment Supervisor table match a person system ID in the Person table. It also ensures that records in the Person table cannot be deleted if matching child records exist in Employment Supervisor. Finally, the constraint blocks changes to the value of the person system ID column in the Person if matching child records exist in Employment Supervisor.', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentSupervisor', 'CONSTRAINT', N'fk_EmploymentSupervisor_SF_Person_PersonSID'
GO
ALTER TABLE [dbo].[EmploymentSupervisor]
	WITH CHECK
	ADD CONSTRAINT [fk_EmploymentSupervisor_RegistrantEmployment_RegistrantEmploymentSID]
	FOREIGN KEY ([RegistrantEmploymentSID]) REFERENCES [dbo].[RegistrantEmployment] ([RegistrantEmploymentSID])
ALTER TABLE [dbo].[EmploymentSupervisor]
	CHECK CONSTRAINT [fk_EmploymentSupervisor_RegistrantEmployment_RegistrantEmploymentSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the registrant employment system ID column in the Employment Supervisor table match a registrant employment system ID in the Registrant Employment table. It also ensures that records in the Registrant Employment table cannot be deleted if matching child records exist in Employment Supervisor. Finally, the constraint blocks changes to the value of the registrant employment system ID column in the Registrant Employment if matching child records exist in Employment Supervisor.', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentSupervisor', 'CONSTRAINT', N'fk_EmploymentSupervisor_RegistrantEmployment_RegistrantEmploymentSID'
GO
CREATE NONCLUSTERED INDEX [ix_EmploymentSupervisor_PersonSID_EmploymentSupervisorSID]
	ON [dbo].[EmploymentSupervisor] ([PersonSID], [EmploymentSupervisorSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Person SID foreign key column and avoids row contention on (parent) Person updates', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentSupervisor', 'INDEX', N'ix_EmploymentSupervisor_PersonSID_EmploymentSupervisorSID'
GO
CREATE NONCLUSTERED INDEX [ix_EmploymentSupervisor_RegistrantEmploymentSID_EmploymentSupervisorSID]
	ON [dbo].[EmploymentSupervisor] ([RegistrantEmploymentSID], [EmploymentSupervisorSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Registrant Employment SID foreign key column and avoids row contention on (parent) Registrant Employment updates', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentSupervisor', 'INDEX', N'ix_EmploymentSupervisor_RegistrantEmploymentSID_EmploymentSupervisorSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table records supervisory relationships for employment.  It is possible to have more than one supervisor assigned for a registrant employment record.  An employment record defines the employer organization and, by default, Alinity considers a supervisory relationship invalid if either the supervisor or supervisee is no longer working at the organization.  It is possible to turn this enforcement off through configuration.  Supervisors must have a person record in the system. They may or may not be required to be active registrants based on business rules.  Supervisors may be further restricted to eligible Practice Registers.  During annual renewal and optionally on profile updates, the parties to the supervisory-relationship may update its status – for example terminating it if they no longer work at the employer or for other reasons.  This may trigger a follow-up for administrators if a supervisory relationship is a requirement for the registration of the supervisee.  If supervisory-relationships are supported by signed agreements between the parties, these documents can be uploaded into Person-Doc and assigned the context of this record for easy access from either party’s record.  ', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentSupervisor', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the employment supervisor assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentSupervisor', 'COLUMN', N'EmploymentSupervisorSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant employment assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentSupervisor', 'COLUMN', N'RegistrantEmploymentSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person record  this employment supervisor is based on', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentSupervisor', 'COLUMN', N'PersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date the Supervisory Agreement was terminated if it does not continue through the end of registration year', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentSupervisor', 'COLUMN', N'ExpiryTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the employment supervisor | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentSupervisor', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentSupervisor', 'COLUMN', N'EmploymentSupervisorXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentSupervisor', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentSupervisor', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the employment supervisor | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentSupervisor', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this employment supervisor record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentSupervisor', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the employment supervisor | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentSupervisor', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the employment supervisor record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentSupervisor', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the employment supervisor record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentSupervisor', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentSupervisor', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'EmploymentSupervisor', 'CONSTRAINT', N'uk_EmploymentSupervisor_RowGUID'
GO
ALTER TABLE [dbo].[EmploymentSupervisor] SET (LOCK_ESCALATION = TABLE)
GO
