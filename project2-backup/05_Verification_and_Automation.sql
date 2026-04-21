/* ========================================================================
   PROJE 2: Veritabanı Yedekleme ve Felaketten Kurtarma Planı
   Dosya  : 05_Verification_and_Automation.sql
   Amaç   : Alınan yedeklerin sağlamlığını test etmek ve otomasyon.
======================================================================== */
USE master;
GO

------------------------------------------------------------
-- 1) VERIFICATION (DOĞRULAMA) TESTLERİ
------------------------------------------------------------
-- Alınan dosyaların diskte bozuk olup olmadığını memory üzerinde test eder.
RESTORE VERIFYONLY FROM DISK = 'C:\Backup\DisasterRecoveryTest_DB_FULL.bak';
RESTORE VERIFYONLY FROM DISK = 'C:\Backup\DisasterRecoveryTest_DB_DIFF.bak';
RESTORE VERIFYONLY FROM DISK = 'C:\Backup\DisasterRecoveryTest_DB_LOG1.trn';
RESTORE VERIFYONLY FROM DISK = 'C:\Backup\DisasterRecoveryTest_DB_TailLog.trn';
GO
