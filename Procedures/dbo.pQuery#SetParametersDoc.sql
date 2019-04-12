SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pQuery#SetParametersDoc
	@ParameterID	 varchar(50)					-- parameter to return definition for (required)
 ,@IsMandatory	 bit = 1							-- indicates whether user must enter value into the parameter
 ,@Cell					 tinyint = 1					-- cell to position the parameter at (referencing same cell twice creates new row)
 ,@Label				 nvarchar(35) = null	-- optional replacement for the default label
 ,@DefaultValue	 nvarchar(100) = null -- optional replacement for the default value/expression
 ,@ParametersDoc xml output						-- document to insert parameter into
as
/*********************************************************************************************************************************
Sproc    : Query - Set Parameter Doc
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : Generates an XML document based on parameter ID passed in (call repeatedly for multiple parameters)
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Sep 2018		|	Initial version
				: Tim Edlund					| Jan 2019		| Removed defaults on start and end dates (pass from setup when required)

Comments	
--------
This is a utility procedure used in (sf) Query setup procedures to simplify the insert of parameter definitions.  The name of
a standard parameter can be passed in which is then looked up in a master parameter definition document. Attributes controlling
whether the parameter is mandatory or not, and its horizontal position by cell reference - may also be passed as parameters.  

The procedure returns the resulting parameter definition as an output parameter (XML document).  The same variable name
can be passed in repeatedly to multiple calls to the procedure to build up an XML document for inserting into the Query
Parameter column of sf.Query.

Note that to cause parameters to be displayed on multiple rows, allow the @Cell parameter to default to 1 on any 
subsequent parameter and a new row is created.  To avoid creating multiple rows, increment the cell number and 
additional columns on the row are added.

Known Limitations
-----------------
The master parameter definition document is embedded in this procedure.  Formatting XML accurately as a T-SQL string is 
prone to errors and therefore any changes to the master document should first be made using an XML editor in the
database project.  The file containing the master document is stored at AlinityDB\zTemplates\QueryParameterDefinitions.xml
Update the parameter list there first, then copy the content into this procedure.

The "CultureSID" parameter is only included in the outbound document when the count of unique cultures among application
user records is 2 or more.  Since the documents supporting queries are created at setup time only, when the configuration
first adds users with a second culture the queries will not automatically start prompting for culture.  The setup sproc
for queries must be run first to have the culture parameters included.

Example
-------
<TestHarness>
  <Test Name = "Basic" IsDefault ="true" Description="Executes the procedure to return a document with 3 parameters">
    <SQLScript>
      <![CDATA[

declare @parametersDoc xml;

exec dbo.pQuery#SetParametersDoc
	@ParameterID = 'RegistrationYear'
 ,@ParametersDoc = @parametersDoc output;

exec dbo.pQuery#SetParametersDoc
	@ParameterID = 'RecentDateTime'
 ,@ParametersDoc = @parametersDoc output;

exec dbo.pQuery#SetParametersDoc
	@ParameterID = 'IsUpdatedByMeOnly'
 ,@Cell = 2
 ,@IsMandatory = 0
 ,@Label = 'My new label'
 ,@DefaultValue = 'true'
 ,@ParametersDoc = @parametersDoc output;

select @parametersDoc QueryParameters ;

		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:03"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pQuery#SetParametersDoc'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo						int						= 0								-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText					nvarchar(4000)									-- message text for business rule errors
	 ,@ON									bit						= cast(1 as bit)	-- constant for bit comparisons = 1
	 ,@isMultiCulture			bit						= cast(1 as bit)	-- controls whether language/culture prompts are included
	 ,@parameterDefString nvarchar(max)										-- parameter definition converted to string
	 ,@parameterDef				xml															-- xml fragment containing parameter definition
	 ,@i									int															-- index position in string
	 ,@j									int															-- index position in string
	 ,@mandatorySetting		nvarchar(5)											-- is-mandatory converted to "true" or "false" for XML setting
	 ,@summaryIndex				tinyint				= 0								-- sets display order of parameters in summary line on UI
	 ,@allParameters			xml;														-- standard parameters: update in AlinityDB\zTemplates\QueryParameterDefinitions.xml

	set @ParametersDoc = @ParametersDoc; -- initialize output variable to avoid code warnings

	begin try

		if @ParameterID is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = '@ParameterID';

			raiserror(@errorText, 18, 1);

		end;

		if @ParameterID = 'CultureSID'
		begin

			select
				@isMultiCulture = cast(count(x.CultureSID) - 1 as bit)
			from
			(select distinct au.CultureSID from sf .ApplicationUser au) x;

		end;

		if @ParameterID <> 'CultureSID' or @isMultiCulture = @ON
		begin

			if @ParametersDoc is null
			begin
				set @ParametersDoc = cast(N'<Parameters></Parameters>' as xml); -- if document not provided initialize it here
			end;
			else
			begin
				select
					@summaryIndex = @ParametersDoc.value('count(/Parameters/Parameter)', 'int');	-- count of parameters in document so far
			end;

			if @IsMandatory = @ON -- convert mandatory setting to XML key word for booleans
			begin
				set @mandatorySetting = N'true';
			end;
			else
			begin
				set @mandatorySetting = N'false'; -- parameter is not required
			end;

			-- set the document for all parameters  
			-- !! update the document in AlinityDB\zTemplates\QueryParameterDefinitions.xml first then copy here!!

			set @allParameters =
				N'
<Parameters>
  <Parameter ID="CultureSID" Label="Language preference" Type="Select" IsMandatory ="false" Cell="@Cell">
    <SQL>
      select
      c.CultureSID					Value
      ,c.CultureLabel				Label
      from
      (select distinct au.culturesid from sf.ApplicationUser au) x
      join
      sf.Culture																							 c on x.CultureSID = c.CultureSID;
    </SQL>
  </Parameter>
  <Parameter ID="RegistrationYear" Label="Registration year" Type="Select" IsMandatory ="@IsMandatory" Cell="@Cell" DefaultValue="[@@CurrentRegYear]">
    <SQL>
      select
      cast(rsy.RegistrationYear as int)  Value
      ,rsy.RegistrationYearLabel         Label
      from
      dbo.vRegistrationScheduleYear rsy
      order by
      rsy.RegistrationYear desc
    </SQL>
  </Parameter>
  <Parameter ID="PracticeRegisterSIDTo" Label="Register" Type="Select" IsMandatory ="@IsMandatory" Cell="@Cell">
    <SQL>
      select
      pr.PracticeRegisterSID   Value
      ,pr.PracticeRegisterLabel Label
      from
      dbo.PracticeRegister pr
      where
      pr.IsActive = cast(1 as bit)
      order by
      pr.PracticeRegisterLabel
    </SQL>
  </Parameter>
  <Parameter ID="PracticeRegisterSID" Label="Register" Type="Select" IsMandatory ="@IsMandatory" Cell="@Cell">
    <SQL>
      select
      pr.PracticeRegisterSID   Value
      ,pr.PracticeRegisterLabel Label
      from
      dbo.PracticeRegister pr
      where
      pr.IsActive = cast(1 as bit)
      order by
      pr.PracticeRegisterLabel
    </SQL>
  </Parameter>
  <Parameter ID="CitySID" Label="City" Type="AutoComplete" IsMandatory ="@IsMandatory" Cell="@Cell">
    <SQL>
      select
      cty.CitySID		Value
      ,cty.CityName + '' '' + sp.StateProvinceCode + (case when c.IsDefault = 0 then '' ('' + c.CountryName + '')'' else '''' end) Label
      from
      dbo.City					cty
      join
      dbo.StateProvince sp on cty.StateProvinceSID = sp.StateProvinceSID
      join
      dbo.Country				c on sp.CountrySID				 = c.CountrySID
      where
      cty.IsActive = 1
      order by
      cty.CityName;
    </SQL>
  </Parameter>
  <Parameter ID="SpecializationSID" Label="Specialization" Type="Select" IsMandatory ="@IsMandatory" Cell="@Cell">
    <SQL>
      select
      crd.CredentialSID		Value
      ,crd.CredentialLabel	Label
      from
      dbo.Credential crd
      where
      crd.IsActive = 1
      order by
      crd.CredentialLabel
    </SQL>
  </Parameter>
  <Parameter ID="FormStatusSID" Label="Status" Type="Select" IsMandatory ="@IsMandatory" Cell="@Cell">
    <SQL>
      select
      fs.FormStatusSID		Value
      ,fs.FormStatusLabel	Label
      from
      sf.FormStatus fs
      where
      fs.FormStatusSCD != ''WITHDRAWN''
      order by
      fs.FormStatusSequence
    </SQL>
  </Parameter>
  <Parameter ID="RegFormTypeSID" Label="Form type" Type="Select" IsMandatory ="@IsMandatory" Cell="@Cell" DefaultValue="100">
    <SQL>
      select
      rft.RegFormTypeSID	 Value
      ,rft.RegFormTypeLabel Label
      from
      dbo.vRegFormType rft
      order by
      rft.RegFormTypeSID;
    </SQL>
  </Parameter>
  <Parameter ID="PUReasonSID" Label="Review reason" Type="Select" IsMandatory ="@IsMandatory" Cell="@Cell">
    <SQL>
      select
      r.ReasonSID	 Value
      ,r.ReasonName Label
      from
      dbo.Reason r
      where
      r.ReasonCode like ''PROFILE.%''
      and
      r.IsActive = 1
      order by
      r.ReasonSequence
      ,r.ReasonName;
    </SQL>
  </Parameter>
  <Parameter ID="RenewalReasonSID" Label="Review reason" Type="Select" IsMandatory ="@IsMandatory" Cell="@Cell">
    <SQL>
      select
      r.ReasonSID	 Value
      ,r.ReasonName Label
      from
      dbo.Reason r
      where
      r.ReasonCode like ''RENEWAL.%''
      and
      r.IsActive = 1
      order by
      r.ReasonSequence
      ,r.ReasonName;
    </SQL>
  </Parameter>
  <Parameter ID="ApplicationReasonSID" Label="Review reason" Type="Select" IsMandatory ="@IsMandatory" Cell="@Cell">
    <SQL>
      select
      r.ReasonSID	 Value
      ,r.ReasonName Label
      from
      dbo.Reason r
      where
      r.ReasonCode like ''APP.BLOCK.%''
      and
      r.IsActive = 1
      order by
      r.ReasonSequence
      ,r.ReasonName;
    </SQL>
  </Parameter>
  <Parameter ID="PaymentTypeSID" Label="Payment type" Type="Select" IsMandatory ="@IsMandatory" Cell="@Cell">
    <SQL>
      select
      pmtT.PaymentTypeSID		Value
      ,pmtT.PaymentTypeLabel Label
      from
      dbo.PaymentType pmtT
      where
      pmtT.IsActive = 1
      order by
      pmtT.PaymentTypeLabel;
    </SQL>
  </Parameter>
  <Parameter ID="PaymentStatusSID" Label="Payment status" Type="Select" IsMandatory ="@IsMandatory" Cell="@Cell">
    <SQL>
      select
      pmtS.PaymentStatusSID		Value
      ,pmtS.PaymentStatusLabel Label
      from
      dbo.PaymentStatus pmtS
      order by
      pmtS.PaymentStatusLabel;
    </SQL>
  </Parameter>
  <Parameter ID="BankGLAccountSID" Label="Payment status" Type="Select" IsMandatory ="@IsMandatory" Cell="@Cell">
    <SQL>
      select
      gla.GLAccountSID	 Value
      ,gla.GLAccountLabel Label
      from
      dbo.GLAccount gla
      where
      gla.IsBankAccount = 1
      order by
      gla.GLAccountLabel
    </SQL>
  </Parameter>
  <Parameter ID="StateProvinceSID" Label="Province / state" Type="AutoComplete" IsMandatory ="@IsMandatory" Cell="@Cell">
    <SQL>
      select
      sp.StateProvinceSID    Value
      ,sp.StateProvinceSearch Label
      from
      dbo.vStateProvince sp
      where
      sp.IsActive = cast(1 as bit)
      order by
      sp.StateProvinceSearch
    </SQL>
  </Parameter>
  <Parameter ID="RegionSID" Label="Region" Type="Select" IsMandatory ="@IsMandatory" Cell="@Cell">
    <SQL>
      select
      r.RegionSID    Value
      ,r.RegionLabel  Label
      from
      dbo.Region r
      where
      r.IsActive = cast(1 as bit)
      order by
      r.RegionLabel
    </SQL>
  </Parameter>
  <Parameter ID="TaskQueueSID" Label="Task queue" Type="Select" IsMandatory ="@IsMandatory" Cell="@Cell">
    <SQL>
      select
      tq.TaskQueueSID    Value
      ,tq.TaskQueueLabel  Label
      from
      sf.TaskQueue tq
      where
      tq.IsActive = cast(1 as bit)
      order by
      tq.TaskQueueLabel
    </SQL>
  </Parameter>
  <Parameter ID="AdminApplicationUserSID" Label="Assigned to" Type="Select" IsMandatory ="@IsMandatory" Cell="@Cell">
    <SQL>
      select
      a.ApplicationUserSID																  Value
      ,isnull(a.CommonName, a.FirstName) + '' '' + a.LastName Label
      from
      dbo.vApplicationUser#Admin a
      order by
      isnull(a.CommonName, a.FirstName)
      ,a.LastName;
    </SQL>
  </Parameter>
  <Parameter ID="TaskContextSID" Label="Context (related to)" Type="Select" IsMandatory ="@IsMandatory" Cell="@Cell">
    <SQL>
      select
      tc.TaskContextSID		Value
      ,tc.TaskContextLabel Label
      from
      dbo.vTask#Context tc
      order by
      tc.TaskContextLabel;
    </SQL>
  </Parameter>
  <Parameter ID="ComplaintTypeSID" Label="Context (related to)" Type="Select" IsMandatory ="@IsMandatory" Cell="@Cell">
    <SQL>
      select
      x.ComplaintTypeSID		Value
      ,x.ComplaintTypeLabel Label
      from
      dbo.ComplaintType x
      order by
      x.ComplaintTypeLabel;
    </SQL>
  </Parameter>
  <Parameter ID="ComplainantTypeSID" Label="Context (related to)" Type="Select" IsMandatory ="@IsMandatory" Cell="@Cell">
    <SQL>
      select
      x.ComplainantTypeSID		Value
      ,x.ComplainantTypeLabel Label
      from
      dbo.ComplainantType x
      order by
      x.ComplainantTypeLabel;
    </SQL>
  </Parameter>
  <Parameter ID="ImportFileSID" Label="Import file" Type="Select" IsMandatory ="@IsMandatory" Cell="@Cell">
    <SQL>
			select distinct
				f.ImportFileSID Value
			 ,f.FileName			Label
			from
				stg.RegistrantProfile rp
			join
				sf.ImportFile					f on rp.ImportFileSID = f.ImportFileSID
			order by
				f.FileName
    </SQL>
  </Parameter>
  <Parameter ID="ProcessingStatusSID" Label="Processing status" Type="Select" IsMandatory ="@IsMandatory" Cell="@Cell">
    <SQL>
			select
				ps.ProcessingStatusSID	 Value
			 ,ps.ProcessingStatusLabel Label
			from
				sf.ProcessingStatus ps
			where
				ps.IsActive = cast(1 as bit)
			order by
				ps.ProcessingStatusLabel
    </SQL>
  </Parameter>
  <Parameter ID="StartDate" Label="From" Type="DatePicker" IsMandatory ="@IsMandatory" Cell="@Cell"/>
  <Parameter ID="EndDate" Label="To" Type="DatePicker" IsMandatory ="@IsMandatory" Cell="@Cell"/>
  <Parameter ID="CutOffDate" Label="Cut off" Type="DatePicker" Cell="@Cell" DefaultValue="[@@Date]-1"/>
  <Parameter ID="FollowUpDate" Label="Follow-up due" Type="DatePicker" Cell="@Cell" DefaultValue="[@@Date]"/>
  <Parameter ID="PhoneNumber" Label="Phone" Type="TextBox" IsMandatory ="@IsMandatory" Cell="@Cell"/>
  <Parameter ID="StreetAddress" Label="Street address" Type="TextBox" IsMandatory ="@IsMandatory" Cell="@Cell"/>
  <Parameter ID="RecentDateTime" Label="Updated on/after" Type="DatePicker" IsMandatory ="@IsMandatory" Cell="@Cell" DefaultValue="[@@Date]"/>
  <Parameter ID="IsUpdatedByMeOnly" Label="By me only" Type="CheckBox" Cell="@Cell" DefaultValue="false" />
  <Parameter ID="IsPaidOnly" Label="Paid only" Type="CheckBox" Cell="@Cell" DefaultValue="false"/>
  <Parameter ID="IsNotPaid" Label="Not paid" Type="CheckBox" Cell="@Cell" DefaultValue="false"/>
  <Parameter ID="IsOverPaid" Label="Overpaid" Type="CheckBox" Cell="@Cell" DefaultValue="false"/>
  <Parameter ID="IsNotStarted" Label="Not started" Type="CheckBox" Cell="@Cell" DefaultValue="false"/>
  <Parameter ID="IsPADSubscriber" Label="PAP subscribers only" Type="CheckBox" Cell="@Cell" DefaultValue="false"/>
  <Parameter ID="IsNotPADSubscriber" Label="Exclude PAP subscribers" Type="CheckBox" Cell="@Cell" DefaultValue="false"/>
  <Parameter ID="IsCardNotPrintedOnly" Label="Card not printed only" Type="CheckBox" Cell="@Cell" DefaultValue="false"/>
  <Parameter ID="HasLateFee" Label="Late fee" Type="CheckBox" Cell="@Cell" DefaultValue="false"/>
  <Parameter ID="HasNoLateFee" Label="No late fee" Type="CheckBox" Cell="@Cell" DefaultValue="false"/>
  <Parameter ID="ItemDescription" Label="Includes item" Type="TextBox" IsMandatory ="@IsMandatory" Cell="@Cell"/>
  <Parameter ID="CutOffNo" Label="label" Type="Numeric" Cell="@Cell" DefaultValue="0"/>
  <Parameter ID="IsUnassigned" Label="Include unassigned" Type="Checkbox" Cell="@Cell" DefaultValue="false"/>
  <Parameter ID="IsOpenOnly" Label="Open only" Type="Checkbox" Cell="@Cell" DefaultValue="false"/>
  <Parameter ID="IsUnprocessedOnly" Label="Unprocessed only" Type="Checkbox" Cell="@Cell" DefaultValue="false"/>
  <Parameter ID="IsOverDue" Label="Overdue only" Type="CheckBox" Cell="@Cell" DefaultValue="false"/>
  <Parameter ID="StagingIdentifier" Label="Identifier" Type="TextBox" IsMandatory ="@IsMandatory" Cell="@Cell"/>
	<Parameter ID="StagingLabel" Label="Label" Type="TextBox" IsMandatory ="@IsMandatory" Cell="@Cell"/>
</Parameters>
'			;
			select
				@parameterDef = cast(replace(replace(cast(x.ParameterXML as nvarchar(max)), '@Cell', ltrim(@Cell)), '@IsMandatory', @mandatorySetting) as xml)
			from
			(
				select
					parameter.node.value('@ID', 'nvarchar(128)') ParameterID
				 ,parameter.node.query('.')										 ParameterXML
				from
					@allParameters.nodes('Parameters/Parameter') as parameter(node)
			) x
			where
				x.ParameterID = @ParameterID;

			if @parameterDef is null
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'RecordNotFound'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
				 ,@Arg1 = 'Parameter'
				 ,@Arg2 = @ParameterID;

				raiserror(@errorText, 18, 1);
			end;

			if @Label is not null
			begin

				set @parameterDefString = replace(replace(cast(@parameterDef as nvarchar(max)), ' =', '='), '= ', '=');
				set @i = charindex('Label="', @parameterDefString);
				set @j = charindex('"', @parameterDefString, @i + 7);

				if @i > 0 and @j > 0
				begin
					set @parameterDefString = left(@parameterDefString, @i + 6) + replace(@Label, '"', '''') + N'"' + substring(@parameterDefString, @j + 1, 1000);
					set @parameterDef = cast(@parameterDefString as xml);
				end;

			end;

			if @DefaultValue is not null
			begin

				set @parameterDefString = replace(replace(cast(@parameterDef as nvarchar(max)), ' =', '='), '= ', '=');
				set @i = charindex('DefaultValue="', @parameterDefString);
				set @j = charindex('"', @parameterDefString, @i + 14);

				if @i > 0 and @j > 0
				begin
					set @parameterDefString =
						left(@parameterDefString, @i + 13) + replace(@DefaultValue, '"', '''') + N'"' + substring(@parameterDefString, @j + 1, 1000);
					set @parameterDef = cast(@parameterDefString as xml);
				end;
				else if @i = 0 and @j = 0 -- basic definition does not include a default so add it now
				begin
					set @parameterDefString += N' DefaultValue="' + replace(@DefaultValue, '"', '''') + N'"';
					set @parameterDef = cast(@parameterDefString as xml);
				end;

			end;

			-- add the summary index property to the parameter definition

			set @parameterDef = cast(replace(cast(@parameterDef as nvarchar(max)), N'Label=', 'SummaryIndex="' + ltrim(@summaryIndex + 1) + '" Label=') as xml);

			-- insert the parameter into the output parameter

			set @ParametersDoc.modify(N'insert sql:variable("@parameterDef") as last into (/Parameters)[1]');

		end;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
