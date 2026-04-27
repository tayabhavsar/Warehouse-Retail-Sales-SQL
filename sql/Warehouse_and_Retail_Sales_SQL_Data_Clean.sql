---Data Verification ---

--Verify count of rows ---
SELECT COUNT(*)
FROM warehouse_and_retail_sales; 
--Total: 307,645 rows--

SELECT *
FROM warehouse_and_retail_sales;

--1. Check NULL values--
SELECT *
FROM warehouse_and_retail_sales
WHERE year IS NULL
OR month IS NULL
OR supplier IS NULL
OR item_code IS NULL
OR item_description IS NULL
OR item_type IS NULL
OR retail_sales IS NULL
OR retail_transfers IS NULL
OR warehouse_sales IS NULL;

---Supplier column has NUll values--

--2. Verify item type--
SELECT DISTINCT item_type,
COUNT(item_type)
FROM warehouse_and_retail_sales
GROUP BY item_type
ORDER BY item_type; 

-- There are 0 null values in the item type column; there are different types (BEER, WINE, LIQUOR, NON-ALCOHOLIC ETC)--


--3. Find negative sale values--
SELECT *
FROM warehouse_and_retail_sales
WHERE retail_sales < 0 
OR retail_transfers < 0 
OR warehouse_sales < 0; 

---There are negative sale values in the data-- 


---4. Find duplicate rows---
SELECT  year, month, supplier, item_code, COUNT(*) as cnt
FROM warehouse_and_retail_sales
GROUP BY year, month, supplier, item_code
HAVING COUNT(*) > 1;

--- There are 0 duplicate rows --- 

---5. Find any dead rows--
SELECT COUNT(*) as dead_rows 
FROM warehouse_and_retail_sales
WHERE retail_sales = 0
AND retail_transfers = 0
AND warehouse_sales = 0;

---Total dead rows: 1,129 rows ---

--Results: 
--1. Supplier is the only known column with NULL values 
--2. There are 5 distinct item_type names 
--3. There are negative sales values in the following columns: retail_sales, retail_transfers, and warehouse_sales
--4. There are 0 duplicate rows in the data
--5. The total dead rows in the data are 1,129 rows out of 307,646 rows of data which makes up 0.37% of the data 

---Clean Up Data---

--Checklist: 
--1. Remove dead rows
--2. Quantify NULL suppliers 
--If small <- delete
--If big <- flag as 'Unknown'

--1. Remove dead rows--
DELETE FROM warehouse_and_retail_sales
WHERE retail_sales = 0 
OR retail_transfers = 0
OR warehouse_sales = 0;

-- Verify deletion of dead rows -- 
SELECT COUNT(*) as dead_rows 
FROM warehouse_and_retail_sales
WHERE retail_sales = 0
AND retail_transfers = 0
AND warehouse_sales = 0;

-- Delete updated -- 


--2. Quantify NULL Suppliers 
SELECT COUNT(*) AS null_suppliers
FROM warehouse_and_retail_sales
WHERE supplier IS NULL;

-- there are 0 -- 

SELECT COUNT(*)
FROM warehouse_and_retail_sales; 

-- Total rows: 75,287 ---
---Deleted too many rows---
--Why? used the OR function instead of AND 

--Fixing the deletion--

--Drop Table
DROP TABLE warehouse_and_retail_sales; 

--Create Table-- 
CREATE TABLE Warehouse_and_Retail_Sales (
YEAR  		INT,
MONTH 		INT,
SUPPLIER 	TEXT,
ITEM_CODE 	TEXT, 
ITEM_DESCRIPTION   TEXT, 
ITEM_TYPE 		   TEXT, 
RETAIL_SALES       NUMERIC, 
RETAIL_TRANSFERS   NUMERIC, 
WAREHOUSE_SALES    NUMERIC
);

COPY warehouse_and_retail_sales
FROM 'C:\Users\tayab\Documents\Data Projects\Datasets\Kaggle Datasets\Warehouse_and_Retail_Sales.csv'
DELIMITER ','
CSV HEADER;

--Verify count of rows--
SELECT COUNT(*)
FROM warehouse_and_retail_sales;

--Back to having 307,645 rows of data--

--Deleting the dead rows with correct query--
DELETE FROM warehouse_and_retail_sales
WHERE retail_sales = 0
AND retail_transfers = 0
AND warehouse_sales = 0;

--Verify deleting dead rows --
SELECT COUNT(*) FROM warehouse_and_retail_sales;

--The data now has 306,516 rows--
--Deleted 1,129 dead rows of data--

--Re-quantify NULL suppliers--
SELECT COUNT(*) AS null_suppliers
FROM warehouse_and_retail_sales
WHERE supplier IS NULL;

--There are 167 NULL suppliers--

--If NULL suppliers > 0, flag rather than delete--
UPDATE warehouse_and_retail_sales 
SET supplier = 'Unknown'
WHERE supplier IS NULL;

--Check if the update worked--

SELECT COUNT(*) AS null_suppliers
FROM warehouse_and_retail_sales
WHERE supplier IS NULL;

SELECT COUNT(*) AS null_suppliers
FROM warehouse_and_retail_sales
WHERE supplier = 'Unknown';

--Update worked-- 
-- Result: 0 rows still NULL (update confirmed)
-- Result: 167 rows now show supplier = 'Unknown' (matches original NULL count)


