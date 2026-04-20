USE WideWorldImporters;
GO

------------------------------------------------------------
-- 1) VARSA ESKİ KULLANICI VE ROLLERİ TEMİZLE
------------------------------------------------------------
IF DATABASE_PRINCIPAL_ID('PerfDemoReader') IS NOT NULL
    DROP ROLE PerfDemoReader;
GO

IF DATABASE_PRINCIPAL_ID('PerfDemoAnalyst') IS NOT NULL
    DROP ROLE PerfDemoAnalyst;
GO

IF DATABASE_PRINCIPAL_ID('PerfDemoAdmin') IS NOT NULL
    DROP ROLE PerfDemoAdmin;
GO

IF DATABASE_PRINCIPAL_ID('reader_user') IS NOT NULL
    DROP USER reader_user;
GO

IF DATABASE_PRINCIPAL_ID('analyst_user') IS NOT NULL
    DROP USER analyst_user;
GO

IF DATABASE_PRINCIPAL_ID('admin_user') IS NOT NULL
    DROP USER admin_user;
GO

------------------------------------------------------------
-- 2) ROLLERİ OLUŞTUR
------------------------------------------------------------
CREATE ROLE PerfDemoReader;
GO

CREATE ROLE PerfDemoAnalyst;
GO

CREATE ROLE PerfDemoAdmin;
GO

------------------------------------------------------------
-- 3) DEMO KULLANICILARI OLUŞTUR
------------------------------------------------------------
CREATE USER reader_user WITHOUT LOGIN;
GO

CREATE USER analyst_user WITHOUT LOGIN;
GO

CREATE USER admin_user WITHOUT LOGIN;
GO

------------------------------------------------------------
-- 4) ROLLERE ÜYE EKLE
------------------------------------------------------------
ALTER ROLE PerfDemoReader ADD MEMBER reader_user;
GO

ALTER ROLE PerfDemoAnalyst ADD MEMBER analyst_user;
GO

ALTER ROLE PerfDemoAdmin ADD MEMBER admin_user;
GO

------------------------------------------------------------
-- 5) READER YETKİLERİ
-- Sadece demo tablolarında SELECT
------------------------------------------------------------
GRANT SELECT ON dbo.OrderLines_PerfDemo TO PerfDemoReader;
GO

GRANT SELECT ON dbo.OrderLines_FragDemo TO PerfDemoReader;
GO

------------------------------------------------------------
-- 6) ANALYST YETKİLERİ
-- Demo tablolarında SELECT + DMV okuma
------------------------------------------------------------
GRANT SELECT ON dbo.OrderLines_PerfDemo TO PerfDemoAnalyst;
GO

GRANT SELECT ON dbo.OrderLines_FragDemo TO PerfDemoAnalyst;
GO

GRANT VIEW DATABASE STATE TO PerfDemoAnalyst;
GO

------------------------------------------------------------
-- 7) ADMIN YETKİLERİ
-- Demo tablolarında tam yetki
------------------------------------------------------------
GRANT SELECT, INSERT, UPDATE, DELETE, ALTER ON dbo.OrderLines_PerfDemo TO PerfDemoAdmin;
GO

GRANT SELECT, INSERT, UPDATE, DELETE, ALTER ON dbo.OrderLines_FragDemo TO PerfDemoAdmin;
GO

------------------------------------------------------------
-- 8) ROL VE ÜYELERİ GÖSTER
------------------------------------------------------------
SELECT
    r.name AS role_name,
    m.name AS member_name
FROM sys.database_role_members drm
INNER JOIN sys.database_principals r
    ON drm.role_principal_id = r.principal_id
INNER JOIN sys.database_principals m
    ON drm.member_principal_id = m.principal_id
WHERE r.name IN ('PerfDemoReader', 'PerfDemoAnalyst', 'PerfDemoAdmin')
ORDER BY r.name, m.name;
GO

------------------------------------------------------------
-- 9) HANGİ YETKİLER VERİLDİ GÖSTER
------------------------------------------------------------
SELECT
    dp.state_desc,
    dp.permission_name,
    USER_NAME(dp.grantee_principal_id) AS grantee_name,
    OBJECT_NAME(dp.major_id) AS object_name
FROM sys.database_permissions dp
WHERE USER_NAME(dp.grantee_principal_id) IN ('PerfDemoReader', 'PerfDemoAnalyst', 'PerfDemoAdmin')
ORDER BY grantee_name, object_name, permission_name;
GO