SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pSetup$SF#TextSender]
	 @SetupUser											nvarchar(75)														-- user assigned to audit columns
	,@Language											char(2)																	-- language to install for
	,@Region												varchar(10)															-- locale (country) to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup sf.TextSender data
Notice   : Copyright © 2015 Softworks Group Inc.
Summary  : Inserts starting values into sf.TextSender if no records exist in the table
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)		| Month Year	| Change Summary
				 : ------------ | ----------- |-------------------------------------------------------------------------------------------
				 : Cory Ng		  | Jul		2016	| Initial Version
----------------------------------------------------------------------------------------------------------------------------------

Comments  
--------
This procedure is responsible for creating sample data in the sf.TextSender table. The data is only inserted if the table
contains no records.  Otherwise, the procedure makes no changes to the database.  The table will contain no records when the 
product is first installed.

Keep in mind the pSetup (parent) procedure is run not only for installation, but also after each upgrade. This ensures any new
tables receive starting values. Tables like this one may be setup with whatever data makes sense to the end user and, therefore,
must not be modified during upgrades. This is achieved by avoiding execution if any records are found in the table. 

The procedure uses the SQL multi-row constructor syntax to insert values into a temporary table. 

Example:
--------
<TestHarness>
	<Test Name="Simple" IsDefault="true" Description="Deletes contents of sf.TextSender table first then calls procedure
	to repopulate it. The content of the table is then listed via a SELECT.">
		<SQLScript>
			<![CDATA[
			
			delete from sf.TextSender																											-- delete only succeeds if no FK rows!
			dbcc checkident( 'sf.TextSender', reseed, 1000000) with NO_INFOMSGS

			exec dbo.pSetup$SF#TextSender 
				 @SetupUser = N'richard.k@alinityapp.com'
				,@Language  = 'en'
				,@Region		= 'Alinity'
	
			select * from sf.TextSender

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:02" />
		</Assertions>
	</Test>

	<Test Name="NoChange" Description="Delete 1 record, call the procedure then search for the deleted record. The
	procedure should not not re-add the deleted record.">
		<SQLScript>
			<![CDATA[
			delete																											
				sf.TextSender
			where
				TextsenderSID in (Select top 1 TextSenderSID from sf.TextSender)

			exec dbo.pSetup$SF#TextSender																					
				 @SetupUser = N'admin@alinity.com'
				,@Language  = 'en'
				,@Region		= 'can'

			select * from sf.TextSender
		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="EmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:02" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName			= 'dbo.pSetup$SF#TextSender'
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
		,@id                                int                               -- id of @sample row to update
		,@displayName												varchar(66)												-- name of the user

	declare
		@sample                             table
		(
			 ID                               int           identity(1,1)
			,SenderPhone				              varchar(25)		not null
			,SenderDisplayName								nvarchar(66)	not null
			,IsPrivate												bit					  not null
			,IsDefault                        bit					  not null
		)
		
	begin try

		if not exists(select 1 from sf.TextSender)														-- only insert sample Text Senders if table is empty
		begin

			set @displayName = (select DisplayName from sf.vApplicationUser where UserName = @SetupUser)

			insert 
				@sample 
			(
				 SenderPhone
				,SenderDisplayName
				,IsPrivate
				,IsDefault
			)
			values
				('555-555-5555', 'Alinity', @OFF, @ON)

			-- now insert to the target table

			insert
				sf.TextSender
			(
				 SenderPhone
				,SenderDisplayName
				,IsPrivate
				,IsDefault
				,CreateUser
				,UpdateUser
			) 
			select
				 x.SenderPhone
				,x.SenderDisplayName
				,x.IsPrivate
				,x.IsDefault
				,@SetupUser
				,@SetupUser
			from
				@sample           x

		end

	end try

	begin catch
		exec @errorNo = sf.pErrorRethrow
	end catch

	return(@errorNo)

end
GO
