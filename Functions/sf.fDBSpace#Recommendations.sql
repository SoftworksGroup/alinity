SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION sf.fDBSpace#Recommendations
(
	@BaseFreeRatio		decimal(4, 2) -- factor of free space to target for base data (e.g. 0.50 for 50%)
 ,@SysFreeRatio			decimal(4, 2) -- factor of free space to target for system (dictionary) data
 ,@DocFreeRatio			decimal(4, 2) -- factor of free space to target for documents (file-stream)
 ,@CurrentFileSlack decimal(4, 2) -- factor of slack to allow in current file sizes (0.0 to leave unchanged, 0.10 for 10% slack)
)
returns table
/*********************************************************************************************************************************
Function : DB Space Recommendations
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : Returns resizing recommendations for database files in the current database
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)				| Month Year	| Change Summary
				 : ---------------- + ----------- + --------------------------------------------------------------------------------------
				 : Tim Edlund				| Dec 2018		| Initial version
 
Comments
--------
This table function is used in managing client disk space.  Decimal values reflecting percentage of free disk space to target
after resizing are the parameter values.  Be sure to enter the values as decimals.  For example, if sizing should be 
determined to allow 50% growth in the document file group, the @DocFreeRatio value should be entered as 0.50.

This function is used by the procedure sf.pDB#Resize to create an ALTER script to resize database files to recommended target
free space settings.  This function does not modify the database but can be used for pre-sizing analysis.

Note that for the "Document Indexes" file group, the space is calculated using the @SysFreeRatio parameter but the result
is compared to a value equal to 10% of the new size of the Document Data file group.  The larger of these 2 values is then
applied as the maximum size of the Document Indexes space. Typically document indexing requires roughly 8-10% of the size
of the document storage and in situations where only a handful of documents have been added, using the current size
of the document index can result in the index being too small.

Limitations
-----------
This table function depends entirely on following SGI naming conventions and underlying base view for extraction of 
file-group information.

Example
-------
<TestHarness>
  <Test Name = "ProdServer" IsDefault ="true" Description="Executes the function allow 50% base data growth, 33% system file
	growth and 100% document area growth.  The current file slack is set at 10%.">
    <SQLScript>
      <![CDATA[
select
	dsr.*
from
	sf.fDBSpace#Recommendations(0.50, 0.33, 1.00, 0.10) dsr
order by
	dsr.FileGroup;

		]]>
    </SQLScript>
    <Assertions>
			<Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
      <Assertion Type="ExecutionTime" Value="00:00:02"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.fDBSpace#Recommendations'
 ,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */
as
return
(
	select
		rsz.FileGroup
	 ,rsz.LogicalFileName
	 ,rsz.UsedSpace
	 ,rsz.CurrentFileSize
	 ,(case when rsz.NewFileSize <= rsz.CurrentFileSize then rsz.CurrentFileSize + 1 else rsz.NewFileSize end) NewFileSize
	 ,rsz.CurrentMaxSize
	 ,(case
			 when rsz.NewMaxFileSize <= (case when rsz.NewFileSize <= rsz.CurrentFileSize then rsz.CurrentFileSize + 1 else rsz.NewFileSize end) then
	 (case when rsz.NewFileSize <= rsz.CurrentFileSize then rsz.CurrentFileSize + 1 else rsz.NewFileSize end) + 1
			 else rsz.NewMaxFileSize
		 end
		)																																																				 NewMaxFileSize
	 ,rsz.NewFreeSpaceMB
	 ,rsz.NewFreeSpacePercentage
	from
	(
		select
			fs.FileGroup
		 ,fs.LogicalFileName
		 ,isnull(fs.UsedSpace, fs.CurrentFileSize) UsedSpace
		 ,fs.CurrentFileSize
		 ,cast(case
						 when fs.FileGroup = 'System' and fs.CurrentFileSize < 25 then 25
						 when fs.FileGroup = 'System' then sf.fRoundUpInt((fs.UsedSpace * (1.00 + @CurrentFileSlack)), 0)
						 when fs.FileGroup = 'Log' then fs.CurrentFileSize
						 when fs.FileGroup = 'Document Data' then fs.CurrentFileSize
						 when fs.UsedSpace < 25 then 25
						 else sf.fRoundUpInt((fs.UsedSpace * (1.00 + @CurrentFileSlack)), 0)
					 end as int)												 NewFileSize
		 ,fs.MaxFileSize													 CurrentMaxSize
		 ,(case
				 when mx.NewMaxFileSize < fs.UsedSpace then fs.UsedSpace
				 when fs.FileGroup = 'Document Data' and mx.NewMaxFileSize < 2000 then 2000
				 when fs.FileGroup = 'Document Indexes' and mx.NewMaxFileSize < 75 then 75
				 when fs.FileGroup = 'Base Data' and mx.NewMaxFileSize < 100 then 100
				 when fs.FileGroup = 'Base Indexes' and mx.NewMaxFileSize < 10 then 10
				 when mx.NewMaxFileSize < 50 then 50
				 else mx.NewMaxFileSize
			 end
			)																				 NewMaxFileSize
		 ,cast((case
							when fs.FileGroup = 'Log' then null
							else (((case
												when mx.NewMaxFileSize < fs.UsedSpace then fs.UsedSpace
												when fs.FileGroup = 'Document Data' and mx.NewMaxFileSize < 2000 then 2000
												when fs.FileGroup = 'Document Indexes' and mx.NewMaxFileSize < 75 then 75
												when fs.FileGroup = 'Base Data' and mx.NewMaxFileSize < 100 then 100
												when fs.FileGroup = 'Base Indexes' and mx.NewMaxFileSize < 10 then 10
												when mx.NewMaxFileSize < 50 then 50
												else mx.NewMaxFileSize
											end
										 )
										) - isnull(fs.UsedSpace, fs.CurrentFileSize)
									 )
						end
					 ) as int)													 NewFreeSpaceMB
		 ,cast(case
						 when fs.FileGroup = 'Log' then null
						 else
							 round(
											((((case
														when mx.NewMaxFileSize < fs.UsedSpace then fs.UsedSpace
														when fs.FileGroup = 'Document Data' and mx.NewMaxFileSize < 2000 then 2000
														when fs.FileGroup = 'Document Indexes' and mx.NewMaxFileSize < 75 then 75
														when fs.FileGroup = 'Base Data' and mx.NewMaxFileSize < 100 then 100
														when fs.FileGroup = 'Base Indexes' and mx.NewMaxFileSize < 10 then 10
														when mx.NewMaxFileSize < 50 then 50
														else mx.NewMaxFileSize
													end
												 ) - isnull(fs.UsedSpace, fs.CurrentFileSize)
												) * 1.0
											 ) / (case
															when mx.NewMaxFileSize < fs.UsedSpace then fs.UsedSpace
															when fs.FileGroup = 'Document Data' and mx.NewMaxFileSize < 2000 then 2000.0
															when fs.FileGroup = 'Document Indexes' and mx.NewMaxFileSize < 75 then 75.0
															when fs.FileGroup = 'Base Data' and mx.NewMaxFileSize < 100 then 100.0
															when fs.FileGroup = 'Base Indexes' and mx.NewMaxFileSize < 10 then 10.0
															when mx.NewMaxFileSize < 50 then 50.0
															else mx.NewMaxFileSize
														end
													 )
											) * 100
											--) / (isnull(fs.UsedSpace, (case isnull(fs.CurrentFileSize,0) when 0 then 1 else 0 end)) * 1.0) * 100
										 ,0
										)
					 end as int)												 NewFreeSpacePercentage
		from
			sf.vFileSpace fs
		join
		(
			select
				z.FileGroup
			 ,z.CountOfFiles
			 ,z.TotalFilesSize
			 ,z.UsedSpace
			 ,cast(case
							 when z.FileGroup = 'System' then sf.fRoundUpInt((z.UsedSpace * (1.00 + @SysFreeRatio + (@SysFreeRatio * @SysFreeRatio))) / z.CountOfFiles, 0)
							 when z.FileGroup = 'Log' then 1000
							 when z.FileGroup = 'Document Data' then sf.fRoundUpInt((z.TotalFilesSize * (1.00 + @DocFreeRatio + (@DocFreeRatio * @DocFreeRatio))), -1)
							 when z.FileGroup = 'Document Indexes' then -- minimum size of document indexes must 5% of the available space in the Document Data space
							 (
								 select
										max(v)
								 from
									(
										values
											(sf.fRoundUpInt((z.UsedSpace * (1.00 + @BaseFreeRatio + (@BaseFreeRatio * @BaseFreeRatio))) / z.CountOfFiles, 0))
										 ,(sf.fRoundUpInt( ((0.05 *
																				 (
																					 select
																							max(sf.fRoundUpInt((fs.CurrentFileSize * (1.00 + @DocFreeRatio + (@DocFreeRatio * @DocFreeRatio))), -1))
																					 from
																							sf.vFileSpace fs
																					 where
																						 fs.FileGroup = 'Document Data'
																				 )
																				) / z.CountOfFiles
																			 )
																			,0
																		 )
											)
									) as value (v)
							 )
							 else sf.fRoundUpInt((z.UsedSpace * (1.00 + @BaseFreeRatio + (@BaseFreeRatio * @BaseFreeRatio))) / z.CountOfFiles, 0)
						 end + sf.fRoundUpInt(0.01 * isnull(z.UsedSpace, z.TotalFilesSize), 0) as int) NewMaxFileSize
			from
			(
				select
					fs.FileGroup
				 ,count(fs.FileID) * 1.0																								 CountOfFiles
				 ,sum(case fs.CurrentFileSize when 0 then 1 else fs.CurrentFileSize end) TotalFilesSize
				 ,sum(case fs.UsedSpace when 0 then 1 else fs.UsedSpace end)						 UsedSpace
				from
					sf.vFileSpace fs
				group by
					fs.FileGroup
			) z
		)								mx on fs.FileGroup = mx.FileGroup
	) rsz
);
GO
