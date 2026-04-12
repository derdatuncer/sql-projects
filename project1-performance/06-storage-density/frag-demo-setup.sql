USE WideWorldImporters;
GO

------------------------------------------------------------
-- 1) TEMİZLİK
------------------------------------------------------------
DROP TABLE IF EXISTS dbo.OrderLines_FragDemo;
GO

------------------------------------------------------------
-- 2) TABLOYU OLUŞTUR
------------------------------------------------------------
SELECT
    IDENTITY(INT,1,1) AS DemoID,
    ol.OrderID,
    ol.StockItemID,
    ol.Description,
    ol.Quantity,
    ol.UnitPrice,
    ol.PickedQuantity,
    ol.PickingCompletedWhen
INTO dbo.OrderLines_FragDemo
FROM Sales.OrderLines ol;
GO

------------------------------------------------------------
-- 3) CLUSTERED INDEX EKLE
------------------------------------------------------------
CREATE CLUSTERED INDEX CIX_OrderLines_FragDemo_OrderID_StockItemID
ON dbo.OrderLines_FragDemo (OrderID, StockItemID);
GO

------------------------------------------------------------
-- 4) İLK FİZİKSEL DURUM
------------------------------------------------------------
SELECT
    OBJECT_NAME(ps.object_id) AS table_name,
    i.name AS index_name,
    ps.index_type_desc,
    ps.avg_fragmentation_in_percent,
    ps.avg_page_space_used_in_percent,
    ps.page_count
FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('dbo.OrderLines_FragDemo'), NULL, NULL, 'DETAILED') ps
INNER JOIN sys.indexes i
    ON ps.object_id = i.object_id
   AND ps.index_id = i.index_id
ORDER BY ps.page_count DESC;
GO