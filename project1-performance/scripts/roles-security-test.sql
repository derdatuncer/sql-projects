USE WideWorldImporters;
GO

------------------------------------------------------------
-- 1) reader_user testi
------------------------------------------------------------
EXECUTE AS USER = 'reader_user';
GO

PRINT 'reader_user -> SELECT test';
SELECT TOP 5 *
FROM dbo.OrderLines_PerfDemo;
GO

PRINT 'reader_user -> UPDATE test (başarısız olmalı)';
BEGIN TRY
    UPDATE dbo.OrderLines_PerfDemo
    SET Quantity = Quantity
    WHERE DemoID = 1;
    PRINT 'UPDATE SUCCEEDED';
END TRY
BEGIN CATCH
    PRINT ERROR_MESSAGE();
END CATCH;
GO

REVERT;
GO

------------------------------------------------------------
-- 2) analyst_user testi
------------------------------------------------------------
EXECUTE AS USER = 'analyst_user';
GO

PRINT 'analyst_user -> SELECT test';
SELECT TOP 5 *
FROM dbo.OrderLines_PerfDemo;
GO

PRINT 'analyst_user -> DMV test';
SELECT TOP 5 *
FROM sys.dm_exec_query_stats;
GO

REVERT;
GO

------------------------------------------------------------
-- 3) admin_user testi
------------------------------------------------------------
EXECUTE AS USER = 'admin_user';
GO

PRINT 'admin_user -> UPDATE test';
BEGIN TRY
    UPDATE dbo.OrderLines_PerfDemo
    SET Quantity = Quantity
    WHERE DemoID = 1;
    PRINT 'UPDATE SUCCEEDED';
END TRY
BEGIN CATCH
    PRINT ERROR_MESSAGE();
END CATCH;
GO

REVERT;
GO