CREATE SERVICE [JobRequest]
	AUTHORIZATION [dbo]
	ON QUEUE [sf].[JobRequestQ]
	([JobContract])
GO
