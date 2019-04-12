SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pSetup$AgeRangeType
	@SetupUser nvarchar(75) -- user assigned to audit columns
 ,@Language	 char(2)			-- language to install for
 ,@Region		 varchar(10)	-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup dbo.AgeRangeType data
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : Initializes dbo.AgeRangeType table with starting/sample values
----------------------------------------------------------------------------------------------------------------------------------
History		: Author								| Month Year	| Change Summary
					: --------------------- + ----------- + --------------------------------------------------------------------------------
					: Tim Edlund						| Jul 2018		|	Initial version
					
Comments  
--------
This procedure populates the dbo.AgeRangeType table with starting values during the application installation process. The
procedure does not modify the table if any records are found in it.  The procedure only inserts the records where the
table is empty.

Records in this table can be added and deleted by end users and the Alinity Service Desk team to meet the requirements of the
client.  The records inserted by the procedure are examples only and may be replaced/modified as required.

Note that while the client and configurator can manage the records in the table as required, the application does depend
on a default type existing and that the default is created for age ranges used for reporting on the ages served in member
practice.  The application also has a series of reports that apply age-ranges of members. A separate type record is 
required for each and if not found, they are added by this setup procedure.  The system searches for specific
code values to locate these groups.  The code values should not be modified.

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully.">
		<SQLScript>
		<![CDATA[

		exec dbo.pSetup$AgeRangeType 
			 @SetupUser = N'system@softworksgroup.com'
			,@Language  = 'en'
			,@Region		= 'can'
	
		select * from dbo.AgeRangeType

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$AgeRangeType'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo	 int					 = 0											-- 0 no error, if < 50000 SQL error, else business rule
	 ,@ON				 bit					 = cast(1 as bit)					-- constant for bit comparisons = 1
	 ,@OFF			 bit					 = cast(0 as bit)					-- constant for bit comparisons = 0
	 ,@tranCount int					 = @@trancount						-- determines whether a wrapping transaction exists
	 ,@procName	 nvarchar(128) = object_name(@@procid)	-- name of currently executing procedure
	 ,@xState		 int;																		-- error state detected in catch block

	begin try

		-- process DB changes as a transaction
		-- to enable partial rollback on error

		if @tranCount = 0
		begin
			begin transaction; -- no wrapping transaction
		end;
		else
		begin
			save transaction @procName; -- previous trx pending - create save point
		end;

		-- ensure both system required age range types exist 

		if not exists
		(
			select 1 from		dbo.AgeRangeType ar where (AgeRangeTypeCode = 'S!CLIENTAGE')
		)
		begin

			insert
				dbo.AgeRangeType
			(
				AgeRangeTypeLabel
			 ,IsDefault
			 ,AgeRangeTypeCode
			 ,Description
			 ,CreateUser
			 ,UpdateUser
			)
			values
			(
				'Client/Patient Age Ranges', @ON, 'S!CLIENTAGE', 'A set defining the age-range of clients served by the member in their professional practice.', @SetupUser, @SetupUser
			);

		end;

		if not exists
		(
			select 1 from		dbo.AgeRangeType ar where ar.AgeRangeTypeCode = 'S!MEMBERAGE'
		)
		begin

			insert
				dbo.AgeRangeType
			(
				AgeRangeTypeLabel
			 ,IsDefault
			 ,AgeRangeTypeCode
			 ,Description
			 ,CreateUser
			 ,UpdateUser
			)
			values
			(
				'Member Age Ranges', @OFF, 'S!MEMBERAGE'
			 ,'A set of age ranges used by the application for reporting on member-user activity by age - e.g. completion of renewal forms. While this type can be renamed, the system depends on the range marked as the default to be used for age-based reporting.'
			 ,@SetupUser, @SetupUser
			);

		end;

		-- ensure a default exists

		if not exists (select 1 from dbo .AgeRangeType ar where ar.IsDefault = @ON)
		begin


			update
				dbo.AgeRangeType
			set
				IsDefault = @ON
			where
				(AgeRangeTypeCode = 'S!CLIENTAGE');

		end;

		if @tranCount = 0 and xact_state() = 1 -- if no wrapping transaction and committable
		begin
			commit;
		end;

	end try
	begin catch

		-- if a transaction was pending at start of routine 
		-- perform partial rollback to save point

		set @xState = xact_state();

		if @tranCount > 0 and (@xState = -1 or @xState = 1)
		begin
			rollback transaction @procName; -- rollback to save point
		end;
		else if (@xState = -1 or @xState = 1) -- full rollback since no previous trx was pending
		begin
			rollback;
		end;

		exec @errorNo = sf.pErrorRethrow; -- process message text and re-throw the error
	end catch;

	return (@errorNo);

end;
GO
