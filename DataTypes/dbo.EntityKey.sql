CREATE TYPE [dbo].[EntityKey]
AS TABLE (
		[EntitySID]     [int] NOT NULL,
	PRIMARY KEY CLUSTERED 
(
	[EntitySID]
)
WITH (IGNORE_DUP_KEY = OFF)
)
GO
