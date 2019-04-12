CREATE SERVICE [JobSchedule]
	AUTHORIZATION [dbo]
	ON QUEUE [sf].[JobScheduleQ]
	([JobContract])
GO
