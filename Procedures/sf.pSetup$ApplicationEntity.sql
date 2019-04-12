SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sf.[pSetup$ApplicationEntity]
	@SetupUser nvarchar(75)				-- user assigned to audit insert and update audit columns
 ,@Language	 char(2)						-- language to install for
 ,@Product	 varchar(10) = null -- Synoptec or Alinity - controls data source setting
as
/*********************************************************************************************************************************
Procedure	: pSetup$ApplicationEntity
Notice		: Copyright © 2014 Softworks Group Inc.
Summary		: Ensures the sf.ApplicationEntity table is updated with current list of tables in the database
History		: Author(s)  		| Month Year			| Change Summary
					: --------------|-----------------|-------------------------------------------------------------------------------------
					: Tim Edlund    | March 2012      |	Initial version
					: Tim Edlund		| July	2013			| Updated to include all tables in the RPT schema as entities.  This was done to
																							ensure these tables are available for table definition reports.
						Tim Edlund		| Sep	2014				| Limited the length of the derived entity SCD and Name to 50 characters to match
																							table definition. This avoids truncation errors that were otherwise occurring on
																							long RPT schema table names. If the names are not unique within those 50 characters
																							however, a unique key violation will occur.	
						Tim Edlund		| May 2015				| Added @Product parameter and logic to set data source bits on for selected views
																							associated with the Synoptec and Alinity products (only).
						Tim Edlund		| Mar 2017				| Added dbo.vContact (view) as entity for the Alinity product branch only.

Comments	
--------
This procedure is run during setup to ensure the sf.ApplicationEntity table has a record for all current (non-temporary) tables 
defined in the database.  Application entities are a required reference for many tables in the application. 

The routine uses a merge statement to insert missing values, to update the entity name values on existing records, and to
remove records that no longer reflect actual tables from the application database. If a FK exists for a row being deleted,
the operation will fail. Deletion errors require investigation from the help desk since a reference in the application must be out 
of date.

The code for entities is <SchemaName>.<TableName> . The name for entities is based on putting spaces where casing changes
in the table name.  If the schema is NOT dbo then it is added in parentheses at the end of the name.

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully. If no child records exist, previous 
	set up data is deleted prior to test.">
		<SQLScript>
		<![CDATA[
		
			exec sf.pSetup$ApplicationEntity
				 @SetupUser = 'system@softworksgroup.com'
				,@Language = 'EN'	

			select * from sf.ApplicationEntity

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'sf.pSetup$ApplicationEntity'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

set nocount on;

begin

	declare
		@errorNo int = 0								-- 0 no error, <50000 SQL error, else business rule
	 ,@ON			 bit = cast(1 as bit);	-- constant for bit comparison and assignments

	begin try

		merge sf.ApplicationEntity target
		using
		(
			select
				x.ApplicationEntitySCD
			 ,x.ApplicationEntityName
			from
		(
			select
				left(t.SchemaAndTableName, 50)																						 ApplicationEntitySCD -- limit length to 50 to avoid truncation error
			 ,left(replace(sf.fObjectNameSpaced(t.SchemaAndTableName), '(dbo)', ''), 50) ApplicationEntityName
			from
				sf.vTable t
			where
				t.TableName			 <> N'sysdiagrams' and t.TableName <> N'systranschemas' -- exclude SSMS modeling tables 
				and t.TableName not like N'[_]%' -- exclude tables starting with _	(underscore)
				and t.SchemaName <> N'cdc'	-- exclude change data control (audit) tables
			union
			select
				'dbo.Contact' ApplicationEntitySCD
			 ,'Contact'			ApplicationEntityName
			union
			select
				'dbo.RegistrantAudit#Search' ApplicationEntitySCD
			 ,'Audit Search'							 ApplicationEntityName
			union
			select
				'dbo.RegistrantLearningPlan#Search' ApplicationEntitySCD
			 ,'Learning Plan Search'							ApplicationEntityName
      union
      select 
          'dbo.ProfileUpdate#Search'        ApplicationEntitySCD
         ,'Profile Update Search'           ApplicationEntityName

		) x
		) source
		on target.ApplicationEntitySCD = source.ApplicationEntitySCD
		when not matched by target then insert (ApplicationEntitySCD, ApplicationEntityName, CreateUser, UpdateUser)
																		values
																		(
																			source.ApplicationEntitySCD, source.ApplicationEntityName, @SetupUser, @SetupUser
																		)
		when matched then update set
												ApplicationEntityName = source.ApplicationEntityName
											 ,UpdateUser = @SetupUser
		when not matched by source then delete;

		-- if this is a product database, turn on the data source
		-- bits for selected entities - do NOT enable for sf.PersonEmailMessage
		-- which is the default data source and must not appear in UI drop-downs!

		if @Product = 'Synoptec'
		begin

			update
				sf.ApplicationEntity
			set
				IsMergeDataSource = @ON
			where
				(
					ApplicationEntitySCD like 'rpt.%'
					or ApplicationEntitySCD in ('sf.ApplicationUser', 'sf.Task', 'dbo.Episode', 'dbo.EpisodeAppointment', 'dbo.Provider')
				)
				and IsMergeDataSource <> @ON; -- note: do not turn others OFF to allow entities to be 
		-- enabled on a config-specific basis
		end;
		else if @Product = 'Alinity'
		begin

			update
				sf.ApplicationEntity
			set
				IsMergeDataSource = @ON
			where
				ApplicationEntitySCD in ('sf.Task', 'sf.PersonGroupMember', 'dbo.RegistrantAudit#Search', 'dbo.RegistrantLearningPlan#Search'
																 ,'dbo.vProfileUpdate#Search', 'dbo.Registration', 'dbo.Invoice', 'dbo.Payment', 'dbo.PAPSubscription', 'dbo.Contact'
																 ,'dbo.ComplaintContact', 'dbo.Complaint'
																)
				and IsMergeDataSource <> @ON;

		end;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);

end;
GO
