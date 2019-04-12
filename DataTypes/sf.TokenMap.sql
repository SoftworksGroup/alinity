CREATE TYPE [sf].[TokenMap]
AS TABLE (
		[ID]                [int] IDENTITY(1, 1) NOT NULL,
		[StartPosition]     [int] NOT NULL,
		[EndPosition]       [int] NOT NULL,
		[MergeToken]        [varchar](131) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
)
GO
