SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vJobRequestQ]
as
/*********************************************************************************************************************************
View    : Job Request Q
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: Returns information about the sf.JobRequestQ service broker queue
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|---------------------------------------------------------------------------------------------
				: Tim Edlund	| Jun		2012	| Initial version

----------------------------------------------------------------------------------------------------------------------------------
Warning: This view is verified for SQL Server 2008 R2 only. Deployment on other versions may fail!
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This view returns information about the SQL Service Broker Queue "sf.JobRequestQ". The view reports status of messages including
the ConversationID that can be used to debug issues arising in job processing.  The view renames columns obtained from the queue
object in the dictionary.

Example
-------

select 
	 q.*
from
	sf.vJobRequestQ q
order by
	q.MessageSequence
------------------------------------------------------------------------------------------------------------------------------- */

select 
	 q.status										QStatus
	,q.priority									QPriority
	,q.queuing_order						QueuingOrder
	,q.conversation_group_id		ConversationGroupID
	,q.conversation_handle			ConversationID
	,q.message_sequence_number	MessageSequence
	,q.service_id								ServiceID
	,q.service_name							ServiceName
	,q.service_contract_id			ServiceContractID
	,q.service_contract_name		ServiceContractName
	,q.message_type_id					MessageTypeID
	,q.message_type_name				MessageTypeName
	,q.validation								QValidation
	,cast(message_body as XML)	MessageBody
from	
	sf.JobRequestQ q
GO
