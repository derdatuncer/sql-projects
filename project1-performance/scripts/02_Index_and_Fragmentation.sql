/* ========================================================================
   Dosya: 02_Index_and_Fragmentation.sql
   Amaç: İndeks optimizasyon demoları ve disk yoğunluğu (Fragmentation)
======================================================================== */
USE WideWorldImporters;
GO

------------------------------------------------------------
-- 1) VARSA ESKİ DEMO INDEXLERİNİ TEMİZLE
------------------------------------------------------------
DROP INDEX IF EXISTS IX_OrderLines_PerfDemo_OrderID_StockItemID ON dbo.OrderLines_PerfDemo;
DROP INDEX IF EXISTS IX_OrderLines_PerfDemo_OrderID_StockItemID_Covering ON dbo.OrderLines_PerfDemo;
DROP INDEX IF EXISTS IX_OrderLines_PerfDemo_PickingCompletedWhen ON dbo.OrderLines_PerfDemo;
GO

------------------------------------------------------------
-- 2) Q1/Q2 BASELINE - İNDEKS OLMADAN (demo-queries.sql'den)
------------------------------------------------------------
CHECKPOINT; DBCC DROPCLEANBUFFERS; DBCC FREEPROCCACHE;
GO
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

PRINT('Q1: BASELINE RANGE QUERY (INDEXSIZ)');
SELECT OrderID, StockItemID, Quantity, UnitPrice FROM dbo.OrderLines_PerfDemo
WHERE OrderID BETWEEN 50000 AND 60000 ORDER BY OrderID, StockItemID;
GO 10

PRINT('Q2: BASELINE AGGREGATE QUERY (INDEXSIZ)');
SELECT StockItemID, COUNT(*) AS line_count, SUM(Quantity) AS total_quantity, AVG(UnitPrice) AS avg_unit_price
FROM dbo.OrderLines_PerfDemo WHERE OrderID BETWEEN 50000 AND 70000 GROUP BY StockItemID ORDER BY StockItemID;
GO 10

------------------------------------------------------------
-- 3) ORDERID TABANLI INDEX OLUŞTUR (index-optimization-demo.sql'den)
------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_OrderLines_PerfDemo_OrderID_StockItemID_Covering
ON dbo.OrderLines_PerfDemo (OrderID, StockItemID) INCLUDE (Quantity, UnitPrice);
GO

------------------------------------------------------------
-- 4) Q1/Q2 TEKRAR ÇALIŞTIR - İNDEKSLİ
------------------------------------------------------------
CHECKPOINT; DBCC DROPCLEANBUFFERS; DBCC FREEPROCCACHE;
GO
PRINT 'Q1_AFTER_ORDERID_INDEX';
SELECT OrderID, StockItemID, Quantity, UnitPrice FROM dbo.OrderLines_PerfDemo
WHERE OrderID BETWEEN 50000 AND 60000 ORDER BY OrderID, StockItemID;
GO

PRINT 'Q2_AFTER_ORDERID_INDEX';
SELECT StockItemID, COUNT(*) AS line_count, SUM(Quantity) AS total_quantity, AVG(UnitPrice) AS avg_unit_price
FROM dbo.OrderLines_PerfDemo WHERE OrderID BETWEEN 50000 AND 70000 GROUP BY StockItemID ORDER BY StockItemID;
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

------------------------------------------------------------
-- 5) PARÇALANMA SİMÜLASYONU (frag-gen.sql'den)
------------------------------------------------------------
-- Parçalanma üretmek için araya satır sokuluyor...
INSERT INTO dbo.OrderLines_FragDemo (OrderID, StockItemID, Description, Quantity, UnitPrice, PickedQuantity, PickingCompletedWhen)
SELECT TOP 50000
    ABS(CHECKSUM(NEWID())) % 80000 + 1 AS OrderID, ABS(CHECKSUM(NEWID())) % 250 + 1 AS StockItemID,
    'Fragmentation test row', 1 + ABS(CHECKSUM(NEWID())) % 10, CAST(1 + ABS(CHECKSUM(NEWID())) % 200 AS DECIMAL(18,2)),
    ABS(CHECKSUM(NEWID())) % 10, DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 365, '2016-01-01')
FROM sys.all_objects a CROSS JOIN sys.all_objects b;
GO

UPDATE dbo.OrderLines_FragDemo 
SET Description = LEFT(Description + ' updated', 100) 
WHERE DemoID % 7 = 0;
GO

------------------------------------------------------------
-- 6) İNDEKS ONARIMI - REORGANIZE VE REBUILD (reorganize-rebuild.sql'den)
------------------------------------------------------------
ALTER INDEX CIX_OrderLines_FragDemo_OrderID_StockItemID ON dbo.OrderLines_FragDemo REORGANIZE;
GO
ALTER INDEX CIX_OrderLines_FragDemo_OrderID_StockItemID ON dbo.OrderLines_FragDemo REBUILD;
GO
