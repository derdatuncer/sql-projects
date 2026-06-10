USE msdb;
GO

SELECT TOP 20
    bs.database_name AS [Veritabani],
    CASE bs.[type] 
        WHEN 'D' THEN 'Full Backup (Tam)' 
        WHEN 'I' THEN 'Differential (Fark)' 
        WHEN 'L' THEN 'Transaction Log' 
    END AS [Yedek_Turu],
    CONVERT(VARCHAR, bs.backup_start_date, 120) AS [Baslangic_Zamani],
    CONVERT(VARCHAR, bs.backup_finish_date, 120) AS [Bitis_Zamani],
    CAST(bs.backup_size / 1024 / 1024 AS DECIMAL(10,2)) AS [Boyut_MB],
    bmf.physical_device_name AS [Kayitli_Dosya_Yolu],
    CASE 
        WHEN bs.backup_finish_date IS NOT NULL THEN 'BASARILI' 
        ELSE 'HATALI' 
    END AS [Durum]
FROM msdb.dbo.backupset bs
INNER JOIN msdb.dbo.backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
WHERE bs.database_name = 'TransactionDB'
ORDER BY bs.backup_finish_date DESC;
GO