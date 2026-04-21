/* ========================================================================
   PROJE 2: Veritabanı Yedekleme ve Felaketten Kurtarma Planı
   Dosya  : 01_DR_Setup.sql
   Amaç   : Kurtarma testleri için izole bir veritabanı oluşturmak.
======================================================================== */
USE master;
GO

-- 1) Yeni bir test veritabanı oluşturma
IF DB_ID('DisasterRecoveryTest_DB') IS NOT NULL
BEGIN
    ALTER DATABASE DisasterRecoveryTest_DB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DisasterRecoveryTest_DB;
END
GO

CREATE DATABASE DisasterRecoveryTest_DB;
GO

-- 2)Veritabanının Kurtarma Modelini (Recovery Model) FULL olarak ayarlama.
-- (Log yedekleri ve Point-in-time restore sadece FULL modelde çalışır).
ALTER DATABASE DisasterRecoveryTest_DB SET RECOVERY FULL;
GO

USE DisasterRecoveryTest_DB;
GO

-- 3) Test için basit bir tablo oluşturma.
CREATE TABLE dbo.MusteriHesaplari (
    HesapID INT IDENTITY(1,1) PRIMARY KEY,
    MusteriAd NVARCHAR(100),
    Bakiye DECIMAL(18,2),
    OlusturmaTarihi DATETIME DEFAULT GETDATE()
);
GO

-- 4) İçine başlangıç verileri ekleme (1000 satır).
SET NOCOUNT ON;
DECLARE @i INT = 1;
WHILE @i <= 1000
BEGIN
    INSERT INTO dbo.MusteriHesaplari (MusteriAd, Bakiye)
    VALUES ('Müşteri_' + CAST(@i AS NVARCHAR), RAND() * 10000);
    SET @i = @i + 1;
END
SET NOCOUNT OFF;
GO

PRINT 'DisasterRecoveryTest_DB veritabanı ve MusteriHesaplari tablosu başarıyla oluşturuldu.';
GO

SELECT TOP 100 * FROM dbo.MusteriHesaplari;
