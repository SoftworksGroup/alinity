SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pMSDescription#SetOnTable]
   @SchemaName                nvarchar(128) = N'dbo'                      -- schema where table is located - default = dbo
  ,@TableName                 nvarchar(128)                               -- table to set extended property on (required)
  ,@MSDescription             nvarchar(4000)                              -- descriptive text to set extended property to
as
/*********************************************************************************************************************************
Procedure	: Set MS_Description Property on Table
Notice		: Copyright © 2014 Softworks Group Inc. 
Summary		: Adds or updates an MS_Description extended property to the value provided
History		: Author(s)  	| Month Year			| Change Summary
					: ------------|-----------------|---------------------------------------------------------------------------------------
					: Tim Edlund	| June      2012  |	Initial version 
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------

This procedure is used in maintenance of database documentation.  The procedure calls sp_addExtendedProperty or 
sp_updateExtendedProperty based on whether or not an MS_Description property is already defined on the table. If it does exist
then it is updated. 

The function is included in the framework and not SGI Studio so that it can be applied to update documentation within production
databases (where SGI Studio may not be installed).  

Assistance to create and maintain table documentation is provided through a standard SGI Excel model where descriptions are 
entered on 1 tab of the model and the syntax is generated on the next.  At the time of this writing, the Excel model template 
could be found on the Corporate Portal (Developer Centre) under the name "Database Table Extended Properties.xls".

Example:
--------

exec sf.pMSDescription#SetOnTable
   @SchemaName    = 'stg'
  ,@TableName     = 'Channel'
  ,@MSDescription = 'Channel is a master table used in interface configuration. A Channel record is setup for each inbound '
                  + 'source, and, outbound destination of data to/from Synoptec™. These interface endpoints are referred to as '
                  + '“channels” within the product. Each Channel record is assigned a name value that must be unique and is the '
                  + 'basis for identifying the source or target channel of the message. For example, when an inbound message is '
                  + 'received by the interface engine (e.g. Iguana), the script processing the message looks up the source of '
                  + 'the message in the Channel table to obtain the “Channel SID (system ID)” value which is then written onto '
                  + 'the Channel Message record along with other content. This table is also applied in the user interface to '
                  + 'categorize inbound and outbound messages.';

------------------------------------------------------------------------------------------------------------------------------- */

set nocount on
																																																																			
begin  

	declare
		 @errorNo                           int = 0                           -- 0 no error, if < 50000 SQL error, else business rule
		,@errorText                         nvarchar(4000)                    -- message text (for business rule errors)
		
	begin try
	
		-- check parameters; ensure schema and table are valid

    if exists
    (
      select
        1
      from
        sf.vTable t
      where
        t.SchemaName = @SchemaName
      and
        t.TableName = @TableName
      and
        t.[Description] is not null
    )
    begin

      exec sys.sp_updateextendedproperty 
         @level0type  = N'SCHEMA'
        ,@level0name  = @SchemaName
        ,@level1type  = N'TABLE'
        ,@level1name  = @TableName
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
