SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fIsLikeItemInList]
(
	 @StringToCheck           nvarchar(1000)                                -- string to compare to items in the list
	,@ListOfItems             nvarchar(max)                                 -- list of items to compare string to with "like" operator
	,@Delimiter		            nvarchar(15)                                  -- value of the delimiter - e.g. ','
)
returns bit
as
/*********************************************************************************************************************************
ScalarF		: Is Like Item In List
Notice		: Copyright © 2014 Softworks Group Inc.
Summary		: returns bit indicating whether the item passed is "like" one of the item in the list-of-items
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Tim Edlund	| June  2012	|	Initial version

Comments	
--------
This function is used to simplify syntax where an item needs to be compared - using a like operator - to a long list of values.

For example - suppose a case statement is being used to determine if the 1st address field in a clinic address is actually
the clinic name. The Street1 value needs to be compared to many different keywords using a like and "%" characters:

case 
	when clinic.Street1 like '%Clinic%' 
		or clinic.Street1 like '%Hospital%' 
		or clinic.Street1 like '%Rehab%' 
		or clinic.Street1 like '%Centre%' 
		or clinic.Street1 like '%Health%' 
		or clinic.Street1 like '%Medic%' 
		or clinic.Street1 like '%Institut%' 
		or clinic.Street1 like '%Diagn%' 
		or clinic.Street1 like '% Docs%' 
	then cast( 1 as bit)
	...

This result, in turn, as an impact to shift other street addresses up in the address columns requiring the logic to be repeated
many times.  

This function allows the list to compare to, to be defined once and then passed to a function to make the comparisons - greatly
simplifying the syntax.  Other applications exist whenever a value in a table needs to be compared to a lengthy number of 
arguments using a like clause.

Note that the wildcard characters "%", "_", etc. for the LIKE clause MUST BE INCLUDED in the @ListOfItems parameter - see example
below!

Example
-------

declare
	@clinicKeyWords   nvarchar(1000)

set @clinicKeyWords =  N'%Clinic%,%Hospital%,%REHAB%,%Centre%,%Health%,%Medic%,%Institut%,%Diagn%,% Docs%'

select
	sf.fIsLikeItemInList(N'Hello World', @clinicKeyWords, N',')                   IsLikeItemInList

select
	sf.fIsLikeItemInList(N'Rocco Medical Centre', @clinicKeyWords, N',')          IsLikeItemInList
	
select
	clinic.Street1
 ,sf.fIsLikeItemInList(clinic.Street1, @clinicKeyWords, N',')                  Address1IsLikeItemInList
 ,clinic.Street2
 ,sf.fIsLikeItemInList(clinic.Street2, @clinicKeyWords, N',')                  Address2IsLikeItemInList
 ,clinic.Street3
 ,sf.fIsLikeItemInList(clinic.Street3, @clinicKeyWords, N',')                  Address3IsLikeItemInList
from
	SampleData.dbo.AB_Physician_List clinic
where
	clinic.Street1 is not null 
	

------------------------------------------------------------------------------------------------------------------------------- */

begin
	
	declare
		 @isLikeItemInList                bit = cast(0 as bit)                 -- return value - 1 if "like" an item in the list

	if exists
	( 
	select
		1
	from
		sf.fSplitString(@ListOfItems, @Delimiter) x
	where
		@StringToCheck like isnull(x.Item , '~!~@~#~$~%^&*()_+')
	) set @isLikeItemInList = cast(1 as bit)

	return( @islikeItemInList )

end
GO
