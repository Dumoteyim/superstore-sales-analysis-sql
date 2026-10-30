/*
  Superstore Sales Analysis — dimensional model
  ----------------------------------------------
  Builds a reusable star-schema-style layer from dbo.Superstore.

  Improvements over the source-report prototype:
    - Dimension keys are validated before dimension creation.
    - A location is uniquely identified by country, state, city, postal code,
      and region—not by city or state alone.
    - The reporting view joins dimensions through unique business keys, avoiding
      accidental multiplication of fact rows in geography analysis.
    - Date calculations use TRY_CONVERT and stop when invalid dates are found.

  Prerequisite: dbo.Superstore must already exist after the CSV import.
*/

USE SuperstoreDB;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

IF OBJECT_ID(N'dbo.Superstore', N'U') IS NULL
BEGIN
    THROW 50000, N'dbo.Superstore was not found. Import the source CSV before running this script.', 1;
END;
GO

/* Confirm that the imported table exposes every field used by this project. */
DECLARE @RequiredColumns TABLE (ColumnName sysname NOT NULL PRIMARY KEY);
INSERT INTO @RequiredColumns (ColumnName)
VALUES
    (N'Row_ID'), (N'Order_ID'), (N'Order_Date'), (N'Ship_Date'), (N'Ship_Mode'),
    (N'Customer_ID'), (N'Customer_Name'), (N'Segment'), (N'Country'), (N'City'),
    (N'State'), (N'Postal_Code'), (N'Region'), (N'Product_ID'), (N'Category'),
    (N'Sub_Category'), (N'Product_Name'), (N'Sales'), (N'Quantity'),
    (N'Discount'), (N'Profit');

IF EXISTS
(
    SELECT 1
    FROM @RequiredColumns AS required
    LEFT JOIN sys.columns AS existing
        ON existing.object_id = OBJECT_ID(N'dbo.Superstore')
       AND existing.name = required.ColumnName
    WHERE existing.name IS NULL
)
BEGIN
    SELECT required.ColumnName AS Missing_Column
    FROM @RequiredColumns AS required
    LEFT JOIN sys.columns AS existing
        ON existing.object_id = OBJECT_ID(N'dbo.Superstore')
       AND existing.name = required.ColumnName
    WHERE existing.name IS NULL;

    THROW 50001, N'The imported table is missing one or more required columns.', 1;
END;
GO

/* Stop before building dimensions when dates cannot be interpreted. */
IF EXISTS
(
    SELECT 1
    FROM dbo.Superstore
    WHERE [Order_Date] IS NULL
       OR TRY_CONVERT(date, [Order_Date]) IS NULL
)
BEGIN
    THROW 50002, N'Order_Date contains NULL or non-date values. Correct the import before modelling.', 1;
END;
GO

IF EXISTS
(
    SELECT 1
    FROM dbo.Superstore
    WHERE [Product_ID] IS NULL
       OR [Customer_ID] IS NULL
)
BEGIN
    THROW 50005, N'Product_ID or Customer_ID contains NULL values. Correct the import before modelling.', 1;
END;
GO

/* Product and customer identifiers must map consistently to one descriptive record. */
IF EXISTS
(
    SELECT 1
    FROM dbo.Superstore
    GROUP BY CONVERT(nvarchar(100), [Product_ID])
    HAVING COUNT(DISTINCT CONCAT(
        COALESCE(CONVERT(nvarchar(500), [Product_Name]), N'[NULL]'), N'|',
        COALESCE(CONVERT(nvarchar(100), [Category]), N'[NULL]'), N'|',
        COALESCE(CONVERT(nvarchar(100), [Sub_Category]), N'[NULL]')
    )) > 1
)
BEGIN
    THROW 50003, N'At least one Product_ID maps to conflicting product attributes.', 1;
END;

