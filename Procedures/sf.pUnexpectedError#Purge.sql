SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pUnexpectedError#Purge]
	@CutOffDate		 date = null	-- date before which errors are deleted from the table (default is to retain previous 3 months)
 ,@ReturnDataSet bit	= 0			-- when 1 then number of records deleted is returned as single row and column dataset
as
/*********************************************************************************************************************************
Sproc    : Unexpected Error - Purge
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : This procedure deletes records from the sf.UnexpectedError table created before the cutoff date
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)				| Month Year | Change Summary
				 : ---------------- | -----------|----------------------------------------------------------------------------------------
				 : Tim Edlund				| Oct 2017 	 | Initial version.
----------------------------------------------------------------------------------------------------------------------------------
 
Comments
--------
This procedure can be run from the UI or as an unattended batch process (scheduled monthly) to delete records from the 
sf.UnexpectedError table. This table can grow in size to the point where it is difficult to search and analyze - particularly 
over implementation periods when error rates are higher.  

The procedure accepts a cutoff date to use in selecting records to purge.  Any records with a create time before the cut off
date are deleted.  If @CutOffDate is not provided, then it defaults to retain the last 3 months of data. 

Call Syntax
-----------
select count(1) RecordCount from sf.UnexpectedError
exec sf.pUnexpectedError#Purge
select count(1) RecordCount from sf.UnexpectedError

------------------------------------------------------------------------------------------------------------------------------- */
set nocount on;

begin
	declare
		@errorNo				int						= 0								-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText			nvarchar(4000)									-- message text for business rule errors
	 ,@blankParm			varchar(50)											-- tracks name of any required parameter not passed
	 ,@ON							bit						= cast(1 as bit)	-- constant for bit comparisons = 1
	 ,@OFF						bit						= cast(0 as bit)	-- constant for bit comparison = 0
	 ,@recordsDeleted int						= 0;							-- buffer for records deleted by the process

	begin try

		if @CutOffDate is null
			set @CutOffDate = dateadd(month, -3, sf.fToday());

		delete
		sf.UnexpectedError
		where
			CreateTime < @CutOffDate;

		set @recordsDeleted = @@rowcount;

		if @ReturnDataSet = @ON select @recordsDeleted RecordsDeleted

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
