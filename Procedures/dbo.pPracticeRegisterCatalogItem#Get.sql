SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pPracticeRegisterCatalogItem#Get]
	@PracticeRegisterSID int			-- key of practice register to return fees for
 ,@RegistrationYear		 smallint -- registration year to return fees for
as
/*********************************************************************************************************************************
Sproc    : Practice Register Catalog Item - Get
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : This procedure returns catalog item information for display on the UI for a given practice register and registration year
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)				| Month Year | Change Summary
				 : ---------------- | -----------|----------------------------------------------------------------------------------------
				 : Tim Edlund				| Sep 2017 	 | Initial version
				 : Cory Ng					| Jul 2018	 | Return bits for IsAppliedOnApplicationApproval and IsAppliedOnRegChange
----------------------------------------------------------------------------------------------------------------------------------
 
Comments
--------
This procedure is called from the Practice Register Management UI to display catalog item information in effect for the register 
for the registration year selected.  

Known Limitations
-----------------
Only fee components which were stil in effect at the END of the registration year are displayed and pricing is obtained based on 
the last price in effect at the end of the year.  If a price change was made during the registration year the earlier price is 
not shown.

!<TestHarness>
<Test Name = "Simple" Description="Get the fees for a random registration year">
<SQLScript>
<![CDATA[

	declare
	  @practiceRegisterSID int
   ,@registrationYear		 smallint;

  select top 1
	  @practiceRegisterSID = pr.PracticeRegisterSID
   ,@registrationYear		 = rsy.RegistrationYear
  from
	  dbo.RegistrationScheduleYear rsy
  join
	  dbo.RegistrationSchedule		 rs on rsy.RegistrationScheduleSID = rs.RegistrationScheduleSID
  join
	  dbo.PracticeRegister				 pr on rs.RegistrationScheduleSID	 = pr.RegistrationScheduleSID
  join
	  dbo.PracticeRegisterCatalogItem prf on pr.PracticeRegisterSID = prf.PracticeRegisterSID
  join
	  dbo.CatalogItemPrice prfp on prf.CatalogItemSID = prfp.CatalogItemSID and year(prfp.EffectiveTime) <= rsy.RegistrationYear
  order by
	  newid();

  exec dbo.pPracticeRegisterCatalogItem#Get 
	  @PracticeRegisterSID = @practiceRegisterSID
   ,@RegistrationYear		 = @registrationYear
		

]]>
</SQLScript>
<Assertions>
	<Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
	<Assertion Type="ExecutionTime" Value="00:00:05" />
</Assertions>
</Test>
!</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.pPracticeRegisterCatalogItem#Get'

------------------------------------------------------------------------------------------------------------------------------- */
set nocount on;

begin
	declare
		@errorNo		 int					 = 0							-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText	 nvarchar(4000)									-- message text for business rule errors
	 ,@blankParm	 varchar(50)										-- tracks name of any required parameter not passed
	 ,@ON					 bit					 = cast(1 as bit) -- constant for bit comparisons = 1
	 ,@OFF				 bit					 = cast(0 as bit) -- constant for bit comparison = 0
	 ,@scheduleSID int														-- schedule associated with the practice register
	 ,@yearStart	 datetime												-- the date and time the registration year begins
	 ,@yearEnd		 datetime												-- the date and time the registration year ends
	 ,@i					 int														-- loop iteration counter
	 ,@maxrow			 int;														-- loop limit

	declare @work table
	(
		ID			int identity(1, 1)
	 ,NextKey int not null
	);

	begin try

		-- check parameters
		if @RegistrationYear is null set @blankParm = '@RegistrationYear';
		if @PracticeRegisterSID is null set @blankParm = '@PracticeRegisterSID';

		if @blankParm is not null
		begin
			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = @blankParm;

			raiserror(@errorText, 18, 1);
		end;

		select
			@scheduleSID = pr.RegistrationScheduleSID
		from
			dbo.PracticeRegister pr
		where
			pr.PracticeRegisterSID = @PracticeRegisterSID;

		if @scheduleSID is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'dbo.PracticeRegister'
			 ,@Arg2 = @PracticeRegisterSID;

			raiserror(@errorText, 18, 1);
		end;

		select
			@yearStart = rsy.YearStartTime
		 ,@yearEnd	 = rsy.YearEndTime
		from
			dbo.RegistrationSchedule		 rs
		join
			dbo.RegistrationScheduleYear rsy on rs.RegistrationScheduleSID = rsy.RegistrationScheduleSID and rsy.RegistrationYear = @RegistrationYear
		where
			rs.RegistrationScheduleSID = @scheduleSID;

		if @yearStart is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'dbo.RegistrationScheduleYear'
			 ,@Arg2 = @scheduleSID;

			raiserror(@errorText, 18, 1);
		end;

		select
			prf.IsAppliedOnApplication
     ,prf.IsAppliedOnApplicationApproval
		 ,prf.IsAppliedOnRenewal
		 ,prf.IsAppliedOnReinstatement
     ,prf.IsAppliedOnRegChange
		 ,ci.IsLateFee
		 ,prf.PracticeRegisterSectionSID
     ,prs.PracticeRegisterSectionLabel
		 ,ci.InvoiceItemDescription
		 ,ci.GLAccountSID
		 ,ci.IsTaxRate1Applied
		 ,ci.IsTaxRate2Applied
		 ,ci.IsTaxRate3Applied
		 ,ci.IsTaxDeductible
		 ,prf.FeeSequence
		 ,prf.EffectiveTime
		 ,prf.ExpiryTime
		 ,price.Price
		from
			dbo.PracticeRegisterCatalogItem prf
    join
      dbo.CatalogItem ci on prf.CatalogItemSID = ci.CatalogItemSID
    left outer join
      dbo.PracticeRegisterSection prs on prf.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
		left outer join
		(
			select
				prfp.CatalogItemPriceSID
			 ,prfp.CatalogItemSID
			 ,prfp.Price
			from
			(
				select
					prfp.CatalogItemPriceSID
				 ,row_number() over (partition by
															 CatalogItemSID
														 order by
															 EffectiveTime desc
															,Price
														) rn	-- order by latest effective then SID
				from
					dbo.CatalogItemPrice prfp
				where
					prfp.EffectiveTime <= @yearEnd -- include prices before or equal to the registration year end
			)															 x
			join
				dbo.CatalogItemPrice prfp on x.CatalogItemPriceSID = prfp.CatalogItemPriceSID and x.rn = 1
		)													price on prf.CatalogItemSID = price.CatalogItemSID
		where
			prf.PracticeRegisterSID = @PracticeRegisterSID and prf.EffectiveTime <= @yearEnd and isnull(prf.ExpiryTime, dateadd(day, 1, @yearEnd)) > @yearEnd
		order by
			prf.FeeSequence;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
