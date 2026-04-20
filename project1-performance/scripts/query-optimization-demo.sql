USE WideWorldImporters;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

------------------------------------------------------------
-- 0) TESTTEN ÖNCE ORTAMI TEMİZLE
------------------------------------------------------------
CHECKPOINT;
DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;
GO

------------------------------------------------------------
-- 1) KÖTÜ SORGU (NON-SARGABLE)
-- YEAR() fonksiyonu kolon üstünde çalıştığı için
-- index kullanımını zorlaştırabilir
------------------------------------------------------------
PRINT 'BAD_QUERY_NON_SARGABLE';
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
-- 2) KÖTÜ SORGU SONRASI DMV
------------------------------------------------------------
SELECT TOP 10
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
WHERE st.text LIKE '%YEAR(PickingCompletedWhen)%'
ORDER BY qs.last_execution_time DESC;
GO

------------------------------------------------------------
-- 3) TESTTEN ÖNCE ORTAMI TEMİZLE
------------------------------------------------------------
CHECKPOINT;
DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;
GO

------------------------------------------------------------
-- 4) İYİ SORGU (SARGABLE)
-- Aynı mantık ama index dostu yazım
------------------------------------------------------------
PRINT 'GOOD_QUERY_SARGABLE';
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
-- 5) İYİ SORGU SONRASI DMV
------------------------------------------------------------
SELECT TOP 10
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
WHERE st.text LIKE '%PickingCompletedWhen >= ''2016-01-01''%'
ORDER BY qs.last_execution_time DESC;
GO

------------------------------------------------------------
-- 6) İKİ SORGUYU YAN YANA YORUMLAMAK İÇİN
-- plan cache üzerinde son kayıtları birlikte göster
------------------------------------------------------------
SELECT TOP 20
    qs.last_execution_time,
    qs.execution_count,
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
  AND (
        st.text LIKE '%YEAR(PickingCompletedWhen)%'
     OR st.text LIKE '%PickingCompletedWhen >= ''2016-01-01''%'
  )
ORDER BY qs.last_execution_time DESC;
GO