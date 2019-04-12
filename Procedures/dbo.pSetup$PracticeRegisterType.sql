SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pSetup$PracticeRegisterType]
	 @SetupUser											nvarchar(75)											      -- user assigned to audit columns
	,@Language                      char(2)                                 -- language to install for
	,@Region                        varchar(10)         										-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup Practice Register Type data
Notice   : Copyright © 2012 Softworks Group Inc.
Summary  : Sets dbo.PracticeRegisterType master table with values expected by the application
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year  | Change Summary
				 : ------------ | ------------|-------------------------------------------------------------------------------------------
				 : Tim Edlund		| Aug 2017		| Initial Version				 
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------
This procedure synchronizes the dbo.PracticeRegisterType table with the settings required by the current version of the application. 
If a record is missing it is added. Where the record exists, it is set to current values. Any extra records - those non longer 
required - are deleted. A single MERGE statement is used to carryout all operations. While descriptions of values in this table can
be updated by configurators and users, records cannot be added or deleted.  The list of SCD values is fixed and cannot be modified.

The procedure uses the SQL multi-row constructor syntax to insert values into a temporary table.

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully.">
		<SQLScript>
		<![CDATA[
		
			exec dbo.pSetup$PracticeRegisterType
				 @SetupUser = 'system@alinityapp.com'
				,@Language = 'EN'
				,@Region = 'CA'

			select * from dbo.PracticeRegisterType

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$PracticeRegisterType'
	,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */

set nocount on
																																																																			
begin  

	declare
		 @errorNo                           int = 0                           -- 0 no error, if < 50000 SQL error, else business rule
		,@errorText                         nvarchar(4000)                    -- message text (for business rule errors)
		,@ON																bit = cast(1 as bit)							-- constant for bit = 1
		,@OFF																bit = cast(0 as bit)							-- constant for bit = 0
		,@sourceCount                       int                               -- count of rows in the source table
		,@targetCount                       int                               -- count of rows in the target table

	declare
		@setup															table
		(
			 ID                               int           identity(1,1)
			,PracticeRegisterTypeSCD		varchar(15)			not null
			,PracticeRegisterTypeLabel	nvarchar(35)		not null
			,IsDefault									bit							not null
			,Description								nvarchar(500)		not null
		)

	begin try
	
		insert
			@setup
		(
			 PracticeRegisterTypeSCD		
			,PracticeRegisterTypeLabel	
			,IsDefault				
			,Description
		)
		values
			 ('FIXED.ANNUAL'		, N'Fixed Term Annual'		, @ON	,'This type applies where the practice register has registrations that expire on the same date each year and have a one year term.')
			,('TERM.PERMIT'			, N'Term Permit'					, @OFF,'This type applies where the registrations on the register do not expire on the same date every year but expire a given number of months after being assigned. This most often applies to term permits - e.g. a "3 Month Temporary Permit"')
			,('PERPETUAL'				, N'Perpetual (no expiry)', @OFF,'This type applies where the registrations on the register do not expire and do not require renewal. This may apply to members in a retired status or where they are on indefinite leave such as long-term disability.')

		merge
			dbo.PracticeRegisterType target
		using
		(
			select
				 x.PracticeRegisterTypeSCD		
				,x.PracticeRegisterTypeLabel		
				,x.IsDefault			
				,x.Description
			from
				@setup x
		) source
		on 
			target.PracticeRegisterTypeSCD = source.PracticeRegisterTypeSCD
		when not matched by target then
			insert 
			(
					PracticeRegisterTypeSCD		
				,	PracticeRegisterTypeLabel		
				, IsDefault	
				, Description
				,	CreateUser
				,	UpdateUser
			) 
			values
			(
					source.PracticeRegisterTypeSCD		
				,	source.PracticeRegisterTypeLabel	
				, source.IsDefault	
				,	source.Description
				,	@SetupUser
				,	@SetupUser
			)
		when not matched by source then
			delete
		;

		-- check count of @setup table and the target table
		-- target should have exactly as many rows as @setup

		select @sourceCount = count(1) from  @setup
		select @targetCount = count(1) from  dbo.PracticeRegisterType

		if isnull(@targetCount,0) <> @sourceCount
		begin

			exec sf.pMessage#Get
				 @MessageSCD    = 'SetupNotSynchronized'
				,@MessageText   = @errorText output
				,@DefaultText   = N'Synchronization of setup codes not complete. Source table count is %1 but target table (%2) count is %3.'
				,@Arg1          = @sourceCount
				,@Arg2          = 'dbo.PracticeRegisterType'
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
