SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fStringSegment]
(			
		@String							nvarchar(max)																			-- string to return a segment for
	,	@Delimiter					nvarchar(15)																			-- delimiter to cut string at	(NULL defaults to ',')
	,	@SegmentToReturn		tinyint																						-- segment of string to return (NULL defaults to 1)
)
returns nvarchar(1000)
as
/*********************************************************************************************************************************
ScalarF	: String Segment
Notice  : Copyright © 2017 Softworks Group Inc.
Summary	: Returns a segment of a string cut at the delimiter specified
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|---------------------------------------------------------------------------------------------
				: Tim Edlund  | Apr 2017		|	Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function is used to simplify parsing of strings.  It cuts the string at the delimiter specified and then returns the segment
number requested.  The function calls fSplitString which returns a table of all segments.

If the delimiter specified (or defaulted) is not found, NULL is returned.  NULL is also returned if the segment specified does
not exist.

Example
-------

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Calls function 3 times to output values for common scenarios. Results expected in all 3 columns">
		<SQLScript>
			<![CDATA[
			
select 
		sf.fStringSegment('ANALYZER.ADMIN', '.', 1)												StringSegmentANALYZER
	,	sf.fStringSegment('A,B,C,D,E,F,G', null, 3)												StringSegmentC
	,	sf.fStringSegment('Abracadabra.I.want.to.reach.OUT.and', '.', 6)  StringSegmentOUT
 
]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1" />
			<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="1" Value="ANALYZER"/>
			<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="2" Value="C"/>
			<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="1" Value="OUT"/>
			<Assertion Type="ExecutionTime" Value="00:00:01" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.fStringSegment'

------------------------------------------------------------------------------------------------------------------------------- */
begin

	if @SegmentToReturn is null set @SegmentToReturn = 1

	declare
		@stringSegment	nvarchar(1000)																				-- segment of string to return

	select 
		@stringSegment = x.Item 
	from 
		sf.fSplitString(@String, isnull(@Delimiter,',')) x
	where
		x.ID = @SegmentToReturn

	return(@stringSegment)

end
GO
