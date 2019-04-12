SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fPersonNote#PaymentFolderXml]
(
	 @PersonSID												int																	-- the id of the person to retrieve notes for
) returns xml
as
/*********************************************************************************************************************************
Function	: Person Note - Payment Folder XML
Notice		: Copyright © 2017 Softworks Group Inc.
Summary		: returns an XML fragment (0..* Folder elements but NO root element) for use with other functions or views
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Kris Dawson	| Oct	2017		| Initial version

Comments	
--------
This function is used to get 0..* Folder elements for Payments belonging to the provided person and their related
notes as nested Item elements.

IsReadGranted is checked, notes where this is 0 are excluded so MAKE SURE your session is set before use.

Example
-------
<TestHarness>
	<Test Name="Single" Description="returns 1 record at random from the view">
		<SQLScript>
		<![CDATA[

					declare
					 @applicationUserSID		int
					,@userName							nvarchar(75)
					,@personNoteTypeSID			int
					,@personNoteSID					int
					,@paymentTypeSID				int
					,@personSID							int
					,@applicationEntitySID	int
					,@paymentStatusSID			int
					,@glAccountCode					varchar(50)
					,@paymentSID						int
					,@xml										xml
					,@docHandle							int	

				begin tran
				
				
				select
						@paymentTypeSID = pt.PaymentTypeSID
					,	@glAccountCode	= pt.GLAccountCode
				from
					dbo.vPaymentType pt
				where
					pt.PaymentTypeSCD = 'CASH'

				select top 1
					@personSID = p.PersonSID
				from
					sf.Person p
				order by
				 newid()
				
				select top 1
					@paymentStatusSID = ps.PaymentStatusSID
				from
					dbo.PaymentStatus ps
				order by
					newid()

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
					ae.ApplicationEntitySCD = 'dbo.Payment'

				insert into dbo.Payment
				(
						PersonSID
					,	PaymentTypeSID
					, PaymentStatusSID
					, GLAccountCode
					, AmountPaid
				)
				select
						@personSID
					,	@PaymentTypeSID
					, @paymentStatusSID
					,	@glAccountCode
					, 0


				set @paymentSID = scope_identity()

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
					,	@paymentSID

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
					@xml = dbo.fPersonNote#PaymentFolderXml(@PersonSID)
				
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
					,	n.t.value('@EntityName', 'varchar(255)') Payment
					,	n.t.value('@EntitySCD', 'varchar(100)') [dbo.Payment]
				from
					@xml.nodes('Folder/Item/NoteContexts/Context') n(t)

				if @@ROWCOUNT = 0 raiserror('* ERROR: no data found for test case',16,1) 
				if @@TRANCOUNT > 0 rollback


			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1" />
			<Assertion Type="ScalarValue" ResultSet="3" Row="1" Column="2" Value="dbo.Payment" />
			<Assertion Type="ScalarValue" ResultSet="4" Row="1" Column="2" Value="Comment" />
			<Assertion Type="ScalarValue" ResultSet="4" Row="1" Column="3" Value="*** TEST ***" />
			<Assertion Type="ScalarValue" ResultSet="5" Row="1" Column="2" Value="Payment " />
			<Assertion Type="ScalarValue" ResultSet="5" Row="1" Column="3" Value="dbo.Payment" />
			<Assertion Type="ExecutionTime" Value="00:00:02"/>
		</Assertions>
	</Test>
	<Test Name="All" IsDefault="True"  Description="returns all records from the view.">
		<SQLScript>
			<![CDATA[
					declare
					 @applicationUserSID	int
					,@userName						nvarchar(75)

				begin tran
					
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
				 ,dbo.fPersonNote#PaymentFolderXml(p.PersonSID) xml
				from
					sf.Person p;
				
				if @@ROWCOUNT = 0 raiserror('* ERROR: no data found for test case',16,1) 
				if @@TRANCOUNT > 0 rollback

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1" />
			<Assertion Type="ExecutionTime" Value="00:00:80"/>
		</Assertions>
	</Test>	
</TestHarness>

exec sf.pUnitTest#Execute
  @ObjectName = 'dbo.fPersonNote#PaymentFolderXml'
 ,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */
begin
	
	return
	(
		select
			 pa.PaymentSID	           				[@EntitySID]
			,'dbo.Payment'				          	[@EntitySCD]
			,pa.PaymentShortLabel       			[@Name]
			,dbo.fPersonNote#ItemXml(@PersonSID, 'dbo.Payment', pa.PaymentSID)
		from
			sf.Person p
		join
			dbo.vPayment pa on pa.PersonSID = p.PersonSID
		where
			p.PersonSID = @PersonSID
		for xml path('Folder')
	)

end
GO
