/*

Data Cleaning in SQL Queries

This SQL-based data cleaning project aimed to prepare two datasets (SalesTable and RealEstateTable) 
for analysis by addressing key issues such as inconsistent formats and missing standardization.

1. Date Standardization: Converted text-based date fields (etablertdato, register_date, sold_date, official_date) 
to SQL DATE format for consistency and replaced original columns with cleaned versions.

2. Days Difference Calculation: Added a days_diff column to compute the time difference (in days) 
between register_date and sold_date using the DATEDIFF function.

3. Address Formatting: Reformatted street_address to proper case and replaced symbols (e.g., -) with spaces for uniformity.

4. Boolean Normalization: Standardized boolean-like fields (parkering, balkong) by replacing true with Y.

5. Duplicate Identification: Checked for duplicate records in id columns to ensure data integrity.

The result is a clean, consistent dataset ready for analysis and modeling tasks.

*/

SELECT TOP 1000 *
FROM PortfolioProject.dbo.SalesTable

SELECT TOP 1000 *
FROM PortfolioProject.dbo.RealEstateTable

--------------------------------

--CHECKING SalesTable
SELECT TOP 1000 *
FROM PortfolioProject..SalesTable

--CHECKING RealEstateTable
SELECT TOP 1000 *
FROM PortfolioProject..RealEstateTable

--LOOKING AT DATA TYPES AND STRUCTURES
EXEC sp_columns 'SalesTable';
EXEC sp_columns 'RealEstateTable';

--------------------------------

--CHANGING DATE FORMAT

SELECT etablertdato, TRY_CAST(tattibrukdato as DATE), TRY_CAST(etablertdato as DATE)
FROM  PortfolioProject.dbo.RealEstateTable


SELECT register_date, TRY_CAST(register_date as DATE) as CleanDate
, sold_date, TRY_CAST(sold_date as DATE) as CleanDate
, official_date, TRY_CAST(official_date as DATE) as CleanDate
FROM PortfolioProject.dbo.SalesTable



--UPDATING THE TABLES

--Add new columns for cleaned data

ALTER TABLE PortfolioProject.dbo.RealEstateTable
ADD etablertdatoConverted DATE,
	tattibrukdatoConverted DATE;

ALTER TABLE PortfolioProject.dbo.SalesTable
ADD register_date_converted DATE,
	sold_date_converted DATE,
	official_date_converted DATE;


--Populate new columns

UPDATE PortfolioProject.dbo.RealEstateTable
SET etablertdatoConverted = TRY_CAST(etablertdato as DATE),
	tattibrukdatoConverted = TRY_CAST(tattibrukdato as DATE)


UPDATE PortfolioProject.dbo.SalesTable
SET register_date_converted = TRY_CAST(register_date as DATE),
	sold_date_converted = TRY_CAST(sold_date as DATE),
	official_date_converted = TRY_CAST(official_date as DATE)



--Replace old columns

ALTER TABLE RealEstateTable DROP COLUMN etablertdato, tattibrukdato;
EXEC sp_rename 'RealEstateTable.etablertdatoConverted', 'etablertdato', 'COLUMN';
EXEC sp_rename 'RealEstateTable.tattibrukdatoConverted', 'tattibrukdato', 'COLUMN';

ALTER TABLE SalesTable DROP COLUMN register_date, sold_date, official_date;
EXEC sp_rename 'SalesTable.register_date_converted', 'register_date', 'COLUMN';
EXEC sp_rename 'SalesTable.sold_date_converted', 'sold_date', 'COLUMN';
EXEC sp_rename 'SalesTable.official_date_converted', 'official_date', 'COLUMN';


-----------------------------


--ADDING A NEW COLUMN WITH DAYS DIFFERENCE BETWEEN register_date and sold_date

SELECT register_date, sold_date, DATEDIFF(dd, register_date, sold_date) as days_diff
FROM PortfolioProject..SalesTable
WHERE register_date IS NOT NULL AND sold_date IS NOT NULL

ALTER TABLE PortfolioProject..SalesTable
ADD days_diff int;

UPDATE PortfolioProject..SalesTable
SET days_diff = DATEDIFF(dd, register_date, sold_date)



---------------------

--CLEANING THE ADDRESS FORMAT

SELECT street_address
, REPLACE(
	CONCAT(
		UPPER(SUBSTRING(street_address, 1, 1)),
		LOWER(SUBSTRING(street_address, 2, LEN(street_address)))
	), '-', ' '
)
FROM PortfolioProject.dbo.RealEstateTable

UPDATE PortfolioProject.dbo.RealEstateTable
SET street_address = REPLACE(
	CONCAT(
		UPPER(SUBSTRING(street_address, 1, 1)),
		LOWER(SUBSTRING(street_address, 2, LEN(street_address)))
	), '-', ' '
)


-----------------------------

--CHANGE 'true' to Y in 'parkering' and 'balkong'

SELECT parkering, balkong
,CASE
	WHEN parkering = 'true' THEN 'Y'
	ELSE parkering
END
,CASE
	WHEN balkong = 'true' THEN 'Y'
	ELSE balkong
END
FROM PortfolioProject..RealEstateTable

UPDATE PortfolioProject..RealEstateTable
SET parkering = CASE
	WHEN parkering = 'true' THEN 'Y'
	ELSE parkering
END,
	balkong = CASE
	WHEN balkong = 'true' THEN 'Y'
	ELSE balkong
END


-------------------------

--CHECKING FOR DUPLICATES


SELECT id, COUNT(*) AS Antall
FROM PortfolioProject..RealEstateTable
GROUP BY id
HAVING COUNT(*) > 1;
