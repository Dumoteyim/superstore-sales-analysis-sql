# Data dictionary

The project expects an imported SQL Server table named `dbo.Superstore`. The raw file remains the factual transaction layer; the four dimensions are reproducible derived structures built by [`sql/01_build_dimensions.sql`](../sql/01_build_dimensions.sql).

## Transaction identifiers and dates

- `Row_ID` identifies a source row. It should be unique; the quality-check script tests this assumption.
- `Order_ID` identifies an order. More than one transaction line can belong to one order.
- `Order_Date` is the date used for the analysis calendar. It must be convertible to SQL Server `date`.
- `Ship_Date` is the fulfilment date. The build script does not use it to create the source report’s dimensions, but it is validated as a date when supplied.
- `Ship_Mode` describes the shipment service level.

## Customer attributes

- `Customer_ID` is the business key for a customer. The model requires it to map consistently to one customer name and segment.
- `Customer_Name` is the customer’s descriptive name.
- `Segment` classifies the customer, for example Consumer, Corporate, or Home Office.

`DimCustomer` contains one record for each valid `Customer_ID` and is keyed by that field.

## Geographic attributes

- `Country` identifies the country associated with the transaction.
- `City` identifies the city associated with the transaction.
- `State` identifies the state or province associated with the transaction.
- `Postal_Code` identifies the postal or ZIP code. It is handled as text in `DimLocation` so leading zeroes remain intact.
- `Region` identifies the source dataset’s regional grouping.

`DimLocation` has a surrogate `LocationKey` and a unique natural key built from **Country + City + State + Postal_Code + Region**. This full combination is necessary because a city or state value alone is not globally unique and can create duplicate matches.

## Product attributes

- `Product_ID` is the business key for a product.
- `Product_Name` is the product description.
- `Category` is the top-level product grouping.
- `Sub_Category` is the more specific product grouping.

`DimProduct` contains one record per `Product_ID`. The model-build script stops if a product key maps to conflicting descriptive attributes.

## Numeric measures

- `Sales` is the sales value recorded on the transaction line. The project uses the unambiguous label `Total_Sales` when it sums this field.
- `Quantity` is the number of units on the transaction line.
- `Discount` is the discount rate on the transaction line. The quality checks flag values outside the expected 0–1 range.
- `Profit` is the profit value recorded on the transaction line.

The analytical script uses `TRY_CONVERT(decimal(19,4), ...)` for `Sales` and `Profit`, so a malformed imported value becomes visible as `NULL` instead of silently causing an incorrect implicit conversion.

## Derived calendar fields

`DimDate` is derived from the distinct valid `Order_Date` values.

- `DateKey` is the date-level key.
- `Year` is the calendar year.
- `Month_Number` and `Day_Number` are numeric calendar parts.
- `Month_Name` and `Day_Name` are descriptive calendar labels.
- `Month_Short` and `Day_Short` are three-character display labels.

## Reporting view

`dbo.vw_Superstore_Star` is the project’s analytical layer. It preserves the raw fact columns and exposes the following aliases from the dimensions:

- `DateKey`, `Order_Year`, `Order_Month_Number`, `Order_Month_Name`, and `Order_Day_Name` from `DimDate`.
- `Dimension_Product_Name`, `Dimension_Category`, and `Dimension_Sub_Category` from `DimProduct`.
- `Dimension_Customer_Name` and `Dimension_Segment` from `DimCustomer`.
- `LocationKey` from `DimLocation`.

Analytical queries should use this view rather than reproduce ad hoc joins to the dimensions.
