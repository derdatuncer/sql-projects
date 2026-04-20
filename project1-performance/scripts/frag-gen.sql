USE WideWorldImporters;
GO

------------------------------------------------------------
-- 1) FRAGMENTATION ÜRETMEK İÇİN ARAYA SATIR SOK
------------------------------------------------------------
INSERT INTO dbo.OrderLines_FragDemo
(
    OrderID,
    StockItemID,
    Description,
    Quantity,
    UnitPrice,
    PickedQuantity,
    PickingCompletedWhen
)
SELECT TOP 50000
    ABS(CHECKSUM(NEWID())) % 80000 + 1 AS OrderID,
    ABS(CHECKSUM(NEWID())) % 250 + 1 AS StockItemID,
    'Fragmentation test row',
    1 + ABS(CHECKSUM(NEWID())) % 10,
    CAST(1 + ABS(CHECKSUM(NEWID())) % 200 AS DECIMAL(18,2)),
    ABS(CHECKSUM(NEWID())) % 10,
    DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 365, '2016-01-01')
FROM sys.all_objects a
CROSS JOIN sys.all_objects b;
GO

------------------------------------------------------------
-- 2) EK OLARAK BAZI UPDATE'LER
------------------------------------------------------------
UPDATE dbo.OrderLines_FragDemo
SET Description = Description + ' updated'
WHERE DemoID % 7 = 0;
GO

------------------------------------------------------------
-- 3) FRAGMENTATION SONRASI ÖLÇÜM
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