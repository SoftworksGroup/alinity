SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[pSetup$Recommendation]
	 @SetupUser											nvarchar(75)											      -- user assigned to audit columns
	,@Language                      char(2)                                 -- language to install for
	,@Region                        varchar(10)         										-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup Recommendation data
Notice   : Copyright © 2012 Softworks Group Inc.
Summary  : Sets dbo.Recommendation master table with starting (sample) values
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year  | Change Summary
				 : ------------ | ------------|-------------------------------------------------------------------------------------------
				 : Tim Edlund		| Jun 2017		| Initial Version				 
				
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------
This procedure inserts a few records into the dbo.Recommendation table as examples of the types of values the user can create in
their configuration.  If the procedure detects existing data for any recommendation-group, it avoids making the insert. Existing
row values are never updated.

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully.">
		<SQLScript>
		<![CDATA[
		
			exec dbo.pSetup$Recommendation
				 @SetupUser = 'system@alinityapp.com'
				,@Language = 'EN'
				,@Region = 'CA'

			select * from dbo.vRecommendation

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$Recommendation'
	,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */

set nocount on
																																																																			
begin  

	declare
		 @errorNo															int = 0                         -- 0 no error, if < 50000 SQL error, else business rule
		,@errorText														nvarchar(4000)                  -- message text (for business rule errors)
		,@sourceCount													int                             -- count of rows in the source table
		,@targetCount													int                             -- count of rows in the target table

	declare
		@setup																table
		(
			 ID																	int           identity(1,1)
			,RecommendationSCD	varchar(15)			not null
			,ButtonLabel				nvarchar(20)		not null
		)

	begin try

		if not exists( select 1 from dbo.vRecommendation r where r.RecommendationGroupSCD ='APP.REVIEW' )		-- for full list of SCD's see dbo.pSetup$RecommendationGroup
		begin

			insert
				dbo.Recommendation
			(
				 RecommendationGroupSID
				,ButtonLabel
				,CreateUser
				,UpdateUser
			)
				select
						rg.RecommendationGroupSID
					,	N'Confirmed'
					,@SetupUser
					,@SetupUser
				from
					dbo.RecommendationGroup rg
				where
					rg.RecommendationGroupSCD = 'APP.REVIEW'

			insert
				dbo.Recommendation
			(
				 RecommendationGroupSID
				,ButtonLabel
				,CreateUser
				,UpdateUser
			)
				select
						rg.RecommendationGroupSID
					,	N'Not Confirmed'
					,@SetupUser
					,@SetupUser
				from
					dbo.RecommendationGroup rg
				where
					rg.RecommendationGroupSCD = 'APP.REVIEW'
					
		end

		if not exists( select 1 from dbo.vRecommendation r where r.RecommendationGroupSCD ='RENEWAL.REVIEW' )	
		begin

			insert
				dbo.Recommendation
			(
				 RecommendationGroupSID
				,ButtonLabel
				,CreateUser
				,UpdateUser

			)
				select
						rg.RecommendationGroupSID
					,	N'Verified'
					,@SetupUser
					,@SetupUser
				from
					dbo.RecommendationGroup rg
				where
					rg.RecommendationGroupSCD = 'RENEWAL.REVIEW'

			insert
				dbo.Recommendation
			(
				 RecommendationGroupSID
				,ButtonLabel
				,CreateUser
				,UpdateUser
			)
				select
						rg.RecommendationGroupSID
					,	N'Failed'
					,@SetupUser
					,@SetupUser
				from
					dbo.RecommendationGroup rg
				where
					rg.RecommendationGroupSCD = 'RENEWAL.REVIEW'
					
		end

		if not exists( select 1 from dbo.vRecommendation r where r.RecommendationGroupSCD ='AUDIT.REVIEW' )
		begin

			insert
				dbo.Recommendation
			(
				 RecommendationGroupSID
				,ButtonLabel
				,CreateUser
				,UpdateUser
			)
				select
						rg.RecommendationGroupSID
					,	N'Verified'
					,@SetupUser
					,@SetupUser
				from
					dbo.RecommendationGroup rg
				where
					rg.RecommendationGroupSCD = 'AUDIT.REVIEW'

			insert
				dbo.Recommendation
			(
				 RecommendationGroupSID
				,ButtonLabel
				,CreateUser
				,UpdateUser
			)
				select
						rg.RecommendationGroupSID
					,	N'Failed'
					,@SetupUser
					,@SetupUser
				from
					dbo.RecommendationGroup rg
				where
					rg.RecommendationGroupSCD = 'AUDIT.REVIEW'
					
		end

	end try

	begin catch
		exec @errorNo = sf.pErrorRethrow
	end catch
		
	return(@errorNo)

end
GO
