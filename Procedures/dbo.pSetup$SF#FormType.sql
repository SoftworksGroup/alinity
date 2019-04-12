SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.[pSetup$SF#FormType]
	@SetupUser nvarchar(75) -- user assigned to audit columns
 ,@Language	 char(2)			-- language to install for
 ,@Region		 varchar(10)	-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup sf.FormType data
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : Updates the (sf) Form Type master table with starting values for the application
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Tim Edlund		| Mar		2017    | Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------
This procedure synchronizes the sf.FormType table with the settings required by the current version of the application. 
If a record is missing it is added. Where the record exists, it is set to current values. Form-Types no longer used are
deleted from the table. One MERGE statement is used to carryout all operations.


Example:
--------

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully.">
		<SQLScript>
		<![CDATA[
		
			exec dbo.pSetup$SF#FormType
				 @SetupUser = 'system@alinityapp.com'
				,@Language = 'EN'
				,@Region = 'CA'

			select * from sf.FormType

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$SF#FormType'
	,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */

set nocount on;

begin

	declare
		@errorNo		 int					 = 0	-- 0 no error, if < 50000 SQL error, else business rule
	 ,@errorText	 nvarchar(4000)			-- message text (for business rule errors)
	 ,@OFF				 bit					 = cast(0 as bit)
	 ,@ON					 bit					 = cast(1 as bit)
	 ,@sourceCount int								-- count of rows in the source table
	 ,@targetCount int;								-- count of rows in the target table

	declare @setup table
	(
		ID						int						identity(1, 1)
	 ,FormTypeSCD		varchar(25)		not null
	 ,FormTypeLabel nvarchar(35)	not null
	 ,FormOwnerSID	int						not null
	 ,UsageNotes		nvarchar(max) not null
	 ,IsDefault			bit						not null
	);

	begin try

		insert
			@setup
		(
			FormTypeSCD
		 ,FormTypeLabel
		 ,IsDefault
		 ,FormOwnerSID
		 ,UsageNotes
		)
		values
-- SQL Prompt formatting off
			 ('APPLICATION.MAIN'				,N'Application (main)'	            ,@ON	,(select fo.FormOwnerSID from sf.FormOwner fo where fo.FormOwnerSCD = 'APPLICANT')	, N'Assign this type to application forms completed by new members seeking a registration in the College. This form type may also apply to existing registrants seeking to upgrade their registration to one offering extended or specialized practice, or, to add a second registration where multiple concurrent registrations are allowed.')
			,('APPLICATION.REVIEW'			,N'Application (supervisor) review'	,@OFF	,(select fo.FormOwnerSID from sf.FormOwner fo where fo.FormOwnerSCD = 'SUPERVISOR')	, N'Assign this type to the form completed by a supervisor or other employer representative who validates aspects of the application or the applicant''s claimed credentials.')
			,('RENEWAL.MAIN'						,N'Renewal'													,@OFF	,(select fo.FormOwnerSID from sf.FormOwner fo where fo.FormOwnerSCD = 'REGISTRANT')	, N'Assign this type to the renewal form created for the practice register.')
			,('REINSTATEMENT.MAIN'			,N'Reinstatement'										,@OFF	,(select fo.FormOwnerSID from sf.FormOwner fo where fo.FormOwnerSCD = 'REGISTRANT')	, N'Assign this type to the reinstatement form used by registrants to reinstate, go inactive, etc.')
			,('LEARNINGPLAN.MAIN'				,N'Learning Plan'				            ,@OFF	,(select fo.FormOwnerSID from sf.FormOwner fo where fo.FormOwnerSCD = 'REGISTRANT')	, N'Assign this type to the learning plan form created for the practice register.')
			,('AUDIT.MAIN'							,N'Audit'														,@OFF	,(select fo.FormOwnerSID from sf.FormOwner fo where fo.FormOwnerSCD = 'REGISTRANT')	, N'Assign this type to the form completed by registrants selected for Continuing Competence review (audit).')
			,('AUDIT.REVIEW'						,N'Audit review'										,@OFF	,(select fo.FormOwnerSID from sf.FormOwner fo where fo.FormOwnerSCD = 'REVIEWER')		, N'Assign this type to the form completed by those assessing Continuing Competence review (audit) forms.')
			,('PROFILE.UPDATE'					,N'Profile update'				          ,@OFF	,(select fo.FormOwnerSID from sf.FormOwner fo where fo.FormOwnerSCD = 'REGISTRANT')	, N'Assign this type to the profile update form (common to all practice registers).')
			,('SELFASSESSMENT'					,N'Self Assessment'				          ,@OFF	,(select fo.FormOwnerSID from sf.FormOwner fo where fo.FormOwnerSCD = 'REGISTRANT')	, N'Assign this type to forms where the member uses the form as a means to assess their skills, abilities and experience in the profession. The result from this process is typically used to shape learning plans.')
-- SQL Prompt formatting on
		merge sf.FormType target
		using (
						select
							x.FormTypeSCD
						 ,x.FormTypeLabel
						 ,x.FormOwnerSID
						 ,x.UsageNotes
						 ,x.IsDefault
						 ,@SetupUser CreateUser
						 ,@SetupUser UpdateUser
						from
							@setup x
					) source
		on target.FormTypeSCD = source.FormTypeSCD
		when not matched by target then
			insert
			(
				FormTypeSCD
			 ,FormTypeLabel
			 ,FormOwnerSID
			 ,UsageNotes
			 ,IsDefault
			 ,CreateUser
			 ,UpdateUser
			)
			values
			(
				source.FormTypeSCD, source.FormTypeLabel, source.FormOwnerSID, source.UsageNotes, source.IsDefault, @SetupUser, @SetupUser
			)
		when matched then update set
												IsDefault = source.IsDefault
											 ,FormTypeLabel = source.FormTypeLabel
											 ,UsageNotes = source.UsageNotes
											 ,UpdateUser = @SetupUser
		when not matched by source then delete;

		-- check count of @setup table and the target table
		-- target should have at least as many rows as @setup

		select @sourceCount	 = count(1) from @setup ;
		select @targetCount	 = count(1) from sf.FormType;

		if isnull(@targetCount, 0) <> @sourceCount
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'SetupNotSynchronized'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'Synchronization of setup codes not complete. Source table count is %1 but target table (%2) count is %3.'
			 ,@Arg1 = @sourceCount
			 ,@Arg2 = 'sf.FormType'
			 ,@Arg3 = @targetCount;

			raiserror(@errorText, 18, 1);
		end;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);

end;
GO
