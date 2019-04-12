SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pSearchName#SplitDS]
	 @SearchName											nvarchar(150)											    -- text containing the name values to search
as
/*********************************************************************************************************************************
Sproc    : Search Name Split - Data Set
Notice   : Copyright © 2014 Softworks Group Inc.
Summary  : Parses name search string provided into last, first and middle name components formatted and ready for "LIKE" search
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-------------------------------------------------------------------------------------------
				 : Tim Edlund   | Jun 2014			| Initial Version

Comments  
--------
This is a wrapper procedure that calls the table function sf.fSearchName#Split to perform parsing of a search name into last, 
first and middle name components.  The values are returned as a data set (DS).  Another procedure without the "DS" extension in
the name, also exists and returns this information as output parameters.

The name components are assumed to reside in sf.Person which is the basis of the data types and lengths of output parameters.  The 
function called parses the search string provided in @SearchName into 1 or more of the 3 name parts returned as output.  See the 
table function for a description of parsing logic.

Note that if a user wants to search for a multi-word last name only - without a first name, then they must put a comma at the end 
of the string.  This is so that the algorithm can distinguish between that case and the situation where a first and last name are
separated by a space.

Example:

<TestHarness>
  <Test Name="FirstNameLastName" IsDefault="true" Description="Returns the search name split out for the format 'FirstName LastName'.">
    <SQLScript>
      <![CDATA[
exec sf.pSearchName#SplitDS
		 @SearchName	= 'Tim Edlund'
      ]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="RowCount" ResultSet="1" Value="1"/>
			<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="1" Value="Edlund%"/>
			<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="2" Value="Tim%"/>
      <Assertion Type="ExecutionTime" Value="00:00:01" />
    </Assertions>
  </Test>
  <Test Name="LastNameFirstName" Description="Returns the search name split out for the format 'LastName, FirstName'.">
    <SQLScript>
      <![CDATA[
exec sf.pSearchName#SplitDS
		 @SearchName	= '  Edlund, Tim   '
      ]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="RowCount" ResultSet="1" Value="1"/>
			<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="1" Value="Edlund%"/>
			<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="2" Value="Tim%"/>
      <Assertion Type="ExecutionTime" Value="00:00:01" />
    </Assertions>
  </Test>
  <Test Name="LastNameFirstNameMiddleName" Description="Returns the search name split out for the format 'LastName, FirstName MiddleName'.">
    <SQLScript>
      <![CDATA[
exec sf.pSearchName#SplitDS
		 @SearchName	= 'Edlund, Tim E'
      ]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="RowCount" ResultSet="1" Value="1"/>
			<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="1" Value="Edlund%"/>
			<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="2" Value="Tim%"/>
			<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="3" Value="E%"/>
      <Assertion Type="ExecutionTime" Value="00:00:01" />
    </Assertions>
  </Test>
  <Test Name="FirstNameMiddleNameLastName" Description="Returns the search name split out for the format 'FirstName MiddleName LastName'.">
    <SQLScript>
      <![CDATA[
exec sf.pSearchName#SplitDS
		 @SearchName	= 'Tim E Edlund'
      ]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="RowCount" ResultSet="1" Value="1"/>
			<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="1" Value="Edlund%"/>
			<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="2" Value="Tim%"/>
			<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="3" Value="E%"/>
      <Assertion Type="ExecutionTime" Value="00:00:01" />
    </Assertions>
  </Test>
  <Test Name="LastName" Description="Returns the search name split out for the format 'LastName'.">
    <SQLScript>
      <![CDATA[
exec sf.pSearchName#SplitDS
		 @SearchName	= 'Edlund'
      ]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="RowCount" ResultSet="1" Value="1"/>
			<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="1" Value="Edlund%"/>
      <Assertion Type="ExecutionTime" Value="00:00:01" />
    </Assertions>
  </Test>
  <Test Name="ThreeWordLastName" Description="Returns the search name split out for the format 'ThreeWordLastName'.">
    <SQLScript>
      <![CDATA[
exec sf.pSearchName#SplitDS
		 @SearchName	= ' Van Der Hoff   ,    '
      ]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="RowCount" ResultSet="1" Value="1"/>
			<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="1" Value="Van Der Hoff%"/>
      <Assertion Type="ExecutionTime" Value="00:00:01" />
    </Assertions>
  </Test>
  <Test Name="TwoWordLastNameFirstName" Description="Returns the search name split out for the format 'TwoWordLastName, FirstName'.">
    <SQLScript>
      <![CDATA[
exec sf.pSearchName#SplitDS
		 @SearchName	= 'Van Man, Tim'
      ]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="RowCount" ResultSet="1" Value="1"/>
			<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="1" Value="Van Man%"/>
			<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="2" Value="Tim%"/>
      <Assertion Type="ExecutionTime" Value="00:00:01" />
    </Assertions>
  </Test>
  <Test Name="ThreeWordLastNameFirstNameMiddleName" Description="Returns the search name split out for the format 'ThreeWordLastName, FirstName MiddleName'.">
    <SQLScript>
      <![CDATA[
exec sf.pSearchName#SplitDS
		 @SearchName	= 'Van Der Hoff, Tim E'
      ]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="RowCount" ResultSet="1" Value="1"/>
			<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="1" Value="Van Der Hoff%"/>
			<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="2" Value="Tim%"/>
			<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="3" Value="E%"/>
      <Assertion Type="ExecutionTime" Value="00:00:01" />
    </Assertions>
  </Test>
</TestHarness>


exec sf.pUnitTest#Execute
	@ObjectName = 'sf.pSearchName#SplitDS'
------------------------------------------------------------------------------------------------------------------------------- */

set nocount on
																																																																			
begin	

	declare
		 @errorNo                           int             = 0               -- 0 no error, <50000 SQL error, else business rule
		,@errorText                         nvarchar(4000)                    -- message text (for business rule errors)

	begin try

		select
			 sn.LastName					LastName
			,sn.FirstName					FirstName
			,sn.MiddleNames				MiddleNames
		from
			sf.fSearchName#Split(@SearchName) sn

	end try

	begin catch
		exec @errorNo = sf.pErrorRethrow																		  -- catch the error, rollback if pending, and re-throw
	end catch

	return(@errorNo)

end
GO
