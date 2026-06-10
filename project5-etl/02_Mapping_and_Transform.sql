USE TransactionDB;
GO

/* ===== 1. REFERANS (MAPPING) TABLOLARI ===== */
IF OBJECT_ID('map_product','U') IS NOT NULL DROP TABLE map_product;
CREATE TABLE map_product (Raw_Pattern VARCHAR(50), Standard_Value VARCHAR(100));
INSERT INTO map_product VALUES
    ('smar','Smartphone'), ('s','Smartphone'),
    ('lap','Laptop'),      ('la','Laptop'), ('l','Laptop'),
    ('tab','Tablet'),      ('ta','Tablet'), ('t','Tablet'),
    ('cof','Coffee Machine'), ('c','Coffee Machine'),
    ('head','Headphones'), ('h','Headphones');

IF OBJECT_ID('map_payment','U') IS NOT NULL DROP TABLE map_payment;
CREATE TABLE map_payment (Raw_Key VARCHAR(50), Standard_Value VARCHAR(50));
INSERT INTO map_payment VALUES
    ('paypal','PayPal'), ('creditcard','Credit Card'),
    ('debitcard','Debit Card'), ('cash','Cash'), ('banktransfer','Bank Transfer');

IF OBJECT_ID('map_status','U') IS NOT NULL DROP TABLE map_status;
CREATE TABLE map_status (Raw_Pattern VARCHAR(50), Standard_Value VARCHAR(50));
INSERT INTO map_status VALUES
    ('complet','Completed'), ('pend','Pending'), ('fail','Failed'),
    ('cancel','Cancelled'), ('refund','Refunded');
GO

/* ===== 2. TRANSFORM (Genişletilmiş Kapasite ile Gap Filling) ===== */
IF OBJECT_ID('stg_financial_transactions','U') IS NOT NULL DROP TABLE stg_financial_transactions;
GO

