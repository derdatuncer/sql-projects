/* ========================================================================
   PROJE 2: Veritabanı Yedekleme ve Felaketten Kurtarma Planı
   Dosya  : 03_Disaster_Simulation.sql
   Amaç   : Sistemi çökertecek veya veriyi bozacak o "yanlış" sorguyu çalıştırmak.
======================================================================== */
USE DisasterRecoveryTest_DB;
GO

------------------------------------------------------------
-- 1) Felaket Saati Öncesi (Sistem saatini not edelim)
------------------------------------------------------------
SELECT GETDATE() AS [Felaket_Gerceklesmeden_Hemen_Onceki_Zaman];
GO

------------------------------------------------------------
-- 2) Kaza ile yanlış komutun çalıştırılması 
------------------------------------------------------------
DELETE FROM dbo.MusteriHesaplari; 
GO

SELECT COUNT(*) AS Kalan_Kayit_Sayisi FROM dbo.MusteriHesaplari;
GO

------------------------------------------------------------
-- 3) Kritik Adım: TAIL-LOG BACKUP (Kuyruk Log Yedeği) Alma
------------------------------------------------------------
USE master;
GO

BACKUP LOG DisasterRecoveryTest_DB
TO DISK = 'C:\Backup\DisasterRecoveryTest_DB_TailLog.trn'
WITH NORECOVERY, FORMAT, INIT, NAME = 'DisasterRecoveryTest_DB-Tail Log Backup';
GO
