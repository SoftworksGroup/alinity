SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fColumnLabel]
	(
	 @EntityName					nvarchar(128)																			-- name of the entity (table) associated with column
	,@ColumnName					nvarchar(128)																			-- entity view column to generate default label for
	)
returns nvarchar(512)
as
/*********************************************************************************************************************************
Function: Column Label
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: Returns an object name formatted to match standards for column labels in Softworks and Alinity product development
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|---------------------------------------------------------------------------------------------
				: Tim Edlund	| Jan	2014		|	Initial version
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This function is used to generate default labels for dynamically generated screens and for use in code generation.  The function 
relies on the sf.fObjectNameSpaced function to put in spaces in the label where casing changes.  Since the database modeling 
standard is to create column names with mixed case - change in case (upper/lower) is used to denote word separation where spaces
are inserted.  E.g. LastName -> Last Name.  

This function then applies additional formatting rules to change to lower case, all words in the label except the first one.  It 
also strips specific leading and trailing words, and makes replacements for specific system text to make those columns easier for 
users to understand.  The end result is a default label only; developers still must look at the output and override some values 
for specific circumstances.  Generated output is typically loaded into a project resource file where the overrides can be applied 
manually.  

The @EntityName parameter is required but it is not validated against schema.  The value is only used to distinguish between "SID"
columns that are Primary Keys and Foreign Keys.  The default labeling for each is different.

For the detailed list of replacements and translations applied, inspect source code below.

Note this function is also called by sf.fColumnHeading which provides a similar service but produces headings where all words
returned are capitalized. 

Example:
--------
<TestHarness>
  <Test Name="fColumnLabelTest" IsDefault="true" Description="Exercises the fColumnLabel function, and compares results
	against expected values.">
    <SQLScript>
      <![CDATA[ 
			
				select sf.fColumnLabel( 'x', 'UpdateTime')																--> Updated on
				select sf.fColumnLabel( 'x', 'CreateUser')																--> Created by
				select sf.fColumnLabel( 'x', 'MyTestColumn')															--> My test column
				select sf.fColumnLabel( 'x', 'ComputerIPAddress')													--> Computer IP address
				select sf.fColumnLabel( 'x', 'EpisodeAssignment')													--> Case assignment
				select sf.fColumnLabel( 'x', 'LastName')																	--> Last name
				select sf.fColumnLabel( 'x', 'RegistrantNo')															--> Registrant#
				select sf.fColumnLabel( 'x', 'IsDeleteEnabled')														--> Delete enabled
				select sf.fColumnLabel( 'x', 'DisplayName')																--> Name

			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="RowCount" ResultSet="1" Value="1"/>
      <Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="1" Value="Updated on"/>
      <Assertion Type="ScalarValue" ResultSet="2" Row="1" Column="1" Value="Created by"/>
      <Assertion Type="ScalarValue" ResultSet="3" Row="1" Column="1" Value="My test column"/>
      <Assertion Type="ScalarValue" ResultSet="4" Row="1" Column="1" Value="Computer IPAddress"/>
      <Assertion Type="ScalarValue" ResultSet="5" Row="1" Column="1" Value="Case assignment"/>
      <Assertion Type="ScalarValue" ResultSet="6" Row="1" Column="1" Value="Last name"/>
      <Assertion Type="ScalarValue" ResultSet="7" Row="1" Column="1" Value="Registrant#"/>
      <Assertion Type="ScalarValue" ResultSet="8" Row="1" Column="1" Value="Delete enabled"/>
      <Assertion Type="ScalarValue" ResultSet="9" Row="1" Column="1" Value="Name"/>
      <Assertion Type="ExecutionTime" Value="00:00:01" />
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.fColumnLabel'

------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare	
		 @columnLabelOut					nvarchar(512)							                  -- string to return; label with spaces inserted
		,@columnLabelIn						nvarchar(512)							                  -- working string to extract separate words from
		,@i								        int                 = 1                     -- character position index
		,@nextWord								nvarchar(512)																-- next word to process
		,@char						        nchar(1)                                    -- next character within word to process
		,@ON											bit		= cast(1 as bit)											-- constant to eliminate redundant casting syntax
		,@OFF											bit		= cast(0 as bit)											-- constant to eliminate redundant casting syntax

	-- handle hard coded assignments for standard system columns

	if @ColumnName = N'CreateTime'
	begin
		set @columnLabelOut = N'Created on'
	end
	else if @ColumnName = N'UpdateTime'
	begin
		set @columnLabelOut = N'Updated on'
	end
	else if @ColumnName = N'CreateUser'
	begin
		set @columnLabelOut = N'Created by'
	end
	else if @ColumnName = N'UpdateUser'
	begin
		set @columnLabelOut = N'Updated by'
	end
	else if @ColumnName = N'RowStamp'
	begin
		set @columnLabelOut = N'Record version'
	end
	else if @ColumnName = N'RowGUID'
	begin
		set @columnLabelOut = N'Global ID'
	end
	else if @ColumnName = @EntityName + 'SID'
	begin
		set @columnLabelOut = N'System ID'
	end
	else if @ColumnName = @EntityName + 'SCD'
	begin
		set @columnLabelOut = N'System code'
	end
	else if @ColumnName = @EntityName + 'XID'
	begin
		set @columnLabelOut = N'External ID'
	end
	else if @ColumnName = N'zContext'
	begin
		set @columnLabelOut = N'Context'
	end
	else
	begin

		-- process remaining columns according to SGI label standards

		set @columnLabelIn = sf.fObjectNameSpaced(@ColumnName)

		if @columnLabelIn like N'Is %'				set @columnLabelIn = substring(@columnLabelIn, 4, 512)																	-- strip specific leading words
		if @columnLabelIn like N'Display %'		set @columnLabelIn = substring(@columnLabelIn, 9, 512)

		if @columnLabelIn like N'% Number'		set @columnLabelIn = substring(@columnLabelIn, 1, len(@columnLabelIn) - 7)							-- strip specific trailing words
		if @columnLabelIn like N'% Phone'			set @columnLabelIn = substring(@columnLabelIn, 1, len(@columnLabelIn) - 6)				
		if @columnLabelIn like N'% Image'			set @columnLabelIn = substring(@columnLabelIn, 1, len(@columnLabelIn) - 6)

		if @columnLabelIn like N'% No'				set @columnLabelIn = substring(@columnLabelIn, 1, len(@columnLabelIn) - 3) + '#'				-- replace specific trailing words
		if @columnLabelIn like N'% Row GUID'	set @columnLabelIn = substring(@columnLabelIn, 1, len(@columnLabelIn) - 9) + ' global ID'
		if @columnLabelIn like N'% SCD'				set @columnLabelIn = substring(@columnLabelIn, 1, len(@columnLabelIn) - 4) + ' system code'
		if @columnLabelIn like N'% XID'				set @columnLabelIn = substring(@columnLabelIn, 1, len(@columnLabelIn) - 4) + ' external ID'

		if @columnLabelIn like N'% SID'				set @columnLabelIn = substring(@columnLabelIn, 1, len(@columnLabelIn) - 4)							-- FK - just show main entity name

		if @columnLabelIn like N'% Email Address%'	set @columnLabelIn = replace(@columnLabelIn, 'Email Address', 'Email')

		if @columnLabelIn like N'%Episode%'		set @columnLabelIn = replace(@columnLabelIn, 'Episode', 'Case')													-- synoptec term replacement

		while len(@columnLabelIn) > 0
		begin

			set @i						= charindex(N' ', @columnLabelIn)																						-- now search for word breaks
			set @char					= N'x'

			if @i = 0 
			begin
				set @nextWord = @columnLabelIn
				set @columnLabelIn = N''
			end
			else
			begin
				set @nextWord	= substring(@columnLabelIn, 1, @i - 1)
				set @columnLabelIn = ltrim(rtrim(substring(@columnLabelIn, @i + 1, 512)))
			end

			if len(@nextWord) > 1 set @char	= substring(@nextWord, 2, 1)

			if @columnLabelOut is null or len(@nextWord) = 1 or sf.fIsUpper(@char) = @ON
			begin
				set @columnLabelOut = isnull(@columnLabelOut + N' ', N'') + @nextWord
			end
			else
			begin
				set @columnLabelOut += N' ' + lower(@nextWord)										-- all words except first or those with upper case in second
			end																																	-- position are down styled to match labeling standard

		end

	end

	return(@columnLabelOut)
	
end
GO
