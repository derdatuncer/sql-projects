USE TransactionDB;
GO

/* ================================================================
   ADIM 5 - QUARANTINE (KARANTİNA)
   Amaç: Kurallara uymayan (Fiyat/Miktar boş, Statü bozuk) verileri ayırmak
   ================================================================ */
IF OBJECT_ID('rejected_financial_transactions','U') IS NOT NULL 
    DROP TABLE rejected_financial_transactions;

SELECT * INTO rejected_financial_transactions 
FROM stg_financial_transactions 
WHERE Quantity IS NULL OR Quantity = 0 OR Price IS NULL OR Transaction_Status IS NULL;
GO

/* ================================================================
   ADIM 6 - LOAD (TEMİZ VERİYİ HEDEF TABLOYA YÜKLEME)
   Amaç: Sadece %100 güvenilir verileri Veri Ambarına eklemek
   ================================================================ */
IF OBJECT_ID('clean_financial_transactions','U') IS NOT NULL 
    DROP TABLE clean_financial_transactions;

CREATE TABLE clean_financial_transactions (
    Transaction_ID VARCHAR(50) PRIMARY KEY, 
    Transaction_Date DATE NOT NULL, 
    Customer_ID VARCHAR(50),
    Product_Name VARCHAR(100), 
    Quantity INT CHECK (Quantity > 0), 
    Price DECIMAL(10,2) CHECK (Price >= 0),
    Payment_Method VARCHAR(50), 
    Transaction_Status VARCHAR(50)
);

INSERT INTO clean_financial_transactions
SELECT 
    Transaction_ID, Transaction_Date, Customer_ID, Product_Name, 
    Quantity, Price, Payment_Method, Transaction_Status
FROM stg_financial_transactions 
WHERE Quantity > 0 AND Price >= 0 AND Transaction_Status IS NOT NULL;
GO

/* ================================================================
   ADIM 7 - BİTİRİCİ RAPOR (DATA QUALITY REPORT)
   Amaç: Hocalarına projenin genel başarı özetini sunmak
   ================================================================ */
SELECT
    (SELECT COUNT(*) FROM raw_financial_transactions) AS [Sisteme Giren Ham Veri],
    (SELECT COUNT(*) FROM clean_financial_transactions) AS [Temizlenen ve Kurtarilan Veri],
    (SELECT COUNT(*) FROM rejected_financial_transactions) AS [Karantinaya Alinan (Cop)],
    CAST(100.0 * (SELECT COUNT(*) FROM clean_financial_transactions)
         / NULLIF((SELECT COUNT(*) FROM raw_financial_transactions),0)
         AS DECIMAL(5,2)) AS [Basari Orani Yuzdesi];

SELECT TOP 100 * FROM clean_financial_transactions;