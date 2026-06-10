USE TransactionDB;
GO

/* ================================================================
   0. HAZIRLIK: SİSTEMDE VAR OLAN KRİTİK BİR TABLO
   ================================================================ */
IF OBJECT_ID('Kritik_Tablo', 'U') IS NOT NULL DROP TABLE Kritik_Tablo;
CREATE TABLE Kritik_Tablo (ID INT, Veri VARCHAR(50));
INSERT INTO Kritik_Tablo VALUES (1, 'Test Verisi');
GO

/* ================================================================
   1. GÜVENLİ DURUM YEDEĞİ
   ================================================================ */
USE master;
GO
BACKUP DATABASE TransactionDB 
TO DISK = 'TransactionDB_SafeState.bak' 
WITH INIT, NAME = 'Güvenli Durum Yedeği';
GO

/* ================================================================
   2. Felaket Senaryosu
   ================================================================ */
USE TransactionDB;
GO
DROP TABLE Kritik_Tablo;
GO

/* ================================================================
   3. TESPİT AŞAMASI 
   ================================================================ */
SELECT TOP 1 
    EventDate AS [Kaza_Saati], 
    DatabaseUser AS [Sorumlu], 
    EventType AS [Hata], 
    ObjectName AS [Silinen_Nesne]
FROM SchemaChangeLog 
WHERE EventType = 'DROP_TABLE' 
ORDER BY EventDate DESC;
GO

/* ================================================================
   4. GERİ DÖNÜŞ (ROLLBACK) İŞLEMİ
   ================================================================ */
USE master;
GO
ALTER DATABASE TransactionDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO
RESTORE DATABASE TransactionDB 
FROM DISK = 'TransactionDB_SafeState.bak' 
WITH REPLACE;
GO
ALTER DATABASE TransactionDB SET MULTI_USER;
GO

/* ================================================================
   5. Kanıt
   ================================================================ */
-- Juriye verinin kaybolmadığını kanıtlayan son sorgu
SELECT * FROM Kritik_Tablo;
GO