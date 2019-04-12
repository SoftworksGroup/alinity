SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pEmploymentSupervisor#EFInsert]
	 @RegistrantEmploymentSID           int               = null						-- required! if not passed value must be set in custom logic prior to insert
	,@PersonSID                         int               = null						-- required! if not passed value must be set in custom logic prior to insert
	,@ExpiryTime                        datetime          = null						
	,@UserDefinedColumns                xml               = null						
	,@EmploymentSupervisorXID           varchar(150)      = null						
	,@LegacyKey                         nvarchar(50)      = null						
	,@CreateUser                        nvarchar(75)      = null						-- default: suser_sname()
	,@IsReselected                      tinyint           = null						-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                          xml               = null						-- other values defining context for the insert (if any)
	,@RegistrantSID                     int               = null						-- not a base table column (default ignored)
	,@OrgSID                            int               = null						-- not a base table column (default ignored)
	,@RegistrationYear                  smallint          = null						-- not a base table column (default ignored)
	,@EmploymentTypeSID                 int               = null						-- not a base table column (default ignored)
	,@EmploymentRoleSID                 int               = null						-- not a base table column (default ignored)
	,@PracticeHours                     int               = null						-- not a base table column (default ignored)
	,@PracticeScopeSID                  int               = null						-- not a base table column (default ignored)
	,@AgeRangeSID                       int               = null						-- not a base table column (default ignored)
	,@IsOnPublicRegistry                bit               = null						-- not a base table column (default ignored)
	,@Phone                             varchar(25)       = null						-- not a base table column (default ignored)
	,@SiteLocation                      nvarchar(50)      = null						-- not a base table column (default ignored)
	,@EffectiveTime                     datetime          = null						-- not a base table column (default ignored)
	,@RegistrantEmploymentExpiryTime    datetime          = null						-- not a base table column (default ignored)
	,@Rank                              smallint          = null						-- not a base table column (default ignored)
	,@OwnershipPercentage               smallint          = null						-- not a base table column (default ignored)
	,@IsEmployerInsurance               bit               = null						-- not a base table column (default ignored)
	,@InsuranceOrgSID                   int               = null						-- not a base table column (default ignored)
	,@InsurancePolicyNo                 varchar(25)       = null						-- not a base table column (default ignored)
	,@InsuranceAmount                   decimal(11,2)     = null						-- not a base table column (default ignored)
	,@RegistrantEmploymentRowGUID       uniqueidentifier  = null						-- not a base table column (default ignored)
	,@GenderSID                         int               = null						-- not a base table column (default ignored)
	,@NamePrefixSID                     int               = null						-- not a base table column (default ignored)
	,@FirstName                         nvarchar(30)      = null						-- not a base table column (default ignored)
	,@CommonName                        nvarchar(30)      = null						-- not a base table column (default ignored)
	,@MiddleNames                       nvarchar(30)      = null						-- not a base table column (default ignored)
	,@LastName                          nvarchar(35)      = null						-- not a base table column (default ignored)
	,@BirthDate                         date              = null						-- not a base table column (default ignored)
	,@DeathDate                         date              = null						-- not a base table column (default ignored)
	,@HomePhone                         varchar(25)       = null						-- not a base table column (default ignored)
	,@MobilePhone                       varchar(25)       = null						-- not a base table column (default ignored)
	,@IsTextMessagingEnabled            bit               = null						-- not a base table column (default ignored)
	,@ImportBatch                       nvarchar(100)     = null						-- not a base table column (default ignored)
	,@PersonRowGUID                     uniqueidentifier  = null						-- not a base table column (default ignored)
	,@IsDeleteEnabled                   bit               = null						-- not a base table column (default ignored)
	,@SupervisorRegistrantLabel         nvarchar(75)      = null						-- not a base table column (default ignored)
	,@IsAgreementValid                  bit               = null						-- not a base table column (default ignored)
	,@AgreementStatusLabel              nvarchar(30)      = null						-- not a base table column (default ignored)
	,@SupervisorRegistrantSID           int               = null						-- not a base table column (default ignored)
	,@SupervisorRegistrantEmploymentSID int               = null						-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pEmploymentSupervisor#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pEmploymentSupervisor#Insert for use with MS Entity Framework (does not declare PK output parameter)
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is a wrapper for the standard insert procedure for the table. It is provided particularly for application using the
Microsoft Entity Framework (EF). The current version of the EF generates an error if an entity attribute is defined as an output
parameter. This procedure does not declare the primary key output parameter but passes all remaining parameters to the standard
insert procedure.

