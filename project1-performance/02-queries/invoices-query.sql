USE WideWorldImporters;
GO
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

SELECT 
    i.InvoiceID,
    i.InvoiceDate,
    c.CustomerName,
    il.StockItemID,
    il.Quantity,
    il.UnitPrice
FROM Sales.Invoices i
INNER JOIN Sales.Customers c
    ON i.CustomerID = c.CustomerID
INNER JOIN Sales.InvoiceLines il
    ON i.InvoiceID = il.InvoiceID
WHERE i.InvoiceDate >= '2015-01-01'
  AND i.InvoiceDate < '2017-01-01'
  AND c.CustomerName LIKE '%Toys%'
ORDER BY i.InvoiceDate DESC;
GO