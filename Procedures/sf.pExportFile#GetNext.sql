SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sf.pExportFile#GetNext
as
/*********************************************************************************************************************************
Sproc    : Export File - Get Next
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : Returns next export file record to process (to create export file for)
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Tim Edlund		| May 2018			| Initial version 
----------------------------------------------------------------------------------------------------------------------------------

Comments
--------
This procedure is called by the export service to return the next export to create.  The procedure is called by the middle tier
perpetually to send exports whenever unprocessed exports are found.  Only the next (single export record is returned. When no 
records are available to process the middle tier waits for a rest-period (about a minute) before checking again.

To be eligible for selection the Export must be in a non-processed, non-failed status.  Retrieval occurs in priority order 
based on priority date (first-in, first-out). A maximum of 1 record is returned by this procedure.  The record set returned will 
be empty, 0 records, if no exports require processing.

When an export is found, its processed time is automatically set to the current time (db time). If any error is detected by the 
export service in sending the message, the service must write the message into the MessageText column and update the IsFailed
column to ON (1).

Calls during maintenance windows
--------------------------------
As the export service will be down during maintenance, there is no concern about checking for offline status.  Users will still
be able to queue exports while the export service is disabled/stopped.

Example:
--------
<TestHarness>
  <Test Name = "ExecStandard" IsDefault ="true" Description="Executes the function to return the next export (with ROLLBACK to avoid using up the record).">
    <SQLScript>
      <![CDATA[
begin transaction
exec sf.pExportFile#GetNext
rollback
]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="ExecutionTime" Value="00:00:02"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'sf.pExportFile#GetNext'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo		int					= 0								-- 0 no error, if < 50000 SQL error, else business rule
	 ,@updateUser nvarchar(75)									-- service ID requesting the export (for audit)
	 ,@OFF				bit					= cast(0 as bit); -- constant for bit comparison = 0

	declare @export table (ExportFileSID int not null);

	begin try

		-- set the ID of the user for audit field

-- SQL Prompt formatting off
		if isnull(@updateUser, 'x') = N'SystemUser' set @updateUser = left(sf.fConfigParam#Value('SystemUser'), 75); -- override for "SystemUser"
		if isnull(@updateUser, 'x') <> N'SystemUser' set @updateUser = sf.fApplicationUserSession#UserName(); -- application user - or DB user if no application session set
-- SQL Prompt formatting on

		-- avoid EF sproc to minimize potential for record lock
		-- from another service and to minimize response time

		update
			sf.ExportFile
		set
			ProcessedTime = sysdatetimeoffset()
		 ,UpdateTime = sysdatetimeoffset()
		 ,UpdateUser = @updateUser
		output
			inserted.ExportFileSID
		into @export
		where
			ExportFileSID =
		(
			select top (1)
				ef.ExportFileSID
			from
				sf.vExportFile ef
			where
				ef.IsFailed = @OFF and ef.ProcessedTime is null
			order by -- priority selection
				ef.CreateTime
			 ,ef.ExportFileSID
		);

		select
			ef.ExportFileSID
		 ,ef.ExportSourceGUID
		 ,ef.FileFormatSCD
		 ,ef.ExportSpecification
		 ,ef.RowGUID
		from
			sf.vExportFile ef
		join
			@export				 ex on ef.ExportFileSID = ex.ExportFileSID;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);

end;
GO
