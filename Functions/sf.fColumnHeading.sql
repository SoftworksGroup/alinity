SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fColumnHeading]
	(
	 @EntityName					nvarchar(128)																			-- name of the entity (table) associated with column
	,@ColumnName					nvarchar(128)																			-- entity view column to generate default label for
	)
returns nvarchar(512)
as
/*********************************************************************************************************************************
Function: Column Heading
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: Returns an object name formatted to match standards for column labels in SGI UI's
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|---------------------------------------------------------------------------------------------
				: Tim Edlund	| Jan	2014		|	Initial version
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This function is used to generate default headings for dynamically generated grids and for use in code generation.  The function 
relies on the sf.fColumnLabel function to do most of the formatting and to replace specific words according to the UI standards
for Softworks and Alinity products.  See that function for details of replacement logic.

This function takes the default string generated from the sf.fColumnLabel function and ensures that the first letter of all
words appear in upper case.  The SGI/AI standard for column headings is to use upper case for column headings while column labels
only have their first word in upper case and remaining words down styled.

The function also overrides the default label text with shorter versions to use in heading in specific circumstances. See detailed
logic below for the overrides applied.

Example:
--------
<TestHarness>
  <Test Name="fColumnHeadingTest" IsDefault="true" Description="Exercises the fColumnHeading function, and compares results
	against expected values.">
    <SQLScript>
      <![CDATA[

				select sf.fColumnHeading( 'x', 'UpdateTime')															--> Updated on
				select sf.fColumnHeading( 'x', 'CreateUser')															--> Created by
				select sf.fColumnHeading( 'x', 'MyTestColumn')														--> My test column
				select sf.fColumnHeading( 'x', 'ComputerIPAddress')												--> Computer IP address
				select sf.fColumnHeading( 'x', 'EpisodeAssignment')												--> Case assignment
				select sf.fColumnHeading( 'x', 'LastName')																--> Last name
				select sf.fColumnHeading( 'x', 'RegistrantNo')														--> Registrant#
				select sf.fColumnHeading( 'x', 'IsDeleteEnabled')													--> Delete enabled
				select sf.fColumnHeading( 'x', 'DisplayName')															--> Name

			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="RowCount" ResultSet="1" Value="1"/>
      <Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="1" Value="Updated On"/>
      <Assertion Type="ScalarValue" ResultSet="2" Row="1" Column="1" Value="Created By"/>
      <Assertion Type="ScalarValue" ResultSet="3" Row="1" Column="1" Value="My Test Column"/>
      <Assertion Type="ScalarValue" ResultSet="4" Row="1" Column="1" Value="Computer Ipaddress"/>
      <Assertion Type="ScalarValue" ResultSet="5" Row="1" Column="1" Value="Case Assignment"/>
      <Assertion Type="ScalarValue" ResultSet="6" Row="1" Column="1" Value="Last Name"/>
      <Assertion Type="ScalarValue" ResultSet="7" Row="1" Column="1" Value="Registrant#"/>
      <Assertion Type="ScalarValue" ResultSet="8" Row="1" Column="1" Value="Delete Enabled"/>
      <Assertion Type="ScalarValue" ResultSet="9" Row="1" Column="1" Value="Name"/>
      <Assertion Type="ExecutionTime" Value="00:00:01" />
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.fColumnHeading'
------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare	
		 @columnHeadingOut					nvarchar(512)							                -- string to return; heading with spaces inserted

	set @columnHeadingOut = sf.fColumnLabel(@EntityName, @ColumnName)	

	-- if the column heading starts with the entity name (and isn't just the entity name)
	-- strip the entity name out to make the heading shorter

	if @columnHeadingOut like @EntityName + N'%' and @columnHeadingOut <> @EntityName set @columnHeadingOut = replace(@columnHeadingOut, @EntityName, N'')

	-- apply other shorter translations for standard column terms

	if @columnHeadingOut like N'%System code'			set @columnHeadingOut = replace(@columnHeadingOut, 'System code'		,	'code')
	if @columnHeadingOut like N'%Record version'	set @columnHeadingOut = replace(@columnHeadingOut, 'Record version'	, 'version')
	if @columnHeadingOut like N'% Date'						set @columnHeadingOut = substring(@columnHeadingOut, 1, len(@columnHeadingOut) - 5)

	set @columnHeadingOut = cast(sf.fProperCase(@columnHeadingOut) as nvarchar(512))									-- ensure secondary words start with uppercase

	return(@columnHeadingOut)
	
end
GO
