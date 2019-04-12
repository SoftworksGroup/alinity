SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sf.pErrorRethrow$Log
	@ErrorNo			 int						-- 0 no error, if < 50000 SQL error, else business rule
 ,@ErrorProc		 nvarchar(128)	-- procedure where error occurred
 ,@ErrorLine		 int						-- line number where error occurred
 ,@ErrorSeverity int						-- 16 user error, 17 configuration, 18 programming, ...
 ,@ErrorState		 int						-- between 0 and 127 (MS has not documented these!)
 ,@MessageSCD		 varchar(128)		-- message code as found in sf.Message
 ,@MessageText	 nvarchar(4000) -- error message text  	
as
/*********************************************************************************************************************************
Sproc		: Error Log Insert
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: writes detail of error event into sf.UnexpectedError table
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund	| Apr		2010		|	Initial version
				:	Tim Edlund	|	Mar		2011		|	Updated documentation
				: Tim Edlund	| Nov		2011		| Updated target table from sf.ErrorLog to sf.UnexpectedError (name change only)
				: Tim Edlund	| July	2013		| Changed logic to swallow (ignore) errors from within the logging operation itself
				: Tim Edlund	| Oct		2017		| Added call to function to attempt to log end user name who experiences the error
				: Tim Edlund	| May		2018		| Replace exec() call with sp_executeSQL and minor formatting changes
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This subroutine logs information about errors to a table for debugging and follow-up. The procedure is called when the severity of 
the error encountered has reached the threshold for logging as set in the sf.ConfigParam table.  The threshold defaults to 17 
(configuration error or higher).  Program errors are severity 18.  

The procedure inserts the record by trapping output from the DBCC command which provides the syntax passed to the database to 
start the batch. This syntax is essentially the same syntax that would be trapped in a SQL Profiler trace.  The call to DBCC is 
made using dynamic SQL.  Once the record has been inserted, it is updated with the parameter values passed into the procedure.  
These parameters include the information passed into the error event are retrieved through the SQL "error_*" function set.  
Because the record is first inserted without the parameter values, the columns that contain these values are set to non-mandatory 
in the table design (and this cannot not be changed).

Example
-------

See parent procedure.

------------------------------------------------------------------------------------------------------------------------------- */
begin

	set nocount on;

	declare
	  @cmd								nvarchar(50)	-- dynamic SQL command buffer for DBCC call
	 ,@unexpectedErrorSID int						-- PK of row inserted
	 ,@userName						nvarchar(75); -- login ID of user experiencing the error

	begin try

		set @cmd = N'dbcc inputbuffer( ' + cast(@@spid as nvarchar(20)) + N')';
		set @userName = sf.fApplicationUserSession#UserName(); -- record the affected user where available

		insert -- insert call syntax into the row via DBCC call
			sf.UnexpectedError (CallEvent, CallParameter, CallSyntax)
		exec sp_executesql @stmt = @cmd;

		set @unexpectedErrorSID = scope_identity();

		update -- log entry created - update to add parameter values
			sf.UnexpectedError
		set
			MessageSCD = @MessageSCD	-- these columns must be nullable in table design!
		 ,ProcName = @ErrorProc
		 ,LineNumber = @ErrorLine
		 ,ErrorNumber = @ErrorNo
		 ,MessageText = @MessageText
		 ,ErrorSeverity = @ErrorSeverity
		 ,ErrorState = @ErrorState
		 ,SPIDNo = @@spid
		 ,MachineName = lower(host_name())
		 ,DBUser = lower(suser_sname())
		 ,CallEvent = ltrim(rtrim(lower(CallEvent)))
		 ,CallSyntax = ltrim(rtrim(CallSyntax))
		 ,CreateUser = @userName
		 ,UpdateUser = @userName
		where
			UnexpectedErrorSID = @unexpectedErrorSID;

	end try
	begin catch

		-- if an error occurs on the logging itself, ignore it to avoid
		-- overriding the original error from being reported

		set @unexpectedErrorSID = -1;

	end catch;

	return (0);

end;
GO
