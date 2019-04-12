SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pSetup$SF#DefaultEmailTemplate]
	 @SetupUser											nvarchar(75)											      -- user assigned to audit columns
	,@Language                      char(2)                                 -- language to install for
	,@Region                        varchar(10)         										-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup sf.DefaultEmailTemplate data
Notice   : Copyright © 2012 Softworks Group Inc.
Summary  : Updates sf.DefaultEmailTemplate master table with values for system required email templates
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Cory Ng			| Mar	2017			| Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------

This procedure synchronizes the sf.DefaultEmailTemplate table with the settings required by the current version of the application. 
If a record is missing it is added. Where the record exists, NO update is performed because the user can change both the label and
email template used. Default email templates no longer used are deleted from the table. One MERGE statement is used to carryout all 
operations.



<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully. If no child records exist, previous set up data is deleted prior to test.">
		<SQLScript>
		<![CDATA[
		
			delete from sf.DefaultEmailTemplate
			dbcc checkident( 'sf.DefaultEmailTemplate', reseed, 1000000) with NO_INFOMSGS

			exec dbo.pSetup$SF#DefaultEmailTemplate
				 @SetupUser = 'system@alinityapp.com'
				,@Language = 'EN'
				,@Region = 'CA'

			select * from sf.DefaultEmailTemplate

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$SF#DefaultEmailTemplate'
	,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */

set nocount on
																																																																			
begin  

	declare
		 @errorNo                           int = 0                           -- 0 no error, if < 50000 SQL error, else business rule
		,@errorText                         nvarchar(4000)                    -- message text (for business rule errors)
		,@sourceCount                       int                               -- count of rows in the source table
		,@targetCount                       int                               -- count of rows in the target table
		,@ON																bit = cast(1 as bit)							-- constant for boolean comparisons
		,@OFF																bit = cast(0 as bit)							-- constant for boolean comparisons
		,@unAssigned												nvarchar(4000)										-- tracks unassigned report names

	begin try

		-- stage the data to be inserted into a temporary table

		declare
			@setup											table
			(
				 ID													int						identity(1,1)
				,DefaultEmailTemplateSCD		varchar(10)		not null
				,DefaultEmailTemplateLabel	nvarchar(35)	not null
				,EmailTemplateSID						int						not null
			)

		-- insert page report assignments into the setup table in a single statement

		insert 
			@setup
			(
				 DefaultEmailTemplateSCD	
				,DefaultEmailTemplateLabel
				,EmailTemplateSID											
			)
		values
       ('SUP.INVITE'	,N'Supervisor invitation'		,(select et.EmailTemplateSID from sf.EmailTemplate et where et.EmailTemplateLabel = 'Supervisor Invitation'))
      ,('REG.INVITE'	,N'Registrant confirmation'	,(select et.EmailTemplateSID from sf.EmailTemplate et where et.EmailTemplateLabel = 'Applicant Invitation'))
      ,('PASS.RESET'	,N'Password reset'					,(select et.EmailTemplateSID from sf.EmailTemplate et where et.EmailTemplateLabel = 'Password Reset Confirmation'))
	  merge
      sf.DefaultEmailTemplate target
		using
    (
      select
				 x.DefaultEmailTemplateSCD	
				,x.DefaultEmailTemplateLabel
				,x.EmailTemplateSID	
				,@SetupUser CreateUser
				,@SetupUser	UpdateUser			       
			from 
				@setup x
    ) source
    on 
      target.DefaultEmailTemplateSCD = source.DefaultEmailTemplateSCD
  	when not matched by target then
	    insert 
      (
				 DefaultEmailTemplateSCD	
				,DefaultEmailTemplateLabel
				,EmailTemplateSID	
				,CreateUser
				,UpdateUser
      ) 
      values
	    (
				 source.DefaultEmailTemplateSCD	
				,source.DefaultEmailTemplateLabel
        ,source.EmailTemplateSID	
        ,@SetupUser
        ,@SetupUser
      )
    when not matched by source then
      delete
    ;
			
	end try

	begin catch
		exec @errorNo = sf.pErrorRethrow
	end catch

	return(@errorNo)

end
GO
