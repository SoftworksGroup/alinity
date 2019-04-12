SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fHashString]
(
		@SaltForHash						nvarchar(50)																	-- GUID to use to build salt value
	,	@String									nvarchar(50)																	-- string to hash
)
returns varbinary(8000)
as
/*********************************************************************************************************************************
ScalarF	: Hash String
Notice  : Copyright © 2017 Softworks Group Inc.
Summary	: Returns the string hashed including insertion of salt values within the string prior to hashing
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|---------------------------------------------------------------------------------------------
				: Tim Edlund  | Apr 2017		|	Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function follows a standard SGI algorithm for salting a string value passed in and then returning the resulting string
hashed using an SHA1 algorithm.  The salt value is expected to be a GUID converted to an nvarchar.  4 "-" characters in th
@SaltForHash are expected. 
Example
-------

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Selects a GUID at random and uses it to return a string hashed.">
		<SQLScript>
			<![CDATA[
			
declare
		@saltForHash						nvarchar(50)			
	,	@string									nvarchar(50) = 'clpna@als'
	,	@userName								nvarchar(75)

select top (1)
		@userName			= au.UserName
	,	@saltForHash	= cast(au.RowGUID as nvarchar(50))
from
	sf.ApplicationUser au
order by
	newid()	

select
		@userName															UserName
	,	@saltForHash													SaltForHash
	,	@string																StringToHash
	,	sf.fHashString(@saltForHash, @string)	HashedString
	 
]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1" />
			<Assertion Type="ExecutionTime" Value="00:00:01" ResultSet="1"/>
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
		@ObjectName				= 'sf.fHashString'
	,	@DefaultTestOnly	= 1

------------------------------------------------------------------------------------------------------------------------------- */
begin

	declare
			@hashedString					varbinary(8000)																-- return value						
		,	@saltPart0						nvarchar(20)																	-- components to insert in string prior to hashing:
		,	@saltPart1						nvarchar(20)
		,	@saltPart2						nvarchar(20)
		,	@saltPart3						nvarchar(20)
		,	@saltPart4						nvarchar(20)
		, @template							nvarchar(500) = 's{0}Y{1}N{2}0{3}p{4}t{5}3C'	-- template to receive salt value inserts

	select 
			@saltPart0 = (case when x.ID = 1 then x.Item else @saltPart0 end)
		,	@saltPart1 = (case when x.ID = 2 then x.Item else @saltPart1 end)
		,	@saltPart2 = (case when x.ID = 3 then x.Item else @saltPart2 end)
		,	@saltPart3 = (case when x.ID = 4 then x.Item else @saltPart3 end)
		,	@saltPart4 = (case when x.ID = 5 then x.Item else @saltPart4 end)
	from 
		sf.fSplitString(lower(@SaltForHash), '-')	x														-- must be lowercase to match with front-end hash algorithm

	set @template = replace(@template, '{0}', @String)
	set @template = replace(@template, '{1}', @saltPart0)
	set @template = replace(@template, '{2}', @saltPart1)
	set @template = replace(@template, '{3}', @saltPart2)
	set @template = replace(@template, '{4}', @saltPart3)
	set @template = replace(@template, '{5}', @saltPart4)

	set @hashedString = hashbytes('SHA1', @template)

	return(@hashedString)

end
GO
