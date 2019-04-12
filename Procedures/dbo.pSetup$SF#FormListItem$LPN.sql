SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pSetup$SF#FormListItem$LPN]
	 @SetupUser											nvarchar(75)											      -- user assigned to audit columns
	,@Language                      char(2)                                 -- language to install for
	,@Region                        varchar(10)         										-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup sf.FormListItem data for LPNs
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : Updates the (sf) Form Status master table with starting values for the application
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Cory Ng			| Jul		2018    | Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------
NOTE: This setup procedure does not run for all clients, this procedure needs to be called from the client's setup scripts as the
values are specific to the profession.

This procedure synchronizes the sf.FormListItem table with the settings required by the current version of the application. 
If a record is missing it is added. Where the record exists, it is set to current values. Form list items are not deleted 
however as client-specific form list items can be added to this table.


Example:
--------

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully.">
		<SQLScript>
		<![CDATA[
		
			exec dbo.pSetup$SF#FormListItem$LPN
				 @SetupUser = 'system@alinityapp.com'
				,@Language = 'EN'
				,@Region = 'CA'

			select * from sf.FormListItem

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$SF#FormListItem$LPN'
	,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */

set nocount on
																																																																			
begin  

	declare
		 @errorNo                           int = 0                           -- 0 no error, if < 50000 SQL error, else business rule
		,@errorText                         nvarchar(4000)                    -- message text (for business rule errors)
		,@sourceCount                       int                               -- count of rows in the source table
		,@targetCount                       int                               -- count of rows in the target table
		,@formListSID												int																-- form list of the item

	declare
		@setup															table
		(
			 ID                               int           identity(1,1)
			,FormListSID								      int						not null
			,FormListItemCode									nvarchar(15)  not null
			,FormListItemLabel								nvarchar(35)  not null
			,ToolTip													nvarchar(500) null
		)

	begin try

		select
			@formListSID = fl.FormListSID
		from
			sf.FormList fl
		where
			fl.FormListCode = 'S!CIHI.ORGTYPE'

		insert 
			@setup
		(
			 FormListSID				
			,FormListItemCode
			,FormListItemLabel
			,ToolTip
		) 
		values 
			  (@formListSID	,N'1'	, N'Hospital'														, N'Hospital (general, maternal,pediatric, psychiatric)')
			 ,(@formListSID	,N'2'	, N'Mental health centre'								, N'Mental health centre')
			 ,(@formListSID	,N'3'	, N'Nursing station (outpost or clinic)', N'Nursing station (outpost or clinic)')
			 ,(@formListSID	,N'4'	, N'Rehabilitation/convalescent centre'	, N'Rehabilitation/convalescent centre')
			 ,(@formListSID	,N'5'	, N'Nursing home/long-term care'				, N'Nursing home/long-term care facility')
			 ,(@formListSID	,N'6'	, N'Home care agency'										, N'Home care agency')
			 ,(@formListSID	,N'7'	, N'Community health centre'						, N'Community health centre')
			 ,(@formListSID	,N'8'	, N'Business/industry/occupational'			, N'Business/industry/occupational health office')
			 ,(@formListSID	,N'9'	, N'Private nursing/private duty'				, N'Private nursing agency/private duty')
			 ,(@formListSID	,N'10', N'Self-employed'											, N'Self-employed')
			 ,(@formListSID	,N'11', N'Physician''s office/family practice', N'Physician''s office/family practice unit')
			 ,(@formListSID	,N'12', N'Educational institution'						, N'Educational institution')
			 ,(@formListSID	,N'13', N'Association/government'							, N'Association/government')
			 ,(@formListSID	,N'14', N'Other'															, N'Other')
			 ,(@formListSID	,N'17', N'Public health department/unit'			, N'Public health department/unit')
			 ,(@formListSID	,N'99', N'Not stated'													, N'Not stated')

		select
			@formListSID = fl.FormListSID
		from
			sf.FormList fl
		where
			fl.FormListCode = 'S!CIHI.CRED'

		insert 
			@setup
		(
			 FormListSID				
			,FormListItemCode
			,FormListItemLabel
			,ToolTip
		) 
		values 
			  (@formListSID	,N'1', N'Diploma/certificate'	, N'Diploma/certificate')
			 ,(@formListSID	,N'2', N'Baccalaureate'				, N'Baccalaureate')
			 ,(@formListSID	,N'3', N'Master''s'						, N'Master''s')
			 ,(@formListSID	,N'4', N'Doctorate'						, N'Doctorate')
			 ,(@formListSID	,N'5', N'None'								, N'None')
			 ,(@formListSID	,N'6', N'Equivalency'					, N'Equivalency')
			 ,(@formListSID	,N'9', N'Not stated'					, N'Not stated')

		select
			@formListSID = fl.FormListSID
		from
			sf.FormList fl
		where
			fl.FormListCode = 'S!CIHI.EMPSTA'

		insert 
			@setup
		(
			 FormListSID				
			,FormListItemCode
			,FormListItemLabel
			,ToolTip
		) 
		values 
			  (@formListSID	,N'10', N'Employed as LPN Regular'					, N'Employed in practical nursing on a regular basis')
			 ,(@formListSID	,N'11', N'Employed as LPN Casual'						, N'Employed in practical nursing on a casual basis')
			 ,(@formListSID	,N'20', N'Employed Seeking LPN Position'		, N'Employed in other than practical nursing and seeking employment in practical nursing')
			 ,(@formListSID	,N'21', N'Employed Not Seeking LPN Position', N'Employed in other than practical nursing and not seeking employment in practical nursing')
			 ,(@formListSID	,N'30', N'Not Employed Seeking LPN Position', N'Not employed and seeking employment in practical nursing')
			 ,(@formListSID	,N'31', N'Not Employed Not Seeking LPN'			, N'Not employed and not seeking employment in practical nursing')
			 ,(@formListSID	,N'99', N'Not stated'												, N'Not stated')
			

		merge
			sf.FormListItem target
		using
		(
			select
				 x.FormListSID
				,x.FormListItemCode
				,x.FormListItemLabel
				,x.ToolTip
				,@SetupUser CreateUser
				,@SetupUser	UpdateUser			       
			from 
				@setup x
		) source
		on 
			target.FormListSID = source.FormListSID and target.FormListItemCode = source.FormListItemCode
		when not matched by target then
			insert 
			(
				 FormListSID
				,FormListItemCode				
				,FormListItemLabel
				,ToolTip
				,CreateUser
				,UpdateUser
			) 
			values
			(
				 source.FormListSID
				,source.FormListItemCode
				,source.FormListItemLabel
				,source.ToolTip
				,@SetupUser
				,@SetupUser
			)
		when matched then
			update 
				set 		
				 ToolTip										= source.ToolTip
				,UpdateUser									= @SetupUser 
			;  
			
		-- check count of @setup table and the target table
		-- target should have at least as many rows as @setup

		select @sourceCount = count(1) from  @setup
		select @targetCount = count(1) from  sf.FormListItem

		if isnull(@targetCount,0) < @sourceCount
		begin

			exec sf.pMessage#Get
				 @MessageSCD    = 'SetupNotSynchronized'
				,@MessageText   = @errorText output
				,@DefaultText   = N'Synchronization of setup codes not complete. Source table count is %1 but target table (%2) count is %3.'
				,@Arg1          = @sourceCount
				,@Arg2          = 'sf.FormListItem'
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
