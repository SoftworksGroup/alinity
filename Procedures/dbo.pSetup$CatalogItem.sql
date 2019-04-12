SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pSetup$CatalogItem]
	 @SetupUser											nvarchar(75)											      -- user assigned to audit columns
	,@Language                      char(2)                                 -- language to install for
	,@Region                        varchar(10)         										-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup dbo.CatalogItem data
Notice   : Copyright © 2012 Softworks Group Inc.
Summary  : Updates dbo.CatalogItem table with starting values for the application
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Cory Ng  		| Mar	2018			| Initial Version				 
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------
This procedure ensures a default starting record exists in the dbo.CatalogItem table for startup of the application.  If any 
records are found in the table, then no additional insert is made.

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully. Previous setup data is NOT deleted prior to 
	the test so the test is that 1 default record exists in the table.">
		<SQLScript>
		<![CDATA[

		exec dbo.pSetup$CatalogItem 
			 @SetupUser = N'system@softworksgroup.com'
			,@Language  = 'en'
			,@Region		= 'can'
	
		select * from dbo.CatalogItem

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$CatalogItem'
	,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */

set nocount on
																																																																			
begin  

	declare
		 @errorNo                           int = 0                           -- 0 no error, if < 50000 SQL error, else business rule
		,@errorText                         nvarchar(4000)                    -- message text (for business rule errors)
		,@OFF																bit = cast(0 as bit)							-- constant to refer to "false" bit value
		,@ON																bit = cast(1 as bit)							-- constant to refer to "true" bit value
    ,@defaultGLAccountSID               int                               -- default GL account to assign to all sample catalog items

	begin try
	
		if not exists (select 1 from dbo.CatalogItem)
		begin

      select top 1
        @defaultGLAccountSID = ga.GLAccountSID
      from
        dbo.GLAccount ga
      where
        ga.IsRevenueAccount = @ON

      update
        sf.FileType
      set
        IsActive = @ON
      where
        FileTypeSCD = '.HTML'
      and
        IsActive = @OFF

      exec dbo.pCatalogItem#Insert
          @CatalogItemLabel = 'Admin Fee'
         ,@InvoiceItemDescription = 'Admin fee'
         ,@GLAccountSID = @defaultGLAccountSID
         ,@IsTaxRate1Applied = 0
         ,@CurrentPrice = 25
				 ,@CreateUser = @SetupUser
         
      exec dbo.pCatalogItem#Insert
          @CatalogItemLabel = 'Shipping Fee'
         ,@InvoiceItemDescription = 'Shipping fee'
         ,@GLAccountSID = @defaultGLAccountSID
         ,@IsTaxRate1Applied = 0
         ,@CurrentPrice = 10
				 ,@CreateUser = @SetupUser
         
      exec dbo.pCatalogItem#Insert
          @CatalogItemLabel = 'Disciplinary fine'
         ,@InvoiceItemDescription = 'Disciplinary fine'
         ,@GLAccountSID = @defaultGLAccountSID
         ,@IsTaxRate1Applied = 0
         ,@CurrentPrice = 5000
				 ,@CreateUser = @SetupUser
         
      exec dbo.pCatalogItem#Insert
          @CatalogItemLabel = 'Exam Fee'
         ,@InvoiceItemDescription = 'Exam fee'
         ,@GLAccountSID = @defaultGLAccountSID
         ,@IsTaxRate1Applied = 0
         ,@CurrentPrice = 400
				 ,@CreateUser = @SetupUser
			
		end

	end try

	begin catch
		exec @errorNo = sf.pErrorRethrow
	end catch
		
	return(@errorNo)

end
GO
