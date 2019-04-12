SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.vRegistration#Future
/*********************************************************************************************************************************
View		: Registration - Future
Notice  : Copyright © 2019 Softworks Group Inc.
Summary	: Returns all future dated registration records 
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Apr 2019		|	Initial version

Comments	
--------
This view retrieves (dbo) Registration records that are dated in the future.  The view is applied in scenarios where the future
registration must be viewed along side the current registration - for example during the Renewal period. Note that business
rules prevent multiple future registrations from being created for the same registrant and therefore no check is needed for
unique selection by registrant identifier as of this writing. 

<TestHarness>
	<Test Name = "Random" Description="Returns contents of the view (all records).">
	<SQLScript>
	<![CDATA[

select x.* from	dbo.vRegistration#Future x

if @@rowcount = 0 
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
	]]>
	</SQLScript>
	<Assertions>
		<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
		<Assertion Type="ExecutionTime" Value="00:01:00" />
	</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.vRegistration#Future'
	,@DefaultTestOnly = 1	
------------------------------------------------------------------------------------------------------------------------------- */
as
select
	reg.RegistrationSID
 ,reg.RegistrantSID
 ,reg.RegistrationYear
 ,reg.PracticeRegisterSectionSID
 ,prs.PracticeRegisterSectionLabel
 ,pr.PracticeRegisterSID
 ,pr.PracticeRegisterLabel
 ,reg.CardPrintedTime
 ,reg.InvoiceSID
 ,reg.ReasonSID
 ,reg.FormGUID
 ,prs.IsDisplayedOnLicense
 ,prs.IsDefault
 ,reg.EffectiveTime
 ,reg.ExpiryTime
from
	dbo.Registration						reg
join
(select sf.fNow() NowCTZ)				x on 1																= 1
join
	dbo.PracticeRegisterSection prs on reg.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
join
	dbo.PracticeRegister				pr on prs.PracticeRegisterSID					= pr.PracticeRegisterSID
where
	reg.EffectiveTime >= x.NowCTZ;
GO
