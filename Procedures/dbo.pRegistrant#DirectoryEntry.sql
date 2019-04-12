SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrant#DirectoryEntry]
	 @RowGUID					uniqueidentifier		= null -- row GUID (from person) of the registrant to retrieve 
	,@CardContext			varchar(25)					= null -- context in which the search is being invoked
as
/*********************************************************************************************************************************
Procedure : Registrant - Directory Entry
Notice    : Copyright © 2017 Softworks Group Inc.
Summary   : Gets a specific record from vRegistrant#DirectorEntry
History   : Author(s)   | Month Year  | Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Kris Dawson	| Feb 2018		| Initial version
          
Comments
--------
This procedure supports the public and private (member) directories on the client portal. This procedure returns all the data
from either the product DirectoryEntry view or a customized one in ext for a specific record. A different sproc than the search
procedure is used since the middle-tier only returns the data used in the search card template so an additional query is run
when a detail record is shown to get the data for that specific record (the detail template may specify different columns to
return to the front end).

Return type
---------------
This search procedure CANNOT be imported through EF since the return values of the procedure are customizable by providing an ext
version of the view used. This is to support configuration of the portal features.

Custom view requirements
------------------------
See the documentation in pRegistrant#DirectorySearch

Example:
--------
<TestHarness>
  <Test Name = "GetEntry" IsDefault ="true" Description="Gets a registrant by person SID.">
    <SQLScript>
      <![CDATA[

declare
	@rowGUID uniqueidentifier

select top 1
	@rowGUID = p.RowGUID
from
	sf.Person p
join
	dbo.Registrant r on p.PersonSID = r.PersonSID
order by
	newid()
				
exec dbo.pRegistrant#DirectoryEntry																					
	@RowGUID = @rowGUID

			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:03" ResultSet="1" />
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
		@ObjectName = 'dbo.pRegistrant#DirectoryEntry'
	,	@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */

set nocount on;

begin

	declare
		@errorNo								 int					 = 0							-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText							 nvarchar(4000)									-- message text (for business rule errors)
	 ,@ON											 bit					 = cast(1 as bit) -- used on bit comparisons to avoid multiple casts

	begin try

		if @RowGUID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@RowGUID'

			raiserror(@errorText, 18, 1)

		end		

		-- return all the columns in the view using *, as the view can be customized

		if @CardContext = 'public'
		begin

			if exists(select ObjectID from sf.vView where SchemaName = 'ext' and ViewName = 'vRegistrant#PublicDirectoryEntry')
			begin

				select
					de.*
				from
					ext.vRegistrant#PublicDirectoryEntry de
				where
					de.RowGUID = @RowGUID
				and
					de.IsOnPublicRegistry = @ON;										-- ensure they are marked as being on the public registry (controls both portals currently)

			end;
			else
			begin

				select
					de.*
				from
					dbo.vRegistrant#PublicDirectoryEntry de
				where
					de.RowGUID = @RowGUID
				and
					de.IsOnPublicRegistry = @ON;										-- ensure they are marked as being on the public registry (controls both portals currently)

			end;

		end
		else if @CardContext = 'member'
		begin

			if exists(select ObjectID from sf.vView where SchemaName = 'ext' and ViewName = 'vRegistrant#MemberDirectoryEntry')
			begin

				select
					de.*
				from
					ext.vRegistrant#MemberDirectoryEntry de
				where
					de.RowGUID = @RowGUID
				and
					de.IsOnPublicRegistry = @ON;										-- ensure they are marked as being on the public registry (controls both portals currently)

			end;
			else
			begin

				select
					de.*
				from
					dbo.vRegistrant#MemberDirectoryEntry de
				where
					de.RowGUID = @RowGUID
				and
					de.IsOnPublicRegistry = @ON;										-- ensure they are marked as being on the public registry (controls both portals currently)

			end

		end
		else if @CardContext = 'employer'
		begin

			if exists(select ObjectID from sf.vView where SchemaName = 'ext' and ViewName = 'vRegistrant#EmployerDirectoryEntry')
			begin

				select
					de.*
				from
					ext.vRegistrant#EmployerDirectoryEntry de
				where
					de.RowGUID = @RowGUID

			end;
			else
			begin

				select
					de.*
				from
					dbo.vRegistrant#EmployerDirectoryEntry de
				where
					de.RowGUID = @RowGUID

			end

		end;
		--else if @CardContext = 'advertise'
		--begin

		--	if exists(select ObjectID from sf.vView where SchemaName = 'ext' and ViewName = 'vRegistrant#AdvertiseDirectoryEntry')
		--	begin

		--		select
		--			de.*
		--		from
		--			ext.vRegistrant#AdvertiseDirectoryEntry de
		--		where
		--			de.RowGUID = @RowGUID

		--	end;
		--	else
		--	begin

		--		set @errorNo = 0 -- TODO Feb 2019 Cory: implement fully once prototype is approved by CDA

		--	end

		--end;
		

	end try

	begin catch
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);

end;
GO
