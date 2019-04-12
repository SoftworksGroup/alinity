SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fFormatString]
(
		@Format nvarchar(max)
		,@Parameters nvarchar(4000)
)
returns nvarchar(max)
as
/*********************************************************************************************************************************
ScalarF	: Mimics the functionality of string.format in c#
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: returns the formatted string.
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Christian T	| Oct 2012	    |	Initial Version
				:							|								|
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function works the same way as string.Format in c#. It allows value replacement for as many values as you need. 

DECLARE @msg NVARCHAR(4000)
SET  @msg = 'Hi {0}, Welcome to our site {1}. Thank you {0}'
SELECT @msg = sf.fFormatString(@msg, N'Christian,Softworks')
PRINT @msg
------------------------------------------------------------------------------------------------------------------------------- */

begin
	declare 
		@Message							nvarchar(max)
		,@Delimiter						char(1)
		
	declare 
		@ParamTable						table 
		( 
			ID									int									identity(0,1)
			,Parameter					varchar(1000) 
		)
		
	select 
		@Message = @Format
		,@Delimiter = ','
		
	;with CTE (StartPos, EndPos) as
	(
		select 
			1
			,charindex(@Delimiter, @Parameters)
		union all		
		select 
			EndPos + (len(@Delimiter))
			,charindex(@Delimiter,@Parameters, EndPos + (len(@Delimiter)))
		from 
			cte
		where 
			EndPos > 0
	)
	
	insert 
		@ParamTable 
	( 
		Parameter 
	)
	select
		[ID] = substring ( @Parameters, StartPos, case when EndPos > 0 then EndPos - StartPos else 4000 end )
	from 
		cte
		
	update 
		@ParamTable 
	set 
		@Message = replace ( @Message, '{'+convert(varchar,ID) + '}', Parameter )
	return 
		@Message

end
GO
