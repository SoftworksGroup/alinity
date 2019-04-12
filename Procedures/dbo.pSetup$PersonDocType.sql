SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.[pSetup$PersonDocType]
	@SetupUser nvarchar(75) -- user assigned to audit columns
 ,@Language	 char(2)			-- language to install for
 ,@Region		 varchar(10)	-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup dbo.PersonDocType data
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : Updates dbo.PersonDocType master table with values required by the application
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year  | Change Summary
				 : ------------ |-------------|-------------------------------------------------------------------------------------------
				 : Kris Dawson	| Feb	2017		| Initial Version
				 : Tim Edlund		| Sep 2017		| Changed to system-code-table (PersonDocTypeSCD column added). Default management added.
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------
This procedure synchronizes the dbo.PersonDocType table with the settings required by the current version of the application. 
If a record is missing it is added. File types no longer used are deleted from the table. One MERGE statement is used to carryout 
all operations.

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully.">
		<SQLScript>
		<![CDATA[		

			exec dbo.pSetup$PersonDocType
				 @SetupUser = 'system@alinityapp.com'
				,@Language = 'EN'
				,@Region = 'CA'

			select * from dbo.PersonDocType

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$PersonDocType'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo		 int					 = 0							-- 0 no error, if < 50000 SQL error, else business rule
	 ,@errorText	 nvarchar(4000)									-- message text (for business rule errors)
	 ,@sourceCount int														-- count of rows in the source table
	 ,@targetCount int														-- count of rows in the target table
	 ,@OFF				 bit					 = cast(0 as bit) -- constant for bit = 0
	 ,@ON					 bit					 = cast(1 as bit) -- constant for bit = 1
	 ,@defaultSCD	 varchar(15);										-- code of current default record if any

	declare @setup table
	(
		ID								 int					identity(1, 1)
	 ,PersonDocTypeSCD	 varchar(15)	not null
	 ,PersonDocTypeLabel nvarchar(35) not null
	 ,IsDefault					 bit					not null default 0
	 ,IsActive					 bit					not null default 1
	);

	begin try

		insert
			@setup (PersonDocTypeSCD, PersonDocTypeLabel, IsDefault, IsActive)
		values
		  ('OTHER', N'Other', @OFF, @ON)
		 ,('APP', N'Application form', @OFF, @ON)
		 ,('RENEWAL', N'Renewal form', @OFF, @ON)
		 ,('AUDIT', N'Competence audit form', @OFF, @ON)
		 ,('REINSTATEMENT', N'Reinstatement form', @OFF, @ON)
		 ,('PROFILE.UPD', N'Profile update form', @OFF, @ON)
		 ,('REGCHANGE', N'Registration change form', @OFF, @ON)
		 ,('LEARNINGPLAN', N'Learning plan form', @OFF, @ON)
		 ,('SPECIALIZATION', N'Specializations', @OFF, @ON)
		 ,('TRANSCRIPT', N'Marks transcript', @OFF, @ON)
		 ,('ID', N'Identification document', @OFF, @ON)
		 ,('CERT', N'Certificate/Diploma', @OFF, @ON)
		 ,('CRC', N'Criminal record check', @OFF, @ON)
		 ,('REVIEW', N'Review form', @OFF, @ON)
		 ,('CPR', N'CPR document', @OFF, @OFF)
		 ,('SELFASSESSMENT', N'Self assessment', @OFF, @OFF)
		 ,('COMPLAINTLETTER', N'Complaint letter', @OFF, @ON)
		 ,('INTERVIEWNOTES', N'Interview notes', @OFF, @ON)
		 ,('COUNCIL', N'Council documents', @OFF, @ON)
		 ,('COMMITTEE', N'Committee documents', @OFF, @ON)
		 ,('PREAUTH', N'Pre-authorized payment documents', @OFF, @ON)
		 ,('EXAM', N'Exam documents', @OFF, @ON)
		 ,('INSURANCE',N'Insurance documents', @OFF, @ON);

		-- ensure default is established

		select
			@defaultSCD = pdt.PersonDocTypeSCD
		from
			dbo.PersonDocType pdt
		join
			@setup						s on pdt.PersonDocTypeSCD = s.PersonDocTypeSCD
		where
			pdt.IsDefault = @ON and pdt.IsActive = @ON;

		if @defaultSCD is null
		begin
			set @defaultSCD = 'OTHER';
		end;

		update @setup	 set IsDefault = @ON where PersonDocTypeSCD = @defaultSCD;

		merge dbo.PersonDocType target
		using
		(
			select
				x.PersonDocTypeSCD
			 ,x.PersonDocTypeLabel
			 ,x.IsDefault
			 ,x.IsActive
			from
				@setup x
		) source
		on target.PersonDocTypeSCD = source.PersonDocTypeSCD
		when not matched by target then insert
																		(
																			PersonDocTypeSCD
																		 ,PersonDocTypeLabel
																		 ,IsDefault
																		 ,IsActive
																		 ,CreateUser
																		 ,UpdateUser
																		)
																		values
																		(
																			source.PersonDocTypeSCD, source.PersonDocTypeLabel, source.IsDefault, source.IsActive, @SetupUser, @SetupUser
																		)
		when matched then update set
												target.IsDefault = source.IsDefault
											 ,target.UpdateUser = @SetupUser
											 ,target.UpdateTime = sysdatetimeoffset()
		when not matched by source then delete;

		-- check count of @setup table and the target table
		-- target should have exactly as many rows as @setup

		select @sourceCount	 = count(1) from @setup ;
		select @targetCount	 = count(1) from dbo .PersonDocType;

		if isnull(@targetCount, 0) <> @sourceCount
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'SetupNotSynchronized'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'Synchronization of setup codes not complete. Source table count is %1 but target table (%2) count is %3.'
			 ,@Arg1 = @sourceCount
			 ,@Arg2 = 'dbo.PersonDocType'
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
