SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE stg.pRegistrantProfile#Process$Groups
	@RegistrantProfileSID int													-- source record to extract Person Group assignments from
 ,@PersonSID						int													-- person to assign person groups to
as
/*********************************************************************************************************************************
Procedure : Registrant Profile - Process Groups
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Processing subroutine to extract and process person group information from stg.RegistrantProfile
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Mar 2019		|	Initial version

Comments
--------
The stg.RegistrantProfile table supports collection of up to 5 person groups per registrant. The subroutine processes a single 
registrant profile record but may return a count of errors > 1 where multiple person group records have been populated in the
main record (@ErrorCount > 1).

This routine provides the logic for extraction of the person group values from the staging record but validation and insert of the
(sf) Person Group record is handled by the (sf) pPersonGroupMember#Set procedure.

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
		@errorNo					int						= 0										-- 0 no error, <50000 SQL error, else business rule
	 ,@columnNo					int																	-- counter to track extractions from flattend records (Label1, Label2, etc)  	
	 ,@personGroupLabel nvarchar(65)												-- person group identifier (see #lookup procedure)	
	 ,@title						nvarchar(75)												-- optional values for person group assignment:
	 ,@isAdministrator	bit
	 ,@effectiveTime		datetime
	 ,@expiryTime				datetime;

	begin try

		set @columnNo = 0;

		while @columnNo < 5
		begin

			set @columnNo += 1;

			-- extract parameter values for the #Set sproc
			-- from the base staging record columns

			select
				@personGroupLabel = case @columnNo
															when 1 then rp.PersonGroupLabel1
															when 2 then rp.PersonGroupLabel2
															when 3 then rp.PersonGroupLabel3
															when 4 then rp.PersonGroupLabel4
															when 5 then rp.PersonGroupLabel5
															else cast('?' as nvarchar(5))
														end
			 ,@title						= case @columnNo
															when 1 then rp.PersonGroupTitle1
															when 2 then rp.PersonGroupTitle2
															when 3 then rp.PersonGroupTitle3
															when 4 then rp.PersonGroupTitle4
															when 5 then rp.PersonGroupTitle5
															else cast('?' as nvarchar(5))
														end
			 ,@isAdministrator	= case @columnNo
															when 1 then rp.PersonGroupIsAdministrator1
															when 2 then rp.PersonGroupIsAdministrator2
															when 3 then rp.PersonGroupIsAdministrator3
															when 4 then rp.PersonGroupIsAdministrator4
															when 5 then rp.PersonGroupIsAdministrator5
														end
			 ,@effectiveTime		= case @columnNo
															when 1 then rp.PersonGroupEffectiveDate1
															when 2 then rp.PersonGroupEffectiveDate2
															when 3 then rp.PersonGroupEffectiveDate3
															when 4 then rp.PersonGroupEffectiveDate4
															when 5 then rp.PersonGroupEffectiveDate5
														end
			 ,@expiryTime				= case @columnNo
															when 1 then rp.PersonGroupExpiryDate1
															when 2 then rp.PersonGroupExpiryDate2
															when 3 then rp.PersonGroupExpiryDate3
															when 4 then rp.PersonGroupExpiryDate4
															when 5 then rp.PersonGroupExpiryDate5
														end
			from
				stg.RegistrantProfile rp
			where
				rp.RegistrantProfileSID = @RegistrantProfileSID;

			if @personGroupLabel is not null
			begin

				exec sf.pPersonGroupMember#Set
					@UpdateRule = 'NEWONLY'
				 ,@PersonSID = @PersonSID
				 ,@PersonGroupLabel = @personGroupLabel
				 ,@Title = @title
				 ,@IsAdministrator = @isAdministrator
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
