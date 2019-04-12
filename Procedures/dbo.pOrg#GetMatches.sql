SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pOrg#GetMatches]
	 @OrgName								nvarchar(150)									-- required - some matches will use first letter only
	,@OrgLabel							nvarchar(35)									-- required - "like" search performed
	,@StreetAddress1				nvarchar(75)									-- not used for searching but impacts ordering of results if matched
	,@PostalCode						varchar(10)		= null
	,@Phone									varchar(25)		= null
	,@Fax										varchar(25)		= null 
	,@WebSite								varchar(250)	= null
	,@MatchCount						int						= null output		-- rows returned
as
/*********************************************************************************************************************************
Procedure : Org - Get Matches
Notice    : Copyright © 2014 Softworks Group Inc.
Summary   : returns list of dbo.Org's which match or partially match criteria entered to establish a new child entity
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)   | Month Year   | Change Summary
				 : ------------|--------------|-------------------------------------------------------------------------------------------
				 : Cory Ng		 | Aug	2016    | Initial version
				 : Kris Dawson | Apr 2017     | Added columns required by quick-add UIs
----------------------------------------------------------------------------------------------------------------------------------
Comments
--------

This procedure supports wizard-styled UI's where the user has entered values required to establish a new Org record. It assists 
the user in avoiding the creation of a duplicate record. Parameter values passed to the procedure are searched in the dbo.Org 
table and matches and approximate matches are returned to the caller (the UI).  In the UI the user may choose to apply a Org 
record found as a new Org record, or, if the Person is already a record of the Org desired, the operation is canceled.

When no rows are returned by this procedure then the values entered are unique and a new Org record needs to be created.

The org label and name are stripped of common suffix names like "Hospital" or "Centre" to ensure matches returned when
the suffix is not provided or a different suffix is used. The label and name fields are searched also searched for in both
columns.

See the  WHERE clause in the syntax below for additional details of the search executed.

The records are returned in an order that attempts to put the most probable duplicates at the top of the list. For review 
purposes the ranking value is returned in the dataset but should not generally be displayed on the UI.

The procedure returns a bit for each column indicating whether or not it matches the associated column. The bit columns are
used on the UI to highlight the specific cells that match the values entered.  

Example
-------

<TestHarness>
	<Test Name="Simple" IsDefault="true" Description="Returns matches for a test organization.">
		<SQLScript>
			<![CDATA[
exec dbo.pOrg#GetMatches
		@OrgName		= 'Test Org'
	 ,@OrgLabel		= 'Test Org'
	 ,@StreetAddress1 = '123 Fake St.'
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="ExecutionTime" Value="00:00:03" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.pOrg#GetMatches'
		
-------------------------------------------------------------------------------------------------------------------------------- */
set nocount on

