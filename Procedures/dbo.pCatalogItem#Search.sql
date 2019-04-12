SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pCatalogItem#Search]
	@SearchString					nvarchar(150) = null	-- catalog item label or invoice item description to search for
 ,@IsActive							bit						= 1			-- filter: active = ON, inactive = OFF, either = null (3 positions!)
 ,@QuerySID						  int						= null	-- SID of sf.Query row providing SQL syntax to execute - not combined
 ,@QueryParameters			xml						= null	-- list of query parameters associated with the query SID
 ,@IsPinnedSearch				bit						= 0			-- quick search: only returns pinned records - not combined
 ,@SIDList							xml						= null	-- quick search: list of pinned records to return (xml contains SID's)
 ,@RecordSID						int						= null	-- quick search: returns RENEWAL (not registration) based on system ID
 ,@RecordXID						varchar(150)	= null	-- quick search: returns RENEWAL (not registration) based on an external ID
 ,@LegacyKey						nvarchar(50)	= null	-- quick search: returns RENEWAL (not registration) based on a legacy key
 ,@IsFilterExcluded			bit						= 0			-- when 1, filters are excluded even when populated (EXCEPT REGISTRATION YEAR)
 ,@IsRowLimitEnforced		bit						= 1			-- when 0, the limit of maximum rows to return is not enforced (see below)
as
/*********************************************************************************************************************************
Procedure : Catalog Item Search
Notice    : Copyright © 2017 Softworks Group Inc.
Summary   : Searches the Catalog Item entity for the search string and/or other criteria provided
History   : Author(s)   | Month Year  | Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Cory Ng   	| Mar 2018		| Initial version

Comments
--------
This procedure supports dashboard displays and general searches of the "CatalogItem" entity from the UI.

Default search
--------------
If no search string or custom query is passed to the procedure the default search is executed. The default search returns active
catalog items up to the max row limit.

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

        exec dbo.pCatalogItem#Search

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:03"/>
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
		@ObjectName = 'dbo.pCatalogItem#Search'
	,	@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */

set nocount on;

begin

	declare
		@errorNo			int						= 0								-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText		nvarchar(4000)									-- message text (for business rule errors)
	 ,@ON						bit						= cast(1 as bit)	-- used on bit comparisons to avoid multiple casts
	 ,@OFF					bit						= cast(0 as bit)	-- used on bit comparisons to avoid multiple casts
	 ,@searchType		varchar(25)											-- type of search; returned in result for debugging
	 ,@maxRows			int															-- maximum rows allowed on search

	declare @selected table -- stores primary key values of records found
	(
		ID				int identity(1, 1) not null -- identity to track add order - preserves custom sorts
	 ,EntitySID int not null								-- record ID joined to main entity to return results
	);

	declare @pinned table -- stores primary key value of pinned records
	(
     ID int identity(1, 1) not null
    ,EntitySID int not null
  );

	begin try

		-- call a subroutine to validate and format search parameters and
		-- to return list of pinned records for this user (if any)

		insert
			@pinned (EntitySID)
		exec sf.pSearchParam#Check -- check parameters and format for searching
			@SearchString = @SearchString output
		 ,@RecordSID = @RecordSID output
		 ,@MaxRows = @maxRows output
		 ,@IDCharacters = '0123456789'
		 ,@ConvertDatesToST = @OFF
		 ,@PinnedPropertyName = 'PinnedCatalogItemList';

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
,@MaxRows = @maxRows; -- query syntax may support restriction on max rows so pass it

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

			insert
				@selected (EntitySID)
			select top (@maxRows) p.EntitySID from	@pinned p;

		end;
		else if coalesce(@RecordSID, @RecordXID, @LegacyKey) is not null -- specific system ID was passed in search text - filters not applied
		begin

			if @RecordSID is not null set @searchType = 'SID';
			if @RecordXID is not null set @searchType = 'XID';
			if @LegacyKey is not null set @searchType = 'LegacyKey';

			insert
				@selected (EntitySID)
			select
				pb.CatalogItemSID
			from
				dbo.CatalogItem pb
			where
				pb.CatalogItemSID        										= @RecordSID
				or isnull(pb.CatalogItemXID, '!~@')          = @RecordXID
				or isnull(pb.LegacyKey,   '!~@')					= @LegacyKey;

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
		else if @SearchString is not null
		begin

			set @searchType = 'Text';
			
			if left(@SearchString, 1) <> N'%' 
			begin
				set @SearchString = cast(N'%' + @SearchString as nvarchar(150))     -- add % to start of string if not already there
			end

			insert
				@selected (EntitySID)
			select
				ci.CatalogItemSID
			from
				dbo.CatalogItem		ci
			where
				ci.CatalogItemLabel like @SearchString
      or
        ci.InvoiceItemDescription like @SearchString

		end;
		else
		begin

			-- the default search is catalog items limited by the max row limit
			-- and applying any bit filters that were set

			set @searchType = 'Default';

			insert
				@selected (EntitySID)
			select top (@maxRows)
				ci.CatalogItemSID
			from
				dbo.vCatalogItem ci
      where
        @IsActive is null
      or
        (ci.IsActive = @OFF and @IsActive	= @OFF)
      or
				(ci.IsActive = @ON and @IsActive = @ON)
		  order by
			  ci.CatalogItemLabel;

		end;
		-- return only the columns required for display joining to the @selected
		-- table to apply found records, and to @pinned to apply pin attribute

		select top (@maxRows)
			--!<ColumnList DataSource="dbo.vCatalogItem" Alias="ci">
			 ci.CatalogItemSID
			,ci.CatalogItemLabel
			,ci.InvoiceItemDescription
			,ci.IsLateFee
			,ci.ItemDetailedDescription
			,ci.ItemSmallImage
			,ci.ItemLargeImage
			,ci.ImageAlternateText
			,ci.IsAvailableOnClientPortal
			,ci.IsComplaintPenalty
			,ci.GLAccountSID
			,ci.IsTaxRate1Applied
			,ci.IsTaxRate2Applied
			,ci.IsTaxRate3Applied
			,ci.IsTaxDeductible
			,ci.EffectiveTime
			,ci.ExpiryTime
			,ci.FileTypeSCD
			,ci.FileTypeSID
			,ci.UserDefinedColumns
			,ci.CatalogItemXID
			,ci.LegacyKey
			,ci.IsDeleted
			,ci.CreateUser
			,ci.CreateTime
			,ci.UpdateUser
			,ci.UpdateTime
			,ci.RowGUID
			,ci.RowStamp
			,ci.GLAccountCode
			,ci.GLAccountLabel
			,ci.IsRevenueAccount
			,ci.IsBankAccount
			,ci.IsTaxAccount
			,ci.IsPAPAccount
			,ci.IsUnappliedPaymentAccount
			,ci.DeferredGLAccountCode
			,ci.GLAccountIsActive
			,ci.GLAccountRowGUID
			,ci.FileTypeFileTypeSCD
			,ci.FileTypeLabel
			,ci.MimeType
			,ci.IsInline
			,ci.FileTypeIsActive
			,ci.FileTypeRowGUID
			,ci.IsActive
			,ci.IsPending
			,ci.IsDeleteEnabled
			,ci.IsReselected
			,ci.IsNullApplied
			,ci.zContext
			,ci.CurrentPrice
			,ci.Tax1Label
			,ci.Tax1Rate
			,ci.Tax1GLAccountSID
			,ci.Tax1Amount
			,ci.Tax2Label
			,ci.Tax2Rate
			,ci.Tax2GLAccountSID
			,ci.Tax2Amount
			,ci.Tax3Label
			,ci.Tax3Rate
			,ci.Tax3GLAccountSID
			,ci.Tax3Amount
			--!</ColumnList>
		 ,cast(isnull(z.EntitySID, 0) as bit) IsPinned	-- if key found in pinned list then @ON else @OFF
		 ,@searchType													SearchType												-- search type for debugging - ignored by UI
		from
			dbo.vCatalogItem ci
		join
			@selected						 x on ci.CatalogItemSID = x.EntitySID
		left outer join
			@pinned							 z on ci.CatalogItemSID = z.EntitySID
		order by
			ci.CatalogItemLabel;

	end try

	begin catch
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);

end;
GO
