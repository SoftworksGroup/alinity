SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.[pSetup$RegistrationSchedule]
	@SetupUser nvarchar(75) -- user assigned to audit columns
 ,@Language	 char(2)			-- language to install for
 ,@Region		 varchar(10)	-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup Registration Schedule data
Notice   : Copyright © 2012 Softworks Group Inc.
Summary  : Sets dbo.RegistrationSchedule master table with a "default" schedule
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year  | Change Summary
				 : ------------ | ------------|-------------------------------------------------------------------------------------------
				 : Tim Edlund		| Sep 2017		| Initial Version				 
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------
This procedure checks to see if a Registration Schedule has been created.  If at least one schedule record exists, no action is 
taken by the procedure. If 0 schedules are defined, however, a "Default" schedule is created.

Registration Schedules define the start and editing dates for renewal and other operations and are part of the definition of 
each Practice Register.  At least one schedule record must exist in the system.  If this procedure adds a default schedule it
also sets up a few dbo.RegistrationScheduleYear records to serve as examples of configuring the schedule details on new
applications.  The sample schedule records are based on a registration year running Jan-Dec.  

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully.">
		<SQLScript>
		<![CDATA[

			exec dbo.pSetup$RegistrationSchedule
				 @SetupUser = 'system@alinityapp.com'
				,@Language = 'EN'
				,@Region = 'CA'

			select * from dbo.RegistrationSchedule
			select * from dbo.RegistrationScheduleYear

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$RegistrationSchedule'
	,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */
set nocount on;

begin
	declare
		@errorNo								 int = 0				-- 0 no error, if < 50000 SQL error, else business rule
	 ,@registrationScheduleSID int						-- key of the registration schedule added (parent key)
	 ,@i											 int
	 ,@maxRow									 int
	 ,@currentYear						 int

	begin try
		if not exists (select 1 from	dbo.RegistrationSchedule)
		begin
			insert
				dbo.RegistrationSchedule
			( RegistrationScheduleLabel
			 ,IsDefault
			 ,CreateUser
			 ,UpdateUser
			)
			values
			(
				'Default Schedule', cast(1 as bit), @SetupUser, @SetupUser
			);

			set @registrationScheduleSID = ident_current('dbo.RegistrationSchedule');
			set @currentYear = year(sf.fNow()) - 1;
			set @maxRow = 2;
			set @i = 0;

			while @i < @maxRow
			begin
				set @i += 1;
				set @currentYear += 1;

				insert
					dbo.RegistrationScheduleYear
				( RegistrationYear
				 ,YearStartTime
				 ,YearEndTime
				 ,RenewalVerificationOpenTime
				 ,RenewalGeneralOpenTime
				 ,RenewalLateFeeStartTime
				 ,RenewalEndTime
				 ,ReinstatementVerificationOpenTime
				 ,ReinstatementGeneralOpenTime
				 ,ReinstatementEndTime
				 ,PAPBlockStartTime
				 ,PAPBlockEndTime
				 ,CECollectionStartTime
				 ,CECollectionEndTime
				 ,RegistrationScheduleSID
				 ,CreateUser
				 ,UpdateUser
				)
				select
					cast(@currentYear as smallint)
				 ,ltrim(@currentYear) + '0101'
				 ,ltrim(@currentYear) + '1231 23:59:59'
				 ,ltrim(@currentYear - 1) + '0929 09:00:00'
				 ,ltrim(@currentYear - 1) + '1001 09:00:00'
				 ,ltrim(@currentYear - 1) + '1201'
				 ,ltrim(@currentYear - 1) + '1231 23:59:59'
				 ,ltrim(@currentYear) + '0101 09:00:00'
				 ,ltrim(@currentYear) + '0102 09:00:00'
				 ,ltrim(@currentYear) + '1201 23:59:59'
				 ,ltrim(@currentYear - 1) + '0201 00:00:00'
				 ,ltrim(@currentYear - 1) + '1119 23:59:59'
				 ,ltrim(@currentYear) + '0101'
				 ,ltrim(@currentYear) + '1231 23:59:59'
				 ,@registrationScheduleSID
				 ,@SetupUser
				 ,@SetupUser;
			end;
		end;
	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
