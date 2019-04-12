SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pEmailMessage#GetMergeFields]
	 @EmailMessageSID													int					= null						-- key of email message to return values for
	,@ApplicationEntitySCD										varchar(50) = null						-- alternate parameter - system code of data source
	,@ApplicationEntitySID										int					= null						-- alternate parameter - PK of data source
as
/*********************************************************************************************************************************
Procedure : Email Message - Get Merge Fields
Notice    : Copyright © 2015 Softworks Group Inc.
Summary   : Returns merge field tokens to the user interface for composing email
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|---------------------------------------------------------------------------------------------
				: Tim Edlund	| Apr		2015	| Initial Version
				: Cory Ng			| Jul		2015	| Return a field name without the [@ ] to allow for quicker navigation to the required field
				: Russ Poirier| Feb   2017  | Query now only brings in fields from Application Entity that vPersonEmailMessage
																			is lacking. Query excludes xml and unique identifiers.

Comments
--------
This procedure is called by email composition screens to provide a list of merge fields that can be used in the email text.
Merge fields are replaced during the sending process so that, for example, [@DisplayName] is replaced with "Tim Edlund" before
the message is sent.

This procedure allow either @EmailMessageSID to be passed to lookup a replace source Application Entity - e.g. dbo.vEpisode,
dbo.vRegistration etc., or the @ApplicationEntitySCD or @ApplicationEntitySID may be passed directly. Note that it is acceptable
for no parameter to be provided. This is because an Application Entity on the email is optional but may be used to specify an
additional source for replacement of merge fields. All emails automatically receive the fields from sf.vPersonEmailMessage as a
replacement source.

In addition to returning merge fields for the data tables, the set of environment merge fields (e.g. [@@Date], [@@Time], etc.
is also returned. Descriptions for each merge field available is also included in the resulting data set.

Example:
--------

<TestHarness>
	<Test Name="Random" IsDefault="true" Description="Selects 1 email message at random and calls
	procedure to return merge fields.">
		<SQLScript>
			<![CDATA[

declare
	@EmailMessageSID int

select top (1)
	@EmailMessageSID = em.EmailMessageSID
from
	sf.EmailMessage em
order by
	newid()

if @EmailMessageSID is null
begin
	raiserror( N'* ERROR: no sample data found to run test', 18, 1)
end
else
begin

	exec sf.pEmailMessage#GetMergeFields
		@EmailMessageSID = @EmailMessageSID

end
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:02" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.pEmailMessage#GetMergeFields'

-------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on

	declare
		 @errorNo													int = 0																												-- 0 no error, <50000 SQL error, else business rule
		,@errorText												nvarchar(4000)																								-- message text (for business rule errors)
		,@environmentVariableLabel				nvarchar(128)																									-- label to use with environment variables
		,@schemaAndViewName								nvarchar(257)																									-- entity to search for

	begin try

		if @EmailMessageSID is not null
		begin

			-- check for a merge data source other than the default
			-- person email message entity (not an error if not defined)

			select
				 @ApplicationEntitySCD = ae.ApplicationEntitySCD
			from
				sf.EmailMessage				em
			join
				sf.ApplicationEntity	ae	on em.ApplicationEntitySID = ae.ApplicationEntitySID
			where
				em.EmailMessageSID = @EmailMessageSID

		end
		else if @ApplicationEntitySCD is not null
		begin

			select
				 @ApplicationEntitySID	= ae.ApplicationEntitySID
			from
				sf.ApplicationEntity	ae
			where
				ae.ApplicationEntitySCD = @ApplicationEntitySCD

			if @ApplicationEntitySID is null
			begin

				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record SCD = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'Application Entity'
					,@Arg2        = @ApplicationEntitySCD

				raiserror(@errorText, 18, 1)
			end

		end
		else if @ApplicationEntitySID is not null
		begin

			select
				 @ApplicationEntitySCD	= ae.ApplicationEntitySCD
			from
				sf.ApplicationEntity	ae
			where
				ae.ApplicationEntitySID = @ApplicationEntitySID

			if @ApplicationEntitySCD is null
			begin

				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record SCD = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'Application Entity'
					,@Arg2        = @ApplicationEntitySID

				raiserror(@errorText, 18, 1)
			end

		end

		set @schemaAndViewName = isnull(replace(@ApplicationEntitySCD, '.', '.v'), N'?')								-- use entity view
		set @environmentVariableLabel = sf.fTermLabel('ENVIRONMENT.VARIABLES', 'Environment Variables')

		-- return data source columns in token format along with
		-- environment merge fields and descriptions

		select
			 x.DataSource
			,x.MergeToken
			,x.MergeFieldName
			,x.[Description]
		from
		(
			(
				select
					N'[@' + vc.ColumnName + ']'																		  MergeToken
					,vc.ColumnName																									MergeFieldName
					,(
					case
						when charindex( N'|', vc.[Description]) > 0 then left(vc.[Description], charindex(N'|', vc.[Description]) - 1)
						else vc.[Description]
					end
					)																															  [Description]
					,cast(sf.fObjectNameSpaced(substring(vc.ViewName, 2, 127)) as nvarchar(128))							  DataSource
				from
					sf.vViewColumn vc
				left outer join
					sf.vViewColumn vc2 on vc.ColumnName = vc2.ColumnName
					and vc2.SchemaAndViewName = 'sf.vPersonEmailMessage'
				where
					vc.SchemaAndViewName = @schemaAndViewName
				and
					vc2.ColumnName is null
				and
					vc.DataType <> 'timestamp'
				and 
					vc.DataType <> 'varbinary'
				and
					vc.DataType <> 'uniqueidentifier'
				and
					vc.DataType <> 'xml'																						-- timestamp, varbinary, xml, and uniqueidentifier  types are not supported!
				and
					vc.ColumnName <> 'IsDeleted'
				union
				select distinct
					N'[@' + vc.ColumnName + ']'																		  MergeToken
					,vc.ColumnName																									MergeFieldName
					,(
						case
							when charindex( N'|', vc.[Description]) > 0 then left(vc.[Description], charindex(N'|', vc.[Description]) - 1)
							else vc.[Description]
						end
					)																															  [Description]
					,cast(sf.fObjectNameSpaced(substring(vc.ViewName, 2, 127)) as nvarchar(128))							  DataSource
				from
					sf.vViewColumn vc
				where
					vc.SchemaAndViewName = N'sf.vPersonEmailMessage'
				and
					vc.DataType <> 'timestamp'
				and 
					vc.DataType <> 'varbinary'
				and
					vc.DataType <> 'uniqueidentifier'
				and
					vc.DataType <> 'xml'																						-- timestamp, varbinary, xml, and uniqueidentifier  types are not supported!
				and
					vc.ColumnName <> 'IsDeleted'
		)
		union
		(
			select
				 emf.MergeToken
				,emf.MergeFieldName
				,emf.[Description]
				,@environmentVariableLabel																				DataSource
			from
				sf.fEnvironment#MergeFields() emf																	-- see this function for list of environmental variables (prefixed with "@@")
		)
	) x
	order by
		x.MergeFieldName


	end try

	begin catch
		exec @errorNo  = sf.pErrorRethrow
	end catch

	return (@errorNo)

end
GO
