SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.[pSetup$SF#FormStatus]
	@SetupUser nvarchar(75) -- user assigned to audit columns
 ,@Language	 char(2)			-- language to install for
 ,@Region		 varchar(10)	-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup sf.FormStatus data
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : Updates the (sf) Form Status master table with starting values for the application
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Mar 2017		|	Initial version
				: Tim Edlund					| Oct	2017		| Added AWAITINGDOCS status
				: Tim Edlund					| Sep 2018		| Added REVIEWED status

Comments	
--------
This procedure synchronizes the sf.FormStatus table with the settings required by the current version of the application. 
If a record is missing it is added. Where the record exists, it is set to current values. Form-Statuses no longer used are
deleted from the table. One MERGE statement is used to carryout all operations.

Example:
--------

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully.">
		<SQLScript>
		<![CDATA[
		
			exec dbo.pSetup$SF#FormStatus
				 @SetupUser = 'system@alinityapp.com'
				,@Language = 'EN'
				,@Region = 'CA'

			select * from sf.FormStatus order by FormStatusSequence

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$SF#FormStatus'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo					int						= 0 -- 0 no error, if < 50000 SQL error, else business rule
	 ,@errorText				nvarchar(4000)		-- message text (for business rule errors)
	 ,@OFF							bit						= cast(0 as bit)
	 ,@ON								bit						= cast(1 as bit)
	 ,@adminOwnerSID		int								-- key of admin form owner
	 ,@assigneeOwnerSID int								-- key of assignee form owner
	 ,@reviewerOwnerSID int								-- key of reviewer form owner
	 ,@noneOwnerSID			int								-- key of "done" owner (form is complete)
	 ,@sourceCount			int								-- count of rows in the source table
	 ,@targetCount			int;							-- count of rows in the target table

	declare @setup table
	(
		ID								 int					 identity(1, 1)
	 ,FormStatusSCD			 varchar(25)	 not null
	 ,FormStatusLabel		 nvarchar(35)	 not null
	 ,FormStatusSequence int					 not null default 0
	 ,FormOwnerSID			 int					 not null
	 ,Description				 nvarchar(max) not null
	 ,IsFinal						 bit					 not null
	 ,IsDefault					 bit					 not null
	);

	begin try

		select
			@assigneeOwnerSID = fo.FormOwnerSID
		from
			sf.FormOwner fo
		where
			fo.FormOwnerSCD = 'ASSIGNEE';

		select
			@adminOwnerSID = fo.FormOwnerSID
		from
			sf.FormOwner fo
		where
			fo.FormOwnerSCD = 'ADMIN';

		select
			@reviewerOwnerSID = fo.FormOwnerSID
		from
			sf.FormOwner fo
		where
			fo.FormOwnerSCD = 'REVIEWER';

		select
			@noneOwnerSID = fo.FormOwnerSID
		from
			sf.FormOwner fo
		where
			fo.FormOwnerSCD = 'NONE';

		insert
			@setup
		(
			FormStatusSCD
		 ,FormStatusLabel
		 ,FormStatusSequence
		 ,FormOwnerSID
		 ,IsFinal
		 ,IsDefault
		 ,Description
		)
		values
			-- SQL Prompt formatting off
			 ('NEW'						,N'New'										,100,@assigneeOwnerSID	,@OFF, @ON,  N'This status applies to new forms which have not yet been submitted.  This is the default status.')
			,('SUBMITTED'			,N'Submitted'							,110,@adminOwnerSID			,@OFF, @OFF, N'This status indicates the form has been submitted by the applicant/registrant or reviewer. The status is applied for first time submission of the form as well as subsequent submissions if it is returned by administrators for further updates.')
			,('UNLOCKED'			,N'Unlocked'							,115,@adminOwnerSID			,@OFF, @OFF, N'This status applies when an administrator needs to re-open a form after a final status (other than "Approved") was assigned to it. Once unlocked, it can be edited for correction, returned to the user or another final status assigned.')
			,('CORRECTED'			,N'Corrected'							,120,@adminOwnerSID			,@OFF, @OFF, N'This status applies when an administrator has made and saved edits to the form. Normally this status appears briefly since, after making corrections, the administrator will typically return the form or approve it.')
			,('RETURNED'			,N'Returned For updates'	,130,@assigneeOwnerSID	,@OFF, @OFF, N'This status applies when an administrator has returned the form to the registrant/applicant or reviewer, to make corrections or other updates.')
			,('AWAITINGDOCS'	,N'Awaiting documents'		,140,@assigneeOwnerSID	,@OFF, @OFF, N'This status applies when an administrator has reviewed the form and is now awaiting submission of supporting documents by the applicant/registrant.')
			,('READY'					,N'Ready for review'			,200,@adminOwnerSID			,@OFF, @OFF, N'This status indicates the form is ready for examination by a reviewer.  This is an interim administrative status useful to determine which forms can be assigned to reviewers. Note that even where forms are not assigned this status, they can still be assigned directly to a reviewer. Use of this status is optional.')			
			,('INREVIEW'			,N'Sent for review'				,300,@reviewerOwnerSID	,@OFF, @OFF, N'This status applies when the main form has one or more reviews assigned. Once all assigned reviewers have provided a recommendation, the status is updated to "Reviewed" and responsibility for the next action is assigned to Administrators.')
			,('REVIEWED'			,N'Review(s) complete'		,310,@adminOwnerSID			,@OFF, @OFF, N'This status applies when all reviewers assigned have provided recommendations. ')
			,('APPROVED'			,N'Approved'							,700,@noneOwnerSID			,@ON,  @OFF, N'This is a final status applied by an administrator when the form has been completed successfully and accepted.  Once this status applies, contents from the form is used to update the registrant/applicant and organization profiles.')
			,('REJECTED'			,N'Rejected/Declined'			,800,@noneOwnerSID			,@ON,  @OFF, N'This is a final status applied by an administrator when the form is declined or rejected because it has remained incomplete or the applicant or registrant is not able to comply with requirements.')
			,('WITHDRAWN'			,N'Withdrawn'							,900,@noneOwnerSID			,@ON,  @OFF, N'This is a final status the end-user can set by choosing to withdraw their form further processing.')
			,('DISCONTINUED'	,N'Discontinued'					,999,@noneOwnerSID			,@ON,  @OFF, N'This status applies when an administrator has determined that the end-user is no longer going to complete the form (admin withdrawal). This scneario may arise with maternity leaves or retirement for example.')
		-- SQL Prompt formatting on
		merge sf.FormStatus target
		using
		(
			select
				x.FormStatusSCD
			 ,x.FormStatusLabel
			 ,x.FormStatusSequence
			 ,x.FormOwnerSID
			 ,x.Description
			 ,x.IsFinal
			 ,x.IsDefault
			 ,@SetupUser CreateUser
			 ,@SetupUser UpdateUser
			from
				@setup x
		) source
		on target.FormStatusSCD = source.FormStatusSCD
		when not matched by target then
			insert
			(
				FormStatusSCD
			 ,FormStatusLabel
			 ,FormStatusSequence
			 ,FormOwnerSID
			 ,Description
			 ,IsFinal
			 ,IsDefault
			 ,CreateUser
			 ,UpdateUser
			)
			values
			(
				source.FormStatusSCD, source.FormStatusLabel, source.FormStatusSequence, source.FormOwnerSID, source.Description, source.IsFinal, source.IsDefault
			 ,@SetupUser, @SetupUser
			)
		when matched then update set
												IsFinal = source.IsFinal
											 ,IsDefault = source.IsDefault
											 ,FormStatusSequence = source.FormStatusSequence
											 ,FormOwnerSID = source.FormOwnerSID
											 ,Description = source.Description
											 ,UpdateUser = @SetupUser
		when not matched by source then delete;

		-- check count of @setup table and the target table
		-- target should have at least as many rows as @setup

		select @sourceCount	 = count(1) from @setup ;
		select @targetCount	 = count(1) from sf .FormStatus;

		if isnull(@targetCount, 0) <> @sourceCount
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'SetupNotSynchronized'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'Synchronization of setup codes not complete. Source table count is %1 but target table (%2) count is %3.'
			 ,@Arg1 = @sourceCount
			 ,@Arg2 = 'sf.FormStatus'
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
