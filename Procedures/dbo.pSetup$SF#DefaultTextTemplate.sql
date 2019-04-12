SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pSetup$SF#DefaultTextTemplate]
	@SetupUser nvarchar(75) -- user assigned to audit columns
 ,@Language	 char(2)			-- language to install for
 ,@Region		 varchar(10)	-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup sf.DefaultTextTemplate data
Notice   : Copyright © 2012 Softworks Group Inc.
Summary  : Updates sf.DefaultTextTemplate master table with values for system required text templates
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Cory Ng			| Mar	2017			| Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------

This procedure synchronizes the sf.DefaultTextTemplate table with the settings required by the current version of the application. 
If a record is missing it is added. Where the record exists, NO update is performed because the user can change both the label and
text template used. Default text templates no longer used are deleted from the table. One MERGE statement is used to carryout all 
operations.

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully. If no child records exist, previous set up data is deleted prior to test.">
		<SQLScript>
		<![CDATA[
		
			delete from sf.DefaultTextTemplate
			dbcc checkident( 'sf.DefaultTextTemplate', reseed, 1000000) with NO_INFOMSGS

			exec dbo.pSetup$SF#DefaultTextTemplate
				 @SetupUser = 'system@alinityapp.com'
				,@Language = 'EN'
				,@Region = 'CA'

			select * from sf.DefaultTextTemplate

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$SF#DefaultTextTemplate'
	,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare @errorNo int = 0; -- 0 no error, if < 50000 SQL error, else business rule

	begin try

		-- stage the data to be inserted into a temporary table

		declare @setup table
		(
			ID											 int					not null identity(1, 1)
		 ,DefaultTextTemplateSCD	 varchar(10)	not null
		 ,DefaultTextTemplateLabel nvarchar(35) not null
		 ,TextTemplateSID					 int					not null
		);

		-- insert page report assignments into the setup table in a single statement

		insert
			@setup
		(
			DefaultTextTemplateSCD
		 ,DefaultTextTemplateLabel
		 ,TextTemplateSID
		)
		values
-- SQL Prompt formatting off
       ('SUP.INVITE'	,N'Supervisor invitation'		,(select et.TextTemplateSID from sf.TextTemplate et where et.TextTemplateLabel = N'Supervisor Invitation'))
      ,('REG.INVITE'	,N'Registrant confirmation'	,(select et.TextTemplateSID from sf.TextTemplate et where et.TextTemplateLabel = N'Applicant Invitation'))
      ,('PASS.RESET'	,N'Password reset'					,(select et.TextTemplateSID from sf.TextTemplate et where et.TextTemplateLabel = N'Password Reset Confirmation'))
-- SQL Prompt formatting on
		merge sf.DefaultTextTemplate target
		using (
						select
							x.DefaultTextTemplateSCD
						 ,x.DefaultTextTemplateLabel
						 ,x.TextTemplateSID
						 ,@SetupUser CreateUser
						 ,@SetupUser UpdateUser
						from
							@setup x
					) source
		on target.DefaultTextTemplateSCD = source.DefaultTextTemplateSCD
		when not matched by target then insert
																		(
																			DefaultTextTemplateSCD
																		 ,DefaultTextTemplateLabel
																		 ,TextTemplateSID
																		 ,CreateUser
																		 ,UpdateUser
																		)
																		values
																		(
																			source.DefaultTextTemplateSCD, source.DefaultTextTemplateLabel, source.TextTemplateSID, @SetupUser, @SetupUser
																		)
		when not matched by source then delete;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);

end;
GO
