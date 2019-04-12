SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pOrgType#Merge
	@OrgTypeSIDFrom int			-- record key to unassign 
 ,@OrgTypeSIDTo	 int			-- replacement record key
 ,@ReturnSelect				 bit = 0	-- when 1 result (count) of updates are returned in a message (1 row dataset)
as
/*********************************************************************************************************************************
Sproc    : OrgType - Merge
Notice   : Copyright © 2019 Softworks Group Inc.
Summary  : Replaces assignments of one OrgType key value with another to support master table data clean-up
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Mar 2019		|	Initial version

Comments	
--------
This is a utility procedure called to replace the assignment of one Organization Type with another. The procedure is used when 
master table data requires clean-up.  After the "from" record key has been replaced by the "to" record key in all the affected
records, the from record can be deleted through the user interface.  

The procedure updates each target table with a single update.

Known Limitations
-----------------
This procedure does not call the main #Update procedure(s) on the affected tables to make the changes.  This avoids other processing
logic that may be configured to apply when Organization Type assignments are changed. In most cases application of additional logic is 
not desirable since the action is to correct data only. Also, completing the update through the EF sproc adds considerable time and 
since the procedure is called in foreground risk of timeout may increase. 

A transaction is not used to improve atomicity of the update since, in the event of a failure, the procedure can be retried and
any updates missed in the original call will be picked up.

Example
-------
<TestHarness>
  <Test Name = "Random" IsDefault ="true" Description="Executes the merge for records selected at random (changes are rolled back 
	after test).">
    <SQLScript>
      <![CDATA[
declare
	@fromSID						 int
 ,@toSID							 int
 ,@updateRequested		 nvarchar(200);

select top (1)
	@fromSID = x.OrgTypeSID
from
	dbo.OrgType x
order by
	newid();

select top (1)
	@toSID = x.OrgTypeSID
from
	dbo.OrgType x
where
	x.OrgTypeSID <> @fromSID
order by
	newid();

if @@rowcount = 0 or @fromSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	select
		@updateRequested = y.OrgTypeName + N' -> '
	from
		dbo.OrgType y
	where
		y.OrgTypeSID = @fromSID;

	select
		@updateRequested += y.OrgTypeName
	from
		dbo.OrgType y
	where
		y.OrgTypeSID = @toSID;

	select @updateRequested	 UpdateRequested;

	begin transaction;

	exec dbo.pOrgType#Merge
		@OrgTypeSIDFrom = @fromSID
	 ,@OrgTypeSIDTo = @toSID
	 ,@ReturnSelect = 1;

	rollback;

end;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:25"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pOrgType#Merge'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo					int							 = 0							-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText				nvarchar(4000)										-- message text for business rule errors
	 ,@ON								bit							 = cast(1 as bit) -- constant for bit comparisons = 1
	 ,@updateUser				nvarchar(75)											-- user account to record for audit of the update
	 ,@now							datetimeoffset(7)									-- current time at server (for update audit)
	 ,@fromLabel				nvarchar(65)											-- label/name of record being replaced
	 ,@toLabel					nvarchar(65)											-- label/name of replacement record
	 ,@resultMessage		nvarchar(4000)										-- summary of job result
	 ,@recordsProcessed int							 = 0;							-- records processed for a single entity 

	begin try

		-- ensure parameters are valid

		select @fromLabel = x.OrgTypeName from dbo.OrgType x where x.OrgTypeSID = @OrgTypeSIDFrom

		if @@rowcount = 0
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'ObjectNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 "%2" was not found.'
			 ,@Arg1 = 'dbo.OrgType'
			 ,@Arg2 = 'record';

			raiserror(@errorText, 18, 1);
		end;

		select @toLabel = x.OrgTypeName from dbo.OrgType x where x.OrgTypeSID = @OrgTypeSIDTo

		if @@rowcount = 0
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'ObjectNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 "%2" was not found.'
			 ,@Arg1 = 'dbo.OrgType'
			 ,@Arg2 = 'record';

			raiserror(@errorText, 18, 1);
		end;

		set @updateUser = sf.fApplicationUserSession#UserName(); -- application/DB user to assign to the update audit
		set @now = sysdatetimeoffset(); -- current time to assign to the update audit

		/* 
	 Tim Edlund | Feb 2019
   Execute statement below to generate UPDATE syntax for affected tables
	 when creating or updating this procedure.  Insert the syntax below
	 this comment and reformat.

		select
			kcu.TABLE_SCHEMA
		 ,kcu.TABLE_NAME
		 ,fk.FKConstraintName
		 ,kcu.COLUMN_NAME
		 ,N'update ' + kcu.TABLE_SCHEMA + '.' + kcu.TABLE_NAME + ' set ' + kcu.COLUMN_NAME + ' = @' + kcu.COLUMN_NAME + 'To'
			+ ',UpdateUser = @updateUser ,UpdateTime = @now where ' + kcu.COLUMN_NAME + ' = @' + kcu.COLUMN_NAME + 'From' + char(13) + char(10) + char(13) + char(10)
			+ 'set @recordsProcessed += @@rowcount;' UpdateSQL
		from
			sf.vForeignKey											fk
		join
			INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu on fk.FKSchemaName = kcu.TABLE_SCHEMA and fk.FKConstraintName = kcu.CONSTRAINT_NAME
		where
			kcu.COLUMN_NAME = 'OrgTypeSID'; 
		*/

		update
			dbo.Org
		set
			OrgTypeSID = @OrgTypeSIDTo
		 ,UpdateUser = @updateUser
		 ,UpdateTime = @now
		where
			OrgTypeSID = @OrgTypeSIDFrom;

		set @recordsProcessed += @@rowcount;

		if @ReturnSelect = @ON
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordsUpdated'
			 ,@MessageText = @resultMessage output
			 ,@DefaultText = N'%1 %2 assignment(s) updated from "%3" to "%4".'
			 ,@Arg1 = @recordsProcessed
			 ,@Arg2 = 'Organization Type'
			 ,@Arg3 = @fromLabel
			 ,@Arg4 = @toLabel

			select @resultMessage	 ResultMessage;
		end;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
