SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pSetup$SF#CardType]
	 @SetupUser											nvarchar(75)											      -- user assigned to audit columns
	,@Language                      char(2)                                 -- language to install for
	,@Region                        varchar(10)         										-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup sf.CardType data
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : Updates the (sf) Form Status master table with starting values for the application
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Kris Dawson	| Feb		2018    | Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------
This procedure synchronizes the sf.CardType table with the settings required by the current version of the application. 
If a record is missing it is added. Where the record exists, it is set to current values. Card types no longer used are
deleted from the table. One MERGE statement is used to carryout all operations.


Example:
--------

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully.">
		<SQLScript>
		<![CDATA[
		
			exec dbo.pSetup$SF#CardType
				 @SetupUser = 'system@alinityapp.com'
				,@Language = 'EN'
				,@Region = 'CA'

			select * from sf.CardType

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$SF#CardType'
	,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */

set nocount on
																																																																			
begin  

	declare
		 @errorNo                           int = 0                           -- 0 no error, if < 50000 SQL error, else business rule
		,@errorText                         nvarchar(4000)                    -- message text (for business rule errors)
		,@OFF																bit								= cast(0 as bit)
		,@ON																bit								= cast(1 as bit)
		,@sourceCount                       int                               -- count of rows in the source table
		,@targetCount                       int                               -- count of rows in the target table

	declare
		@setup															table
		(
			 ID                               int           identity(1,1)
			,CardTypeSCD								      varchar(25)		not null
			,CardTypeLabel								    nvarchar(35)  not null
			,UsageNotes												nvarchar(max)	not null
		)

	begin try

		insert 
			@setup
		(
			 CardTypeSCD				
			,CardTypeLabel
			,UsageNotes
		) 
		values 
			 ('DIRECTORY'		,N'Member directory'			, N'This card type is used for the public and member directory features in the client portal.')

		merge
			sf.CardType target
		using
		(
			select
				 x.CardTypeSCD				
				,x.CardTypeLabel
				,x.UsageNotes
				,@SetupUser CreateUser
				,@SetupUser	UpdateUser			       
			from 
				@setup x
		) source
		on 
			target.CardTypeSCD = source.CardTypeSCD
		when not matched by target then
			insert 
			(
				 CardTypeSCD				
				,CardTypeLabel
				,UsageNotes
				,CreateUser
				,UpdateUser
			) 
			values
			(
				 source.CardTypeSCD				
				,source.CardTypeLabel
				,source.UsageNotes
				,@SetupUser
				,@SetupUser
			)
		when matched then
			update 
				set 		
				 CardTypeLabel                = source.CardTypeLabel
				,UsageNotes										= source.UsageNotes
				,UpdateUser										= @SetupUser 
		when not matched by source then
			delete
			;  
			
		-- check count of @setup table and the target table
		-- target should have at least as many rows as @setup

		select @sourceCount = count(1) from  @setup
		select @targetCount = count(1) from  sf.CardType

		if isnull(@targetCount,0) <> @sourceCount
		begin

			exec sf.pMessage#Get
				 @MessageSCD    = 'SetupNotSynchronized'
				,@MessageText   = @errorText output
				,@DefaultText   = N'Synchronization of setup codes not complete. Source table count is %1 but target table (%2) count is %3.'
				,@Arg1          = @sourceCount
				,@Arg2          = 'sf.CardType'
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
