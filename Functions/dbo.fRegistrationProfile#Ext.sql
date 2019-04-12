SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fRegistrationProfile#Ext
(
	@RegistrationProfileSID int -- key of record to look up values for
)
returns table
/*********************************************************************************************************************************
TableF		: Registration Profile Extended Columns
Notice		: Copyright © 2018 Softworks Group Inc.
Summary		: Returns a table of calculated columns for the Registration Profile extended view (vRegistrationProfile#Ext)
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + -----------------------------------------------------------------------------------
 				: Tim Edlund          | Jul 2018		|	Initial version
Comments	
--------
This function is called by the dbo.vRegistrationProfile#Ext view to return a series of calculated values. By using a table function,
many lookups required for the calculated values can be executed once rather than many times if separate functions are used.

This function expects to be selected for a single primary key value.  The function is not designed for inclusion in SELECTs 
scanning large portions of the table.  Performance in that context may not be acceptable and to resolve that, selected components 
of logic may need to be isolated into smaller functions that can be called separately.

This function encapsulates the logic for defaulting CIHI reporting codes and also calculates the current checksum on the record
which is used to determine if the record has been modified since last exported.  Note that IsModified is also ON if the record
has never been exported.

Example
-------
<TestHarness>
	<Test Name = "Simple" Description="Returns the extended columns for an instance of the entity at random.">
	<SQLScript>
	<![CDATA[

	select 
		 y.RegistrationProfileSID
		,x.*
	from
	(select top 10
		*
	from
		dbo.RegistrationProfile x
	order by
		newid()
	) y
	cross apply
		dbo.fRegistrationProfile#Ext(y.RegistrationProfileSID) x

	]]>
	</SQLScript>
	<Assertions>
		<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
		<Assertion Type="ExecutionTime" Value="00:00:02" />
	</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.fRegistrationProfile#Ext'
------------------------------------------------------------------------------------------------------------------------------- */
as
return select
					cast(case when rp.IsInvalid = cast(1 as bit) then 0 else 1 end as bit)																								 IsValid													--# Indicates if the profile record has passed all validations
				,(case rp.GenderSCD when 'M' then '1' when 'F' then '2' else '9' end)																										 CIHIGenderCD											--#CIHI gender code 
				,isnull(year(rp.BirthDate), 9999)																																												 CIHIBirthYear										--#CIHI year of birth (maps to Export Field #8)
				,isnull(rp.Education1CredentialCode, '9')																																								 CIHIEducation1CredentialCode			--#CIHI qualifing credential level (maps to Export Field #9)
				,isnull(rp.Education1GraduationYear, 9999)																																							 CIHIEducation1GraduationYear			--#CIHI qualifying credential graduation year (maps to Export Field #10)
				,(case
						when rp.Education1IsDefaultCountry = 1 then rp.Education1StateProvinceISONumber
						else rp.Education1CountryISONumber
					end
				 )																																																											 CIHIEducation1Location						--#CIHI qualifying credential organization location code (maps to Export Field #11)
				,(case when rp.Education2RegistrantCredentialSID is not null then isnull(rp.Education2CredentialCode, '9') else '5' end) CIHIEducation2CredentialCode			--#CIHI related credential level (maps to Export Field #13)
				,(case when rp.Education3RegistrantCredentialSID is not null then isnull(rp.Education3CredentialCode, '9') else '5' end) CIHIEducation3CredentialCode			--#CIHI non-related credential level (maps to Export Field #14)
				,isnull(rp.EmploymentStatusCode, '99')																																									 CIHIEmploymentStatusCode					--#CIHI employment status code (maps to Export Field #15)
				,isnull(rp.Employment1TypeCode, '9')																																										 CIHIEmployment1TypeCode					--#CIHI employment type for primary employment: full-time, part-time, etc. (maps to Export Field #16)
				,(case when rp.EmploymentCount > 1 then '1' else '0' end)																																 CIHIMultipleEmploymentStatus			--#CIHI multiple employment status (maps to Export Field #17)
				,(case
						when rp.Employment1IsDefaultCountry = 1 then rp.Employment1StateProvinceISONumber
						else isnull(rp.Employment1CountryISONumber, 999)
					end
				 )																																																											 CIHIEmployment1Location					--#CIHI primary employer location code (maps to Export Field #19)
				,isnull(rp.Employment1OrgTypeCode, '99')																																								 CIHIEmployment1OrgTypeCode				--#CIHI primary employer type (maps to Export Field #20)
				,isnull(rp.Employment1PracticeAreaCode, '99')																																						 CIHIEmployment1PracticeAreaCode  --#CIHI secondary employment practice scope (maps to Export Field #21)
				,isnull(rp.Employment1PracticeScopeCode, '99')																																					 CIHIEmployment1PracticeScopeCode --#CIHI primary employment practice scope (maps to Export Field #??)
				,isnull(rp.Employment1RoleCode, '99')																																										 CIHIEmployment1RoleCode					--#CIHI primary employment position code (maps to Export Field #22)
				,(case
						when rp.ResidenceIsDefaultCountry = 1 then rp.ResidenceStateProvinceISONumber
						else isnull(rp.ResidenceCountryISONumber, 999)
					end
				 )																																																											 CIHIResidenceLocation						--#CIHI residence location code (maps to Export Field #23)
				,(case when rp.ResidenceIsDefaultCountry = 1 then replace(rp.ResidencePostalCode, ' ', '') else null end)								 CIHIResidencePostalCode					--#CIHI residence postal code (maps to Export Field #24)
				,(case when rp.Employment1IsDefaultCountry = 1 then replace(rp.Employment1PostalCode, ' ', '') else null end)						 CIHIEmployment1PostalCode				--#CIHI postal code of primary work site (maps to Export Field #25)
				,(case when rp.Employment2IsDefaultCountry = 1 then replace(rp.Employment2PostalCode, ' ', '') else null end)						 CIHIEmployment2PostalCode				--#CIHI postal code of secondary work site (maps to Export Field #33)
				,(case when rp.Employment3IsDefaultCountry = 1 then replace(rp.Employment3PostalCode, ' ', '') else null end)						 CIHIEmployment3PostalCode				--#CIHI postal code of tertiary work site (maps to Export Field #34)
				,convert(char(6), reg.EffectiveTime, 112)																																								 CIHIRegistrationYearMonth				--#CIHI year and month registration became effective (maps to Export Field #26)
				,(case
						when rp.Employment2IsDefaultCountry = 1 then rp.Employment2StateProvinceISONumber
						else isnull(rp.Employment2CountryISONumber, 999)
					end
				 )																																																											 CIHIEmployment2Location					--#CIHI secondary employer location code (maps to Export Field #33)
				,isnull(rp.Employment2OrgTypeCode, '99')																																								 CIHIEmployment2OrgTypeCode				--#CIHI secondary employer type (maps to Export Field #27)
				,isnull(rp.Employment2PracticeAreaCode, '99')																																						 CIHIEmployment2PracticeAreaCode  --#CIHI secondary employment practice scope (maps to Export Field #29)
				,isnull(rp.Employment2PracticeScopeCode, '99')																																					 CIHIEmployment2PracticeScopeCode --#CIHI secondary employment practice scope (maps to Export Field #??)
				,isnull(rp.Employment2RoleCode, '99')																																										 CIHIEmployment2RoleCode					--#CIHI secondary employment position code (maps to Export Field #31)
				,(case
						when rp.Employment3IsDefaultCountry = 1 then rp.Employment3StateProvinceISONumber
						else isnull(rp.Employment3CountryISONumber, 999)
					end
				 )																																																											 CIHIEmployment3Location					--#CIHI tertiary employer location code (maps to Export Field #34)
				,isnull(rp.Employment3OrgTypeCode, '99')																																								 CIHIEmployment3OrgTypeCode				--#CIHI tertiary employer type (maps to Export Field #28)
				,isnull(rp.Employment3PracticeAreaCode, '99')																																						 CIHIEmployment3PracticeAreaCode  --#CIHI secondary employment practice scope (maps to Export Field #30)
				,isnull(rp.Employment3PracticeScopeCode, '99')																																					 CIHIEmployment3PracticeScopeCode --#CIHI tertiary employment practice scope (maps to Export Field #??)
				,isnull(rp.Employment3RoleCode, '99')																																										 CIHIEmployment3RoleCode					--#CIHI tertiary employment position code (maps to Export Field #32)
				,checksum(
									 rp.RegistrationSnapshotSID
									,rp.JursidictionStateProvinceISONumber
									,rp.RegistrantSID
									,rp.RegistrantNo
									,rp.GenderSCD
									,rp.BirthDate
									,rp.PersonMailingAddressSID
									,rp.ResidenceStateProvinceISONumber
									,rp.ResidencePostalCode
									,rp.ResidenceCountryISONumber
									,rp.ResidenceIsDefaultCountry
									,rp.RegistrationSID
									,rp.IsActivePractice
									,rp.Education1RegistrantCredentialSID
									,rp.Education1CredentialCode
									,rp.Education1GraduationYear
									,rp.Education1StateProvinceISONumber
									,rp.Education1CountryISONumber
									,rp.Education1IsDefaultCountry
									,rp.Education2RegistrantCredentialSID
									,rp.Education2CredentialCode
									,rp.Education2GraduationYear
									,rp.Education2StateProvinceISONumber
									,rp.Education2CountryISONumber
									,rp.Education2IsDefaultCountry
									,rp.Education3RegistrantCredentialSID
									,rp.Education3CredentialCode
									,rp.Education3GraduationYear
									,rp.Education3StateProvinceISONumber
									,rp.Education3CountryISONumber
									,rp.Education3IsDefaultCountry
									,rp.RegistrantPracticeSID
									,rp.EmploymentStatusCode
									,rp.EmploymentCount
									,rp.PracticeHours
									,rp.Employment1RegistrantEmploymentSID
									,rp.Employment1TypeCode
									,rp.Employment1StateProvinceISONumber
									,rp.Employment1CountryISONumber
									,rp.Employment1IsDefaultCountry
									,rp.Employment1PostalCode
									,rp.Employment1OrgTypeCode
									,rp.Employment1PracticeScopeCode
									,rp.Employment1RoleCode
									,rp.Employment2RegistrantEmploymentSID
									,rp.Employment2TypeCode
									,rp.Employment2StateProvinceISONumber
									,rp.Employment2IsDefaultCountry
									,rp.Employment2CountryISONumber
									,rp.Employment2PostalCode
									,rp.Employment2OrgTypeCode
									,rp.Employment2PracticeScopeCode
									,rp.Employment2RoleCode
									,rp.Employment3RegistrantEmploymentSID
									,rp.Employment3TypeCode
									,rp.Employment3StateProvinceISONumber
									,rp.Employment3CountryISONumber
									,rp.Employment3IsDefaultCountry
									,rp.Employment3PostalCode
									,rp.Employment3OrgTypeCode
									,rp.Employment3PracticeScopeCode
									,rp.Employment3RoleCode
								 )																																																							 CurrentCheckSum
				,cast(case
								when rp.CheckSumOnLastExport is null
										 or rp.CheckSumOnLastExport <> checksum(
																														 rp.RegistrationSnapshotSID
																														,rp.JursidictionStateProvinceISONumber
																														,rp.RegistrantSID
																														,rp.RegistrantNo
																														,rp.GenderSCD
																														,rp.BirthDate
																														,rp.PersonMailingAddressSID
																														,rp.ResidenceStateProvinceISONumber
																														,rp.ResidencePostalCode
																														,rp.ResidenceCountryISONumber
																														,rp.ResidenceIsDefaultCountry
																														,rp.RegistrationSID
																														,rp.IsActivePractice
																														,rp.Education1RegistrantCredentialSID
																														,rp.Education1CredentialCode
																														,rp.Education1GraduationYear
																														,rp.Education1StateProvinceISONumber
																														,rp.Education1CountryISONumber
																														,rp.Education1IsDefaultCountry
																														,rp.Education2RegistrantCredentialSID
																														,rp.Education2CredentialCode
																														,rp.Education2GraduationYear
																														,rp.Education2StateProvinceISONumber
																														,rp.Education2CountryISONumber
																														,rp.Education2IsDefaultCountry
																														,rp.Education3RegistrantCredentialSID
																														,rp.Education3CredentialCode
																														,rp.Education3GraduationYear
																														,rp.Education3StateProvinceISONumber
																														,rp.Education3CountryISONumber
																														,rp.Education3IsDefaultCountry
																														,rp.RegistrantPracticeSID
																														,rp.EmploymentStatusCode
																														,rp.EmploymentCount
																														,rp.PracticeHours
																														,rp.Employment1RegistrantEmploymentSID
																														,rp.Employment1TypeCode
																														,rp.Employment1StateProvinceISONumber
																														,rp.Employment1CountryISONumber
																														,rp.Employment1IsDefaultCountry
																														,rp.Employment1PostalCode
																														,rp.Employment1OrgTypeCode
																														,rp.Employment1PracticeScopeCode
																														,rp.Employment1RoleCode
																														,rp.Employment2RegistrantEmploymentSID
																														,rp.Employment2TypeCode
																														,rp.Employment2StateProvinceISONumber
																														,rp.Employment2IsDefaultCountry
																														,rp.Employment2CountryISONumber
																														,rp.Employment2PostalCode
																														,rp.Employment2OrgTypeCode
																														,rp.Employment2PracticeScopeCode
																														,rp.Employment2RoleCode
																														,rp.Employment3RegistrantEmploymentSID
																														,rp.Employment3TypeCode
																														,rp.Employment3StateProvinceISONumber
																														,rp.Employment3CountryISONumber
																														,rp.Employment3IsDefaultCountry
																														,rp.Employment3PostalCode
																														,rp.Employment3OrgTypeCode
																														,rp.Employment3PracticeScopeCode
																														,rp.Employment3RoleCode
																													 ) then 1
								else 0
							end as bit)																																																				 IsModified												-- Indicates if the record has not been exported or has been modified since the last export
			 from
					dbo.RegistrationProfile rp
			 join
				 dbo.Registration					reg on rp.RegistrationSID = reg.RegistrationSID
			 where
				 rp.RegistrationProfileSID = @RegistrationProfileSID;
GO
