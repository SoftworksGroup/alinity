SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
create procedure dbo.pProfileUpdate#WithdrawBatch
	@ProfileUpdates xml					-- list of ProfileUpdateSID's to withdraw
 ,@ReasonSID			int = null	-- optional reason why the ProfileUpdate was withdrawn
 ,@AdminComments	xml = null	-- optional comments to expand on why the ProfileUpdate was withdrawn
as
/*********************************************************************************************************************************
Procedure : ProfileUpdate - Withdraw Batch
Notice    : Copyright © 2018 Softworks Group Inc.
Summary   : Sets batch of ProfileUpdates provided to a cancelled status
----------------------------------------------------------------------------------------------------------------------------------
History		: Author(s)  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Taylor N		| Apr 2019		|	Initial version

Comments	
--------
This procedure calls dbo.pProfileUpdate#Update with the @NewFormStatusSCD value set to 'WITHDRAWN' for the primary keys passed in 
the XML parameter.  The  procedure supports the multi-select mode in the UI where records are pinned and then the WITHDRAW action 
is applied against the set.

The procedure is applied most often to withdraw old ProfileUpdates at the end of the year which were opened but never completed.

Note that only profile updates without an associated parent form, and not in a final status, can be withdrawn. If either scenario 
is encountered, the procedure raises an error and no withdrawals are processed.

This list of records to process is identified using xml in the following format:

<ProfileUpdates>
		<ProfileUpdate SID="1000001" />
		<ProfileUpdate SID="1000011" />
		<ProfileUpdate SID="1000123" />
</ProfileUpdates>

If a single ProfileUpdate is being processed, the pProfileUpdate#Update procedure can be used.

@ReasonSID
----------
The @ReasonSID parameter is optional and may be passed by the caller to fill-in the ReasonSID on the resulting dbo.ProfileUpdate
record. This value is optional.

@AdminComments
----------
The @AdminComments parameter is optional and may be passed by the caller to fill-in the AdminComments on the resulting dbo.ProfileUpdate
record. This value is optional.

Example:
--------
<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully.">
		<SQLScript>
		<![CDATA[
	declare
			@ProfileUpdates xml
		,	@AdminComments 	xml = N'<Comments><Comment ReviewerDisplayName="TestHarness" Comments="Validating comments" /></Comments>'
		,	@ReasonSID 			int

	select
		@ReasonSID = r.ReasonSID
	from
		dbo.vReason r
	where
		r.ReasonCode = 'PRFLUPDT.WITHDRAWN.OTHER'

	set @ProfileUpdates = (
		select top (5)
			pu.ProfileUpdateSID as '@SID'
		from
			dbo.ProfileUpdate pu
		cross apply
			dbo.fProfileUpdate#CurrentStatus(pu.ProfileUpdateSID, -1) cs
		where
			cs.IsFinal = cast(0 as bit)
		and
			pu.ParentRowGUID is null
		order by
			newid()
		for xml path('ProfileUpdate'), root('ProfileUpdates')
	)

	exec dbo.pProfileUpdate#WithdrawBatch
			@ProfileUpdates = @ProfileUpdates
		,	@ReasonSID = @ReasonSID
		,	@AdminComments = @AdminComments

	select
		1
	from
		dbo.ProfileUpdate pu
	join
		@ProfileUpdates.nodes('/ProfileUpdates/ProfileUpdate') px(n) on pu.ProfileUpdateSID = px.n.value('@SID', 'int')
	cross apply
		dbo.fProfileUpdate#CurrentStatus(pu.ProfileUpdateSID, -1) cs
	where
		cs.FormStatusSCD = 'WITHDRAWN'
	and
		pu.ReasonSID = @ReasonSID
	and
		ac.n.value('@ReviewerDisplayName', 'varchar(max)') = 'TestHarness'
		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="5"/>
			<Assertion Type="ExecutionTime" Value="00:00:15" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pProfileUpdate#WithdrawBatch'
	,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */
