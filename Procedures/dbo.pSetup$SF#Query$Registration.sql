SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.[pSetup$SF#Query$Registration]
	@SetupUser nvarchar(75) -- user assigned to audit columns
as
/*********************************************************************************************************************************
Sproc    : Setup Query for Registration management
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : Synchronizes the sf.Query table for product queries used in management of Registrations
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Sep 2018		|	Initial version

Comments  
--------
This procedure sets up product queries used to manage Registrations.  The data is setup in the sf.Query table. Product queries
related to the entity which are no longer supported/required are removed from the table and any new queries are added.  Parameter 
details for existing queries are updated to ensure they match the current query syntax defined in the execution procedure:
dbo.pQuery#Execute#Registration.

The procedure also calls a framework utility to verify that a one-to-one match exists for the query codes defined for setup and 
for which query syntax is defined in the query#execute subroutine. If any discrepancies are found an error is raised and no changes
to the sf.Query table are saved.  Details of the 2 code lists are returned as a data set.

Known Limitations
-----------------
For most locations in the system "label" column values can be customized by the end-user directly through the user interface.  For 
the Query table, however, any customized entries are overwritten as pSetup is executed and calls to this procedure take place. This 
ensures queries are named consistently so that they are recognizable for (video) training.  If unique labels are required for a 
client, implement them in the client's post deployment script using the Query Code to locate records for update.

Example:
--------
<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully.">
		<SQLScript>
		<![CDATA[

exec dbo.pSetup$SF#Query$Registration
	@SetupUser = N'system@softworksgroup.com'

if @@error = 0
begin

	select
		q.*
	from
		sf.Query						 q
	join
		sf.ApplicationPage	 ap on q.ApplicationPageSID		 = ap.ApplicationPageSID
	join
		sf.ApplicationEntity ae on ap.ApplicationEntitySID = ae.ApplicationEntitySID
	where
		ae.ApplicationEntitySCD = 'dbo.Registration'
	order by
		q.QueryLabel;

end;

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$SF#Query$Registration'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo											 int					 = 0											-- 0 no error, if < 50000 SQL error, else business rule
	 ,@errorText										 nvarchar(4000)													-- message text (for business rule errors)
	 ,@OFF													 bit					 = cast(0 as bit)					-- constant for bit comparisons = 0
	 ,@tranCount										 int					 = @@trancount						-- determines whether a wrapping transaction exists
	 ,@procName											 nvarchar(128) = object_name(@@procid)	-- name of currently executing procedure
	 ,@xState												 int																		-- error state detected in catch block
	 ,@defaultCategorySID						 int																		-- categories to put queries in:
	 ,@renewalCategorySID						 int
	 ,@reinstatementCategorySID			 int
	 ,@registrationChangeCategorySID int
	 ,@applicationCategorySID				 int
	 ,@applicationPageSID						 int																		-- key of the application page to associate queries with
	 ,@parametersDoc								 xml;																		-- buffer to hold parameter definitions for query

	declare @setup table -- interim storage for query setup data
	(
		ID											 int					 identity(1, 1)
	 ,QueryCategorySID				 int					 not null
	 ,QueryCode								 varchar(30)	 not null
	 ,QueryLabel							 nvarchar(35)	 not null
	 ,IsApplicationPageDefault bit					 not null default cast(0 as bit)
	 ,ToolTip									 nvarchar(250) not null
	 ,QueryParameters					 xml					 null
	);

	begin try

		-- process DB changes as a transaction
		-- to enable partial rollback on error

		if @tranCount = 0
		begin
			begin transaction; -- no wrapping transaction
		end;
		else
		begin
			save transaction @procName; -- previous trx pending - create save point
		end;

		select
			@defaultCategorySID						 = (case when qc.QueryCategoryCode = 'S!DEFAULT' then qc.QueryCategorySID else @defaultCategorySID end)
		 ,@renewalCategorySID						 = (case when qc.QueryCategoryCode = 'S!RENEWAL' then qc.QueryCategorySID else @renewalCategorySID end)
		 ,@reinstatementCategorySID			 = (case when qc.QueryCategoryCode = 'S!REINSTATEMENT' then qc.QueryCategorySID else @reinstatementCategorySID end)
		 ,@registrationChangeCategorySID = (case
																					when qc.QueryCategoryCode = 'S!REGISTRATION.CHANGE' then qc.QueryCategorySID
																					else @registrationChangeCategorySID
																				end
																			 )
		 ,@applicationCategorySID				 = (case when qc.QueryCategoryCode = 'S!APPLICATION' then qc.QueryCategorySID else @applicationCategorySID end)
		from
			sf.QueryCategory qc;

		select
			@applicationPageSID = ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'RegistrationList';

		if @defaultCategorySID is null or @applicationPageSID is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotConfigured'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Please complete the missing configuration before trying again or contact the Help Desk for assistance.'
			 ,@Arg1 = '"Query Category or Application Page"';

			raiserror(@errorText, 17, 1);

		end;

		-- insert each query with parameter definitions
		-- into the setup table

		----- All (for year) ----- 

		set @parametersDoc = null;

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@defaultCategorySID, 'S!REG.ALL', @parametersDoc, 'All', @OFF, N'Returns all registrations for the selected year'
		);

		----- All Active  -----

		set @parametersDoc = null;

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@defaultCategorySID, 'S!REG.ALL.ACTIVE', @parametersDoc, 'All active', @OFF, N'Returns all active-practice registrations for the selected year'
		);

		----- All Renewing  -----

		set @parametersDoc = null;

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@defaultCategorySID, 'S!REG.ALL.RENEWING', @parametersDoc, 'All renewing', @OFF
		 ,N'Returns all registrations for the selected year where renewal is enabled'
		);

		----- All Term Based -----

		set @parametersDoc = null;

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@defaultCategorySID, 'S!REG.ALL.TERM.BASED', @parametersDoc, 'All term-based', @OFF
		 ,N'Returns all registrations for the selected year where the registration type has a fixed term (annual or permits)'
		);

		----- Open forms ----- (SYSTEM DEFAULT)

		set @parametersDoc = null;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'RegFormTypeSID'
		 ,@ParametersDoc = @parametersDoc output;

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@defaultCategorySID, 'S!REG.OPEN.FORMS', @parametersDoc, 'Open forms', @OFF, N'Returns open forms created in the selected year'
		);

		----- By Status  -----

		set @parametersDoc = null;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'RegFormTypeSID'
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'FormStatusSID'
		 ,@Cell = 2
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'CultureSID'
		 ,@Cell = 3
		 ,@IsMandatory = 'false'
		 ,@ParametersDoc = @parametersDoc output;

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@defaultCategorySID, 'S!REG.BY.STATUS', @parametersDoc, 'By status', @OFF, N'Returns records matching the selected status'
		);

		----- By Register -----

		set @parametersDoc = null;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'PracticeRegisterSID'
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'CultureSID'
		 ,@Cell = 2
		 ,@IsMandatory = 'false'
		 ,@ParametersDoc = @parametersDoc output;

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@defaultCategorySID, 'S!REG.BY.REGISTER', @parametersDoc, 'By register', @OFF, N'Returns records matching the selected practice register'
		);

		----- FollowUp -----

		set @parametersDoc = null;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'RegFormTypeSID'
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'EndDate'
		 ,@Label = 'Due on/before'
		 ,@Cell = 2
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'CultureSID'
		 ,@Cell = 3
		 ,@IsMandatory = 'false'
		 ,@ParametersDoc = @parametersDoc output;

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@defaultCategorySID, 'S!REG.FOLLOWUP', @parametersDoc, 'Follow-up due', @OFF
		 ,N'Returns records where a follow-up is required before a provided cut off date'
		);

		----- Abandoned -----

		set @parametersDoc = null;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'RegFormTypeSID'
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'EndDate'
		 ,@Label = 'No update after'
		 ,@Cell = 2
		 ,@DefaultValue = '[@@Date]-7'
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'CultureSID'
		 ,@Cell = 3
		 ,@IsMandatory = 'false'
		 ,@ParametersDoc = @parametersDoc output;

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@defaultCategorySID, 'S!REG.ABANDONED', @parametersDoc, 'Abandoned', @OFF
		 ,N'Returns records where the form is open and has not been updated after a provided cut-off date'
		);

		----- Approved -----

		set @parametersDoc = null;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'RegFormTypeSID'
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'StartDate'
		 ,@Cell = 2
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'EndDate'
		 ,@Cell = 3
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'IsPaidOnly'
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'CultureSID'
		 ,@Cell = 2
		 ,@IsMandatory = 'false'
		 ,@ParametersDoc = @parametersDoc output;

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@defaultCategorySID, 'S!REG.APPROVED', @parametersDoc, 'Approved', @OFF, N'Returns forms approved in a date range'
		);

		----- Card not printed -----

		set @parametersDoc = null;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'PracticeRegisterSID'
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'CutoffDate'
		 ,@Label = 'Registration creation cut off'
		 ,@IsMandatory = 'false'
		 ,@Cell = 2
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'CultureSID'
		 ,@Cell = 3
		 ,@IsMandatory = 'false'
		 ,@ParametersDoc = @parametersDoc output;

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@defaultCategorySID, 'S!REG.CARD.NOT.PRINTED', @parametersDoc, 'Card not printed', @OFF
		 ,N'Returns active-practice type registrations where a card-printed date been not been recorded'
		);

		----- Card printed -----

		set @parametersDoc = null;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'PracticeRegisterSID'
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'StartDate'
		 ,@Cell = 2
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'EndDate'
		 ,@Cell = 3
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'CultureSID'
		 ,@IsMandatory = 'false'
		 ,@ParametersDoc = @parametersDoc output;

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@defaultCategorySID, 'S!REG.CARD.PRINTED', @parametersDoc, 'Card printed', @OFF
		 ,N'Returns active-practice type registrations where cards were printed in a date range'
		);

		----- Expired -----

		set @parametersDoc = null;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'PracticeRegisterSID'
		 ,@IsMandatory = 'false'
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'CultureSID'
		 ,@IsMandatory = 'false'
		 ,@ParametersDoc = @parametersDoc output;

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@defaultCategorySID, 'S!REG.EXPIRED', @parametersDoc, 'Expired license', @OFF
		 ,N'Returns registrations where the member''s last license or permit has expired.'
		);

		----- Find By Phone -----

		set @parametersDoc = null;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'PhoneNumber'
		 ,@ParametersDoc = @parametersDoc output;

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@defaultCategorySID, 'S!REG.FIND.BY.PHONE', @parametersDoc, 'Find by phone', @OFF
		 ,N'Returns records where the person''s home or mobile phone matches any portion of a number provided'
		);

		----- Find By Address -----

		set @parametersDoc = null;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'StreetAddress'
		 ,@IsMandatory = 'false'
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'CitySID'
		 ,@IsMandatory = 'false'
		 ,@Cell = 2
		 ,@ParametersDoc = @parametersDoc output;

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@defaultCategorySID, 'S!REG.FIND.BY.ADDRESS', @parametersDoc, 'Find by address', @OFF
		 ,N'Returns records where the person''s address matches any portion of a street address provided'
		);

		----- Find By Location -----

		set @parametersDoc = null;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'PracticeRegisterSID'
		 ,@IsMandatory = 'false'
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'CitySID'
		 ,@IsMandatory = 'false'
		 ,@Cell = 2
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'StateProvinceSID'
		 ,@IsMandatory = 'false'
		 ,@Cell = 3
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'RegionSID'
		 ,@IsMandatory = 'false'
		 ,@Cell = 1
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'CultureSID'
		 ,@Cell = 2
		 ,@IsMandatory = 'false'
		 ,@ParametersDoc = @parametersDoc output;

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@defaultCategorySID, 'S!REG.FIND.BY.LOCATION', @parametersDoc, 'Find by location', @OFF
		 ,N'Returns records where the person''s location matches either the city, province, or region provided'
		);

		----- Recently Updated -----

		set @parametersDoc = null;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'RecentDateTime'
		 ,@Cell = 2
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'IsUpdatedByMeOnly'
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'CultureSID'
		 ,@Cell = 3
		 ,@IsMandatory = 'false'
		 ,@ParametersDoc = @parametersDoc output;

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@defaultCategorySID, 'S!REG.RECENTLY.UPDATED', @parametersDoc, 'Recently updated', @OFF
		 ,N'Returns registration records that were recently updated (and optionally restricted to updates made by the logged in user)'
		);

		----- Renewal review reasons ------

		set @parametersDoc = null;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'RenewalReasonSID'
		 ,@IsMandatory = 'false'
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'CultureSID'
		 ,@Cell = 3
		 ,@IsMandatory = 'false'
		 ,@ParametersDoc = @parametersDoc output;

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@renewalCategorySID, 'S!REG.RENEWAL.RVW.REQUIRED', @parametersDoc, 'Review required (renewal)', @OFF
		 ,N'Returns records matching the selected review (blocking) reason'
		);

		----- Renewal not started ------

		set @parametersDoc = null;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'PracticeRegisterSID'
		 ,@IsMandatory = 'false'
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'IsPADSubscriber'
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'IsNotPADSubscriber'
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'CultureSID'
		 ,@IsMandatory = 'false'
		 ,@ParametersDoc = @parametersDoc output;

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@renewalCategorySID, 'S!REG.RENEWAL.NOT.STARTED', @parametersDoc, 'Not started', @OFF, N'Returns registrations where a renewal has not been started'
		);

		----- Renewal in progress ------

		set @parametersDoc = null;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'PracticeRegisterSID'
		 ,@IsMandatory = 'false'
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'CultureSID'
		 ,@IsMandatory = 'false'
		 ,@ParametersDoc = @parametersDoc output;

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@renewalCategorySID, 'S!REG.RENEWAL.IN.PROGRESS', @parametersDoc, 'In progress (renewal)', @OFF
		 ,N'Returns registrations where a renewal form has been started but not finalized or paid'
		);

		----- Renewal not paid ------

		set @parametersDoc = null;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'PracticeRegisterSID'
		 ,@IsMandatory = 'false'
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'IsPADSubscriber'
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'IsNotPADSubscriber'
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'CultureSID'
		 ,@IsMandatory = 'false'
		 ,@ParametersDoc = @parametersDoc output;

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@renewalCategorySID, 'S!REG.RENEWAL.NOT.PAID', @parametersDoc, 'Approved not paid (renewal)', @OFF
		 ,N'Returns renewal records that are approved but not paid'
		);

		----- Renewal paid via PAP with leftovers ------

		set @parametersDoc = null;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'PracticeRegisterSID'
		 ,@IsMandatory = 'false'
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'CultureSID'
		 ,@IsMandatory = 'false'
		 ,@ParametersDoc = @parametersDoc output;

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@renewalCategorySID, 'S!REG.RENEWAL.PAP.UNAPPLIED', @parametersDoc, 'Paid via PAP w/ leftovers (renewal)', @OFF
		 ,N'Returns renewal records that are fully paid and where the member has unapplied PAP payments remaining'
		);

		----- Not renewed -----

		set @parametersDoc = null;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'PracticeRegisterSID'
		 ,@IsMandatory = @OFF
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'FormStatusSID'
		 ,@IsMandatory = @OFF
		 ,@Cell = 2
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'IsNotStarted'
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'IsNotPaid'
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'IsPADSubscriber'
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'IsNotPADSubscriber'
		 ,@Cell = 2
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'CultureSID'
		 ,@IsMandatory = @OFF
		 ,@ParametersDoc = @parametersDoc output;

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@renewalCategorySID, 'S!REG.NOT.RENEWED', @parametersDoc, 'Not renewed', @OFF, N'Returns renewal forms which are not complete'
		);

		----- Complete (renewal) -----

		set @parametersDoc = null;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'PracticeRegisterSID'
		 ,@Label = 'Renewed from'
		 ,@IsMandatory = @OFF
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'PracticeRegisterSIDTo'
		 ,@Label = 'to'
		 ,@Cell = 2
		 ,@IsMandatory = @OFF
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'StartDate'
		 ,@Label = 'Between'
		 ,@Cell = 1
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'EndDate'
		 ,@Label = 'and'
		 ,@Cell = 2
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'CultureSID'
		 ,@IsMandatory = @OFF
		 ,@ParametersDoc = @parametersDoc output;

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@renewalCategorySID, 'S!REG.RENEWAL.DONE', @parametersDoc, 'Complete (renewal)', @OFF, N'Returns renewals that are complete'
		);

		----- Register change (renewal) -----

		set @parametersDoc = null;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'PracticeRegisterSID'
		 ,@Label = 'Renewed from'
		 ,@IsMandatory = @OFF
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'PracticeRegisterSIDTo'
		 ,@Label = 'to'
		 ,@Cell = 2
		 ,@IsMandatory = @OFF
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'StartDate'
		 ,@Label = 'Approved from'
		 ,@IsMandatory = @OFF
		 ,@DefaultValue = ''
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'EndDate'
		 ,@Label = 'to'
		 ,@Cell = 2
		 ,@IsMandatory = @OFF
		 ,@DefaultValue = ''
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'IsPADSubscriber'
		 ,@IsMandatory = @OFF
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'IsNotPADSubscriber'
		 ,@Cell = 2
		 ,@IsMandatory = @OFF
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'IsPaidOnly'
		 ,@Label = 'Paid only'
		 ,@IsMandatory = @OFF
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'CultureSID'
		 ,@IsMandatory = @OFF
		 ,@ParametersDoc = @parametersDoc output;

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@renewalCategorySID, 'S!REG.RENEWAL.REGCHANGE', @parametersDoc, 'Register change (renewal)', @OFF
		 ,N'Returns completed renewals that reflect a change in register'
		);

		----- By Status (renewal)  -----

		set @parametersDoc = null;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'FormStatusSID'
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'PracticeRegisterSID'
		 ,@Cell = 2
		 ,@IsMandatory = @OFF
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'CultureSID'
		 ,@Cell = 3
		 ,@IsMandatory = 'false'
		 ,@ParametersDoc = @parametersDoc output;

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@renewalCategorySID, 'S!REG.RENEWAL.BY.STATUS', @parametersDoc, 'By status (renewal)', @OFF, N'Returns renewals matching the selected status'
		);

		----- Abandoned (renewals) -----

		set @parametersDoc = null;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'EndDate'
		 ,@Label = 'No update after'
		 ,@DefaultValue = '[@@Date]-7'
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'PracticeRegisterSID'
		 ,@Cell = 2
		 ,@IsMandatory = @OFF
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'CultureSID'
		 ,@Cell = 3
		 ,@IsMandatory = 'false'
		 ,@ParametersDoc = @parametersDoc output;

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@renewalCategorySID, 'S!REG.RENEWAL.ABANDONED', @parametersDoc, 'Abandoned (renewal)', @OFF
		 ,N'Returns renewals where the form is open and has not been updated after a provided cut-off date'
		);

		----- Paid not renewed (renewals) -----

		set @parametersDoc = null;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'CutOffDate'
		 ,@Label = 'Updated on or before'
		 ,@DefaultValue = '[@@Date]'
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'CultureSID'
		 ,@Cell = 2
		 ,@IsMandatory = 'false'
		 ,@ParametersDoc = @parametersDoc output;

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@renewalCategorySID, 'S!REG.RENEWAL.PAIDNOREG', @parametersDoc, 'Paid not renewed', @OFF
		 ,N'Returns renewals that are paid but a registration record for the following year is not created'
		);

		----- Did not renew (reg changed) -----

		set @parametersDoc = null;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'PracticeRegisterSID'
		 ,@Cell = 2
		 ,@IsMandatory = @OFF
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'CultureSID'
		 ,@Cell = 3
		 ,@IsMandatory = 'false'
		 ,@ParametersDoc = @parametersDoc output;

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@renewalCategorySID, 'S!REG.RENEWAL.DIDNOT', @parametersDoc, 'Did not renew (reg changed)', @OFF
		 ,N'Returns records where renewal was not completed but a registration change was made by Administration'
		);

		----- Application review reasons ------

		set @parametersDoc = null;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'ApplicationReasonSID'
		 ,@IsMandatory = 'false'
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'CultureSID'
		 ,@Cell = 2
		 ,@IsMandatory = 'false'
		 ,@ParametersDoc = @parametersDoc output;

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@applicationCategorySID, 'S!REG.APPLICATION.RVW.REQUIRED', @parametersDoc, 'Review required (application)', @OFF
		 ,N'Returns records matching the selected review (blocking) reason'
		);

		----- Application in progress ------

		set @parametersDoc = null;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'PracticeRegisterSID'
		 ,@Label = 'Applying to'
		 ,@IsMandatory = 'false'
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'CultureSID'
		 ,@IsMandatory = 'false'
		 ,@ParametersDoc = @parametersDoc output;

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@applicationCategorySID, 'S!REG.APPLICATION.IN.PROGRESS', @parametersDoc, 'In progress (application)', @OFF
		 ,N'Returns registrations where an application form has been started but not finalized or paid'
		);

		----- Application not paid ------

		set @parametersDoc = null;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'PracticeRegisterSID'
		 ,@IsMandatory = 'false'
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'CultureSID'
		 ,@IsMandatory = 'false'
		 ,@ParametersDoc = @parametersDoc output;

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@applicationCategorySID, 'S!REG.APPLICATION.NOT.PAID', @parametersDoc, 'Approved not paid (application)', @OFF
		 ,N'Returns application records that are approved but not paid (funds are owing)'
		);

		----- Complete (application) -----

		set @parametersDoc = null;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'PracticeRegisterSID'
		 ,@Label = 'Applied to'
		 ,@IsMandatory = @OFF
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'StartDate'
		 ,@Cell = 2
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'EndDate'
		 ,@Cell = 3
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'CultureSID'
		 ,@IsMandatory = @OFF
		 ,@ParametersDoc = @parametersDoc output;

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@applicationCategorySID, 'S!REG.APPLICATION.DONE', @parametersDoc, 'Complete (application)', @OFF, N'Returns forms that are completed in a date range'
		);

		----- By Status (application)  -----

		set @parametersDoc = null;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'FormStatusSID'
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'PracticeRegisterSID'
		 ,@IsMandatory = @OFF
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'CultureSID'
		 ,@IsMandatory = 'false'
		 ,@ParametersDoc = @parametersDoc output;

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@applicationCategorySID, 'S!REG.APPLICATION.BY.STATUS', @parametersDoc, 'By status (application)', @OFF
		 ,N'Returns applications matching the selected status'
		);

		----- Abandoned (applications) -----

		set @parametersDoc = null;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'EndDate'
		 ,@Label = 'No update after'
		 ,@DefaultValue = '[@@Date]-7'
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'PracticeRegisterSID'
		 ,@IsMandatory = @OFF
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'CultureSID'
		 ,@IsMandatory = 'false'
		 ,@ParametersDoc = @parametersDoc output;

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@applicationCategorySID, 'S!REG.APPLICATION.ABANDONED', @parametersDoc, 'Abandoned (application)', @OFF
		 ,N'Returns applications where the form is open and has not been updated after a provided cut-off date'
		);

		----- Paid not registered (applications) -----

		set @parametersDoc = null;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'CutOffDate'
		 ,@Label = 'Updated on or before'
		 ,@DefaultValue = '[@@Date]'
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'CultureSID'
		 ,@Cell = 2
		 ,@IsMandatory = 'false'
		 ,@ParametersDoc = @parametersDoc output;

		insert
			@setup
		(
			QueryCategorySID
		 ,QueryCode
		 ,QueryParameters
		 ,QueryLabel
		 ,IsApplicationPageDefault
		 ,ToolTip
		)
		values
		(
			@applicationCategorySID, 'S!REG.APPLICATION.PAIDNOREG', @parametersDoc, 'Paid not registered', @OFF
		 ,N'Returns applications that are paid (where amount was owing) but a registration record is not created'
		);

		-- delete any remaining product queries related to the entity 
		-- which are not in the current setup or are using the older
		-- style dynamic syntax stored directly in the table

		delete
		q
		from
			sf.Query						 q
		join
			sf.ApplicationPage	 ap on q.ApplicationPageSID		 = ap.ApplicationPageSID
		join
			sf.ApplicationEntity ae on ap.ApplicationEntitySID = ae.ApplicationEntitySID
		left outer join
			@setup							 s on q.QueryCode							 = s.QueryCode
		where
			ae.ApplicationEntitySCD = 'dbo.Registration'
			and
			((left(q.QueryCode, 2) = 'S!'	 and s.QueryCode is null) or left(q.QueryCode,6) = '[None]' or left(q.QueryCode,4) = 'None' or q.QuerySQL is not null);

		-- insert/update the query definitions to the latest version

		merge sf.Query target
		using
		(
			select
				x.QueryCategorySID
			 ,x.QueryCode
			 ,x.QueryLabel
			 ,x.IsApplicationPageDefault
			 ,x.ToolTip
			 ,x.QueryParameters
			 ,@applicationPageSID ApplicationPageSID
			 ,@SetupUser					CreateUser
			 ,@SetupUser					UpdateUser
			from
				@setup x
		) source
		on target.QueryCode = source.QueryCode
		when not matched by target then
			insert
			(
				QueryCategorySID
			 ,QueryCode
			 ,QueryLabel
			 ,IsApplicationPageDefault
			 ,ToolTip
			 ,QueryParameters
			 ,ApplicationPageSID
			 ,CreateUser
			 ,UpdateUser
			)
			values
			(
				source.QueryCategorySID, source.QueryCode, source.QueryLabel, source.IsApplicationPageDefault, source.ToolTip, source.QueryParameters
			 ,source.ApplicationPageSID, source.CreateUser, source.UpdateUser
			)
		when matched then update set
												target.QueryLabel = source.QueryLabel
											 ,target.IsApplicationPageDefault = source.IsApplicationPageDefault
											 ,target.QueryCategorySID = source.QueryCategorySID
											 ,target.ToolTip = source.ToolTip
											 ,target.QueryParameters = source.QueryParameters
											 ,target.ApplicationPageSID = source.ApplicationPageSID
											 ,target.UpdateUser = source.UpdateUser;

		-- validate that the list of product query codes just setup
		-- matches the query codes for which syntax is defined in the
		-- Query Search subroutine

		exec sf.pQuery#CheckCodes
			@ApplicationEntitySCD = 'dbo.Registration'
		 ,@SchemaAndRoutineName = 'dbo.pQuery#Execute$Registration'
		 ,@SetupSprocName = @procName;

		if @tranCount = 0 and xact_state() = 1 -- if no wrapping transaction and committable
		begin
			commit;
		end;

	end try
	begin catch

		-- if a transaction was pending at start of routine 
		-- perform partial rollback to save point

		set @xState = xact_state();

		if @tranCount > 0 and (@xState = -1 or @xState = 1)
		begin
			rollback transaction @procName; -- rollback to save point
		end;
		else if (@xState = -1 or @xState = 1) -- full rollback since no previous trx was pending
		begin
			rollback;
		end;

		exec @errorNo = sf.pErrorRethrow; -- process message text and re-throw the error
	end catch;

	return (@errorNo);

end;
GO
