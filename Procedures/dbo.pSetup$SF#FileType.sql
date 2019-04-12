SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.[pSetup$SF#FileType]
	@SetupUser nvarchar(75) -- user assigned to audit columns
 ,@Language	 char(2)			-- language to install for
 ,@Region		 varchar(10)	-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup sf.FileType data
Notice   : Copyright © 2015 Softworks Group Inc.
Summary  : Updates sf.FileType master table with values required by the application
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Tim Edlund		| Feb 2015			| Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------
This procedure synchronizes the sf.FileType table with the settings required by the current version of the application. 
If a record is missing it is added. File types no longer used are deleted from the table. One MERGE statement is used to carryout 
all operations.

Note that adding a file type does not mean that it will be successfully included in full text indexes!  You must ensure an
"iFilter" is installed on the server that supports the new file type.  To see the list of file types supported by the 
current set of installed filters run this query:

exec sp_help_fulltext_system_components 'filter';

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="This test deletes the content of table if no records are in use as foreign 
	keys, calls the procedure, and selects all records. The test checks to ensure the resulting data set is not empty and 
	performance is within 3 seconds.">
		<SQLScript>
		<![CDATA[
			
			if	not exists (select 1 from dbo.PersonDoc where FileTypeSID is not null)
			and not exists (select 1 from dbo.PersonGroupFolderDoc where FileTypeSID is not null)
			begin
				delete from sf.FileType
				dbcc checkident( 'sf.FileType', reseed, 1000000) with NO_INFOMSGS
			end

			exec dbo.pSetup$SF#FileType
				 @SetupUser	= 'system@product.com'
				,@Language	= 'EN'
				,@Region		= 'CA'

			select * from sf.FileType

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:03" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName			= 'dbo.pSetup$SF#FileType'
	,@DefaultTestOnly	= 1

------------------------------------------------------------------------------------------------------------------------------- */

set nocount on;

begin

	declare
		@errorNo		 int					 = 0								-- 0 no error, if < 50000 SQL error, else business rule
	 ,@errorText	 nvarchar(4000)										-- message text (for business rule errors)
	 ,@sourceCount int															-- count of rows in the source table
	 ,@targetCount int															-- count of rows in the target table
	 ,@OFF				 bit					 = cast(0 as bit)		-- constant for bit = 0
	 ,@ON					 bit					 = cast(1 as bit);	-- constant for bit = 1

	declare @setup table
	(
		ID						int					 identity(1, 1)
	 ,FileTypeSCD		varchar(8)	 not null
	 ,FileTypeLabel nvarchar(35) not null
	 ,MimeType			varchar(255) not null
	 ,IsInline			bit					 not null
	 ,IsActive			bit					 not null
	);

	begin try

		insert
			@setup
		( FileTypeSCD
		 ,FileTypeLabel
		 ,MimeType
		 ,IsInline
		 ,IsActive)
		values
		(
			'.DOC', N'Microsoft Word', 'application/msword', @OFF, @OFF)
	 ,(
			'.DOCX', N'Microsoft Word (ver 2007+)', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', @OFF, @OFF)	-- NOTE: requires ADD on filter be installed!
	 ,(
			'.HTML', N'Web page', 'text/html', @ON, @OFF)
	 ,(
			'.PDF', N'Adobe PDF', 'application/pdf', @ON, @ON)
	 ,(
			'.PPT', N'Microsoft PowerPoint', 'application/vnd.ms-powerpointtd>', @OFF, @OFF)
	 ,(
			'.PPTX', N'Microsoft PowerPoint (ver 2007+)', 'application/vnd.openxmlformats-officedocument.presentationml.presentation', @OFF, @OFF)
	 ,(
			'.RTF', N'Rich text format', 'application/rtf', @OFF, @OFF)
	 ,(
			'.TXT', N'Text document', 'text/plain', @OFF, @OFF)
	 ,(
			'.XLS', N'Microsoft Excel', 'application/vnd.ms-excel', @OFF, @OFF)
	 ,(
			'.XLSX', N'Microsoft Excel (ver 2007+)', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', @OFF, @OFF)
	 ,(
			'.XML', N'XML document', 'application/xml', @OFF, @OFF)
	 ,(
			'.PNG', N'PNG Image document', 'image/png', @ON, @ON)
	 ,(
			'.JPG', N'JPG Image document', 'image/jpeg', @ON, @ON)
	 ,(
			'.JPEG', N'JPEG Image document', 'image/jpeg', @ON, @ON);

		merge sf.FileType target
		using
		( select
				x.FileTypeSCD
			 ,x.FileTypeLabel
			 ,x.MimeType
			 ,x.IsInline
			 ,x.IsActive
			from
				@setup x) source
		on target.FileTypeSCD = source.FileTypeSCD
		when not matched by target then insert
																		( FileTypeSCD
																		 ,FileTypeLabel
																		 ,MimeType
																		 ,IsInline
																		 ,IsActive
																		 ,CreateUser
																		 ,UpdateUser)
																		values
																		(
																			source.FileTypeSCD, source.FileTypeLabel, source.MimeType, source.IsInline, source.IsActive, @SetupUser, @SetupUser)
		when matched then update set
												MimeType = source.MimeType
											 ,IsInline = source.IsInline
											 ,UpdateUser = @SetupUser
		when not matched by source then delete;

		-- check count of @setup table and the target table
		-- target should have exactly as many rows as @setup

		select	@sourceCount = count(1) from	@setup;
		select	@targetCount = count(1) from	sf.FileType;

		if isnull(@targetCount, 0) <> @sourceCount
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'SetupNotSynchronized'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'Synchronization of setup codes not complete. Source table count is %1 but target table (%2) count is %3.'
			 ,@Arg1 = @sourceCount
			 ,@Arg2 = 'sf.FileType'
			 ,@Arg3 = @targetCount;

			raiserror(@errorText, 18, 1);
		end;

	end try

	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);

end;
GO
