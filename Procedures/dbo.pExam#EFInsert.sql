SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pExam#EFInsert]
	 @ExamName                  nvarchar(50)      = null										-- required! if not passed value must be set in custom logic prior to insert
	,@ExamCategory              nvarchar(65)      = null										
	,@PassingScore              int               = null										
	,@EffectiveTime             datetime          = null										-- default: sf.fNow()
	,@ExpiryTime                datetime          = null										
	,@IsOnlineExam              bit               = null										-- default: CONVERT(bit,(0))
	,@IsEnabledOnPortal         bit               = null										-- default: CONVERT(bit,(0))
	,@Sequence                  int               = null										-- default: (0)
	,@CultureSID                int               = null										-- required! if not passed value must be set in custom logic prior to insert
	,@InstructionText           nvarchar(max)     = null										
	,@LastVerifiedTime          datetimeoffset(7) = null										
	,@MinLagDaysBetweenAttempts smallint          = null										-- default: (0)
	,@MaxAttemptsPerYear        tinyint           = null										-- default: (99)
	,@VendorExamID              varchar(25)       = null										
	,@UserDefinedColumns        xml               = null										
	,@ExamXID                   varchar(150)      = null										
	,@LegacyKey                 nvarchar(50)      = null										
	,@CreateUser                nvarchar(75)      = null										-- default: suser_sname()
	,@IsReselected              tinyint           = null										-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                  xml               = null										-- other values defining context for the insert (if any)
	,@CultureSCD                varchar(10)       = null										-- not a base table column (default ignored)
	,@CultureLabel              nvarchar(35)      = null										-- not a base table column (default ignored)
	,@CultureIsDefault          bit               = null										-- not a base table column (default ignored)
	,@CultureIsActive           bit               = null										-- not a base table column (default ignored)
	,@CultureRowGUID            uniqueidentifier  = null										-- not a base table column (default ignored)
	,@IsActive                  bit               = null										-- not a base table column (default ignored)
	,@IsPending                 bit               = null										-- not a base table column (default ignored)
	,@IsDeleteEnabled           bit               = null										-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pExam#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pExam#Insert for use with MS Entity Framework (does not declare PK output parameter)
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

		exec @errorNo = dbo.pExam#Insert
			 @ExamName                  = @ExamName
			,@ExamCategory              = @ExamCategory
			,@PassingScore              = @PassingScore
			,@EffectiveTime             = @EffectiveTime
			,@ExpiryTime                = @ExpiryTime
			,@IsOnlineExam              = @IsOnlineExam
			,@IsEnabledOnPortal         = @IsEnabledOnPortal
			,@Sequence                  = @Sequence
			,@CultureSID                = @CultureSID
			,@InstructionText           = @InstructionText
			,@LastVerifiedTime          = @LastVerifiedTime
			,@MinLagDaysBetweenAttempts = @MinLagDaysBetweenAttempts
			,@MaxAttemptsPerYear        = @MaxAttemptsPerYear
			,@VendorExamID              = @VendorExamID
			,@UserDefinedColumns        = @UserDefinedColumns
			,@ExamXID                   = @ExamXID
			,@LegacyKey                 = @LegacyKey
			,@CreateUser                = @CreateUser
			,@IsReselected              = @IsReselected
			,@zContext                  = @zContext
			,@CultureSCD                = @CultureSCD
			,@CultureLabel              = @CultureLabel
			,@CultureIsDefault          = @CultureIsDefault
			,@CultureIsActive           = @CultureIsActive
			,@CultureRowGUID            = @CultureRowGUID
			,@IsActive                  = @IsActive
			,@IsPending                 = @IsPending
			,@IsDeleteEnabled           = @IsDeleteEnabled

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
