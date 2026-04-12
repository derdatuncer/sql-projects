SELECT
    o.OrderID,
    o.OrderDate,
    c.CustomerName,
    ol.StockItemID,
    ol.Quantity,
    ol.UnitPrice,
    si.StockItemName
FROM Sales.Orders o
JOIN Sales.Customers c ON o.CustomerID = c.CustomerID
JOIN Sales.OrderLines ol ON o.OrderID = ol.OrderID
JOIN Warehouse.StockItems si ON ol.StockItemID = si.StockItemID
WHERE o.OrderDate >= '2015-01-01'
  AND o.OrderDate < '2017-01-01'
ORDER BY o.OrderDate DESC;