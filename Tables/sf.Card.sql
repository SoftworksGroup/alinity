SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[Card] (
		[CardSID]                   [int] IDENTITY(1000001, 1) NOT NULL,
		[CardTypeSID]               [int] NOT NULL,
		[CardLabel]                 [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CardContext]               [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CSSDefinition]             [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[SummaryCardDefinition]     [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[DetailCardDefinition]      [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[HeaderDefinition]          [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FooterDefinition]          [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[GridRowDefinition]         [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsActive]                  [bit] NOT NULL,
		[CardHelp]                  [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[UserDefinedColumns]        [xml] NULL,
		[CardXID]                   [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                 [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                 [bit] NOT NULL,
		[CreateUser]                [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                [datetimeoffset](7) NOT NULL,
		[UpdateUser]                [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                [datetimeoffset](7) NOT NULL,
		[RowGUID]                   [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                  [timestamp] NOT NULL,
		CONSTRAINT [uk_Card_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_Card_CardTypeSID_CardContext]
		UNIQUE
		NONCLUSTERED
		([CardTypeSID], [CardContext])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_Card_CardLabel]
		UNIQUE
		NONCLUSTERED
		([CardLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_Card]
		PRIMARY KEY
		CLUSTERED
		([CardSID])
	WITH FILLFACTOR=90
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Card table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'Card', 'CONSTRAINT', N'pk_Card'
GO
ALTER TABLE [sf].[Card]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_Card]
	CHECK
	([sf].[fCard#Check]([CardSID],[CardTypeSID],[CardLabel],[CardContext],[CSSDefinition],[IsActive],[CardXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[Card]
CHECK CONSTRAINT [ck_Card]
GO
ALTER TABLE [sf].[Card]
	ADD
	CONSTRAINT [df_Card_CardContext]
	DEFAULT ('DEFAULT') FOR [CardContext]
GO
ALTER TABLE [sf].[Card]
	ADD
	CONSTRAINT [df_Card_CSSDefinition]
	DEFAULT ('col-xs-12 col-sm-6 col-md-6 col-lg-4') FOR [CSSDefinition]
GO
ALTER TABLE [sf].[Card]
	ADD
	CONSTRAINT [df_Card_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [sf].[Card]
	ADD
	CONSTRAINT [df_Card_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[Card]
	ADD
	CONSTRAINT [df_Card_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[Card]
	ADD
	CONSTRAINT [df_Card_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[Card]
	ADD
	CONSTRAINT [df_Card_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[Card]
	ADD
	CONSTRAINT [df_Card_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[Card]
	ADD
	CONSTRAINT [df_Card_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[Card]
	WITH CHECK
	ADD CONSTRAINT [fk_Card_CardType_CardTypeSID]
	FOREIGN KEY ([CardTypeSID]) REFERENCES [sf].[CardType] ([CardTypeSID])
ALTER TABLE [sf].[Card]
	CHECK CONSTRAINT [fk_Card_CardType_CardTypeSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the card type system ID column in the Card table match a card type system ID in the Card Type table. It also ensures that records in the Card Type table cannot be deleted if matching child records exist in Card. Finally, the constraint blocks changes to the value of the card type system ID column in the Card Type if matching child records exist in Card.', 'SCHEMA', N'sf', 'TABLE', N'Card', 'CONSTRAINT', N'fk_Card_CardType_CardTypeSID'
GO
CREATE NONCLUSTERED INDEX [ix_Card_CardTypeSID_CardSID]
	ON [sf].[Card] ([CardTypeSID], [CardSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Card Type SID foreign key column and avoids row contention on (parent) Card Type updates', 'SCHEMA', N'sf', 'TABLE', N'Card', 'INDEX', N'ix_Card_CardTypeSID_CardSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This record is used to configure customized directories or listings in the application.  There are 2 formats suported: a "summary" card and a "detail" card.  The summary card is typically presented in a view that supports searching. The summary card can be clicked to navigate to a more detailed view showing additional information.  A summary card definition is required but a detailed card definition is not required.  The record requires a type of card be specified as defined in the Card Type table.  The application uses the card-type code in the associated master table to select the correct type for a given context.  Context may be defined further through the card-context column. The content (fields), layout and style elements of a card are stored in the nvarchar columns as an HTML document.  Note that "versions" of card formats are not stored in a sub-table.  The design will incorporate temporal tables to store history once upgrades to SQL Server 2016 are made.', 'SCHEMA', N'sf', 'TABLE', N'Card', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the card assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'Card', 'COLUMN', N'CardSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the audit action assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'Card', 'COLUMN', N'CardTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the card to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'TABLE', N'Card', 'COLUMN', N'CardLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional identifier of the use-case or context where this card should be applied.  | This value enables 2 (or more) cards of the same type to be in effect at the same time. ', 'SCHEMA', N'sf', 'TABLE', N'Card', 'COLUMN', N'CardContext'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A string that defines the CSS style sheets that are used in the formatting of the web page', 'SCHEMA', N'sf', 'TABLE', N'Card', 'COLUMN', N'CSSDefinition'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An HTML fragment specifying the design of the summary card that appears to display search results | This is not a full HTML page specification but a fragment matching the structure expected by an Alinity plug-in (requires Help Desk to configure)', 'SCHEMA', N'sf', 'TABLE', N'Card', 'COLUMN', N'SummaryCardDefinition'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An HTML fragment specifying the design of the detail card that appears when the user clicks the summary card on the search results page | This is not a full HTML page specification but a fragment matching the structure expected by an Alinity plug-in (requires Help Desk to configure)', 'SCHEMA', N'sf', 'TABLE', N'Card', 'COLUMN', N'DetailCardDefinition'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An HTML fragment specifying the design of the header area of the page that the summary and detail cards are displayed on (optional) | This is not a full HTML page specification but a fragment matching the structure expected by an Alinity plug-in (requires Help Desk to configure)', 'SCHEMA', N'sf', 'TABLE', N'Card', 'COLUMN', N'HeaderDefinition'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An HTML fragment specifying the design of the footer area of the page that the summary and detail cards are displayed on (optional) | This is not a full HTML page specification but a fragment matching the structure expected by an Alinity plug-in (requires Help Desk to configure)', 'SCHEMA', N'sf', 'TABLE', N'Card', 'COLUMN', N'FooterDefinition'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An HTML fragment specifying the design of the grid/table row area (optional) | This is not a full HTML page specification but a fragment matching the structure expected by an Alinity plug-in (requires Help Desk to configure)', 'SCHEMA', N'sf', 'TABLE', N'Card', 'COLUMN', N'GridRowDefinition'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this card record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'sf', 'TABLE', N'Card', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Instructions to present to the end user when this card is presented. Note that instructions from the "Parent" card in a card set are always displayed first even if the parent card does not appear until later in the card-set sequence.', 'SCHEMA', N'sf', 'TABLE', N'Card', 'COLUMN', N'CardHelp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the card | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'Card', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'Card', 'COLUMN', N'CardXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'Card', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'Card', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the card | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'Card', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this card record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'Card', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the card | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'Card', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the card record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'Card', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the card record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'Card', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'Card', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'Card', 'CONSTRAINT', N'uk_Card_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the combination of values provided for the "Card Type SID + Card Context" columns is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'Card', 'CONSTRAINT', N'uk_Card_CardTypeSID_CardContext'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Card Label column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'Card', 'CONSTRAINT', N'uk_Card_CardLabel'
GO
ALTER TABLE [sf].[Card] SET (LOCK_ESCALATION = TABLE)
GO
