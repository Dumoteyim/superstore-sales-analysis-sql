/*
  Superstore Sales Analysis — analytical query suite
  ---------------------------------------------------
  Run sql/01_build_dimensions.sql first. These queries retain the business
  questions from the source report while using the safe reporting view.

  Important: Total_Sales is a revenue aggregate, not a product price.
  Profit margin is calculated from total profit / total sales, not by averaging
  row-level margins.
*/

USE SuperstoreDB;
GO

/* A reusable numeric conversion pattern for imported CSV values. */

/* 01 — Product-level profit margin */
WITH CleanFacts AS
(
    SELECT
        Dimension_Product_Name AS Product_Name,
        TRY_CONVERT(decimal(19, 4), Sales) AS Sales_Value,
        TRY_CONVERT(decimal(19, 4), Profit) AS Profit_Value
    FROM dbo.vw_Superstore_Star
)
SELECT
    Product_Name,
    CAST(SUM(Profit_Value) AS decimal(19, 2)) AS Total_Profit,
    CAST(SUM(Sales_Value) AS decimal(19, 2)) AS Total_Sales,
    CAST(100.0 * SUM(Profit_Value) / NULLIF(SUM(Sales_Value), 0) AS decimal(10, 2)) AS Profit_Margin_Percent
FROM CleanFacts
GROUP BY Product_Name
ORDER BY Profit_Margin_Percent DESC, Total_Profit DESC;
GO

/* 02 — Sales and profit by product category */
WITH CleanFacts AS
(
    SELECT
        Dimension_Category AS Category,
        TRY_CONVERT(decimal(19, 4), Sales) AS Sales_Value,
        TRY_CONVERT(decimal(19, 4), Profit) AS Profit_Value
    FROM dbo.vw_Superstore_Star
)
SELECT
    Category,
    CAST(SUM(Sales_Value) AS decimal(19, 2)) AS Total_Sales,
    CAST(SUM(Profit_Value) AS decimal(19, 2)) AS Total_Profit,
    CAST(100.0 * SUM(Profit_Value) / NULLIF(SUM(Sales_Value), 0) AS decimal(10, 2)) AS Profit_Margin_Percent
FROM CleanFacts
GROUP BY Category
ORDER BY Total_Sales DESC;
GO

/* 03 — Annual sales */
WITH CleanFacts AS
(
    SELECT
        Order_Year,
        TRY_CONVERT(decimal(19, 4), Sales) AS Sales_Value
    FROM dbo.vw_Superstore_Star
)
SELECT
    Order_Year AS [Year],
    CAST(SUM(Sales_Value) AS decimal(19, 2)) AS Total_Sales
FROM CleanFacts
GROUP BY Order_Year
ORDER BY Total_Sales DESC;
GO

/* 04 — Sales by city; no city-only dimension join is used. */
WITH CleanFacts AS
(
    SELECT
        [City],
        TRY_CONVERT(decimal(19, 4), Sales) AS Sales_Value
    FROM dbo.vw_Superstore_Star
)
SELECT
    [City],
    CAST(SUM(Sales_Value) AS decimal(19, 2)) AS Total_Sales
FROM CleanFacts
GROUP BY [City]
ORDER BY Total_Sales DESC, [City];
GO

/* 05 — Average transaction-line sales by customer segment */
WITH CleanFacts AS
(
    SELECT
        Dimension_Segment AS Segment,
        TRY_CONVERT(decimal(19, 4), Sales) AS Sales_Value
    FROM dbo.vw_Superstore_Star
)
SELECT
    Segment,
    CAST(AVG(Sales_Value) AS decimal(19, 2)) AS Avg_Line_Sales,
    COUNT(*) AS Transaction_Line_Count
FROM CleanFacts
GROUP BY Segment
ORDER BY Avg_Line_Sales DESC;
GO

/* 06 — Highest-spending customer */
WITH CleanFacts AS
(
    SELECT
        Customer_ID,
        Dimension_Customer_Name AS Customer_Name,
        TRY_CONVERT(decimal(19, 4), Sales) AS Sales_Value
    FROM dbo.vw_Superstore_Star
)
SELECT TOP (1) WITH TIES
    Customer_ID,
    Customer_Name,
    CAST(SUM(Sales_Value) AS decimal(19, 2)) AS Total_Sales
FROM CleanFacts
GROUP BY Customer_ID, Customer_Name
ORDER BY Total_Sales DESC;
GO

/* 07 — Highest-spending customers in Los Angeles */
WITH CleanFacts AS
(
    SELECT
        Customer_ID,
        Dimension_Customer_Name AS Customer_Name,
        [City],
        TRY_CONVERT(decimal(19, 4), Sales) AS Sales_Value
    FROM dbo.vw_Superstore_Star
)
SELECT TOP (10) WITH TIES
    Customer_ID,
    Customer_Name,
    [City],
    CAST(SUM(Sales_Value) AS decimal(19, 2)) AS Total_Sales
FROM CleanFacts
WHERE [City] = N'Los Angeles'
GROUP BY Customer_ID, Customer_Name, [City]
ORDER BY Total_Sales DESC;
GO

/* 08 — Five most profitable products */
WITH CleanFacts AS
(
    SELECT
        Product_ID,
        Dimension_Product_Name AS Product_Name,
        TRY_CONVERT(decimal(19, 4), Profit) AS Profit_Value
    FROM dbo.vw_Superstore_Star
)
SELECT TOP (5) WITH TIES
    Product_ID,
    Product_Name,
    CAST(SUM(Profit_Value) AS decimal(19, 2)) AS Total_Profit
FROM CleanFacts
GROUP BY Product_ID, Product_Name
ORDER BY Total_Profit DESC;
GO

/* 09 — Top three customers in Texas */
WITH CleanFacts AS
(
    SELECT
        Customer_ID,
        Dimension_Customer_Name AS Customer_Name,
        [State],
        TRY_CONVERT(decimal(19, 4), Sales) AS Sales_Value
    FROM dbo.vw_Superstore_Star
)
SELECT TOP (3) WITH TIES
    Customer_ID,
    Customer_Name,
    [State],
    CAST(SUM(Sales_Value) AS decimal(19, 2)) AS Total_Sales
FROM CleanFacts
WHERE [State] = N'Texas'
GROUP BY Customer_ID, Customer_Name, [State]
ORDER BY Total_Sales DESC;
GO

/* 10 — Five products with the highest cumulative sales */
WITH CleanFacts AS
(
    SELECT
        Product_ID,
        Dimension_Product_Name AS Product_Name,
        TRY_CONVERT(decimal(19, 4), Sales) AS Sales_Value
    FROM dbo.vw_Superstore_Star
)
SELECT TOP (5) WITH TIES
    Product_ID,
    Product_Name,
    CAST(SUM(Sales_Value) AS decimal(19, 2)) AS Total_Sales
FROM CleanFacts
GROUP BY Product_ID, Product_Name
ORDER BY Total_Sales DESC;
GO

/* 11 — Three products with the lowest cumulative sales */
WITH CleanFacts AS
(
    SELECT
        Product_ID,
        Dimension_Product_Name AS Product_Name,
        TRY_CONVERT(decimal(19, 4), Sales) AS Sales_Value
    FROM dbo.vw_Superstore_Star
)
SELECT TOP (3) WITH TIES
    Product_ID,
    Product_Name,
    CAST(SUM(Sales_Value) AS decimal(19, 2)) AS Total_Sales
FROM CleanFacts
GROUP BY Product_ID, Product_Name
ORDER BY Total_Sales ASC;
GO
