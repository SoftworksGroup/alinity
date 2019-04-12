CREATE QUEUE [sf].[JobScheduleQ]
	WITH
		STATUS = ON,
		RETENTION = OFF,
		ACTIVATION (
			STATUS = ON,
			PROCEDURE_NAME = [sf].[pJobSchedule#Read],
			MAX_QUEUE_READERS = 1,
			EXECUTE AS OWNER
			),
		POISON_MESSAGE_HANDLING (STATUS = ON)
ON [ApplicationRowData]
GO
