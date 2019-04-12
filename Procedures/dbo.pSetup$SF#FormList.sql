SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pSetup$SF#FormList]
	 @SetupUser											nvarchar(75)											      -- user assigned to audit columns
	,@Language                      char(2)                                 -- language to install for
	,@Region                        varchar(10)         										-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup sf.FormList data
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : Updates the (sf) Form Status master table with starting values for the application
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Cory Ng			| Jul		2018    | Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------
This procedure synchronizes the sf.FormList table with the settings required by the current version of the application. 
If a record is missing it is added. Where the record exists, it is set to current values. Form lists are not deleted 
however as client-specific form lists can be added to this table.


Example:
--------

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully.">
		<SQLScript>
		<![CDATA[
		
			exec dbo.pSetup$SF#FormList
				 @SetupUser = 'system@alinityapp.com'
				,@Language = 'EN'
				,@Region = 'CA'

			select * from sf.FormList

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$SF#FormList'
	,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */

set nocount on
																																																																			
begin  

	declare
		 @errorNo                           int = 0                           -- 0 no error, if < 50000 SQL error, else business rule
		,@errorText                         nvarchar(4000)                    -- message text (for business rule errors)
		,@sourceCount                       int                               -- count of rows in the source table
		,@targetCount                       int                               -- count of rows in the target table

	declare
		@setup															table
		(
			 ID                               int           identity(1,1)
			,FormListCode								      varchar(15)		not null
			,FormListLabel								    nvarchar(35)  not null
			,ToolTip													nvarchar(500)	not null
		)

	begin try

		insert 
			@setup
		(
			 FormListCode				
			,FormListLabel
			,ToolTip
		) 
		values 
			  ('S!CIHI.ORGTYPE'		,N'CIHI org types'					, N'This list contains CIHI org types specific to the college.')
			 ,('S!CIHI.CRED'			,N'CIHI credentials'				, N'This list contains CIHI credentials specific to the college.')
			 ,('S!CIHI.EMPSTA'		,N'CIHI employment status'	, N'This list contains CIHI employment types specific to the college.')

		merge
			sf.FormList target
		using
		(
			select
				 x.FormListCode
				,x.FormListLabel
				,x.ToolTip
				,@SetupUser CreateUser
				,@SetupUser	UpdateUser			       
			from 
				@setup x
		) source
		on 
			target.FormListCode = source.FormListCode
		when not matched by target then
			insert 
			(
				 FormListCode				
				,FormListLabel
				,ToolTip
				,CreateUser
				,UpdateUser
			) 
			values
			(
				 source.FormListCode
				,source.FormListLabel
				,source.ToolTip
				,@SetupUser
				,@SetupUser
			)
		when matched then
			update 
				set 		
				 FormListLabel					    = source.FormListLabel
				,ToolTip										= source.ToolTip
				,UpdateUser									= @SetupUser 
		;
			
		-- check count of @setup table and the target table
		-- target should have at least as many rows as @setup

		select @sourceCount = count(1) from  @setup
		select @targetCount = count(1) from  sf.FormList

		if isnull(@targetCount,0) < @sourceCount
		begin

			exec sf.pMessage#Get
				 @MessageSCD    = 'SetupNotSynchronized'
				,@MessageText   = @errorText output
				,@DefaultText   = N'Synchronization of setup codes not complete. Source table count is %1 but target table (%2) count is %3.'
				,@Arg1          = @sourceCount
				,@Arg2          = 'sf.FormList'
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
