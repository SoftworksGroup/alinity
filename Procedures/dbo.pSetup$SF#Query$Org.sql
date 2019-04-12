SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pSetup$SF#Query$Org
	@SetupUser nvarchar(75) -- user assigned to insert and update columns
as
/*********************************************************************************************************************************
Sproc    : Setup Org Queries
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : Returns a data set of sf.Query master table data to pSetup$SF#Query
----------------------------------------------------------------------------------------------------------------------------------
History		: Author	  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Taylor N		| Dec 2018		|	Initial version

Comments	
--------
This procedure adds queries used to support the organization UI.

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Returns configured org queries.">
		<SQLScript>
		<![CDATA[
		
			exec dbo.pSetup$SF#Query$Org
				@SetupUser = 'support@softworksgroup.com'

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
					ae.ApplicationEntitySCD = 'dbo.Org'
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
	 @ObjectName = 'dbo.pSetup$SF#Query$Org'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo						int						= 0								-- 0 no error, if < 50000 SQL error, else business rule
	 ,@errorText					nvarchar(4000)									-- message text (for business rule errors)
	 ,@applicationPageSID int															-- key of the search page where these queries are to appear
	 ,@queryCategorySID		int															-- key of category for this query set
	 ,@parametersDoc			xml;														-- buffer to hold parameter definitions for query

	begin try

		declare @setup table -- setup data for staging rows to be inserted
		(
			ID								 int					 identity(1, 1)
		 ,QueryCategorySID	 int					 not null
		 ,QueryLabel				 nvarchar(35)	 not null
		 ,QueryCode					 varchar(30)	 not null
		 ,ToolTip						 nvarchar(250) not null
		 ,QuerySQL					 nvarchar(max) not null
		 ,QueryParameters		 xml					 null
		 ,ApplicationPageSID int					 not null
		);

		select
			@applicationPageSID = ap.ApplicationPageSID
		from
			sf.ApplicationPage ap
		where
			ap.ApplicationPageURI = 'OrgList';

		if @applicationPageSID is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'sf.ApplicationPage'
			 ,@Arg2 = 'RegistrantAuditList';

			raiserror(@errorText, 18, 1);
		end;

		select top (1) 
			@querycategorysid= qc.QueryCategorySID 
		from 
			sf.QueryCategory qc 
		where 
			qc.IsDefault = cast(1 as bit)

		if @applicationPageSID is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'sf.QueryCategory'
			 ,@Arg2 = 'Audit %';

			raiserror(@errorText, 18, 1);
		end;


		----- By Type ----- 
		set @parametersDoc = null;

		insert
			@setup
		(
			QueryCategorySID
			,QueryLabel
			,QueryCode
			,ToolTip
			,QueryParameters
			,QuerySQL
			,ApplicationPageSID
		)
		values (
			 @queryCategorySID
			,N'By Type'
			,'NONE.ORGTYPE'
			,N'Returns all organizations by type and related flags.'
			,cast(N'<Parameters>
	<Parameter ID="OrgTypeSID" Label="Type" Type="Select" IsMandatory="True">
		<SQL>
			select
					ot.OrgTypeSID					Value
				,	ot.OrgTypeName				Label
			from
				dbo.OrgType ot
			order by
				ot.OrgTypeName
		</SQL>
	</Parameter>
	<Parameter ID="IsEmployer" Label="Is Employer" Type="Select" IsMandatory="False">
		<SQL>
			select 1 Value, ''Yes'' Label
			union all
			select 0 Value, ''No'' Label
		</SQL>
	</Parameter>
	<Parameter ID="IsCredentialAuthority" Label="Is Credential Authority" Type="Select" IsMandatory="False">
		<SQL>
			select 1 Value, ''Yes'' Label
			union all
			select 0 Value, ''No'' Label
		</SQL>
	</Parameter>
	<Parameter ID="IsActive" Label="Is Active" Type="Select" IsMandatory="False">
		<SQL>
			select 1 Value, ''Yes'' Label
			union all
			select 0 Value, ''No'' Label
		</SQL>
	</Parameter>
</Parameters>' as xml)
			, N'select
		og.OrgSID
from
	dbo.Org og
where
	og.OrgTypeSID = [@OrgTypeSID]
and
	([@IsEmployer] is null or og.IsEmployer = [@IsEmployer])
and
	([@IsCredentialAuthority] is null or og.IsCredentialAuthority = [@IsCredentialAuthority])
and
	([@IsActive] is null or og.IsActive = [@IsActive])'
			,@applicationPageSID
		)


		----- By Location ----- 
		set @parametersDoc = cast(N'<Parameters>
	<Parameter ID="PostalCode" Label="Postal Code" Type="TextBox" IsMandatory="False" />
</Parameters>' as xml);

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'CitySID'
		 ,@Cell = 2
		 ,@IsMandatory = 0
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'StateProvinceSID'
		 ,@Cell = 2
		 ,@IsMandatory = 0
		 ,@ParametersDoc = @parametersDoc output;

		exec dbo.pQuery#SetParametersDoc
			@ParameterID = 'RegionSID'
		 ,@IsMandatory = 0
		 ,@ParametersDoc = @parametersDoc output;

		insert
			@setup
		(
			QueryCategorySID
			,QueryLabel
			,QueryCode
			,ToolTip
			,QueryParameters
			,QuerySQL
			,ApplicationPageSID
		)
		values (
			 @queryCategorySID
			,N'By Location'
			,'NONE.ORGLOCATION'
			,N'Returns all orgs that are currently at a location that matches the optional parameters. The optional postal code supports partial matches; if a full postal code is entered it should match the format "H0H 0H0".'
			,@parametersDoc
			, N'declare @formattedPostalCode varchar(12) = ''%'' + [@PostalCode] + ''%''

select
		og.OrgSID
from
	dbo.Org og
join
	dbo.City cy on cy.CitySID = og.CitySID
where
	([@CitySID] is null or cy.CitySID = [@CitySID])
and
	([@StateProvinceSID] is null or cy.StateProvinceSID = [@StateProvinceSID])
and
	([@PostalCode] is null or og.PostalCode like @formattedPostalCode)
and
	([@RegionSID] is null or og.RegionSID = [@RegionSID])'
			,@applicationPageSID
		)


		----- Employers with no employees ----- 
		set @parametersDoc = N'<Parameters>
		<Parameter ID="IsActive" Label="Is Active" Type="Select" IsMandatory="False">
		<SQL>
			select 1 Value, ''Yes'' Label
			union all
			select 0 Value, ''No'' Label
		</SQL>
	</Parameter>
</Parameters>';

		insert
			@setup
		(
			QueryCategorySID
			,QueryLabel
			,QueryCode
			,ToolTip
			,QueryParameters
			,QuerySQL
			,ApplicationPageSID
		)
		values (
			 @queryCategorySID
			,N'Employers with no employees'
			,'NONE.ORGMISSEMP'
			,N'Returns all employers who have no current employees. Employment with an expiry time in the past, and employment with no expiry date but a registration year 2 years in the past are considered to no longer be current.'
			,@parametersDoc
			, N'declare
		@ON				bit = cast(1 as bit)
	,	@now			datetime = sf.fNow()
	,	@lastYear			int = dbo.fRegistrationYear#Current() - 1

select
	og.OrgSID
from
	dbo.Org og
left join
(
	select
			re.OrgSID
		,	count(1)	TotalEmployed
	from
		dbo.RegistrantEmployment re
	where
		(re.ExpiryTime is null and re.RegistrationYear >= @lastYear)
	or
		re.ExpiryTime > @now
	group by
		re.OrgSID
) emp on emp.OrgSID = og.OrgSID
where
	og.IsEmployer = @ON
and
	([@IsActive] is null or og.IsActive = [@IsActive])
and
	isnull(emp.TotalEmployed, 0) = 0'
			,@applicationPageSID
		)
			
		----- INSERTION ----- 
		merge
			sf.Query as target
		using (
			select
					s.QueryCategorySID
				,	s.QueryLabel
				,	s.QueryCode
				,	s.ToolTip
				,	s.QuerySQL
				,	s.QueryParameters
				,	s.ApplicationPageSID
			from
				@setup s
		) as source (
					QueryCategorySID
				,	QueryLabel
				,	QueryCode
				,	ToolTip
				,	QuerySQL
				,	QueryParameters
				,	ApplicationPageSID
		)
		on (
			target.QueryCategorySID = source.QueryCategorySID
				and target.QueryCode = source.QueryCode
		)
		when matched
			and checksum(
					target.QueryCategorySID
				,	target.QuerySQL
				,	target.QueryLabel
				,	target.ToolTip
				,	target.ApplicationPageSID
				,	cast(target.QueryParameters as nvarchar(max))
			)
			<>
			checksum(
					source.QueryCategorySID
				,	source.QuerySQL
				,	source.QueryLabel
				,	source.ToolTip
				,	source.ApplicationPageSID
				,	cast(source.QueryParameters as nvarchar(max))
			)
			then
			update set
					target.QueryCategorySID			= source.QueryCategorySID
				,	target.QuerySQL							= source.QuerySQL
				,	target.QueryLabel						= source.QueryLabel
				,	target.ToolTip						  = source.ToolTip
				,	target.ApplicationPageSID		= source.ApplicationPageSID
				,	target.QueryParameters			= source.QueryParameters
				,	target.UpdateUser						= @SetupUser
				,	target.UpdateTime						= sysdatetime()
		when not matched by target then
			insert(
					QueryCategorySID
				,	QueryLabel
				,	QueryCode
				,	ToolTip
				,	QuerySQL
				,	QueryParameters
				,	ApplicationPageSID
				,	CreateUser
				,	UpdateUser
			)
			values(
					source.QueryCategorySID
				,	source.QueryLabel
				,	source.QueryCode
				,	source.ToolTip
				,	source.QuerySQL
				,	source.QueryParameters
				,	source.ApplicationPageSID
				,	@SetupUser
				,	@SetupUser
			);

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);

end;
GO
