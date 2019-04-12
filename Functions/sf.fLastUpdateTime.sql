SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fLastUpdateTime]
(
	 @UpdateTimeOffset1			datetimeoffset(7)
	,@UpdateTimeOffset2			datetimeoffset(7)
	,@UpdateTimeOffset3			datetimeoffset(7)
) returns datetimeoffset(7)
as
begin

	declare
		@lastUpdateTime				datetimeoffset(7)


	select 
		@lastUpdateTime = max(value) 
	from 
		(
			values
				 (@UpdateTimeOffset1)
				,(@UpdateTimeOffset2)
				,(@UpdateTimeOffset3)
		) as tbl(value)

	return(@lastUpdateTime)
end
GO
