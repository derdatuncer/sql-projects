/* ========================================================================
   Dosya: 01_Setup_All.sql
   Amaç: Test ortamı ve büyük test tablolarının yaratılması
======================================================================== */
USE WideWorldImporters;
GO

------------------------------------------------------------
-- 1) DEMO TABLOSUNU OLUŞTURMA (setup-demo.sql'den)
------------------------------------------------------------
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_OrderLines_PerfDemo_OrderID_StockItemID' AND object_id = OBJECT_ID('dbo.OrderLines_PerfDemo'))
BEGIN
    DROP INDEX IX_OrderLines_PerfDemo_OrderID_StockItemID ON dbo.OrderLines_PerfDemo;
END
GO
DROP TABLE IF EXISTS dbo.OrderLines_PerfDemo;
GO

SELECT
    IDENTITY(INT,1,1) AS DemoID, ol.OrderID, ol.StockItemID, ol.Description, ol.Quantity, ol.UnitPrice, ol.PickedQuantity, ol.PickingCompletedWhen
INTO dbo.OrderLines_PerfDemo
FROM Sales.OrderLines AS ol
CROSS JOIN (SELECT TOP 50 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n FROM sys.all_objects) AS x;
GO

SELECT COUNT(*) AS row_count, MIN(OrderID) AS min_order_id, MAX(OrderID) AS max_order_id FROM dbo.OrderLines_PerfDemo;
GO
SELECT TOP 10 DemoID, OrderID, StockItemID, Quantity, UnitPrice, PickingCompletedWhen FROM dbo.OrderLines_PerfDemo ORDER BY DemoID;
GO
SELECT COUNT(DISTINCT OrderID) AS distinct_orders, COUNT(DISTINCT StockItemID) AS distinct_stockitems FROM dbo.OrderLines_PerfDemo;
GO

------------------------------------------------------------
-- 2) FRAGMENTASYON TEST TABLOSUNU OLUŞTURMA (frag-demo-setup.sql'den)
------------------------------------------------------------
DROP TABLE IF EXISTS dbo.OrderLines_FragDemo;
GO

SELECT
    IDENTITY(INT,1,1) AS DemoID, ol.OrderID, ol.StockItemID, ol.Description, ol.Quantity, ol.UnitPrice, ol.PickedQuantity, ol.PickingCompletedWhen
INTO dbo.OrderLines_FragDemo
FROM Sales.OrderLines ol;
GO

CREATE CLUSTERED INDEX CIX_OrderLines_FragDemo_OrderID_StockItemID
ON dbo.OrderLines_FragDemo (OrderID, StockItemID);
GO

SELECT OBJECT_NAME(ps.object_id) AS table_name, i.name AS index_name, ps.index_type_desc, ps.avg_fragmentation_in_percent, ps.avg_page_space_used_in_percent, ps.page_count
FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('dbo.OrderLines_FragDemo'), NULL, NULL, 'DETAILED') ps
INNER JOIN sys.indexes i ON ps.object_id = i.object_id AND ps.index_id = i.index_id
ORDER BY ps.page_count DESC;
GO

------------------------------------------------------------
-- 3) ÖLÇÜM ORTAMI VE CACHE TEMİZLİĞİ
------------------------------------------------------------
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

CHECKPOINT;
DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;
GO
