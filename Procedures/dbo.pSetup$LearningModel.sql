SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pSetup$LearningModel]
	 @SetupUser											nvarchar(75)											      -- user assigned to audit columns
	,@Language                      char(2)                                 -- language to install for
	,@Region                        varchar(10)         										-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup Learning Model data
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : Sets dbo.LearningModel master table with values expected by the application
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year  | Change Summary
				 : ------------ | ------------|-------------------------------------------------------------------------------------------
				 : Tim Edlund		| Aug 2017		| Initial Version				 
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------
This procedure synchronizes the dbo.LearningModel table with the settings required by the current version of the application. 
If a record is missing it is added. Where the record exists, it is set to current values. Any extra records - those non longer 
required - are deleted. A single MERGE statement is used to carryout all operations. While descriptions of values in this table can
be updated by configurators and users, records cannot be added or deleted.  The list of SCD values is fixed and cannot be modified.

The procedure uses the SQL multi-row constructor syntax to insert values into a temporary table.

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully.">
		<SQLScript>
		<![CDATA[
		
			exec dbo.pSetup$LearningModel
				 @SetupUser = 'system@alinityapp.com'
				,@Language = 'EN'
				,@Region = 'CA'

			select * from dbo.LearningModel

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$LearningModel'
	,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */

set nocount on
																																																																			
begin  

	declare
		 @errorNo                           int = 0                           -- 0 no error, if < 50000 SQL error, else business rule
		,@errorText                         nvarchar(4000)                    -- message text (for business rule errors)
		,@ON																bit = cast(1 as bit)							-- constant for bit = 1 to reduce repetitive casting
		,@OFF																bit = cast(0 as bit)							-- constant for bit = 0 to reduce repetitive casting
		,@sourceCount                       int                               -- count of rows in the source table
		,@targetCount                       int                               -- count of rows in the target table

	declare
		@setup															table
		(
			 ID                               int           identity(1,1)
			,LearningModelSCD		varchar(15)		not null
			,LearningModelLabel	nvarchar(35)	not null
			,IsDefault									bit		not null
		)

	begin try
	
		insert
			@setup
		(
			 LearningModelSCD		
			,LearningModelLabel	
			,IsDefault									
		)
		values
			 ('CEU'				, N'Continuing Education Units'				, @ON)
			,('ACTIVITY'	, N'Activity Based'										, @OFF)

		merge
			dbo.LearningModel target
		using
		(
			select
				 x.LearningModelSCD		
				,x.LearningModelLabel		
				,x.IsDefault			
			from
				@setup x
		) source
		on 
			target.LearningModelSCD = source.LearningModelSCD
		when not matched by target then
			insert 
			(
					LearningModelSCD		
				,	LearningModelLabel		
				, IsDefault								
				,	CreateUser
				,	UpdateUser
			) 
			values
			(
					source.LearningModelSCD		
				,	source.LearningModelLabel	
				, source.IsDefault									
				,	@SetupUser
				,	@SetupUser
			)
		when not matched by source then
			delete
		;

		-- check count of @setup table and the target table
		-- target should have exactly as many rows as @setup

		select @sourceCount = count(1) from  @setup
		select @targetCount = count(1) from  dbo.LearningModel

		if isnull(@targetCount,0) <> @sourceCount
		begin

			exec sf.pMessage#Get
				 @MessageSCD    = 'SetupNotSynchronized'
				,@MessageText   = @errorText output
				,@DefaultText   = N'Synchronization of setup codes not complete. Source table count is %1 but target table (%2) count is %3.'
				,@Arg1          = @sourceCount
				,@Arg2          = 'dbo.LearningModel'
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
