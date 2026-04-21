/* ========================================================================
   PROJE 1 - PERFORMANS VE İNDEKS SIFIRLAMA SCRIPTI
   Amaç: Testleri defalarca yapabilmeniz için oluşturulan tabloları,
         kullanıcıları, indeksleri ve rolleri temizler.
======================================================================== */

USE WideWorldImporters;
GO

PRINT 'Proje 1 sıfırlaması başlatıldı...';

-- 1. Güvenlik ve Rol Temizlikleri 
IF DATABASE_PRINCIPAL_ID('PerfDemoReader') IS NOT NULL DROP ROLE PerfDemoReader;
IF DATABASE_PRINCIPAL_ID('PerfDemoAnalyst') IS NOT NULL DROP ROLE PerfDemoAnalyst;
IF DATABASE_PRINCIPAL_ID('PerfDemoAdmin') IS NOT NULL DROP ROLE PerfDemoAdmin;

IF DATABASE_PRINCIPAL_ID('reader_user') IS NOT NULL DROP USER reader_user;
IF DATABASE_PRINCIPAL_ID('analyst_user') IS NOT NULL DROP USER analyst_user;
IF DATABASE_PRINCIPAL_ID('admin_user') IS NOT NULL DROP USER admin_user;

-- 2. Tablo Temizlikleri (Bu komutlar aynı zamanda üzerlerindeki indeksleri de siler)
DROP TABLE IF EXISTS dbo.OrderLines_PerfDemo;
DROP TABLE IF EXISTS dbo.OrderLines_FragDemo;

-- 3. Cache Temizliği
DBCC DROPCLEANBUFFERS WITH NO_INFOMSGS;
DBCC FREEPROCCACHE WITH NO_INFOMSGS;

PRINT 'Proje 1 sıfırlaması başarıyla tamamlandı.';
GO
