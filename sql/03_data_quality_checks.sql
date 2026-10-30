/*
  Superstore Sales Analysis — data quality and integrity checks
  -------------------------------------------------------------
  Run after sql/01_build_dimensions.sql. Review every result set before using
  the analytical outputs for decisions.
*/

USE SuperstoreDB;
GO

/* 01 — Raw-table volume and date coverage */
SELECT
    COUNT(*) AS Transaction_Line_Count,
    COUNT(DISTINCT Order_ID) AS Distinct_Order_Count,
    MIN(TRY_CONVERT(date, Order_Date)) AS First_Order_Date,
    MAX(TRY_CONVERT(date, Order_Date)) AS Last_Order_Date
FROM dbo.Superstore;
GO

/* 02 — Duplicate source row identifiers; expected result: no rows */
SELECT
    Row_ID,
    COUNT(*) AS Duplicate_Count
FROM dbo.Superstore
GROUP BY Row_ID
HAVING COUNT(*) > 1;
GO

/* 03 — Non-convertible dates; expected result: no rows */
SELECT
    Row_ID,
    Order_ID,
    Order_Date,
    Ship_Date
FROM dbo.Superstore
WHERE TRY_CONVERT(date, Order_Date) IS NULL
   OR (Ship_Date IS NOT NULL AND TRY_CONVERT(date, Ship_Date) IS NULL);
GO

/* 04 — Missing or non-numeric measures */
SELECT
    SUM(CASE WHEN TRY_CONVERT(decimal(19, 4), Sales) IS NULL THEN 1 ELSE 0 END) AS Invalid_Sales_Rows,
    SUM(CASE WHEN TRY_CONVERT(int, Quantity) IS NULL THEN 1 ELSE 0 END) AS Invalid_Quantity_Rows,
    SUM(CASE WHEN TRY_CONVERT(decimal(19, 4), Discount) IS NULL THEN 1 ELSE 0 END) AS Invalid_Discount_Rows,
    SUM(CASE WHEN TRY_CONVERT(decimal(19, 4), Profit) IS NULL THEN 1 ELSE 0 END) AS Invalid_Profit_Rows
FROM dbo.Superstore;
GO

/* 05 — Verify that every fact row reached every dimension exactly once. */
SELECT
    COUNT(*) AS Fact_Row_Count,
    SUM(CASE WHEN DateKey IS NULL THEN 1 ELSE 0 END) AS Unmatched_Date_Rows,
    SUM(CASE WHEN Dimension_Product_Name IS NULL THEN 1 ELSE 0 END) AS Unmatched_Product_Rows,
    SUM(CASE WHEN Dimension_Customer_Name IS NULL THEN 1 ELSE 0 END) AS Unmatched_Customer_Rows,
    SUM(CASE WHEN LocationKey IS NULL THEN 1 ELSE 0 END) AS Unmatched_Location_Rows
FROM dbo.vw_Superstore_Star;
GO

/* 06 — The safe reporting view must have the same row count as the raw fact table. */
SELECT
    (SELECT COUNT(*) FROM dbo.Superstore) AS Raw_Fact_Rows,
    (SELECT COUNT(*) FROM dbo.vw_Superstore_Star) AS Reporting_View_Rows,
    (SELECT COUNT(*) FROM dbo.vw_Superstore_Star) -
    (SELECT COUNT(*) FROM dbo.Superstore) AS Unexpected_Row_Difference;
GO

/*
  07 — Cities appearing in multiple location records. This is diagnostic proof
  of why city-only joins are unsafe and can inflate sales totals.
*/
SELECT
    City,
    COUNT(*) AS Distinct_Location_Records
FROM dbo.DimLocation
GROUP BY City
HAVING COUNT(*) > 1
ORDER BY Distinct_Location_Records DESC, City;
GO

/* 08 — Compare raw fact sales with safe-view sales. They must agree. */
SELECT
    (SELECT SUM(TRY_CONVERT(decimal(19, 4), Sales)) FROM dbo.Superstore) AS Raw_Total_Sales,
    (SELECT SUM(TRY_CONVERT(decimal(19, 4), Sales)) FROM dbo.vw_Superstore_Star) AS View_Total_Sales;
GO

/* 09 — Flag measures that deserve inspection rather than silently excluding them. */
SELECT
    Row_ID,
    Order_ID,
    Sales,
    Profit,
    Discount,
    Quantity
FROM dbo.Superstore
WHERE TRY_CONVERT(decimal(19, 4), Sales) < 0
   OR TRY_CONVERT(decimal(19, 4), Discount) NOT BETWEEN 0 AND 1
   OR TRY_CONVERT(int, Quantity) <= 0
ORDER BY Row_ID;
GO
