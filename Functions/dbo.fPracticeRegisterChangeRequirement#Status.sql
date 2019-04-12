SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fPracticeRegisterChangeRequirement#Status
(
	@RegistrantSID												int -- key of member to check requirement for
 ,@PracticeRegisterChangeRequirementSID int -- key of requirement to check
)
returns @requirementStatus table
(
	RegistrantLabel							 nvarchar(75)	 not null
 ,RegistrationRequirementCode	 varchar(15)	 not null
 ,RegistrationRequirementLabel nvarchar(35)	 not null
 ,RequirementTypeExtended			 nvarchar(75)	 not null
 ,ResponseDetails							 nvarchar(250) null
 ,IsRequirementMet						 bit					 not null
 ,PersonSID										 int					 not null
 ,RegistrationRequirementSID	 int					 not null
 ,PersonDocSID								 int					 null -- key of latest document of the required type
 ,RegistrantExamSID						 int					 null -- key of latest exam of the required type
)
as
/*********************************************************************************************************************************
TableF	: Practice Register Change Requirement - Status
Notice	: Copyright © 2018 Softworks Group Inc.
Summary	: Returns a table summarizing compliance with a given registration change requirement
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Nov 2018		|	Initial version 

Comments	
--------
This function is called in the user interface to determine if the member is compliant with a specific requirement applied to 
the registration change in progress.  Note that this function is not targeted at (dbo) RegistrationChange forms uniquely but
rather all form-types which change the members registration included renewal to the same register.

The function requires that the member to run the check for be identified through their registrant key and that a specific
requirement - associated with the Register they are moving to - be identified. This requires that the configuration include
setup of Registration-Change-Requirement records linked to Practice-Registers through the Practice-Register-Change-Requirement
table. 

The function returns a single row data set summarizes a description of the requirement and the member's compliance with it.

As of this writing, 3 requirement types are supported: Document Types (including expiry months), Exams (including pass/fail
results), and Declarations.  

Limitation
----------
As of the current version, Declarations are supported but not evaluated. The function does not establish whether the declaration
has been complied with.  Declarations are stored within the XML of the form in the present version and since these forms are
unique to each configuration, no parsing is carried out.  Compliance with declarations must be established within the form logic.

Example
-------
<TestHarness>
	<Test Name="Document" Description="Calls function for DOCUMENT requirement selected at random">
		<SQLScript>
			<![CDATA[
declare
	@registrantSID												int
 ,@practiceRegisterChangeRequirementSID int;

select top (1)
	@registrantSID												= r.RegistrantSID
 ,@practiceRegisterChangeRequirementSID = prcr.PracticeRegisterChangeRequirementSID
from
	dbo.PracticeRegisterChangeRequirement prcr
join
	dbo.RegistrationRequirement						rreq on prcr.RegistrationRequirementSID = rreq.RegistrationRequirementSID
join
	dbo.PersonDoc													pd on rreq.PersonDocTypeSID							= pd.PersonDocTypeSID
join
	dbo.Registrant												r on pd.PersonSID												= r.PersonSID
order by
	newid();

if @@rowcount = 0 or @registrantSID is null or @practiceRegisterChangeRequirementSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin
	select
		x.*
	from
		dbo.fPracticeRegisterChangeRequirement#Status(@registrantSID, @practiceRegisterChangeRequirementSID) x;
end;
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:02"/>
		</Assertions>
	</Test>
	<Test Name="Exam" Description="Calls function for EXAM requirement selected at random">
		<SQLScript>
			<![CDATA[
declare
	@registrantSID												int
 ,@practiceRegisterChangeRequirementSID int;

select top (1)
	@registrantSID												= rex.RegistrantSID
 ,@practiceRegisterChangeRequirementSID = prcr.PracticeRegisterChangeRequirementSID
from
	dbo.PracticeRegisterChangeRequirement prcr
join
	dbo.RegistrationRequirement						rreq on prcr.RegistrationRequirementSID = rreq.RegistrationRequirementSID
join
	dbo.RegistrantExam										rex on rreq.ExamSID											= rex.ExamSID
order by
	newid();

if @@rowcount = 0 or @registrantSID is null or @practiceRegisterChangeRequirementSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin
	select
		x.*
	from
		dbo.fPracticeRegisterChangeRequirement#Status(@registrantSID, @practiceRegisterChangeRequirementSID) x;
end;		
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:02"/>
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
  @ObjectName = 'fPracticeRegisterChangeRequirement#Status'
 ,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		@OFF													bit					 = cast(0 as bit) -- constant for bit comparison = 0
	 ,@ON														bit					 = cast(1 as bit) -- constant for bit comparison = 0
	 ,@registrantLabel							nvarchar(75)
	 ,@registrationRequirementCode	varchar(15)	 = 'UNKNOWN'
	 ,@registrationRequirementLabel nvarchar(35)
	 ,@requirementTypeExtended			nvarchar(75)
	 ,@responseDetails							nvarchar(250)
	 ,@isRequirementMet							bit					 = cast(0 as bit)
	 ,@personSID										int
	 ,@registrationRequirementSID		int
	 ,@personDocTypeSID							int
	 ,@examSID											int
	 ,@isDeclaration								bit
	 ,@expiryMonths									smallint
	 ,@today												date				 = sf.fToday()		-- current date in client timezone;
	 ,@personDocSID									int														-- key of latest document of the required type
	 ,@registrantExamSID						int;													-- key of latest exam of the required type

	-- load return values describing the requirement

	select
		@registrantLabel							= dbo.fRegistrant#Label(p.LastName, p.FirstName, p.MiddleNames, r.RegistrantNo, 'REGISTRATION')
	 ,@registrationRequirementLabel = rreq.RegistrationRequirementLabel
	 ,@personSID										= r.PersonSID
	 ,@registrationRequirementSID		= prcr.RegistrationRequirementSID
	 ,@personDocTypeSID							= rreq.PersonDocTypeSID
	 ,@examSID											= rreq.ExamSID
	 ,@isDeclaration								= cast(case when rrt.RegistrationRequirementTypeCode like 'S!%.DEC' then 1 else 0 end as bit)
	 ,@expiryMonths									= isnull(prcr.ExpiryMonths, rreq.ExpiryMonths)
	 ,@requirementTypeExtended			=
			rrt.RegistrationRequirementTypeLabel + N' | '
			+ (case
					 when rrt.RegistrationRequirementTypeCode like 'S!%.DEC' then 'Declaration: ' + isnull(left(rreq.RequirementDescription, 24), '(no description)')
					 when rreq.PersonDocTypeSID is not null then
						 pdt.PersonDocTypeLabel + ' | Expiry: ' + isnull(ltrim(isnull(prcr.ExpiryMonths, rreq.ExpiryMonths)) + ' months', '(not specified)')
					 when rreq.ExamSID is not null then 'Exam: ' + ex.ExamName + ' | Passing score: ' + isnull(ltrim(ex.PassingScore), '(not specified)')
					 else 'ERROR: Type Not Supported'
				 end
				)
	from
		dbo.PracticeRegisterChangeRequirement prcr
	join
		dbo.Registrant												r on r.RegistrantSID											 = @RegistrantSID
	join
		sf.Person															p on r.PersonSID													 = p.PersonSID
	join
		dbo.RegistrationRequirement						rreq on prcr.RegistrationRequirementSID		 = rreq.RegistrationRequirementSID
	join
		dbo.RegistrationRequirementType				rrt on rreq.RegistrationRequirementTypeSID = rrt.RegistrationRequirementTypeSID
	left outer join
		dbo.PersonDocType											pdt on rreq.PersonDocTypeSID							 = pdt.PersonDocTypeSID
	left outer join
		dbo.Exam															ex on rreq.ExamSID												 = ex.ExamSID
	where
		prcr.PracticeRegisterChangeRequirementSID = @PracticeRegisterChangeRequirementSID;

	-- check for responses to the requirement based on type

	if @personDocTypeSID is not null and @personSID is not null
	begin
		set @registrationRequirementCode = 'DOCUMENT';

		select top (1)
			@personDocSID = pd.PersonDocSID -- retrieve latest document of the required type
		from
			dbo.PersonDoc pd
		where
			pd.PersonSID = @personSID and pd.PersonDocTypeSID = @personDocTypeSID
		order by
			isnull(pd.ExpiryDate, pd.CreateTime) desc;

		if @personDocSID is null
		begin
			set @responseDetails = N'Document not on file';
		end;
		else
		begin

			select
				@responseDetails	=
				N'Document Provided  | Title: ' + pd.DocumentTitle + N' | Expiry: ' + (case
																																								 when pd.ExpiryDate is not null then format(pd.ExpiryDate, 'dd-MMM-yyyy')
																																								 when @expiryMonths = 0 then 'None'
																																								 else format(dateadd(month, @expiryMonths, pd.CreateTime), 'dd-MMM-yyyy')
																																							 end
																																							) + N' | '
				+ (case
						 when pd.ExpiryDate is not null and pd.ExpiryDate > @today then 'Not Expired'
						 when @expiryMonths = 0 then 'Not Expired'
						 when dateadd(month, @expiryMonths, pd.CreateTime) > @today then 'Not Expired'
						 else 'EXPIRED'
					 end
					)
			 ,@isRequirementMet = (case
															 when pd.ExpiryDate is not null and pd.ExpiryDate > @today then @ON
															 when @expiryMonths = 0 then @ON
															 when dateadd(month, @expiryMonths, pd.CreateTime) > @today then @ON
															 else @OFF
														 end
														)
			from
				dbo.PersonDoc pd
			where
				pd.PersonDocSID = @personDocSID;

		end;

	end;
	else if @examSID is not null and @personSID is not null
	begin
		set @registrationRequirementCode = 'EXAM';

		select top (1)
			@registrantExamSID = rex.RegistrantExamSID	-- retrieve latest exam of the required type
		from
			dbo.RegistrantExam rex
		where
			rex.RegistrantSID = @RegistrantSID and rex.ExamSID = @examSID
		order by
			rex.ExamDate desc;

		if @registrantExamSID is null
		begin
			set @responseDetails = N'Exam not on file';
		end;
		else
		begin

			select
				@responseDetails	=
				N'Exam Recorded | ' + ex.ExamName + N' | Date: ' + format(rex.ExamDate, 'dd-MMM-yyyy') + N' | Score: ' + isnull(ltrim(rex.Score), '(no score)')
				+ N' | Result: ' + exr.ExamStatusLabel
			 ,@isRequirementMet = (case when exr.ExamStatusSCD = 'PASSED' then @ON else @OFF end)
			from
				dbo.RegistrantExam rex
			join
				dbo.Exam					 ex on rex.ExamSID				= ex.ExamSID
			join
				dbo.ExamStatus		 exr on rex.ExamStatusSID = exr.ExamStatusSID
			where
				rex.RegistrantExamSID = @registrantExamSID;

		end;

	end;
	else if @isDeclaration = @ON and @personSID is not null
	begin
		set @registrationRequirementCode = 'EXAM';
		set @responseDetails = N'Declaration | (compliance not evaluated - check form)';
		set @isRequirementMet = @ON; -- assume compliance
	end;

	insert
		@requirementStatus
	(
		RegistrantLabel
	 ,RegistrationRequirementCode
	 ,RegistrationRequirementLabel
	 ,RequirementTypeExtended
	 ,ResponseDetails
	 ,IsRequirementMet
	 ,PersonSID
	 ,RegistrationRequirementSID
	 ,PersonDocSID
	 ,RegistrantExamSID
	)
	values
	(
		isnull(@registrantLabel, 'ERROR: Invalid @RegistrantSID'), @registrationRequirementCode
	 ,isnull(@registrationRequirementLabel, 'ERROR: @PRChangeRequirementSID'), isnull(@requirementTypeExtended, 'ERROR: @PRChangeRequirementSID')
	 ,@responseDetails, @isRequirementMet, isnull(@personSID, 0), isnull(@registrationRequirementSID, 0), @personDocSID, @registrantExamSID
	);

	return;

end;
GO
