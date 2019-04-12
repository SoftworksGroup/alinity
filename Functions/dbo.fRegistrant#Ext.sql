SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fRegistrant#Ext]
(
@RegistrantSID int -- key of record to look up values for
)
returns @Registrant#Ext table
(
	PersonSID												 int								-- key of sf.Person record of registrant (1 to 1)
 ,EmailAddress										 varchar(150)				-- email address of registrant
 ,RegistrationSID									 int								-- key of registrant's current registration (see notes)
 ,RegistrationNo									 nvarchar(50)				-- the number of the top-ranked registration
 ,PracticeRegisterSID							 int								-- key of the practice register the registration is under
 ,PracticeRegisterSectionSID			 int								-- key of the section of register the registration is under
 ,EffectiveTime										 datetime						-- date and time registration became/becomes effective
 ,ExpiryTime											 datetime						-- date and time the registration expires/expired
 ,PracticeRegisterName						 nvarchar(65)				-- name of the practice register registration is under
 ,PracticeRegisterLabel						 nvarchar(35)				-- label of the practice register registration is under	
 ,IsActivePractice								 bit								-- indicates whether type of registration is active practice
 ,PracticeRegisterSectionLabel		 nvarchar(35)				-- label of the section of register the registration is under		
 ,IsSectionDisplayedOnLicense			 bit								-- indicates whether the section is displayed on registration
 ,LicenseRegistrationYear					 smallint						-- registration year the registration is/was in effect
 ,RenewalRegistrationYear					 smallint						-- registration year the next renewal is available for (null if not available)
 ,RenewalStatusSCD								 varchar(25)				-- status of top ranked registration's renewal - if any
 ,RenewalStatusLabel							 nvarchar(35)				-- status label of the top ranked registration's renewal
 ,RenewalUpdateTime								 datetimeoffset(7)	-- date and time renewal of the registration was last updated 
 ,RenewalIsEditEnabled						 bit								-- whether edit is enabled on the renewal form associated with registration
 ,RenewalIsDeleteEnabled					 bit								-- whether delete is enabled on renewal form associated with registration
 ,RenewalIsUnPaid									 bit								-- whether invoice associated with the registrations renewal is unpaid
 ,RenewalTotalDue									 decimal(11, 2)			-- amount due on invoice associated with the registration - if any
 ,RenewalIsRegisterChange					 bit								-- whether the current renewal reflected a register change
 ,IsCurrentUserVerifier						 bit								-- whether the currently logged in user is a verifier (has early access to renewal)
 ,RegistrationLabel								 nvarchar(80)				-- a label to use to display the registration (to administrators)
 ,RegistrationPublicDirectoryLabel nvarchar(75)				-- a label to use to display the registration (on public directories)
 ,IsRenewalEnabled								 bit								-- whether renewal is enabled for this registration
 ,IsReinstatementEnabled					 bit								-- whether reinstatement is enabled for this registration
)
as
/*********************************************************************************************************************************
TableF		: Registration Extended Columns
Notice		: Copyright © 2017 Softworks Group Inc.
Summary		: Returns a table of calculated columns for the Registration extended view (vRegistrant#Ext)
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-------------------------------------------------------------------------------------------
					: Tim Edlund  | May 2017		|	Initial version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------

This function is called by the dbo.vRegistrant#Ext view to return a series of calculated values. By using a table function,
many lookups required for the calculated values can be executed once rather than many times if separate functions are used.

This function expects to be selected for a single primary key value.  The function is not designed for inclusion in SELECTs 
scanning large portions of the table.  Performance in that context may not be acceptable and to resolve that, selected components 
of logic may need to be isolated into smaller functions that can be called separately.

In addition to returning some values related to the registrant, the function also returns information for one registration for the
registrant. While most implementations allow only a single active registration,  Alinity supports multiple concurrent active registrations. 
If a registrant has more than one, only a single registration is returned by this function. The function calls #LatestRegistration which
returns an active registration if one exists.  If there are multiple active registrations, then the one with the highest rank (as set
in RegisterRank in Practice Register) is returned.  If not active registration exists for the registrant, then the latest registration
that was active is returned.

Note that if a registrant has a current registration, it is always returned even if a renewed registration for a later period exists.
In that sense, the registration returned is not "latest" but more accurately the "latest registration that was or is active".  If no
active registration exists, then the registration that was most recently active is returned.  A future dated or pending registration is
never returned by the function.

Example
-------

<TestHarness>
	<Test Name = "Simple" Description="Returns the extended columns for an instance of the entity at random.">
	<SQLScript>
	<![CDATA[

	select 
		rlx.*
	from
	(select top 10
		*
	from
		dbo.Registrant rl
	order by
		newid()
	) x
	cross apply
		dbo.fRegistrant#Ext(x.RegistrantSID) rlx

	]]>
	</SQLScript>
	<Assertions>
		<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
		<Assertion Type="ExecutionTime" Value="00:00:02" />
	</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.fRegistrant#Ext'
	
------------------------------------------------------------------------------------------------------------------------------- */
begin
	declare @ON bit = cast(1 as bit); -- constant to eliminate repetitive casting syntax

	insert
		@Registrant#Ext
	(
		PersonSID
	 ,EmailAddress
	 ,RegistrationSID
	 ,RegistrationNo
	 ,PracticeRegisterSID
	 ,PracticeRegisterSectionSID
	 ,EffectiveTime
	 ,ExpiryTime
	 ,PracticeRegisterName
	 ,PracticeRegisterLabel
	 ,IsActivePractice
	 ,PracticeRegisterSectionLabel
	 ,IsSectionDisplayedOnLicense
	 ,LicenseRegistrationYear
	 ,RenewalRegistrationYear
	 ,RenewalStatusSCD
	 ,RenewalStatusLabel
	 ,RenewalUpdateTime
	 ,RenewalIsEditEnabled
	 ,RenewalIsDeleteEnabled
	 ,RenewalIsUnPaid
	 ,RenewalTotalDue
	 ,RenewalIsRegisterChange
	 ,IsCurrentUserVerifier
	 ,RegistrationLabel
	 ,RegistrationPublicDirectoryLabel
	 ,IsRenewalEnabled
	 ,IsReinstatementEnabled
	)
	select
		p.PersonSID
	 ,pea.EmailAddress
	 ,rcl.RegistrationSID
	 ,rcl.RegistrationNo
	 ,rcl.PracticeRegisterSID
	 ,rcl.PracticeRegisterSectionSID
	 ,rcl.EffectiveTime
	 ,rcl.ExpiryTime
	 ,rcl.PracticeRegisterName
	 ,rcl.PracticeRegisterLabel
	 ,rcl.IsActivePractice
	 ,rcl.PracticeRegisterSectionLabel
	 ,rcl.IsSectionDisplayedOnLicense
	 ,rcl.LicenseRegistrationYear
	 ,rcl.RenewalRegistrationYear
	 ,rcl.RenewalStatusSCD
	 ,rcl.RenewalStatusLabel
	 ,rcl.RenewalUpdateTime
	 ,rcl.RenewalIsEditEnabled
	 ,rcl.RenewalIsDeleteEnabled
	 ,rcl.RenewalIsUnPaid
	 ,rcl.RenewalTotalDue
	 ,rcl.RenewalIsRegisterChange
	 ,rcl.IsCurrentUserVerifier
	 ,rcl.RegistrationLabel
	 ,dbo.fRegistration#PublicDirectoryLabel(rcl.RegistrationSID) RegistrationPublicDirectoryLabel
	 ,rcl.IsRenewalEnabled
	 ,rcl.IsReinstatementEnabled
	from
		dbo.Registrant																								 r
	join
		sf.Person																											 p on r.PersonSID = p.PersonSID
	left outer join
		sf.PersonEmailAddress																					 pea on p.PersonSID = pea.PersonSID and pea.IsActive = @ON and pea.IsPrimary = @ON
	outer apply dbo.fRegistrant#LatestRegistration2(r.RegistrantSID) rcl
	where
		r.RegistrantSID = @RegistrantSID;

	return;
end;
GO
