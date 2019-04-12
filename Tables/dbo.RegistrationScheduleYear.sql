SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RegistrationScheduleYear] (
		[RegistrationScheduleYearSID]           [int] IDENTITY(1000001, 1) NOT NULL,
		[RegistrationScheduleSID]               [int] NOT NULL,
		[RegistrationYear]                      [smallint] NOT NULL,
		[YearStartTime]                         [datetime] NOT NULL,
		[YearEndTime]                           [datetime] NOT NULL,
		[RenewalVerificationOpenTime]           [datetime] NOT NULL,
		[RenewalGeneralOpenTime]                [datetime] NOT NULL,
		[RenewalLateFeeStartTime]               [datetime] NOT NULL,
		[RenewalEndTime]                        [datetime] NOT NULL,
		[ReinstatementVerificationOpenTime]     [datetime] NOT NULL,
		[ReinstatementGeneralOpenTime]          [datetime] NOT NULL,
		[ReinstatementEndTime]                  [datetime] NOT NULL,
		[CECollectionStartTime]                 [datetime] NOT NULL,
		[CECollectionEndTime]                   [datetime] NOT NULL,
		[PAPBlockStartTime]                     [datetime] NOT NULL,
		[PAPBlockEndTime]                       [datetime] NOT NULL,
		[UserDefinedColumns]                    [xml] NULL,
		[RegistrationScheduleYearXID]           [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                             [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                             [bit] NOT NULL,
		[CreateUser]                            [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                            [datetimeoffset](7) NOT NULL,
		[UpdateUser]                            [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                            [datetimeoffset](7) NOT NULL,
		[RowGUID]                               [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                              [timestamp] NOT NULL,
		CONSTRAINT [uk_RegistrationScheduleYear_RegistrationScheduleSID_RegistrationYear]
		UNIQUE
		NONCLUSTERED
		([RegistrationScheduleSID], [RegistrationYear])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_RegistrationScheduleYear_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_RegistrationScheduleYear]
		PRIMARY KEY
		CLUSTERED
		([RegistrationScheduleYearSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Registration Schedule Year table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationScheduleYear', 'CONSTRAINT', N'pk_RegistrationScheduleYear'
GO
ALTER TABLE [dbo].[RegistrationScheduleYear]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_RegistrationScheduleYear]
	CHECK
	([dbo].[fRegistrationScheduleYear#Check]([RegistrationScheduleYearSID],[RegistrationScheduleSID],[RegistrationYear],[YearStartTime],[YearEndTime],[RenewalVerificationOpenTime],[RenewalGeneralOpenTime],[RenewalLateFeeStartTime],[RenewalEndTime],[ReinstatementVerificationOpenTime],[ReinstatementGeneralOpenTime],[ReinstatementEndTime],[CECollectionStartTime],[CECollectionEndTime],[PAPBlockStartTime],[PAPBlockEndTime],[RegistrationScheduleYearXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[RegistrationScheduleYear]
CHECK CONSTRAINT [ck_RegistrationScheduleYear]
GO
ALTER TABLE [dbo].[RegistrationScheduleYear]
	ADD
	CONSTRAINT [df_RegistrationScheduleYear_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[RegistrationScheduleYear]
	ADD
	CONSTRAINT [df_RegistrationScheduleYear_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[RegistrationScheduleYear]
	ADD
	CONSTRAINT [df_RegistrationScheduleYear_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[RegistrationScheduleYear]
	ADD
	CONSTRAINT [df_RegistrationScheduleYear_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[RegistrationScheduleYear]
	ADD
	CONSTRAINT [df_RegistrationScheduleYear_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[RegistrationScheduleYear]
	ADD
	CONSTRAINT [df_RegistrationScheduleYear_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[RegistrationScheduleYear]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrationScheduleYear_RegistrationSchedule_RegistrationScheduleSID]
	FOREIGN KEY ([RegistrationScheduleSID]) REFERENCES [dbo].[RegistrationSchedule] ([RegistrationScheduleSID])
ALTER TABLE [dbo].[RegistrationScheduleYear]
	CHECK CONSTRAINT [fk_RegistrationScheduleYear_RegistrationSchedule_RegistrationScheduleSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the registration schedule system ID column in the Registration Schedule Year table match a registration schedule system ID in the Registration Schedule table. It also ensures that records in the Registration Schedule table cannot be deleted if matching child records exist in Registration Schedule Year. Finally, the constraint blocks changes to the value of the registration schedule system ID column in the Registration Schedule if matching child records exist in Registration Schedule Year.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationScheduleYear', 'CONSTRAINT', N'fk_RegistrationScheduleYear_RegistrationSchedule_RegistrationScheduleSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrationScheduleYear_RegistrationScheduleSID_RegistrationScheduleYearSID]
	ON [dbo].[RegistrationScheduleYear] ([RegistrationScheduleSID], [RegistrationScheduleYearSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Registration Schedule SID foreign key column and avoids row contention on (parent) Registration Schedule updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationScheduleYear', 'INDEX', N'ix_RegistrationScheduleYear_RegistrationScheduleSID_RegistrationScheduleYearSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table records the schedule of registration years including when renewal is open and closed, when late fees are applied, etc.  The values are also used to control which year(s) are eligible for reinstatements.  The schedule may be applied to one or more practice registers. You can also use this table to adjust the open/close dates for specific years in order to avoid weekends and holidays. At least one "future" year should be established at all times to ensure renewal and reinstatement are perpetually available at the right times from the member dashboard. Note that the "Registration Year" is a 4 digit year value set by the system based on the Year-End-Time value.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationScheduleYear', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registration schedule year assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationScheduleYear', 'COLUMN', N'RegistrationScheduleYearSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The registration schedule this year is defined for', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationScheduleYear', 'COLUMN', N'RegistrationScheduleSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A 4 digit numeric year set by the system based on the end of the term (entered into Year-End-Time).  For example, a year starting October 1st 2019 and ending September 30, 2020 is referred to by the system as the "2020" Registration Year.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationScheduleYear', 'COLUMN', N'RegistrationYear'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The first day in the registration year.  When registrations are renewed in advance of the registration year, this becomes the effective time of the new registration. | This value is entered as a full date but the system stores it with a time component to make comparisons easier. The time component is always 0:00:00 indicating the first moment of the year.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationScheduleYear', 'COLUMN', N'YearStartTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The last day in the registration year.  When registrations are renewed before the registration year or during it, this becomes the expiry time of the new registration.  For temporary permits, the term may be shorter. This value is entered on the user interface as a date but the system stores it with a time component to make comparisons easier.  The time component is always set to 23:59:59 indicating the last moment of the year.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationScheduleYear', 'COLUMN', N'YearEndTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time when the online renewal process for this registration year is opened to selected verifiers.  Verifiers are staff or committee members who hold registrations that you wish to check the configuration of the renewal before opening it to the general membership.  This date is typically set a few days before the general renewal open date.  Note that you must assign the "Verification" grant in security settings in order that the early renewal will appear on the members dashboard. If no specific time component is entered the time defaults to 0:00:00 indicating the first moment of the day.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationScheduleYear', 'COLUMN', N'RenewalVerificationOpenTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time when the online renewal process for this registration year is opened to the general membership.  If no specific time component is entered the time defaults to 0:00:00 indicating the first moment of the day.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationScheduleYear', 'COLUMN', N'RenewalGeneralOpenTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time when the late fee should be applied to renewal charges.  If no specific time component is entered the time defaults to 0:00:00 indicating the first moment of the day.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationScheduleYear', 'COLUMN', N'RenewalLateFeeStartTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time when renewal for the given registration year should close.  This results in the option not being selectable from the member dashboard, however, if the member has already started their renewal they will be able to save it - however automatic approval will not occur.  If no specific time component is entered the time defaults to 23:59:59 indicating the last moment of the day.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationScheduleYear', 'COLUMN', N'RenewalEndTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time the reinstatement process for this registration year is opened to selected verifiers.  Verifiers are staff or committee members who hold registrations that you wish to check the configuration of the reinstatement before opening it to the general membership.  This date is typically set a few days before the general reinstatement open date.  Note that you must assign the "Verification" grant in security settings in order that the early renewal will appear on the members dashboard. If no specific time component is entered the time defaults to 0:00:00 indicating the first moment of the day.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationScheduleYear', 'COLUMN', N'ReinstatementVerificationOpenTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time when the online reinstatement process for this registration year is opened to the general membership.  If no specific time component is entered the time defaults to 0:00:00 indicating the first moment of the day.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationScheduleYear', 'COLUMN', N'ReinstatementGeneralOpenTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time when reinstatement process for the given registration year should close.  This results in the option not being selectable from the member dashboard, however, if the member has already started their reinstatement they will be able to save it - however automatic approval will not occur.  If no specific time component is entered the time defaults to 23:59:59 indicating the last moment of the day.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationScheduleYear', 'COLUMN', N'ReinstatementEndTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date when collection for continuing education unit/hours compliance starts for this registration year', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationScheduleYear', 'COLUMN', N'CECollectionStartTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date when collection for continuing education unit/hours compliance ends for this registration year', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationScheduleYear', 'COLUMN', N'CECollectionEndTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the registration schedule year | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationScheduleYear', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationScheduleYear', 'COLUMN', N'RegistrationScheduleYearXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationScheduleYear', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationScheduleYear', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the registration schedule year | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationScheduleYear', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this registration schedule year record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationScheduleYear', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the registration schedule year | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationScheduleYear', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the registration schedule year record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationScheduleYear', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registration schedule year record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationScheduleYear', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationScheduleYear', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the combination of values provided for the "Registration Schedule SID + Registration Year" columns is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationScheduleYear', 'CONSTRAINT', N'uk_RegistrationScheduleYear_RegistrationScheduleSID_RegistrationYear'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationScheduleYear', 'CONSTRAINT', N'uk_RegistrationScheduleYear_RowGUID'
GO
ALTER TABLE [dbo].[RegistrationScheduleYear] SET (LOCK_ESCALATION = TABLE)
GO
