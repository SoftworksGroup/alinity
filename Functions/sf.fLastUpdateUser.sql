SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [sf].[fLastUpdateUser]
(
	 @UpdateTimeOffset1			datetimeoffset(7)
	,@UpdateUser1						nvarchar(75)
	,@UpdateTimeOffset2			datetimeoffset(7)
	,@UpdateUser2						nvarchar(75)
	,@UpdateTimeOffset3			datetimeoffset(7)
	,@UpdateUser3						nvarchar(75)
) returns nvarchar(75)
as
begin

	declare
		 @lastUpdateUser				nvarchar(75)
		,@lastUpdateTime				datetimeoffset(7)

	set @lastUpdateTime = sf.fLastUpdateTime(@UpdateTimeOffset1, @UpdateTimeOffset2, @UpdateTimeOffset3)

	set @lastUpdateUser = 
	(
		case
			when @lastUpdateTime = @UpdateTimeOffset1 then @UpdateUser1
			when @lastUpdateTime = @UpdateTimeOffset2 then @UpdateUser2
			when @lastUpdateTime = @UpdateTimeOffset3 then @UpdateUser3
		end
	)

	return(@lastUpdateUser)
end
GO
