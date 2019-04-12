SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fPersonNote#ItemXml]
(
	 @PersonSID												int																	-- the id of the person to retrieve notes for
	,@ForApplicationEntitySCD					varchar(50)													-- the entity to restrict notes to (if null will get notes without context entries)
	,@ForEntitySID										int																	-- the entity id to restrict notes to (ignored if entity scd is null)
) returns xml
as
/*********************************************************************************************************************************
Function	: Person Note - Item XML
Notice		: Copyright © 2017 Softworks Group Inc.
Summary		: returns an XML fragment (0..* Item elements but NO root element) for use with other functions or views
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Kris Dawson	| Oct	2017		| initial version

Comments	
--------
This function is used to get item XML, based on PersonNote entities, to populate a larger XML document made up of folders and 
items.

IsReadGranted is checked, notes where this is 0 are excluded so MAKE SURE your session is set before use.

Example:
--------
<TestHarness>
	<Test Name="Admin" Description="Admin can see everything">
		<SQLScript>
			<![CDATA[
					
					declare
					 @applicationUserSID	int
					,@userName						nvarchar(75)
					,@personSID						int
					,@personNoteTypeSID		int
					,@fileTypeSID					int
					,@fileTypeSCD					varchar(8)
					,@ItemXML							xml

				begin tran
					
				select top 1
						@fileTypeSCD = ft.FileTypeSCD
					,	@fileTypeSID = ft.FileTypeSID
				from
					sf.FileType ft
				where
					ft.IsActive = cast( 1 as bit)
				order by
					newid()

				-- Look up a specific doc type, so we can check for it later.
				select 
						@personNoteTypeSID = pdt.personNoteTypeSID
				from
					dbo.personNoteType pdt
				where
					pdt.PersonNoteTypeLabel = 'DOCUMENT'

				-- Select a random person
				select top 1
					@personSID = p.PersonSID
				from
					sf.person p
				order by
					newid()
				
				delete from PersonNote
				where 
					PersonSID = @personSID
					
				insert into dbo.personNote
				(
						PersonSID
					,	personNoteTypeSID
					,	NoteContent
				)
				select
						@personSID
					,	@personNoteTypeSID
					,	'*** TEST ***'
					
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
					@itemXml =	dbo.fpersonNote#ItemXml(@personSID, null, null)

				select
					@itemXml
				select 
						n.t.value('@Name',						'nvarchar(max)') Name
					,	n.t.value('@PersonNoteSID',		'nvarchar(max)') personNoteSID
					,	n.t.value('@NoteType',					'nvarchar(max)') NoteType
					, n.t.value('@IsDeleteEnabled',	'nvarchar(max)') IsDeleteEnabled
					,	n.t.value('@IsRemoved',				'nvarchar(max)') IsRemoved
					,	n.t.value('@Date',						'nvarchar(max)') Date
					,	n.t.value('@UpdatedBy',			'nvarchar(max)') UploadedBy
				from
					@itemXML.nodes('/Item') n(t)
				
				
				if @@ROWCOUNT = 0 raiserror('* ERROR: no data found for test case',16,1) 
				if @@TRANCOUNT > 0 rollback


						]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1" />
			<Assertion Type="NotEmptyResultSet" ResultSet="2" />
			<Assertion Type="ScalarValue"	ResultSet="3" Row="1" Column="1" Value="*** TEST ***" />
			<Assertion Type="ScalarValue"	ResultSet="3" Row="1" Column="3" Value="Document" />
			<Assertion Type="ExecutionTime" Value="00:00:02"/>
		</Assertions>
	</Test>
</TestHarness>


exec sf.pUnitTest#Execute																								
			@ObjectName = N'dbo.fPersonDoc#ItemXml'
		,	@DefaultTestOnly = 1


------------------------------------------------------------------------------------------------------------------------------- */
begin
	declare
		@selected                         table															-- stores results of query - SID only
		(
			 PersonNoteSID            int not null      
		)
	declare
		 @ON												bit				= cast(1 as bit)							-- used on bit comparisons to avoid multiple casts
		,@OFF												bit				= cast(0 as bit)							-- used on bit comparisons to avoid multiple casts
		,@forApplicationEntitySID		int																			-- used to get the SID of the app entity from the provided SCD
		
	if @ForApplicationEntitySCD is null or @ForEntitySID is null
	begin

		-- get all the items that don't have a context (they count as being at the root of the person folder structure)

		insert
			@selected
		select
			pn.PersonNoteSID
		from
			dbo.PersonNote pn
		left outer join
			dbo.PersonNoteContext pnc on pn.PersonNoteSID = pnc.PersonNoteSID
		where
			pn.PersonSID = @PersonSID
		and
			pnc.PersonNoteContextSID is null

	end
	else
	begin

		-- get all items matching the entity type and sid

		select
			@forApplicationEntitySID = ae.ApplicationEntitySID
		from
			sf.ApplicationEntity ae
		where
			ae.ApplicationEntitySCD = @ForApplicationEntitySCD

		insert
			@selected
		select
			pn.PersonNoteSID
		from
			dbo.PersonNote pn
		join
			dbo.PersonNoteContext pnc on pn.PersonNoteSID = pnc.PersonNoteSID 
		and 
			pnc.ApplicationEntitySID = @forApplicationEntitySID
		and
			pnc.EntitySID = @ForEntitySID
		where
			pn.PersonSID = @PersonSID

	end

	return
	(
    select 
			 pn.PersonNoteSID				[@PersonNoteSID]
			,case
				when pn.NoteTitle is not null and sf.fContainsInvalidXmlChars(pn.NoteTitle) = @ON then sf.fStripInvalidXmlChars(pn.NoteTitle, '')
				when pn.NoteTitle is not null then pn.NoteTitle
        when len(pn.NoteContent) > 65 and sf.fContainsInvalidXmlChars(pn.NoteContent) = @ON then left(sf.fStripInvalidXmlChars(pn.NoteContent, ''), 62) + '...'
        when sf.fContainsInvalidXmlChars(pn.NoteContent) = @ON then sf.fStripInvalidXmlChars(pn.NoteContent, '')
        when len(pn.NoteContent) > 65 then left(pn.NoteContent, 62) + '...'
        else pn.NoteContent
      end                   	[@Name]
			,pn.PersonNoteTypeLabel	[@NoteType]			
			,pn.IsDeleteEnabled			[@IsDeleteEnabled]      
			,pn.UpdateTime					[@Date]
      ,pn.CreateUser					[@CreatedBy]
			,pn.UpdateUser					[@UpdatedBy]
			,pn.TagList							[TagList]
			,(
				select
					 pnc.EntitySID							[@EntitySID]
					,ae.ApplicationEntityName		[@EntityName]
					,ae.ApplicationEntitySCD		[@EntitySCD]
				from
					dbo.PersonNoteContext pnc
				join
					sf.ApplicationEntity ae on pnc.ApplicationEntitySID = ae.ApplicationEntitySID
				where
					pnc.PersonNoteSID = pn.PersonNoteSID
				for xml path('Context'), type
			) NoteContexts																											-- in this case we use an alias since we want the collection wrapped in an element
		from
			dbo.vPersonNote pn
		join
			@selected s on pn.PersonNoteSID = s.PersonNoteSID
		where
			pn.IsReadGranted = @ON
		for xml path('Item')
	)

end
GO
