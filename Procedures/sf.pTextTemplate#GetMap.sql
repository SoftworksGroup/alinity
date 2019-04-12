SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pTextTemplate#GetMap] @TextTemplate nvarchar(max) -- template to create merge token mappings for
as
/*********************************************************************************************************************************
Sproc    : Text Template - Get Map
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : This procedure returns a table (data set) mapping the position of each merge token it contains
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)				| Month Year | Change Summary
				 : ---------------- | -----------|----------------------------------------------------------------------------------------
				 : Tim Edlund				| Oct 2017 	 | Initial version.
----------------------------------------------------------------------------------------------------------------------------------
 
Comments
--------
This procedure is used in processing replacement values in templates.  It is used primarily in processing emails where replacement
tokens are positioned in the template which must be replaced for each instance (person) the email is sent out for.  The procedure
returns a table which identifies each replacement value which exists in the template along with its starting and ending 
position in the string.  

Known Limitations
-----------------
At the time of this writing the starting and ending positions returned are used for debugging since the use of this table to 
make replacements in the source template is accomplished by the tsql "replace" command.  A change in algorightm is possible to
use the "stuff" command which is faster (about 30%) however this would require updating the starting and ending positions 
after each replacement to recalculate their values based on the length of replacements just made.

Call Syntax
-----------
declare @textTemplate nvarchar(max) = N'This is [@Test] #[@TextNo] of the template [@Parsing] routine.'

exec sf.pTextTemplate#GetMap 
	@TextTemplate = @textTemplate
------------------------------------------------------------------------------------------------------------------------------- */

begin
	
	set nocount on;

	declare
		@errorNo		int						= 0								-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText	nvarchar(4000)									-- message text for business rule errors
	 ,@blankParm	varchar(50)											-- tracks name of any required parameter not passed
	 ,@i					int															-- index position of start of next replacement value in the string
	 ,@j					int															-- index position of end of next replacement value in the string
	 ,@mergeToken varchar(131)										-- next merge token mapped - e.g. '[@MyToken]'
	 ,@tokenMap		sf.TokenMap;										-- output table structure

	begin try

		-- check parameters

		if @TextTemplate is null set @blankParm = '@TextTemplate';

		if @blankParm is not null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = @blankParm;

			raiserror(@errorText, 18, 1);
		end;

		set @i = charindex('[@', @TextTemplate);
		set @j = 1;

		while @i > 0 and @j > 0
		begin

			set @j = charindex(']', @TextTemplate, @i + 1);

			if @j > 0
			begin
				set @mergeToken = substring(@TextTemplate, @i, @j - @i + 1);

				insert
					@tokenMap (StartPosition, EndPosition, MergeToken)
				values (@i, @j, @mergeToken);

				set @i = charindex('[@', @TextTemplate, @j + 1);
			end;

		end;

		select
			tm.StartPosition
		 ,tm.EndPosition
		 ,tm.MergeToken
		from
			@tokenMap tm;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
