CREATE TYPE [dbo].[Parameter]
AS TABLE (
		[ID]                 [int] IDENTITY(1, 1) NOT NULL,
		[ParameterID]        [nvarchar](120) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[Label]              [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ParameterValue]     [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
