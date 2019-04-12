SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrationRequirement#EFInsert]
	 @RegistrationRequirementTypeSID       int               = null					-- required! if not passed value must be set in custom logic prior to insert
	,@RegistrationRequirementLabel         nvarchar(35)      = null					-- required! if not passed value must be set in custom logic prior to insert
	,@RequirementDescription               varbinary(max)    = null					
	,@AdminGuidance                        varbinary(max)    = null					
	,@PersonDocTypeSID                     int               = null					
	,@ExamSID                              int               = null					
	,@ExpiryMonths                         smallint          = null					-- default: (0)
	,@IsActive                             bit               = null					-- default: (1)
	,@UserDefinedColumns                   xml               = null					
	,@RegistrationRequirementXID           varchar(150)      = null					
	,@LegacyKey                            nvarchar(50)      = null					
	,@CreateUser                           nvarchar(75)      = null					-- default: suser_sname()
	,@IsReselected                         tinyint           = null					-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                             xml               = null					-- other values defining context for the insert (if any)
	,@RegistrationRequirementTypeLabel     nvarchar(35)      = null					-- not a base table column (default ignored)
	,@RegistrationRequirementTypeCode      varchar(20)       = null					-- not a base table column (default ignored)
	,@RegistrationRequirementTypeCategory  nvarchar(65)      = null					-- not a base table column (default ignored)
	,@IsAppliedToPeople                    bit               = null					-- not a base table column (default ignored)
	,@IsAppliedToOrganizations             bit               = null					-- not a base table column (default ignored)
	,@RegistrationRequirementTypeIsDefault bit               = null					-- not a base table column (default ignored)
	,@RegistrationRequirementTypeIsActive  bit               = null					-- not a base table column (default ignored)
	,@RegistrationRequirementTypeRowGUID   uniqueidentifier  = null					-- not a base table column (default ignored)
	,@ExamName                             nvarchar(50)      = null					-- not a base table column (default ignored)
	,@ExamCategory                         nvarchar(65)      = null					-- not a base table column (default ignored)
	,@PassingScore                         int               = null					-- not a base table column (default ignored)
	,@EffectiveTime                        datetime          = null					-- not a base table column (default ignored)
	,@ExpiryTime                           datetime          = null					-- not a base table column (default ignored)
	,@IsOnlineExam                         bit               = null					-- not a base table column (default ignored)
	,@IsEnabledOnPortal                    bit               = null					-- not a base table column (default ignored)
	,@Sequence                             int               = null					-- not a base table column (default ignored)
	,@CultureSID                           int               = null					-- not a base table column (default ignored)
	,@LastVerifiedTime                     datetimeoffset(7) = null					-- not a base table column (default ignored)
	,@MinLagDaysBetweenAttempts            smallint          = null					-- not a base table column (default ignored)
	,@MaxAttemptsPerYear                   tinyint           = null					-- not a base table column (default ignored)
	,@VendorExamID                         varchar(25)       = null					-- not a base table column (default ignored)
	,@ExamRowGUID                          uniqueidentifier  = null					-- not a base table column (default ignored)
	,@PersonDocTypeSCD                     varchar(15)       = null					-- not a base table column (default ignored)
	,@PersonDocTypeLabel                   nvarchar(35)      = null					-- not a base table column (default ignored)
	,@PersonDocTypeCategory                nvarchar(65)      = null					-- not a base table column (default ignored)
	,@PersonDocTypeIsDefault               bit               = null					-- not a base table column (default ignored)
	,@PersonDocTypeIsActive                bit               = null					-- not a base table column (default ignored)
	,@PersonDocTypeRowGUID                 uniqueidentifier  = null					-- not a base table column (default ignored)
	,@IsDeleteEnabled                      bit               = null					-- not a base table column (default ignored)
	,@IsDeclaration                        bit               = null					-- not a base table column (default ignored)
	,@IsExam                               bit               = null					-- not a base table column (default ignored)
	,@IsDocument                           bit               = null					-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pRegistrationRequirement#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pRegistrationRequirement#Insert for use with MS Entity Framework (does not declare PK output parameter)
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

		exec @errorNo = dbo.pRegistrationRequirement#Insert
			 @RegistrationRequirementTypeSID       = @RegistrationRequirementTypeSID
			,@RegistrationRequirementLabel         = @RegistrationRequirementLabel
			,@RequirementDescription               = @RequirementDescription
			,@AdminGuidance                        = @AdminGuidance
			,@PersonDocTypeSID                     = @PersonDocTypeSID
			,@ExamSID                              = @ExamSID
			,@ExpiryMonths                         = @ExpiryMonths
			,@IsActive                             = @IsActive
			,@UserDefinedColumns                   = @UserDefinedColumns
			,@RegistrationRequirementXID           = @RegistrationRequirementXID
			,@LegacyKey                            = @LegacyKey
			,@CreateUser                           = @CreateUser
			,@IsReselected                         = @IsReselected
			,@zContext                             = @zContext
			,@RegistrationRequirementTypeLabel     = @RegistrationRequirementTypeLabel
			,@RegistrationRequirementTypeCode      = @RegistrationRequirementTypeCode
			,@RegistrationRequirementTypeCategory  = @RegistrationRequirementTypeCategory
			,@IsAppliedToPeople                    = @IsAppliedToPeople
			,@IsAppliedToOrganizations             = @IsAppliedToOrganizations
			,@RegistrationRequirementTypeIsDefault = @RegistrationRequirementTypeIsDefault
			,@RegistrationRequirementTypeIsActive  = @RegistrationRequirementTypeIsActive
			,@RegistrationRequirementTypeRowGUID   = @RegistrationRequirementTypeRowGUID
			,@ExamName                             = @ExamName
			,@ExamCategory                         = @ExamCategory
			,@PassingScore                         = @PassingScore
			,@EffectiveTime                        = @EffectiveTime
			,@ExpiryTime                           = @ExpiryTime
			,@IsOnlineExam                         = @IsOnlineExam
			,@IsEnabledOnPortal                    = @IsEnabledOnPortal
			,@Sequence                             = @Sequence
			,@CultureSID                           = @CultureSID
			,@LastVerifiedTime                     = @LastVerifiedTime
			,@MinLagDaysBetweenAttempts            = @MinLagDaysBetweenAttempts
			,@MaxAttemptsPerYear                   = @MaxAttemptsPerYear
			,@VendorExamID                         = @VendorExamID
			,@ExamRowGUID                          = @ExamRowGUID
			,@PersonDocTypeSCD                     = @PersonDocTypeSCD
			,@PersonDocTypeLabel                   = @PersonDocTypeLabel
			,@PersonDocTypeCategory                = @PersonDocTypeCategory
			,@PersonDocTypeIsDefault               = @PersonDocTypeIsDefault
			,@PersonDocTypeIsActive                = @PersonDocTypeIsActive
			,@PersonDocTypeRowGUID                 = @PersonDocTypeRowGUID
			,@IsDeleteEnabled                      = @IsDeleteEnabled
			,@IsDeclaration                        = @IsDeclaration
			,@IsExam                               = @IsExam
			,@IsDocument                           = @IsDocument

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
