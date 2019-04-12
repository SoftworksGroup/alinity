CREATE TYPE [dbo].[LatestRegistration]
AS TABLE (
		[RegistrationSID]     [int] NOT NULL,
		[RegistrantSID]       [int] NOT NULL,
	PRIMARY KEY CLUSTERED 
(
	[RegistrationSID]
)
WITH (IGNORE_DUP_KEY = OFF)
)
GO
