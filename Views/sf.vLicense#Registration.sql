SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vLicense#Registration]
-- with encryption
as
/*********************************************************************************************************************************
View    : License Registration
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: returns information about who the license is registered to
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund  | April 2010    |	Initial Version
				: Adam Panter	| May 2014			| Added test harness
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------

***** WARNING: TAMPERING WITH THIS VIEW WILL BLOCK ACCESS TO THE APPLICATION FOR ALL USERS *****

This view is used in branding UI elements, reports and other components of the user interface.  The view also supports information 
display in the "About" feature in the software.  The view parses the XML in the license record to obtain the registration values. 

The contents of this view is used in hashing algorithms related to the license key file. 

Testing
-------
Two tests are included, which ensure that exactly one record is returned when retrieving license registration 
records from the database. We should never have more than one license key per database, and its contents should never
be empty.

<TestHarness>
<Test Name = "DetailSelect" Description="Select all records in the License Registration view and ensures that exactly one record (not 0, not more than 1) is returned.">
<SQLScript>
<![CDATA[
			select 
				 lr.Registration
				,LicenseKey
				,ProductName
			from
				sf.vLicense#Registration lr
	
]]>
</SQLScript>
<Assertions>
  <Assertion Type="RowCount" RowSet="1" Value="1" ResultSet="1"/>
  <Assertion Type="ExecutionTime" Value="00:00:01" />
</Assertions>
</Test>

<Test Name = "LicenseKeyNotEmpty" Description="Ensures that the single License key stored in the database contains a Registration, LicenseKey, and Product Name.">
<SQLScript>
<![CDATA[
			 
			select 
				 lr.Registration
				,LicenseKey
				,ProductName
			from
				sf.vLicense#Registration lr
			where
				LicenseKey is not null
			and
				Registration is not null 
			and
				ProductName is not null 
]]>
</SQLScript>
<Assertions>
  <Assertion Type="RowCount" RowSet="1" Value="1" ResultSet="1"/>
  <Assertion Type="ExecutionTime" Value="00:00:01" />
</Assertions>
</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.vLicense#Registration'
------------------------------------------------------------------------------------------------------------------------------- */
select  
	 x.License.value('@Registration[1]', 'nvarchar(75)')		Registration
	,x.License.value('@LicenseKey[1]', 'char(40)')					LicenseKey
	,x.License.value('@ProductName[1]', 'nvarchar(75)')			ProductName
from 
	sf.License l
cross apply
	l.License.nodes('License') x(License)
GO
