SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fIsPending]
(
	 @Effective														datetime													-- first datetime in range to check 
  ,@Expiry															datetime													-- last datetime in range to check
)
returns bit
as
/*********************************************************************************************************************************
ScalarF		: Is Pending 
Notice		: Copyright © 2014 Softworks Group Inc.
Summary		: Returns a bit indicating if the assignment/grant will come into effect in the future
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Tim Edlund	| Dec		2012	|	Initial version

Comments	
--------
This function is used to determine if grant/assignment records are "pending" - meaning that they are future dated and will
come into effect in the future.  This determination is largely addressed by checking if the @Effective time is greater
than the timezone adjusted time for the client. The one exception, however, is where a future dated grant/assignment
is expired. In that case the Effective and Expiry dates are set to the same value and even though the Effective is after
the current date, the grant will never come into effect and therefore is not pending.

if @Effective is null, then 0 (false) is returned

Example
-------

	select
		 sf.fNow()																														CurrentClientTime
		,aug.EffectiveTime
		,aug.ExpiryTime
		,sf.fIsPending(aug.EffectiveTime, aug.ExpiryTime) IsPending
	from
		sf.ApplicationUserGrant aug
	where
		aug.ApplicationUserGrantSID = 1000001

------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		 @isPending			bit = cast(0 as bit)                                  -- return value
    ,@now		        datetime = sf.fNow()																	-- current time adjusted for user timezone

  if @Effective > @now and @Effective <> isnull(@Expiry, @now) set @isPending = cast(1 as bit)

	return(@isPending)

end
GO
