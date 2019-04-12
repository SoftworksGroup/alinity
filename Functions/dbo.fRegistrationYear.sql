SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fRegistrationYear]
(
	@EventTime datetime -- date time of event to return registration year for
)
returns smallint
as
/*********************************************************************************************************************************
ScalarF		: Registration Year
Notice		: Copyright © 2017 Softworks Group Inc.
Summary		: Returns a 4 digit year indicating in which registration year the event occurred
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Tim Edlund	| Sep	2017		|	Initial version

Comments	
--------
This function is used to return a registration year based on the default Registration Schedule established in the configuration. 
It is used, for example, to determine which registration year an invoice is generated in. This is a part of the calculation to 
determine if deferred revenue accounts are used.

Example
-------
<TestHarness>
	<Test Name="Simple" IsDefault="True"  Description="Test the correct label is returned when the calendar year and the registration year match">
		<SQLScript>
			<![CDATA[
						
			declare
				@RegistrationScheduleSID int
			
			begin tran
			
			select
				@RegistrationScheduleSID  = rs.RegistrationScheduleSID
			from
				dbo.RegistrationSchedule rs
			where
				rs.IsDefault = cast( 1 as bit)

			delete from dbo.RegistrationScheduleYear
			where
				RegistrationScheduleSID = @RegistrationScheduleSID
				

			insert into dbo.RegistrationScheduleYear
			(
				RegistrationScheduleSID
				,RegistrationYear
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
			)
			select
				@RegistrationScheduleSID	
				,2017	
				,'2017-01-01 00:00:00.000'
				,'2017-12-31 23:59:59.000'
				,'2016-09-01 00:00:00.000'
				,'2016-09-15 00:00:00.000'
				,'2016-10-31 00:00:00.000'
				,'2016-11-30 23:59:59.000'
				,'2017-01-01 00:00:00.000'
				,'2017-02-01 00:00:00.000'
				,'2017-08-31 23:59:59.000'
				,'2017-02-01 00:00:00.000'
				,'2017-11-19 00:00:00.000'
			
			insert into dbo.RegistrationScheduleYear
			(
				RegistrationScheduleSID
				,RegistrationYear
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
			)
			select
				@RegistrationScheduleSID	
				,2018	
				,'2018-01-01 00:00:00.000'
				,'2018-12-31 23:59:59.000'
				,'2017-09-01 00:00:00.000'
				,'2017-09-15 00:00:00.000'
				,'2017-10-31 00:00:00.000'
				,'2017-11-30 23:59:59.000'
				,'2018-01-01 00:00:00.000'
				,'2018-02-01 00:00:00.000'
				,'2018-08-31 23:59:59.000'
				,'2018-02-01 00:00:00.000'
				,'2018-11-19 00:00:00.000'

			select
					dbo.fRegistrationYear('2017-01-01') [2017]
				,	dbo.fRegistrationYear('2018-01-01') [2018]
				, dbo.fRegistrationYear('2017-04-01') [2017]
				, dbo.fRegistrationYear('2018-04-01') [2018]
				

			if @@ROWCOUNT = 0 raiserror( N'* ERROR: no sample data found to run test', 18, 1)
			if @@TRANCOUNT > 0 rollback


			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1" />
			<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="1" Value="2017" />
			<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="2" Value="2018" />
			<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="3" Value="2017" />
			<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="4" Value="2018" />
			<Assertion Type="ExecutionTime" Value="00:00:02" />
		</Assertions>
	</Test>
	<Test Name="MultiYear"   Description="Test the correct label is returned when the calendar year and the registration year do not match">
		<SQLScript>
			<![CDATA[

			declare
				@RegistrationScheduleSID int
			
			begin tran
			
			select
				@RegistrationScheduleSID  = rs.RegistrationScheduleSID
			from
				dbo.RegistrationSchedule rs
			where
				rs.IsDefault = cast( 1 as bit)

			delete from dbo.RegistrationScheduleYear
			where
				RegistrationScheduleSID = @RegistrationScheduleSID


			insert into dbo.RegistrationScheduleYear
			(
				RegistrationScheduleSID
				,RegistrationYear
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
			)
			select
				@RegistrationScheduleSID	
				,2017	
				,'2016-04-01 00:00:00.000'
				,'2017-03-31 23:59:59.000'
				,'2016-02-14 00:00:00.000'
				,'2016-02-15 00:00:00.000'
				,'2017-03-30 23:59:59.999'
				,'2017-03-31 23:59:59.999'
				,'2017-03-31 23:59:59.999'
				,'2018-04-01 00:00:00.000'
				,'2018-04-01 00:00:00.000'
				,'2017-02-01 00:00:00.000'
				,'2017-11-19 00:00:00.000'
			
			insert into dbo.RegistrationScheduleYear
			(
				RegistrationScheduleSID
				,RegistrationYear
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
			)
			select
				@RegistrationScheduleSID	
				,2018	
				,'2017-04-01 00:00:00.000'
				,'2018-03-31 23:59:59.000'
				,'2017-02-14 00:00:00.000'
				,'2017-02-15 00:00:00.000'
				,'2018-03-30 23:59:59.999'
				,'2018-03-31 23:59:59.999'
				,'2018-03-31 23:59:59.999'
				,'2019-04-01 00:00:00.000'
				,'2019-04-01 00:00:00.000'
				,'2018-02-01 00:00:00.000'
				,'2018-11-19 00:00:00.000'
						insert into dbo.RegistrationScheduleYear
			(
				RegistrationScheduleSID
				,RegistrationYear
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
			)
			select
				@RegistrationScheduleSID	
				,2019	
				,'2018-04-01 00:00:00.000'
				,'2019-03-31 23:59:59.000'
				,'2018-02-15 00:00:00.000'
				,'2018-02-15 00:00:00.000'
				,'2019-03-31 23:59:59.999'
				,'2019-03-31 23:59:59.999'
				,'2019-03-31 23:59:59.999'
				,'2020-04-01 00:00:00.000'
				,'2020-04-01 00:00:00.000'
				,'2019-02-01 00:00:00.000'
				,'2019-11-19 00:00:00.000'

			select
					dbo.fRegistrationYear('2017-01-01') [2017]
				,	dbo.fRegistrationYear('2018-01-01') [2018]
				, dbo.fRegistrationYear('2017-04-01') [2017]
				, dbo.fRegistrationYear('2018-04-01') [2018]
				

			if @@ROWCOUNT = 0 raiserror( N'* ERROR: no sample data found to run test', 18, 1)
			if @@TRANCOUNT > 0 rollback



			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1" />
			<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="1" Value="2017" />
			<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="2" Value="2018" />
			<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="3" Value="2018" />
			<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="4" Value="2019" />
			<Assertion Type="ExecutionTime" Value="00:00:02" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
  @ObjectName = 'dbo.fRegistrationYear'
 ,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */
begin
	declare @registrationYear smallint; -- return value

	if @EventTime is not null
	begin
		select
			@registrationYear = rsy.RegistrationYear
		from
			dbo.RegistrationSchedule		 rs
		join
			dbo.RegistrationScheduleYear rsy on rs.RegistrationScheduleSID = rsy.RegistrationScheduleSID
		where
			rs.IsDefault = cast(1 as bit) and @EventTime between rsy.YearStartTime and rsy.YearEndTime;
	end;

	return (@registrationYear);
end;
GO
