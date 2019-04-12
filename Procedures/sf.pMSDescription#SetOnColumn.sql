SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pMSDescription#SetOnColumn]
   @SchemaName                nvarchar(128) = N'dbo'                      -- schema where table is located - default = dbo
  ,@TableName                 nvarchar(128)                               -- table to set extended property on (required)
  ,@ColumnName                nvarchar(128)                               -- column to set extended property on (required)
  ,@MSDescription             nvarchar(4000)                              -- descriptive text to set extended property to
as
/*********************************************************************************************************************************
Procedure	: Set MS_Description Property on table column
Notice		: Copyright © 2014 Softworks Group Inc. 
Summary		: Adds or updates an MS_Description extended property to the value provided
History		: Author(s)  	| Month Year			| Change Summary
					: ------------|-----------------|---------------------------------------------------------------------------------------
					: Tim Edlund	| June      2012  |	Initial version 
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------

This procedure is used in maintenance of database documentation.  The procedure calls sp_addExtendedProperty or 
sp_updateExtendedProperty based on whether or not an MS_Description property is already defined on the table column. If it does 
exist then it is updated. 

The procedure simplifies syntax but otherwise does not add functionality to the built-in system procedures.

The function is included in the framework and not SGI Studio so that it can be applied to update documentation within production
databases (where SGI Studio may not be installed).  

Assistance to create and maintain column documentation is provided through a standard SGI Excel model where descriptions are 
entered on 1 tab of the model and the syntax is generated on the next.  At the time of this writing, the Excel model template 
could be found on the Corporate Portal (Developer Centre) under the name "Database Column Extended Properties.xls".

Example:
--------

exec sf.pMSDescription#SetOnColumn
   @SchemaName    = 'stg'
  ,@TableName     = 'PatientCaseProvider'
  ,@ColumnName    = 'CreateTime'
  ,@MSDescription = 'Date and time this patient case provider record was created | System assigned. '
                  + 'Value includes time zone offset.';

------------------------------------------------------------------------------------------------------------------------------- */

set nocount on
																																																																			
begin  

	declare
		 @errorNo                           int = 0                           -- 0 no error, if < 50000 SQL error, else business rule
		,@errorText                         nvarchar(4000)                    -- message text (for business rule errors)
		
	begin try
	
		-- check parameters; ensure schema, table and column are valid

    if exists
    (
      select
        1
      from
        sf.vTableColumn tc
      where
        tc.SchemaName = @SchemaName
      and
        tc.TableName  = @TableName
      and
        tc.ColumnName = @ColumnName
      and
        tc.[Description] is not null
    )
    begin

      exec sys.sp_updateextendedproperty 
         @level0type  = N'SCHEMA'
        ,@level0name  = @SchemaName
        ,@level1type  = N'TABLE'
        ,@level1name  = @TableName
        ,@level2type  = N'COLUMN'
        ,@level2name = @ColumnName
        ,@name        = N'MS_Description'
        ,@value       = @MSDescription

    end
    else
    begin

      exec sys.sp_addextendedproperty 
         @level0type  = N'SCHEMA'
        ,@level0name  = @SchemaName
        ,@level1type  = N'TABLE'
        ,@level1name  = @TableName
        ,@level2type  = N'COLUMN'
        ,@level2name = @ColumnName
        ,@name        = N'MS_Description'
        ,@value       = @MSDescription

    end
        
	end try

	begin catch
		exec @errorNo     = sf.pErrorRethrow
	end catch

	return(@errorNo)

end
GO
