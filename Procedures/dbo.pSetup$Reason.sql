SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.[pSetup$Reason]
  @SetupUser nvarchar(75) -- user assigned to audit columns
 ,@Language	 char(2)			-- language to install for
 ,@Region		 varchar(10)	-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup Reason data
Notice   : Copyright © 2012 Softworks Group Inc.
Summary  : Sets dbo.Reason master table with starting (sample) values
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year  | Change Summary
				 : ------------ | ------------|-------------------------------------------------------------------------------------------
				 : Tim Edlund		| Jun 2017		| Initial Version			 
				
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------
This procedure inserts both codes required by the application and a some example records of optional reasons the user can create in
their configuration.  Deleting or updating any previously required system values must be handled in the procedure as well.

Pre-existing records are not deleted or updated by this procedure.

Maintenance Note
----------------
It is generally easier to create new reason records through the user interface.  To extract those reasons into the work table
structure - use the SELECT below:

select
	',(' + (case when r.IsLockedGroup = 1 then '@ON' else '@OFF' end) + ', ' + sf.fQuoteString(r.ReasonCode) + ', ' + sf.fQuoteString(r.ReasonName) + ', '
	+ sf.fQuoteString(isnull(r.ToolTip, r.ReasonName)) + ', ' + '(select rg.ReasonGroupSID from dbo.ReasonGroup rg where rg.ReasonGroupSCD = '''
	+ r.ReasonGroupSCD + '''))'
from
	dbo.vReason r
where
	r.ReasonCode like '%.%'
order by
	r.IsLockedGroup desc
 ,r.ReasonGroupSCD

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully.">
		<SQLScript>
		<![CDATA[
		
			exec dbo.pSetup$Reason
				 @SetupUser = 'system@alinityapp.com'
				,@Language = 'EN'
				,@Region = 'CA'

			select * from dbo.vReason

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$Reason'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo int = 0							-- 0 no error, if < 50000 SQL error, else business rule
	 ,@ON			 bit = cast(1 as bit) -- constant to reduce repetitive casting
	 ,@OFF		 bit = cast(0 as bit) -- constant to reduce repetitive casting
	 ,@maxRows int									-- row counter for loop
	 ,@i			 int;									-- loop index

	declare @work table
	(
		ID						 int					 not null identity(1, 1)
	 ,IsRequired		 bit					 not null default 0
	 ,ReasonGroupSID int					 not null
	 ,ReasonCode		 varchar(25)	 not null
	 ,ReasonName		 nvarchar(50)	 not null
	 ,ToolTip				 nvarchar(500) null
	);

	begin try

		-- load a work table with values to insert

		insert
			@work (IsRequired, ReasonCode, ReasonName, ToolTip, ReasonGroupSID) -- to obtain the formatted data below from an existing database, see SELECT statement in header
		values
-- SQL Prompt formatting off
		 (@OFF,	'APP.BLOCK.NO.EDU.ORG'			, 'Education organization not found', 'Education organization needs to be reviewed and added by administration.', (select rg.ReasonGroupSID from dbo.ReasonGroup rg where rg.ReasonGroupSCD = 'APP.BLOCK'))
		,(@OFF,	'APP.BLOCK.NO.EMP.ORG'			, 'Employer not found', 'Employer needs to be reviewed and added by administration.', (select rg.ReasonGroupSID from dbo.ReasonGroup rg where rg.ReasonGroupSCD = 'APP.BLOCK'))
		,(@ON,	'APP.BLOCK.DUPLICATE'				, 'Suspected duplicate', 'New applicant may be a duplicate (similar name exists)', (select rg.ReasonGroupSID from dbo.ReasonGroup rg where rg.ReasonGroupSCD = 'APP.BLOCK'))
		,(@OFF, 'AUDIT.WITHDRAWN.IR'				, 'Recently audited', 'Recently audited', (select rg.ReasonGroupSID from dbo.ReasonGroup rg where rg.ReasonGroupSCD = 'AUDIT.WITHDRAWN'))
		,(@OFF, 'AUDIT.WITHDRAWN.OTHER'			, 'Other', 'Other', (select rg.ReasonGroupSID from dbo.ReasonGroup rg where rg.ReasonGroupSCD = 'AUDIT.WITHDRAWN'))
		,(@OFF, 'FEE.ADJUSTMENT.HARDSHIP'		, 'Hardship', 'Unable to make the full payment', (select rg.ReasonGroupSID from dbo.ReasonGroup rg where rg.ReasonGroupSCD = 'FEE.ADJUSTMENT'))
		,(@OFF, 'FEE.ADJUSTMENT.ERROR'			, 'College error', 'Error in pricing was made by the college', (select rg.ReasonGroupSID from dbo.ReasonGroup rg where rg.ReasonGroupSCD = 'FEE.ADJUSTMENT'))
		,(@ON,	'INVOICE.CANCEL.WITHDRAWN'	, 'Invoice was associated with a withdrawn form.', 'Invoice was associated with a withdrawn form.', (select rg.ReasonGroupSID from dbo.ReasonGroup rg where rg.ReasonGroupSCD = 'INVOICE.CANCEL'))
		,(@OFF, 'INVOICE.CANCEL.DUP'				, 'Invoice is a duplicate', 'Invoice is a duplicate', (select rg.ReasonGroupSID from dbo.ReasonGroup rg where rg.ReasonGroupSCD = 'INVOICE.CANCEL'))
		,(@OFF, 'INVOICE.CANCEL.NOTREQ'			, 'Invoice not required (entered in error)', 'Invoice not required (entered in error)', (select rg.ReasonGroupSID from dbo.ReasonGroup rg where rg.ReasonGroupSCD = 'INVOICE.CANCEL'))
		,(@OFF, 'INVOICE.CANCEL.NOTCOL'			, 'Invoice is not collectible (lost contact)', 'Invoice is not collectible (lost contact)', (select rg.ReasonGroupSID from dbo.ReasonGroup rg where rg.ReasonGroupSCD = 'INVOICE.CANCEL'))
		,(@OFF, 'INVOICE.CANCEL.OTHER'			, 'Other', 'Other', (select rg.ReasonGroupSID from dbo.ReasonGroup rg where rg.ReasonGroupSCD = 'INVOICE.CANCEL'))
		,(@OFF, 'LPLAN.WITHDRAWN.RQTNOTMET'	, 'Requirement not met', 'Learning requirement has not been met for this registration year', (select rg.ReasonGroupSID from dbo.ReasonGroup rg where rg.ReasonGroupSCD = 'LPLAN.WITHDRAWN'))
		,(@OFF, 'LPLAN.WITHDRAWN.OTHER'			, 'Other', 'Other', (select rg.ReasonGroupSID from dbo.ReasonGroup rg where rg.ReasonGroupSCD = 'LPLAN.WITHDRAWN'))
		,(@ON,	'LPLAN.WITHDRAWN.REGCHG'		, 'Registration change to inactive', 'Member has changed to register not requiring CE reporting', (select rg.ReasonGroupSID from dbo.ReasonGroup rg where rg.ReasonGroupSCD = 'LPLAN.WITHDRAWN'))
		,(@ON,	'PAYMENT.CANCEL.NSF'				, 'Returned NSF', 'Payment returned for non-sufficient funds.  You can select to charge an admin fee for processing.', (select rg.ReasonGroupSID from dbo.ReasonGroup rg where rg.ReasonGroupSCD = 'PAYMENT.CANCEL'))
		,(@ON,	'PAYMENT.CANCEL.0'					, '$0 Payment', 'Payment cancelled because the amount is $0', (select rg.ReasonGroupSID from dbo.ReasonGroup rg where rg.ReasonGroupSCD = 'PAYMENT.CANCEL'))
		,(@ON,	'PAYMENT.CANCEL.DUPLICATE'	, 'Duplicate', 'Payment was entered/recorded multiple times.', (select rg.ReasonGroupSID from dbo.ReasonGroup rg where rg.ReasonGroupSCD = 'PAYMENT.CANCEL'))
		,(@ON,	'PAYMENT.CANCEL.DECLINED'		, 'Declined by Bank', 'Payment was declined by the bank (for reasons other than non-sufficient funds e.g. account closed). You can select to charge an admin fee for processing.', (select rg.ReasonGroupSID from dbo.ReasonGroup rg where rg.ReasonGroupSCD = 'PAYMENT.CANCEL'))
		,(@ON,	'PAYMENT.REFUND.DUPLICATE'	, 'Duplicate payment (refund)', 'Duplicate payment', (select rg.ReasonGroupSID from dbo.ReasonGroup rg where rg.ReasonGroupSCD = 'PAYMENT.REFUND'))
		,(@ON,	'PAYMENT.REFUND.OVERPAID'		, 'Overpayment', 'Overpayment', (select rg.ReasonGroupSID from dbo.ReasonGroup rg where rg.ReasonGroupSCD = 'PAYMENT.REFUND'))
		,(@ON,	'PAYMENT.UNAPPLY.DUPLICATE'	, 'Duplicate payment (un-apply)', 'Duplicate payment', (select rg.ReasonGroupSID from dbo.ReasonGroup rg where rg.ReasonGroupSCD = 'PAYMENT.UNAPPLY'))
		,(@ON,	'PAYMENT.UNAPPLY.CORRECT'		, 'Correction (applied to wrong invoice)', 'Correction (applied to wrong invoice)', (select rg.ReasonGroupSID from dbo.ReasonGroup rg where rg.ReasonGroupSCD = 'PAYMENT.UNAPPLY'))
		,(@OFF, 'PRFLUPDT.WITHDRAWN.NOCGE'	, 'No changes required', 'Profile is up to date and doesn''t require updating.', (select rg.ReasonGroupSID from dbo.ReasonGroup rg where rg.ReasonGroupSCD = 'PRFLUPDT.WITHDRAWN'))
		,(@OFF, 'PRFLUPDT.WITHDRAWN.OTHER'	, 'Other', 'Other', (select rg.ReasonGroupSID from dbo.ReasonGroup rg where rg.ReasonGroupSCD = 'PRFLUPDT.WITHDRAWN'))
		,(@OFF, 'PROFILE.AA.SPECIALIZATION'	, 'New specialization selected', 'New specialization has been requested to be added.', (select rg.ReasonGroupSID from dbo.ReasonGroup rg where rg.ReasonGroupSCD = 'AUTO.APPROVE.BLOCKED'))
		,(@OFF, 'PROFILE.AA.ADD.EDUCATION'	, 'New education added', 'New education added by member.', (select rg.ReasonGroupSID from dbo.ReasonGroup rg where rg.ReasonGroupSCD = 'AUTO.APPROVE.BLOCKED'))
		,(@OFF, 'PROFILE.AA.NAME.CHANGE'		, 'Pending name change', 'Name change has been added by registrant.', (select rg.ReasonGroupSID from dbo.ReasonGroup rg where rg.ReasonGroupSCD = 'AUTO.APPROVE.BLOCKED'))
		,(@OFF, 'PROFILE.AA.EMAIL.CHANGE'		, 'Primary email change', 'Email address has been modified.', (select rg.ReasonGroupSID from dbo.ReasonGroup rg where rg.ReasonGroupSCD = 'AUTO.APPROVE.BLOCKED'))
		,(@OFF, 'PROFILE.AA.MULTIPLE'				, 'Multiple block reasons', 'Multiple block reasons have been detected on the form.', (select rg.ReasonGroupSID from dbo.ReasonGroup rg where rg.ReasonGroupSCD = 'AUTO.APPROVE.BLOCKED'))
		,(@OFF, 'PROFILE.AA.ADDRESS.CHANGE'	, 'Pending address change', 'Address change has been added by registrant.', (select rg.ReasonGroupSID from dbo.ReasonGroup rg where rg.ReasonGroupSCD = 'AUTO.APPROVE.BLOCKED'))
		,(@OFF,	'PROFILE.AA.NO.EDU.ORG'	, 'Education organization not found', 'Education organization needs to be reviewed and added by administration.', (select rg.ReasonGroupSID from dbo.ReasonGroup rg where rg.ReasonGroupSCD = 'AUTO.APPROVE.BLOCKED'))
		,(@OFF,	'PROFILE.AA.NO.EMP.ORG'	, 'Employer not found', 'Employer needs to be reviewed and added by administration.', (select rg.ReasonGroupSID from dbo.ReasonGroup rg where rg.ReasonGroupSCD = 'AUTO.APPROVE.BLOCKED'))
		,(@OFF, 'REGCHANGE.NORENEWAL'				, 'Did Not Renew', 'Renewal not completed', (select rg.ReasonGroupSID from dbo.ReasonGroup rg where rg.ReasonGroupSCD = 'REGCHANGE'))
		,(@OFF, 'REGCHANGE.WITHDRAWN.RQT'		, 'Requirement not met', 'Registration change requirement has not been met for this registration year', (select rg.ReasonGroupSID from dbo.ReasonGroup rg where rg.ReasonGroupSCD = 'REGCHANGE.WITHDRAWN'))
		,(@OFF, 'REGCHANGE.WITHDRAWN.OTHER'	, 'Other', 'Other', (select rg.ReasonGroupSID from dbo.ReasonGroup rg where rg.ReasonGroupSCD = 'REGCHANGE.WITHDRAWN'))
		,(@ON,	'RENEWAL.AA.REGISTRANT'			, 'Auto-approval blocked for this registrant', 'Auto-approval blocked for this registrant', (select rg.ReasonGroupSID from dbo.ReasonGroup rg where rg.ReasonGroupSCD = 'AUTO.APPROVE.BLOCKED'))
		,(@ON,	'RENEWAL.AA.AUDIT'					, 'Incomplete audit is pending', 'Incomplete audit is pending', (select rg.ReasonGroupSID from dbo.ReasonGroup rg where rg.ReasonGroupSCD = 'AUTO.APPROVE.BLOCKED'))
		,(@ON,	'RENEWAL.AA.LATE'						, 'Form submitted after renewal period', 'Form submitted after renewal period', (select rg.ReasonGroupSID from dbo.ReasonGroup rg where rg.ReasonGroupSCD = 'AUTO.APPROVE.BLOCKED'))
		,(@ON,	'RENEWAL.AA.TOO.EARLY'			, 'Form submitted before renewal open time', 'Form submitted before renewal open time', (select rg.ReasonGroupSID from dbo.ReasonGroup rg where rg.ReasonGroupSCD = 'AUTO.APPROVE.BLOCKED'))
		,(@ON,	'RENEWAL.AA.PERSONAL'				, 'Answered YES to a question on personal declaration', 'Answered YES to a question on personal declaration', (select rg.ReasonGroupSID from dbo.ReasonGroup rg where rg.ReasonGroupSCD = 'AUTO.APPROVE.BLOCKED'))
		,(@ON,	'RENEWAL.AA.HOURS'					, 'Lack of practice hours', 'Lack of practice hours', (select rg.ReasonGroupSID from dbo.ReasonGroup rg where rg.ReasonGroupSCD = 'AUTO.APPROVE.BLOCKED'))
		,(@OFF, 'RENEWAL.WITHDRAWN.IR'			, 'Incorrect register chosen', 'Incorrect register chosen', (select rg.ReasonGroupSID from dbo.ReasonGroup rg where rg.ReasonGroupSCD = 'RENEWAL.WITHDRAWN'))
		,(@OFF, 'RENEWAL.WITHDRAWN.OTHER'		, 'Other', 'Other', (select rg.ReasonGroupSID from dbo.ReasonGroup rg where rg.ReasonGroupSCD = 'RENEWAL.WITHDRAWN'))
		,(@OFF, 'COMPLAINT.DISMISS.NOEVI'		, 'Lack of evidence', 'There is an insufficient amount of evidence to support the complaint', (select rg.ReasonGroupSID from dbo.ReasonGroup rg where rg.ReasonGroupSCD = 'COMPLAINT.DISMISS'))
		,(@OFF, 'COMPLAINT.DISMISS.RECANT'	, 'Recanted complaint', 'Complaintant recanted their complaint', (select rg.ReasonGroupSID from dbo.ReasonGroup rg where rg.ReasonGroupSCD = 'COMPLAINT.DISMISS'))
-- SQL Prompt formatting on

		select @maxRows	 = max(w.ID) from @work w;
		set @i = 0;

		-- update codes where name already exists

		update
			rsn
		set
			 rsn.ReasonCode = w.ReasonCode
			,rsn.UpdateUser = @SetupUser
			,rsn.UpdateTime = sysdatetimeoffset()
		from
			dbo.Reason rsn
		join
			@work			 w on rsn.ReasonName = w.ReasonName and rsn.ReasonGroupSID = w.ReasonGroupSID
		where
			rsn.ReasonCode <> w.ReasonCode;

		while @i < @maxRows
		begin

			set @i += 1;

			if not exists
			(
				select
					1
				from
					@work			 w
				join
					dbo.Reason r on w.ReasonCode = r.ReasonCode
				where
					w.ID = @i
			)
				insert
					dbo.Reason (ReasonGroupSID, ReasonCode, ReasonName, ToolTip, CreateUser, UpdateUser)
				select
					w.ReasonGroupSID
				 ,w.ReasonCode
				 ,w.ReasonName
				 ,w.ToolTip
				 ,@SetupUser
				 ,@SetupUser
				from
					@work w
				where
					w.ID = @i;

		end;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);

end;
GO
