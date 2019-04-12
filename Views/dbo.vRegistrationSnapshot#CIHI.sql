SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vRegistrationSnapshot#CIHI]
/*********************************************************************************************************************************
View		: Registration Snapshot - CIHI (Canadian Institute for Health Informatics)
Notice  : Copyright © 2018 Softworks Group Inc.
Summary	: Returns column values required for exporting to CIHI (control record content)
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Jul 2018		|	Initial version

Comments	
--------
This view extracts columns required for creating the control record (header) required for CIHI exports.  The values for
the body of the export are provided by dbo.vRegistrationProfile#CIHI.  A single row is returned.

Example:
-------
!<TestHarness>
	<Test Name = "Select1" Description="Select from view for a snapshot selected at random.">
		<SQLScript>
		<![CDATA[
declare @registrationSnapshotSID int;

select top (1)
	@registrationSnapshotSID = rs.RegistrationSnapshotSID
from
	dbo.vRegistrationSnapshot rs
where
	rs.RegistrationSnapshotTypeSCD = 'CIHI' and rs.ProfileCount > 0
order by
	newid();

if @registrationSnapshotSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	select 
		x.*
	from
		dbo.vRegistrationSnapshot#CIHI x
	where
		x.RegistrationsnapshotSID = @registrationSnapshotSID

end;
		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>'
			<Assertion Type="ExecutionTime" Value="00:00:03" />
		</Assertions>
	</Test>
!</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.vRegistrationSnapshot#CIHI'
------------------------------------------------------------------------------------------------------------------------------- */
as
select
	rs.RegistrationSnapshotSID
 ,isnull(sf.fConfigParam#Value('CIHIOccupationID'), 'ERROR') OccupationID
 ,sp.ISONumber																							 JurisdictionLocation
 ,rs.RegistrationYear
 ,rs.ProfileCount
 ,format(sf.fToday(), 'yyyyMMdd')														 SubmissionDate
from
	dbo.vRegistrationSnapshot rs
left outer join
	dbo.Country								c on c.IsDefault = cast(1 as bit)
left outer join
	dbo.StateProvince					sp on c.CountrySID = sp.CountrySID and sp.IsDefault = cast(1 as bit)
GO
