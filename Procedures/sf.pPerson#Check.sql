SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pPerson#Check]
	 @PersonSID              int
	,@GenderSID              int
	,@NamePrefixSID          int
	,@FirstName              nvarchar(30)
	,@CommonName             nvarchar(30)
	,@MiddleNames            nvarchar(30)
	,@LastName               nvarchar(35)
	,@BirthDate              date
	,@DeathDate              date
	,@HomePhone              varchar(25)
	,@MobilePhone            varchar(25)
	,@IsTextMessagingEnabled bit
	,@ImportBatch            nvarchar(100)
	,@PersonXID              varchar(150)
	,@LegacyKey              nvarchar(50)
	,@IsDeleted              bit
	,@CreateUser             nvarchar(75)
	,@CreateTime             datetimeoffset(7)
	,@UpdateUser             nvarchar(75)
	,@UpdateTime             datetimeoffset(7)
	,@RowGUID                uniqueidentifier
as
/*********************************************************************************************************************************
ScalarF : sf.pPerson#Check
Notice  : Copyright © 2014 Softworks Group Inc.
Summary : Executes the fPerson#Check validation function and raises formatted exception text on error
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Tim Edlund
Version : November 2012
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------

The procedure is a wrapper for the record validation function sf.fPerson#Check.  The procedure allows values entered on
UI forms to be validated before they are committed to the database.  This is useful in wizard-style UI's where records may not
be submitted to the database until several pages have been filled out by the user.  The validation needs to be run before the
end of the wizard or the user may lose input added if errors are discovered on insert/update. 

The procedure requires that all columns of the table be passed in.  The procedure does not accept entity columns that are not
part of the table.  All table columns are required because check functions can be extended.  Any table column may ultimately
become involved in a validation operation. Any column can be passed as NULL without error. 

MAINTENANCE NOTE - this procedure requires updating whenever the structure of sf.Person is changed!  Copy parameters for the
call syntax and function call from sf.fPerson#Check.

-------------------------------------------------------------------------------------------------------------------------------- */

set nocount on

begin

	declare
		 @errorNo															int = 0													-- 0 no error, <50000 SQL error, else business rule
		,@isValid															bit															-- set to 1 if values are valid

	begin try

		set @HomePhone		= sf.fFormatPhone(@HomePhone)
		set @MobilePhone	= sf.fFormatPhone(@MobilePhone)

		set @isValid = sf.fPerson#Check
		(
			 @PersonSID          
			,@GenderSID             
			,@NamePrefixSID         
			,@FirstName             
			,@CommonName            
			,@MiddleNames           
			,@LastName              
			,@BirthDate             
			,@DeathDate             
			,@HomePhone             
			,@MobilePhone           
			,@IsTextMessagingEnabled       
			,@ImportBatch           
			,@PersonXID             
			,@LegacyKey             
			,@IsDeleted             
			,@CreateUser            
			,@CreateTime            
			,@UpdateUser            
			,@UpdateTime            
			,@RowGUID               
		)

	end try

	begin catch
		exec @errorNo = sf.pErrorRethrow																			-- catch the error, parse and re-raise it
	end catch

	return(@errorNo)

end
GO
