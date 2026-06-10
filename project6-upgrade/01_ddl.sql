USE TransactionDB;
GO

-- DDL Trigger Silme
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_TrackSchemaChanges' AND parent_class = 0)
BEGIN
    DROP TRIGGER trg_TrackSchemaChanges ON DATABASE;
END
GO

-- 1. SÜRÜM KONTROL LOG TABLOSU OLUŞTURMA
IF OBJECT_ID('SchemaChangeLog', 'U') IS NOT NULL DROP TABLE SchemaChangeLog;
CREATE TABLE SchemaChangeLog (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    EventDate DATETIME DEFAULT GETDATE(),
    DatabaseUser NVARCHAR(100),
    EventType NVARCHAR(100),
    ObjectName NVARCHAR(100),
    TSQLCommand NVARCHAR(MAX)
);
GO

-- 2. DDL TRIGGER KURULUMU
CREATE OR ALTER TRIGGER trg_TrackSchemaChanges
ON DATABASE
FOR DDL_DATABASE_LEVEL_EVENTS
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @EventData XML = EVENTDATA();
    INSERT INTO SchemaChangeLog (DatabaseUser, EventType, ObjectName, TSQLCommand)
    VALUES (
        @EventData.value('(/EVENT_INSTANCE/LoginName)[1]', 'NVARCHAR(100)'),
        @EventData.value('(/EVENT_INSTANCE/EventType)[1]', 'NVARCHAR(100)'),
        @EventData.value('(/EVENT_INSTANCE/ObjectName)[1]', 'NVARCHAR(100)'),
        @EventData.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'NVARCHAR(MAX)')
    );
END;
GO

-- 3. TEST AŞAMASI
IF OBJECT_ID('Test_Tablosu_V1', 'U') IS NOT NULL DROP TABLE Test_Tablosu_V1;
CREATE TABLE Test_Tablosu_V1 (ID INT);
GO
ALTER TABLE Test_Tablosu_V1 ADD Kolon VARCHAR(10);
GO
DROP TABLE Test_Tablosu_V1;
GO

-- 4. LOG TABLOSU ÇIKTISI
SELECT EventDate AS [Tarih], DatabaseUser AS [Kullanici], EventType AS [Olay_Tipi], ObjectName AS [Nesne], TSQLCommand AS [Calistirilan_Kod]
FROM SchemaChangeLog ORDER BY EventDate DESC;