SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vRegistrationProfile#CIHI]
/*********************************************************************************************************************************
View		: Registration Profile - CIHI (Canadian Institute for Health Informatics)
Notice  : Copyright © 2018 Softworks Group Inc.
Summary	: Returns column values required for exporting to CIHI
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Jul 2018		|	Initial version

Comments	
--------
This view extracts columns required for creating exports to CIHI.  The view obtains the columns from the snapshot 
(dbo.vRegistrationSnapshot) and profile (dbo.vRegistrationProfile) entities views.  The content of the columns is not modified
but the column names are changed to include a prefix identifying the field number they should appear in, in the resulting
export file.  Note that export files themselves are unique to each profession and therefore a specific sf.ExportJob with 
unique SELECT statement within it is still required for each College type.

Maintenance Note:  
-----------------
Avoid making changes to column contents here.  Adjust the entity view or the SELECT statement in the specific sf.ExportJob
for the College/Regulator type.

Example:
-------
!<TestHarness>
	<Test Name = "Select100" Description="Select a sample set of records from the function.">
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
		dbo.vRegistrationProfile#CIHI x
	where
		x.RegistrationsnapshotSID = @registrationSnapshotSID
	order by
		x.registrationprofilesid;

end;
		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>'
			<Assertion Type="ExecutionTime" Value="00:00:30" />
		</Assertions>
	</Test>
!</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.vRegistrationProfile#CIHI'
------------------------------------------------------------------------------------------------------------------------------- */
as
select
	rp.RegistrationSnapshotSID
 ,rp.RegistrationProfileSID
 ,rp.RegistrantPersonSID PersonSID
 ,(case when rs.ModifiedCount = rs.ProfileCount then '1' else '2' end) F01SubmissionType
 ,isnull(sf.fConfigParam#Value('CIHIOccupationID'), 'ERROR')					 F02OccupationID
 ,ltrim(rp.IsActivePractice)																					 F03PracticeStatus
 ,rs.RegistrationYear																									 F04RegistrationYear
 ,rp.JursidictionStateProvinceISONumber																 F05JurisdictionLocation
 ,rp.RegistrantNo																											 F06RegistrantNo
 ,rp.CIHIGenderCD																											 F07GenderCD
 ,rp.CIHIBirthYear																										 F08BirthYear
 ,rp.CIHIEducation1CredentialCode																			 F09Education1CredentialCode
 ,rp.CIHIEducation1GraduationYear																			 F10Education1GraduationYear
 ,rp.CIHIEducation1Location																						 F11Education1Location
 ,'9'																																	 F12Filler
 ,rp.CIHIEducation2CredentialCode																			 F13Education2CredentialCode
 ,rp.CIHIEducation3CredentialCode																			 F14Education3CredentialCode
 ,rp.CIHIEmploymentStatusCode																					 F15EmploymentStatusCode
 ,rp.CIHIEmployment1TypeCode																					 F16Employment1TypeCode
 ,rp.CIHIMultipleEmploymentStatus																			 F17MultipleEmploymentStatus
 ,space(1)																														 F18Filler
 ,rp.CIHIEmployment1Location																					 F19Employment1Location
 ,rp.CIHIEmployment1OrgTypeCode																				 F20Employment1OrgTypeCode
 ,rp.CIHIEmployment1PracticeAreaCode																	 F21Employment1PracticeAreaCode
 ,rp.CIHIEmployment1RoleCode																					 F22Employment1RoleCode
 ,rp.CIHIResidenceLocation																						 F23ResidenceLocation
 ,rp.CIHIResidencePostalCode																					 F24ResidencePostalCode
 ,rp.CIHIEmployment1PostalCode																				 F25Employment1PostalCode
 ,rp.CIHIRegistrationYearMonth																				 F26RegistrationYearMonth
 ,rp.CIHIEmployment2OrgTypeCode																				 F27Employment2OrgTypeCode
 ,rp.CIHIEmployment3OrgTypeCode																				 F28Employment3OrgTypeCode
 ,rp.CIHIEmployment2PracticeAreaCode																	 F29Employment2PracticeAreaCode
 ,rp.CIHIEmployment3PracticeAreaCode																	 F30Employment3PracticeAreaCode
 ,rp.CIHIEmployment2RoleCode																					 F31Employment2RoleCode
 ,rp.CIHIEmployment3RoleCode																					 F32Employment3RoleCode
 ,rp.CIHIEmployment2PostalCode																				 F33Employment2PostalCode
 ,rp.CIHIEmployment2Location																					 F33Employment2Location
 ,rp.CIHIEmployment3PostalCode																				 F34Employment3PostalCode
 ,rp.CIHIEmployment3Location																					 F34Employment3Location
 ,rp.PracticeHours																										 F06PracticeHours
from
	dbo.vRegistrationProfile	rp
join
	dbo.vRegistrationSnapshot rs on rp.RegistrationSnapshotSID = rs.RegistrationSnapshotSID and rs.RegistrationSnapshotTypeSCD = 'CIHI';
GO
EXEC sp_addextendedproperty N'MS_Description', N'Returns fields required for creating exports to CIHI. No contents are available until a Registration Snapshot has been created. Field names include a prefix identifying the CIHI field number they should appear in when exported to CIHI. |EXPORT+ ^RegistrationSnapshotList ^PersonList', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrationProfile#CIHI', NULL, NULL
GO
