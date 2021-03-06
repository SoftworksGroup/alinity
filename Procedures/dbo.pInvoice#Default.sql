SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pInvoice#Default]
	 @zContext                    xml               = null                -- default values provided from client-tier (if any)
	,@SetFKDefaults               bit               = 0                   -- when 1, mandatory FK's are returned as -1 instead of NULL
as
/*********************************************************************************************************************************
Procedure : dbo.pInvoice#Default
Notice    : Copyright © 2019 Softworks Group Inc.
Summary   : provides a blank row with default values for presentation in the UI for "new" dbo.Invoice records
-----------------------------------------------------------------------------------------------------------------------------------
Author    : Generated by DB Studio: pSprocGen | Designer: Tim Edlund
Version   : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure is used in maintenance of the dbo.Invoice table. When a new record is to be added from the UI, this procedure
is called to return a blank record with default values. If the client-tier is providing the context for the insert, such as a parent
key value for the new record, it must be passed in the @zContext XML parameter. Multiple values may be passed. The standard format
is: <Parameters MyParameter="1000001"/>.

The @SetFKDefaults parameter can be set to 1 to cause the procedure to return mandatory FK values as -1 rather than NULL. This avoids
the need to create complex types for the procedure on architectures which are not using RIA services.

Note that default values for text, ntext and binary type columns is not supported.  These data types are not permitted as local
variables in the current version of SQL Server and should be replaced by varchar(max) and nvarchar(max) where possible.

Some default values are built-in to the shell of the sproc.  The base table column defaults set in the variable declarations below
were obtained from database default constraints which existed at the time the procedure was generated. The declarations include all
columns of the vInvoice entity view, however, only some values (as noted above) are eligible for default setting.  The other
parameters are included for setting context for the table-specific or client-specific logic of the procedure (if any). Default values
returning a question mark "?", system date, or 0 are provided for non-base table columns which are mandatory.  This is done to avoid
compilation errors from the Entity Framework, however, the values will not be applied since they are not in the base table row.

Two levels of customization of the procedure shell are supported. Table-specific logic can be added through the tagged section and a
call to an extended procedure supports client-specific customization. Logic implemented within the code tags is part of the base
product and applies to all client configurations. Client-specific customizations must be implemented in the ext.pInvoice
procedure. The extended procedure is only called where it exists in database. The parameter "@Mode" is set to "default.pre" to
advise ext.pInvoice of the context of the call. All other parameters are also passed, however, only those parameters eligible
for default setting are passed for "output". All parameters corresponding to entity view columns are returned through a SELECT statement.

In order to simplify working with the XML parameter values, logic in the procedure parses the XML and assigns values to variables where
the variable name matches the column name in the XML (assumes single row).  The variables are then available to the table-specific and
client-specific logic.  The @zContext parameter is also passed, unmodified, to the extended procedure to support situations where values
are passed that are not mapped to column names.


-------------------------------------------------------------------------------------------------------------------------------- */

