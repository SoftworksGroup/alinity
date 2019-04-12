SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sf.pImportFile#GetNext
as
/*********************************************************************************************************************************
Sproc    : Import File - Get Next
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : Returns next import file record to process (to push records into staging)
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Tim Edlund		| May 2018			| Initial version 
----------------------------------------------------------------------------------------------------------------------------------

Comments
--------
This procedure is called by the import service to return the next import to process.  The procedure is called by the service
perpetually to get imports whenever unprocessed imports are found.  Only the next (single import record is returned. When no 
records are available to process the middle tier waits for a rest-period (about a minute) before checking again.

To be eligible for selection the Import must be in a non-processed, non-failed status.  Retrieval occurs in priority order 
based on priority date (first-in, first-out). A maximum of 1 record is returned by this procedure.  The record set returned will 
be empty, 0 records, if no imports require processing.

When an import is found, its processed time is automatically set to the current time (db time). If any error is detected by the 
import service in sending the message, the service must write the message into the MessageText column and update the IsFailed
column to ON (1).

Calls during maintenance windows
--------------------------------
As the import service will be down during maintenance, there is no concern about checking for offline status.  Users will still
be able to queue imports while the import service is disabled/stopped.

Example:
--------
<TestHarness>
  <Test Name = "ExecStandard" IsDefault ="true" Description="Executes the function to return the next import (with ROLLBACK to avoid using up the record).">
    <SQLScript>
      <![CDATA[
begin transaction
exec sf.pImportFile#GetNext
rollback
]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="ExecutionTime" Value="00:00:02"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'sf.pImportFile#GetNext'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo		int					= 0								-- 0 no error, if < 50000 SQL error, else business rule
	 ,@updateUser nvarchar(75)									-- service ID requesting the import (for audit)
	 ,@ON					bit					= cast(1 as bit)	-- constant for bit comparison = 1
	 ,@OFF				bit					= cast(0 as bit); -- constant for bit comparison = 0

	declare @import table (ImportFileSID int not null);

	begin try

		-- set the ID of the user for audit field

-- SQL Prompt formatting off
		if isnull(@updateUser, 'x') = N'SystemUser' set @updateUser = left(sf.fConfigParam#Value('SystemUser'), 75); -- override for "SystemUser"
		if isnull(@updateUser, 'x') <> N'SystemUser' set @updateUser = sf.fApplicationUserSession#UserName(); -- application user - or DB user if no application session set
-- SQL Prompt formatting on

		-- avoid EF sproc to minimize potential for record lock
		-- from another service and to minimize response time

		update
			sf.ImportFile
		set
			LoadStartTime = sysdatetimeoffset()
		 ,UpdateTime = sysdatetimeoffset()
		 ,UpdateUser = @updateUser
		output
			inserted.ImportFileSID
		into @import
		where
			ImportFileSID =
		(
			select top (1)
				im.ImportFileSID
			from
				sf.ImportFile im
			where
				im.IsFailed = @OFF and im.LoadStartTime is null
			order by -- priority selection
				im.CreateTime
			 ,im.ImportFileSID
		);

		select
			im.ImportFileSID
		 ,im.ApplicationEntitySCD
		 ,ps.ProcessingStatusSID DefaultProcessingStatusSID
		 ,cast(',' as char(1))	 Delimiter
		 ,im.CreateUser
		from
			sf.vImportFile im
		join
			@import				 i on im.ImportFileSID = i.ImportFileSID
		cross apply
		(
			select top (1)
				ProcessingStatusSID
			from
				sf.ProcessingStatus
			where
				IsDefault = @ON
		)								 ps;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);

end;
GO
