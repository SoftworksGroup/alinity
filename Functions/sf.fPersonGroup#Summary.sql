SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION sf.fPersonGroup#Summary (@IsActiveOnly bit, @TagSID int)
returns table
as
/*********************************************************************************************************************************
TableFcn	: Person Group - Summary
Notice		: Copyright © 2018 Softworks Group Inc.
Summary		: Returns columns for displaying/reporting summary information about Person Groups
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-------------------------------------------------------------------------------------------
					: Tim Edlund  | Aug 2018		|	Initial version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This table function is used for reporting and querying on Person Groups. It includes the main columns from the entity with
the tag values presented as a comma delimited list (via #TagList sub-view).  Some totals on the member count within each
group are also provided.  The @TagSID criteria is a derived column (row number) assigned to each tag returned by 
sf.vPersonGroup#TagSummary. This value is typically a selection criteria in reports but can be left null or passed as -1
to avoid filtering by tag.

Example
-------
<TestHarness>
	<Test Name = "Random" Description="Returns group information for 1 group selected at random.">
	<SQLScript>
	<![CDATA[

declare @personGroupSID int;

select top (1)
	@personGroupSID = pg.PersonGroupSID
from
	sf.PersonGroup pg
order by
	newid();

if @@rowcount = 0 or @personGroupSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin
	select x.* from sf.fPersonGroup#Summary(0, null) x where x.PersonGroupSID = @personGroupSID;
end;
	]]>
	</SQLScript>
	<Assertions>
		<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
		<Assertion Type="ExecutionTime" Value="00:00:03" />
	</Assertions>
	</Test>
	<Test Name = "All" Description="Returns all active groups.">
	<SQLScript>
	<![CDATA[
select x.* from sf.fPersonGroup#Summary(1,null) x;
	]]>
	</SQLScript>
	<Assertions>
		<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
		<Assertion Type="ExecutionTime" Value="00:00:30" />
	</Assertions>
	</Test>
	<Test Name = "ForATagSID" Description="Returns group information where group has matching tag.">
	<SQLScript>
	<![CDATA[

declare @tagSID int;

select top (1)
	@tagSID = pgts.TagSID
from
	sf.vPersonGroup#TagSummary pgts
order by
	newid();

if @@rowcount = 0 or @tagSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin
	select x.* from sf.fPersonGroup#Summary(0, @tagSID) x 
end;
	]]>
	</SQLScript>
	<Assertions>
		<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
		<Assertion Type="ExecutionTime" Value="00:00:03" />
	</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'sf.fPersonGroup#Summary'
	,@DefaultTestOnly = 1	
------------------------------------------------------------------------------------------------------------------------------- */
return
(
	select
		pg.PersonGroupSID
	 ,pg.PersonGroupName
	 ,(case
			 when pg.IsSmartGroup = cast(1 as bit) then cast(null as int)
			 else
		 (
			 select
					count(1)
			 from
					sf.PersonGroupMember pgm
			 where
				 pgm.PersonGroupSID = pg.PersonGroupSID
		 )
		 end
		)																							 CurrentMemberCount
	 ,cast(0 as int)																 MembersRequiringReplacement
	 ,pg.IsDocumentLibraryEnabled
	 ,pgtl.Tags
	 ,sf.fDTOffsetToClientDate(pg.CreateTime)				 GroupCreatedDate
	 ,pg.IsSmartGroup
	 ,pg.QueryLabel																	 SmartGroupQuery
	 ,p.DisplayName																	 GroupOwnerDisplayName
	 ,p.PrimaryEmailAddressSID											 GroupOwnerEmailAddress
	 ,sf.fDTOffsetToClientDate(pg.NextReviewDueDate) NextReviewDate
	 ,pg.IsNextReviewOverdue
	from
		sf.vPersonGroup					pg
	join
		sf.vPersonGroup#TagList pgtl on pg.PersonGroupSID = pgtl.PersonGroupSID
	join
		sf.vPerson							p on pg.PersonSID					= p.PersonSID
	left outer join
	(
		select
			pgtd.PersonGroupSID
		 ,pgts.TagSID
		from
			sf.vPersonGroup#TagSummary pgts
		join
			sf.vPersonGroup#TagDetail	 pgtd on pgts.Tag = pgtd.Tag
		where
			pgts.TagSID = isnull(@TagSID, -1)
	)													tags on pg.PersonGroupSID = tags.PersonGroupSID
	where
		(pg.IsActive = @IsActiveOnly or isnull(@IsActiveOnly, 0) = 0) and (@TagSID is null or @TagSID = -1 or tags.TagSID is not null)
);
GO