begin
	set nocount on

	declare
		 @errorNo                                      int = 0								-- 0 no error, <50000 SQL error, else business rule
		,@tranCount                                    int = @@trancount			-- determines whether a wrapping transaction exists
		,@sprocName                                    nvarchar(128) = object_name(@@procid)						-- name of currently executing procedure
		,@xState                                       int										-- error state detected in catch block
		,@ON                          bit = cast(1 as bit)										-- constant for bit comparisons
		,@OFF                         bit = cast(0 as bit)										-- constant for bit comparisons
		,@invoiceSID                  int               = -1									-- specific default required by EF - do not override
		,@personSID                   int               = null								-- no default provided from DB constraint - OK to override
		,@invoiceDate                 date              = sf.fToday()					-- default provided from DB constraint - OK to override
		,@tax1Label                   nvarchar(8)       = N'N/A'							-- default provided from DB constraint - OK to override
		,@tax1Rate                    decimal(4,4)      = (0.0)								-- default provided from DB constraint - OK to override
		,@tax1GLAccountCode           varchar(50)       = null								-- no default provided from DB constraint - OK to override
		,@tax2Label                   nvarchar(8)       = N'N/A'							-- default provided from DB constraint - OK to override
		,@tax2Rate                    decimal(4,4)      = (0.0)								-- default provided from DB constraint - OK to override
		,@tax2GLAccountCode           varchar(50)       = null								-- no default provided from DB constraint - OK to override
		,@tax3Label                   nvarchar(8)       = N'N/A'							-- default provided from DB constraint - OK to override
		,@tax3Rate                    decimal(4,4)      = (0.0)								-- default provided from DB constraint - OK to override
		,@tax3GLAccountCode           varchar(50)       = null								-- no default provided from DB constraint - OK to override
		,@registrationYear            smallint          = null								-- no default provided from DB constraint - OK to override
		,@cancelledTime               datetimeoffset(7) = null								-- no default provided from DB constraint - OK to override
		,@reasonSID                   int               = null								-- no default provided from DB constraint - OK to override
		,@isRefund                    bit               = CONVERT(bit,(0))		-- default provided from DB constraint - OK to override
		,@complaintSID                int               = null								-- no default provided from DB constraint - OK to override
		,@userDefinedColumns          xml               = null								-- no default provided from DB constraint - OK to override
		,@invoiceXID                  varchar(150)      = null								-- no default provided from DB constraint - OK to override
		,@legacyKey                   nvarchar(50)      = null								-- no default provided from DB constraint - OK to override
		,@isDeleted                   bit               = (0)									-- default provided from DB constraint - OK to override
		,@createUser                  nvarchar(75)      = suser_sname()				-- default value ignored (value set by UI)
		,@createTime                  datetimeoffset(7) = sysdatetimeoffset()	-- default value ignored (set to system time)
		,@updateUser                  nvarchar(75)      = suser_sname()				-- default value ignored (value set by UI)
		,@updateTime                  datetimeoffset(7) = sysdatetimeoffset()	-- default value ignored (set to system time)
		,@rowGUID                     uniqueidentifier  = newid()							-- default value ignored (value set by system)
		,@rowStamp                    timestamp         = null								-- default value ignored (value set by system)
		,@genderSID                   int               = 0										-- not a base table column (default ignored)
		,@namePrefixSID               int																			-- not a base table column (default ignored)
		,@firstName                   nvarchar(30)      = N'?'								-- not a base table column (default ignored)
		,@commonName                  nvarchar(30)														-- not a base table column (default ignored)
		,@middleNames                 nvarchar(30)														-- not a base table column (default ignored)
		,@lastName                    nvarchar(35)      = N'?'								-- not a base table column (default ignored)
		,@birthDate                   date																		-- not a base table column (default ignored)
		,@deathDate                   date																		-- not a base table column (default ignored)
		,@homePhone                   varchar(25)															-- not a base table column (default ignored)
		,@mobilePhone                 varchar(25)															-- not a base table column (default ignored)
		,@isTextMessagingEnabled      bit               = 0										-- not a base table column (default ignored)
		,@importBatch                 nvarchar(100)														-- not a base table column (default ignored)
		,@personRowGUID               uniqueidentifier  = newid()							-- not a base table column (default ignored)
		,@complaintNo                 varchar(50)															-- not a base table column (default ignored)
		,@registrantSID               int																			-- not a base table column (default ignored)
		,@complaintTypeSID            int																			-- not a base table column (default ignored)
		,@complainantTypeSID          int																			-- not a base table column (default ignored)
		,@applicationUserSID          int																			-- not a base table column (default ignored)
		,@openedDate                  date																		-- not a base table column (default ignored)
		,@conductStartDate            date																		-- not a base table column (default ignored)
		,@conductEndDate              date																		-- not a base table column (default ignored)
		,@complaintSeveritySID        int																			-- not a base table column (default ignored)
		,@isDisplayedOnPublicRegistry bit																			-- not a base table column (default ignored)
		,@closedDate                  date																		-- not a base table column (default ignored)
		,@dismissedDate               date																		-- not a base table column (default ignored)
		,@complaintReasonSID          int																			-- not a base table column (default ignored)
		,@fileExtension               varchar(5)															-- not a base table column (default ignored)
		,@complaintRowGUID            uniqueidentifier												-- not a base table column (default ignored)
		,@reasonGroupSID              int																			-- not a base table column (default ignored)
		,@reasonName                  nvarchar(50)														-- not a base table column (default ignored)
		,@reasonCode                  varchar(25)															-- not a base table column (default ignored)
		,@reasonSequence              smallint																-- not a base table column (default ignored)
		,@toolTip                     nvarchar(500)														-- not a base table column (default ignored)
		,@reasonIsActive              bit																			-- not a base table column (default ignored)
		,@reasonRowGUID               uniqueidentifier												-- not a base table column (default ignored)
		,@isDeleteEnabled             bit																			-- not a base table column (default ignored)
		,@isReselected                tinyint           = 1										-- specific default required by EF - do not override
		,@isNullApplied               bit               = 1										-- specific default required by EF - do not override
		,@invoiceLabel                nvarchar(4000)													-- not a base table column (default ignored)
		,@invoiceShortLabel           nvarchar(4000)													-- not a base table column (default ignored)
		,@totalBeforeTax              decimal(11,2)														-- not a base table column (default ignored)
		,@tax1Total                   decimal(11,2)														-- not a base table column (default ignored)
		,@tax2Total                   decimal(11,2)														-- not a base table column (default ignored)
		,@tax3Total                   decimal(11,2)														-- not a base table column (default ignored)
		,@totalAdjustment             decimal(11,2)														-- not a base table column (default ignored)
		,@totalAfterTax               decimal(11,2)														-- not a base table column (default ignored)
		,@totalPaid                   decimal(11,2)														-- not a base table column (default ignored)
		,@totalDue                    decimal(11,2)														-- not a base table column (default ignored)
		,@isUnPaid                    bit																			-- not a base table column (default ignored)
		,@isPaid                      bit																			-- not a base table column (default ignored)
		,@isOverPaid                  bit																			-- not a base table column (default ignored)
		,@isOverDue                   bit																			-- not a base table column (default ignored)
		,@tax1GLAccountLabel          nvarchar(35)														-- not a base table column (default ignored)
		,@tax1IsTaxAccount            bit																			-- not a base table column (default ignored)
		,@tax2GLAccountLabel          nvarchar(35)														-- not a base table column (default ignored)
		,@tax2IsTaxAccount            bit																			-- not a base table column (default ignored)
		,@tax3GLAccountLabel          nvarchar(35)														-- not a base table column (default ignored)
		,@tax3IsTaxAccount            bit																			-- not a base table column (default ignored)
		,@isDeferred                  bit																			-- not a base table column (default ignored)
		,@isCancelled                 bit																			-- not a base table column (default ignored)
		,@isEditEnabled               bit																			-- not a base table column (default ignored)
		,@isPAPSubscriber             bit																			-- not a base table column (default ignored)
		,@isPAPEnabled                bit																			-- not a base table column (default ignored)
		,@addressBlockForPrint        nvarchar(512)														-- not a base table column (default ignored)
		,@addressBlockForHTML         nvarchar(512)														-- not a base table column (default ignored)

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
		-- set mandatory FK values to -1 where requested
		
		if @SetFKDefaults = @ON
		begin
			set @personSID = -1
		end

		-- assign literal defaults passed through @zContext where
		-- provided otherwise leave database default in place
		
		select
			 @personSID          = isnull(context.node.value('@PersonSID'        ,'int'              ),@personSID)
			,@invoiceDate        = isnull(context.node.value('@InvoiceDate'      ,'date'             ),@invoiceDate)
			,@tax1Label          = isnull(context.node.value('@Tax1Label'        ,'nvarchar(8)'      ),@tax1Label)
			,@tax1Rate           = isnull(context.node.value('@Tax1Rate'         ,'decimal(4,4)'     ),@tax1Rate)
			,@tax1GLAccountCode  = isnull(context.node.value('@Tax1GLAccountCode','varchar(50)'      ),@tax1GLAccountCode)
			,@tax2Label          = isnull(context.node.value('@Tax2Label'        ,'nvarchar(8)'      ),@tax2Label)
			,@tax2Rate           = isnull(context.node.value('@Tax2Rate'         ,'decimal(4,4)'     ),@tax2Rate)
			,@tax2GLAccountCode  = isnull(context.node.value('@Tax2GLAccountCode','varchar(50)'      ),@tax2GLAccountCode)
			,@tax3Label          = isnull(context.node.value('@Tax3Label'        ,'nvarchar(8)'      ),@tax3Label)
			,@tax3Rate           = isnull(context.node.value('@Tax3Rate'         ,'decimal(4,4)'     ),@tax3Rate)
			,@tax3GLAccountCode  = isnull(context.node.value('@Tax3GLAccountCode','varchar(50)'      ),@tax3GLAccountCode)
			,@registrationYear   = isnull(context.node.value('@RegistrationYear' ,'smallint'         ),@registrationYear)
			,@cancelledTime      = isnull(context.node.value('@CancelledTime'    ,'datetimeoffset(7)'),@cancelledTime)
			,@reasonSID          = isnull(context.node.value('@ReasonSID'        ,'int'              ),@reasonSID)
			,@isRefund           = isnull(context.node.value('@IsRefund'         ,'bit'              ),@isRefund)
			,@complaintSID       = isnull(context.node.value('@ComplaintSID'     ,'int'              ),@complaintSID)
			,@invoiceXID         = isnull(context.node.value('@InvoiceXID'       ,'varchar(150)'     ),@invoiceXID)
			,@legacyKey          = isnull(context.node.value('@LegacyKey'        ,'nvarchar(50)'     ),@legacyKey)
		from
			@zContext.nodes('Parameters') as context(node)
		

		--! <Overrides>
		--  insert default value logic here ...
		--! </Overrides>
	
		-- call the extended version of the procedure (if it exists) for "default.pre" mode
		
		if exists
		(
			select
				1
			from
				sf.vRoutine r
			where
				r.SchemaName = 'ext'
			and
				r.RoutineName = 'pInvoice'
		)
		begin
		
			exec @errorNo = ext.pInvoice
				 @Mode                        = 'default.pre'
				,@InvoiceSID = @invoiceSID
				,@PersonSID = @personSID output
				,@InvoiceDate = @invoiceDate output
				,@Tax1Label = @tax1Label output
				,@Tax1Rate = @tax1Rate output
				,@Tax1GLAccountCode = @tax1GLAccountCode output
				,@Tax2Label = @tax2Label output
				,@Tax2Rate = @tax2Rate output
				,@Tax2GLAccountCode = @tax2GLAccountCode output
				,@Tax3Label = @tax3Label output
				,@Tax3Rate = @tax3Rate output
				,@Tax3GLAccountCode = @tax3GLAccountCode output
				,@RegistrationYear = @registrationYear output
				,@CancelledTime = @cancelledTime output
				,@ReasonSID = @reasonSID output
				,@IsRefund = @isRefund output
				,@ComplaintSID = @complaintSID output
				,@UserDefinedColumns = @userDefinedColumns output
				,@InvoiceXID = @invoiceXID output
				,@LegacyKey = @legacyKey output
				,@IsDeleted = @isDeleted
				,@CreateUser = @createUser
				,@CreateTime = @createTime
				,@UpdateUser = @updateUser
				,@UpdateTime = @updateTime
				,@RowGUID = @rowGUID
				,@RowStamp = @rowStamp
				,@GenderSID = @genderSID
				,@NamePrefixSID = @namePrefixSID
				,@FirstName = @firstName
				,@CommonName = @commonName
				,@MiddleNames = @middleNames
				,@LastName = @lastName
				,@BirthDate = @birthDate
				,@DeathDate = @deathDate
				,@HomePhone = @homePhone
				,@MobilePhone = @mobilePhone
				,@IsTextMessagingEnabled = @isTextMessagingEnabled
				,@ImportBatch = @importBatch
				,@PersonRowGUID = @personRowGUID
				,@ComplaintNo = @complaintNo
				,@RegistrantSID = @registrantSID
				,@ComplaintTypeSID = @complaintTypeSID
				,@ComplainantTypeSID = @complainantTypeSID
				,@ApplicationUserSID = @applicationUserSID
				,@OpenedDate = @openedDate
				,@ConductStartDate = @conductStartDate
				,@ConductEndDate = @conductEndDate
				,@ComplaintSeveritySID = @complaintSeveritySID
				,@IsDisplayedOnPublicRegistry = @isDisplayedOnPublicRegistry
				,@ClosedDate = @closedDate
				,@DismissedDate = @dismissedDate
				,@ComplaintReasonSID = @complaintReasonSID
				,@FileExtension = @fileExtension
				,@ComplaintRowGUID = @complaintRowGUID
				,@ReasonGroupSID = @reasonGroupSID
				,@ReasonName = @reasonName
				,@ReasonCode = @reasonCode
				,@ReasonSequence = @reasonSequence
				,@ToolTip = @toolTip
				,@ReasonIsActive = @reasonIsActive
				,@ReasonRowGUID = @reasonRowGUID
				,@IsDeleteEnabled = @isDeleteEnabled
				,@IsReselected = @isReselected
				,@IsNullApplied = @isNullApplied
				,@zContext = @zContext output
				,@InvoiceLabel = @invoiceLabel
				,@InvoiceShortLabel = @invoiceShortLabel
				,@TotalBeforeTax = @totalBeforeTax
				,@Tax1Total = @tax1Total
				,@Tax2Total = @tax2Total
				,@Tax3Total = @tax3Total
				,@TotalAdjustment = @totalAdjustment
				,@TotalAfterTax = @totalAfterTax
				,@TotalPaid = @totalPaid
				,@TotalDue = @totalDue
				,@IsUnPaid = @isUnPaid
				,@IsPaid = @isPaid
				,@IsOverPaid = @isOverPaid
				,@IsOverDue = @isOverDue
				,@Tax1GLAccountLabel = @tax1GLAccountLabel
				,@Tax1IsTaxAccount = @tax1IsTaxAccount
				,@Tax2GLAccountLabel = @tax2GLAccountLabel
				,@Tax2IsTaxAccount = @tax2IsTaxAccount
				,@Tax3GLAccountLabel = @tax3GLAccountLabel
				,@Tax3IsTaxAccount = @tax3IsTaxAccount
				,@IsDeferred = @isDeferred
				,@IsCancelled = @isCancelled
				,@IsEditEnabled = @isEditEnabled
				,@IsPAPSubscriber = @isPAPSubscriber
				,@IsPAPEnabled = @isPAPEnabled
				,@AddressBlockForPrint = @addressBlockForPrint
				,@AddressBlockForHTML = @addressBlockForHTML
		
		end

		select
			 @invoiceSID InvoiceSID
			,@personSID PersonSID
			,@invoiceDate InvoiceDate
			,@tax1Label Tax1Label
			,@tax1Rate Tax1Rate
			,@tax1GLAccountCode Tax1GLAccountCode
			,@tax2Label Tax2Label
			,@tax2Rate Tax2Rate
			,@tax2GLAccountCode Tax2GLAccountCode
			,@tax3Label Tax3Label
			,@tax3Rate Tax3Rate
			,@tax3GLAccountCode Tax3GLAccountCode
			,@registrationYear RegistrationYear
			,@cancelledTime CancelledTime
			,@reasonSID ReasonSID
			,@isRefund IsRefund
			,@complaintSID ComplaintSID
			,@userDefinedColumns UserDefinedColumns
			,@invoiceXID InvoiceXID
			,@legacyKey LegacyKey
			,@isDeleted IsDeleted
			,@createUser CreateUser
			,@createTime CreateTime
			,@updateUser UpdateUser
			,@updateTime UpdateTime
			,@rowGUID RowGUID
			,@rowStamp RowStamp
			,@genderSID GenderSID
			,@namePrefixSID NamePrefixSID
			,@firstName FirstName
			,@commonName CommonName
			,@middleNames MiddleNames
			,@lastName LastName
			,@birthDate BirthDate
			,@deathDate DeathDate
			,@homePhone HomePhone
			,@mobilePhone MobilePhone
			,@isTextMessagingEnabled IsTextMessagingEnabled
			,@importBatch ImportBatch
			,@personRowGUID PersonRowGUID
			,@complaintNo ComplaintNo
			,@registrantSID RegistrantSID
			,@complaintTypeSID ComplaintTypeSID
			,@complainantTypeSID ComplainantTypeSID
			,@applicationUserSID ApplicationUserSID
			,@openedDate OpenedDate
			,@conductStartDate ConductStartDate
			,@conductEndDate ConductEndDate
			,@complaintSeveritySID ComplaintSeveritySID
			,@isDisplayedOnPublicRegistry IsDisplayedOnPublicRegistry
			,@closedDate ClosedDate
			,@dismissedDate DismissedDate
			,@complaintReasonSID ComplaintReasonSID
			,@fileExtension FileExtension
			,@complaintRowGUID ComplaintRowGUID
			,@reasonGroupSID ReasonGroupSID
			,@reasonName ReasonName
			,@reasonCode ReasonCode
			,@reasonSequence ReasonSequence
			,@toolTip ToolTip
			,@reasonIsActive ReasonIsActive
			,@reasonRowGUID ReasonRowGUID
			,@isDeleteEnabled IsDeleteEnabled
			,@isReselected IsReselected
			,@isNullApplied IsNullApplied
			,@zContext zContext
			,@invoiceLabel InvoiceLabel
			,@invoiceShortLabel InvoiceShortLabel
			,@totalBeforeTax TotalBeforeTax
			,@tax1Total Tax1Total
			,@tax2Total Tax2Total
			,@tax3Total Tax3Total
			,@totalAdjustment TotalAdjustment
			,@totalAfterTax TotalAfterTax
			,@totalPaid TotalPaid
			,@totalDue TotalDue
			,@isUnPaid IsUnPaid
			,@isPaid IsPaid
			,@isOverPaid IsOverPaid
			,@isOverDue IsOverDue
			,@tax1GLAccountLabel Tax1GLAccountLabel
			,@tax1IsTaxAccount Tax1IsTaxAccount
			,@tax2GLAccountLabel Tax2GLAccountLabel
			,@tax2IsTaxAccount Tax2IsTaxAccount
			,@tax3GLAccountLabel Tax3GLAccountLabel
			,@tax3IsTaxAccount Tax3IsTaxAccount
			,@isDeferred IsDeferred
			,@isCancelled IsCancelled
			,@isEditEnabled IsEditEnabled
			,@isPAPSubscriber IsPAPSubscriber
			,@isPAPEnabled IsPAPEnabled
			,@addressBlockForPrint AddressBlockForPrint
			,@addressBlockForHTML AddressBlockForHTML

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