-- A. GARANTİLİ SAYI ÜRETİCİ (Kapasite 200,000'e çıkarıldı)
WITH 
L0 AS (SELECT 1 AS c UNION ALL SELECT 1),
L1 AS (SELECT 1 AS c FROM L0 a CROSS JOIN L0 b),
L2 AS (SELECT 1 AS c FROM L1 a CROSS JOIN L1 b),
L3 AS (SELECT 1 AS c FROM L2 a CROSS JOIN L2 b),
L4 AS (SELECT 1 AS c FROM L3 a CROSS JOIN L3 b),
L5 AS (SELECT 1 AS c FROM L4 a CROSS JOIN L4 b),
Tally AS (SELECT TOP 200000 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS N FROM L5),

-- B. HALİHAZIRDA VAR OLAN VE GEÇERLİ OLAN ID NUMARALARI
ExistingIDs AS (
    SELECT TRY_CAST(SUBSTRING(LTRIM(RTRIM(Transaction_ID)), 2, 50) AS INT) AS ExistingNum
    FROM raw_financial_transactions
    WHERE LTRIM(RTRIM(Transaction_ID)) LIKE 'T[0-9]%'
),

-- C. BOŞLUKLARI BULMA: Tally'den var olanları güvenle çıkarıyoruz
AvailableNumbers AS (
    SELECT N FROM Tally 
    EXCEPT 
    SELECT ExistingNum FROM ExistingIDs WHERE ExistingNum IS NOT NULL
),
AvailableIDs AS (
    SELECT N, ROW_NUMBER() OVER (ORDER BY N) AS seq
    FROM AvailableNumbers
),

-- D. MOD TARİH BULMA VE TEMEL TEMİZLEME
ModeDateCTE AS (
    SELECT TOP 1 TRY_CONVERT(DATE, Transaction_Date) AS Mode_Date
    FROM raw_financial_transactions
    WHERE TRY_CONVERT(DATE, Transaction_Date) IS NOT NULL
    GROUP BY TRY_CONVERT(DATE, Transaction_Date)
    ORDER BY COUNT(*) DESC
),
ParsedData AS (
    SELECT
        r.Row_ID,
        NULLIF(LTRIM(RTRIM(r.Transaction_ID)), '') AS Raw_Txn_ID,
        COALESCE(TRY_CONVERT(DATE, r.Transaction_Date), m.Mode_Date) AS Transaction_Date,
        ISNULL(NULLIF(LTRIM(RTRIM(r.Customer_ID)),''),'UNKNOWN_CUST') AS Customer_ID,
        ISNULL(p.Standard_Value, ISNULL(NULLIF(LTRIM(RTRIM(r.Product_Name)),''),'UNKNOWN_PROD')) AS Product_Name,
        CAST(ABS(TRY_CONVERT(FLOAT, r.Quantity)) AS INT) AS Quantity,
        CAST(ABS(TRY_CONVERT(FLOAT, REPLACE(REPLACE(REPLACE(REPLACE(LOWER(r.Price),'$',''),',',''),' ',''),'price',''))) AS DECIMAL(10,2)) AS Price,
        ISNULL(mpay.Standard_Value, NULLIF(LTRIM(RTRIM(r.Payment_Method)),'')) AS Payment_Method,
        s.Standard_Value AS Transaction_Status
    FROM raw_financial_transactions r
    CROSS JOIN ModeDateCTE m  
    OUTER APPLY (SELECT TOP 1 Standard_Value FROM map_product WHERE LOWER(LTRIM(RTRIM(r.Product_Name))) LIKE Raw_Pattern + '%' ORDER BY LEN(Raw_Pattern) DESC) p
    LEFT JOIN map_payment mpay ON REPLACE(LOWER(LTRIM(RTRIM(r.Payment_Method))),' ','') = mpay.Raw_Key
    OUTER APPLY (SELECT TOP 1 Standard_Value FROM map_status WHERE LOWER(LTRIM(RTRIM(r.Transaction_Status))) LIKE Raw_Pattern + '%' ORDER BY LEN(Raw_Pattern) DESC) s
),

-- E. YİNELENENLERİ (ÇAKIŞMALARI) BULMA
DataWithRN AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY Raw_Txn_ID ORDER BY Row_ID) AS rn
    FROM ParsedData
),

-- F. YENİ ID'YE İHTİYACI OLANLARI SIRALAMA
RowsNeedingID AS (
    SELECT Row_ID, ROW_NUMBER() OVER (ORDER BY Row_ID) AS NeedSeq
    FROM DataWithRN
    WHERE Raw_Txn_ID IS NULL OR rn > 1
)

-- G. NİHAİ BİRLEŞTİRME VE BOŞLUKLARI DOLDURMA
SELECT
    d.Row_ID, 
    CASE 
        -- Eğer ID yoksa veya mükerrerse, havuzdan ID al:
        WHEN d.Raw_Txn_ID IS NULL OR d.rn > 1 THEN 
            CASE 
                -- Sayı 10.000'den küçükse 4 haneye tamamla (Örn: 45 -> T0045)
                WHEN a.N < 10000 THEN 'T' + RIGHT('0000' + CAST(a.N AS VARCHAR(10)), 4)
                -- Sayı 10.000 ve üzeriyse doğal halini bırak (Örn: 10001 -> T10001)
                ELSE 'T' + CAST(a.N AS VARCHAR(10))
            END
        -- Eğer ESKİ ve sağlam bir ID ise ASLA dokunma, aynen kalsın!
        ELSE d.Raw_Txn_ID 
    END AS Transaction_ID,
    d.Transaction_Date, 
    d.Customer_ID, 
    d.Product_Name, 
    d.Quantity, 
    d.Price, 
    d.Payment_Method, 
    d.Transaction_Status
INTO stg_financial_transactions
FROM DataWithRN d
LEFT JOIN RowsNeedingID r_need ON d.Row_ID = r_need.Row_ID
LEFT JOIN AvailableIDs a ON r_need.NeedSeq = a.seq;

SELECT TOP 100 * FROM stg_financial_transactions ORDER BY Transaction_ID;