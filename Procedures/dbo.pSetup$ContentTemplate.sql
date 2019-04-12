SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pSetup$ContentTemplate]
	 @SetupUser				nvarchar(75)																					-- user assigned to audit columns
	,@Language        char(2)																								-- language to install for
	,@Region					varchar(10)													        				  -- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc   : Setup dbo.ContentTemplate data
Notice  : Copyright © 2012 Alinity Group Inc.
Summary : updates dbo.ContentTemplate master table with starting values for the application
----------------------------------------------------------------------------------------------------------------------------------
History : Author(s)			| Month Year    | Change Summary
				: ------------- |---------------|-----------------------------------------------------------------------------------------
				: Arthur L			| Nov 2015			| Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure synchronizes the dbo.ContentTempalte table with the settings required by the current version of the application. If
a record is missing it is added. Where the record exists, it is set to current values. ContentTemplates no longer used are
deleted from the table. One MERGE statement is used to carryout all operations.

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully. If no child records exist, previous set
	up data is deleted prior to test.">
		<SQLScript>
		<![CDATA[

			delete from dbo.ContentTemplate
			dbcc checkident( 'dbo.ContentTemplate', reseed, 1000000) with NO_INFOMSGS

			exec dbo.pSetup$ContentTemplate
				 @SetupUser = 'system@alinityapp.com'
				,@Language = 'EN'
				,@Region = 'CA'

			select * from dbo.ContentTemplate

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$ContentTemplate'
	,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */

set nocount on

begin

	declare
		 @errorNo                           int = 0                           -- 0 no error, if < 50000 SQL error, else business rule
		,@errorText                         nvarchar(4000)                    -- message text (for business rule errors)
		,@ON																bit							= cast(1 as bit)	-- constant to repeated prevent type conversions
		,@OFF																bit							= cast(0 as bit)	-- constant to repeated prevent type conversions
		,@sourceCount                       int                               -- count of rows in the source table
		,@targetCount                       int                               -- count of rows in the target table

	declare
		@setup															table
		(
			 ID																int							identity(1,1)
			,ContentTemplateSCD								varchar(15)			not null
			,ContentTemplateLabel							nvarchar(35)		not null
			,ContentTemplateData							xml							not null
		)

	begin try

		insert
			@setup
		(
			 ContentTemplateSCD
			,ContentTemplateLabel
			,ContentTemplateData
		)
		values
			('PUBREGCARD.10',	'Public Register Small',				cast('<DataElements><DataElement Name="ContactRegistrantID" Value="1" /><DataElement Name="CurrentRegistrations" Value="1" /><DataElement Name="CurrentPrimaryEmploymentShort" Value="1" /><DataElement Name="CurrentPrimaryEmploymentLong" Value="0" /><DataElement Name="ConditionsExistIndicator" Value="1" /><DataElement Name="ConditionsList" Value="0" /><DataElement Name="SpecializationsExistIndicator" Value="0" /><DataElement Name="SpecializationsList" Value="0" /><DataElement Name="AuthorizedActivitiesExistIndicator" Value="0" /><DataElement Name="AuthorizedActivitiesList" Value="0" /></DataElements>' as xml)),
			('PUBREGCARD.20',	'Public Register Medium',				cast('<DataElements><DataElement Name="ContactRegistrantID" Value="1" /><DataElement Name="CurrentRegistrations" Value="1" /><DataElement Name="CurrentPrimaryEmploymentShort" Value="0" /><DataElement Name="CurrentPrimaryEmploymentLong" Value="1" /><DataElement Name="ConditionsExistIndicator" Value="1" /><DataElement Name="ConditionsList" Value="0" /><DataElement Name="SpecializationsExistIndicator" Value="0" /><DataElement Name="SpecializationsList" Value="0" /><DataElement Name="AuthorizedActivitiesExistIndicator" Value="0" /><DataElement Name="AuthorizedActivitiesList" Value="0" /></DataElements>' as xml)),
			('PUBREGCARD.30',	'Public Register Large',				cast('<DataElements><DataElement Name="ContactRegistrantID" Value="1" /><DataElement Name="CurrentRegistrations" Value="1" /><DataElement Name="CurrentPrimaryEmploymentShort" Value="0" /><DataElement Name="CurrentPrimaryEmploymentLong" Value="1" /><DataElement Name="ConditionsExistIndicator" Value="0" /><DataElement Name="ConditionsList" Value="1" /><DataElement Name="SpecializationsExistIndicator" Value="0" /><DataElement Name="SpecializationsList" Value="1" /><DataElement Name="AuthorizedActivitiesExistIndicator" Value="0" /><DataElement Name="AuthorizedActivitiesList" Value="1" /></DataElements>' as xml)),
			('PUBREG.DETAIL',	'Public Register Detail Page',	cast('<DataElements><DataElement Name="General" Value="1" /><DataElement Name="ContactRegistrantID" Value="1" /><DataElement Name="Demographics" Value="1" /><DataElement Name="Languages" Value="1" /><DataElement Name="Conditions" Value="1" /><DataElement Name="Specializations" Value="1" /><DataElement Name="AuthorizedActivities" Value="1" /><DataElement Name="PreviousLicenses" Value="1" /><DataElement Name="CurrentEmployers" Value="1" /><DataElement Name="PreviousEmployers" Value="1" /></DataElements>' as xml))

		merge
			dbo.ContentTemplate target
		using
		(
			select
				 x.ContentTemplateSCD
				,x.ContentTemplateLabel
				,x.ContentTemplateData
				,@SetupUser								CreateUser
				,@SetupUser								UpdateUser
			from
				@setup x
		) source
		on
			target.ContentTemplateSCD = source.ContentTemplateSCD
		when not matched by target then
			insert
			(
				 ContentTemplateSCD
				,ContentTemplateLabel
				,ContentTemplateData
				,CreateUser
				,UpdateUser
			)
			values
			(
				 source.ContentTemplateSCD
				,source.ContentTemplateLabel
				,source.ContentTemplateData
				,@SetupUser
				,@SetupUser
			)
		when matched then
		 update
				set
				 ContentTemplateSCD			= source.ContentTemplateSCD
				,ContentTemplateLabel		= source.ContentTemplateLabel
				,ContentTemplateData		= source.ContentTemplateData
				,UpdateUser           = @SetupUser
		when not matched by source then
			delete
			;

		-- check count of @setup table and the target table
		-- target should have at least as many rows as @setup

		select @sourceCount = count(1) from  @setup
		select @targetCount = count(1) from  dbo.ContentTemplate

		if isnull(@targetCount,0) < @sourceCount
		begin

			exec sf.pMessage#Get
				 @MessageSCD    = 'SetupCountTooLow'
				,@MessageText   = @errorText output
				,@DefaultText   = N'Insert of some setup records failed. Source table count is %1 but target table (%2) count is only %3. Check "JOIN" conditions.'
				,@Arg1          = @sourceCount
				,@Arg2          = 'dbo.ContentTemplate'
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
