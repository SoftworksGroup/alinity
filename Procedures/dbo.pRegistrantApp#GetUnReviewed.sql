SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[pRegistrantApp#GetUnReviewed]
	@PracticeRegisterSID		int						-- practice register (type of application) to restrict return dataset to (required)
 ,@RegistrantAppStatusSID int = null		-- status of application to restrict returned dataset to (null=eligible)
 ,@MaxRows								int = 9999999 -- maximum number of application records to return
as
/*********************************************************************************************************************************
Procedure : Registrant Application Review - Get Un-reviewed
Notice    : Copyright © 2017 Softworks Group Inc.
Summary   : Returns Registrant-Application rows (entity) at random for assignment to reviewers
-----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)				| Month Year  | Change Summary
				 : ----------------	|	----------	| --------------
				 : Tim Edlund				| May 2017    | Initial version
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is called from the UI to return a set of registrant application records to assign to reviewers.  The procedure
requires a practice register to be identified.  The returned records only include applications that do not have assignments.  If
a single assignment exists, then the record is excluded.  To get a second reviewer on a record that already has one reviewer
assigned, the individual form must be accessed and the assignment made from the Administrator area at the bottom of the form.

The procedure also accepts a parameter for the status of applications to include.  This will typically be either "Ready-For-Review"
(the SID from sf.FormStatus is passed) or left NULL in which all statuses where the form owner is ADMIN are included.

The final parameter limits the number of records returned. Where more forms are eligible than are requested for return, the data
set returned is random.  If no records exist which are eligible, then a error is returned.

Example
-------

<TestHarness>
	<Test Name="AdminStatuses" IsDefault="true" Description="Returns max=25 rows of application records eligible for assignment (all admin statuses)">
		<SQLScript>
			<![CDATA[

declare
		@practiceRegisterSID			int

select top 1
	@practiceRegisterSID = pr.PracticeRegisterSID
from
	dbo.PracticeRegister pr
where
	pr.IsActive = 1
order by
	newid()

exec dbo.pRegistrantApp#GetUnReviewed
		@PracticeRegisterSID	= @practiceRegisterSID
	,	@MaxRows							= 25

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:02" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.pRegistrantApp#GetUnReviewed'
-------------------------------------------------------------------------------------------------------------------------------- */

set nocount on;

begin

	declare
		@errorNo	 int					 = 0								-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText nvarchar(4000)										-- message text (for business rule errors)
	 ,@blankParm nvarchar(100)										-- error checking buffer for required parameters

	begin try

		-- check parameters

		if @PracticeRegisterSID is null
		begin
			set @blankParm = N'@PracticeRegisterSID';
		end

		if @blankParm is not null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = @blankParm;

			raiserror(@errorText, 18, 1);

		end;

		select top (@MaxRows)
			--!<ColumnList DataSource="dbo.vRegistrantApp#Search" Alias="ra">
			 ra.RegistrantAppSID
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
			,ra.PracticeRegisterLabel
			,ra.PracticeRegisterSectionLabel
			,ra.PracticeRegisterSID
			,ra.PracticeRegisterSectionSID
			,ra.NextFollowUp
			,ra.IsFollowUpDue
			,ra.FormOwnerSCD
			,ra.FormOwnerLabel
			,ra.LastStatusChangeUser
			,ra.LastStatusChangeTime
			,ra.FormStatusSID
			,ra.RegistrantAppStatusSCD
			,ra.RegistrantAppStatusLabel
			,ra.IsFinal
			,ra.IsInProgress
			,ra.RecommendationLabel
			,ra.DaysSinceLastUpdate
			,ra.PersonAddressBlockForHTML
			,ra.PersonAddressBlockForPrint
			,ra.RegistrantAppXID
			,ra.LegacyKey
		--!</ColumnList>
		from
			dbo.vRegistrantApp#Search ra
		join
			sf.FormStatus							fs on ra.FormStatusSID		 = fs.FormStatusSID
																			and fs.FormStatusSID = isnull(@RegistrantAppStatusSID, fs.FormStatusSID)
																			and fs.FormStatusSCD <> 'UNLOCKED'
		join
			sf.FormOwner							fo on fs.FormOwnerSID			 = fo.FormOwnerSID and fo.FormOwnerSCD = 'ADMIN'
		left outer join
			dbo.RegistrantAppReview		rar on ra.RegistrantAppSID = rar.RegistrantAppSID -- check for existence of reviews already assigned
		where
			ra.PracticeRegisterSID = @PracticeRegisterSID -- restrict to given practice register									
			and rar.RegistrantAppReviewSID is null
		order by
			newid();	-- randomize top selection

	end try
	begin catch
		if @@trancount > 0 rollback;
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);

end;
GO
