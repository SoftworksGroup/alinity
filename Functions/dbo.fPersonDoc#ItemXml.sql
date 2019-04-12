SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fPersonDoc#ItemXml]
(
	 @PersonSID												int																	-- the id of the person to retrieve documents for
	,@ForApplicationEntitySCD					varchar(50)													-- the entity to restrict docs to (if null will get docs without context entries)
	,@ForEntitySID										int																	-- the entity id to restrict docs to (ignored if entity scd is null)
) returns xml
as
/*********************************************************************************************************************************
Function	: Person Doc - Item XML
Notice		: Copyright © 2017 Softworks Group Inc.
Summary		: returns an XML fragment (0..* Item elements but NO root element) for use with other functions or views
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Kris Dawson	| Feb	2017		| Initial version
					: Cory Ng			| Nov 2018		| Returned IsPrimary bit with context, used by UI to branch on showing title or type

Comments	
--------
This function is used to get item XML, based on PersonDoc entities, to populate a larger XML document made up of folders and 
items.

IsReadGranted is checked, documents where this is 0 are excluded so MAKE SURE your session is set before use.

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
					,@personDocTypeSID		int
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
						@personDocTypeSID = pdt.PersonDocTypeSID
				from
					dbo.PersonDocType pdt
				where
					pdt.PersonDocTypeSCD = 'TRANSCRIPT'

				-- Select a random person
				select top 1
					@personSID = p.PersonSID
				from
					sf.person p
				order by
					newid()

					insert into dbo.PersonDoc
					(
							PersonSID
						,	PersonDocTypeSID
						,	DocumentTitle
						,	DocumentContent
						, FileTypeSCD
						,	FileTypeSID
					)
					select
							@personSID
						,	@personDocTypeSID
						,	'*** TEST ***'
						,	cast('*** TEST ***' as varbinary)
						,	@fileTypeSCD
						,	@fileTypeSID
						
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
					@itemXml =	dbo.fPersonDoc#ItemXml(@personSID, null, null)

				select
					@itemXml
				select 
						n.t.value('@Name',						'nvarchar(max)') Name
					,	n.t.value('@PersonDocSID',		'nvarchar(max)') PersonDocSID
					,	n.t.value('@DocType',					'nvarchar(max)') DocType
					, n.t.value('@IsDeleteEnabled',	'nvarchar(max)') IsDeleteEnabled
					,	n.t.value('@IsRemoved',				'nvarchar(max)') IsRemoved
					,	n.t.value('@Date',						'nvarchar(max)') Date
					,	n.t.value('@UploadedBy',			'nvarchar(max)') UploadedBy
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
			<Assertion Type="ScalarValue"	ResultSet="3" Row="1" Column="3" Value="Mark Transcript" />
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
			 PersonDocSID             int not null      
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
			pd.PersonDocSID
		from
			dbo.PersonDoc pd
		left outer join
			dbo.PersonDocContext pdc on pd.PersonDocSID = pdc.PersonDocSID
		where
			pd.PersonSID = @PersonSID
		and
			pdc.PersonDocContextSID is null

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
			pd.PersonDocSID
		from
			dbo.PersonDoc pd
		join
			dbo.PersonDocContext pdc on pd.PersonDocSID = pdc.PersonDocSID 
		and 
			pdc.ApplicationEntitySID = @forApplicationEntitySID
		and
			pdc.EntitySID = @ForEntitySID
		where
			pd.PersonSID = @personSID

	end

	return
	(
		select 
			 pd.PersonDocSID				[@PersonDocSID]
			,case 
				when pd.IsPrimary = @ON then pd.DocumentTitle
				when pd.AdditionalInfo is not null then pd.PersonDocTypeLabel +  ' - ' + pd.AdditionalInfo
				else pd.PersonDocTypeLabel
			 end										[@Name]
			,pd.PersonDocTypeLabel	[@DocType]
			,pd.IsDeleteEnabled			[@IsDeleteEnabled]
      ,pd.IsRemoved           [@IsRemoved]
			,pd.UpdateTime					[@Date]
			,pd.UpdateUser					[@UploadedBy]
			,(
				select
					 pdc.EntitySID							[@EntitySID]
					,ae.ApplicationEntityName		[@EntityName]
					,ae.ApplicationEntitySCD		[@EntitySCD]
				from
					dbo.PersonDocContext pdc
				join
					sf.ApplicationEntity ae on pdc.ApplicationEntitySID = ae.ApplicationEntitySID
				where
					pdc.PersonDocSID = pd.PersonDocSID
				for xml path('Context'), type
			) DocContexts
		from
			dbo.vPersonDoc pd
		join
			@selected s on pd.PersonDocSID = s.PersonDocSID
		where
			pd.IsReadGranted = @ON
		and
			isnull(datalength(pd.DocumentContent), 0) > 0
		and
			pd.IsReportPending = @OFF
		and
			pd.IsReportCancelled = @OFF
		for xml path('Item')
	)

end
GO
