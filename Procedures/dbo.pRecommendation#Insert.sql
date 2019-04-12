SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRecommendation#Insert]
	 @RecommendationSID          int               = null output						-- identity value assigned to the new record
	,@RecommendationGroupSID     int               = null										-- required! if not passed value must be set in custom logic prior to insert
	,@ButtonLabel                nvarchar(20)      = null										-- required! if not passed value must be set in custom logic prior to insert
	,@RecommendationSequence     smallint          = null										-- default: (0)
	,@ToolTip                    nvarchar(500)     = null										
	,@IsActive                   bit               = null										-- default: (1)
	,@UserDefinedColumns         xml               = null										
	,@RecommendationXID          varchar(150)      = null										
	,@LegacyKey                  nvarchar(50)      = null										
	,@CreateUser                 nvarchar(75)      = null										-- default: suser_sname()
	,@IsReselected               tinyint           = null										-- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@zContext                   xml               = null										-- other values defining context for the insert (if any)
	,@RecommendationGroupSCD     varchar(15)       = null										-- not a base table column (default ignored)
	,@RecommendationGroupLabel   nvarchar(35)      = null										-- not a base table column (default ignored)
	,@RecommendationGroupRowGUID uniqueidentifier  = null										-- not a base table column (default ignored)
	,@IsDeleteEnabled            bit               = null										-- not a base table column (default ignored)
as
/*********************************************************************************************************************************
Procedure : dbo.pRecommendation#Insert
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : inserts 1 row into the dbo.Recommendation table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the dbo.Recommendation table with parameter values represent columns of the table. Additional
parameters are provided for all columns in the vRecommendation entity view, however, the base logic of the procedure inserts the
the columns of the table only.

Note: This procedure cannot be called directly from the MS Entity Framework! Use the wrapper procedure instead (...#EFInsert) that
excludes the primary key output parameter, but includes all other parameters.

Table-specific logic can be added through tagged sections (pre and post insert) and a call to an extended procedure supports
configuration (client) specific logic. Code implemented within code tags (table-specific logic) is part of the base product and
applies to all client configurations. Calls to the extended procedure occurs immediately after the table-specific logic in both
"pre-insert" and "post-insert" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pRecommendation procedure. The extended procedure is only called
where it exists in the DB. The first parameter passed @Mode is set to either "insert.pre" or "insert.post" to provide context for
the extended logic.

The @zContext parameter is an additional construct available to support overrides where different results are produced based on
content provided in the XML from the client tier. This parameter may contain multiple values.

The "@IsReselected" parameter controls whether the entity row is returned as a dataset (SELECT). There are 3 settings:
   0 - no data set is returned
   1 - return the full entity
   2 - return only the SID (primary key) of the row inserted

For client-tier calls using the Microsoft Entity Framework and RIA Services, the @IsReselected bit should be passed as 1 to
force re-selection of table columns + extended view columns (the entity view).

Values for parameters representing mandatory columns must be provided unless a database default exists.  The default values
displayed as comments next to the parameter declarations above, and the list of columns returned from the entity view when
@IsReselected = 1, were obtained from the data dictionary at generation time. If the table or view design has been
updated since then, the procedure must be regenerated to keep comments up to date. In the StudioDB run dbo.pEFGen
to update all views and procedures which appear out-of-date.

The procedure does not accept a parameter for UpdateUser since the @CreateUser value is applied into both the user audit
columns.  Audit times are set automatically through database defaults and cannot be passed or overwritten.

If the @CreateUser parameter is passed as the special value "SystemUser", then the system user established in sf.ConfigParam
is applied. This option is useful for conversion and system generated inserts the user would not recognize as have caused. Any
other value provided for the parameter (including null) is overwritten with the current application user.

Business rule compliance is checked through a table constraint which calls fRecommendationCheck to test all rules.

-------------------------------------------------------------------------------------------------------------------------------- */

