SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pPersonMailingAddress#GetHTMLDisplay]
	 @Name						nvarchar(140)																					--The Person's Display Name														
	,@StreetAddress1	nvarchar(75)		= null																--The Person's main street address
	,@StreetAddress2	nvarchar(75)		= null																--The Person's secondary street address (if applicable)
	,@StreetAddress3	nvarchar(75)		= null																--The Person's third street address (if applicable)
	,@CityName				nvarchar(30)		= null																--The Person's current city for the main street address.
	,@StateProvince		nvarchar(30)		= null																--The Person's current state or province for the main street address.
	,@PostalCode			varchar(10)			= null																--The Person's postal code/zip code for the main street address.
	,@CountryName			nvarchar(50)		= null																--The Person's county name for the main street address supplied.
AS
/*********************************************************************************************************************************
Procedure : PersonMailingAddress - Get HTML Display
Notice    : Copyright © 2010-2014 Softworks Group Inc.
Summary   : returns a formatted mailing address in HTML as a string, by calling fFormatForHTML function
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)   | Month Year   | Change Summary
				 : ------------|--------------|-------------------------------------------------------------------------------------------
				 : Tyson Schulz| Jul	2014    | Initial version
----------------------------------------------------------------------------------------------------------------------------------
Comments
--------

This procedure is primarily used to wrap the fFormatForHTML function in a executable state for Alinity.Web.Portal.

The values supplied to this procedure are all the parameters fFormatForHTML accepts. Each parameter can be passed as null, except 
the person's name

Example
-------

<TestHarness>
  <Test Name="GetFormattedHTML" IsDefault="true" Description="Returns combined parameters supplied as a string in HTML format.">
    <SQLScript>
      <![CDATA[
				exec dbo.pPersonMailingAddress#GetHTMLDisplay
					 @Name						= 'Tyson'
					,@StreetAddress1	= '742 Evergreen Terrace'
					,@StreetAddress2	=	null
					,@StreetAddress3	= null
					,@CityName				= 'Edmonton'
					,@StateProvince		= 'AB'
					,@PostalCode			= 'T5E 8U6'
					,@CountryName			= 'Canada'
      ]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="ExecutionTime" Value="00:00:01" />
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#execute
	@objectName = 'dbo.pPersonMailingAddress#GetHTMLDisplay'
	
-------------------------------------------------------------------------------------------------------------------------------- */
set nocount on

begin
		select 
		sf.fFormatAddressForHTML(
															@Name
															,@StreetAddress1
															,@StreetAddress2
															,@StreetAddress3
															,@CityName
															,@StateProvince
															,@PostalCode
															,@CountryName
														) HTMLFormattedAddress
		return(0)
end
GO
