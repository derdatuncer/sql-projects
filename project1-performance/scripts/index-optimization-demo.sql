USE WideWorldImporters;
GO

------------------------------------------------------------
-- 0) VARSA ESKİ DEMO INDEXLERİNİ TEMİZLE
------------------------------------------------------------
DROP INDEX IF EXISTS IX_OrderLines_PerfDemo_OrderID_StockItemID
ON dbo.OrderLines_PerfDemo;
GO

DROP INDEX IF EXISTS IX_OrderLines_PerfDemo_OrderID_StockItemID_Covering
ON dbo.OrderLines_PerfDemo;
GO

DROP INDEX IF EXISTS IX_OrderLines_PerfDemo_PickingCompletedWhen
ON dbo.OrderLines_PerfDemo;
GO

------------------------------------------------------------
-- 1) ORDERID TABANLI INDEX OLUŞTUR
-- Q1 ve Q2 için
------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_OrderLines_PerfDemo_OrderID_StockItemID_Covering
ON dbo.OrderLines_PerfDemo (OrderID, StockItemID)
INCLUDE (Quantity, UnitPrice);
GO

------------------------------------------------------------
-- 2) CACHE TEMİZLE
------------------------------------------------------------
CHECKPOINT;
DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

------------------------------------------------------------
-- 3) Q1 TEKRAR ÇALIŞTIR
------------------------------------------------------------
PRINT 'Q1_AFTER_ORDERID_INDEX';
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
-- 4) Q2 TEKRAR ÇALIŞTIR
------------------------------------------------------------
PRINT 'Q2_AFTER_ORDERID_INDEX';
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

------------------------------------------------------------
-- 5) ORDERID INDEXTEN SONRA DMV
------------------------------------------------------------
SELECT TOP 20
    qs.last_execution_time,
    qs.execution_count,
    qs.total_worker_time / 1000 AS total_cpu_ms,
    qs.total_elapsed_time / 1000 AS total_elapsed_ms,
    qs.total_logical_reads AS total_logical_reads,
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
WHERE st.text LIKE '%OrderLines_PerfDemo%'
ORDER BY qs.last_execution_time DESC;
GO

------------------------------------------------------------
-- 6) INDEX USAGE KONTROLÜ
------------------------------------------------------------
SELECT
    OBJECT_NAME(s.object_id) AS table_name,
    i.name AS index_name,
    i.type_desc,
    s.user_seeks,
    s.user_scans,
    s.user_lookups,
    s.user_updates,
    s.last_user_seek,
    s.last_user_scan
FROM sys.dm_db_index_usage_stats s
INNER JOIN sys.indexes i
    ON s.object_id = i.object_id
   AND s.index_id = i.index_id
WHERE s.database_id = DB_ID()
  AND OBJECT_NAME(s.object_id) = 'OrderLines_PerfDemo'
ORDER BY s.user_seeks DESC, s.user_scans DESC;
GO

------------------------------------------------------------
-- 7) DATE TABANLI INDEX OLUŞTUR
-- Q3/Q4 için
------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_OrderLines_PerfDemo_PickingCompletedWhen
ON dbo.OrderLines_PerfDemo (PickingCompletedWhen)
INCLUDE (DemoID, OrderID, StockItemID, Quantity, UnitPrice);
GO

------------------------------------------------------------
-- 8) CACHE TEMİZLE
------------------------------------------------------------
CHECKPOINT;
DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

------------------------------------------------------------
-- 9) Q3 TEKRAR ÇALIŞTIR (KÖTÜ SORGU)
------------------------------------------------------------
PRINT 'Q3_AFTER_DATE_INDEX_BAD_QUERY';
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

------------------------------------------------------------
-- 10) Q4 TEKRAR ÇALIŞTIR (İYİ SORGU)
------------------------------------------------------------
PRINT 'Q4_AFTER_DATE_INDEX_GOOD_QUERY';
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

------------------------------------------------------------
-- 11) DATE INDEXTEN SONRA DMV
------------------------------------------------------------
SELECT TOP 20
    qs.last_execution_time,
    qs.execution_count,
    qs.total_worker_time / 1000 AS total_cpu_ms,
    qs.total_elapsed_time / 1000 AS total_elapsed_ms,
    qs.total_logical_reads AS total_logical_reads,
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
WHERE st.text LIKE '%OrderLines_PerfDemo%'
ORDER BY qs.last_execution_time DESC;
GO

------------------------------------------------------------
-- 12) MISSING INDEX DMV'Yİ TEKRAR KONTROL ET
------------------------------------------------------------
SELECT
    DB_NAME(mid.database_id) AS database_name,
    OBJECT_NAME(mid.object_id, mid.database_id) AS table_name,
    migs.user_seeks,
    migs.user_scans,
    migs.avg_total_user_cost,
    migs.avg_user_impact,
    mid.equality_columns,
    mid.inequality_columns,
    mid.included_columns
FROM sys.dm_db_missing_index_details mid
INNER JOIN sys.dm_db_missing_index_groups mig
    ON mid.index_handle = mig.index_handle
INNER JOIN sys.dm_db_missing_index_group_stats migs
    ON mig.index_group_handle = migs.group_handle
WHERE mid.database_id = DB_ID()
  AND OBJECT_NAME(mid.object_id, mid.database_id) = 'OrderLines_PerfDemo'
ORDER BY migs.avg_user_impact DESC, migs.user_seeks DESC;
GO
