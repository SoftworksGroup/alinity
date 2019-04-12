SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pQuery#Execute$Invoice
	@QueryCode	varchar(30)							-- code of the sf.Query record to execute query for
 ,@Parameters dbo.Parameter readonly	-- query parameter values assigned to variables in query syntax
 ,@MaxRows		int											-- maximum rows allowed on search
as
/*********************************************************************************************************************************
Sproc    : Query Search - Invoice
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : This procedure executes searches (queries) to support management of Invoice records
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Nov 2018		|	Initial version

Comments	
--------
This procedure is a subroutine called from pQuery#Execute. It provides the syntax for executing queries in support of Invoice
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
	@queryCode				varchar(30)	 = 'S!IVC.ALL'
 ,@parameters				dbo.Parameter

if not exists (select 1 from dbo.Invoice)
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	exec dbo.pQuery#Execute$Invoice
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
	@queryCode	 varchar(30) = 'S!IVC.FIND.BY.PHONE'
 ,@phoneNumber varchar(4)
 ,@parameters	 dbo.Parameter

select top (1)
	 @phoneNumber = substring(p.MobilePhone, 5, 4)
from
	sf.Person				 p
join
	dbo.Invoice ivc on p.PersonSID = ivc.PersonSID
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

	exec dbo.pQuery#Execute$Invoice
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
	 @ObjectName = 'dbo.pQuery#Execute$Invoice'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo					 int						= 0																			-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText				 nvarchar(4000)																					-- message text (for business rule errors)   
	 ,@ON								 bit						= cast(1 as bit)												-- constant for bit comparisons = 1
	 ,@OFF							 bit						= cast(0 as bit)												-- constant for bit comparison = 0
	 ,@recentDateTime		 datetimeoffset = sf.fRecentAccessCutOff()							-- oldest point considered within the recent access hours
	 ,@userName					 nvarchar(75)		= sf.fApplicationUserSession#UserName() -- sf.ApplicationUser UserName for the current user
	 ,@startDate				 date																										-- query parameter values:
	 ,@endDate					 date
	 ,@itemDescription	 nvarchar(100)
	 ,@isPaidOnly				 bit
	 ,@isNotPaid				 bit
	 ,@hasLateFee				 bit
	 ,@hasNoLateFee			 bit
	 ,@cutOffNo					 int
	 ,@cutoffDate				 date
	 ,@phoneNumber			 varchar(25)
	 ,@streetAddress		 nvarchar(75)
	 ,@citySID					 int
	 ,@isUpdatedByMeOnly bit;

	begin try

		-- retrieve parameter values

		-- SQL Prompt formatting off
		select @recentDateTime				= cast(replace(p.ParameterValue, '-', '') as date)	from	@Parameters p	where	p.ParameterID = 'RecentDateTime';
		select @startDate							= cast(replace(p.ParameterValue, '-', '') as date)	from	@Parameters p	where	p.ParameterID = 'StartDate';
		select @endDate								= cast(replace(p.ParameterValue, '-', '') as date)	from	@Parameters p	where	p.ParameterID = 'EndDate';
		select @phoneNumber						= cast(p.ParameterValue as varchar(25))							from	@Parameters p	where	p.ParameterID = 'PhoneNumber';
		select @streetAddress					= cast(p.ParameterValue as nvarchar(75))						from	@Parameters p	where	p.ParameterID = 'StreetAddress';
		select @citySID								= cast(p.ParameterValue as int)											from	@Parameters p	where	p.ParameterID = 'CitySID';
		select @isUpdatedByMeOnly			= cast(p.ParameterValue as bit)											from	@Parameters p	where	p.ParameterID = 'IsUpdatedByMeOnly';
		select @itemDescription				= cast(p.ParameterValue as nvarchar(100))						from  @Parameters p where p.ParameterID = 'ItemDescription';
		select @isPaidOnly						= cast(p.ParameterValue as bit)											from  @Parameters p where p.ParameterID = 'IsPaidOnly'
		select @isNotPaid							= cast(p.ParameterValue as bit)											from  @Parameters p where p.ParameterID = 'IsNotPaid'
		select @hasLateFee						= cast(p.ParameterValue as bit)											from  @Parameters p where p.ParameterID = 'HasLateFee'
		select @isNotPaid							= cast(p.ParameterValue as bit)											from  @Parameters p where p.ParameterID = 'IsNotPaid'
		select @cutOffNo							= cast(p.ParameterValue as int)											from  @Parameters p where p.ParameterID = 'CutOffNo';
		-- SQL Prompt formatting on

		-- store start/end dates entered on the UI as DTO's to 
		-- enable comparison with server times

		if @recentDateTime is not null
		begin
			set @recentDateTime = cast(convert(varchar(8), @recentDateTime, 112) + ' 23:59:59.99' as datetime);
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

		if @isNotPaid = @ON and @isPaidOnly = @ON
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'ConflictingParameters'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The "%1" and "%2" criteria cannot both be applied.'
			 ,@Arg1 = 'paid only'
			 ,@Arg2 = 'not paid';

			raiserror(@errorText, 16, 1);

		end;

		if @hasLateFee = @ON and @hasNoLateFee = @ON
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'ConflictingParameters'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The "%1" and "%2" criteria cannot both be applied.'
			 ,@Arg1 = 'late fee'
			 ,@Arg2 = 'no late fee';

			raiserror(@errorText, 16, 1);

		end;

		-- if a query was saved as a default that has no
		-- data values for it, default them here based on 
		-- the most recent week of invoice activity

		if @startDate is null or @endDate is null
		begin
			select @endDate	 = max(ivc.InvoiceDate) from dbo.Invoice ivc;
			set @startDate = dateadd(day, -7, @endDate);
		end;

		-- format item description for "like" clause searching

		set @itemDescription = ltrim(rtrim(@itemDescription));

		if len(@itemDescription) = 0
		begin
			set @itemDescription = null;
		end;
		else
		begin
			set @itemDescription = N'%' + @itemDescription + N'%';
		end;

		-- execute the query 

		if @QueryCode = 'S!IVC.ALL'
		begin

			if @itemDescription is null
			begin

				select top (@MaxRows)
					ivc.InvoiceSID
				from
					dbo.Invoice ivc
				where
					(ivc.InvoiceDate between @startDate and @endDate)
				order by
					ivc.InvoiceSID;

			end;
			else
			begin

				select top (@MaxRows)
					x.InvoiceSID
				from
				(
					select distinct
						ivc.InvoiceSID
					from
						dbo.Invoice			ivc
					join
						dbo.InvoiceItem ii on ivc.InvoiceSID = ii.InvoiceSID
					where
						(ivc.InvoiceDate between @startDate and @endDate) and ii.InvoiceItemDescription like @itemDescription
				) x
				order by
					x.InvoiceSID;

			end;

		end;
		else if @QueryCode = 'S!IVC.ALL.LATEST.WK'
		begin

			select top (@MaxRows)
				ivc.InvoiceSID
			from
				dbo.Invoice ivc
			where
				(ivc.InvoiceDate between @startDate and @endDate)
			order by
				ivc.InvoiceSID;

		end;
		else if @QueryCode = 'S!IVC.NOT.PAID'
		begin

			if @cutOffNo is null begin
														 set @cutOffNo = 0;
			end;

			set @cutoffDate = dateadd(day, (-1 * @cutOffNo), sf.fToday());

			select top (@MaxRows)
				ivc.InvoiceSID
			from
				dbo.Invoice																	 ivc
			cross apply dbo.fInvoice#Total(ivc.InvoiceSID) it
			where
				it.TotalDue > 0.0 and ivc.InvoiceDate <= @cutoffDate
			order by
				ivc.InvoiceSID;

		end;
		else if @QueryCode = 'S!IVC.OVER.PAID'
		begin

			if @cutOffNo is null begin
														 set @cutOffNo = 0;
			end;

			set @cutoffDate = dateadd(day, (-1 * @cutOffNo), sf.fToday());

			select top (@MaxRows)
				ivc.InvoiceSID
			from
				dbo.Invoice																	 ivc
			cross apply dbo.fInvoice#Total(ivc.InvoiceSID) it
			where
				it.TotalDue < 0.0 and ivc.InvoiceDate <= @cutoffDate
			order by
				ivc.InvoiceSID;

		end;
		else if @QueryCode = 'S!IVC.REFUNDS'
		begin

			if @itemDescription is null
			begin

				select top (@MaxRows)
					ivc.InvoiceSID
				from
					dbo.Invoice																	 ivc
				cross apply dbo.fInvoice#Total(ivc.InvoiceSID) it
				where
					(ivc.InvoiceDate between @startDate and @endDate) and it.TotalAfterTax < 0.0
				order by
					ivc.InvoiceSID;

			end;
			else
			begin

				select top (@MaxRows)
					x.InvoiceSID
				from
				(
					select distinct
						ivc.InvoiceSID
					from
						dbo.Invoice																	 ivc
					join
						dbo.InvoiceItem															 ii on ivc.InvoiceSID = ii.InvoiceSID
					cross apply dbo.fInvoice#Total(ivc.InvoiceSID) it
					where
						(ivc.InvoiceDate between @startDate and @endDate) and ii.InvoiceItemDescription like @itemDescription and it.TotalAfterTax < 0.0
				) x
				order by
					x.InvoiceSID;

			end;

		end;
		else if @QueryCode = 'S!IVC.ADJUSTED'
		begin

			select top (@MaxRows)
				ivc.InvoiceSID
			from
				dbo.Invoice																	 ivc
			cross apply dbo.fInvoice#Total(ivc.InvoiceSID) it
			where
				(ivc.InvoiceDate between @startDate and @endDate) and it.TotalAdjustment <> 0.0
			order by
				ivc.InvoiceSID;

		end;
		else if @QueryCode = 'S!IVC.PAP'
		begin

			if @isNotPaid = @ON
			begin

				select top (@MaxRows)
					x.InvoiceSID
				from
				(
					select distinct
						ivc.InvoiceSID
					from
						dbo.Invoice				 ivc
					join
						dbo.InvoicePayment ipmt on ivc.InvoiceSID = ipmt.InvoiceSID
					join
						dbo.PAPTransaction pt on ipmt.PaymentSID	= pt.PaymentSID
					where
						(ivc.InvoiceDate between @startDate and @endDate)
				)																						 x
				cross apply dbo.fInvoice#Total(x.InvoiceSID) it
				where
					it.TotalDue > 0.0
				order by
					x.InvoiceSID;

			end;
			else
			begin

				select top (@MaxRows)
					x.InvoiceSID
				from
				(
					select distinct
						ivc.InvoiceSID
					from
						dbo.Invoice				 ivc
					join
						dbo.InvoicePayment ipmt on ivc.InvoiceSID = ipmt.InvoiceSID
					join
						dbo.PAPTransaction pt on ipmt.PaymentSID	= pt.PaymentSID
					where
						(ivc.InvoiceDate between @startDate and @endDate)
				) x
				order by
					x.InvoiceSID;

			end;

		end;
		else if @QueryCode = 'S!IVC.RENEWAL'
		begin

			if @hasLateFee = @ON
			begin

				select top (@MaxRows)
					x.InvoiceSID
				from
				(
					select
						ivc.InvoiceSID
					from
						dbo.Invoice																	 ivc
					join
						dbo.RegistrantRenewal												 rnw on ivc.InvoiceSID = rnw.InvoiceSID
					cross apply dbo.fInvoice#Total(ivc.InvoiceSID) it
					where
						(ivc.InvoiceDate between @startDate and @endDate) and (@isPaidOnly = @OFF or it.TotalDue = 0.0) and (@isNotPaid = @OFF or it.TotalDue > 0.0)
				)									x
				join
					dbo.InvoiceItem ii on x.InvoiceSID			= ii.InvoiceSID
				join
					dbo.CatalogItem ci on ii.CatalogItemSID = ci.CatalogItemSID and ci.IsLateFee = @ON
				order by
					x.InvoiceSID;

			end;
			else if @hasNoLateFee = @ON
			begin

				select top (@MaxRows)
					x.InvoiceSID
				from
				(
					select
						ivc.InvoiceSID
					from
						dbo.Invoice																	 ivc
					join
						dbo.RegistrantRenewal												 rnw on ivc.InvoiceSID = rnw.InvoiceSID
					cross apply dbo.fInvoice#Total(ivc.InvoiceSID) it
					where
						(ivc.InvoiceDate between @startDate and @endDate) and (@isPaidOnly = @OFF or it.TotalDue = 0.0) and (@isNotPaid = @OFF or it.TotalDue > 0.0)
				) x
				where
					not exists
				(
					select
						1
					from
						dbo.InvoiceItem ii
					join
						dbo.CatalogItem ci on ii.CatalogItemSID = ci.CatalogItemSID
					where
						ii.InvoiceSID = x.InvoiceSID and ci.IsLateFee = @ON
				)
				order by
					x.InvoiceSID;

			end;
			else
			begin

				select top (@MaxRows)
					ivc.InvoiceSID
				from
					dbo.Invoice																	 ivc
				join
					dbo.RegistrantRenewal												 rnw on ivc.InvoiceSID = rnw.InvoiceSID
				cross apply dbo.fInvoice#Total(ivc.InvoiceSID) it
				where
					(ivc.InvoiceDate between @startDate and @endDate) and (@isPaidOnly = @OFF or it.TotalDue = 0.0) and (@isNotPaid = @OFF or it.TotalDue > 0.0)
				order by
					ivc.InvoiceSID;

			end;

		end;
		else if @QueryCode = 'S!IVC.REINSTATEMENT'
		begin

			select top (@MaxRows)
				ivc.InvoiceSID
			from
				dbo.Invoice																	 ivc
			join
				dbo.Reinstatement														 rin on ivc.InvoiceSID = rin.InvoiceSID
			cross apply dbo.fInvoice#Total(ivc.InvoiceSID) it
			where
				(ivc.InvoiceDate between @startDate and @endDate) and (@isPaidOnly = @OFF or it.TotalDue = 0.0) and (@isNotPaid = @OFF or it.TotalDue > 0.0)
			order by
				ivc.InvoiceSID;

		end;
		else if @QueryCode = 'S!IVC.APPLICATION'
		begin

			select top (@MaxRows)
				ivc.InvoiceSID
			from
				dbo.Invoice																	 ivc
			join
				dbo.RegistrantApp														 app on ivc.InvoiceSID = app.InvoiceSID
			cross apply dbo.fInvoice#Total(ivc.InvoiceSID) it
			where
				(ivc.InvoiceDate between @startDate and @endDate) and (@isPaidOnly = @OFF or it.TotalDue = 0.0) and (@isNotPaid = @OFF or it.TotalDue > 0.0)
			order by
				ivc.InvoiceSID;

		end;
		else if @QueryCode = 'S!IVC.REGCHG'
		begin

			select top (@MaxRows)
				ivc.InvoiceSID
			from
				dbo.Invoice																	 ivc
			join
				dbo.RegistrationChange											 rc on ivc.InvoiceSID = rc.InvoiceSID
			cross apply dbo.fInvoice#Total(ivc.InvoiceSID) it
			where
				(ivc.InvoiceDate between @startDate and @endDate) and (@isPaidOnly = @OFF or it.TotalDue = 0.0) and (@isNotPaid = @OFF or it.TotalDue > 0.0)
			order by
				ivc.InvoiceSID;

		end;
		else if @QueryCode = 'S!IVC.CANCELLED'
		begin

			select
				ivc.InvoiceSID
			from
				dbo.Invoice ivc
			where
				(ivc.CancelledTime between @startDate and @endDate);

		end;
		else if @QueryCode = 'S!IVC.FIND.BY.PHONE'
		begin

			select distinct
				ivc.InvoiceSID
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
				dbo.Invoice ivc on x.PersonSID = ivc.PersonSID;

		end;
		else if @QueryCode = 'S!IVC.FIND.BY.ADDRESS'
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
				ivc.InvoiceSID
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
				dbo.Invoice ivc on x.PersonSID = ivc.PersonSID;

		end;
		else if @QueryCode = 'S!IVC.RECENTLY.UPDATED'
		begin

			select
				ivc.InvoiceSID
			from
				dbo.Invoice ivc
			where
				ivc.UpdateTime >= @recentDateTime and (@isUpdatedByMeOnly = @OFF or ivc.UpdateUser = @userName);

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
