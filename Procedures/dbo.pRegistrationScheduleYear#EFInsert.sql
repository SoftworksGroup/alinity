SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrationScheduleYear#EFInsert]
	 @RegistrationScheduleSID                    int               = null		-- required! if not passed value must be set in custom logic prior to insert
	,@RegistrationYear                           smallint          = null		-- required! if not passed value must be set in custom logic prior to insert
	,@YearStartTime                              datetime          = null		-- required! if not passed value must be set in custom logic prior to insert
	,@YearEndTime                                datetime          = null		-- required! if not passed value must be set in custom logic prior to insert
	,@RenewalVerificationOpenTime                datetime          = null		-- required! if not passed value must be set in custom logic prior to insert
	,@RenewalGeneralOpenTime                     datetime          = null		-- required! if not passed value must be set in custom logic prior to insert
	,@RenewalLateFeeStartTime                    datetime          = null		-- required! if not passed value must be set in custom logic prior to insert
	,@RenewalEndTime                             datetime          = null		-- required! if not passed value must be set in custom logic prior to insert
	,@ReinstatementVerificationOpenTime          datetime          = null		-- required! if not passed value must be set in custom logic prior to insert
	,@ReinstatementGeneralOpenTime               datetime          = null		-- required! if not passed value must be set in custom logic prior to insert
	,@ReinstatementEndTime                       datetime          = null		-- required! if not passed value must be set in custom logic prior to insert
	,@CECollectionStartTime                      datetime          = null		-- required! if not passed value must be set in custom logic prior to insert
	,@CECollectionEndTime                        datetime          = null		-- required! if not passed value must be set in custom logic prior to insert
	,@PAPBlockStartTime                          datetime          = null		-- required! if not passed value must be set in custom logic prior to insert
	,@PAPBlockEndTime                            datetime          = null		-- required! if not passed value must be set in custom logic prior to insert
	,@UserDefinedColumns                         xml               = null		
	,@RegistrationScheduleYearXID                varchar(150)      = null		
	,@LegacyKey                                  nvarchar(50)      = null		
	,@CreateUser                                 nvarchar(75)      = null		-- default: suser_sname()
	,@IsReselected                               tinyint           = null		-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                                   xml               = null		-- other values defining context for the insert (if any)
	,@RegistrationScheduleLabel                  nvarchar(35)      = null		-- not a base table column (default ignored)
	,@RegistrationScheduleIsDefault              bit               = null		-- not a base table column (default ignored)
	,@RegistrationScheduleIsActive               bit               = null		-- not a base table column (default ignored)
	,@RegistrationScheduleRowGUID                uniqueidentifier  = null		-- not a base table column (default ignored)
	,@IsDeleteEnabled                            bit               = null		-- not a base table column (default ignored)
	,@RegistrationYearLabel                      varchar(25)       = null		-- not a base table column (default ignored)
	,@RenewalVerificationOpenTimeComponent       time(7)           = null		-- not a base table column (default ignored)
	,@RenewalGeneralOpenTimeComponent            time(7)           = null		-- not a base table column (default ignored)
	,@ReinstatementVerificationOpenTimeComponent time(7)           = null		-- not a base table column (default ignored)
	,@ReinstatementGeneralOpenTimeComponent      time(7)           = null		-- not a base table column (default ignored)
	,@YearStartTimeComponent                     time(7)           = null		-- not a base table column (default ignored)
	,@YearEndTimeComponent                       time(7)           = null		-- not a base table column (default ignored)
	,@RenewalLateFeeStartTimeComponent           time(7)           = null		-- not a base table column (default ignored)
	,@RenewalEndTimeComponent                    time(7)           = null		-- not a base table column (default ignored)
	,@ReinstatementEndTimeComponent              time(7)           = null		-- not a base table column (default ignored)
	,@PAPBlockStartTimeComponent                 time(7)           = null		-- not a base table column (default ignored)
	,@PAPBlockEndTimeComponent                   time(7)           = null		-- not a base table column (default ignored)
	,@IsEditEnabled                              bit               = null		-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pRegistrationScheduleYear#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pRegistrationScheduleYear#Insert for use with MS Entity Framework (does not declare PK output parameter)
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : March 2019
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

		exec @errorNo = dbo.pRegistrationScheduleYear#Insert
			 @RegistrationScheduleSID                    = @RegistrationScheduleSID
			,@RegistrationYear                           = @RegistrationYear
			,@YearStartTime                              = @YearStartTime
			,@YearEndTime                                = @YearEndTime
			,@RenewalVerificationOpenTime                = @RenewalVerificationOpenTime
			,@RenewalGeneralOpenTime                     = @RenewalGeneralOpenTime
			,@RenewalLateFeeStartTime                    = @RenewalLateFeeStartTime
			,@RenewalEndTime                             = @RenewalEndTime
			,@ReinstatementVerificationOpenTime          = @ReinstatementVerificationOpenTime
			,@ReinstatementGeneralOpenTime               = @ReinstatementGeneralOpenTime
			,@ReinstatementEndTime                       = @ReinstatementEndTime
			,@CECollectionStartTime                      = @CECollectionStartTime
			,@CECollectionEndTime                        = @CECollectionEndTime
			,@PAPBlockStartTime                          = @PAPBlockStartTime
			,@PAPBlockEndTime                            = @PAPBlockEndTime
			,@UserDefinedColumns                         = @UserDefinedColumns
			,@RegistrationScheduleYearXID                = @RegistrationScheduleYearXID
			,@LegacyKey                                  = @LegacyKey
			,@CreateUser                                 = @CreateUser
			,@IsReselected                               = @IsReselected
			,@zContext                                   = @zContext
			,@RegistrationScheduleLabel                  = @RegistrationScheduleLabel
			,@RegistrationScheduleIsDefault              = @RegistrationScheduleIsDefault
			,@RegistrationScheduleIsActive               = @RegistrationScheduleIsActive
			,@RegistrationScheduleRowGUID                = @RegistrationScheduleRowGUID
			,@IsDeleteEnabled                            = @IsDeleteEnabled
			,@RegistrationYearLabel                      = @RegistrationYearLabel
			,@RenewalVerificationOpenTimeComponent       = @RenewalVerificationOpenTimeComponent
			,@RenewalGeneralOpenTimeComponent            = @RenewalGeneralOpenTimeComponent
			,@ReinstatementVerificationOpenTimeComponent = @ReinstatementVerificationOpenTimeComponent
			,@ReinstatementGeneralOpenTimeComponent      = @ReinstatementGeneralOpenTimeComponent
			,@YearStartTimeComponent                     = @YearStartTimeComponent
			,@YearEndTimeComponent                       = @YearEndTimeComponent
			,@RenewalLateFeeStartTimeComponent           = @RenewalLateFeeStartTimeComponent
			,@RenewalEndTimeComponent                    = @RenewalEndTimeComponent
			,@ReinstatementEndTimeComponent              = @ReinstatementEndTimeComponent
			,@PAPBlockStartTimeComponent                 = @PAPBlockStartTimeComponent
			,@PAPBlockEndTimeComponent                   = @PAPBlockEndTimeComponent
			,@IsEditEnabled                              = @IsEditEnabled

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
