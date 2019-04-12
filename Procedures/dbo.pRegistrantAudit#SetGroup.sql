SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE  [dbo].[pRegistrantAudit#SetGroup]
	 @AuditTypeSID				int																								-- the type of audit to assign
	,@RegistrationYear		smallint																					-- the year to assign to the audit
	,@AuditGroup					xml																								-- a document of registrant SID's to create audits for
as
/*********************************************************************************************************************************
Procedure : Registrant Audit - Set Group
Notice    : Copyright © 2017 Softworks Group Inc.
Summary   : Creates dbo.RegistrantAudit records for the list of registrant keys passed in.
-----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)				| Month Year  | Change Summary
				 : ----------------	|	----------	| --------------
				 : Tim Edlund				| Apr 2017    | Initial version
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure saves a list of registrants to be audited.  Records in the dbo.RegistrantAudit table are created - one per 
registrant included in the @AuditGroup (xml) document.

A preliminary list of registrants to be audited is typically returned through the dbo.pRegistrantAudit#GetGroup procedure. That
list is then refined (registrants added and removed) by the user.  When the list is confirmed for auditing, the UI transfers
the list of associated Registrant SID's into an XML document and passed that along with the audit type (@AuditTypeSID) and the 
year to audit (@RegistrationYear) to this procedure which creates the records in the database.  The format of the XML expected
is as follows:

declare
		@auditGroup xml = N'
<AuditGroup>
	<Registrants>
		<Registrant SID="12345" />
		<Registrant SID="12355" />
		<Registrant SID="12356" />
		<Registrant SID="12313" />
	</Registrants>
</AuditGroup>'

select @auditGroup AuditGroup

Example
-------

<TestHarness>
	<Test Name="FileAsName" IsDefault="true" Description="Select a full name at random from the person view and then search for it through the procedure.">
		<SQLScript>
			<![CDATA[

-- TODO: Tim

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:01" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.pRegistrantAudit#SetGroup'
-------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on

	declare
		 @errorNo												int = 0																-- 0 no error, <50000 SQL error, else business rule
		,@errorText											nvarchar(4000)												-- message text (for business rule errors)
		,@blankParm											nvarchar(100)													-- error checking buffer for required parameters
		,@OFF														bit = cast(0 as bit)									-- used on bit comparisons to avoid multiple casts	
		,@i															int																		-- loop index
		,@maxRows												int																		-- loop limit
		,@registrantSID									int																		-- next registrant key to process
		,@registrantLabel								nvarchar(100)													-- name of registrant (used in messaging)

	declare
		@work														table																	-- a table to hold keys to process
		(
			 ID														int			not null identity(1,1)
			,RegistrantSID								int			not null
		)

	begin try

		-- check parameters

		if @RegistrationYear	is null set @blankParm = '@RegistrationYear'
		if @AuditTypeSID			is null set @blankParm = '@AuditTypeSID'		
		if @AuditGroup				is null set @blankParm = '@AuditGroup'

		if @blankParm is not null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= @blankParm

			raiserror(@errorText, 18, 1)
		
		end

		insert
			@work
		(
			RegistrantSID
		)
		select
			Registrant.r.value('@SID', 'int')   RegistrantSID
		from
			@auditGroup.nodes('//Registrant') Registrant(r)

		set @maxRows = @@rowcount
		set @i			 = 0

		if @maxRows = 0
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@AuditGroup'

			raiserror(@errorText, 16, 1)

		end

		-- validate the candidate list before creating any audits

		while @i < @maxRows
		begin

			set @i += 1	

			select 
				@registrantSID = w.RegistrantSID 
			from 
				@work w 
			where 
				w.ID = @i

			if dbo.fRegistrant#IsEligibleForAudit(@registrantSID, @AuditTypeSID, @RegistrationYear) = @OFF
			begin

				select
					 @registrantLabel = r.RegistrantLabel
				from
					dbo.vRegistrant	r		
				where
					r.RegistrantSID = @RegistrantSID

				exec sf.pMessage#Get
					 @MessageSCD  	= 'RegistrantInvalidForAudit'
					,@MessageText 	= @errorText output
					,@DefaultText 	= N'The registrant "%1" cannot be selected for audit. To be eligible for audits the registrant must have: an active user account, and either be directly selected for audit or have an active license. In addition, the registrant must not already have an audit of the same type for the registration year.'
					,@Arg1					= @registrantLabel


				raiserror(@errorText, 16, 1)

			end
		end

		-- the list is valid, so create the audit records

		set @i = 0

		while @i < @maxRows
		begin

			set @i += 1	

			select 
				@registrantSID = w.RegistrantSID 
			from 
				@work w 
			where 
				w.ID = @i

			exec dbo.pRegistrantAudit#Insert
				 @RegistrantSID			= @registrantSID
				,@AuditTypeSID			= @AuditTypeSID
				,@RegistrationYear	= @RegistrationYear

		end


	end try

	begin catch
		if @@trancount > 0 rollback
		exec @errorNo = sf.pErrorRethrow																			-- catch the error, rollback if pending, and re-throw
	end catch

	return(@errorNo)

end
GO
