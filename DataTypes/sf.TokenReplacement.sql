CREATE TYPE [sf].[TokenReplacement]
AS TABLE (
		[ID]        [int] IDENTITY(1, 1) NOT NULL,
		[Token]     [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[Value]     [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
