/* ========================================================================
   PROJE 2: Veritabanı Yedekleme ve Felaketten Kurtarma Planı
   Dosya  : 02_Backup_Strategies.sql
   Amaç   : Tam (Full), Fark (Differential) ve İşlem Günlüğü (Transaction Log) yedeklerini almak.
======================================================================== */
USE master;
GO

------------------------------------------------------------
-- 1) TAM YEDEK (FULL BACKUP) ALMA
------------------------------------------------------------
BACKUP DATABASE DisasterRecoveryTest_DB
TO DISK = 'C:\Backup\DisasterRecoveryTest_DB_FULL.bak'
WITH FORMAT, INIT, NAME = 'DisasterRecoveryTest_DB-Full Database Backup', STATS = 10;
GO

------------------------------------------------------------
-- 2) Tabloya birkaç yeni kayıt ekleme veya güncelleme.
------------------------------------------------------------
USE DisasterRecoveryTest_DB;
GO
INSERT INTO dbo.MusteriHesaplari (MusteriAd, Bakiye) VALUES ('YeniMüşteri_DiffÖncesi_1', 5000);
INSERT INTO dbo.MusteriHesaplari (MusteriAd, Bakiye) VALUES ('YeniMüşteri_DiffÖncesi_2', 7500);
GO

------------------------------------------------------------
-- 3) FARK YEDEĞİ (DIFFERENTIAL BACKUP) ALMA
------------------------------------------------------------
USE master;
GO
BACKUP DATABASE DisasterRecoveryTest_DB
TO DISK = 'C:\Backup\DisasterRecoveryTest_DB_DIFF.bak'
WITH DIFFERENTIAL, FORMAT, INIT, NAME = 'DisasterRecoveryTest_DB-Differential Database Backup', STATS = 10;
GO

------------------------------------------------------------
-- 4) Tabloya tekrar veri ekleme.
------------------------------------------------------------
USE DisasterRecoveryTest_DB;
GO
INSERT INTO dbo.MusteriHesaplari (MusteriAd, Bakiye) VALUES ('YeniMüşteri_LogÖncesi', 300);
GO

------------------------------------------------------------
-- 5) İŞLEM GÜNLÜĞÜ YEDEĞİ (TRANSACTION LOG BACKUP) ALMA
------------------------------------------------------------
USE master;
GO
BACKUP LOG DisasterRecoveryTest_DB
TO DISK = 'C:\Backup\DisasterRecoveryTest_DB_LOG1.trn'
WITH FORMAT, INIT, NAME = 'DisasterRecoveryTest_DB-Transaction Log Backup', STATS = 10;
GO
