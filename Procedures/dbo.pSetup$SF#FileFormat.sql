SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.[pSetup$SF#FileFormat]
	@SetupUser nvarchar(75) -- user assigned to audit columns
 ,@Language	 char(2)			-- language to install for
 ,@Region		 varchar(10)	-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup sf.FileFormat data
Notice   : Copyright © 2015 Softworks Group Inc.
Summary  : Updates sf.FileFormat master table with values required by the application
----------------------------------------------------------------------------------------------------------------------------------
History		: Author	  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Tim Edlund	| May 2018		|	Initial version

Comments	
--------
This procedure synchronizes the sf.FileFormat table with the settings required by the current version of the application. 
If a record is missing it is added. File types no longer used are deleted from the table. One MERGE statement is used to carryout 
all operations.

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully.">
		<SQLScript>
		<![CDATA[
		
			exec dbo.pSetup$SF#FileFormat
				 @SetupUser = 'system@alinityapp.com'
				,@Language = 'EN'
				,@Region = 'CA'

			select * from sf.FileFormat order by Sequence

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName			= 'dbo.pSetup$SF#FileFormat'
	,@DefaultTestOnly	= 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo		 int					 = 0								-- 0 no error, if < 50000 SQL error, else business rule
	 ,@errorText	 nvarchar(4000)										-- message text (for business rule errors)
	 ,@sourceCount int															-- count of rows in the source table
	 ,@targetCount int															-- count of rows in the target table
	 ,@OFF				 bit					 = cast(0 as bit)		-- constant for bit = 0
	 ,@ON					 bit					 = cast(1 as bit);	-- constant for bit = 1

	declare @setup table
	(
		ID							int					 identity(1, 1)
	 ,FileFormatSCD		varchar(8)	 not null
	 ,FileFormatLabel nvarchar(35) not null
	 ,IsDefault				bit					 not null
	);

	begin try

		insert
			@setup
		(
			FileFormatSCD
		 ,FileFormatLabel
		 ,IsDefault
		)
		values
		(
			'.XLSX', N'Microsoft Excel (version 2007+)', @ON
		)
		 ,(
				'.XML', N'XML Document',  @OFF
			)
		 ,(
				'.CSV', N'Comma Separated Values (Text)', @OFF
			)
		 ,(
				'.TXT', N'Text/Fixed Width', @OFF
			)
		 ,(
				'.PDF', N'Adobe PDF', @OFF
			);

		merge sf.FileFormat target
		using (
						select
							x.FileFormatSCD
						 ,x.FileFormatLabel
						 ,x.IsDefault
						from
							@setup x
					) source
		on target.FileFormatSCD = source.FileFormatSCD
		when not matched by target then insert
																		(
																			FileFormatSCD
																		 ,FileFormatLabel
																		 ,IsDefault
																		 ,CreateUser
																		 ,UpdateUser
																		)
																		values
																		(
																			source.FileFormatSCD, source.FileFormatLabel, source.IsDefault, @SetupUser, @SetupUser
																		)
		when not matched by source then delete;

		-- check count of @setup table and the target table
		-- target should have exactly as many rows as @setup

		select @sourceCount	 = count(1) from @setup ;
		select @targetCount	 = count(1) from sf.FileFormat;

		if isnull(@targetCount, 0) <> @sourceCount
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'SetupNotSynchronized'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'Synchronization of setup codes not complete. Source table count is %1 but target table (%2) count is %3.'
			 ,@Arg1 = @sourceCount
			 ,@Arg2 = 'sf.FileFormat'
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