begin
	set nocount on

	declare
		 @errorNo                                      int = 0								-- 0 no error, <50000 SQL error, else business rule
		,@tranCount                                    int = @@trancount			-- determines whether a wrapping transaction exists
		,@sprocName                                    nvarchar(128) = object_name(@@procid)						-- name of currently executing procedure
		,@xState                                       int										-- error state detected in catch block
		,@errorText                                    nvarchar(4000)					-- message text (for business rule errors)
		,@rowsAffected                                 int = 0								-- tracks rows impacted by the operation (error check)
		,@recordSID                                    int										-- tracks primary key value for clearing current default
		,@ON                                           bit = cast(1 as bit)		-- constant for bit comparison and assignments
		,@OFF                                          bit = cast(0 as bit)		-- constant for bit comparison and assignments

	set @RecommendationSID = null																						-- initialize output parameter

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

		-- remove leading and trailing spaces from character type columns

		set @ButtonLabel = ltrim(rtrim(@ButtonLabel))
		set @ToolTip = ltrim(rtrim(@ToolTip))
		set @RecommendationXID = ltrim(rtrim(@RecommendationXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @CreateUser = ltrim(rtrim(@CreateUser))
		set @RecommendationGroupSCD = ltrim(rtrim(@RecommendationGroupSCD))
		set @RecommendationGroupLabel = ltrim(rtrim(@RecommendationGroupLabel))

		-- set zero length strings to null to avoid storing them in the record

		if len(@ButtonLabel) = 0 set @ButtonLabel = null
		if len(@ToolTip) = 0 set @ToolTip = null
		if len(@RecommendationXID) = 0 set @RecommendationXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@CreateUser) = 0 set @CreateUser = null
		if len(@RecommendationGroupSCD) = 0 set @RecommendationGroupSCD = null
		if len(@RecommendationGroupLabel) = 0 set @RecommendationGroupLabel = null

		-- set the ID of the user

		if isnull(@CreateUser, 'x') = N'SystemUser' set @CreateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@CreateUser, 'x') <> N'SystemUser' set @CreateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- reset defaults on table parameters passed as NULL

		set @RecommendationSequence = isnull(@RecommendationSequence,(0))
		set @IsActive = isnull(@IsActive,(1))
		set @CreateUser = isnull(@CreateUser,suser_sname())
		set @IsReselected           = isnull(@IsReselected          ,(0))
		
		-- look up the FK value matching the system code if set; this allows
		-- FK values value to be set/updated based on system code values
		
		if @RecommendationGroupSCD is not null
		begin
		
			select
				@RecommendationGroupSID = x.RecommendationGroupSID
			from
				dbo.RecommendationGroup x
			where
				x.RecommendationGroupSCD = @RecommendationGroupSCD
		
		end

		-- apply the table-specific pre-insert logic (if any)

		--! <PreInsert>
		--  insert pre-insert logic here ...
		--! </PreInsert>
	
		-- call the extended version of the procedure (if it exists) for "insert.pre" mode
		
		if exists
		(
			select
				1
			from
				sf.vRoutine r
			where
				r.SchemaName = 'ext'
			and
				r.RoutineName = 'pRecommendation'
		)
		begin
		
			exec @errorNo = ext.pRecommendation
				 @Mode                       = 'insert.pre'
				,@RecommendationGroupSID     = @RecommendationGroupSID output
				,@ButtonLabel                = @ButtonLabel output
				,@RecommendationSequence     = @RecommendationSequence output
				,@ToolTip                    = @ToolTip output
				,@IsActive                   = @IsActive output
				,@UserDefinedColumns         = @UserDefinedColumns output
				,@RecommendationXID          = @RecommendationXID output
				,@LegacyKey                  = @LegacyKey output
				,@CreateUser                 = @CreateUser
				,@IsReselected               = @IsReselected
				,@zContext                   = @zContext
				,@RecommendationGroupSCD     = @RecommendationGroupSCD
				,@RecommendationGroupLabel   = @RecommendationGroupLabel
				,@RecommendationGroupRowGUID = @RecommendationGroupRowGUID
				,@IsDeleteEnabled            = @IsDeleteEnabled
		
		end

		-- insert the record

		insert
			dbo.Recommendation
		(
			 RecommendationGroupSID
			,ButtonLabel
			,RecommendationSequence
			,ToolTip
			,IsActive
			,UserDefinedColumns
			,RecommendationXID
			,LegacyKey
			,CreateUser
			,UpdateUser
		)
		select
			 @RecommendationGroupSID
			,@ButtonLabel
			,@RecommendationSequence
			,@ToolTip
			,@IsActive
			,@UserDefinedColumns
			,@RecommendationXID
			,@LegacyKey
			,@CreateUser
			,@CreateUser

		select
			 @rowsAffected      = @@rowcount
			,@RecommendationSID = scope_identity()															-- capture key value of new row

		-- check for errors

		if @rowsAffected <> 1																									-- ensure 1 row was inserted
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'insert'
				,@Arg2        = 'dbo.Recommendation'
				,@Arg3        = @rowsAffected
				,@Arg4        = @RecommendationSID
			
			raiserror(@errorText, 18, 1)
			
		end

		-- apply the table-specific post-insert logic (if any)

		--! <PostInsert>
		--  insert post-insert logic here ...
		--! </PostInsert>
	
		-- call the extended version of the procedure (if it exists) for "insert.post" mode
		
		if exists
		(
			select
				1
			from
				sf.vRoutine r
			where
				r.SchemaName = 'ext'
			and
				r.RoutineName = 'pRecommendation'
		)
		begin
		
			exec @errorNo = ext.pRecommendation
				 @Mode                       = 'insert.post'
				,@RecommendationSID          = @RecommendationSID
				,@RecommendationGroupSID     = @RecommendationGroupSID
				,@ButtonLabel                = @ButtonLabel
				,@RecommendationSequence     = @RecommendationSequence
				,@ToolTip                    = @ToolTip
				,@IsActive                   = @IsActive
				,@UserDefinedColumns         = @UserDefinedColumns
				,@RecommendationXID          = @RecommendationXID
				,@LegacyKey                  = @LegacyKey
				,@CreateUser                 = @CreateUser
				,@IsReselected               = @IsReselected
				,@zContext                   = @zContext
				,@RecommendationGroupSCD     = @RecommendationGroupSCD
				,@RecommendationGroupLabel   = @RecommendationGroupLabel
				,@RecommendationGroupRowGUID = @RecommendationGroupRowGUID
				,@IsDeleteEnabled            = @IsDeleteEnabled
		
		end

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.RecommendationSID
			from
				dbo.vRecommendation ent
			where
				ent.RecommendationSID = @RecommendationSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.RecommendationSID
				,ent.RecommendationGroupSID
				,ent.ButtonLabel
				,ent.RecommendationSequence
				,ent.ToolTip
				,ent.IsActive
				,ent.UserDefinedColumns
				,ent.RecommendationXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.RecommendationGroupSCD
				,ent.RecommendationGroupLabel
				,ent.RecommendationGroupRowGUID
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
			from
				dbo.vRecommendation ent
			where
				ent.RecommendationSID = @RecommendationSID

		end

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
