SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pSetup$SF#ExportJob]
	@SetupUser nvarchar(75) -- user assigned to audit columns
 ,@Language	 char(2)			-- language to install for
 ,@Region		 varchar(10)	-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup Export Job
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : Updates/initializes sf.ExportJob table with records required by the application
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + -----------------------------------------------------------------------------------
 				: Tim Edlund          | Jul 2018		|	Initial version

Comments	
--------
Records can be added and removed from sf.ExportJob table by configurators in order to support unique and custom exports
required in the client configuration.  The application also requires a set of specific export job records which this procedure
ensures are created and updated to follow the current standard.  These codes are easily identified by their "S!" prefix.

The procedure will ensure all required records are in place but will not delete any additional records which may have been
added by the configurator.


Example
-------
<TestHarness>
  <Test Name = "Random" IsDefault ="true" Description="Executes the procedure to ensure it completes successfully">
    <SQLScript>
      <![CDATA[

		exec dbo.pSetup$SF#ExportJob 
			 @SetupUser = N'system@softworksgroup.com'
			,@Language  = 'en'
			,@Region		= 'can'
	
		select * from sf.ExportJob

		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:03"/>
    </Assertions>
  </Test>
	<Test Name = 'CIHI.LPN.M' Description="Tests exports of a CIHI LPN Main batch">
		<SQLScript>
			<![CDATA[
declare
	@registrationSnapshotSID int
 ,@rowGUID								 uniqueidentifier
 ,@fileFormatSID					 int
 ,@sql nvarchar(max)
 ,@exportJobSID						 int;

select top (1)
	@registrationSnapshotSID = rs.RegistrationSnapshotSID
 ,@rowGUID								 = rs.RowGUID
from
	dbo.vRegistrationSnapshot rs
where
	rs.RegistrationSnapshotTypeSCD = 'CIHI' and rs.ProfileCount > 0
order by
	newid();

select
	@exportJobSID	 = x.ExportJobSID
 ,@fileFormatSID = x.FileFormatSID
 ,@rowGUID			 = x.RowGUID
 ,@sql = x.QuerySQL
from
	sf.ExportJob x
where
	x.ExportJobCode = 'S!CIHI.LPN.M';

if @registrationSnapshotSID is null or @exportJobSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	insert
		sf.ExportFile
	(
		ExportSourceGUID
	 ,FileFormatSID
	 ,ExportSpecification
	)
	values
	(
		cast(@rowGUID as nvarchar(50))
		,@fileFormatSID
	 ,'<Export Type="ExportJob" ExportJobSID="' + ltrim(@ExportJobSID) + '"><SQL>' + @sql + '</SQL><Parameters><Parameter Name="RegistrationSnapShotSID" Type="Int" Value="' + ltrim(@registrationSnapshotSID) + '"/></Parameters></Export>'
	);

end;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="ExecutionTime" Value="00:00:03"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$SF#ExportJob'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo	 int					 = 0											-- 0 no error, if < 50000 SQL error, else business rule
	 ,@tranCount int					 = @@trancount						-- determines whether a wrapping transaction exists
	 ,@procName	 nvarchar(128) = object_name(@@procid)	-- name of currently executing procedure
	 ,@xState		 int;																		-- error state detected in catch block

	declare @setup table
	(
		ID								int						not null identity(1, 1)
	 ,ExportJobName			nvarchar(65)	not null
	 ,ExportJobCode			varchar(15)		not null
	 ,QuerySQL					nvarchar(max) not null
	 ,QueryParameters		xml						null
	 ,FileFormatSID			int						not null
	 ,BodySpecification nvarchar(max) null
	 ,LineSpecification nvarchar(max) null
	);

	begin try

		-- if a wrapping transaction exists set a save point to rollback to on a local error

		if @tranCount = 0 -- no outer transaction
		begin
			begin transaction;
		end;
		else -- outer transaction so create save point
		begin
			save transaction @procName;
		end;

		-- load table with system required export jobs

		insert
			@setup
		(
			ExportJobName
		 ,ExportJobCode
		 ,QuerySQL
		 ,QueryParameters
		 ,FileFormatSID
		 ,BodySpecification
		 ,LineSpecification
		)
		select
			N'CIHI Export LPN (main)'
		 ,'S!CIHI.LPN.M'
		 ,N'select rpc.* from dbo.vRegistrationProfile#CIHI rpc where rpc.RegistrationSnapshotSID = @RegistrationSnapshotSID' + char(13) + char(10)
			+ 'select rsc.* from dbo.vRegistrationSnapshot#CIHI rsc where rsc.RegistrationSnapshotSID = @RegistrationSnapshotSID'
		 ,cast(N'<Parameters><Parameter ID="RegistrationSnapshotSID" Label="Snapshot Key" Type="TextBox" /></Parameters>' as xml)
		 ,ff.FileFormatSID
		 ,N'0{OccupationID}{JurisdictionLocation}{RegistrationYear}{ProfileCount^fw,6,0,r}{SubmissionDate}{$space:70}' + char(13) + char(10)
			+ '{_bodycontent}'
		 ,N'{F01SubmissionType^fw,1, ,l}{F02OccupationID^fw,5,0,r}{F03PracticeStatus^fw,1, ,l}{F04RegistrationYear^fw,4,0,r}{F05JurisdictionLocation^fw,3,0,r}{F06RegistrantNo^fw,8, ,r}{F07GenderCD^fw,1, ,l}{F08BirthYear^fw,4,0,r}{F09Education1CredentialCode^fw,1, ,l}{F10Education1GraduationYear^fw,4,0,r}{F11Education1Location^fw,3,0,r}{F12Filler^fw,1, ,l}{F13Education2CredentialCode^fw,1, ,l}{F14Education3CredentialCode^fw,1, ,l}{F15EmploymentStatusCode^fw,2,0,r}{F16Employment1TypeCode^fw,1, ,l}{F17MultipleEmploymentStatus^fw,1, ,l}{F18Filler^fw,1, ,l}{F19Employment1Location^fw,3,0,r}{F20Employment1OrgTypeCode^fw,2,0,r}{F21Employment1PracticeAreaCode^fw,2,0,r}{F22Employment1RoleCode^fw,2,0,r}{F23ResidenceLocation^fw,3,0,r}{F24ResidencePostalCode^fw,6, ,l}{F25Employment1PostalCode^fw,6, ,l}{F26RegistrationYearMonth^fw,6,0,r}{F27Employment2OrgTypeCode^fw,2,0,r}{F28Employment3OrgTypeCode^fw,2,0,r}{F29Employment2PracticeAreaCode^fw,2,0,r}{F30Employment3PracticeAreaCode^fw,2,0,r}{F31Employment2RoleCode^fw,2,0,r}{F32Employment3RoleCode^fw,2,0,r}{F33Employment2PostalCode^fw,6, ,l}{F34Employment3PostalCode^fw,6, ,l}'
		from
			sf.FileFormat ff
		where
			ff.FileFormatSCD = '.TXT';

		insert
			@setup
		(
			ExportJobName
		 ,ExportJobCode
		 ,QuerySQL
		 ,QueryParameters
		 ,FileFormatSID
		 ,BodySpecification
		 ,LineSpecification
		)
		select
			N'CIHI Export LPN (hours)'
		 ,'S!CIHI.LPN.H'
		 ,N'select rpc.* from dbo.vRegistrationProfile#CIHI rpc where rpc.RegistrationSnapshotSID = @RegistrationSnapshotSID'+ char(13) + char(10)
			+ 'select rsc.* from dbo.vRegistrationSnapshot#CIHI rsc where rsc.RegistrationSnapshotSID = @RegistrationSnapshotSID' 
		 ,cast(N'<Parameters><Parameter Name="RegistrationSnapshotSID" Type="int" Value="@RegistrationSnapshotSID"/></Parameters>' as xml)
		 ,ff.FileFormatSID
		 ,N'0{OccupationID}{JurisdictionLocation}{RegistrationYear}{ProfileCount^fw,6,0,r}{SubmissionDate}{$space:70}' + char(13) + char(10)
			+ '{_bodycontent}'
		 ,N'{F01SubmissionType^fw,1, ,l}{F02OccupationID^fw,5,0,r}{F04RegistrationYear^fw,4,0,r}{F05JurisdictionLocation^fw,3,0,r}{F06RegistrantNo^fw,8, ,r}{F06PracticeHours^fw,4, ,r}'
		from
			sf.FileFormat ff
		where
			ff.FileFormatSCD = '.TXT';

		-- ensure all required jobs exist and are updated to 
		-- reflect current standard formats (non-system 
		-- entries are not deleted)

		merge sf.ExportJob target
		using
		(
			select
				x.ID
			 ,x.ExportJobName
			 ,x.ExportJobCode
			 ,x.QuerySQL
			 ,x.QueryParameters
			 ,x.FileFormatSID
			 ,x.BodySpecification
			 ,x.LineSpecification
			from
				@setup x
		) source
		on target.ExportJobCode = source.ExportJobCode
		when not matched by target then
			insert
			(
				ExportJobName
			 ,ExportJobCode
			 ,QuerySQL
			 ,QueryParameters
			 ,FileFormatSID
			 ,BodySpecification
			 ,LineSpecification
			 ,CreateUser
			 ,UpdateUser
			)
			values
			(
				source.ExportJobName, source.ExportJobCode, source.QuerySQL, source.QueryParameters, source.FileFormatSID, source.BodySpecification
			 ,source.LineSpecification, @SetupUser, @SetupUser
			)
		when matched then update set
												target.QuerySQL = source.QuerySQL
											 ,target.QueryParameters = source.QueryParameters
											 ,target.FileFormatSID = source.FileFormatSID
											 ,target.BodySpecification = source.BodySpecification
											 ,target.LineSpecification = source.LineSpecification
											 ,target.UpdateUser = @SetupUser
											 ,target.UpdateTime = sysdatetimeoffset();

		if @tranCount = 0 and xact_state() = 1
		begin
			commit transaction;
		end;

	end try
	begin catch

		set @xState = xact_state();

		if @tranCount = 0 and (@xState = -1 or @xState = 1)
		begin
			rollback; -- rollback if any transaction is pending (committable or not)
		end;

		exec @errorNo = sf.pErrorRethrow;

	end catch;

	return (@errorNo);
end;
GO
