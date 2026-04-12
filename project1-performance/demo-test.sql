USE WideWorldImporters;
GO

------------------------------------------------------------
-- 1) DEMO TABLOSUNU OLUŞTUR
------------------------------------------------------------
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

------------------------------------------------------------
-- 2) SATIR SAYISI
------------------------------------------------------------
SELECT COUNT(*) AS row_count
FROM dbo.OrderLines_PerfDemo;
GO

------------------------------------------------------------
-- 3) ÖLÇÜMÜ TEMİZLE
------------------------------------------------------------
CHECKPOINT;
DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

------------------------------------------------------------
-- 4) INDEX OLMADAN QUERY
------------------------------------------------------------
SELECT
    OrderID,
    StockItemID,
    Quantity,
    UnitPrice
FROM dbo.OrderLines_PerfDemo
WHERE OrderID BETWEEN 50000 AND 60000
ORDER BY OrderID, StockItemID;
GO

------------------------------------------------------------
-- 5) INDEX OLMADAN DMV ANALİZİ
------------------------------------------------------------
SELECT TOP 10
    qs.execution_count,
    qs.total_worker_time / 1000 AS total_cpu_ms,
    qs.total_elapsed_time / 1000 AS total_elapsed_ms,
    qs.total_logical_reads AS total_logical_reads,
    qs.total_physical_reads AS total_physical_reads,
    (qs.total_worker_time / qs.execution_count) / 1000 AS avg_cpu_ms,
    (qs.total_elapsed_time / qs.execution_count) / 1000 AS avg_elapsed_ms,
    (qs.total_logical_reads / qs.execution_count) AS avg_logical_reads,
    SUBSTRING(
        st.text,
        (qs.statement_start_offset / 2) + 1,
        (
            (
                CASE qs.statement_end_offset
                    WHEN -1 THEN DATALENGTH(st.text)
                    ELSE qs.statement_end_offset
                END - qs.statement_start_offset
            ) / 2
        ) + 1
    ) AS query_text
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
WHERE st.text LIKE '%dbo.OrderLines_PerfDemo%'
ORDER BY qs.last_execution_time DESC;
GO

------------------------------------------------------------
-- 6) INDEX OLUŞTUR
------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_OrderLines_PerfDemo_OrderID_StockItemID
ON dbo.OrderLines_PerfDemo (OrderID, StockItemID)
INCLUDE (Quantity, UnitPrice);
GO

------------------------------------------------------------
-- 7) YİNE TEMİZ ÖLÇÜM
------------------------------------------------------------
CHECKPOINT;
DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

------------------------------------------------------------
-- 8) INDEXTEN SONRA AYNI QUERY
------------------------------------------------------------
SELECT
    OrderID,
    StockItemID,
    Quantity,
    UnitPrice
FROM dbo.OrderLines_PerfDemo
WHERE OrderID BETWEEN 50000 AND 60000
ORDER BY OrderID, StockItemID;
GO

------------------------------------------------------------
-- 9) INDEXTEN SONRA DMV ANALİZİ
------------------------------------------------------------
SELECT TOP 10
    qs.execution_count,
    qs.total_worker_time / 1000 AS total_cpu_ms,
    qs.total_elapsed_time / 1000 AS total_elapsed_ms,
    qs.total_logical_reads AS total_logical_reads,
    qs.total_physical_reads AS total_physical_reads,
    (qs.total_worker_time / qs.execution_count) / 1000 AS avg_cpu_ms,
    (qs.total_elapsed_time / qs.execution_count) / 1000 AS avg_elapsed_ms,
    (qs.total_logical_reads / qs.execution_count) AS avg_logical_reads,
    SUBSTRING(
        st.text,
        (qs.statement_start_offset / 2) + 1,
        (
            (
                CASE qs.statement_end_offset
                    WHEN -1 THEN DATALENGTH(st.text)
                    ELSE qs.statement_end_offset
                END - qs.statement_start_offset
            ) / 2
        ) + 1
    ) AS query_text
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
WHERE st.text LIKE '%dbo.OrderLines_PerfDemo%'
ORDER BY qs.last_execution_time DESC;
GO