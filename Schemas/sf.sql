CREATE SCHEMA [sf]
	AUTHORIZATION [dbo]
GO
EXEC sp_addextendedproperty N'MS_Description', N'The Softworks Framework (SF) schema stores common database objects used across most products developed by Softworks Group Inc. The schema includes tables for storing user profile information, user session preferences, functional grants, tasks, queries and other common software feature support tables.  The schema also provides a framework library of functions and procedures used throughout the product.  The SF objects are maintained in a separate schema to simplify upgrades which may occur at different intervals that upgrades to objects in other schemas.  The SF schema does not store clinical data but does implement a base “Person” table which is inherited by Patient and Provider tables stored in the DBO schema.  Objects in the SF schema must not be modified by end users (product warranty condition).', 'SCHEMA', N'sf', NULL, NULL, NULL, NULL
GO
