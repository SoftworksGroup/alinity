SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pSetup$SF#MessageStatus]
	 @SetupUser						nvarchar(75)									-- user assigned to audit columns
	,@Language						char(2)												-- language to install for
	,@Region							varchar(10)         					-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup dbo.MessageStatus data
Notice   : Copyright © 2014 Softworks Group Inc.
Summary  : Updates dbo.MessageStatus master table with starting values for the application
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Richard K		| Apr 2015			|	Initial Version
				 : Tim Edlund		| Jul 2018			| Added "GENERATED" status. Corrected errors in IsClosedStatus settings.
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------
 This procedure populates the MessageStatus table with initial values used to track identify the status of email messages.
 If a record is missing it is added, when a record matches all field except descriptive fields editable by the user are changed to
 the defaults.  Any records not found are deleted.

 One MERGE statement is used to carryout all operations.

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully. If no child records exist, previous set up data is deleted prior to test.">
		<SQLScript>
		<![CDATA[
		
			if	not exists (select 1 from sf.MessageStatus where MessageStatusSID is not null)
			begin
				delete from sf.MessageStatus
				dbcc checkident( 'sf.MessageStatus', reseed, 1000000) with NO_INFOMSGS
			end

			exec dbo.pSetup$SF#MessageStatus
				 @SetupUser = 'system@alinityapp.com'
				,@Language = 'EN'
				,@Region = 'CA'

			select * from sf.MessageStatus

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$SF#MessageStatus'
	,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */
 
begin  

	set nocount on

	declare
		 @errorNo                           int = 0                           -- 0 no error, if < 50000 SQL error, else business rule
		,@errorText                         nvarchar(4000)                    -- message text (for business rule errors)
		,@ON																bit = cast(1 as bit)							-- constant for TRUE - reduces casting operations
		,@OFF																bit = cast(0 as bit)							-- constant for FALSE - reduces casting operations
		,@sourceCount                       int                               -- count of rows in the source table
		,@targetCount                       int                               -- count of rows in the target table

	declare
		@setup															table
		(
			 ID                               int           identity(1,1)
			,MessageStatusSCD									varchar(10)		not null
			,MessageStatusLabel								nvarchar(35)	not null
			,UsageNotes												nvarchar(max)	not null
			,IsClosedStatus										bit not null
			,IsActive													bit not null
			,IsDefault												bit	not null
		)

	begin try
	
		insert
			@setup
		(
			 MessageStatusSCD
			,MessageStatusLabel
			,UsageNotes
			,IsClosedStatus
			,IsActive
			,IsDefault
		)
		values
			 ('DRAFT'				, N'Draft'							, 'This status indicates that the email message has been created but has not yet been queued for processing.', @OFF, @ON, @ON )
			,('MERGING'			, N'Merging'						, 'This status indicates that the email message is in the process of merging all recipient emails.', @OFF, @ON, @OFF )
			,('QUEUING'			, N'Queuing'						, 'This status indicates that the email message is currently being queued for sending.', @OFF, @ON, @OFF )
			,('QUEUED'			, N'Queued'							, 'This status indicates that the email message has been placed into the queue for processing. Processing is carried out by a separate Windows Service which reports back once complete.', @OFF, @ON, @OFF )
			,('SENT'				, N'Sent'								, 'This status indicates that the email message has been sent successfully. Note that this is not a confirmation that the email was received which cannot be reliably determined.', @ON, @ON, @OFF )
			,('GENERATED'		, N'Generated Only'			, 'This status indicates that the email message was generated successfully but not sent out based on the user having requested the "do-not-send/generate-only" option. This option allows documents to be generated from a template and stored in the member records for downloading and/or printing as hard-copy documents.', @ON, @ON, @OFF)
			,('ARCHIVED'		, N'Archived'						, 'This status indicates that the email message has been moved into archive.  This means the email will not show in any query results unless the Archived message status is specifically requested in the search.', @ON, @ON, @OFF )
			,('PURGED'			, N'Purged'							, 'This status indicates that the email message has been purged.  This means that the PDFs will no longer be available on the individual emails sent to members.', @ON, @ON, @OFF )
			,('CANCELLED'		, N'Cancelled'					, 'This status indicates that the email message has been cancelled prior to sending any email messages.  This means the email will not show in any query results unless the Cancelled message status is specifically requested in the search.', @ON, @ON, @OFF )
			,('PARTIAL'			, N'Partial'						, 'This status indicates that the email message has been cancelled after one more more emails have already been sent.  This means the email will not show in any query results unless the Partial message status is specifically requested in the search.', @ON, @ON, @OFF )

		merge
			sf.MessageStatus target		-- update the database for any new, missing or changed values
		using
		(
			select
				 x.MessageStatusSCD
				,x.MessageStatusLabel
				,x.UsageNotes
				,x.IsClosedStatus
				,x.IsActive
				,x.IsDefault
			from
				@setup x
		) source
		on 
			target.MessageStatusSCD = source.MessageStatusSCD
		when not matched by target then
			insert 
			(
				 MessageStatusSCD
				,MessageStatusLabel
				,UsageNotes
				,IsClosedStatus
				,IsActive
				,IsDefault
				,CreateUser
				,UpdateUser
			) 
			values
			(
				 source.MessageStatusSCD
				,source.MessageStatusLabel
				,source.UsageNotes
				,source.IsClosedStatus	
				,source.IsActive
				,source.IsDefault			
				,@SetupUser
				,@SetupUser
			)
		when matched then
			update 
				set 
				IsDefault									= source.IsDefault
				,IsActive									= source.IsActive
				,IsClosedStatus						=	source.IsClosedStatus
				,UpdateUser								= @SetupUser
				,UpdateTime = sysdatetimeoffset()
		when not matched by source then
			delete
		;

		-- check count of @setup table and the target table
		-- target should have exactly as many rows as @setup

		select @sourceCount = count(1) from  @setup
		select @targetCount = count(1) from  sf.MessageStatus

		if isnull(@targetCount,0) <> @sourceCount
		begin

			exec sf.pMessage#Get
				 @MessageSCD    = 'SetupNotSynchronized'
				,@MessageText   = @errorText output
				,@DefaultText   = N'Synchronization of setup codes not complete. Source table count is %1 but target table (%2) count is %3.'
				,@Arg1          = @sourceCount
				,@Arg2          = 'sf.MessageStatus'
				,@Arg3          = @targetCount

			raiserror(@errorText, 18, 1)
		end
			
	end try

	begin catch
		exec @errorNo = sf.pErrorRethrow
	end catch
		
	return(@errorNo)

end
GO
