SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pFormVersion#Publish]
	 @FormVersionSID              int                                       -- form revision to publish
	,@VersionNo                   smallint = null                           -- version number to publish revision as    
as
/*********************************************************************************************************************************
Procedure : Form Version - Publish
Notice    : Copyright © 2017 Softworks Group Inc.
Summary   : Publishes the revision as either a new version or reassign an existing version to a new revision
History   : Author(s)   | Month Year | Change Summary
					: ------------|------------|-----------------------------------------------------------------------------------------
					: Cory Ng     | Mar 2017   | Initial Version

TODO: Tim Apr 2017 - this could be a generic sproc in the framework using dynamic SQL to create an update statement for 
all tables containing a "FormVersionSID" column that are not in SF.
						
Comments
--------
This procedure publishes the form version either to a new version or on top of an existing version. Most of the logic to set
the published version number and update "overwritten" form versions is done in the update API procedure. This procedure runs
the update to the form version but also reassigns any existing tables currently using the form version to the new form version.

Updating the form definition for existing forms can cause issues and it is the configurator's responsibility to ensure they
want to update an existing version.


<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully.">
		<SQLScript>
		<![CDATA[
			
			declare
				 @formVersionSID  int

			begin tran

				select
					@formVersionSID = fv.FormVersionSID
				from
					 sf.FormVersion fv
				where
					fv.VersionNo = 0
				order by
					newid()

				exec dbo.pFormVersion#Publish
					@FormVersionSID = @formVersionSID

			rollback

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:03:00" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pFormVersion#Publish'
	,@DefaultTestOnly = 1

-------------------------------------------------------------------------------------------------------------------------------- */

set nocount on

begin

	declare
		 @errorNo                         int = 0                             -- 0 no error, <50000 SQL error, else business rule
		,@errorText                       nvarchar(4000)                      -- message text (for business rule errors)
		,@ON                              bit = cast(1 as bit)                -- used on bit comparisons to avoid multiple casts
		,@OFF                             bit = cast(0 as bit)                -- used on bit comparisons to avoid multiple casts
		,@formSID                         int                                 -- SID for the form of the revision
		,@previousFormVersionSID          int                                 -- form version record to replace
		,@updateUser											nvarchar(75)												-- capture user executing the procedure	

	begin try

		select
			 @formSID                 = fv.FormSID
			,@previousFormVersionSID  = pfv.FormVersionSID
		from
			sf.FormVersion fv
		left outer join
			sf.FormVersion pfv on fv.FormSID = pfv.FormSID and pfv.VersionNo = isnull(@VersionNo, -1)
		where
			fv.FormVersionSID = @FormVersionSID

		if @formSID is null																
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RecordNotFound'
				,@MessageText = @errorText output
				,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
				,@Arg1        = 'sf.FormVersion'
				,@Arg2        = @FormVersionSID

			raiserror(@errorText, 18, 1)

		end

		if @VersionNo is not null and @previousFormVersionSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RecordNotFound'
				,@MessageText = @errorText output
				,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
				,@Arg1        = 'sf.FormVersion'
				,@Arg2        = @VersionNo

			raiserror(@errorText, 18, 1)

		end

		exec sf.pFormVersion#Update
			 @FormVersionSID  = @FormVersionSID
			,@IsApproved      = @ON
			,@VersionNo       = @VersionNo

		if @previousFormVersionSID is not null
		begin

			set @updateUser = sf.fApplicationUserSession#UserName()							-- application user - or DB user if no application session set

			update 
				dbo.RegistrantApp
			set
				 FormVersionSID = @FormVersionSID
				,UpdateUser     = @updateUser
				,UpdateTime     = sysdatetimeoffset()
			where
				FormVersionSID = @previousFormVersionSID

			update 
				dbo.RegistrantAppReview
			set
				 FormVersionSID = @FormVersionSID
				,UpdateUser     = @updateUser
				,UpdateTime     = sysdatetimeoffset()
			where
				FormVersionSID = @previousFormVersionSID

		end
		
	end try

	begin catch
		exec @errorNo = sf.pErrorRethrow                                      -- catch the error, rollback if pending, and re-throw
	end catch

	return(@errorNo)

end
GO
