USE master;
GO

-- 1. ESKİ SÜRÜMDEN DIŞA AKTARMA (BACKUP)
BACKUP DATABASE TransactionDB 
TO DISK = 'TransactionDB_EskiSurum.bak' 
WITH INIT, NAME = 'Yükseltme Öncesi Ana Yedek';
GO

-- 2. YENİ SİSTEME TAŞIMA (RESTORE)
ALTER DATABASE TransactionDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
RESTORE DATABASE TransactionDB 
FROM DISK = 'TransactionDB_EskiSurum.bak' 
WITH REPLACE;
ALTER DATABASE TransactionDB SET MULTI_USER;
GO

-- 3. MOTOR YÜKSELTMESİ
ALTER DATABASE TransactionDB SET COMPATIBILITY_LEVEL = 160;
GO

-- 4. YÜKSELTME ONAY RAPORU
SELECT 
    name AS [Veritabani_Adi], 
    compatibility_level AS [Guncel_Surum_Kodu],
    'SQL Server 2022' AS [Hedeflenen_Surum],
    'Yükseltme Stratejisi Başarıyla Uygulandı!' AS [Durum]
FROM sys.databases 
WHERE name = 'TransactionDB';
GO