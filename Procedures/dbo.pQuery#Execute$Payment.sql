SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pQuery#Execute$Payment
	@QueryCode	varchar(30)							-- code of the sf.Query record to execute query for
 ,@Parameters dbo.Parameter readonly	-- query parameter values assigned to variables in query syntax
 ,@MaxRows		int											-- maximum rows allowed on search
as
/*********************************************************************************************************************************
Sproc    : Query Search - Payment
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : This procedure executes searches (queries) to support management of Payment records
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Oct 2018		|	Initial version

Comments	
--------
This procedure is a subroutine called from pQuery#Execute. It provides the syntax for executing queries in support of Payment
management. In order for query execution to synchronize with queries displayed on the user interface, the content of this procedure
and the query records created through sf.pSetup$SF#Query must be the same.

The @QueryCode value corresponds to the sf.Query.QueryCode column and is used for branching to the query to execute.  Any parameters
entered in the user interface for the query are stored as records in the @Parameters table and must be retrieved into local 
variables prior to execution.  Unless enforced as mandatory in the parameter definition, the parameter values can be null.
Zero-length strings detected in parameter values are converted to NULL's.  See also parent procedure.

Limitations
-----------
Although @MaxRows is passed as a parameter, a returned record limit is only enforced where "select top(@MaxRows)..." syntax is
implemented in the query.  If the enforcement of record limits has been turned off in the UI, the @MaxRows value has been set 
by the caller to a high value to avoid limiting the data set returned.

Example
-------
<TestHarness>
  <Test Name = "All" IsDefault ="true" Description="Executes the procedure to return all forms in a year selected at random">
    <SQLScript>
      <![CDATA[
declare
	@queryCode				varchar(30)	 = 'S!PMT.ALL'
 ,@parameters				dbo.Parameter

if not exists (select 1 from dbo.Payment)
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	exec dbo.pQuery#Execute$Payment
		@QueryCode = @queryCode
	 ,@Parameters = @parameters
	 ,@MaxRows = 9999999

end;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:05"/>
    </Assertions>
  </Test>
  <Test Name = "FindByPhone"  Description="Executes the procedure to search for a partial phone number selected at random">
    <SQLScript>
      <![CDATA[
declare
	@queryCode	 varchar(30) = 'S!PMT.FIND.BY.PHONE'
 ,@phoneNumber varchar(4)
 ,@parameters	 dbo.Parameter

select top (1)
	 @phoneNumber = substring(p.MobilePhone, 5, 4)
from
	sf.Person				 p
join
	dbo.Payment pmt on p.PersonSID = pmt.PersonSID
where
	len(ltrim(rtrim(substring(p.MobilePhone, 5, 4)))) = 4
order by
	newid();

if @@rowcount = 0 or @phoneNumber is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	insert
		@parameters (ParameterID, ParameterValue, Label)
	values
	(N'PhoneNumber', @phoneNumber, 'Phone');

	exec dbo.pQuery#Execute$Payment
		@QueryCode = @queryCode
	 ,@Parameters = @parameters
	 ,@MaxRows = 9999999

end;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:05"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pQuery#Execute$Payment'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo						int							 = 0																			-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText					nvarchar(4000)																						-- message text (for business rule errors)   
	 ,@ON									bit							 = cast(1 as bit)													-- constant for bit comparisons = 1
	 ,@OFF								bit							 = cast(0 as bit)													-- constant for bit comparison = 0
	 ,@recentDateTime			datetimeoffset	 = sf.fRecentAccessCutOff()								-- oldest point considered within the recent access hours
	 ,@userName						nvarchar(75)		 = sf.fApplicationUserSession#UserName()	-- sf.ApplicationUser UserName for the current user
	 ,@paymentTypeSID			int																												-- search parameters:
	 ,@paymentStatusSID		int
	 ,@startDate					date
	 ,@endDate						date
	 ,@cutoffDate					date
	 ,@startDateTime			datetime
	 ,@endDateTime				datetime
	 ,@cutoffDateTime			datetime
	 ,@startDateDTO				datetimeoffset(7)
	 ,@endDateDTO					datetimeoffset(7)
	 ,@phoneNumber				varchar(25)
	 ,@streetAddress			nvarchar(75)
	 ,@citySID						int
	 ,@isUpdatedByMeOnly	bit
	 ,@isPADSubscriber		bit
	 ,@isNotPADSubscriber bit
	 ,@bankGLAccountSID		int
	 ,@glAccountCode			varchar(50);

	begin try

		-- retrieve parameter values

		-- SQL Prompt formatting off
		select @paymentTypeSID				= cast(p.ParameterValue as int)											from	@Parameters p	where	p.ParameterID = 'PaymentTypeSID';
		select @paymentStatusSID			= cast(p.ParameterValue as int)											from	@Parameters p	where	p.ParameterID = 'PaymentStatusSID';
		select @recentDateTime				= cast(replace(p.ParameterValue, '-', '') as date)	from	@Parameters p	where	p.ParameterID = 'RecentDateTime';
		select @startDate							= cast(replace(p.ParameterValue, '-', '') as date)	from	@Parameters p	where	p.ParameterID = 'StartDate';
		select @endDate								= cast(replace(p.ParameterValue, '-', '') as date)	from	@Parameters p	where	p.ParameterID = 'EndDate';
		select @phoneNumber						= cast(p.ParameterValue as varchar(25))							from	@Parameters p	where	p.ParameterID = 'PhoneNumber';
		select @streetAddress					= cast(p.ParameterValue as nvarchar(75))						from	@Parameters p	where	p.ParameterID = 'StreetAddress';
		select @citySID								= cast(p.ParameterValue as int)											from	@Parameters p	where	p.ParameterID = 'CitySID';
		select @isUpdatedByMeOnly			= cast(p.ParameterValue as bit)											from	@Parameters p	where	p.ParameterID = 'IsUpdatedByMeOnly';
		select @isPADSubscriber				= cast(p.ParameterValue as bit)											from	@Parameters p	where	p.ParameterID = 'IsPADSubscriber';
		select @isNotPADSubscriber		= cast(p.ParameterValue as bit)											from	@Parameters p	where	p.ParameterID = 'IsNotPADSubscriber';
		select @bankGLAccountSID			= cast(p.ParameterValue as int)											from	@Parameters p	where	p.ParameterID = 'BankGLAccountSID';
		-- SQL Prompt formatting on

		-- store start/end dates entered on the UI as DTO's to 
		-- enable comparison with server times

		if @recentDateTime is not null
		begin
			set @recentDateTime = cast(convert(varchar(8), @recentDateTime, 112) + ' 23:59:59.99' as datetime);
		end;

		if @startDate is not null
		begin
			set @startDateTime = @startDate;
			set @startDateDTO = sf.fClientDateTimeToDTOffset(@startDateTime); -- convert to server time for comparison
		end;

		if @endDate is not null
		begin
			set @endDateTime = cast(convert(varchar(8), @endDate, 112) + ' 23:59:59.99' as datetime);
			set @endDateDTO = sf.fClientDateTimeToDTOffset(@endDateTime); -- set to end of day
		end;

		if @cutoffDate is not null
		begin
			set @cutoffDateTime = @cutoffDate;
		end;

		-- validate for conflicting parameters

		if @startDate > @endDate
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'DateRangeReversed'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The "%1" must be before the "%2".'
			 ,@Arg1 = 'Start Date'
			 ,@Arg2 = 'End Date';

			raiserror(@errorText, 16, 1);

		end;

		if @isPADSubscriber = @ON and @isNotPADSubscriber = @ON
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'ConflictingParameters'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The "%1" and "%2" criteria cannot both be applied.'
			 ,@Arg1 = 'Include PAD Subscribers'
			 ,@Arg2 = 'Exclude PAD Subscribers';

			raiserror(@errorText, 16, 1);

		end;

		-- if a query was saved as a default that has no
		-- data values for it, default them here based on 
		-- the most recent week of payment activity

		if @startDate is null or @endDate is null
		begin
			select @endDateDTO = max (pmt.CreateTime) from dbo.Payment pmt;
			set @endDate = sf.fDTOffsetToClientDate(@endDateDTO);
			set @startDateDTO = dateadd(day, -7, @endDateDTO);
			set @startDate = sf.fDTOffsetToClientDate(@startDateDTO);
		end;

		-- execute the query 

		if @QueryCode = 'S!PMT.ALL'
		begin

			select top (@MaxRows)
				pmt.PaymentSID
			from
				dbo.Payment pmt
			where
				(pmt.CreateTime between @startDateDTO and @endDateDTO)
			order by
				pmt.PaymentSID;

		end;
		else if @QueryCode = 'S!PMT.ALL.LATEST.WK'
		begin

			select @endDateDTO = max (pmt.CreateTime) from dbo.Payment pmt;
			set @startDateDTO = dateadd(day, -7, @endDateDTO);

			select top (@MaxRows)
				pmt.PaymentSID
			from
				dbo.Payment pmt
			where
				(pmt.CreateTime between @startDateDTO and @endDateDTO)
			order by
				pmt.PaymentSID;

		end;
		else if @QueryCode = 'S!PMT.DEPOSIT'
		begin

			select
				@glAccountCode = gla.GLAccountCode
			from
				dbo.GLAccount gla
			where
				gla.GLAccountSID = @bankGLAccountSID;

			select top (@MaxRows)
				pmt.PaymentSID
			from
				dbo.Payment pmt
			where
				(pmt.DepositDate between @startDate and @endDate) and pmt.GLAccountCode = @glAccountCode
			order by
				pmt.PaymentSID;

		end;
		else if @QueryCode = 'S!PMT.GLPOSTING'
		begin

			select top (@MaxRows)
				x.PaymentSID
			from
			(
				select distinct
					gt.PaymentSID
				from
					dbo.GLTransaction gt
				where
					(gt.GLPostingDate between @startDate and @endDate)
			) x
			order by
				x.PaymentSID;

		end;
		else if @QueryCode = 'S!PMT.ALL.PAP'
		begin

			select top (@MaxRows)
				pmt.PaymentSID
			from
				dbo.Payment				 pmt
			join
				dbo.PAPTransaction pt on pmt.PaymentSID = pt.PaymentSID
			where
				(pmt.CreateTime between @startDateDTO and @endDateDTO)
			order by
				pmt.PaymentSID;

		end;
		else if @QueryCode = 'S!PMT.BY.TYPE'
		begin

			select top (@MaxRows)
				pmt.PaymentSID
			from
				dbo.Payment				pmt
			join
				dbo.PaymentType		pt on pmt.PaymentTypeSID	 = pt.PaymentTypeSID
			join
				dbo.PaymentStatus ps on pmt.PaymentStatusSID = ps.PaymentStatusSID
			where
				(pmt.CreateTime between @startDateDTO and @endDateDTO)
				and pt.PaymentTypeSID																	= @paymentTypeSID
				and (@paymentStatusSID is null or ps.PaymentStatusSID = @paymentStatusSID)
			order by
				pmt.PaymentSID;

		end;
		else if @QueryCode = 'S!PMT.RENEWAL'
		begin

			select top (@MaxRows)
				pmt.PaymentSID
			from
				dbo.Payment						pmt
			join
				dbo.PaymentStatus			ps on pmt.PaymentStatusSID = ps.PaymentStatusSID
			join
				dbo.InvoicePayment		ipmt on pmt.PaymentSID		 = ipmt.PaymentSID
			join
				dbo.RegistrantRenewal rnw on ipmt.InvoiceSID		 = rnw.InvoiceSID
			where
				(pmt.CreateTime between @startDateDTO and @endDateDTO) and (@paymentStatusSID is null or ps.PaymentStatusSID = @paymentStatusSID)
			order by
				pmt.PaymentSID;

		end;
		else if @QueryCode = 'S!PMT.REINSTATEMENT'
		begin

			select top (@MaxRows)
				pmt.PaymentSID
			from
				dbo.Payment				 pmt
			join
				dbo.PaymentStatus	 ps on pmt.PaymentStatusSID = ps.PaymentStatusSID
			join
				dbo.InvoicePayment ipmt on pmt.PaymentSID			= ipmt.PaymentSID
			join
				dbo.Reinstatement	 rin on ipmt.InvoiceSID			= rin.InvoiceSID
			where
				(pmt.CreateTime between @startDateDTO and @endDateDTO) and (@paymentStatusSID is null or ps.PaymentStatusSID = @paymentStatusSID)
			order by
				pmt.PaymentSID;

		end;
		else if @QueryCode = 'S!PMT.APPLICATION'
		begin

			select top (@MaxRows)
				pmt.PaymentSID
			from
				dbo.Payment				 pmt
			join
				dbo.PaymentStatus	 ps on pmt.PaymentStatusSID = ps.PaymentStatusSID
			join
				dbo.InvoicePayment ipmt on pmt.PaymentSID			= ipmt.PaymentSID
			join
				dbo.RegistrantApp	 app on ipmt.InvoiceSID			= app.InvoiceSID
			where
				(pmt.CreateTime between @startDateDTO and @endDateDTO) and (@paymentStatusSID is null or ps.PaymentStatusSID = @paymentStatusSID)
			order by
				pmt.PaymentSID;

		end;
		else if @QueryCode = 'S!PMT.REGCHG'
		begin

			select top (@MaxRows)
				pmt.PaymentSID
			from
				dbo.Payment						 pmt
			join
				dbo.PaymentStatus			 ps on pmt.PaymentStatusSID = ps.PaymentStatusSID
			join
				dbo.InvoicePayment		 ipmt on pmt.PaymentSID			= ipmt.PaymentSID
			join
				dbo.RegistrationChange rc on ipmt.InvoiceSID			= rc.InvoiceSID
			where
				(pmt.CreateTime between @startDateDTO and @endDateDTO) and (@paymentStatusSID is null or ps.PaymentStatusSID = @paymentStatusSID)
			order by
				pmt.PaymentSID;

		end;
		else if @QueryCode = 'S!PMT.UNAPPLIED'
		begin

			select
				pmt.PaymentSID
			from
				dbo.Payment				 pmt
			join
				dbo.PaymentStatus	 ps on pmt.PaymentStatusSID = ps.PaymentStatusSID and ps.IsPaid = @ON -- only included PAID status
			left outer join
				dbo.PAPTransaction pt on pmt.PaymentSID				= pt.PaymentSID
			left outer join
			(
				select
					ip.PaymentSID
				 ,cast(isnull(sum(ip.AmountApplied), 0.00) as decimal(11, 2)) TotalApplied
				from
					dbo.InvoicePayment ip
				where
					ip.CancelledTime is null	-- do not include cancelled payments in the total applied
				group by
					ip.PaymentSID
			)										 ptot on pmt.PaymentSID			= ptot.PaymentSID
			where
				pmt.AmountPaid > isnull(ptot.TotalApplied, 0.0) and (@isPADSubscriber = @ON or pt.PAPTransactionSID is null) and pmt.CancelledTime is null
			order by
				pmt.PaymentSID;

		end;
		else if @QueryCode = 'S!PMT.PENDING'
		begin

			set @cutoffDateTime = dateadd(minute, -2, sysdatetimeoffset());

			select
				pmt.PaymentSID
			from
				dbo.Payment				pmt
			join
				dbo.PaymentStatus ps on pmt.PaymentStatusSID = ps.PaymentStatusSID and ps.PaymentStatusSCD = 'PENDING' -- pending payments only
			join
				dbo.PaymentType		pt on pmt.PaymentTypeSID	 = pt.PaymentTypeSID and left(pt.PaymentTypeSCD, 3) = 'PP.' -- payment processor type (credit card) only
			where
				pmt.CancelledTime is null and pmt.UpdateTime <= @cutoffDateTime;

		end;
		else if @QueryCode = 'S!PMT.CANCELLED'
		begin

			select
				pmt.PaymentSID
			from
				dbo.Payment				pmt
			join
				dbo.PaymentStatus ps on pmt.PaymentStatusSID = ps.PaymentStatusSID
			where
				(pmt.CreateTime between @startDateDTO and @endDateDTO)
				and
				(
					pmt.CancelledTime is not null or ps.PaymentStatusSCD = 'REJECTED' or ps.PaymentStatusSCD = 'CANCELLED'
				);

		end;
		else if @QueryCode = 'S!PMT.FIND.BY.PHONE'
		begin

			select distinct
				pmt.PaymentSID
			from
			(
				select distinct
					p.PersonSID
				from
					sf.Person p
				where
					p.HomePhone like '%' + @phoneNumber + '%' or p.MobilePhone like '%' + @phoneNumber + '%'
			)							x
			join
				dbo.Payment pmt on x.PersonSID = pmt.PersonSID;

		end;
		else if @QueryCode = 'S!PMT.FIND.BY.ADDRESS'
		begin

			if @streetAddress is null and @citySID is null
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'NoSearchParameters'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'No search criteria was provided. Enter at least one value.';

				raiserror(@errorText, 16, 1);
			end;

			select distinct
				pmt.PaymentSID
			from
			(
				select distinct
					pma.PersonSID
				from
					dbo.PersonMailingAddress pma
				where
					(
						@streetAddress is null
						or pma.StreetAddress1 like '%' + @streetAddress + '%'
						or pma.StreetAddress2 like '%' + @streetAddress + '%'
						or pma.StreetAddress3 like '%' + @streetAddress + '%'
					)
					and (@citySID is null or pma.CitySID = @citySID)
			)							x
			join
				dbo.Payment pmt on x.PersonSID = pmt.PersonSID;

		end;
		else if @QueryCode = 'S!PMT.RECENTLY.UPDATED'
		begin

			select
				pmt.PaymentSID
			from
				dbo.Payment pmt
			where
				pmt.UpdateTime >= @recentDateTime and (@isUpdatedByMeOnly = @OFF or pmt.UpdateUser = @userName);

		end;
		else
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'Query'
			 ,@Arg2 = @QueryCode;

			raiserror(@errorText, 18, 1);

		end;

	end try
	begin catch
		set noexec off;
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
