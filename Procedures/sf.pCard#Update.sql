SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pCard#Update]
	 @CardSID               int               = null -- required! id of row to update - must be set in custom logic if not passed
	,@CardTypeSID           int               = null -- table column values to update:
	,@CardLabel             nvarchar(35)      = null
	,@CardContext           varchar(25)       = null
	,@CSSDefinition         varchar(150)      = null
	,@SummaryCardDefinition nvarchar(max)     = null
	,@DetailCardDefinition  nvarchar(max)     = null
	,@HeaderDefinition      nvarchar(max)     = null
	,@FooterDefinition      nvarchar(max)     = null
	,@GridRowDefinition     nvarchar(max)     = null
	,@IsActive              bit               = null
	,@CardHelp              nvarchar(max)     = null
	,@UserDefinedColumns    xml               = null
	,@CardXID               varchar(150)      = null
	,@LegacyKey             nvarchar(50)      = null
	,@UpdateUser            nvarchar(75)      = null -- set to current application user unless "SystemUser" passed
	,@RowStamp              timestamp         = null -- row time stamp - pass for preemptive check for overwrites
	,@IsReselected          tinyint           = 0    -- when 1 all columns in entity view are returned, 2 PK only, 0 none
	,@IsNullApplied         bit               = 0    -- when 1 null parameters overwrite corresponding columns with null
	,@zContext              xml               = null -- other values defining context for the update (if any)
	,@CardTypeSCD           varchar(25)       = null -- not a base table column
	,@CardTypeLabel         nvarchar(35)      = null -- not a base table column
	,@CardTypeRowGUID       uniqueidentifier  = null -- not a base table column
	,@IsDeleteEnabled       bit               = null -- not a base table column
