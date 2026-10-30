Title: SUPERSTORE SALES ANALYSIS

URL Source: http://medium.com/@dumoaby/superstore-sales-analysis-52dbe6710270

Final URL: https://medium.com/@dumoaby/superstore-sales-analysis-52dbe6710270

Published Time: 2026-10-30T15:46:45Z

Markdown Content:
[![Image 1: Dumoteyim Abiye-Suku](https://miro.medium.com/v2/resize:fill:64:64/1*dmbNkD5D-u45r44go_cf0g.png)](https://medium.com/@dumoaby?source=post_page---byline--52dbe6710270-----------------------------------------)

15 min read

Just now

## Executive Report on Database Development, Data Exploration, Data Modelling and SQL Analytics

## Executive Summary

This project involved developing a Superstore sales database in Microsoft SQL Server and using Structured Query Language (SQL) to explore the dataset, organise the data into dimension tables, establish relationships between tables, and conduct business-focused sales and profitability analyses.

The project began with the creation of a database and the importation of a CSV file using SQL Server’s Import Flat File functionality. Following the import, the dataset was explored using SQL queries to understand its structure, identify relevant attributes, and establish a foundation for further analysis.

To improve the organisation of the data and support analytical queries, four dimension tables were created: `DimDate`, `DimProduct`, `DimCustomer`, and `DimLocation`. These tables were connected to the central `Superstore` table, creating a dimensional data model that supports analysis across time, products, customers, and geographical locations.

Several SQL queries were subsequently developed to investigate sales performance, profitability, customer purchasing behaviour, product performance, and geographical sales distribution. The analyses included sales and profit by product category, annual sales, sales by city, average sales by customer segment, identification of high-spending customers, and rankings of the most profitable and highest- and lowest-sales products.

Overall, the project demonstrates the application of SQL for database development, data preparation, data modelling, and business intelligence. The resulting model provides a foundation for extracting insights from transactional data and supporting evidence-based business decisions.

## Project Objectives

The primary objective was to transform raw Superstore sales data into a structured database that could support systematic business analysis.

The specific objectives were to:

*   Create a database in Microsoft SQL Server and import the Superstore CSV dataset
*   Explore the imported data and understand its structure and attributes.
*   Create dimension tables to organise customer, product, location, and date information.
*   Establish relationships between the central sales table and the dimension tables.
*   Develop SQL queries to analyse sales, profit, customer purchasing behaviour, and product performance.
*   Identify opportunities to improve data quality, analytical accuracy, and the usefulness of the resulting insights.

## Database Creation and Data Importation

The first stage involved creating a database named `SuperstoreDB` in Microsoft SQL Server. This provided a dedicated environment in which the data could be stored, queried, and analysed.

CREATE DATABASE SuperstoreDB;
The source data was supplied in CSV format and imported using SQL Server’s Import Flat File functionality. This process enabled the tabular data to be loaded into SQL Server, where the columns could be accessed and manipulated using SQL statements.

Following the import, the main transactional table was referenced as `dbo.Superstore`. It contained information relating to orders, shipping, customers, geographical locations, products, sales, quantities, discounts, and profits.

These attributes provided the foundation for the subsequent analysis. In particular, `Sales` and `Profit` supported financial analysis, while customer, product, date, and location fields enabled comparisons across different business dimensions.

## Data Exploration

After importing the CSV file, initial data exploration was conducted using SQL queries.

A statement such as `SELECT * FROM dbo.Superstore` was used to retrieve the records and examine the available columns. Additional queries selected specific fields, including order identifiers, customer names, customer segments, sales, and profit.

Press enter or click to view image in full size

![Image 2](https://miro.medium.com/v2/resize:fit:700/1*Ux8ERn1rYAtfdkm6wYEg9Q.png)

Data Exploration

This process helped establish an understanding of the dataset and identify the fields required for analysis and data modelling.

The exploration stage was important for three reasons. First, it provided an overview of the available information. Second, it helped identify the attributes that could be used to categorise transactions. Third, it established the basis for creating dimension tables and writing queries that would answer specific business questions.

The dataset included both descriptive attributes and numerical measures. Descriptive attributes, such as product category and customer segment, provide context for interpreting transactions. Numerical measures, such as sales and profit, can be aggregated to evaluate business performance.

Separating these roles in the analysis made it possible to examine the data from several perspectives rather than relying solely on the original transaction table.

## Data Modelling and Dimension Table Creation

Following the initial exploration, the data was organised into a dimensional model. This approach separates descriptive information into dimension tables while retaining the transactional records in the central `Superstore` table.

Press enter or click to view image in full size

![Image 3](https://miro.medium.com/v2/resize:fit:700/1*lrusslqGRbUi306oK5WSdg.png)

Data Modelling

The model included four dimension tables.

**DimDate**

The `DimDate` table was created to support time-based analysis. It included `Order_Date`, `Year`, `Month_Number`, `Day_Number`, `Month_Name`, `Day_Name`, `Month_Short`, and `Day_Short`.

SELECT DISTINCT
Order_Date,
YEAR(Order_Date) AS Year,
MONTH(Order_Date) AS Month_Number,
DAY(Order_Date) AS Day_Number,
DATENAME(MONTH, Order_Date) AS Month_Name,
DATENAME(WEEKDAY, Order_Date) AS Day_Name,
LEFT(DATENAME(MONTH, Order_Date),3) AS Month_Short,
LEFT(DATENAME(WEEKDAY, Order_Date),3) AS Day_Short
INTO DimDate
FROM [dbo].[Superstore];
SQL date functions, including `YEAR()`, `MONTH()`, `DAY()`, and `DATENAME()`, were used to derive calendar attributes from the order date. The `LEFT()` function was also used to generate shortened date labels.

Press enter or click to view image in full size

![Image 4](https://miro.medium.com/v2/resize:fit:700/1*8yWZyv1MOnG3VDrEFpEk0w.png)

DimDate

This table enables transactions to be grouped by year, month, or other calendar attributes. It supports comparisons of sales over time and provides a foundation for identifying seasonal patterns and changes in business performance.

**DimProduct**

The `DimProduct` table contained `Product_ID`, `Product_Name`, `Category`, and `Sub_Category`.

SELECT DISTINCT
Product_ID, Product_Name, Category, Sub_Category
INTO DimProduct
FROM [dbo].[Superstore];
Its purpose was to organise product information and support analysis at different levels of product classification. For example, sales and profit could be compared across categories, sub-categories, and individual products.

Press enter or click to view image in full size

![Image 5](https://miro.medium.com/v2/resize:fit:700/1*sHbAxgrOmDMqbUaINx5xKw.png)

DimProduct

This structure also made it possible to identify products contributing the highest total profit or generating the highest and lowest cumulative sales.

**DimCustomer**

The `DimCustomer` table contained `Customer_ID`, `Customer_Name`, and `Segment`.

SELECT DISTINCT
Customer_ID, Customer_Name, Segment
INTO DimCustomer
FROM [dbo].[Superstore];
This table supported customer-focused analysis by connecting transactions to customer information. It enabled the calculation of total sales by customer, the identification of high-spending customers, and comparisons between customer segments.

Press enter or click to view image in full size

![Image 6](https://miro.medium.com/v2/resize:fit:700/1*bEWvAY87d0vpjrZlk-vh3w.png)

DimCustomer

Such analysis can help a business understand how purchasing value is distributed across its customer base and identify opportunities for customer retention and targeted marketing.

**DimLocation**

The `DimLocation` table contained `Country`, `City`, `State`, `Postal_Code`, and `Region`.

SELECT DISTINCT
Country, City, State, Postal_Code, Region
INTO DimLocation
FROM [dbo].[Superstore];
Its purpose was to organise geographical information and enable location-based analysis. Using these attributes, sales could be investigated across cities and other geographical areas, while customer purchasing activity could be examined within selected locations.

Press enter or click to view image in full size

![Image 7](https://miro.medium.com/v2/resize:fit:700/1*rOEAuWgHJsRe8LIbQJ6O9g.png)

DimLocation

Geographical analysis can help identify areas generating substantial sales and provide a basis for further investigation into regional performance.

**SQL techniques used to create the dimensions**

The dimension tables were created using `SELECT DISTINCT ... INTO`.

The `DISTINCT` keyword removes duplicate combinations of the selected attributes, while `INTO` creates a new table from the query results.

This approach provides a straightforward method for extracting descriptive data from the original transaction table. However, it does not automatically establish primary keys, foreign keys, or indexes. These should be added and validated where appropriate to strengthen the model.

## Establishing Relationships Between Tables

After creating the dimension tables, relationships were established between the central `Superstore` table and the four dimensions.

The relationships used in the analytical queries were based on the following attributes:

*   **Date:**`Order_Date` connected the transaction table to `DimDate`.
*   **Product:**`Product_ID` connected the transaction table to `DimProduct`.
*   **Customer:**`Customer_ID` connected the transaction table to `DimCustomer`.
*   **Location:** Geographical attributes connected the transaction table to `DimLocation`.

This arrangement resembles a star-schema analytical model, in which a central fact-like table is linked to dimensions containing descriptive information.

The central table stores the transactional measures, while the dimension tables provide the attributes used to group and filter the results.

SQL `INNER JOIN` statements were used to combine information from the related tables. This enabled queries to calculate measures such as sales and profit while grouping the results by product category, customer, date, or location.

The dimensional model improves the organisation of the analysis because it separates descriptive information into dedicated tables rather than requiring all analytical queries to work exclusively with the original transaction structure.

However, relationship accuracy is essential. In particular, joining the location table using only `City` or only `State` may match a transaction to multiple dimension records when those values are not unique. This can duplicate transaction rows and inflate calculated sales totals. Using a validated location key or an appropriate combination of geographical attributes would improve reliability.

## SQL Analytics and Business Applications

Following database preparation and data modelling, a series of SQL queries was developed to investigate different aspects of Superstore performance.

### Product Profit Margin Analysis

A query was written to calculate product profit margin as a percentage of sales using the formula:

**Profit Margin (%) = (Profit ÷ Sales) × 100**

---Calculate Profit Margin of the Product
SELECT Product_Name,
(Profit/Sales) *100 AS Profit_Margin
FROM [dbo].[Superstore];
The purpose was to examine profitability relative to sales value rather than focusing exclusively on revenue.

This distinction is important because a product generating substantial sales may not necessarily generate a proportionately high profit.

Press enter or click to view image in full size

![Image 8](https://miro.medium.com/v2/resize:fit:700/1*jKJlTaiLPC3uVHAvpBZD_Q.png)

Profit_Margin

The results could help identify products that contribute strongly to profitability and those that may require further investigation into pricing, discounts, or costs.

For reliable calculations, the SQL expression should use decimal arithmetic and protect against division by zero. Where a product-level margin is required, total profit divided by total sales is generally more meaningful than averaging individual transaction margins.

### Sales and Profit by Product Category

A query joined the `Superstore` table to `DimProduct`, grouped the transactions by product category, and calculated total sales and total profit using `SUM()`.





SELECT P.Category,
SUM(S.Sales) AS Total_Sales,
SUM(S.Profit) AS Total_Profit
FROM Superstore AS S
INNER JOIN DimProduct AS P
ON S.Product_ID = P.Product_ID
GROUP BY P.Category
ORDER BY Total_Sales DESC;

The results were ordered by total sales in descending order.

## Get Dumoteyim Abiye-Suku’s stories in your inbox

Join Medium for free to get updates from this writer.

Remember me for faster sign in

This analysis was designed to compare the financial contribution of different product categories. Examining sales and profit together provides a more balanced view of performance because a category with high revenue may not necessarily have the highest profit.

Press enter or click to view image in full size

![Image 9](https://miro.medium.com/v2/resize:fit:700/1*avDbfglElfH6Q_CmCmFOJw.png)

Sales and Profit Analysis

The findings could support decisions about product assortment, promotional strategies, pricing, and the allocation of business resources.

### Annual Sales Analysis

The annual sales query joined the transaction table to `DimDate`, grouped the records by year, and calculated total sales for each year.




SELECT D.[Year],
SUM(S.Sales) AS Total_Sales
FROM Superstore AS S
INNER JOIN DimDate AS D
ON S.Order_Date = D.Order_Date
GROUP BY D.[Year]
ORDER BY Total_Sales DESC;

The results were ordered from highest to lowest sales.

This analysis was intended to identify the strongest sales years and compare performance over the period covered by the dataset.

Press enter or click to view image in full size

![Image 10](https://miro.medium.com/v2/resize:fit:700/1*eFTu3pUbkQGSVy5-eGX7gw.png)

Annual Sales

Annual sales comparisons can provide an overview of business performance over time. However, identifying sustained growth or decline requires examining the actual values and the sequence of results rather than relying solely on a ranking.

### Sales by City

A geographical query joined the transaction table to `DimLocation`, grouped the data by city, and calculated total sales. The resulting values were rounded to two decimal places and sorted in descending order.

---Which city generate the most sales?
---DimLocation(alias L) -City
---Superstore(alias S) -Sales
SELECT L.City,
ROUND(SUM(S.Sales), 2) AS Total_Sales
FROM Superstore AS S
INNER JOIN DimLocation AS L
ON S.City = L.City
GROUP BY L.City
ORDER BY Total_Sales DESC;

The purpose was to identify cities associated with the highest recorded sales values.

This information can support geographical performance assessments and help guide further investigation into regional demand and sales distribution.

Press enter or click to view image in full size

![Image 11](https://miro.medium.com/v2/resize:fit:700/1*U_3rp1TPLQm52N6w9-X_wQ.png)

Sales Records

The results must, however, be checked for duplicated transaction rows caused by non-unique city joins before drawing conclusions.

### Average Sales by Customer Segment

The customer segment query joined the transaction table to `DimCustomer`, grouped the data by segment, and calculated average sales using `AVG()`.

---Which segment has the highest average sales? (average-AVG)
----DimCustomer (alias C)
----Superstore(alias S)
SELECT C.Segment,
ROUND(AVG(S.Sales), 2) AS Avg_Sales
FROM Superstore AS S
INNER JOIN DimCustomer AS C
ON S.Customer_ID = C.Customer_ID
GROUP BY C.Segment
ORDER BY Avg_Sales DESC;

The results were ordered by average sales in descending order.

This analysis was intended to compare the average transaction-line sales value across customer segments.

It provides an initial indication of differences in purchasing value between segments. However, average transaction sales should not be interpreted as average customer spending or customer lifetime value. Those measures require grouping transactions at the appropriate customer or order level.

Press enter or click to view image in full size

![Image 12](https://miro.medium.com/v2/resize:fit:700/1*WzSvB1IpecxcgmUDjMAhfA.png)

Average Sales

Additional metrics, including total sales, order count, customer count, and sales per customer, would provide a more complete understanding of segment performance.

### Identification of the Highest-Spending Customer

A query grouped transaction records by customer identifier and customer name, calculated total sales for each customer, and returned the top-ranked customer using `TOP 1`.

---Find the customer with the highest purchase?
---DimCustomer(alias C) -Customer_ID, Customer_Name
---Superstore(alias S) -Sales
SELECT TOP 1 C.Customer_ID, C.Customer_Name,
SUM(S.Sales) AS Total_Sales
FROM Superstore AS S
INNER JOIN DimCustomer AS C
ON S.Customer_ID = C.Customer_ID
GROUP BY C.Customer_ID, C.Customer_Name
ORDER BY Total_Sales DESC;

The purpose was to identify the customer associated with the highest cumulative sales value in the dataset.

This analysis can help highlight customers who account for a substantial share of recorded sales. Such information may support customer relationship management and retention strategies.

Press enter or click to view image in full size

![Image 13](https://miro.medium.com/v2/resize:fit:700/1*FL7pXzvhZ888hvcnbjgetg.png)

Highest Customer

However, total historical sales alone do not establish profitability or future customer value. Those questions would require additional measures.

### Highest-Spending Customer in Los Angeles

A location-specific query filtered the data to Los Angeles, grouped the results by customer and city, and ranked customers according to total purchase value.

---Find Los Angeles customers and display the highest purchaser
---Superstore(alias S) -Sales, Customer_Name
---Location(alias L) -City
SELECT S.Customer_Name, L.City,
SUM(S.Sales) AS Total_Purchase
FROM Superstore AS S
JOIN DimLocation AS L
ON S.City = L.City
WHERE L.City =
GROUP BY S.Customer_Name, L.City
ORDER BY Total_Purchase DESC;

This analysis was designed to examine customer purchasing activity within a specific geographical area.

It demonstrates how SQL filters can be combined with joins and aggregation to investigate a more focused business question.

Press enter or click to view image in full size

![Image 14](https://miro.medium.com/v2/resize:fit:700/1*FUspz_YZLf1PxglZXn4llg.png)

Los Angeles Analysis

The results could support local marketing analysis or identify customers with substantial recorded purchases in the selected city. The accuracy of the output depends on the geographical join correctly identifying the relevant transactions.

### Five Most Profitable Products

A product profitability query calculated total profit by product identifier and product name, then returned the five highest-ranked products.

The query used `SUM()` to aggregate profit and `TOP 5` with descending ordering to identify the leading products.

---Show 5 most profitable product(High Profit)
----Superstore(alias S)
----DimProduct(alias P)
SELECT TOP 5 P.Product_ID, P.Product_Name,
SUM(S.Profit) AS Total_Profit
FROM Superstore AS S
JOIN DimProduct AS P
ON S.Product_ID = P.Product_ID
GROUP BY P.Product_ID, P.Product_Name
ORDER BY Total_Profit DESC;

This analysis focuses on profit contribution rather than sales volume alone. It can help distinguish products that contribute strongly to the business’s financial performance from products that generate revenue but relatively little profit.

Press enter or click to view image in full size

![Image 15](https://miro.medium.com/v2/resize:fit:700/1*c47fHnTtUZxQQF5MjWlshA.png)

Most Profitable Products

The resulting rankings could inform decisions about product promotion, assortment planning, and profitability reviews.

### Top Three Customers in Texas

A customer query filtered transactions to Texas, aggregated sales by customer, and returned the three highest-ranked customers.

--Find Texas customers and display the top 3 highest purchasers
---Superstore(alias S) -Sales, Customer_Name
----Location (alias L) -State
SELECT TOP 3 S.Customer_Name, L.State,
SUM(S.Sales) AS Total_Purchase
FROM Superstore AS S
JOIN DimLocation AS L
ON S.State =L.State
WHERE L.State =
GROUP BY S.Customer_Name, L.State
ORDER BY Total_Purchase DESC

The purpose was to identify customers with the greatest recorded sales value within the selected state.

This provides a practical example of combining geographical filtering with customer-level aggregation.

Press enter or click to view image in full size

![Image 16](https://miro.medium.com/v2/resize:fit:700/1*alfZQcTBorKsw_-ohXlEgQ.png)

Texas Analysis

The results could help focus customer engagement efforts within the state. However, the interpretation should remain limited to recorded sales during the period represented by the dataset.

### Five Products with the Highest Total Sales

A query grouped transactions by product identifier, summed sales for each product, and returned the five highest totals.

---Find the TOP 5 highest priced products
---Superstore(alias S) -Sales
----DimProduct(alias P)
SELECT TOP 5 P.Product_ID,
SUM(S.Sales) AS Price
FROM Superstore AS S
JOIN DimProduct AS P
ON S.Product_ID = P.Product_ID
GROUP BY P.Product_ID
ORDER BY Price DESC;

Although the query labels the measure as price, the calculation represents **total sales value accumulated across transactions**, not the unit or list price of a product.

This distinction matters because products with high cumulative sales may perform well due to sales volume, selling price, or a combination of both.

Press enter or click to view image in full size

![Image 17](https://miro.medium.com/v2/resize:fit:700/1*niWaCjZYVkMTY4F6Quk00Q.png)

Top5 Products

The analysis can help identify products that contribute substantially to total recorded revenue and provide a basis for further investigation into demand and inventory planning.

### Three Products with the Lowest Total Sales

A complementary query returned the three products with the lowest cumulative sales values.

--Find the Least 3 Cheapest products
---Superstore(alias S) -Sales
---DimProduct(alias P) -Product
SELECT TOP 3 P.Product_ID,P.Product_Name,
SUM(S.Sales) AS Price
FROM Superstore AS S
JOIN DimProduct AS P
ON S.Product_ID =P.Product_ID
GROUP BY P.Product_ID,P.Product_Name
ORDER BY Price ASC;

This analysis was intended to identify products that generated relatively little recorded sales value during the period covered by the dataset.

The findings could support further investigation into product demand, stock management, marketing effectiveness, and assortment decisions.

Press enter or click to view image in full size

![Image 18](https://miro.medium.com/v2/resize:fit:700/1*J-ubFb-APYZKNijnpiNZ4A.png)

Top3 Lowest Products

Low cumulative sales alone do not prove that a product is unprofitable or underperforming. Product availability, the length of time a product has been sold, profit margins, and inventory levels should also be considered.

## Overall Business Value and Interpretation

The SQL analyses collectively provide a framework for understanding Superstore performance across several dimensions.

First, combining sales and profit analysis provides a more balanced assessment of financial performance. Revenue indicates the value of sales, while profit helps evaluate the financial contribution associated with those sales.

Second, customer rankings and segment comparisons can help reveal how purchasing activity is distributed across the customer base. This information can support customer engagement and retention initiatives.

Third, geographical analysis enables the investigation of differences between cities and states. Such analysis can inform further research into regional demand and sales opportunities.

Finally, product rankings provide an initial view of sales concentration and profitability. They can help prioritise products for additional investigation, although inventory and pricing decisions should not be based on sales rankings alone.

The dimensional model supports these analyses by providing a consistent structure for combining transactional measures with descriptive attributes.

**The principal limitation is that the supplied SQL script defines the analyses but does not provide the returned results.** Specific claims about the best-performing category, most profitable product, highest-spending customer, or strongest sales year must therefore be confirmed by executing the queries and examining their outputs.

## Data Quality Considerations and Recommendations

Although the project demonstrates a structured analytical workflow, several improvements would strengthen the accuracy and reliability of the results.

**First, review the**`DimDate`**table lifecycle.** The supplied script includes a statement that drops `dbo.DimDate`. If the script is executed sequentially, subsequent queries that depend on that table may fail unless it is recreated. The table should remain available throughout the analytical workflow, and cleanup statements should be separated from the main analysis.

**Second, validate the geographical joins.** Joining on city or state alone may produce multiple matches and inflate aggregate values. A unique location key or a validated combination of location attributes should be used to ensure that each transaction matches the correct location record.

**Third, improve the profit margin calculation.** The calculation should use decimal arithmetic and handle zero sales values safely. Product-level margin should generally be calculated as total profit divided by total sales for the product, multiplied by 100.

**Fourth, distinguish sales value from product price.** Queries that sum `Sales` should use labels such as `Total_Sales` rather than `Price`. This ensures that the output is interpreted correctly.

**Fifth, define and validate dimension keys.** The dimension tables should have appropriate primary keys, and relationships should be checked for uniqueness and referential integrity. This would improve the robustness of the model and help prevent incorrect joins.

**Sixth, expand the analytical measures.** Customer analysis could include order counts, customer counts, and sales per customer. Product analysis could compare sales, profit, and profit margin. These additional measures would provide more context for business decisions.

**Finally, validate the results.** Important aggregate totals should be compared with the source data, and checks should be performed for missing values, duplicate records, unexpected numerical values, and unmatched dimension records.

## Conclusion

This project demonstrates the use of Microsoft SQL Server to develop a database, import and explore a CSV dataset, create dimension tables, establish analytical relationships, and perform SQL-based business analysis.

The creation of `DimDate`, `DimProduct`, `DimCustomer`, and `DimLocation` provides a more organised structure for analysing transactions by time, product, customer, and geography. The subsequent SQL queries investigate sales, profit, customer purchasing behaviour, and product performance, illustrating how transactional data can be transformed into information relevant to business decision-making.

The project therefore provides a practical foundation for database management, dimensional modelling, and business intelligence using SQL.

To strengthen the final analytical conclusions, the next step is to execute the queries, capture the actual results, validate the calculations and joins, and incorporate the resulting figures into the report. This would allow the analysis to move beyond describing the methods used and provide quantified findings that directly support business recommendations.
