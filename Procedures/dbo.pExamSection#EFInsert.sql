SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pExamSection#EFInsert]
	 @ExamSID                   int               = null										-- required! if not passed value must be set in custom logic prior to insert
	,@Sequence                  smallint          = null										-- default: (0)
	,@SectionTitle              nvarchar(85)      = null										-- required! if not passed value must be set in custom logic prior to insert
	,@SectionText               nvarchar(max)     = null										
	,@RandomQuestionCount       smallint          = null										-- default: (0)
	,@WeightPerQuestion         smallint          = null										-- default: (0)
	,@MinimumCorrect            smallint          = null										-- default: (0)
	,@UserDefinedColumns        xml               = null										
	,@ExamSectionXID            varchar(150)      = null										
	,@LegacyKey                 nvarchar(50)      = null										
	,@CreateUser                nvarchar(75)      = null										-- default: suser_sname()
	,@IsReselected              tinyint           = null										-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                  xml               = null										-- other values defining context for the insert (if any)
	,@ExamName                  nvarchar(50)      = null										-- not a base table column (default ignored)
	,@ExamCategory              nvarchar(65)      = null										-- not a base table column (default ignored)
	,@PassingScore              int               = null										-- not a base table column (default ignored)
	,@EffectiveTime             datetime          = null										-- not a base table column (default ignored)
	,@ExpiryTime                datetime          = null										-- not a base table column (default ignored)
	,@IsOnlineExam              bit               = null										-- not a base table column (default ignored)
	,@IsEnabledOnPortal         bit               = null										-- not a base table column (default ignored)
	,@ExamSequence              int               = null										-- not a base table column (default ignored)
	,@CultureSID                int               = null										-- not a base table column (default ignored)
	,@LastVerifiedTime          datetimeoffset(7) = null										-- not a base table column (default ignored)
	,@MinLagDaysBetweenAttempts smallint          = null										-- not a base table column (default ignored)
	,@MaxAttemptsPerYear        tinyint           = null										-- not a base table column (default ignored)
	,@VendorExamID              varchar(25)       = null										-- not a base table column (default ignored)
	,@ExamRowGUID               uniqueidentifier  = null										-- not a base table column (default ignored)
	,@IsDeleteEnabled           bit               = null										-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pExamSection#EFInsert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : Alternate call syntax for pExamSection#Insert for use with MS Entity Framework (does not declare PK output parameter)
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

		exec @errorNo = dbo.pExamSection#Insert
			 @ExamSID                   = @ExamSID
			,@Sequence                  = @Sequence
			,@SectionTitle              = @SectionTitle
			,@SectionText               = @SectionText
			,@RandomQuestionCount       = @RandomQuestionCount
			,@WeightPerQuestion         = @WeightPerQuestion
			,@MinimumCorrect            = @MinimumCorrect
			,@UserDefinedColumns        = @UserDefinedColumns
			,@ExamSectionXID            = @ExamSectionXID
			,@LegacyKey                 = @LegacyKey
			,@CreateUser                = @CreateUser
			,@IsReselected              = @IsReselected
			,@zContext                  = @zContext
			,@ExamName                  = @ExamName
			,@ExamCategory              = @ExamCategory
			,@PassingScore              = @PassingScore
			,@EffectiveTime             = @EffectiveTime
			,@ExpiryTime                = @ExpiryTime
			,@IsOnlineExam              = @IsOnlineExam
			,@IsEnabledOnPortal         = @IsEnabledOnPortal
			,@ExamSequence              = @ExamSequence
			,@CultureSID                = @CultureSID
			,@LastVerifiedTime          = @LastVerifiedTime
			,@MinLagDaysBetweenAttempts = @MinLagDaysBetweenAttempts
			,@MaxAttemptsPerYear        = @MaxAttemptsPerYear
			,@VendorExamID              = @VendorExamID
			,@ExamRowGUID               = @ExamRowGUID
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
