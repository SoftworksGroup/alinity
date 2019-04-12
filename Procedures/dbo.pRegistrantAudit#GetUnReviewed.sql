SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrantAudit#GetUnReviewed]
		@RegistrationYear					smallint																		-- the audit year to select from (required)
	,	@AuditTypeSID							int																					-- type of audit to restrict return dataset to (required)
	,	@RegistrantAuditStatusSID	int = null																	-- status of audit to restrict returned dataset to (null=eligible)
	,	@MaxRows									int	= 9999999																-- maximum number of audit records to return

as
/*********************************************************************************************************************************
Procedure : Registrant Audit Review - Get Un-reviewed
Notice    : Copyright © 2017 Softworks Group Inc.
Summary   : Returns Registrant-Audit rows (entity) at random for assignment to reviewers
-----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)				| Month Year  | Change Summary
				 : ----------------	|	----------	| --------------
				 : Tim Edlund				| May 2017    | Initial version
				 : Cory Ng					| Aug 2017		| Updated to always return "ready for review" audits even if reviews are already assigned
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is called from the UI to return a set of registrant audit records to assign to reviewers.  The procedure requires
a registration year and type of audit be identified - e.g. Competence-Full, Competence-Basic, Practice-Hours, etc.  The returned
records only include audits that do not have assignments.  If a single assignment exists, then the record is excluded.  To get a
second reviewer on a record that already has one reviewer assigned, the individual form must be accessed and the assignment made
from the Administrator area at the bottom of the form.

The procedure also accepts a parameter for the status of audit to include.  This will typically be either "Ready-For-Review"
(the SID from sf.FormStatus is passed) or left NULL in which all statuses where the form owner is ADMIN are included.

The final parameter limits the number of records returned. Where more forms are eligible than are requested for return, the data
set returned is random.  If no records exist which are eligible, then a error is returned.

Example
-------

<TestHarness>
	<Test Name="AdminStatuses" IsDefault="true" Description="Returns max=25 rows of audit records eligible for assignment (all admin statuses)">
		<SQLScript>
			<![CDATA[

declare
		@auditTypeSID							int
	,	@registrantAuditStatusSID	int
	, @registrationYear					smallint = year(sysdatetime())

select top 1
	@auditTypeSID = at.AuditTypeSID
from
	dbo.AuditType at
where
	at.IsActive = 1
order by
	newid()

exec dbo.pRegistrantAudit#GetUnReviewed
		@RegistrationYear = @registrationYear
	,	@AuditTypeSID			= @auditTypeSID
	,	@MaxRows					= 25

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:02" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.pRegistrantAudit#GetUnReviewed'
-------------------------------------------------------------------------------------------------------------------------------- */

set nocount on

begin

	declare
			@errorNo											int = 0																-- 0 no error, <50000 SQL error, else business rule
		,	@errorText										nvarchar(4000)												-- message text (for business rule errors)
		,	@blankParm										nvarchar(100)													-- error checking buffer for required parameters
		,	@ON														bit = cast(1 as bit)									-- used on bit comparisons to avoid multiple casts
		,	@OFF													bit = cast(0 as bit)									-- used on bit comparisons to avoid multiple casts	

	begin try

		-- check parameters

		if @AuditTypeSID	is null set @blankParm = '@AuditTypeSID'

		if @blankParm is not null
		begin
			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= @blankParm

			raiserror(@errorText, 18, 1)
		
		end

		select top (@MaxRows)
			--!<ColumnList DataSource="dbo.vRegistrantAudit#Search" Alias="ra">
			 ra.RegistrantAuditSID
			,ra.RegistrantSID
			,ra.RegistrantNo
			,ra.FileAsName
			,ra.RegistrantLabel
			,ra.RegistrationYear
			,ra.PersonSID
			,ra.FirstName
			,ra.CommonName
			,ra.MiddleNames
			,ra.LastName
			,ra.BirthDate
			,ra.HomePhone
			,ra.MobilePhone
			,ra.EmailAddress
			,ra.AuditTypeSID
			,ra.AuditTypeLabel
			,ra.IsFollowUpDue
			,ra.FormOwnerSID
			,ra.FormOwnerSCD
			,ra.FormOwnerLabel
			,ra.LastStatusChangeUser
			,ra.LastStatusChangeTime
			,ra.FormStatusSID
			,ra.RegistrantAuditStatusSCD
			,ra.RegistrantAuditStatusLabel
			,ra.IsFinal
			,ra.IsInProgress
			,ra.RecommendationLabel
			,ra.DaysSinceLastUpdate
			,ra.RegistrantAuditXID
			,ra.LegacyKey
			--!</ColumnList>
		from
			dbo.vRegistrantAudit#Search	ra
		join
			sf.FormStatus								fs on ra.FormStatusSID = fs.FormStatusSID and fs.FormStatusSID = isnull(@RegistrantAuditStatusSID, fs.FormStatusSID) and fs.FormStatusSCD <> 'UNLOCKED'
		join
			sf.FormOwner								fo on fs.FormOwnerSID = fo.FormOwnerSID and fo.FormOwnerSCD = 'ADMIN'
		left outer join
			dbo.RegistrantAuditReview		rar on ra.RegistrantAuditSID = rar.RegistrantAuditSID							-- check for existence of reviews already assigned
		where
			ra.RegistrationYear = @RegistrationYear																												-- restrict to the specified year and audit type
		and
			ra.AuditTypeSID = @AuditTypeSID																																
		and
		(
			fs.FormStatusSCD = 'READY'																																		-- always return row if ready for review or else only if no reviews assigned
		or
			rar.RegistrantAuditReviewSID is null		
		)
		order by
			newid()																																												-- randomize top selection

	end try

	begin catch
		if @@trancount > 0 rollback
		exec @errorNo = sf.pErrorRethrow																																-- catch the error, rollback if pending, and re-throw
	end catch

	return(@errorNo)

end
GO
