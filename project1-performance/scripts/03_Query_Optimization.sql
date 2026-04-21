/* ========================================================================
   Dosya: 03_Query_Optimization.sql
   Amaç: Kötü Performanslı ve İyi Performanslı sorguların kıyaslaması
======================================================================== */
USE WideWorldImporters;
GO

------------------------------------------------------------
-- 1) DATE TABANLI INDEX OLUŞTUR (index-optimization-demo.sql'den)
------------------------------------------------------------
-- Q3/Q4 testleri için altyapı
DROP INDEX IF EXISTS IX_OrderLines_PerfDemo_PickingCompletedWhen ON dbo.OrderLines_PerfDemo;
CREATE NONCLUSTERED INDEX IX_OrderLines_PerfDemo_PickingCompletedWhen
ON dbo.OrderLines_PerfDemo (PickingCompletedWhen)
INCLUDE (DemoID, OrderID, StockItemID, Quantity, UnitPrice);
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

------------------------------------------------------------
-- 2) KÖTÜ SORGU ÖRNEĞİ (NON-SARGABLE)
-- YEAR() fonksiyonu kolon üstünde çalıştığı için index kullanımını zorlaştırır
------------------------------------------------------------
CHECKPOINT;
DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;
GO

PRINT 'Q3_AFTER_DATE_INDEX_BAD_QUERY (NON-SARGABLE)';
SELECT DemoID, OrderID, StockItemID, Quantity, UnitPrice, PickingCompletedWhen 
FROM dbo.OrderLines_PerfDemo 
WHERE YEAR(PickingCompletedWhen) = 2016 
ORDER BY OrderID;
GO

------------------------------------------------------------
-- 3) İYİ SORGU (SARGABLE)
-- Aynı mantık ama index dostu, doğrudan Range verilmiş yazım
------------------------------------------------------------
CHECKPOINT;
DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;
GO

PRINT 'Q4_AFTER_DATE_INDEX_GOOD_QUERY (SARGABLE)';
SELECT DemoID, OrderID, StockItemID, Quantity, UnitPrice, PickingCompletedWhen 
FROM dbo.OrderLines_PerfDemo 
WHERE PickingCompletedWhen >= '2016-01-01' AND PickingCompletedWhen < '2017-01-01' 
ORDER BY OrderID;
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
