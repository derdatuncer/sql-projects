USE WideWorldImporters;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

PRINT('QUERY1');
------------------------------------------------------------
-- Q1: BASELINE RANGE QUERY
-- Amaç: OrderID aralığında sıralı veri çekmek
-- Sonradan index etkisini burada net göreceğiz
------------------------------------------------------------
CHECKPOINT;
DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;
GO

SELECT
    OrderID,
    StockItemID,
    Quantity,
    UnitPrice
FROM dbo.OrderLines_PerfDemo
WHERE OrderID BETWEEN 50000 AND 60000
ORDER BY OrderID, StockItemID;
GO

PRINT('QUERY2');
------------------------------------------------------------
-- Q2: BASELINE AGGREGATE QUERY
-- Amaç: Belirli bir aralıkta grup bazlı toplama yapmak
-- Index öncesi/sonrası logical read farkı görülebilir
------------------------------------------------------------
CHECKPOINT;
DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;
GO

SELECT
    StockItemID,
    COUNT(*) AS line_count,
    SUM(Quantity) AS total_quantity,
    AVG(UnitPrice) AS avg_unit_price
FROM dbo.OrderLines_PerfDemo
WHERE OrderID BETWEEN 50000 AND 70000
GROUP BY StockItemID
ORDER BY StockItemID;
GO

PRINT('QUERY3');
------------------------------------------------------------
-- Q3: KÖTÜ SORGU ÖRNEĞİ (NON-SARGABLE)
-- Amaç: query optimization bölümünde düzeltilecek örnek üretmek
------------------------------------------------------------
CHECKPOINT;
DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;
GO

SELECT
    DemoID,
    OrderID,
    StockItemID,
    Quantity,
    UnitPrice,
    PickingCompletedWhen
FROM dbo.OrderLines_PerfDemo
WHERE YEAR(PickingCompletedWhen) = 2016
ORDER BY OrderID;
GO

PRINT('QUERY4');
------------------------------------------------------------
-- Q4: AYNI İŞİN DAHA DOĞRU YAZILMIŞ HALİ
-- Şimdilik bunu da baseline olarak ölç
-- Sonradan index ile birlikte tekrar çalıştıracağız
------------------------------------------------------------
CHECKPOINT;
DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;
GO

SELECT
    DemoID,
    OrderID,
    StockItemID,
    Quantity,
    UnitPrice,
    PickingCompletedWhen
FROM dbo.OrderLines_PerfDemo
WHERE PickingCompletedWhen >= '2016-01-01'
  AND PickingCompletedWhen < '2017-01-01'
ORDER BY OrderID;
GO