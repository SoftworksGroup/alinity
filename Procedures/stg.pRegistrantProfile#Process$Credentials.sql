SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE stg.pRegistrantProfile#Process$Credentials
	@RegistrantProfileSID int													-- source record to extract Credential values from
 ,@RegistrantSID				int													-- registrant to assign credentials to
as
/*********************************************************************************************************************************
Procedure : Registrant Profile - Process Credentials
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Processing subroutine to extract and process registrant credential information from stg.RegistrantProfile
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Mar 2019		|	Initial version

Comments
--------
The stg.RegistrantProfile table supports collection of up to 10 credentials per registrant. One of the credentials is validated
as qualifying while the others may be non-qualifying credentials or specializations. The subroutine processes a single 
registrant profile record but may return a count of errors > 1 where multiple credential records have been populated in the
main record (@ErrorCount > 1).

This routine provides the logic for extraction of the credential values from the staging record but validation and insert of the
(dbo) Registrant Credential record is handled by the (dbo) pRegistrantCredential#Set procedure.

Limitations
-----------
This procedure is not designed to be called directly.  Call it through the parent procedure only.

Example
-------
See parent procedure.
-------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo										 int					 = 0										-- 0 no error, <50000 SQL error, else business rule
	 ,@ON													 bit					 = cast(1 as bit)				-- constant for bit comparisons = 1
	 ,@OFF												 bit					 = cast(0 as bit)				-- constant for bit comparison = 0
	 ,@columnNo										 int																	-- counter to track extractions from flattend records (Label1, Label2, etc)  		
	 ,@credentialLabel						 nvarchar(35)													-- buffer for extracted column values in repeating record sets
	 ,@isQualifying								 bit
	 ,@orgLabel										 nvarchar(150)
	 ,@programName								 nvarchar(65)
	 ,@programStartDate						 date
	 ,@programTargetCompletionDate date
	 ,@fieldOfStudyName						 nvarchar(50)
	 ,@effectiveTime							 datetime
	 ,@expiryTime									 datetime;

	begin try

		set @columnNo = -1;

		while @columnNo < 9
		begin

			set @columnNo += 1;

			-- extract parameter values for the #Set sproc
			-- from the base staging record columns

			select
				@credentialLabel						 = case @columnNo
																				 when 0 then rp.QualifyingCredentialLabel
																				 when 1 then rp.CredentialLabel1
																				 when 2 then rp.CredentialLabel2
																				 when 3 then rp.CredentialLabel3
																				 when 4 then rp.CredentialLabel4
																				 when 5 then rp.CredentialLabel5
																				 when 6 then rp.CredentialLabel6
																				 when 7 then rp.CredentialLabel7
																				 when 8 then rp.CredentialLabel8
																				 when 9 then rp.CredentialLabel9
																				 else cast('?' as nvarchar(5))
																			 end
			 ,@orgLabel										 = case @columnNo
																				 when 0 then rp.QualifyingCredentialOrgLabel
																				 when 1 then rp.CredentialOrgLabel1
																				 when 2 then rp.CredentialOrgLabel2
																				 when 3 then rp.CredentialOrgLabel3
																				 when 4 then rp.CredentialOrgLabel4
																				 when 5 then rp.CredentialOrgLabel5
																				 when 6 then rp.CredentialOrgLabel6
																				 when 7 then rp.CredentialOrgLabel7
																				 when 8 then rp.CredentialOrgLabel8
																				 when 9 then rp.CredentialOrgLabel9
																				 else cast('?' as nvarchar(5))
																			 end
			 ,@programName								 = case @columnNo
																				 when 0 then rp.QualifyingProgramName
																				 when 1 then rp.CredentialProgramName1
																				 when 2 then rp.CredentialProgramName2
																				 when 3 then rp.CredentialProgramName3
																				 when 4 then rp.CredentialProgramName4
																				 when 5 then rp.CredentialProgramName5
																				 when 6 then rp.CredentialProgramName6
																				 when 7 then rp.CredentialProgramName7
																				 when 8 then rp.CredentialProgramName8
																				 when 9 then rp.CredentialProgramName9
																				 else cast('?' as nvarchar(5))
																			 end
			 ,@programStartDate						 = case @columnNo -- program start dates apply to qualifying credential only
																				 when 0 then rp.QualifyingProgramStartDate
																				 else cast(null as date)
																			 end
			 ,@programTargetCompletionDate = case @columnNo -- program completion dates apply to qualifying credential only
																				 when 0 then rp.QualifyingProgramCompletionDate
																				 else cast(null as date)
																			 end
			 ,@fieldOfStudyName						 = case @columnNo
																				 when 0 then rp.QualifyingFieldOfStudyName
																				 when 1 then rp.CredentialFieldOfStudyName1
																				 when 2 then rp.CredentialFieldOfStudyName2
																				 when 3 then rp.CredentialFieldOfStudyName3
																				 when 4 then rp.CredentialFieldOfStudyName4
																				 when 5 then rp.CredentialFieldOfStudyName5
																				 when 6 then rp.CredentialFieldOfStudyName6
																				 when 7 then rp.CredentialFieldOfStudyName7
																				 when 8 then rp.CredentialFieldOfStudyName8
																				 when 9 then rp.CredentialFieldOfStudyName9
																				 else cast('?' as nvarchar(5))
																			 end
			 ,@effectiveTime							 = case @columnNo
																				 when 0 then rp.QualifyingProgramCompletionDate -- for qualifying effective date is the completion date
																				 when 1 then rp.CredentialEffectiveDate1
																				 when 2 then rp.CredentialEffectiveDate2
																				 when 3 then rp.CredentialEffectiveDate3
																				 when 4 then rp.CredentialEffectiveDate4
																				 when 5 then rp.CredentialEffectiveDate5
																				 when 6 then rp.CredentialEffectiveDate6
																				 when 7 then rp.CredentialEffectiveDate7
																				 when 8 then rp.CredentialEffectiveDate8
																				 when 9 then rp.CredentialEffectiveDate9
																			 end
			 ,@expiryTime									 = case @columnNo
																				 when 0 then cast(null as date) -- qualifying credentials do not expire
																				 when 1 then rp.CredentialExpiryDate1
																				 when 2 then rp.CredentialExpiryDate2
																				 when 3 then rp.CredentialExpiryDate3
																				 when 4 then rp.CredentialExpiryDate4
																				 when 5 then rp.CredentialExpiryDate5
																				 when 6 then rp.CredentialExpiryDate6
																				 when 7 then rp.CredentialExpiryDate7
																				 when 8 then rp.CredentialExpiryDate8
																				 when 9 then rp.CredentialExpiryDate9
																			 end
			from
				stg.RegistrantProfile rp
			where
				rp.RegistrantProfileSID = @RegistrantProfileSID;

			if @credentialLabel is not null
			begin

				if @columnNo = 0 -- qualifying credential in first iteration
				begin
					set @isQualifying = @ON;
				end;
				else -- otherwise non-qualifying or specialization
				begin
					set @isQualifying = @OFF;
				end;

				exec dbo.pRegistrantCredential#Set
					@UpdateRule = 'NEWONLY'
				 ,@RegistrantSID = @RegistrantSID
				 ,@CredentialLabel = @credentialLabel
				 ,@IsQualifying = @isQualifying
				 ,@OrgLabel = @orgLabel
				 ,@ProgramName = @programName
				 ,@ProgramStartDate = @programStartDate
				 ,@ProgramTargetCompletionDate = @programTargetCompletionDate
				 ,@FieldOfStudyName = @fieldOfStudyName
				 ,@EffectiveTime = @effectiveTime
				 ,@ExpiryTime = @expiryTime

			end;

		end;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);

end;
GO
