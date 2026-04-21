/* ========================================================================
   Dosya: 04_Roles_And_Security.sql
   Amaç: Roller, Güvenlik İzinleri ve Testleri
======================================================================== */
USE WideWorldImporters;
GO

------------------------------------------------------------
-- 1) VARSA ESKİ KULLANICI VE ROLLERİ TEMİZLE
------------------------------------------------------------
-- Önce kullanıcıları silip rolleri boşaltıyoruz
IF DATABASE_PRINCIPAL_ID('reader_user') IS NOT NULL DROP USER reader_user;
IF DATABASE_PRINCIPAL_ID('admin_user') IS NOT NULL DROP USER admin_user;

-- Şimdi içi boşalan rolleri güvenle siliyoruz
IF DATABASE_PRINCIPAL_ID('PerfDemoReader') IS NOT NULL DROP ROLE PerfDemoReader;
IF DATABASE_PRINCIPAL_ID('PerfDemoAdmin') IS NOT NULL DROP ROLE PerfDemoAdmin;
GO

------------------------------------------------------------
-- 2) YENİ ROLLERİ VE KULLANICILARI OLUŞTUR
------------------------------------------------------------
CREATE ROLE PerfDemoReader;
CREATE ROLE PerfDemoAdmin;
CREATE USER reader_user WITHOUT LOGIN;
CREATE USER admin_user WITHOUT LOGIN;

ALTER ROLE PerfDemoReader ADD MEMBER reader_user;
ALTER ROLE PerfDemoAdmin ADD MEMBER admin_user;
GO

------------------------------------------------------------
-- 3) YETKİ (GRANT) İŞLEMLERİ
------------------------------------------------------------
GRANT SELECT ON dbo.OrderLines_PerfDemo TO PerfDemoReader;
GRANT SELECT ON dbo.OrderLines_FragDemo TO PerfDemoReader;

GRANT SELECT, INSERT, UPDATE, DELETE, ALTER ON dbo.OrderLines_PerfDemo TO PerfDemoAdmin;
GRANT SELECT, INSERT, UPDATE, DELETE, ALTER ON dbo.OrderLines_FragDemo TO PerfDemoAdmin;
GO

------------------------------------------------------------
-- 4) ROL AĞACI VE ERİŞİM KONTROL RAPORU
------------------------------------------------------------
SELECT dp.state_desc, dp.permission_name, USER_NAME(dp.grantee_principal_id) AS grantee_name, OBJECT_NAME(dp.major_id) AS object_name
FROM sys.database_permissions dp
WHERE USER_NAME(dp.grantee_principal_id) IN ('PerfDemoReader', 'PerfDemoAdmin')
ORDER BY grantee_name, object_name, permission_name;
GO

------------------------------------------------------------
-- 5) SECURITY TESTLERİ (roles-security-test.sql'den)
------------------------------------------------------------
EXECUTE AS USER = 'reader_user';
GO
PRINT 'reader_user -> SELECT test';
SELECT TOP 5 * FROM dbo.OrderLines_PerfDemo;
GO
PRINT 'reader_user -> UPDATE test (başarısız olmalı)';
BEGIN TRY
    UPDATE dbo.OrderLines_PerfDemo SET Quantity = Quantity WHERE DemoID = 1;
    PRINT 'UPDATE SUCCEEDED';
END TRY
BEGIN CATCH
    PRINT ERROR_MESSAGE();
END CATCH;
GO
REVERT;
GO

EXECUTE AS USER = 'admin_user';
GO
PRINT 'admin_user -> UPDATE test (Başarılı Olmalı)';
BEGIN TRY
    UPDATE dbo.OrderLines_PerfDemo SET Quantity = Quantity WHERE DemoID = 1;
    PRINT 'UPDATE SUCCEEDED';
END TRY
BEGIN CATCH
    PRINT ERROR_MESSAGE();
END CATCH;
GO
REVERT;
GO