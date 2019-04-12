SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pQuery#TableCheck]
	  @QuerySID						int							= null														-- query to run table check against
	 ,@ErrorText					nvarchar(4000)	= null output											-- error text output from this procedure
as
/*********************************************************************************************************************************
Procedure : Query Table Check
Notice    : Copyright © 2014 Softworks Group Inc.
Summary   : Stub procedure to allow product specific tables checks to occur prior to query execution.
History   : Author(s)   | Month Year  | Change Summary
          : ------------|-------------|-----------------------------------------------------------------------------------------
          : Cory Ng		  | Jul 2016    | Initial version

Comments  
--------
This procedure is used to check if the tables used in the query are up to date. The procedure is executed prior to query
execution (sf.pQuery#Execute). This procedure is a stub in the framework project but is intended to be overwritten for product 
specific checks. In Synoptec's case data mart tables can be referenced by queries, it is important to check if the tables are 
up to date at the time the queries are executed.

Errors related to the table check are set to the error text which is then thrown in the sf.pQuery#Execute sproc. This is required
to avoid the "Cannot use the ROLLBACK statement within an INSERT-EXEC statement." error from EF.

Example
-------

<TestHarness>
	<Test Name="Simple" IsDefault="true" Description="Take a query at random and run the table check and output any errors">
		<SQLScript>
			<![CDATA[

				declare
					 @errorText	nvarchar(4000)
					,@querySID	int

				select
					@querySID = q.QuerySID
				from
					sf.Query q
				order by
					newid()

				exec sf.pQuery#TableCheck
					 @QuerySID	= @querySID
					,@ErrorText	= @errorText output

				select @errorText

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="ExecutionTime" Value="00:00:30" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.pQuery#TableCheck'

-------------------------------------------------------------------------------------------------------------------------------- */

set nocount on

begin

  declare
		 @errorNo                                      int = 0								-- 0 no error, <50000 SQL error, else business rule

	set @ErrorText = null

  return(@errorNo)

end
GO
