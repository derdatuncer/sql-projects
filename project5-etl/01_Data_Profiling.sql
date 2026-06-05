USE TransactionDB;
GO

/* ================================================================
   ADIM 1 - EXTRACT: Ham veriyi güvenli katmana al
   ================================================================ */
IF OBJECT_ID('raw_financial_transactions','U') IS NOT NULL 
    DROP TABLE raw_financial_transactions;
GO

CREATE TABLE raw_financial_transactions (
    Row_ID             INT IDENTITY(1,1) PRIMARY KEY,
    Transaction_ID     VARCHAR(50),
    Transaction_Date   VARCHAR(50),
    Customer_ID        VARCHAR(50),
    Product_Name       VARCHAR(100),
    Quantity           VARCHAR(50),
    Price              VARCHAR(50),
    Payment_Method     VARCHAR(50),
    Transaction_Status VARCHAR(50),
    Loaded_At          DATETIME2 DEFAULT SYSDATETIME()
);
GO

INSERT INTO raw_financial_transactions
    (Transaction_ID, Transaction_Date, Customer_ID, Product_Name,
     Quantity, Price, Payment_Method, Transaction_Status)
SELECT
    CAST(Transaction_ID     AS VARCHAR(50)),
    CAST(Transaction_Date   AS VARCHAR(50)),
    CAST(Customer_ID        AS VARCHAR(50)),
    CAST(Product_Name       AS VARCHAR(100)),
    CAST(Quantity           AS VARCHAR(50)),
    CAST(Price              AS VARCHAR(50)),
    CAST(Payment_Method     AS VARCHAR(50)),
    CAST(Transaction_Status AS VARCHAR(50))
FROM dirty_financial_transactions;
GO

/* ================================================================
   ADIM 2 - PROFILLEME: Detaylı ve Kurumsal Veri Kalitesi Metrikleri
   ================================================================ */
IF OBJECT_ID('dq_report','U') IS NOT NULL 
    DROP TABLE dq_report;
GO

CREATE TABLE dq_report (
    Report_ID    INT IDENTITY(1,1) PRIMARY KEY,
    Stage        VARCHAR(20),
    Metric_Name  VARCHAR(120),
    Metric_Value INT,
    Captured_At  DATETIME2 DEFAULT SYSDATETIME()
);
GO

INSERT INTO dq_report (Stage, Metric_Name, Metric_Value)
SELECT 'ONCE', '1. Toplam Kayit Sayisi', COUNT(*) FROM raw_financial_transactions
UNION ALL 
SELECT 'ONCE', '2. Eksik / Bos Transaction_ID', COUNT(*) FROM raw_financial_transactions
    WHERE NULLIF(LTRIM(RTRIM(Transaction_ID)),'') IS NULL
UNION ALL 
SELECT 'ONCE', '3. Eksik / Bos Customer_ID', COUNT(*) FROM raw_financial_transactions
    WHERE NULLIF(LTRIM(RTRIM(Customer_ID)),'') IS NULL
UNION ALL 
SELECT 'ONCE', '4. Gecersiz Tarih (Orn: 13. Ay / Uyumsuz Format)', COUNT(*) FROM raw_financial_transactions
    WHERE TRY_CONVERT(DATE, Transaction_Date) IS NULL 
UNION ALL 
SELECT 'ONCE', '5. Mantiksiz (-) Negatif veya Sifir Miktar', COUNT(*) FROM raw_financial_transactions
    WHERE TRY_CONVERT(FLOAT, Quantity) <= 0
UNION ALL 
SELECT 'ONCE', '6. İcinde Dolar ($) veya Harf Olan Bozuk Fiyatlar', COUNT(*) FROM raw_financial_transactions
    WHERE Price LIKE '%$%' OR Price LIKE '%[a-zA-Z]%'
UNION ALL 
SELECT 'ONCE', '7. Eksik / Bos Birakilmis Fiyatlar', COUNT(*) FROM raw_financial_transactions
    WHERE NULLIF(LTRIM(RTRIM(Price)),'') IS NULL;
GO

SELECT Metric_Name AS [Detayli Profilleme Metrigi], Metric_Value AS [Tespit Edilen Hata Sayisi] 
FROM dq_report 
WHERE Stage = 'ONCE'
ORDER BY Metric_Name;