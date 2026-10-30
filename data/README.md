# Data folder

The source CSV is **not included** in this public repository. The Medium report documents the analytical workflow and shows a 9,994-row Superstore table in its source screenshot, but it does not provide a redistribution link or an attached dataset. Keeping the raw file out of the repository avoids publishing a dataset whose license and provenance have not been confirmed here.

To reproduce the analysis, obtain a Superstore CSV that you are permitted to use and import it into SQL Server as `dbo.Superstore`. The project expects these columns:

```text
Row_ID, Order_ID, Order_Date, Ship_Date, Ship_Mode,
Customer_ID, Customer_Name, Segment,
Country, City, State, Postal_Code, Region,
Product_ID, Category, Sub_Category, Product_Name,
Sales, Quantity, Discount, Profit
```

Use a stable date format such as `YYYY-MM-DD`. Preserve postal codes as text whenever possible so leading zeroes are not lost. Once imported, run the SQL files in the order described in [`docs/reproducibility.md`](../docs/reproducibility.md).
