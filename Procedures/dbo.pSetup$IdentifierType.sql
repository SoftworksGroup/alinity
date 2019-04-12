SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pSetup$IdentifierType
	@SetupUser nvarchar(75) -- user assigned to audit columns
 ,@Language	 char(2)			-- language to install for
 ,@Region		 varchar(10)	-- designator for locale to generate data for
as

/*********************************************************************************************************************************
Sproc    : Setup dbo.IdentifierType data
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : Updates dbo.IdentifierType table with starting values for the application
----------------------------------------------------------------------------------------------------------------------------------
History		: Author	  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Tim Edlund	| May 2018		|	Initial version
					: Tim Edlund	| Jun 2018		| Added OrgSID key with placeholder insert where required
					: Tim Edlund	| Aug 2018		| Added system type for Applicant numbers

Comments	
--------
This procedure establishes sample records in the dbo.IdentifierType for end users to work with on new configurations. The
records are only added if no records exist in the table.  The Identifier Type table is maintained by end users and may
contain any values and coding. 

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully.">
		<SQLScript>
		<![CDATA[

		exec dbo.pSetup$IdentifierType 
			 @SetupUser = N'system@softworksgroup.com'
			,@Language  = 'en'
			,@Region		= 'can'
	
		select * from dbo.IdentifierType

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$IdentifierType'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */
begin

	set nocount on;

	declare
		@errorNo						 int = 0							-- 0 no error, if < 50000 SQL error, else business rule
	 ,@ON									 bit = cast(1 as bit) -- constant to refer to "true" bit value
	 ,@OFF								 bit = cast(0 as bit) -- constant to refer to "false" bit value
	 ,@orgSID							 int									-- keys for inserting placeholder organization record
	 ,@citySID						 int									-- default city for adding of placeholder organization
	 ,@orgTypeSID					 int									-- key of default organization type for adding placeholder
	 ,@applicantNoTemplate varchar(50);					-- configuration parameter value defining format of applicant number

	begin try

		select @orgSID = o .OrgSID from dbo.Org o where o.OrgLabel = '[PLACEHOLDER]';
		select @orgTypeSID = ot .OrgTypeSID from dbo .OrgType ot where ot.IsDefault = @ON;

		if @orgSID is null
		begin

			select @citySID	 = c.CitySID from dbo.City c where c.IsDefault = 1; -- ensure a city will be assigned

			if @citySID is null
			begin
				select @citySID	 = min(c.CitySID) from dbo .City c;
			end;

			exec dbo.pOrg#Insert
				@OrgSID = @orgSID output
			 ,@OrgName = '[PLACEHOLDER]'
			 ,@OrgLabel = '[PLACEHOLDER]'
			 ,@OrgTypeSID = @orgTypeSID
			 ,@StreetAddress1 = N'Created for conversion/upgrade'
			 ,@StreetAddress2 = N'only. Update references then'
			 ,@StreetAddress3 = N'delete this record!'
			 ,@PostalCode = 'X0X 0X0'
			 ,@CitySID = @citySID	-- this insert is still dependent on a default RegionSID and OrgTypeSID!
			 ,@CreateUser = @SetupUser;

			print 'ok - [PLACEHOLDER] record inserted for dbo.Org';

		end;

		if not exists (select 1 from dbo .IdentifierType)
		begin

			insert
				dbo.IdentifierType
			(
				IdentifierCode
			 ,IdentifierTypeLabel
			 ,OrgSID
			 ,DisplayRank
			 ,EditMask
			 ,IsDefault
			 ,CreateUser
			 ,UpdateUser
			)
			values
			(
				'OTHER.LICENSE', 'Other Jurisdiction ID', @orgSID, 5, '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]', @ON, @SetupUser, @SetupUser
			);

		end;

		-- ensure an identifier type is defined for application numbers

		if not exists
		(
			select 1 from		dbo.IdentifierType it where it.IdentifierCode = 'S!APPLICANT'
		)
		begin

			insert
				dbo.IdentifierType
			(
				IdentifierCode
			 ,IdentifierTypeLabel
			 ,OrgSID
			 ,DisplayRank
			 ,EditMask
			 ,IsDefault
			 ,CreateUser
			 ,UpdateUser
			)
			values
			(
				'S!APPLICANT', 'Applicant Number', @orgSID, 5, '[0-9][0-9][0-9][0-9]', @OFF, @SetupUser, @SetupUser -- default format is updated below
			);

		end;

		-- update the edit mask for the applicant number
		-- based on the template stored in configuration (if any)

		set @applicantNoTemplate = cast(ltrim(rtrim(isnull(sf.fConfigParam#Value('ApplicantNoTemplate'), '[NONE]'))) as varchar(50));

		if @applicantNoTemplate not in ('NONE', '[NONE]')
		begin

			update
				dbo.IdentifierType
			set
				EditMask = replace(@applicantNoTemplate, '#', '[0-9]')
			 ,UpdateUser = @SetupUser
			 ,UpdateTime = sysdatetimeoffset()
			where
				IdentifierCode = 'S!APPLICANT';

		end;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);

end;
GO
