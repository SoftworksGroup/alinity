SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pCredential#GetMatches]
	 @CredentialLabel				nvarchar(35)	=	null				-- may be included to limit results to a specific program name
	,@MatchCount						int						= null output		-- rows returned
as
/*********************************************************************************************************************************
Procedure : Credential - Get Matches
Notice    : Copyright © 2014 Softworks Group Inc.
Summary   : returns list of dbo.Credential's which match or partially match criteria entered to establish a new child entity
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)		| Month Year  | Change Summary
				 : ------------	|-------------|-------------------------------------------------------------------------------------------
				 : Cory Ng			| Aug	2016    | Initial version
				 : Tim Edlund		|	Apr 2017		| Updated for movement of OrgSID from dbo.Credential to dbo.RegistrantCredential	
----------------------------------------------------------------------------------------------------------------------------------
Comments
--------

This procedure supports wizard-styled UI's where the user has entered values required to establish a new Credential record. It 
assists the user in avoiding the creation of a duplicate record. Parameter values passed to the procedure are searched in the 
dbo.Credential table and matches and approximate matches are returned to the caller (the UI).  In the UI the user may choose to 
apply a Credential record found as a new Credential record, or, if the Person is already a record of the Credential desired, the 
operation is canceled.

When no rows are returned by this procedure then the values entered are unique and a new Credential record needs to be created.

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

declare
	 @CredentialLabel				nvarchar(65)

select top 1
	 @CredentialLabel				= c.CredentialLabel
from
	dbo.Credential c
order by
	newid()

exec dbo.pCredential#GetMatches
		@CredentialLabel				= @CredentialLabel
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="ExecutionTime" Value="00:00:03" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.pCredential#GetMatches'
		
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

		if @CredentialLabel	is null set @blankParm = '@CredentialLabel'

		if @blankParm is not null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= @blankParm

			raiserror(@errorText, 18, 1)
		
		end
		
		-- prepare criteria for searching
		
		set @CredentialLabel = '%' + sf.fReplaceAll(@CredentialLabel, N'program,,degree,,diploma,,certificate.,, ,%', N',') + '%'

		-- obtain max rows to return from configuration or set to 100

		set @maxRows = isnull(convert(smallint, sf.fConfigParam#Value('MaxRowsOnSearch')), convert(int, 100))
				
		select
			 x.CredentialSID
			,x.CredentialLabel
			,cast(x.ProgramNameMatched 				as bit)				IsProgramNameMatched 	-- convert non-zero matches to bit = 1
			,cast(x.OrgSIDMatched 						as bit)				IsOrgSIDMatched
			,cast(x.CredentialTypeSIDMatched	as bit)				IsCredentialTypeSIDMatched
			,(
					x.ProgramNameMatched 
				+ x.OrgSIDMatched
				+ x.CredentialTypeSIDMatched
			)																						RankOrder	
		from
		(
		select top (@maxRows)
			 c.CredentialSID
			,c.CredentialLabel
			,case																																																														                    -- assign points on matches for rank order
				when (c.CredentialLabel like @CredentialLabel)																																										then 1
				else 0
			 end																																																												ProgramNameMatched
			,1																																																													OrgSIDMatched						-- only returns record if these match:
			,1																																																													CredentialTypeSIDMatched				
		from
			dbo.[Credential]		c
		where
			c.CredentialLabel like @CredentialLabel
		) x
	order by
		(
				x.ProgramNameMatched 		
			+ x.OrgSIDMatched 
			+ x.CredentialTypeSIDMatched
		 ) desc	
		,x.CredentialLabel
		
	set @MatchCount = @@rowcount																																									                  -- return results so that most likely duplicates appear first

	end try

	begin catch
		exec @errorNo = sf.pErrorRethrow																																	                            -- catch the error, rollback if pending, and re-throw
	end catch

	return(@errorNo)

end
GO
