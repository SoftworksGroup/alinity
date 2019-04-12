SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Complaint] (
		[ComplaintSID]                    [int] IDENTITY(1000001, 1) NOT NULL,
		[ComplaintNo]                     [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[RegistrantSID]                   [int] NOT NULL,
		[ComplaintTypeSID]                [int] NOT NULL,
		[ComplainantTypeSID]              [int] NOT NULL,
		[ApplicationUserSID]              [int] NOT NULL,
		[OpenedDate]                      [date] NOT NULL,
		[ConductStartDate]                [date] NOT NULL,
		[ConductEndDate]                  [date] NOT NULL,
		[ComplaintSummary]                [varbinary](max) NOT NULL,
		[ComplaintSeveritySID]            [int] NOT NULL,
		[OutcomeSummary]                  [varbinary](max) NULL,
		[IsDisplayedOnPublicRegistry]     [bit] NOT NULL,
		[ClosedDate]                      [date] NULL,
		[DismissedDate]                   [date] NULL,
		[ReasonSID]                       [int] NULL,
		[TagList]                         [xml] NOT NULL,
		[FileExtension]                   [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UserDefinedColumns]              [xml] NULL,
		[ComplaintXID]                    [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                       [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                       [bit] NOT NULL,
		[CreateUser]                      [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                      [datetimeoffset](7) NOT NULL,
		[UpdateUser]                      [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                      [datetimeoffset](7) NOT NULL,
		[RowGUID]                         [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                        [timestamp] NOT NULL,
		CONSTRAINT [uk_Complaint_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_Complaint_ComplaintNo]
		UNIQUE
		NONCLUSTERED
		([ComplaintNo])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_Complaint]
		PRIMARY KEY
		CLUSTERED
		([ComplaintSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Complaint table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'Complaint', 'CONSTRAINT', N'pk_Complaint'
GO
ALTER TABLE [dbo].[Complaint]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_Complaint]
	CHECK
	([dbo].[fComplaint#Check]([ComplaintSID],[ComplaintNo],[RegistrantSID],[ComplaintTypeSID],[ComplainantTypeSID],[ApplicationUserSID],[OpenedDate],[ConductStartDate],[ConductEndDate],[ComplaintSeveritySID],[IsDisplayedOnPublicRegistry],[ClosedDate],[DismissedDate],[ReasonSID],[FileExtension],[ComplaintXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[Complaint]
CHECK CONSTRAINT [ck_Complaint]
GO
ALTER TABLE [dbo].[Complaint]
	ADD
	CONSTRAINT [df_Complaint_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[Complaint]
	ADD
	CONSTRAINT [df_Complaint_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[Complaint]
	ADD
	CONSTRAINT [df_Complaint_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[Complaint]
	ADD
	CONSTRAINT [df_Complaint_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[Complaint]
	ADD
	CONSTRAINT [df_Complaint_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[Complaint]
	ADD
	CONSTRAINT [df_Complaint_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[Complaint]
	ADD
	CONSTRAINT [df_Complaint_ApplicationUserSID]
	DEFAULT ([sf].[fApplicationUserSessionUserSID]()) FOR [ApplicationUserSID]
GO
ALTER TABLE [dbo].[Complaint]
	ADD
	CONSTRAINT [df_Complaint_OpenedDate]
	DEFAULT ([sf].[fToday]()) FOR [OpenedDate]
GO
ALTER TABLE [dbo].[Complaint]
	ADD
	CONSTRAINT [df_Complaint_IsDisplayedOnPublicRegistry]
	DEFAULT ((0)) FOR [IsDisplayedOnPublicRegistry]
GO
ALTER TABLE [dbo].[Complaint]
	ADD
	CONSTRAINT [df_Complaint_TagList]
	DEFAULT (CONVERT([xml],N'<Tags/>')) FOR [TagList]
GO
ALTER TABLE [dbo].[Complaint]
	ADD
	CONSTRAINT [df_Complaint_FileExtension]
	DEFAULT ('.html') FOR [FileExtension]
GO
ALTER TABLE [dbo].[Complaint]
	WITH CHECK
	ADD CONSTRAINT [fk_Complaint_ComplainantType_ComplainantTypeSID]
	FOREIGN KEY ([ComplainantTypeSID]) REFERENCES [dbo].[ComplainantType] ([ComplainantTypeSID])
ALTER TABLE [dbo].[Complaint]
	CHECK CONSTRAINT [fk_Complaint_ComplainantType_ComplainantTypeSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the complainant type system ID column in the Complaint table match a complainant type system ID in the Complainant Type table. It also ensures that records in the Complainant Type table cannot be deleted if matching child records exist in Complaint. Finally, the constraint blocks changes to the value of the complainant type system ID column in the Complainant Type if matching child records exist in Complaint.', 'SCHEMA', N'dbo', 'TABLE', N'Complaint', 'CONSTRAINT', N'fk_Complaint_ComplainantType_ComplainantTypeSID'
GO
ALTER TABLE [dbo].[Complaint]
	WITH CHECK
	ADD CONSTRAINT [fk_Complaint_ComplaintSeverity_ComplaintSeveritySID]
	FOREIGN KEY ([ComplaintSeveritySID]) REFERENCES [dbo].[ComplaintSeverity] ([ComplaintSeveritySID])
ALTER TABLE [dbo].[Complaint]
	CHECK CONSTRAINT [fk_Complaint_ComplaintSeverity_ComplaintSeveritySID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the complaint severity system ID column in the Complaint table match a complaint severity system ID in the Complaint Severity table. It also ensures that records in the Complaint Severity table cannot be deleted if matching child records exist in Complaint. Finally, the constraint blocks changes to the value of the complaint severity system ID column in the Complaint Severity if matching child records exist in Complaint.', 'SCHEMA', N'dbo', 'TABLE', N'Complaint', 'CONSTRAINT', N'fk_Complaint_ComplaintSeverity_ComplaintSeveritySID'
GO
ALTER TABLE [dbo].[Complaint]
	WITH CHECK
	ADD CONSTRAINT [fk_Complaint_ComplaintType_ComplaintTypeSID]
	FOREIGN KEY ([ComplaintTypeSID]) REFERENCES [dbo].[ComplaintType] ([ComplaintTypeSID])
ALTER TABLE [dbo].[Complaint]
	CHECK CONSTRAINT [fk_Complaint_ComplaintType_ComplaintTypeSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the complaint type system ID column in the Complaint table match a complaint type system ID in the Complaint Type table. It also ensures that records in the Complaint Type table cannot be deleted if matching child records exist in Complaint. Finally, the constraint blocks changes to the value of the complaint type system ID column in the Complaint Type if matching child records exist in Complaint.', 'SCHEMA', N'dbo', 'TABLE', N'Complaint', 'CONSTRAINT', N'fk_Complaint_ComplaintType_ComplaintTypeSID'
GO
ALTER TABLE [dbo].[Complaint]
	WITH CHECK
	ADD CONSTRAINT [fk_Complaint_Reason_ReasonSID]
	FOREIGN KEY ([ReasonSID]) REFERENCES [dbo].[Reason] ([ReasonSID])
ALTER TABLE [dbo].[Complaint]
	CHECK CONSTRAINT [fk_Complaint_Reason_ReasonSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the reason system ID column in the Complaint table match a reason system ID in the Reason table. It also ensures that records in the Reason table cannot be deleted if matching child records exist in Complaint. Finally, the constraint blocks changes to the value of the reason system ID column in the Reason if matching child records exist in Complaint.', 'SCHEMA', N'dbo', 'TABLE', N'Complaint', 'CONSTRAINT', N'fk_Complaint_Reason_ReasonSID'
GO
ALTER TABLE [dbo].[Complaint]
	WITH CHECK
	ADD CONSTRAINT [fk_Complaint_SF_ApplicationUser_ApplicationUserSID]
	FOREIGN KEY ([ApplicationUserSID]) REFERENCES [sf].[ApplicationUser] ([ApplicationUserSID])
ALTER TABLE [dbo].[Complaint]
	CHECK CONSTRAINT [fk_Complaint_SF_ApplicationUser_ApplicationUserSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the application user system ID column in the Complaint table match a application user system ID in the Application User table. It also ensures that records in the Application User table cannot be deleted if matching child records exist in Complaint. Finally, the constraint blocks changes to the value of the application user system ID column in the Application User if matching child records exist in Complaint.', 'SCHEMA', N'dbo', 'TABLE', N'Complaint', 'CONSTRAINT', N'fk_Complaint_SF_ApplicationUser_ApplicationUserSID'
GO
ALTER TABLE [dbo].[Complaint]
	WITH CHECK
	ADD CONSTRAINT [fk_Complaint_Registrant_RegistrantSID]
	FOREIGN KEY ([RegistrantSID]) REFERENCES [dbo].[Registrant] ([RegistrantSID])
ALTER TABLE [dbo].[Complaint]
	CHECK CONSTRAINT [fk_Complaint_Registrant_RegistrantSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the registrant system ID column in the Complaint table match a registrant system ID in the Registrant table. It also ensures that records in the Registrant table cannot be deleted if matching child records exist in Complaint. Finally, the constraint blocks changes to the value of the registrant system ID column in the Registrant if matching child records exist in Complaint.', 'SCHEMA', N'dbo', 'TABLE', N'Complaint', 'CONSTRAINT', N'fk_Complaint_Registrant_RegistrantSID'
GO
CREATE NONCLUSTERED INDEX [ix_Complaint_ApplicationUserSID_ComplaintSID]
	ON [dbo].[Complaint] ([ApplicationUserSID], [ComplaintSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Application User SID foreign key column and avoids row contention on (parent) Application User updates', 'SCHEMA', N'dbo', 'TABLE', N'Complaint', 'INDEX', N'ix_Complaint_ApplicationUserSID_ComplaintSID'
GO
CREATE NONCLUSTERED INDEX [ix_Complaint_ComplainantTypeSID_ComplaintSID]
	ON [dbo].[Complaint] ([ComplainantTypeSID], [ComplaintSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Complainant Type SID foreign key column and avoids row contention on (parent) Complainant Type updates', 'SCHEMA', N'dbo', 'TABLE', N'Complaint', 'INDEX', N'ix_Complaint_ComplainantTypeSID_ComplaintSID'
GO
CREATE NONCLUSTERED INDEX [ix_Complaint_ComplaintSeveritySID_ComplaintSID]
	ON [dbo].[Complaint] ([ComplaintSeveritySID], [ComplaintSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Complaint Severity SID foreign key column and avoids row contention on (parent) Complaint Severity updates', 'SCHEMA', N'dbo', 'TABLE', N'Complaint', 'INDEX', N'ix_Complaint_ComplaintSeveritySID_ComplaintSID'
GO
CREATE NONCLUSTERED INDEX [ix_Complaint_ComplaintTypeSID_ComplaintSID]
	ON [dbo].[Complaint] ([ComplaintTypeSID], [ComplaintSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Complaint Type SID foreign key column and avoids row contention on (parent) Complaint Type updates', 'SCHEMA', N'dbo', 'TABLE', N'Complaint', 'INDEX', N'ix_Complaint_ComplaintTypeSID_ComplaintSID'
GO
CREATE NONCLUSTERED INDEX [ix_Complaint_ReasonSID_ComplaintSID]
	ON [dbo].[Complaint] ([ReasonSID], [ComplaintSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Reason SID foreign key column and avoids row contention on (parent) Reason updates', 'SCHEMA', N'dbo', 'TABLE', N'Complaint', 'INDEX', N'ix_Complaint_ReasonSID_ComplaintSID'
GO
CREATE NONCLUSTERED INDEX [ix_Complaint_RegistrantSID_ComplaintSID]
	ON [dbo].[Complaint] ([RegistrantSID], [ComplaintSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Registrant SID foreign key column and avoids row contention on (parent) Registrant updates', 'SCHEMA', N'dbo', 'TABLE', N'Complaint', 'INDEX', N'ix_Complaint_RegistrantSID_ComplaintSID'
GO
CREATE FULLTEXT INDEX ON [dbo].[Complaint]
	([ComplaintSummary] TYPE COLUMN [FileExtension] LANGUAGE 1033, [OutcomeSummary] TYPE COLUMN [FileExtension] LANGUAGE 1033)
	KEY INDEX [pk_Complaint]
	ON (FILEGROUP [FullTextIndexData], [ftcDefault])
	WITH CHANGE_TRACKING AUTO, STOPLIST OFF
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the complaint assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'Complaint', 'COLUMN', N'ComplaintSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'Complaint', 'COLUMN', N'RegistrantSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of complaint', 'SCHEMA', N'dbo', 'TABLE', N'Complaint', 'COLUMN', N'ComplaintTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of complaint', 'SCHEMA', N'dbo', 'TABLE', N'Complaint', 'COLUMN', N'ComplainantTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The user assigned to this complaint', 'SCHEMA', N'dbo', 'TABLE', N'Complaint', 'COLUMN', N'ApplicationUserSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date the complaint was reported. | Normally the record entry date but provided to support back-dating when received through other channels', 'SCHEMA', N'dbo', 'TABLE', N'Complaint', 'COLUMN', N'OpenedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date the reported conduct took place or the start of the period the reported conduct took place', 'SCHEMA', N'dbo', 'TABLE', N'Complaint', 'COLUMN', N'ConductStartDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date the reported conduct took place or the end of the period the reported conduct took place', 'SCHEMA', N'dbo', 'TABLE', N'Complaint', 'COLUMN', N'ConductEndDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The complaint severity assigned to this complaint', 'SCHEMA', N'dbo', 'TABLE', N'Complaint', 'COLUMN', N'ComplaintSeveritySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if the outcome text is displayed on the public directory', 'SCHEMA', N'dbo', 'TABLE', N'Complaint', 'COLUMN', N'IsDisplayedOnPublicRegistry'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The reason assigned to this complaint', 'SCHEMA', N'dbo', 'TABLE', N'Complaint', 'COLUMN', N'ReasonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A value required by the system to perform full-text indexing on the HTML formatted content in the record (do not expose in user interface).', 'SCHEMA', N'dbo', 'TABLE', N'Complaint', 'COLUMN', N'FileExtension'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the complaint | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'Complaint', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'Complaint', 'COLUMN', N'ComplaintXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'Complaint', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'Complaint', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the complaint | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'Complaint', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this complaint record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'Complaint', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the complaint | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'Complaint', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the complaint record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'Complaint', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the complaint record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'Complaint', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'Complaint', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Complaint No column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'Complaint', 'CONSTRAINT', N'uk_Complaint_ComplaintNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'Complaint', 'CONSTRAINT', N'uk_Complaint_RowGUID'
GO
SET ANSI_PADDING ON
GO
CREATE PRIMARY XML INDEX [xp_Complaint_TagList]
	ON [dbo].[Complaint] ([TagList])
GO
EXEC sp_addextendedproperty N'MS_Description', N'A primary XML index to support fast parsing of the Tag List (XML) column', 'SCHEMA', N'dbo', 'TABLE', N'Complaint', 'INDEX', N'xp_Complaint_TagList'
GO
ALTER TABLE [dbo].[Complaint] SET (LOCK_ESCALATION = TABLE)
GO
