/* ========================================================================
   PROJE 2: Veritabanı Yedekleme ve Felaketten Kurtarma Planı
   Dosya  : 04_Restore_Methods.sql
   Amaç   : 3 Farklı Yöntemle Restore İşlemi (Full, Diff, Point-In-Time)
======================================================================== */
USE master;
GO

------------------------------------------------------------
-- YÖNTEM 1: SADECE TAM (FULL) YEDEKTEN KURTARMA
------------------------------------------------------------
-- Bu senaryoda sadece ilk aldığımız %100'lük tam yedeği dönüyoruz.
-- Sonrasında atılan Diff ve Log verileri kaybolur. (Sadece ilk 1000 kayıt gelir)

ALTER DATABASE DisasterRecoveryTest_DB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

RESTORE DATABASE DisasterRecoveryTest_DB
FROM DISK = 'C:\Backup\DisasterRecoveryTest_DB_FULL.bak'
WITH REPLACE, RECOVERY;
GO

-- Sonucu Görelim
USE DisasterRecoveryTest_DB;
GO
PRINT 'YÖNTEM 1 SONUCU (Sadece FULL döndük - İlk 1000 veri geldi):';
SELECT COUNT(*) AS Kalan_Kayit FROM dbo.MusteriHesaplari;
GO


------------------------------------------------------------
-- YÖNTEM 2: FARK (DIFFERENTIAL) YEDEĞİ İLE KURTARMA (FULL + DIFF)
------------------------------------------------------------
-- Full yedeği NORECOVERY ile dönüp, üstüne bindiği Diff yedeği dönülür.
-- (1000 kayıt + Diff öncesi atılan 2 kayıt = 1002 kayıt gelir)

USE master;
GO
ALTER DATABASE DisasterRecoveryTest_DB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

-- A) Full yedek (NORECOVERY)
RESTORE DATABASE DisasterRecoveryTest_DB
FROM DISK = 'C:\Backup\DisasterRecoveryTest_DB_FULL.bak'
WITH REPLACE, NORECOVERY;
GO

-- B) Üstüne Diff Yedeği (RECOVERY)
RESTORE DATABASE DisasterRecoveryTest_DB
FROM DISK = 'C:\Backup\DisasterRecoveryTest_DB_DIFF.bak'
WITH RECOVERY;
GO

-- Sonucu Görelim
USE DisasterRecoveryTest_DB;
GO
PRINT 'YÖNTEM 2 SONUCU (FULL + DIFF döndük - 1002 veri geldi):';
SELECT COUNT(*) AS Kalan_Kayit FROM dbo.MusteriHesaplari;
GO


------------------------------------------------------------
-- YÖNTEM 3: İŞLEM GÜNLÜĞÜ VE ZAMANA DÖNÜŞ (FULL + DIFF + LOG + TAIL-LOG)
------------------------------------------------------------
-- Hatanın meydana geldiği o salise saniyesine (Point-in-time) kadar kurtarma yaparız.
-- Tüm kayıtlar + Log sonrası atılan veriler geri gelir. (1003 kayıt)

USE master;
GO
ALTER DATABASE DisasterRecoveryTest_DB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

-- A) Full Yedek
RESTORE DATABASE DisasterRecoveryTest_DB FROM DISK = 'C:\Backup\DisasterRecoveryTest_DB_FULL.bak' WITH REPLACE, NORECOVERY;
-- B) Diff Yedek
RESTORE DATABASE DisasterRecoveryTest_DB FROM DISK = 'C:\Backup\DisasterRecoveryTest_DB_DIFF.bak' WITH NORECOVERY;
-- C) 1. Log Yedeği
RESTORE LOG DisasterRecoveryTest_DB FROM DISK = 'C:\Backup\DisasterRecoveryTest_DB_LOG1.trn' WITH NORECOVERY;

-- D) TAIL-LOG YEDEĞİ İLE ÇÖKÜŞ NOKTASINA (STOPAT) GİTMEK
RESTORE LOG DisasterRecoveryTest_DB
FROM DISK = 'C:\Backup\DisasterRecoveryTest_DB_TailLog.trn'
WITH RECOVERY,
     STOPAT = 'YYYY-MM-DD HH:MM:SS.000'; -- <- BURAYI KENDİ NOT ALDIĞINIZ SAATLE DEĞİŞTİRİN
GO

ALTER DATABASE DisasterRecoveryTest_DB SET MULTI_USER;
GO

-- Sonucu Görelim
USE DisasterRecoveryTest_DB;
GO
PRINT 'YÖNTEM 3 SONUCU (Point-in-Time, felaket öncesi tam anına döndük - Eksiksiz tüm veriler):';
SELECT COUNT(*) AS Kalan_Kayit FROM dbo.MusteriHesaplari;
GO