IF EXISTS
(
    SELECT 1
    FROM dbo.Superstore
    GROUP BY CONVERT(nvarchar(100), [Customer_ID])
    HAVING COUNT(DISTINCT CONCAT(
        COALESCE(CONVERT(nvarchar(500), [Customer_Name]), N'[NULL]'), N'|',
        COALESCE(CONVERT(nvarchar(100), [Segment]), N'[NULL]')
    )) > 1
)
BEGIN
    THROW 50004, N'At least one Customer_ID maps to conflicting customer attributes.', 1;
END;
GO

/* Remove the reporting view before rebuilding its dependencies. */
IF OBJECT_ID(N'dbo.vw_Superstore_Star', N'V') IS NOT NULL
    DROP VIEW dbo.vw_Superstore_Star;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    DROP TABLE IF EXISTS dbo.DimLocation;
    DROP TABLE IF EXISTS dbo.DimCustomer;
    DROP TABLE IF EXISTS dbo.DimProduct;
    DROP TABLE IF EXISTS dbo.DimDate;

    CREATE TABLE dbo.DimDate
    (
        DateKey      date         NOT NULL CONSTRAINT PK_DimDate PRIMARY KEY,
        [Year]       smallint     NOT NULL,
        Month_Number tinyint      NOT NULL,
        Day_Number   tinyint      NOT NULL,
        Month_Name   nvarchar(20) NOT NULL,
        Day_Name     nvarchar(20) NOT NULL,
        Month_Short  char(3)      NOT NULL,
        Day_Short    char(3)      NOT NULL
    );

    INSERT INTO dbo.DimDate
    (
        DateKey, [Year], Month_Number, Day_Number,
        Month_Name, Day_Name, Month_Short, Day_Short
    )
    SELECT DISTINCT
        CONVERT(date, s.[Order_Date]) AS DateKey,
        YEAR(CONVERT(date, s.[Order_Date])) AS [Year],
        MONTH(CONVERT(date, s.[Order_Date])) AS Month_Number,
        DAY(CONVERT(date, s.[Order_Date])) AS Day_Number,
        DATENAME(month, CONVERT(date, s.[Order_Date])) AS Month_Name,
        DATENAME(weekday, CONVERT(date, s.[Order_Date])) AS Day_Name,
        LEFT(DATENAME(month, CONVERT(date, s.[Order_Date])), 3) AS Month_Short,
        LEFT(DATENAME(weekday, CONVERT(date, s.[Order_Date])), 3) AS Day_Short
    FROM dbo.Superstore AS s;

    CREATE TABLE dbo.DimProduct
    (
        Product_ID   nvarchar(100) NOT NULL CONSTRAINT PK_DimProduct PRIMARY KEY,
        Product_Name nvarchar(500) NOT NULL,
        Category     nvarchar(100) NOT NULL,
        Sub_Category nvarchar(100) NOT NULL
    );

    INSERT INTO dbo.DimProduct (Product_ID, Product_Name, Category, Sub_Category)
    SELECT DISTINCT
        CONVERT(nvarchar(100), s.[Product_ID]),
        COALESCE(CONVERT(nvarchar(500), s.[Product_Name]), N'[Unknown]'),
        COALESCE(CONVERT(nvarchar(100), s.[Category]), N'[Unknown]'),
        COALESCE(CONVERT(nvarchar(100), s.[Sub_Category]), N'[Unknown]')
    FROM dbo.Superstore AS s;

    CREATE TABLE dbo.DimCustomer
    (
        Customer_ID   nvarchar(100) NOT NULL CONSTRAINT PK_DimCustomer PRIMARY KEY,
        Customer_Name nvarchar(500) NOT NULL,
        Segment       nvarchar(100) NOT NULL
    );

    INSERT INTO dbo.DimCustomer (Customer_ID, Customer_Name, Segment)
    SELECT DISTINCT
        CONVERT(nvarchar(100), s.[Customer_ID]),
        COALESCE(CONVERT(nvarchar(500), s.[Customer_Name]), N'[Unknown]'),
        COALESCE(CONVERT(nvarchar(100), s.[Segment]), N'[Unknown]')
    FROM dbo.Superstore AS s;

    /*
      Postal codes are stored as text to retain leading zeroes. The complete
      five-column business key prevents city- or state-only join duplication.
    */
    CREATE TABLE dbo.DimLocation
    (
        LocationKey int IDENTITY(1, 1) NOT NULL CONSTRAINT PK_DimLocation PRIMARY KEY,
        Country     nvarchar(100) NOT NULL,
        City        nvarchar(100) NOT NULL,
        [State]     nvarchar(100) NOT NULL,
        Postal_Code nvarchar(30)  NOT NULL,
        Region      nvarchar(100) NOT NULL,
        CONSTRAINT UQ_DimLocation_NaturalKey UNIQUE (Country, City, [State], Postal_Code, Region)
    );

    INSERT INTO dbo.DimLocation (Country, City, [State], Postal_Code, Region)
    SELECT DISTINCT
        COALESCE(CONVERT(nvarchar(100), s.[Country]), N'[Unknown]'),
        COALESCE(CONVERT(nvarchar(100), s.[City]), N'[Unknown]'),
        COALESCE(CONVERT(nvarchar(100), s.[State]), N'[Unknown]'),
        COALESCE(CONVERT(nvarchar(30), s.[Postal_Code]), N'[Unknown]'),
        COALESCE(CONVERT(nvarchar(100), s.[Region]), N'[Unknown]')
    FROM dbo.Superstore AS s;

    CREATE INDEX IX_DimDate_Year_Month ON dbo.DimDate ([Year], Month_Number);
    CREATE INDEX IX_DimProduct_Category ON dbo.DimProduct (Category, Sub_Category);
    CREATE INDEX IX_DimCustomer_Segment ON dbo.DimCustomer (Segment);
    CREATE INDEX IX_DimLocation_Geography ON dbo.DimLocation ([State], City, Region);

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

