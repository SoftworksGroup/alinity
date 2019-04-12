SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pApplicationEntity#GetSelectList]
	 @ApplicationEntitySID						int							= null								-- identifier of the application page
	,@ApplicationEntitySCD						varchar(50)			= null								-- system code for the application page
	
as
/*********************************************************************************************************************************
Procedure : Application Entity Get Select List
Notice    : Copyright © 2015 Softworks Group Inc.
Summary   : Returns a dataset to support a select list on the front end for a given entity
History   : Author(s)			| Month Year		| Change Summary
					: -------------	|-------------	|-----------------------------------------------------------------------------------------
					: Richard K			| Aug 2015			| Initial version

Comments
--------
This procedure will return a table containing a "Text" column and a "Value" column.

Assumptions;
- Name or Label columns follow the standard convention of [TableName] + "Name"/"Label"
- If an entity has both a name and an entity field, the name field is preferred (preferred order field).
- the value field assumes convention of [TableName] + "SID"
- If the entity has an IsActive column, then the query will check for IsActive = @ON


<TestHarness>
	<Test Name="Test sf filetype table" IsDefault="true" Description="Get select list data for filetype">
		<SQLScript>
			<![CDATA[
			
				exec pApplicationEntity#GetSelectList @ApplicationEntitySCD = 'sf.FileType'

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1"/>
			<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="1" Value="Test0001"/>      
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>

</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.pApplicationEntity#GetSelectList'

-------------------------------------------------------------------------------------------------------------------------------- */

set nocount on

begin

	declare
		 @errorNo												int = 0																-- 0 no error, <50000 SQL error, else business rule
		,@errorText											nvarchar(4000)												-- message text (for business rule errors)
		,@blankParm											nvarchar(100)													-- error checking buffer for required parameters
		,@ON														bit = cast(1 as bit)									-- used on bit comparisons to avoid multiple casts
		,@OFF														bit = cast(0 as bit)									-- used on bit comparisons to avoid multiple casts			
		,@schemaName										varchar(50)														
		,@entityName										varchar(50)
		,@textColumn										varchar(100)
		,@valueColumn										varchar(100)
		,@query													nvarchar(max)
		,@hasIsActive										bit										= cast(0 as bit)

	declare @textColumns table
		(
			ColumnText						varchar(100)
			,OrderPreference			int
		)

	begin try	

		if @ApplicationEntitySID is null and @ApplicationEntitySCD is null 
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@ApplicationEntitySID or @ApplicationEntitySCD'

			raiserror(@errorText, 18, 1)

		end		

		if @ApplicationEntitySCD is null and @ApplicationEntitySID is not null
		begin
			
			if not exists (select 1 from sf.ApplicationEntity where ApplicationEntitySID = @ApplicationEntitySID)
			begin

				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'Application Entity SID'
					,@Arg2        = @ApplicationEntitySID

				raiserror(@errorText, 18, 1)

			end
			else
			begin

				select
					@ApplicationEntitySCD = ApplicationEntitySCD
				from
					sf.ApplicationEntity
				where
					ApplicationEntitySID = @ApplicationEntitySID

			end

		end

		if not exists (select 1 from sf.ApplicationEntity where ApplicationEntitySCD = @ApplicationEntitySCD)
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RecordNotFound'
				,@MessageText = @errorText output
				,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
				,@Arg1        = 'Application Entity SCD'
				,@Arg2        = @ApplicationEntitySCD

			raiserror(@errorText, 18, 1)

		end

		-- TODO Richard Aug 2015: determine if we're pulling from a view or a table.
		-- as we do allow views to be a sudo-entity in Alinity 
		select @entityName = BaseTableName from sf.vApplicationEntity where ApplicationEntitySCD = @ApplicationEntitySCD

		insert @textColumns 
		(
			ColumnText
			,OrderPreference
		)
		select 
			ColumnName 
			,case when (ColumnName = @entityName + 'Name') then 
				1 
			else case when (ColumnName = @entityName + 'Label') then 
				2 
			else 
				3 end end OrderPreference
		from
			sf.vTableColumn
		where
			SchemaAndTableName = @ApplicationEntitySCD
		and
			ColumnName = @entityName + 'Name'
			or
			ColumnName = @entityName + 'Label'
		
		if exists (select 1 from sf.vTableColumn where SchemaAndTableName = @ApplicationEntitySCD and ColumnName = 'IsActive')
		begin

			set @hasIsActive = @ON

		end

		select 
			top 1 
			@TextColumn = ColumnText
			,@ValueColumn = @entityName + 'SID' 
		from 
			@textColumns 
		order by 
			OrderPreference

		if @TextColumn is null or @ValueColumn is null
		begin
		
			exec sf.pMessage#Get
				 @MessageSCD  = 'RequiredValueBlank'
				,@MessageText = @errorText output
				,@DefaultText = N'A required value has been left blank (%1).'
				,@Arg1        = ', could not find a matching name, label or sid column in the entity.'

			raiserror(@errorText, 18, 1)

		end
				
		set @query = 'select ' + @TextColumn + ' ''Text'', ' + @ValueColumn + ' ''Value'' from ' + @ApplicationEntitySCD + case when @hasIsActive = @ON then ' where IsActive = cast(1 as bit)' else '' end

		execute sp_executesql @query

	end try

	begin catch
		exec @errorNo = sf.pErrorRethrow																			-- catch the error, rollback if pending, and re-throw
	end catch

	return(@errorNo)
end
GO
