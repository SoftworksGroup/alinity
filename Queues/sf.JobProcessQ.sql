CREATE QUEUE [sf].[JobProcessQ]
	WITH
		STATUS = ON,
		RETENTION = OFF,
		ACTIVATION (
			STATUS = ON,
			PROCEDURE_NAME = [sf].[pJob#Receive],
			MAX_QUEUE_READERS = 25,
			EXECUTE AS OWNER
			),
		POISON_MESSAGE_HANDLING (STATUS = ON)
ON [ApplicationRowData]
GO