/*
  The view exposes a safe, readable star-schema layer without changing the
  imported raw table. Every dimension join is one-to-one by construction.
*/
CREATE OR ALTER VIEW dbo.vw_Superstore_Star
AS
SELECT
    s.*,
    d.DateKey,
    d.[Year] AS Order_Year,
    d.Month_Number AS Order_Month_Number,
    d.Month_Name AS Order_Month_Name,
    d.Day_Name AS Order_Day_Name,
    p.Product_Name AS Dimension_Product_Name,
    p.Category AS Dimension_Category,
    p.Sub_Category AS Dimension_Sub_Category,
    c.Customer_Name AS Dimension_Customer_Name,
    c.Segment AS Dimension_Segment,
    l.LocationKey
FROM dbo.Superstore AS s
LEFT JOIN dbo.DimDate AS d
    ON d.DateKey = TRY_CONVERT(date, s.[Order_Date])
LEFT JOIN dbo.DimProduct AS p
    ON p.Product_ID = CONVERT(nvarchar(100), s.[Product_ID])
LEFT JOIN dbo.DimCustomer AS c
    ON c.Customer_ID = CONVERT(nvarchar(100), s.[Customer_ID])
LEFT JOIN dbo.DimLocation AS l
    ON l.Country = COALESCE(CONVERT(nvarchar(100), s.[Country]), N'[Unknown]')
   AND l.City = COALESCE(CONVERT(nvarchar(100), s.[City]), N'[Unknown]')
   AND l.[State] = COALESCE(CONVERT(nvarchar(100), s.[State]), N'[Unknown]')
   AND l.Postal_Code = COALESCE(CONVERT(nvarchar(30), s.[Postal_Code]), N'[Unknown]')
   AND l.Region = COALESCE(CONVERT(nvarchar(100), s.[Region]), N'[Unknown]');
GO

/* Quick model inventory. */
SELECT N'DimDate' AS Object_Name, COUNT(*) AS Row_Count FROM dbo.DimDate
UNION ALL SELECT N'DimProduct', COUNT(*) FROM dbo.DimProduct
UNION ALL SELECT N'DimCustomer', COUNT(*) FROM dbo.DimCustomer
UNION ALL SELECT N'DimLocation', COUNT(*) FROM dbo.DimLocation
UNION ALL SELECT N'Superstore', COUNT(*) FROM dbo.Superstore;
GO
