SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fRegistrant#Label]
(
	 @LastName											nvarchar(35)														-- surname - "Edlund"
	,@FirstName											nvarchar(30)														-- given name - "Tim"
	,@MiddleNames										nvarchar(30)														-- middle names or initials - "E'
	,@RegistrantNo									varchar(50)															-- ID number of the registrant - '12345'	
	,@Context												varchar(20)															-- context for use in custom overrides															
)
returns nvarchar(75)
as 
/*********************************************************************************************************************************
Function: Registrant Label
Notice  : Copyright © 2017 Softworks Group Inc.
Summary	: Returns a label for identifying the registrant.
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|---------------------------------------------------------------------------------------------
				: Tim Edlund	| Jun	2017		|	Initial version
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This function formats name values and registrant number as a label for identifying the registrant on inquiries and reports in
the system.  While the application provides a default format for the label a configuration-specific override can be implemented 
by deploying an override version of the function in the ext (extended) schema. The override version must be named the same, accept
the same parameters, and return the same data length.  If more values are required for the custom version of the function than
are provided in the parameters, the @RegistrantNo can be used to look them up.

@Context - is not applied in the product function but is passed to the extended function to support different formats for the
registrant label for different situations.  For example, some configuration may wish to mask the name of the registrant when
it appears on audit review forms.  The associated context value is: "AUDIT.REVIEW"

Leading and trailing spaces are trimmed from parameters before processing. No case conversions are applied.

Example
-------
<TestHarness>
	<Test Name = "Simple" Description="Returns the extended columns for an instance of the entity at random.">
	<SQLScript>
	<![CDATA[

select top 10
		p.LastName
	,	p.FirstName
	,	p.MiddleNames
	,	r.RegistrantNo
	, dbo.fRegistrant#Label(p.LastName, p.FirstName, p.MiddleNames, r.RegistrantNo, null) RegistrantLabel				
from 
	dbo.Registrant r
join
	sf.Person				p on r.PersonSID = p.PersonSID
order by
	newid()

	]]>
	</SQLScript>
	<Assertions>
		<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
		<Assertion Type="ExecutionTime" Value="00:00:02" />
	</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.fRegistrant#Label'

------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		 @formattedLabel				nvarchar(75)																	-- return value
		,@fileAsName						nvarchar(65)																	-- interim value for file-as-name - part of label

	-- format inbound parameters

	set @LastName					= ltrim(rtrim(@LastName))													-- remove leading and trailing spaces
	set @FirstName				= ltrim(rtrim(@FirstName))
	set @MiddleNames			= ltrim(rtrim(@MiddleNames))
	set @RegistrantNo			= ltrim(rtrim(@RegistrantNo))
	
	if len(@LastName)			= 0 set @LastName			= null											-- set zero length strings to null
	if len(@FirstName)		= 0	set @FirstName		= null
	if len(@MiddleNames)	= 0 set @MiddleNames	= null
	if len(@RegistrantNo) = 0 set @RegistrantNo	= null

	if exists(select 1 from sf.vRoutine r where r.SchemaName = 'ext' and r.RoutineName = 'fRegistrant#Label')
	begin
		set @formattedLabel = ext.fRegistrant#Label(@LastName, @FirstName, @MiddleNames, @RegistrantNo, @Context)
	end

	if @formattedLabel is null
	begin

		-- create registrant label based on the file-as-name format
		-- with registrant number appended

		set @fileAsName = sf.fFormatFileAsName(@LastName, @FirstName, @MiddleNames)

		if len(@fileAsName + @RegistrantNo) + 2 > 75 set @fileAsName = sf.fFormatFileAsName(@LastName, @FirstName, null)							-- if too long, remove middle name

		if len(@fileAsName + @RegistrantNo) + 2 > 75																																									-- if still too long, use initial for first name
		begin
			set @FirstName = left(@FirstName, 1)
			set @fileAsName = sf.fFormatFileAsName(@LastName, @FirstName, null) 
		end

		if @RegistrantNo is not null
		begin
			set @formattedLabel = cast( @fileAsName + ' (' + @RegistrantNo + ')' as nvarchar(75))
		end
		else
		begin
			set @formattedLabel = @fileAsName
		end

	end

	return(@formattedLabel)

end
GO
