SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.[pSetup$AgeRange]
	@SetupUser nvarchar(75) -- user assigned to audit columns
 ,@Language	 char(2)			-- language to install for
 ,@Region		 varchar(10)	-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup dbo.AgeRange data
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : Initializes dbo.AgeRange table with starting/sample values
----------------------------------------------------------------------------------------------------------------------------------
History		: Author								| Month Year	| Change Summary
					: --------------------- + ----------- + --------------------------------------------------------------------------------
					: Tim Edlund						| Jul 2018		|	Initial version
					
Comments  
--------
This procedure populates the dbo.AgeRange table with starting values during the application installation process. The
procedure does not modify the table if any records are found in it.  The procedure only inserts the records where the
table is empty.

Records in this table can be added and deleted by end users and the Alinity Service Desk team to meet the requirements of the
client.  The records inserted by the procedure are examples only and may be replaced/modified as required.

Note that while the client and configurator can manage the records in the table as required, the application does depend
on the existence of an age range for reporting on ages served in member practice, and a second set of ranges for
member-age based reporting.  These range types are identified through specific code values in the parent table.

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully.">
		<SQLScript>
		<![CDATA[

		exec dbo.pSetup$AgeRange 
			 @SetupUser = N'system@softworksgroup.com'
			,@Language  = 'en'
			,@Region		= 'can'
	
		select * from dbo.AgeRange

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$AgeRange'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo				 int					 = 0											-- 0 no error, if < 50000 SQL error, else business rule
	 ,@ON							 bit					 = cast(1 as bit)					-- constant for bit comparisons = 1
	 ,@OFF						 bit					 = cast(0 as bit)					-- constant for bit comparison = 0
	 ,@tranCount			 int					 = @@trancount						-- determines whether a wrapping transaction exists
	 ,@procName				 nvarchar(128) = object_name(@@procid)	-- name of currently executing procedure
	 ,@xState					 int																		-- error state detected in catch block
	 ,@ageRangeTypeSID int;																		-- key of parent type table record to assign

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

		select
			@ageRangeTypeSID = art.AgeRangeTypeSID
		from
			dbo.AgeRangeType art
		where
			art.AgeRangeTypeCode = 'S!CLIENTAGE';

		if @ageRangeTypeSID is not null and not exists(select 1 from dbo.AgeRange ar where ar.AgeRangeTypeSID = @ageRangeTypeSID)
		begin

			insert
				dbo.AgeRange
			(
				AgeRangeTypeSID
			 ,StartAge
			 ,EndAge
			 ,IsDefault
			 ,AgeRangeLabel
			 ,CreateUser
			 ,UpdateUser
			)
			values
			(@ageRangeTypeSID, 0, 999, @ON,			'All ages'	,@SetupUser, @SetupUser)
			 ,(@ageRangeTypeSID, 0, 17, @OFF,		'Children'	,@SetupUser, @SetupUser)
			 ,(@ageRangeTypeSID, 18, 64, @OFF,	'Adults'		,@SetupUser, @SetupUser)
			 ,(@ageRangeTypeSID, 65, 999, @OFF, 'Seniors'		,@SetupUser, @SetupUser);

		end;

		set @ageRangeTypeSID = null;

		select
			@ageRangeTypeSID = art.AgeRangeTypeSID
		from
			dbo.AgeRangeType art
		where
			art.AgeRangeTypeCode = 'S!MEMBERAGE';

		if @ageRangeTypeSID is not null and not exists(select 1 from dbo.AgeRange ar where ar.AgeRangeTypeSID = @ageRangeTypeSID)
		begin

			insert
				dbo.AgeRange
			(
				AgeRangeTypeSID
			 ,StartAge
			 ,EndAge
			 ,IsDefault
			 ,AgeRangeLabel
			 ,CreateUser
			 ,UpdateUser
			)
			values
			(@ageRangeTypeSID, 0, 30, @OFF, '<= 30 years'			,@SetupUser, @SetupUser)
			 ,(@ageRangeTypeSID, 31, 40, @OFF, '31 - 40 years',@SetupUser, @SetupUser)
			 ,(@ageRangeTypeSID, 41, 50, @OFF, '41 - 50 years',@SetupUser, @SetupUser)
			 ,(@ageRangeTypeSID, 51, 60, @OFF, '51 - 60 years',@SetupUser, @SetupUser)
			 ,(@ageRangeTypeSID, 61, 70, @OFF, '61 - 70 years',@SetupUser, @SetupUser)
			 ,(@ageRangeTypeSID, 71, 999, @OFF, '71 + years'	,@SetupUser, @SetupUser);

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
