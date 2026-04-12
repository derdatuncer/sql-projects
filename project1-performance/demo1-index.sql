USE WideWorldImporters;
GO

DROP TABLE IF EXISTS dbo.OrderLines_PerfDemo;
GO

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
FROM Sales.OrderLines ol
CROSS JOIN (
    SELECT TOP 30 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects
) x;
GO

SELECT COUNT(*) AS row_count
FROM dbo.OrderLines_PerfDemo;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
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

CREATE NONCLUSTERED INDEX IX_OrderLines_PerfDemo_OrderID_StockItemID
ON dbo.OrderLines_PerfDemo (OrderID, StockItemID)
INCLUDE (Quantity, UnitPrice);
GO

DROP INDEX IX_OrderLines_PerfDemo_OrderID_StockItemID ON dbo.OrderLines_PerfDemo;
