/* ========================================================================
   PROJE 2 - ORTAM SIFIRLAMA SCRIPTI
   Amaç: Testleri baştan alabilmeniz için oluşturduğunuz DisasterRecoveryTest_DB
         test veritabanını kaldırır ve tüm seansları temizler.
======================================================================== */

USE master;
GO

PRINT 'Proje 2 sıfırlaması başlatıldı...';

-- Veritabanı bağlantılarını kesip silmek
IF DB_ID('DisasterRecoveryTest_DB') IS NOT NULL
BEGIN
    ALTER DATABASE DisasterRecoveryTest_DB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DisasterRecoveryTest_DB;
    PRINT 'DisasterRecoveryTest_DB veritabanı silindi.';
END

PRINT 'Proje 2 sıfırlaması başarıyla tamamlandı.';
GO

/* ========================================================================
   Manuel İşlemler:
   - C:\Backup klasörü altına atılan .bak ve .trn dosyalarını klasörden silebilirsiniz.
======================================================================== */