as
/*********************************************************************************************************************************
Procedure : sf.pCard#Update
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : updates 1 row in the sf.Card table
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used to update the sf.Card table. The procedure requires a primary key to locate the record to update.
Additional parameters are provided for all columns in the vCard entity view, however, the base logic of the procedure
updates the columns of the table only. Table-specific logic can be added through tagged sections (pre and post update) and a call
to an extended procedure supports client-specific logic. Logic implemented within code tags (table-specific logic) is part of the
base product and applies to all client configurations. Calls to the extended procedure occur immediately after the table-specific
logic in both "pre-update" and "post-update" contexts.  A transaction is used to commit/rollback all changes as a logical unit.

Client specific customizations must be implemented in the ext.pCard procedure. The extended procedure is only called
where it exists in the DB. The first parameter passed @Mode is set to either "update.pre" or "update.post" to provide context for
the extended logic.

The @zContext parameter is an additional construct available to support overrides where different results are produced based on
content provided in the XML from the client tier. This parameter may contain multiple values.

The "@IsReselected" parameter controls output and "@IsNullApplied" controls whether or not parameters with null values overwrite
corresponding columns on the row.

For client-tier calls using the Microsoft Entity Framework and RIA Services, the @IsReselected bit should be passed as 1 to
force re-selection of table columns + extended view columns (the entity view).

Values for parameters representing mandatory columns must be provided unless @IsNullApplied is passed as 0. If @IsNullApplied = 1
any parameter with a null value overwrites the corresponding column value with null.  @IsNullApplied defaults to 0 but should be
passed as 1 when calling through the entity framework domain service since all columns are mapped to the procedure.

If the @UpdateUser parameter is passed as the special value "SystemUser", then the system user established in sf.ConfigParam
is applied. This option is useful for conversion and system generated updates the user would not recognize as having caused. Any
other value provided for the parameter (including null) is overwritten with the current application user.

The @RowStamp parameter should always be passed when calling from the user interface. The @RowStamp parameter is used to
preemptively check for an overwrite.  The value should be passed as the RowStamp value from the row when it was last
retrieved into the UI. If the RowStamp on the record changes from the value passed, this procedure will raise an exception and
avoid the overwrite.  For calls from back-end procedures, the @RowStamp parameter can be left blank and it will default to the
current time stamp on the record (avoiding the need to look up the value prior to calling.)

Business rule compliance is checked through a table constraint which calls fCardCheck to test all rules.

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

		-- check parameters

		if @CardSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@CardSID'

			raiserror(@errorText, 18, 1)
		end

		-- remove leading and trailing spaces from character type columns

		set @CardLabel = ltrim(rtrim(@CardLabel))
		set @CardContext = ltrim(rtrim(@CardContext))
		set @CSSDefinition = ltrim(rtrim(@CSSDefinition))
		set @SummaryCardDefinition = ltrim(rtrim(@SummaryCardDefinition))
		set @DetailCardDefinition = ltrim(rtrim(@DetailCardDefinition))
		set @HeaderDefinition = ltrim(rtrim(@HeaderDefinition))
		set @FooterDefinition = ltrim(rtrim(@FooterDefinition))
		set @GridRowDefinition = ltrim(rtrim(@GridRowDefinition))
		set @CardHelp = ltrim(rtrim(@CardHelp))
		set @CardXID = ltrim(rtrim(@CardXID))
		set @LegacyKey = ltrim(rtrim(@LegacyKey))
		set @UpdateUser = ltrim(rtrim(@UpdateUser))
		set @CardTypeSCD = ltrim(rtrim(@CardTypeSCD))
		set @CardTypeLabel = ltrim(rtrim(@CardTypeLabel))

		-- set zero length strings to null to avoid storing them in the record

		if len(@CardLabel) = 0 set @CardLabel = null
		if len(@CardContext) = 0 set @CardContext = null
		if len(@CSSDefinition) = 0 set @CSSDefinition = null
		if len(@SummaryCardDefinition) = 0 set @SummaryCardDefinition = null
		if len(@DetailCardDefinition) = 0 set @DetailCardDefinition = null
		if len(@HeaderDefinition) = 0 set @HeaderDefinition = null
		if len(@FooterDefinition) = 0 set @FooterDefinition = null
		if len(@GridRowDefinition) = 0 set @GridRowDefinition = null
		if len(@CardHelp) = 0 set @CardHelp = null
		if len(@CardXID) = 0 set @CardXID = null
		if len(@LegacyKey) = 0 set @LegacyKey = null
		if len(@UpdateUser) = 0 set @UpdateUser = null
		if len(@CardTypeSCD) = 0 set @CardTypeSCD = null
		if len(@CardTypeLabel) = 0 set @CardTypeLabel = null

		-- set the ID of the user

		if isnull(@UpdateUser, 'x') = N'SystemUser' set @UpdateUser = left(sf.fConfigParam#Value('SystemUser'),75)-- override for "SystemUser"
		if isnull(@UpdateUser, 'x') <> N'SystemUser' set @UpdateUser = sf.fApplicationUserSession#UserName()			-- application user - or DB user if no application session set

		-- avoid overwriting with null parameter values (unless specified)
		-- by retrieving existing values from the entity row for blank parameters

		if @IsNullApplied = 0
		begin

			select
				 @CardTypeSID           = isnull(@CardTypeSID,card.CardTypeSID)
				,@CardLabel             = isnull(@CardLabel,card.CardLabel)
				,@CardContext           = isnull(@CardContext,card.CardContext)
				,@CSSDefinition         = isnull(@CSSDefinition,card.CSSDefinition)
				,@SummaryCardDefinition = isnull(@SummaryCardDefinition,card.SummaryCardDefinition)
				,@DetailCardDefinition  = isnull(@DetailCardDefinition,card.DetailCardDefinition)
				,@HeaderDefinition      = isnull(@HeaderDefinition,card.HeaderDefinition)
				,@FooterDefinition      = isnull(@FooterDefinition,card.FooterDefinition)
				,@GridRowDefinition     = isnull(@GridRowDefinition,card.GridRowDefinition)
				,@IsActive              = isnull(@IsActive,card.IsActive)
				,@CardHelp              = isnull(@CardHelp,card.CardHelp)
				,@UserDefinedColumns    = isnull(@UserDefinedColumns,card.UserDefinedColumns)
				,@CardXID               = isnull(@CardXID,card.CardXID)
				,@LegacyKey             = isnull(@LegacyKey,card.LegacyKey)
				,@UpdateUser            = isnull(@UpdateUser,card.UpdateUser)
				,@IsReselected          = isnull(@IsReselected,card.IsReselected)
				,@IsNullApplied         = isnull(@IsNullApplied,card.IsNullApplied)
				,@zContext              = isnull(@zContext,card.zContext)
				,@CardTypeSCD           = isnull(@CardTypeSCD,card.CardTypeSCD)
				,@CardTypeLabel         = isnull(@CardTypeLabel,card.CardTypeLabel)
				,@CardTypeRowGUID       = isnull(@CardTypeRowGUID,card.CardTypeRowGUID)
				,@IsDeleteEnabled       = isnull(@IsDeleteEnabled,card.IsDeleteEnabled)
			from
				sf.vCard card
			where
				card.CardSID = @CardSID

		end
		
		-- look up the FK value matching the system code if set; this allows
		-- FK values value to be set/updated based on system code values
		
		if @CardTypeSCD is not null and @CardTypeSID = (select x.CardTypeSID from sf.Card x where x.CardSID = @CardSID)
		begin
		
			select
				@CardTypeSID = x.CardTypeSID
			from
				sf.CardType x
			where
				x.CardTypeSCD = @CardTypeSCD
		
		end

		-- apply the table-specific pre-update logic (if any)

		--! <PreUpdate>
		--  insert pre-update logic here ...
		--! </PreUpdate>

		-- update the record

		update
			sf.Card
		set
			 CardTypeSID = @CardTypeSID
			,CardLabel = @CardLabel
			,CardContext = @CardContext
			,CSSDefinition = @CSSDefinition
			,SummaryCardDefinition = @SummaryCardDefinition
			,DetailCardDefinition = @DetailCardDefinition
			,HeaderDefinition = @HeaderDefinition
			,FooterDefinition = @FooterDefinition
			,GridRowDefinition = @GridRowDefinition
			,IsActive = @IsActive
			,CardHelp = @CardHelp
			,UserDefinedColumns = @UserDefinedColumns
			,CardXID = @CardXID
			,LegacyKey = @LegacyKey
			,UpdateUser = @UpdateUser
			,UpdateTime = sysdatetimeoffset()
		where
			CardSID = @CardSID
			and
			RowStamp = isnull(@RowStamp, RowStamp)

		set @rowsAffected = @@rowcount

		-- check for errors

		if @rowsAffected = 0
		begin
			
			if exists (select 1 from sf.Card where CardSID = @cardSID)
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'UpdateBlocked'
					,@MessageText = @errorText output
					,@DefaultText = N'A change was made to the "%1" record since it was last retrieved. The overwrite was avoided. Refresh the record and try again.'
					,@Arg1        = 'sf.Card'
				
				raiserror(@errorText, 16, 1)
			end
			else
			begin
				
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'sf.Card'
					,@Arg2        = @cardSID
				
				raiserror(@errorText, 18, 1)
			end

		end
		else if @rowsAffected <> 1
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RowCountUnexpected'
				,@MessageText = @errorText output
				,@DefaultText = N'The %1 operation on table "%2" affected an unexpected number of rows (%3). Record ID = %4.'
				,@Arg1        = 'update'
				,@Arg2        = 'sf.Card'
				,@Arg3        = @rowsAffected
				,@Arg4        = @cardSID
			
			raiserror(@errorText, 18, 1)
		end

		-- apply the table-specific post-update logic (if any)

		--! <PostUpdate>
		--  insert post-update logic here ...
		--! </PostUpdate>

		if @trancount = 0 and xact_state() = 1 commit transaction

		-- return all columns for entity (1), just the PK value (2), or no returned value (0)

		if @IsReselected = 2
		begin

			select
				 ent.CardSID
			from
				sf.vCard ent
			where
				ent.CardSID = @CardSID

		end
		else if @IsReselected = 1
		begin

			select
				 ent.CardSID
				,ent.CardTypeSID
				,ent.CardLabel
				,ent.CardContext
				,ent.CSSDefinition
				,ent.SummaryCardDefinition
				,ent.DetailCardDefinition
				,ent.HeaderDefinition
				,ent.FooterDefinition
				,ent.GridRowDefinition
				,ent.IsActive
				,ent.CardHelp
				,ent.UserDefinedColumns
				,ent.CardXID
				,ent.LegacyKey
				,ent.IsDeleted
				,ent.CreateUser
				,ent.CreateTime
				,ent.UpdateUser
				,ent.UpdateTime
				,ent.RowGUID
				,ent.RowStamp
				,ent.CardTypeSCD
				,ent.CardTypeLabel
				,ent.CardTypeRowGUID
				,ent.IsDeleteEnabled
				,ent.IsReselected
				,ent.IsNullApplied
				,ent.zContext
			from
				sf.vCard ent
			where
				ent.CardSID = @CardSID

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
