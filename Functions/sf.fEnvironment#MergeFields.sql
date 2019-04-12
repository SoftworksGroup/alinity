SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fEnvironment#MergeFields]
()
returns @environmentFields	table
(
	 ID											int							identity(1,1)	
	,MergeToken							varchar(100)		not null
	,MergeFieldName					nvarchar(128)		not null
	,ReplacementValue				nvarchar(max)		not null
	,[Description]					nvarchar(250)		not null
)
as
/*********************************************************************************************************************************
TableF	: Environment Merge Fields
Notice  : Copyright © 2015 Softworks Group Inc.
Summary	: Returns a table of environment variables used in email and note template merges
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund  | Jun	2015			|	Initial Version
				: Cory Ng			| Jul 2016			| Replaced _STG in database name with Test
				: Cory Ng			| Sep	2016			| Stripped out RowGUID placeholder if ApplicationPageURI contains ApplicationPortal
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function is called by procedures requiring merge field tokens and replacement values. It populates a table of merge fields
not related to any table, but rather to the general database environment - e.g. current time and date etc.  The function also 
loads the list of email links and their corresponding application routes from the sf.MessageLink table.  This table is populated
for each product through a setup procedure.

Example
-------

select 
	* 
from 
	sf.fEnvironment#MergeFields()

------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		 @ON                              bit = cast(1 as bit)								-- a constant to reduce repetitive cast syntax in bit comparisons
		,@OFF                             bit = cast(0 as bit)								-- a constant to reduce repetitive cast syntax in bit comparisons
		,@dbName													nvarchar(max)												-- replacement value for sub-domain and DBName
		,@now															nvarchar(30)												-- buffer for current time
		,@now24														nvarchar(30)												-- buffer for current time using 24 hour clock

	set @dbName = lower(db_name())																					-- obtain DB values for easier string manipulation below
	set @now		= convert(nvarchar(30),	sf.fNow(), 100)
	set @now24	= convert(nvarchar(30),	sf.fNow(), 121)

	insert
		@environmentFields
	(
		 MergeToken
		,MergeFieldName
		,ReplacementValue
		,[Description]
	)
	values
		 ('[@@Date]'			, N'Date (e.g. ' + format(sf.fToday(), 'MMMM d, yyyy') + ')'	,format(sf.fToday(), 'MMMM d, yyyy'), cast(N'The current date in your timezone - e.g. ' + format(sf.fToday(), 'MMMM d, yyyy') as nvarchar(250)))
		,('[@@DateM-D-Y]'	, N'Date (e.g. ' + format(sf.fToday(), 'MMM-dd-yyyy')	+ ')'	, format(sf.fToday(), 'MMM-dd-yyyy'), cast(N'The current date in your timezone - e.g. ' + format(sf.fToday(), 'MMM-dd-yyyy') 	as nvarchar(250)))
		,('[@@DateM.D.Y]'	, N'Date (e.g. ' + format(sf.fToday(), 'MMM.dd.yyyy')	+ ')'	, format(sf.fToday(), 'MMM.dd.yyyy'), cast(N'The current date in your timezone - e.g. ' + format(sf.fToday(), 'MMM.dd.yyyy') 	as nvarchar(250)))
		,('[@@DateM/D/Y]'	, N'Date (e.g. ' + format(sf.fToday(), 'MM/dd/yyyy')		+ ')'		, format(sf.fToday(), 'MM/dd/yyyy') , cast(N'The current date in your timezone - e.g. ' + format(sf.fToday(), 'MMM.dd.yyyy') 	as nvarchar(250)))
		,('[@@DateD-M-Y]'	, N'Date (e.g. ' + format(sf.fToday(), 'dd-MMM-yyyy')	+ ')'	, format(sf.fToday(), 'dd-MMM-yyyy'), cast(N'The current date in your timezone - e.g. ' + format(sf.fToday(), 'dd-MMM-yyyy') 	as nvarchar(250)))
		,('[@@DateD-M-Y]'	, N'Date (e.g. ' + format(sf.fToday(), 'dd-MMM-yyyy')	+ ')'	, format(sf.fToday(), 'dd-MMM-yyyy'), cast(N'The current date in your timezone - e.g. ' + format(sf.fToday(), 'dd-MMM-yyyy') 	as nvarchar(250)))
		,('[@@DateD.M.Y]'	, N'Date (e.g. ' + format(sf.fToday(), 'dd.MMM.yyyy')	+ ')'	, format(sf.fToday(), 'dd.MMM.yyyy'), cast(N'The current date in your timezone - e.g. ' + format(sf.fToday(), 'dd.MMM.yyyy') 	as nvarchar(250)))
		,('[@@Time]'			, N'Time (e.g. ' + ltrim(substring(@now	, sf.fCharIndexLast(' ',@now), 8)) + ')',ltrim(substring(@now, sf.fCharIndexLast(' ',@now), 8))		,	cast(N'The current time in your timezone - e.g. ' + ltrim(substring(@now, sf.fCharIndexLast(' ',@now), 8)) as nvarchar(250)))
		,('[@@Time24]'		, N'Time (e.g. ' + ltrim(substring(@now24, sf.fCharIndexLast(' ',@now24), 5)) + ')',ltrim(substring(@now24, sf.fCharIndexLast(' ',@now24), 5)),	cast(N'The current time in your timezone - e.g. ' + ltrim(substring(@now24, sf.fCharIndexLast(' ',@now24), 5)) as nvarchar(250)))
		,('[@@Time24S]'		, N'Time (e.g. ' + ltrim(substring(@now24, sf.fCharIndexLast(' ',@now24), 8)) + ')',ltrim(substring(@now24, sf.fCharIndexLast(' ',@now24), 8)),	cast(N'The current time in your timezone - e.g. ' + ltrim(substring(@now24, sf.fCharIndexLast(' ',@now24), 8)) as nvarchar(250)))
		,('[@@SubDomain]' , N'SubDomain', replace(@dbName, '_stg', 'test'), cast(N'The sub-domain assigned to your website: ' + @dbName as nvarchar(250)))

	insert
		@environmentFields
	(
		 MergeToken
		,MergeFieldName
		,ReplacementValue
		,[Description]
	)
	select
		 '[@@' + cast(replace(sf.fProperCase(el.MessageLinkSCD), N'.', '') as varchar(96)) + ']'
		,N'Email link (' + cast(replace(sf.fProperCase(el.MessageLinkSCD), N'.', '') as varchar(96)) + ')'
		,replace(ap.ApplicationRoute, '[@@SubDomain]', replace(@dbName, '_stg', 'test'))	+ case when charindex('ApplicationPortal', ap.ApplicationPageURI) > 0 then '' else N'/[@RowGUID]' end	-- replacement value includes subdomain of site AND reference to the email row!
		,cast(el.UsageNotes as nvarchar(250))																																-- subdomain can be replaced now but row GUID needs to wait for merge event
	from
		sf.MessageLink			 el
	join
		sf.ApplicationPage ap on el.ApplicationPageSID = ap.ApplicationPageSID

	-- TODO: Tim May 2017
	-- Override for CLPNA - need permanent fix with table of exceptions
	-- for this link or make a direct config param - and use code above
	-- as default if no config param

	update
		@environmentFields
	set
		ReplacementValue = replace(ReplacementValue, 'clpnav6', 'myclpna' )

	return

end
GO
