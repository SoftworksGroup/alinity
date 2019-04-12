SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pPersonMailingAddress#GetAsHTML]
	@PersonSID	 int			-- key of the person record to return a formatted address for
 ,@IncludeName bit = 1	-- when 0 the name is not included as part of the address block
as
/*********************************************************************************************************************************
Sproc    : Person Mailing Address - Get as HTML (string)
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : Returns a single record and column containing an HTML string of the person's current address
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)				| Month Year    | Change Summary
				 : ---------------- | ------------- |-------------------------------------------------------------------------------------
				 : Tim Edlund				| Sep 2017			| Initial version.
----------------------------------------------------------------------------------------------------------------------------------
 
Comments
--------
This procedure looks up the current mailing address for the person key provided.  If no current address exists, then null is
returned.

Example:
--------
 
<TestHarness>
	<Test Name = "Default" IsDefault ="true" Description="Tests basic operation of procedure by selecting a person with an address at random.">
		<SQLScript>
			<![CDATA[

declare
	@personSID int

select top 1
	@personSID = p.PersonSID
from
	sf.Person p
join
	dbo.PersonMailingAddress pma on p.PersonSID = pma.PersonSID
order by 
	newid()

exec [dbo].[pPersonMailingAddress#GetAsHTML]
	@PersonSID	= @personSID

exec [dbo].[pPersonMailingAddress#GetAsHTML]
	@PersonSID	= @personSID
	,@IncludeName = 0

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="ExecutionTime" Value="00:00:03"/>
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName			= 'dbo.pPersonMailingAddress#GetAsHTML'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo int = 0								-- 0 no error, <50000 SQL error, else business rule
	 ,@ON			 bit = cast(1 as bit)		-- constant for bit comparison and assignments
	 ,@OFF		 bit = cast(0 as bit);	-- constant for bit comparison and assignments

	begin try

		select
			(sf.fFormatAddressForHTML(
																 (case when @IncludeName = @OFF then cast(null as nvarchar(100))else p.FullName end)
																,pmac.StreetAddress1
																,pmac.StreetAddress2
																,pmac.StreetAddress3
																,pmac.CityName
																,pmac.StateProvinceName
																,pmac.PostalCode
																,(case when pmac.CountryIsDefault = @ON then cast(null as nvarchar(50))else pmac.CountryName end)
															 )
			) FormattedAddress
		from
			sf.vPerson												p
		cross apply
			dbo.fPersonMailingAddress#Current(p.PersonSID) pmac
		where
			p.PersonSID = @PersonSID;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
