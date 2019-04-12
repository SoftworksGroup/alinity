CREATE SERVICE [JobProcess]
	AUTHORIZATION [dbo]
	ON QUEUE [sf].[JobProcessQ]
	([JobContract])
GO
