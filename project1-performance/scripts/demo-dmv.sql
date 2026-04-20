USE WideWorldImporters;
GO

------------------------------------------------------------
-- 1) DEMO TABLOSUYLA İLGİLİ EN SON ÇALIŞAN SORGULAR
-- Amaç: PerfDemo tablosunu kullanan sorguları plan cache'ten bulmak
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
-- 2) EN PAHALI DEMO SORGULARI
-- Amaç: PerfDemo içeren sorgular arasında en maliyetlileri görmek
------------------------------------------------------------
SELECT TOP 10
    qs.execution_count,
    qs.total_worker_time / 1000 AS total_cpu_ms,
    qs.total_elapsed_time / 1000 AS total_elapsed_ms,
    qs.total_logical_reads AS total_logical_reads,
    (qs.total_worker_time / qs.execution_count) / 1000 AS avg_cpu_ms,
    (qs.total_elapsed_time / qs.execution_count) / 1000 AS avg_elapsed_ms,
    (qs.total_logical_reads / qs.execution_count) AS avg_logical_reads,
    qs.total_physical_reads,
    qs.total_logical_writes,
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
ORDER BY avg_elapsed_ms DESC;
GO

------------------------------------------------------------
-- 3) MISSING INDEX ÖNERİLERİ
-- Amaç: PerfDemo tablosu için DMV'nin önerdiği indexleri görmek
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
    mid.included_columns,
    'CREATE INDEX IX_' + OBJECT_NAME(mid.object_id, mid.database_id) +
    '_' + REPLACE(REPLACE(ISNULL(mid.equality_columns, ''), ', ', '_'), '[', '') +
    ' ON ' + mid.statement +
    ' (' + ISNULL(mid.equality_columns, '') +
    CASE
        WHEN mid.equality_columns IS NOT NULL
         AND mid.inequality_columns IS NOT NULL
        THEN ', '
        ELSE ''
    END +
    ISNULL(mid.inequality_columns, '') + ')' +
    ISNULL(' INCLUDE (' + mid.included_columns + ')', '') AS suggested_index
FROM sys.dm_db_missing_index_details mid
INNER JOIN sys.dm_db_missing_index_groups mig
    ON mid.index_handle = mig.index_handle
INNER JOIN sys.dm_db_missing_index_group_stats migs
    ON mig.index_group_handle = migs.group_handle
WHERE mid.database_id = DB_ID()
  AND OBJECT_NAME(mid.object_id, mid.database_id) = 'OrderLines_PerfDemo'
ORDER BY migs.avg_user_impact DESC, migs.user_seeks DESC;
GO

------------------------------------------------------------
-- 4) INDEX USAGE DURUMU
-- Amaç: Demo tablo üzerindeki index gerçekten kullanılıyor mu görmek
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
-- 5) INDEX FİZİKSEL DURUMU / STORAGE-DENSITY İÇİN ÖN GÖRÜNÜM
-- Amaç: page count, fragmentation, page space used değerlerini görmek
------------------------------------------------------------
SELECT
    OBJECT_NAME(ps.object_id) AS table_name,
    i.name AS index_name,
    ps.index_type_desc,
    ps.avg_fragmentation_in_percent,
    ps.avg_page_space_used_in_percent,
    ps.page_count
FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('dbo.OrderLines_PerfDemo'), NULL, NULL, 'DETAILED') ps
INNER JOIN sys.indexes i
    ON ps.object_id = i.object_id
   AND ps.index_id = i.index_id
ORDER BY ps.page_count DESC;
GO

------------------------------------------------------------
-- 6) TABLO ALAN KULLANIMI
-- Amaç: raporda tablo boyutu göstermek
------------------------------------------------------------
EXEC sp_spaceused 'dbo.OrderLines_PerfDemo';
GO