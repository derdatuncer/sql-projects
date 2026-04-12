USE WideWorldImporters;
GO

------------------------------------------------------------
-- 1) GÜVENLİ TEMİZLİK
------------------------------------------------------------
IF EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_OrderLines_PerfDemo_OrderID_StockItemID'
      AND object_id = OBJECT_ID('dbo.OrderLines_PerfDemo')
)
BEGIN
    DROP INDEX IX_OrderLines_PerfDemo_OrderID_StockItemID
    ON dbo.OrderLines_PerfDemo;
END
GO

DROP TABLE IF EXISTS dbo.OrderLines_PerfDemo;
GO

------------------------------------------------------------
-- 2) DEMO TABLOSUNU OLUŞTUR
-- Sales.OrderLines verisini büyütülmüş şekilde kopyalıyoruz
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
INTO dbo.OrderLines_PerfDemo
FROM Sales.OrderLines AS ol
CROSS JOIN (
    SELECT TOP 50
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects
) AS x;
GO

------------------------------------------------------------
-- 3) TABLO KONTROLÜ
------------------------------------------------------------
SELECT
    COUNT(*) AS row_count,
    MIN(OrderID) AS min_order_id,
    MAX(OrderID) AS max_order_id
FROM dbo.OrderLines_PerfDemo;
GO

------------------------------------------------------------
-- 4) İLK VERİ KONTROLÜ
------------------------------------------------------------
SELECT TOP 10
    DemoID,
    OrderID,
    StockItemID,
    Quantity,
    UnitPrice,
    PickingCompletedWhen
FROM dbo.OrderLines_PerfDemo
ORDER BY DemoID;
GO

------------------------------------------------------------
-- 5) TEMEL DAĞILIM KONTROLÜ
------------------------------------------------------------
SELECT
    COUNT(DISTINCT OrderID) AS distinct_orders,
    COUNT(DISTINCT StockItemID) AS distinct_stockitems
FROM dbo.OrderLines_PerfDemo;
GO

------------------------------------------------------------
-- 6) ÖLÇÜM ORTAMI
------------------------------------------------------------
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

------------------------------------------------------------
-- 7) CACHE / PLAN TEMİZLİĞİ
-- Her büyük testten önce tekrar çalıştırılabilir
------------------------------------------------------------
CHECKPOINT;
DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;
GO