begin

	declare
		 @errorNo                         int = 0															-- 0 no error, <50000 SQL error, else business rule
		,@errorText                       nvarchar(4000)											-- message text (for business rule errors)
		,@blankParm												varchar(50)													-- tracks if any required parameters are not provided
		,@maxRows                         int                                 -- maximum rows to return on the search
		
	set @MatchCount = 0

	begin try

		-- check parameters

		if @OrgName is null set @blankParm = 'OrgName'
		if @OrgLabel  is null set @blankParm = 'OrgLabel'
		if @StreetAddress1  is null set @blankParm = 'StreetAddress1'

		if @blankParm is not null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= @blankParm

			raiserror(@errorText, 18, 1)
		
		end
		
		-- for parameters not passed, set to values that won't be found on searches (avoid searching for nulls)

		set @PostalCode				= isnull(@PostalCode, '?')
		set @Phone						= isnull(@Phone, '?')
		set @Fax							= isnull(@Fax, '?')
		set @WebSite					= isnull(@WebSite, '?')

		-- prepare criteria for searching
		
		set @OrgLabel				= sf.fReplaceAll(@OrgLabel, N'center,,centre,,hospital,,inc.,,clinic,, ,%', N',')			-- strip commonly used words to increase chance of match
		set @OrgLabel				= cast(sf.fSearchString#Format(@OrgLabel)     as nvarchar(35))												-- format search name values to eliminate outer spaces 
		set @OrgName				= sf.fReplaceAll(@OrgName, N'center,,centre,,hospital,,inc.,,clinic,, ,%', N',')			-- and adds % character (when not null)	
		set @OrgName				= cast(sf.fSearchString#Format(@OrgName)			as nvarchar(150))                       
		set @StreetAddress1	= cast(sf.fSearchString#Format(@StreetAddress1)	as nvarchar(75))												

		set @PostalCode  = sf.fFormatPostalCode(@PostalCode)
		set @Phone  = sf.fFormatPhone(@Phone)																																	
		set @Fax    = sf.fFormatPhone(@Fax)     

		-- obtain max rows to return from configuration or set to 100

		set @maxRows = isnull(convert(smallint, sf.fConfigParam#Value('MaxRowsOnSearch')), convert(int, 100))
				
		select
			 x.OrgSID
			,x.OrgName
			,x.OrgLabel
			,x.StreetAddress1
			,x.StreetAddress2
			,x.PostalCode
			,x.Phone
			,x.Fax
			,x.WebSite
			,cast(x.OrgNameMatched 				as bit)			IsOrgNameMatched 				-- convert non-zero matches to bit = 1
			,cast(x.OrgLabelMatched 			as bit)			IsOrgLabelMatched 
			,cast(x.StreetAddress1Matched	as bit)			IsStreetAddress1Matched	
			,cast(x.StreetAddress2Matched	as bit)			IsStreetAddress2Matched
			,cast(x.PhoneMatched					as bit)			IsPhoneMatched
			,cast(x.FaxMatched						as bit)			IsFaxMatched
			,cast(x.PostalCodeMatched			as bit)			IsPostalCodeMatched
			,cast(x.WebSiteMatched				as bit)			IsWebSiteMatched
			,x.IsActive
      ,x.IsCredentialAuthority
      ,x.IsEmployer
			,(
				x.OrgNameMatched 		
			+ x.OrgLabelMatched 
			+ x.StreetAddress1Matched
			+ x.StreetAddress2Matched
			+ x.PhoneMatched
			+ x.FaxMatched
			+ x.PostalCodeMatched
			+ x.WebSiteMatched
			)																						RankOrder	
		from
		(
		select top (@maxRows)
			 o.OrgSID
			,o.OrgName
			,o.OrgLabel
			,o.StreetAddress1
			,o.StreetAddress2
			,o.PostalCode
			,o.Phone
			,o.Fax
			,o.WebSite      
			,case																																																														                    -- assign points on matches for rank order
				when (o.OrgName like @OrgLabel or o.OrgName like @OrgName)																																then 3
				else 0
			 end																																																												OrgNameMatched
			,case
				when (o.OrgLabel like @OrgLabel or o.OrgLabel like @OrgName)																			  											then 3
				else 0
			 end																																																												OrgLabelMatched
			,case
				when o.StreetAddress1 like @StreetAddress1																																								then 3
				else 0
			 end																																																												StreetAddress1Matched
			,case
				when o.StreetAddress2 like @StreetAddress1																																								then 3
				else 0
			 end																																																												StreetAddress2Matched
			,case
				when isnull(o.Phone, '!') = @Phone																																												then 5
				else 0
			 end																																																												PhoneMatched
			,case
				when isnull(o.Fax, '!') = @Fax																																														then 5
				else 0
			 end																																																												FaxMatched
			,case
				when isnull(o.PostalCode, '!') = @PostalCode																																							then 3		
				else 0
			 end																																																												PostalCodeMatched
			,case
				when isnull(o.WebSite, '!') = @WebSite																																										then 5
				else 0
			 end																																																												WebSiteMatched       
			 ,o.IsActive
       ,o.IsCredentialAuthority
       ,o.IsEmployer
		from
			dbo.Org o
		where
			o.OrgLabel like @OrgLabel
		or
			o.OrgLabel like @OrgName
		or
			o.OrgName like @OrgLabel
		or
			o.OrgName like @OrgName
		or
			o.StreetAddress1 like @StreetAddress1
		or
			isnull(o.StreetAddress2, '!') like @StreetAddress1
		or
			isnull(o.Phone, '!') = @Phone
		or
			isnull(o.Fax, '!') = @Fax
		or
			isnull(o.PostalCode, '!') = @PostalCode
		or
			isnull(o.WebSite, '!') = @WebSite
		) x
	order by
		(
				x.OrgNameMatched 		
			+ x.OrgLabelMatched 
			+ x.StreetAddress1Matched
			+ x.StreetAddress2Matched
			+ x.PhoneMatched
			+ x.FaxMatched
			+ x.PostalCodeMatched
			+ x.WebSiteMatched
		 ) desc	
		,x.OrgName
		
	set @MatchCount = @@rowcount																																									                  -- return results so that most likely duplicates appear first

	end try

	begin catch
		exec @errorNo = sf.pErrorRethrow																																	                            -- catch the error, rollback if pending, and re-throw
	end catch

	return(@errorNo)

end
GO
