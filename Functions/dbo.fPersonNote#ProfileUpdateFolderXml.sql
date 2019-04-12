SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fPersonNote#ProfileUpdateFolderXml]
(
	 @PersonSID												int																	-- the id of the person to retrieve notes for
) returns xml
as
/*********************************************************************************************************************************
Function	: Person Note - Profile Update Folder XML
Notice		: Copyright © 2017 Softworks Group Inc.
Summary		: returns an XML fragment (0..* Folder elements but NO root element) for use with other functions or views
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Cory Ng			| Jan	2018		| Initial version

Comments	
--------
This function is used to get 0..* Folder elements for Profile Updates belonging to the provided person and their related
notes as nested Item elements.

IsReadGranted is checked, notes where this is 0 are excluded so MAKE SURE your session is set before use.

Example:
--------
<TestHarness>
	<Test Name="All" Description="Return all Items">
		<SQLScript>
			<![CDATA[
					
					declare
					 @applicationUserSID	int
					,@userName						nvarchar(75)
					,@paymentTypeSID			int
					,@paymentStatusSID		int
					,@GLAccountCode				int

					
				-- Sign in as a random application user with admin grants
				select top(1)
					 @applicationUserSID	= aug.ApplicationUserSID
					,@userName						= aug.UserName
				from
					sf.vApplicationUserGrant aug
				where
					aug.ApplicationUserIsActive = cast(1 as bit)
				and
					sf.fIsGrantedToUserSID('ADMIN.BASE', aug.ApplicationUserSID)  = 1
				order by
					newid()
				
				exec sf.pApplicationUser#Authorize
					@UserName   = @userName
				 ,@IPAddress = '10.0.0.1'


				select 
					p.PersonSID
				 ,p.LastName
				 ,p.FirstName
				 ,dbo.fPersonNote#ProfileUpdateFolderXml(p.PersonSID)XML
				from
					sf.Person p;
				
				
				if @@ROWCOUNT = 0 raiserror('* ERROR: no data found for test case',16,1) 

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1" />
			<Assertion Type="NotEmptyResultSet" ResultSet="2" />
			<Assertion Type="ExecutionTime" Value="00:00:80"/>
		</Assertions>
	</Test>
	<Test Name="Single" Description="Return items for a single person">
		<SQLScript>
			<![CDATA[
					
					declare
					 @applicationUserSID			int
					,@userName								nvarchar(75)
					,@personNoteTypeSID				int
					,@personNoteSID						int
					,@formVersionSID					int
					,@personSID								int
					,@applicationEntitySID		int
					,@profileUpdateStatusSID	int
					,@profileUpdateSID				int
					,@xml											xml

				begin tran
				
				select  top 1
					@formVersionSID = fv.FormVersionSID
				from
					sf.FormVersion fv
				order by
					newid()

				select top 1
					@personSID = p.PersonSID
				from
					sf.Person p
				order by
				 newid()
				
				select top 1
					@profileUpdateStatusSID = ps.ProfileUpdateStatusSID
				from
					dbo.ProfileUpdateStatus ps
				order by
					NEWID()

				select
					@personNoteTypeSID = pnt.PersonNoteTypeSID
				from
					dbo.PersonNoteType pnt
				where
					pnt.PersonNoteTypeLabel = 'Comment'

				select
					@ApplicationEntitySID = ae.ApplicationEntitySID
				from
					sf.ApplicationEntity ae
				where
					ae.ApplicationEntitySCD = 'dbo.ProfileUpdate'

				insert into dbo.ProfileUpdate
				(
						PersonSID
					, FormVersionSID
				)
				select
						@personSID
					, @formVersionSID

				set @profileUpdateSID = scope_identity()

				insert into dbo.PersonNote
				(
					PersonSID
					,PersonNoteTypeSID
					,NoteContent
				)
				select
						@personSID
					,	@personNoteTypeSID
					,	'*** TEST ***'
					

				set @personNoteSID = scope_identity()

				insert into dbo.PersonNoteContext
				(
						PersonNoteSID
					,	ApplicationEntitySID
					,	EntitySID
				)
				select
						@personNoteSID
					,	@applicationEntitySID
					,	@profileUpdateSID

				-- Sign in as a random application user with admin grants
				select top(1)
					 @applicationUserSID	= aug.ApplicationUserSID
					,@userName						= aug.UserName
				from
					sf.vApplicationUserGrant aug
				where
					aug.ApplicationUserIsActive = cast(1 as bit)
				and
					sf.fIsGrantedToUserSID('ADMIN.BASE', aug.ApplicationUserSID)  = 1
				order by
					newid()

				exec sf.pApplicationUser#Authorize
					@UserName   = @userName
				 ,@IPAddress = '10.0.0.1'

				select
					@xml = dbo.fPersonNote#ProfileUpdateFolderXml(@PersonSID)
				
				select @xml

				select
						n.t.value('@EntitySID', 'int') EntitySID
					,	n.t.value('@EntitySCD', 'varchar(255)') EntitySCD
					,	n.t.value('@Name', 'varchar(100)') Name
				from
					@xml.nodes('Folder') n(t)

				select
						n.t.value('@PersonNoteSID', 'int') PersonNoteSID
					,	n.t.value('@NoteType', 'varchar(255)') Comment
					,	n.t.value('@Name', 'varchar(100)') [*** TEST ***]
				from
					@xml.nodes('Folder/Item') n(t)

				select
						n.t.value('@EntitySID', 'int') EntitySID
					,	n.t.value('@EntityName', 'varchar(255)') ProfileUpdate
					,	n.t.value('@EntitySCD', 'varchar(100)') [dbo.ProfileUpdate]
				from
					@xml.nodes('Folder/Item/NoteContexts/Context') n(t)

				if @@ROWCOUNT = 0 raiserror('* ERROR: no data found for test case',16,1) 
				if @@TRANCOUNT > 0 rollback

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1" />
			<Assertion Type="ScalarValue" ResultSet="3" Row="1" Column="2" Value="dbo.ProfileUpdate" />
			<Assertion Type="ScalarValue" ResultSet="4" Row="1" Column="2" Value="Comment" />
			<Assertion Type="ScalarValue" ResultSet="4" Row="1" Column="3" Value="*** TEST ***" />
			<Assertion Type="ScalarValue" ResultSet="5" Row="1" Column="2" Value="Profile Update "  />
			<Assertion Type="ScalarValue" ResultSet="5" Row="1" Column="3" Value="dbo.ProfileUpdate" />
			<Assertion Type="ExecutionTime" Value="00:00:02"/>
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute																								
			@ObjectName = N'dbo.fPersonNote#ProfileUpdateFolderXml'
		,	@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */
begin
	
	return
	(
		select
			 pu.ProfileUpdateSID					[@EntitySID]
			,'dbo.ProfileUpdate'					[@EntitySCD]
			,pu.ProfileUpdateLabel  			[@Name]
			,dbo.fPersonNote#ItemXml(@PersonSID, 'dbo.ProfileUpdate', pu.ProfileUpdateSID)
		from
			sf.Person p
		join
			dbo.vProfileUpdate pu on p.PersonSID = pu.PersonSID
		where
			p.PersonSID = @PersonSID
		for xml path('Folder')
	)

end
GO
