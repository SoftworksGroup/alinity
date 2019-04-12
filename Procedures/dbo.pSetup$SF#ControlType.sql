SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pSetup$SF#ControlType]
	 @SetupUser					nvarchar(75)																				-- user assigned to audit columns
	,@Language          char(2)																							-- language to install for
	,@Region            varchar(10)																					-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup sf.ControlType data
Notice   : Copyright © 2015 Softworks Group Inc.
Summary  : Updates sf.ControlType master table with values required by the application
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Tim Edlund		| Aug 2017			| Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------
This procedure synchronizes the sf.ControlType table with the settings required by the current version of the application. 
If a record is missing it is added. File types no longer used are deleted from the table. One MERGE statement is used to carryout 
all operations.

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="The basic operation of the procedure is tested.">
		<SQLScript>
		<![CDATA[
			
			exec dbo.pSetup$SF#ControlType
				 @SetupUser	= 'system@product.com'
				,@Language	= 'EN'
				,@Region		= 'CA'

			select * from sf.ControlType

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:03" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName			= 'dbo.pSetup$SF#ControlType'
	,@DefaultTestOnly	= 1

------------------------------------------------------------------------------------------------------------------------------- */

set nocount on
																																																																			
begin  

	declare
		 @errorNo                           int = 0                           -- 0 no error, if < 50000 SQL error, else business rule
		,@errorText                         nvarchar(4000)                    -- message text (for business rule errors)
		,@sourceCount                       int                               -- count of rows in the source table
		,@targetCount                       int                               -- count of rows in the target table
		,@OFF																bit = cast(0 as bit)							-- constant for bit = 0
		,@ON																bit = cast(1 as bit)							-- constant for bit = 1

	declare
		@setup															table
		(
				ID                              int           identity(1,1)
			,	ControlTypeSCD									varchar(15)		not null
			,	ControlTypeLabel								nvarchar(35)	not null
			,	IsDefault												bit						not null

		)

	begin try

		insert
			@setup
			(
				 ControlTypeSCD
				,ControlTypeLabel
				,IsDefault
			)
			values
				 ('TEXTBOX'		, N'TextBox'													,@ON)
				,('TEXTAREA'	, N'TextArea'													,@OFF)
				,('DATEPICKER', N'DatePicker'												,@OFF)
				,('NUMERIC'		, N'Numeric'													,@OFF)
				,('CHECKBOX'	, N'CheckBox'													,@OFF)

		merge
			sf.ControlType target
		using
		(
			select
				 x.ControlTypeSCD
				,x.ControlTypeLabel
				,x.IsDefault
			from
				@setup x
		) source
		on 
			target.ControlTypeSCD = source.ControlTypeSCD
		when not matched by target then
			insert 
			(
				 ControlTypeSCD
				,ControlTypeLabel
				,IsDefault
				,CreateUser
				,UpdateUser
			) 
			values
			(
				 source.ControlTypeSCD
				,source.ControlTypeLabel
				,source.IsDefault
				,@SetupUser
				,@SetupUser
			)
		when matched then
			update 
				set 		
				 IsDefault													= source.IsDefault
				,UpdateUser												= @SetupUser 
		when not matched by source then
			delete
		;

		-- check count of @setup table and the target table
		-- target should have exactly as many rows as @setup

		select @sourceCount = count(1) from  @setup
		select @targetCount = count(1) from  sf.ControlType

		if isnull(@targetCount,0) <> @sourceCount
		begin

			exec sf.pMessage#Get
				 @MessageSCD    = 'SetupNotSynchronized'
				,@MessageText   = @errorText output
				,@DefaultText   = N'Synchronization of setup codes not complete. Source table count is %1 but target table (%2) count is %3.'
				,@Arg1          = @sourceCount
				,@Arg2          = 'sf.ControlType'
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
