# Reproducibility guide

## Requirements

Use Microsoft SQL Server 2016 SP1 or newer and a SQL client such as SQL Server Management Studio. You also need a Superstore CSV that you are authorized to use. This repository deliberately does not include a CSV because the original report did not attach a redistributable raw-data file.

The CSV must contain the columns listed in [`data/README.md`](../data/README.md). Use an ISO date format such as `YYYY-MM-DD` if you prepare or normalize the file before import.

## Import the raw table

1. Open SQL Server Management Studio and connect to your server.
2. Run [`sql/00_create_database.sql`](../sql/00_create_database.sql). This creates `SuperstoreDB` if it does not already exist.
3. In Object Explorer, right-click `SuperstoreDB`, select **Tasks**, and select **Import Flat File**.
4. Choose the authorized CSV and use `Superstore` as the destination table name, creating `dbo.Superstore`.
5. Inspect inferred types before import. `Order_Date` and `Ship_Date` should be date-compatible; `Sales`, `Quantity`, `Discount`, and `Profit` must be numeric-compatible. Preserve `Postal_Code` as text where possible.
6. Finish the import and verify `SELECT TOP (10) * FROM dbo.Superstore;` returns the expected fields.

## Build the model

Run [`sql/01_build_dimensions.sql`](../sql/01_build_dimensions.sql) in `SuperstoreDB`.

The script performs four checks before it writes derived tables:

- Confirms that the raw table exists and exposes every expected source column.
- Rejects invalid or null order dates.
- Rejects a `Product_ID` with conflicting product descriptions or categories.
- Rejects a `Customer_ID` with conflicting customer names or segments.

When validation succeeds, it creates `DimDate`, `DimProduct`, `DimCustomer`, and `DimLocation`, then creates `dbo.vw_Superstore_Star`. The final result set lists row counts for the raw table and all four dimensions.

The script is intentionally rerunnable. It replaces only the derived dimensions and reporting view; it does not alter or delete the imported `dbo.Superstore` table.

## Validate before analysis

Run [`sql/03_data_quality_checks.sql`](../sql/03_data_quality_checks.sql). Review every result set, especially these gates:

- The duplicate `Row_ID` query should return no rows.
- The invalid-date query should return no rows.
- Invalid numeric measure counts should be zero unless you have a documented reason to exclude or remediate those records.
- All unmatched dimension counts in the reporting-view test should be zero.
- `Raw_Fact_Rows` must equal `Reporting_View_Rows`. A positive difference means an incorrect join is multiplying transaction rows.
- `Raw_Total_Sales` and `View_Total_Sales` must agree.

The diagnostic list of cities with multiple location records is expected to contain rows in many retail datasets. It is a warning against joining geography using `City` alone, not an error in the data.

## Run analytics

Run [`sql/02_analytics.sql`](../sql/02_analytics.sql). It returns eleven ordered result sets:

1. Product-level total sales, total profit, and profit margin.
2. Sales, profit, and margin by category.
3. Annual total sales.
4. City total sales.
5. Average transaction-line sales by customer segment.
6. Highest-spending customer, including ties.
7. Top customers in Los Angeles.
8. Five most profitable products, including ties.
9. Top three customers in Texas, including ties.
10. Five products with the highest cumulative sales, including ties.
11. Three products with the lowest cumulative sales, including ties.

## Compare with the source report carefully

The original report and its screenshots are retained in this repository as provenance. See [`analysis-guide.md`](analysis-guide.md) and [`source-material/`](source-material/). Some original queries join location data by city or state alone. The report itself identifies this as a risk, and the implementation here intentionally uses a composite geography match instead.

Because the source dataset is not committed, a newly imported CSV may not reproduce every captured screenshot exactly. Differences can arise from the input file, field types, source cleanup, or the safer aggregation logic. Treat a clean quality-check run as the prerequisite for interpreting any new output.
