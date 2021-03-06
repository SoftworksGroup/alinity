SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pPAPSubscription#EFInsert]
	 @PersonSID              int               = null												-- required! if not passed value must be set in custom logic prior to insert
	,@InstitutionNo          varchar(3)        = null												-- required! if not passed value must be set in custom logic prior to insert
	,@TransitNo              varchar(5)        = null												-- required! if not passed value must be set in custom logic prior to insert
	,@AccountNo              varchar(15)       = null												-- required! if not passed value must be set in custom logic prior to insert
	,@WithdrawalAmount       decimal(11,2)     = null												-- required! if not passed value must be set in custom logic prior to insert
	,@EffectiveTime          datetime          = null												-- required! if not passed value must be set in custom logic prior to insert
	,@CancelledTime          datetime          = null												
	,@UserDefinedColumns     xml               = null												
	,@PAPSubscriptionXID     varchar(150)      = null												
	,@LegacyKey              nvarchar(50)      = null												
	,@CreateUser             nvarchar(75)      = null												-- default: suser_sname()
	,@IsReselected           tinyint           = null												-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext               xml               = null												-- other values defining context for the insert (if any)
	,@GenderSID              int               = null												-- not a base table column (default ignored)
	,@NamePrefixSID          int               = null												-- not a base table column (default ignored)
	,@FirstName              nvarchar(30)      = null												-- not a base table column (default ignored)
	,@CommonName             nvarchar(30)      = null												-- not a base table column (default ignored)
	,@MiddleNames            nvarchar(30)      = null												-- not a base table column (default ignored)
	,@LastName               nvarchar(35)      = null												-- not a base table column (default ignored)
	,@BirthDate              date              = null												-- not a base table column (default ignored)
	,@DeathDate              date              = null												-- not a base table column (default ignored)
	,@HomePhone              varchar(25)       = null												-- not a base table column (default ignored)
	,@MobilePhone            varchar(25)       = null												-- not a base table column (default ignored)
	,@IsTextMessagingEnabled bit               = null												-- not a base table column (default ignored)
	,@ImportBatch            nvarchar(100)     = null												-- not a base table column (default ignored)
	,@PersonRowGUID          uniqueidentifier  = null												-- not a base table column (default ignored)
	,@IsDeleteEnabled        bit               = null												-- not a base table column (default ignored)
	,@RegistrantNo           varchar(50)       = null												-- not a base table column (default ignored)
	,@RegistrantLabel        nvarchar(75)      = null												-- not a base table column (default ignored)
	,@FileAsName             nvarchar(65)      = null												-- not a base table column (default ignored)
	,@DisplayName            nvarchar(65)      = null												-- not a base table column (default ignored)
	,@IsActiveSubscription   bit               = null												-- not a base table column (default ignored)
	,@HasRejectedTrxs        bit               = null												-- not a base table column (default ignored)
	,@HasUnappliedAmount     bit               = null												-- not a base table column (default ignored)
	,@EmailAddress           varchar(150)      = null												-- not a base table column (default ignored)
	,@TrxCount               int               = null												-- not a base table column (default ignored)
	,@RejectedTrxCount       int               = null												-- not a base table column (default ignored)
	,@TotalUnapplied         decimal(38,2)     = null												-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pPAPSubscription#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pPAPSubscription#Insert for use with MS Entity Framework (does not declare PK output parameter)
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

		exec @errorNo = dbo.pPAPSubscription#Insert
			 @PersonSID              = @PersonSID
			,@InstitutionNo          = @InstitutionNo
			,@TransitNo              = @TransitNo
			,@AccountNo              = @AccountNo
			,@WithdrawalAmount       = @WithdrawalAmount
			,@EffectiveTime          = @EffectiveTime
			,@CancelledTime          = @CancelledTime
			,@UserDefinedColumns     = @UserDefinedColumns
			,@PAPSubscriptionXID     = @PAPSubscriptionXID
			,@LegacyKey              = @LegacyKey
			,@CreateUser             = @CreateUser
			,@IsReselected           = @IsReselected
			,@zContext               = @zContext
			,@GenderSID              = @GenderSID
			,@NamePrefixSID          = @NamePrefixSID
			,@FirstName              = @FirstName
			,@CommonName             = @CommonName
			,@MiddleNames            = @MiddleNames
			,@LastName               = @LastName
			,@BirthDate              = @BirthDate
			,@DeathDate              = @DeathDate
			,@HomePhone              = @HomePhone
			,@MobilePhone            = @MobilePhone
			,@IsTextMessagingEnabled = @IsTextMessagingEnabled
			,@ImportBatch            = @ImportBatch
			,@PersonRowGUID          = @PersonRowGUID
			,@IsDeleteEnabled        = @IsDeleteEnabled
			,@RegistrantNo           = @RegistrantNo
			,@RegistrantLabel        = @RegistrantLabel
			,@FileAsName             = @FileAsName
			,@DisplayName            = @DisplayName
			,@IsActiveSubscription   = @IsActiveSubscription
			,@HasRejectedTrxs        = @HasRejectedTrxs
			,@HasUnappliedAmount     = @HasUnappliedAmount
			,@EmailAddress           = @EmailAddress
			,@TrxCount               = @TrxCount
			,@RejectedTrxCount       = @RejectedTrxCount
			,@TotalUnapplied         = @TotalUnapplied

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
