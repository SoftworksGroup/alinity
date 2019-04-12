SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pExam#Lookup
	@ExamIdentifier	 varchar(50)					-- registrant number to lookup
 ,@LegacyKey			 nvarchar(50) = null	-- legacy key matching the Exam or Exam Offering
 ,@ExamDate				 date = null					-- date of exam - used to lookup offering
 ,@OrgSID					 int = null						-- key of examining organization
 ,@ExamSID				 int output						-- key of the exam record
 ,@ExamOfferingSID int = null output		-- key of the exam offering record
as
/*********************************************************************************************************************************
Procedure	: Lookup Exam (and Exam Offering)
Notice		: Copyright © 2019 Softworks Group Inc. 
Summary		: Subroutine to lookup a(n) ExamSID and ExamOfferingSID based on identifiers passed in 
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Apr 2019		|	Initial version

Comments
--------
This procedure is used when processing staged data. It attempts to find a primary key value for the dbo.Exam and dbo.ExamOffering 
tables based on identifiers passed in.  The identifiers include the @ExamIdentifier and @LegacyKey - which are unique identifiers,
and, the first, last and birthdate values which can be used in combination to locate a record.  The @ExamSID key can be passed 
explicitly if available as another method to lookup/check-for a Registrant record.

Note that the procedure verifies the lookup with the @ExamIdentifier parameter which is always required. Where a value is looked 
up successfully using identifiers other than the last name, the last name is compared to the record found to ensure there is a
match.  If a match is not found, then an error is raised.

For the lookup based on last name + first name + birth date, both the first-name and common-name fields are checked for the
@FirstName parameter value.

No Record Found
---------------
It is possible, and expected, that the values provided will not result in a record being found in the (sf) Person or (dbo) 
Registrant table.  The caller is responsible for checking the output parameters and either raise an error if a successful lookup 
was required, or, to add the record if new record insertions are a supported option in the caller.

Add-on-the-fly NOT supported
----------------------------
Where a record is not found through the lookup, it will not be added.  Person and Registrant records must be created by the 
caller. 

Example:
--------
<TestHarness>
	<Test Name="Random" IsDefault="true" Description="Calls lookup procedure to find random exam by name.">
		<SQLScript>
			<![CDATA[
declare
	@examIdentifier varchar(50)
 ,@examSID				int;

select top (1) @examIdentifier = x .ExamName from dbo.Exam x order by newid();

if @@rowcount = 0 or @examIdentifier is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin
	exec dbo.pExam#Lookup
		@ExamIdentifier = @examIdentifier
	 ,@ExamSID = @examSID output;

	select @examIdentifier [@ExamIdentifier] , @examSID [@ExamSID];
end;
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:01" />
		</Assertions>
	</Test>
	<Test Name="WithOffering" Description="Calls lookup procedure to find both exam and exam offering.">
		<SQLScript>
			<![CDATA[

declare
	@examIdentifier	 varchar(50)
 ,@examDate				 date
 ,@legacyKey			 varchar(50)
 ,@orgSID					 int
 ,@examSID				 int
 ,@examOfferingSID int;

select top (1)
	@examIdentifier = x.ExamName
 ,@examDate				= xo.ExamTime
 ,@legacyKey			= xo.LegacyKey
 ,@orgSID					= xo.OrgSID
from
	dbo.Exam				 x
join
	dbo.ExamOffering xo on x.ExamSID = xo.ExamSID
where
	xo.ExamTime is not null and xo.OrgSID is not null
order by
	newid();

if @@rowcount = 0 or @examIdentifier is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin
	exec dbo.pExam#Lookup
		@ExamIdentifier = @examIdentifier
	 ,@ExamDate = @examDate
	 ,@LegacyKey = @legacyKey
	 ,@OrgSID = @orgsid output
	 ,@ExamSID = @examSID output
	 ,@ExamOfferingSID = @examOfferingSID output;

	select
		@examIdentifier	 [@ExamIdentifier]
	 ,@examDate				 [@ExamDate]
	 ,@legacyKey			 [@LegacyKey]
	 ,@orgSID					 [@OrgSID]
	 ,@examSID				 [@ExamSID]
	 ,@examOfferingSID [@ExamOfferingSID];
end;
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:01" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pExam#Lookup'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */
begin
	set nocount on;

	declare
		@errorNo	 int = 0					-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText nvarchar(4000);	-- message text (for business rule errors)

	set @ExamSID = @ExamSID; -- may be passed as in/out parameter;
	set @ExamOfferingSID = @ExamOfferingSID;

	begin try

		-- format and check parameters
		set @ExamIdentifier = ltrim(rtrim(@ExamIdentifier));
		set @LegacyKey = ltrim(rtrim(@LegacyKey));

		if @ExamIdentifier is null
		begin
			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = 'ExamIdentifier';

			raiserror(@errorText, 18, 1);
		end;

		-- lookup the identifiers; starting with legacy key where provided
		if @ExamSID is null and @LegacyKey is not null
		begin
			select @ExamSID	 = x.ExamSID from dbo.Exam x where x.LegacyKey = @LegacyKey;
		end;

		if @ExamOfferingSID is null and @LegacyKey is not null
		begin
			select
				@ExamOfferingSID = xo.ExamOfferingSID
			from
				dbo.ExamOffering xo
			where
				xo.LegacyKey = @LegacyKey;
		end;

		-- lookup by Exam Name or Vendor ID
		if @ExamSID is null
		begin
			select
				@ExamSID = x.ExamSID
			from
				dbo.Exam x
			where
				x.ExamName = @ExamIdentifier or x.VendorExamID = @ExamIdentifier; -- both implemented as UK's in the model
		end;

		if @ExamOfferingSID is null
		begin
			select
				@ExamOfferingSID = xo.ExamOfferingSID
			from
				dbo.ExamOffering xo
			where
				xo.VendorExamOfferingID = @ExamIdentifier;	-- also implemented as UK in the model
		end;

		-- use exam offering key to lookup exam 
		if @ExamOfferingSID is not null and @ExamSID is null
		begin
			select
				@ExamSID = xo.ExamSID
			from
				dbo.ExamOffering xo
			where
				xo.ExamOfferingSID = @ExamOfferingSID;
		end;

		-- where an exam date is provided, use that with the exam key and 
		-- organization where available, to locate the offering 
		if @ExamOfferingSID is null and @ExamSID is not null and @ExamDate is not null
		begin
			if
			(
				select
					count(1)
				from
					dbo.ExamOffering xo
				where
					xo.ExamSID = @ExamSID and cast(xo.ExamTime as date) = @ExamDate and (@OrgSID is null or xo.OrgSID = @OrgSID)
			) = 1 -- only select this offering if only 1 occurence is found for the criteria
			begin
				select
					@ExamOfferingSID = xo.ExamOfferingSID
				from
					dbo.ExamOffering xo
				where
					xo.ExamSID = @ExamSID and cast(xo.ExamTime as date) = @ExamDate and (@OrgSID is null or xo.OrgSID = @OrgSID);
			end;
		end;

		-- finally where both keys are found or provided
		-- ensure they point to same exam
		if @ExamSID is not null and @ExamOfferingSID is not null
		begin
			if not exists
			(
				select
					1
				from
					dbo.ExamOffering xo
				where
					xo.ExamOfferingSID = @ExamOfferingSID and xo.ExamSID = @ExamSID
			)
			begin
				exec sf.pMessage#Get
					@MessageSCD = 'ExamKeyConflict'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The exam identified on the exam-offering record (key=%1) does does not match the exam record found (key= %2).'
				 ,@Arg1 = @ExamOfferingSID
				 ,@Arg2 = @ExamSID;

				raiserror(@errorText, 18, 1);
			end;
		end;
	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);
end;
GO
