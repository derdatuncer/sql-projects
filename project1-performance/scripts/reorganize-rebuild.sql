USE WideWorldImporters;
GO

------------------------------------------------------------
-- 1) REORGANIZE
------------------------------------------------------------
ALTER INDEX CIX_OrderLines_FragDemo_OrderID_StockItemID
ON dbo.OrderLines_FragDemo
REORGANIZE;
GO

SELECT
    'AFTER_REORGANIZE' AS phase,
    OBJECT_NAME(ps.object_id) AS table_name,
    i.name AS index_name,
    ps.avg_fragmentation_in_percent,
    ps.avg_page_space_used_in_percent,
    ps.page_count
FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('dbo.OrderLines_FragDemo'), NULL, NULL, 'DETAILED') ps
INNER JOIN sys.indexes i
    ON ps.object_id = i.object_id
   AND ps.index_id = i.index_id;
GO

------------------------------------------------------------
-- 2) REBUILD
------------------------------------------------------------
ALTER INDEX CIX_OrderLines_FragDemo_OrderID_StockItemID
ON dbo.OrderLines_FragDemo
REBUILD;
GO

SELECT
    'AFTER_REBUILD' AS phase,
    OBJECT_NAME(ps.object_id) AS table_name,
    i.name AS index_name,
    ps.avg_fragmentation_in_percent,
    ps.avg_page_space_used_in_percent,
    ps.page_count
FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('dbo.OrderLines_FragDemo'), NULL, NULL, 'DETAILED') ps
INNER JOIN sys.indexes i
    ON ps.object_id = i.object_id
   AND ps.index_id = i.index_id;
GO