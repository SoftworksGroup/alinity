SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pSetup$RegistrationRequirementType
	@SetupUser nvarchar(75) -- user assigned to audit columns
 ,@Language	 char(2)			-- language to install for
 ,@Region		 varchar(10)	-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup dbo.RegistrationRequirementType data
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : Initializes dbo.RegistrationRequirementType table with starting/sample values
----------------------------------------------------------------------------------------------------------------------------------
History		: Author								| Month Year	| Change Summary
					: --------------------- + ----------- + --------------------------------------------------------------------------------
					: Tim Edlund						| Dec 2018		|	Initial version
					
Comments  
--------
This procedure populates the dbo.RegistrationRequirementType table with starting values required by the application.  The 
procedure is run on installation and on each upgrade.  

Note that while client administrators and configurators can augment the set of records included in this table, the application
depends on a set of expected values.  These are identified by system codes beginning with "S!".  The UI prevents these records
from being deleted or having their code values changed.  Where a configuration does not wish to use one or more of the system-code 
records, the Is-Active bit can be turned off.  

The application also depends on the existence of a default value and so the procedures ensures a default is identified. 

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully.">
		<SQLScript>
		<![CDATA[

		exec dbo.pSetup$RegistrationRequirementType 
			 @SetupUser = N'system@softworksgroup.com'
			,@Language  = 'en'
			,@Region		= 'can'
	
		select * from dbo.RegistrationRequirementType

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$RegistrationRequirementType'
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

	declare @setup table
	(
		RegistrationRequirementTypeCode	 varchar(20)	not null
	 ,RegistrationRequirementTypeLabel nvarchar(35) not null
	 ,IsAppliedToPeople								 bit					not null default cast(1 as bit)
	 ,IsAppliedToOrganizations				 bit					not null default cast(0 as bit)
	);

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

		-- populate a table with system-expected values

		insert
			@setup
		(
			RegistrationRequirementTypeCode
		 ,RegistrationRequirementTypeLabel
		 ,IsAppliedToPeople
		 ,IsAppliedToOrganizations
		)
		values
		  ('S!DOCUMENT', N'Documents', @ON, @ON)
		 ,('S!JUDICIAL.DEC', N'Judicial declarations', @ON, @OFF)
		 ,('S!RENEWAL.DEC', N'Declarations', @ON, @OFF)
		 ,('S!EXAM', N'Exams', @ON, @OFF);

		-- add any missing system codes but do not modify or
		-- delete any additional codes nor change the IsActive status

		insert
			dbo.RegistrationRequirementType
		(
			RegistrationRequirementTypeCode
		 ,RegistrationRequirementTypeLabel
		 ,IsAppliedToPeople
		 ,IsAppliedToOrganizations
		)
		select
			s.RegistrationRequirementTypeCode
		 ,s.RegistrationRequirementTypeLabel
		 ,s.IsAppliedToPeople
		 ,s.IsAppliedToOrganizations
		from
			@setup													s
		left outer join
			dbo.RegistrationRequirementType x on s.RegistrationRequirementTypeCode = x.RegistrationRequirementTypeCode
		where
			x.RegistrationRequirementTypeSID is null;

		-- ensure a default exists

		if not exists (select 1 from dbo .RegistrationRequirementType ar where ar.IsDefault = @ON)
		begin

			update
				dbo.RegistrationRequirementType
			set
				IsDefault = @ON
			where
				RegistrationRequirementTypeSID =
			(
				select
					min(z.RegistrationRequirementTypeSID)
				from
					dbo.RegistrationRequirementType z
				where
					z.IsActive = @ON
			);

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
