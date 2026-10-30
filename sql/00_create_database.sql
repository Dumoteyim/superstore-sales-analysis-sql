/*
  Superstore Sales Analysis — database bootstrap
  Target: Microsoft SQL Server 2016 SP1+ / Azure SQL compatible T-SQL

  This script creates the project database only. Import the source CSV into
  dbo.Superstore before running 01_build_dimensions.sql.
*/

USE master;
GO

IF DB_ID(N'SuperstoreDB') IS NULL
BEGIN
    CREATE DATABASE SuperstoreDB;
END;
GO

USE SuperstoreDB;
GO

/*
  CSV import guidance
  -------------------
  1. In SSMS, right-click SuperstoreDB > Tasks > Import Flat File.
  2. Select the Superstore CSV and retain the destination name dbo.Superstore.
  3. Verify that Order_Date and Ship_Date import as date or as ISO-compatible
     text; verify Sales, Quantity, Discount, and Profit as numeric values.
  4. Run sql/01_build_dimensions.sql.

  The raw CSV is intentionally not bundled in this repository. See data/README.md
  for the expected columns and provenance notes.
*/

SELECT
    DB_NAME() AS Current_Database,
    N'Import the CSV to dbo.Superstore, then run 01_build_dimensions.sql.' AS Next_Step;
GO
