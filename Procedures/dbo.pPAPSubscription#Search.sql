SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pPAPSubscription#Search
	@SearchString					nvarchar(150) = null	-- registrant name, registrant #, or email to search for
 ,@IsActiveSubscription bit = null						-- filter: active = ON, inactive = OFF, either = NULL (3 states!)
 ,@HasRejectedTrxs			bit = null						-- filter: has rejected = ON, no rejected = OFF, either = NULL (3 states!)
 ,@HasUnappliedAmount		bit = null						-- filter: unapplied > 0 = ON, unapplied = 0 OFF, either = NULL (3 states!)
 ,@QuerySID							int = null						-- SID of sf.Query row providing SQL syntax to execute - not combined
 ,@QueryParameters			xml = null						-- list of query parameters associated with the query SID
 ,@IsPinnedSearch				bit = 0								-- quick search: only returns pinned records - not combined
 ,@SIDList							xml = null						-- quick search: list of pinned records to return (xml contains SID's)
 ,@RecordSID						int = null						-- quick search: returns RENEWAL (not registration) based on system ID
 ,@RecordXID						varchar(150) = null		-- quick search: returns RENEWAL (not registration) based on an external ID
 ,@LegacyKey						nvarchar(50) = null		-- quick search: returns RENEWAL (not registration) based on a legacy key
 ,@IsFilterExcluded			bit = 0								-- when 1, filters are excluded even when populated (EXCEPT REGISTRATION YEAR)
 ,@IsRowLimitEnforced		bit = 1								-- when 0, the limit of maximum rows to return is not enforced (see below)
as
/*********************************************************************************************************************************
Procedure : PAP Subscription Search
Notice    : Copyright © 2017 Softworks Group Inc.
Summary   : Searches the PAP Subscription entity for the search string and/or other criteria provided
History   : Author(s)						| Month Year  | Change Summary
					: --------------------+-------------+-----------------------------------------------------------------------------------
					: Tim Edlund					| Sep 2017		| Initial version
					: Tim Edlund					| Aug 2018		| Implemented support for other name and past email searches (sf.fPerson#SearchNames)

Comments
--------
This procedure supports dashboard displays and general searches of the "PAP-Subscription" entity from the UI. Various search
options are supported but the primary method is to SELECT for a search string entered by the end user. The string typically
contains a registrant name, registrant number or email address. The other primary method is to search for work items by using
the filters provided - for example to find all subscriptions where unapplied amounts exist (so that refunds can be provided).

Default search
--------------
If no search string or custom query is passed to the procedure the default search is executed. The default search returns all
open PAP Subscriptions (limited by Max Rows) and the last @ClosedRowLimit most recently closed records. The closed-row-limit
can typically be edited by users on the UI and is passed by the caller.  Note that an Renewal is considered to be open where
the Registrant has a registration and no renewals is started, or, the subscription is started and possibly even APPROVED, but a registration
for the new (following) year has not yet been created. The Renewals is considered closed when a registration for the following
year has been generated.

Row Limit (MaxRows)
-------------------
The number of records returned on any search is limited by a configuration parameter setting "MaxRowsOnSearch" which if not set,
defaults to 200. The maximum is implemented to avoid timeout errors on rendering complex result layouts - particularly on slower
mobile-phone based connections.  The limit can be turned off by passing @IsRowLimitEnforced as 0 (it defaults to ON).

Filters
-------
Filters are applied in combination with text searches but do not apply when a query identifier has been passed in.  Filters are
based on foreign key values, derived bits, or in some cases date ranges  These searches can generally be applied without
significantly increasing processing time assuming appropriate indexing.

pSearchParam#Check (SF)
-----------------------
A subroutine in the framework is called to check parameters passed in and to format the text string and retrieve configuration
settings. The procedure is applied by all (current) search procedures and implements  formatting and priority-setting branching
critical to the searching process.  Be sure to review the documentation in that procedure thoroughly in order to debug issues
in search execution.

Text/String search
------------------
The search is performed against the person's full name, registrant number or email address.  Detection of a registration
number (vs name or email address) is based on matching a character string passed into the pSearchParam#Check procedure. For name
and email components, wild cards are supported within the text entered.  A trailing "%" is always added to the search string but
a leading "%" is not added in order to preserve use of indexes.  If a user wishes to search for records matching an email domain
only then, for example, a leading wildcard must be entered by them - e.g. "%@softworks.ca".

Dynamic queries
---------------
When the @QuerySID parameter is passed, then a dynamic query is executed from sf.Query.  The query syntax is retrieved from
and executed through a subroutine. This feature supports configuration-specific (custom) queries to be added to the installation.
See sf.pQuery#Search for additional details.  Queries are executed independently of the filter criteria (not combined).

System Identifier Searches
--------------------------
@RecordSID search ("SID: 12345")
@RecordXID search ("XID: AB12345")
@LegacyKey search	("LegacyKey: XYZ1111")

The procedure supports searches on 3 possible key values entered explicitly by including a prefix in the search string. These
searches are intended primarily for debugging (where SID is reported in the error message) and for validating converted
records.

The first search is on the primary key of the entity.  It can be invoked by passing the parameter directly, or by entering
the keyword "SID:" followed by a number into the @SearchString - e.g. "SID:1234567". The digits are stripped from the string
and converted into the parameter value by the procedure.  The conversion only takes place if all values following "SID:" are
digits. By allowing system ID's to the be entered into search string, administrators and configurators are able to trouble
shoot error messages that return SID's using the subscription's user interface.  The other 2 options are similar except that no
validation occurs for a specific data type.  The search against external ID's (XID) and LegacyKey are wildcard based so passing
a partial value will result in found records.  For Legacy-Key both the prefix "LegacyKey:" and "LKey:" are supported.

Sort order
----------
This procedure orders all results by name but other sort orders can be set in the UI.

Use of Memory Table
-------------------
The coding standard for search procedures is to retrieve key values of records matching the search into a temporary table,
and then join from that table to create the result set.  This technique, while more complex than direct SELECT's, generally
improves performance since complex columns returned to the UI for display only can be excluded from retrieval logic.

Example:
--------
<TestHarness>
	<Test Name = "DefaultAdmin" IsDefault ="true" Description="Runs default search for current registration year">
		<SQLScript>
			<![CDATA[
exec dbo.pPAPSubscription#Search
@isRowLimitEnforced = 1
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:03"/>
		</Assertions>
	</Test>
	<Test Name = "RegistrantNo" Description="Runs a registrant# search for an administrator">
		<SQLScript>
			<![CDATA[
declare
  @registrantNo varchar(50)
begin
  select top 1
		@registrantNo = r.RegistrantNo
	from
		dbo.Registrant			r
	join		dbo.PAPSubscription paps on r.PersonSID = paps.PersonSID
  order by
    newid()

  exec dbo.pPAPSubscription#Search																			-- search for registrant#
	  @SearchString = @registrantNo
end
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:03"/>
		</Assertions>
	</Test>
	<Test Name = "RegistrantName" Description="Runs a partial last name search">
		<SQLScript>
			<![CDATA[

exec dbo.pPAPSubscription#Search																			-- search for partial last name
	 @SearchString = N'bow'

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:03"/>
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
		@ObjectName = 'dbo.pPAPSubscription#Search'
	,	@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo			int						= 0								-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText		nvarchar(4000)									-- message text (for business rule errors)
	 ,@ON						bit						= cast(1 as bit)	-- used on bit comparisons to avoid multiple casts
	 ,@OFF					bit						= cast(0 as bit)	-- used on bit comparisons to avoid multiple casts
	 ,@searchType		varchar(25)											-- type of search; returned in result for debugging
	 ,@maxRows			int															-- maximum rows allowed on search
	 ,@registrantNo varchar(50)											-- ID of registrant (base of registration numbers)	
	 ,@lastName			nvarchar(35)										-- for name searches, buffer for each name part:
	 ,@firstName		nvarchar(30)
	 ,@middleNames	nvarchar(30);

	declare @selected table -- stores primary key values of records found
	(
		ID				int identity(1, 1) not null -- identity to track add order - preserves custom sorts
	 ,EntitySID int not null								-- record ID joined to main entity to return results
	);

	declare @pinned table -- stores primary key value of pinned records
	(ID int identity(1, 1) not null, EntitySID int not null);

	begin try

		-- if filters are to be excluded, set them to null
		-- (passed by the front end in order not to lose values from UI)

		if @IsFilterExcluded = @ON
		begin
			set @IsActiveSubscription = null;
			set @HasRejectedTrxs = null;
			set @HasUnappliedAmount = null;
		end;

		-- call a subroutine to validate and format search parameters and
		-- to return list of pinned records for this user (if any)

		insert
			@pinned (EntitySID)
		exec sf.pSearchParam#Check -- check parameters and format for searching
			@SearchString = @SearchString output
		 ,@RecordSID = @RecordSID output
		 ,@MaxRows = @maxRows output
		 ,@IDNumber = @registrantNo output
		 ,@LastName = @lastName output
		 ,@FirstName = @firstName output
		 ,@MiddleNames = @middleNames output
		 ,@IDCharacters = '0123456789'
		 ,@ConvertDatesToST = @ON
		 ,@PinnedPropertyName = 'PinnedPAPSubscriptionList';

		if @IsRowLimitEnforced = @OFF set @maxRows = 999999999;

		-- execute the searches

		if @QuerySID is not null -- dynamic query search (filters not applied)
		begin

			set @searchType = 'Query';

			insert
				@selected (EntitySID)
			exec sf.pQuery#Execute
				@QuerySID = @QuerySID
			 ,@QueryParameters = @QueryParameters
			 ,@MaxRows = @maxRows;	-- query syntax may support restriction on max rows so pass it

		end;
		else if @SIDList is not null -- set of specific SIDs passed or pinned record search (filters not applied)
		begin

			set @searchType = 'Identifiers';

			insert
				@selected (EntitySID)
			select top (@maxRows) -- parse attributes from the XML parameter document
				EntitySID.r.value('.', 'int') EntitySID -- return rows matching list of SID's passed in XML doc
			from
				@SIDList.nodes('//EntitySID') as EntitySID(r);

		end;
		else if @IsPinnedSearch = @ON -- returned pinned records (retrieved by #Check) - filters not applied
		begin

			set @searchType = 'Pins';

			insert @selected ( EntitySID) select top (@maxRows) p.EntitySID from @pinned p ;

		end;
		else if coalesce(@RecordSID, @RecordXID, @LegacyKey) is not null -- specific system ID was passed in search text - filters not applied
		begin

			if @RecordSID is not null set @searchType = 'SID';
			if @RecordXID is not null set @searchType = 'XID';
			if @LegacyKey is not null set @searchType = 'LegacyKey';

			-- search is run against both the registration and subscription
			-- entities since subscription form may not exist (outer join)

			insert
				@selected (EntitySID)
			select
				paps.PAPSubscriptionSID
			from
				dbo.PAPSubscription paps
			where
				paps.PAPSubscriptionSID = @RecordSID or isnull(paps.PAPSubscriptionXID, '!~@') = @RecordXID or isnull(paps.LegacyKey, '!~@') = @LegacyKey;

			if @@rowcount = 0 -- failure to find the record is unexpected
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'RecordNotFound'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The "%1" record was not found. Record ID = %2. The record may have been deleted or the identifier is invalid.'
				 ,@Arg1 = 'PAP Subscription'
				 ,@Arg2 = @RecordSID;

				raiserror(@errorText, 16, 1);

			end;

		end;
		else if @registrantNo is not null -- a search on the registrant's # (faster than name searches)
		begin

			set @searchType = 'RegistrantNo';

			insert
				@selected (EntitySID)
			select
				paps.PAPSubscriptionSID
			from
				dbo.Registrant			r
			join
				dbo.PAPSubscription paps on r.PersonSID = paps.PersonSID
			where
				r.RegistrantNo = @registrantNo;

			if @@rowcount = 0
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'IDNotFound'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The %1 "%2" was not found.'
				 ,@Arg1 = 'registrant#'
				 ,@Arg2 = @registrantNo;

				raiserror(@errorText, 16, 1);

			end;

		end;
		else if @SearchString is not null
		begin

			set @searchType = 'Text';

			insert
				@selected (EntitySID)
			select
				paps.PAPSubscriptionSID
			from
				sf.fPerson#SearchNames(@SearchString, @lastName, @firstName, @middleNames, @ON) px
			join
				dbo.PAPSubscription																												 paps on px.PersonSID = paps.PersonSID;

			if @@rowcount = 0
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'TextNotFound'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'No results were found for the search text entered.';

				raiserror(@errorText, 16, 1);

			end;

		end;
		else
		begin

			-- the default search is subscriptions limited by the max row limit
			-- and applying any bit filters that were set

			set @searchType = 'Default';

			insert
				@selected (EntitySID)
			select top (@maxRows)
				paps.PAPSubscriptionSID
			from
				dbo.vPAPSubscription paps
			where
				paps.IsActiveSubscription		= isnull(@IsActiveSubscription, paps.IsActiveSubscription)
				and paps.HasRejectedTrxs		= isnull(@HasRejectedTrxs, paps.HasRejectedTrxs)
				and paps.HasUnappliedAmount = isnull(@HasUnappliedAmount, paps.HasUnappliedAmount)
			order by
				paps.LastName
			 ,paps.FirstName
			 ,paps.MiddleNames;

		end;
		-- return only the columns required for display joining to the @selected
		-- table to apply found records, and to @pinned to apply pin attribute

		select top (@maxRows)
			--!<ColumnList DataSource="dbo.vPAPSubscription" Alias="paps">
			 paps.PAPSubscriptionSID
			,paps.PersonSID
			,paps.InstitutionNo
			,paps.TransitNo
			,paps.AccountNo
			,paps.WithdrawalAmount
			,paps.EffectiveTime
			,paps.CancelledTime
			,paps.UserDefinedColumns
			,paps.PAPSubscriptionXID
			,paps.LegacyKey
			,paps.IsDeleted
			,paps.CreateUser
			,paps.CreateTime
			,paps.UpdateUser
			,paps.UpdateTime
			,paps.RowGUID
			,paps.RowStamp
			,paps.GenderSID
			,paps.NamePrefixSID
			,paps.FirstName
			,paps.CommonName
			,paps.MiddleNames
			,paps.LastName
			,paps.BirthDate
			,paps.DeathDate
			,paps.HomePhone
			,paps.MobilePhone
			,paps.IsTextMessagingEnabled
			,paps.ImportBatch
			,paps.PersonRowGUID
			,paps.IsDeleteEnabled
			,paps.IsReselected
			,paps.IsNullApplied
			,paps.zContext
			,paps.RegistrantNo
			,paps.RegistrantLabel
			,paps.FileAsName
			,paps.DisplayName
			,paps.IsActiveSubscription
			,paps.HasRejectedTrxs
			,paps.HasUnappliedAmount
			,paps.EmailAddress
			,paps.TrxCount
			,paps.RejectedTrxCount
			,paps.TotalUnapplied
																										--!</ColumnList>
		 ,cast(isnull(z.EntitySID, 0) as bit) IsPinned	-- if key found in pinned list then @ON else @OFF
		 ,@searchType													SearchType												-- search type for debugging - ignored by UI
		from
			dbo.vPAPSubscription paps
		join
			@selected						 x on paps.PAPSubscriptionSID = x.EntitySID
		left outer join
			@pinned							 z on paps.PAPSubscriptionSID = z.EntitySID
		where
			paps.IsActiveSubscription		= isnull(@IsActiveSubscription, paps.IsActiveSubscription)
			and paps.HasRejectedTrxs		= isnull(@HasRejectedTrxs, paps.HasRejectedTrxs)
			and paps.HasUnappliedAmount = isnull(@HasUnappliedAmount, paps.HasUnappliedAmount)
		order by
			paps.LastName
		 ,paps.FirstName
		 ,paps.MiddleNames;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);

end;
GO