-------------------------------------------------------------------------------------------------------------------------------- */

begin
	set nocount on

	declare
		 @errorNo                                      int = 0								-- 0 no error, <50000 SQL error, else business rule
		,@tranCount                                    int = @@trancount			-- determines whether a wrapping transaction exists
		,@sprocName                                    nvarchar(128) = object_name(@@procid)						-- name of currently executing procedure
		,@xState                                       int										-- error state detected in catch block

	begin try

		-- use a transaction so that any additional updates implemented through the extended
		-- procedure or through table-specific logic succeed or fail as a logical unit

		if @tranCount = 0																											-- no outer transaction
		begin
			begin transaction
		end
		else																																	-- outer transaction so create save point
		begin
			save transaction @sprocName
		end

		-- call the main procedure

		exec @errorNo = dbo.pEmploymentSupervisor#Insert
			 @RegistrantEmploymentSID           = @RegistrantEmploymentSID
			,@PersonSID                         = @PersonSID
			,@ExpiryTime                        = @ExpiryTime
			,@UserDefinedColumns                = @UserDefinedColumns
			,@EmploymentSupervisorXID           = @EmploymentSupervisorXID
			,@LegacyKey                         = @LegacyKey
			,@CreateUser                        = @CreateUser
			,@IsReselected                      = @IsReselected
			,@zContext                          = @zContext
			,@RegistrantSID                     = @RegistrantSID
			,@OrgSID                            = @OrgSID
			,@RegistrationYear                  = @RegistrationYear
			,@EmploymentTypeSID                 = @EmploymentTypeSID
			,@EmploymentRoleSID                 = @EmploymentRoleSID
			,@PracticeHours                     = @PracticeHours
			,@PracticeScopeSID                  = @PracticeScopeSID
			,@AgeRangeSID                       = @AgeRangeSID
			,@IsOnPublicRegistry                = @IsOnPublicRegistry
			,@Phone                             = @Phone
			,@SiteLocation                      = @SiteLocation
			,@EffectiveTime                     = @EffectiveTime
			,@RegistrantEmploymentExpiryTime    = @RegistrantEmploymentExpiryTime
			,@Rank                              = @Rank
			,@OwnershipPercentage               = @OwnershipPercentage
			,@IsEmployerInsurance               = @IsEmployerInsurance
			,@InsuranceOrgSID                   = @InsuranceOrgSID
			,@InsurancePolicyNo                 = @InsurancePolicyNo
			,@InsuranceAmount                   = @InsuranceAmount
			,@RegistrantEmploymentRowGUID       = @RegistrantEmploymentRowGUID
			,@GenderSID                         = @GenderSID
			,@NamePrefixSID                     = @NamePrefixSID
			,@FirstName                         = @FirstName
			,@CommonName                        = @CommonName
			,@MiddleNames                       = @MiddleNames
			,@LastName                          = @LastName
			,@BirthDate                         = @BirthDate
			,@DeathDate                         = @DeathDate
			,@HomePhone                         = @HomePhone
			,@MobilePhone                       = @MobilePhone
			,@IsTextMessagingEnabled            = @IsTextMessagingEnabled
			,@ImportBatch                       = @ImportBatch
			,@PersonRowGUID                     = @PersonRowGUID
			,@IsDeleteEnabled                   = @IsDeleteEnabled
			,@SupervisorRegistrantLabel         = @SupervisorRegistrantLabel
			,@IsAgreementValid                  = @IsAgreementValid
			,@AgreementStatusLabel              = @AgreementStatusLabel
			,@SupervisorRegistrantSID           = @SupervisorRegistrantSID
			,@SupervisorRegistrantEmploymentSID = @SupervisorRegistrantEmploymentSID

	end try

	begin catch
		set @xState = xact_state()
		
		if @tranCount > 0 and @xState = 1
		begin
			rollback transaction @sprocName																			-- committable wrapping trx exists: rollback to savepoint
		end
		else if @xState <> 0																									-- full rollback
		begin
			rollback
		end
		
		exec @errorNo = sf.pErrorRethrow																			-- process message text and re-throw the error
	end catch

	return(@errorNo)

end
GO