begin
	set nocount on;

	declare
		@errorNo					int							= 0											-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText				nvarchar(4000)													-- message text (for business rule errors)
	 ,@tranCount				int							= @@trancount						-- determines whether a wrapping transaction exists
	 ,@sprocName				nvarchar(128)		= object_name(@@procid) -- name of currently executing procedure
	 ,@xState						int																			-- error state detected in catch block
	 ,@blankParm				nvarchar(100)														-- error checking buffer for required parameters
	 ,@OFF							bit							= cast(0 as bit)				-- constant for bit comparisons = 0
	 ,@ON								bit							= cast(1 as bit)				-- constant for bit comparisons = 1
	 ,@i								int																			-- loop index
	 ,@maxRows					int																			-- loop limit
	 ,@parentRowGUID		uniqueidentifier												-- tracks if the current form has a parent
	 ,@statusIsFinal		bit																			-- tracks if the current form is already in a final status
	 ,@ProfileUpdateSID int;																		-- key of next ProfileUpdate record to assign

	declare @work table -- table of keys to process
	(ID int identity(1, 1), ProfileUpdateSID int not null);

	begin try

		-- check parameters
		if @ProfileUpdates is null
			set @blankParm = N'@ProfileUpdates';

		if @blankParm is not null
		begin
			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = @blankParm;

			raiserror(@errorText, 18, 1);
		end;

		insert
			@work -- parse XML key values into table for processing
		(ProfileUpdateSID)
		select
			ProfileUpdate.rc.value('@SID', 'int')
		from
			@ProfileUpdates.nodes('//ProfileUpdate') ProfileUpdate(rc);

		set @maxRows = @@rowcount;
		set @i = 0;

		if @maxRows = 0
		begin
			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = '@ProfileUpdates';

			raiserror(@errorText, 16, 1);
		end;

		-- use a transaction so that any additional updates implemented through the extended
		-- procedure or through table-specific logic succeed or fail as a logical unit
		if @tranCount = 0 -- no outer transaction
		begin
			begin transaction;
		end;
		else -- outer transaction so create save point
		begin
			save transaction @sprocName;
		end;

		while @i < @maxRows -- first proceed through each ProfileUpdate in the list passed
		begin
			set @i += 1;
			set @parentRowGUID = null;
			set @statusIsFinal = @OFF;

			select @ProfileUpdateSID = w .ProfileUpdateSID from @work w where w.ID = @i;

			select
				@ProfileUpdateSID = pu.ProfileUpdateSID
			 ,@parentRowGUID		= pu.ParentRowGUID
			 ,@statusIsFinal		= cs.IsFinal
			from
				@work																														w
			join
				dbo.ProfileUpdate																								pu on w.ProfileUpdateSID = pu.ProfileUpdateSID
			cross apply fProfileUpdate#CurrentStatus(pu.ProfileUpdateSID, -1) cs
			where
				w.ID = @i;

			if @@rowcount = 0
			begin
				exec sf.pMessage#Get
					@MessageSCD = 'RecordNotFound'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
				 ,@Arg1 = 'dbo.ProfileUpdate'
				 ,@Arg2 = @ProfileUpdateSID;

				raiserror(@errorText, 18, 1);
			end;
			else if @parentRowGUID is not null
			begin
				exec sf.pMessage#Get
					@MessageSCD = 'ProfileUpdateParentWithdraw'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The profile update (%1) cannot be withdrawn since a parent form relies on it. Please review the record and withdraw the parent form if necessary.'
				 ,@Arg1 = 'dbo.ProfileUpdate'
				 ,@Arg2 = @ProfileUpdateSID;

				raiserror(@errorText, 18, 1);
			end;
			else if @statusIsFinal = @ON
			begin
				exec sf.pMessage#Get
					@MessageSCD = 'ProfileUpdateIsFinal'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The profile update (%1) cannot be withdrawn since it is already in a final status.'
				 ,@Arg1 = 'dbo.ProfileUpdate'
				 ,@Arg2 = @ProfileUpdateSID;

				raiserror(@errorText, 18, 1);
			end;

			exec dbo.pProfileUpdate#Update
				@ProfileUpdateSID = @ProfileUpdateSID
			 ,@ReasonSID = @ReasonSID
			 ,@AdminComments = @AdminComments
			 ,@NewFormStatusSCD = 'WITHDRAWN';
		end;

		if @tranCount = 0 and xact_state() = 1 commit transaction;
	end try
	begin catch
		set @xState = xact_state();

		if @tranCount > 0 and @xState = 1
		begin
			rollback transaction @sprocName; -- committable wrapping trx exists: rollback to savepoint
		end;
		else if @xState <> 0 -- full rollback
		begin
			rollback;
		end;

		exec @errorNo = sf.pErrorRethrow; -- process message text and re-throw the error
	end catch;

	return (@errorNo);
end;
GO
