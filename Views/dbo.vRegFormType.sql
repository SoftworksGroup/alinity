SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.vRegFormType
/*********************************************************************************************************************************
View			: Registration Form Type
Notice		: Copyright © 2018 Softworks Group Inc.
Summary		: Returns a list of registration form types and codes
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Sep 2018		|	Initial version

Comments	
--------
This view returns a list of registration form type records.  The view is hard-coded and conforms to the codes returned by the
dbo.fRegistration#FormStatus function.  The view is designed to support parameter value setting on queries created for the
Registration List page.

The "All" choice is used to indicate no particular form type is to be selected by the query.  The "SID" values returned
are depended on by the query logic in dbo.pQuery#Execute$Registration and must not be modified.

Maintenance Note
----------------
Ensure the codes returned by this view are consistent with codes returned by dbo.fRegistration#FormStatus.

Example
-------
<TestHarness>
	<Test Name="One" Description="Returns view content">
		<SQLScript>
			<![CDATA[

select x.* from dbo .vRegFormType x order by x.RegFormTypeSID;

if @@ROWCOUNT = 0 raiserror( N'* ERROR: no sample data found to run test', 18, 1)

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1" />
			<Assertion Type="ExecutionTime" Value="00:00:02"/>
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
  @ObjectName = 'dbo.vRegFormType'
 ,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */

as
select 100 RegFormTypeSID , 'All' RegFormTypeLabel, 'ALL' RegFormTypeCode
union
select 101 RegFormTypeSID , 'Renewal' RegFormTypeLabel, 'RENEWAL' RegFormTypeCode
union
select
	102							RegFormTypeSID
 ,'Reinstatement' RegFormTypeLabel
 ,'REINSTATEMENT' RegFormTypeCode
union
select
	103										RegFormTypeSID
 ,'Registration change' RegFormTypeLabel
 ,'REGCHANGE'						RegFormTypeCode
union
select
	104						RegFormTypeSID
 ,'Application' RegFormTypeLabel
 ,'APPLICATION' RegFormTypeCode;

GO
