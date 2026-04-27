--Schema Normalization--
--Why?: the warehouse_and_retail_sales table has all the data living on one flat table
--Goal: Split the data into three related tables 

SELECT *
FROM warehouse_and_retail_sales;

--Schema 1: Suppliers
--What do we need for this table?: supplier, supplier_name
CREATE TABLE suppliers (
supplier INTEGER PRIMARY KEY,
supplier_name TEXT NOT NULL 
);

SELECT COUNT(*)
FROM suppliers;

--Schema 2: Products 
--What do we need for this table?: item_description, item_code, item_type, supplier_id 
CREATE TABLE products (
item_code TEXT PRIMARY KEY,
item_description TEXT,
item_type TEXT,
supplier_id INTEGER,
FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

---Saying Error: ERROR:  column "supplier_id" referenced in foreign key constraint does not exist 
--SQL state: 42703

--What this means: the products table is looking for supplier_id, however, the suppliers table created doesn't have that column
--Decision: Drop the table and re-create suppliers table using the supplier_id so it matches

--Drop Suppliers Table--
DROP TABLE suppliers; 

CREATE TABLE suppliers (
supplier_id INTEGER PRIMARY KEY,
supplier_name TEXT NOT NULL
);

SELECT COUNT(*)
FROM suppliers; 

--	"count"
	0
-- Verified that the query ran successfully

--Create products Schema again--
CREATE TABLE products (
item_code TEXT PRIMARY KEY,
item_description TEXT,
item_type TEXT,
supplier_id INTEGER,
FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

SELECT COUNT(*)
FROM products; 

-- "count"
	0
-- Verified that the query ran successfully 

-- Schema 3: Sales
--What do we need for this table?: year, month, item_code, retail_sales, retail_transfers, warehouse_sales
CREATE TABLE sales (
sale_id INTEGER PRIMARY KEY,
year INTEGER,
month INTEGER, 
item_code TEXT, 
retail_sales REAL,
retail_tranfers REAL, 
warehouse_sales REAL, 
FOREIGN KEY (item_code) REFERENCES products (item_code)
);

SELECT COUNT(*)
FROM sales; 

-- "count"
	0

--Check sales table--
SELECT *
FROM sales;

--What needs to be fixed: sale_id needs to be a serial instead of integer, retail_transfers is spelled wrong
--Decision: drop sales table and re-create with fixes 

--Drop sales table--
DROP TABLE sales; 

--Create sales table-- 
CREATE TABLE sales (
sale_id SERIAL PRIMARY KEY,
year INTEGER,
month INTEGER, 
item_code TEXT, 
retail_sales REAL,
retail_transfers REAL, 
warehouse_sales REAL, 
FOREIGN KEY (item_code) REFERENCES products (item_code)
);

SELECT COUNT(*)
FROM sales; 

-- "count"
	0
--Verified that query ran successfully 
-----------------------------------------------------------

--Populate suppliers table--
INSERT INTO suppliers (supplier_name)
SELECT DISTINCT supplier
FROM warehouse_and_retail_sales
ORDER BY supplier; 

-- ERROR:  null value in column "supplier_id" of relation "suppliers" violates not-null constraint
--Failing row contains (null, 8 VINI INC). 
--SQL state: 23502
--Detail: Failing row contains (null, 8 VINI INC).

--What does this mean?: the supplier_id has no default value; the system doesn't know what to put
-- What to fix?: change supplier_id to SERIAL in the suppliers table; the purpose is to auto-generate the IDs for each row and drop the products table and re-create it since it depends on the suppliers table

-- Drop products table--
DROP TABLE products;

-- ERROR:  cannot drop table products because other objects depend on it
--constraint sales_item_code_fkey on table sales depends on table products 
--SQL state: 2BP01
--Detail: constraint sales_item_code_fkey on table sales depends on table products
--Hint: Use DROP ... CASCADE to drop the dependent objects too.

--Drop tables using CASCADE
DROP TABLE sales; 
DROP TABLE products CASCADE;
 DROP TABLE suppliers;

-- all three tables are dropped 

-- RE-create tables in order 
CREATE TABLE suppliers (
    supplier_id   SERIAL PRIMARY KEY,
    supplier_name TEXT NOT NULL
);

CREATE TABLE products (
    item_code        TEXT PRIMARY KEY,
    item_description TEXT,
    item_type        TEXT,
    supplier_id      INTEGER,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

CREATE TABLE sales (
    sale_id          SERIAL PRIMARY KEY,
    year             INTEGER,
    month            INTEGER,
    item_code        TEXT,
    retail_sales     REAL,
    retail_transfers REAL,
    warehouse_sales  REAL,
    FOREIGN KEY (item_code) REFERENCES products(item_code)
);

--CREATE TABLE
--Query returned successfully in 52 msec. (x3)

-- Re-create population of suppliers table--
INSERT INTO suppliers (supplier_name)
SELECT DISTINCT supplier
FROM warehouse_and_retail_sales
ORDER BY supplier; 

-- INSERT 0 396
--Query returned successfully in 131 msec.

SELECT COUNT(*) FROM suppliers;

-- "count"
	396
	
SELECT * 
FROM suppliers LIMIT 5;

--"supplier_id"	    "supplier_name"
1	     			"8 VINI INC"
2					"A HARDY USA LTD"
3					"A I G WINE & SPIRITS"
4					"A VINTNERS SELECTIONS"
5					"A&E INC"

-------------------------------------------------------------
--After normalization, the data is split across three tables:
```
--suppliers        products         sales
-----------      -----------      -----------
--supplier_id  →   supplier_id      sale_id
--supplier_name    item_code    →   item_code
                 --item_type        warehouse_sales
```

--The supplier name is in `suppliers`. The warehouse sales numbers are in `sales`. They don't share a column directly — `products` is the bridge between them.

--So to get supplier name + warehouse sales together, you have to **JOIN all three tables:**
```
--sales → products → suppliers

------------------------------------------------------------------------

--Find the top 10 suppliers by warehouse sales using JOINs across the new schemas instead of the flat table--
-- What does this mean?: JOIN the three tables 
SELECT 
    s.supplier_name,
    ROUND(SUM(sl.warehouse_sales)::numeric, 2) AS total_warehouse_sales
FROM sales sl
JOIN products p 
    ON s.item_code = p.item_code
JOIN suppliers s 
    ON p.supplier_id = s.supplier_id
GROUP BY s.supplier_id, s.supplier_name
ORDER BY total_warehouse_sales DESC
LIMIT 10;

--Returns 0 rows -- 

--Why did the JOIN not work?
-- I populated the suppliers table incorrectly which gave me a result of 396 suppliers but returned only 5 when doing the count of suppliers 
-- I did not populate the suppliers table with the supplier_id: also a cause of error
-- the join I have has typos -> query could not match rows correctly 

--What to fix?
-- 1. recreate the suppliers table correctly 
-- 2. Populate products with supplier_id
-- 3. Re-create the JOIN 

-- Re-create suppliers table--
DROP TABLE IF EXISTS suppliers CASCADE;

--NOTICE:  drop cascades to constraint products_supplier_id_fkey on table products
--DROP TABLE
--Query returned successfully in 59 msec.

CREATE TABLE suppliers (
    supplier_id   SERIAL PRIMARY KEY,
    supplier_name TEXT NOT NULL
);

--CREATE TABLE
--Query returned successfully in 56 msec.

--Repopulation of suppliers table--
INSERT INTO suppliers (supplier_name)
SELECT DISTINCT supplier
FROM warehouse_and_retail_sales
ORDER BY supplier;

--Verify count--
SELECT COUNT(*) FROM suppliers;

-- "count"
	396

--Correction: there are actually 396 suppliers in the table

--Populate products table--
--What will this do?
-- warehouse_and_retail_sales) contains: item_code, item_description, item_type, supplier (name)

--the normalized products table has: products.item_code, products.item_description, products.item_type, products.supplier_id (FK to suppliers)
--So I need to: 
--Look up each product’s supplier name in the flat table
--Match that supplier name to the correct supplier_id in the new suppliers table
--Insert each product once, with the correct supplier_id


INSERT INTO products (item_code, item_description, item_type, supplier_id)
SELECT 
    wrs.item_code,
    wrs.item_description,
    wrs.item_type,
    s.supplier_id
FROM warehouse_and_retail_sales wrs
JOIN suppliers s
    ON wrs.supplier = s.supplier_name
GROUP BY 
    wrs.item_code, 
    wrs.item_description, 
    wrs.item_type, 
    s.supplier_id;

--ERROR:  duplicate key value violates unique constraint "products_pkey"
--Key (item_code)=(193348) already exists. 
--SQL state: 23505
--Detail: Key (item_code)=(193348) already exists

-- Solution: Drop sales and products table (in order) -> recreate tables -> re-populate product and sales table 

DROP TABLE sales;
DROP TABLE products;

--Re-create products and sales table 

CREATE TABLE products (
    item_code        TEXT PRIMARY KEY,
    item_description TEXT,
    item_type        TEXT,
    supplier_id      INTEGER,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

CREATE TABLE sales (
    sale_id           INTEGER PRIMARY KEY,
    year              INTEGER,
    month             INTEGER,
    item_code         TEXT,
    retail_sales      REAL,
    retail_transfers  REAL,
    warehouse_sales   REAL,
    FOREIGN KEY (item_code) REFERENCES products(item_code)
);

--Re-populate products table 
INSERT INTO products (item_code, item_description, item_type, supplier_id)
SELECT DISTINCT ON (wrs.item_code)
    wrs.item_code,
    wrs.item_description,
    wrs.item_type,
    s.supplier_id
FROM warehouse_and_retail_sales wrs
JOIN suppliers s
    ON wrs.supplier = s.supplier_name
ORDER BY wrs.item_code;

--Re-populate sales table
INSERT INTO sales (year, month, item_code, retail_sales, retail_transfers, warehouse_sales)
SELECT year, month, item_code, retail_sales, retail_transfers, warehouse_sales
FROM warehouse_and_retail_sales;

--ERROR:  null value in column "sale_id" of relation "sales" violates not-null constraint
--Failing row contains (null, 2020, 1, 100009, 0, 0, 2). 
--SQL state: 23502
--Detail: Failing row contains (null, 2020, 1, 100009, 0, 0, 2).

--Problem: the sale_id column is not auto generating (this was the same problem encountered with supplier_id in products table)
--Solution: Drop sales table ->re-create table -> re-populate sales table 

DROP TABLE sales; 

--Re-create sales table 
CREATE TABLE sales (
    sale_id          SERIAL PRIMARY KEY,
    year             INTEGER,
    month            INTEGER,
    item_code        TEXT,
    retail_sales     REAL,
    retail_transfers REAL,
    warehouse_sales  REAL,
    FOREIGN KEY (item_code) REFERENCES products(item_code)
);

--Re-populate sales table 
INSERT INTO sales (year, month, item_code, retail_sales, retail_transfers, warehouse_sales)
SELECT year, month, item_code, retail_sales, retail_transfers, warehouse_sales
FROM warehouse_and_retail_sales;

--Verify everything is working properly 

-- 1. Check count of rows in each table 
SELECT COUNT(*) FROM suppliers;  		-- "count"
											396
SELECT COUNT(*) FROM products; 			-- "count"  
											33917  
SELECT COUNT(*) FROM sales;  			-- "count"
											306516
-- Rows are counted properly 

-- 2. Preview each table 
SELECT * FROM suppliers LIMIT 5;

--"supplier_id"			"supplier_name"
1						"8VINI INC"
2						"A HARDY USA LTD"
3						"A I G WINE & SPIRITS"
4						"A VINTNERS SELECTIONS"
5						"A&E INC"

SELECT * FROM products LIMIT 5; 

--"item_code"	"item_description"				"item_type"				"supplier_id"
"100002"	"PATRON TEQUILA SILVER LTD - 1L"		"LIQUOR"				271
"100007"	"LA CETTO CAB SAUV - 750ML"				"WINE"					76
"100008"	"AMITY VINEYARDS P/NOIR 2013 - 750ML"	"WINE"					76
"100009"	"BOOTLEG RED - 750ML"					"WINE"					273
"100011"	"PAPI P/GRIG - 1.5L"					"WINE"					168

SELECT * FROM sales LIMIT 5;

-- "sale_id"	"year"	"month"	"item_code"	"retail_sales"	"retail_transfers"	"warehouse_sales"
1				2020		1	"100009"			0			0						2
2				2020		1	"100024"			0			1						4
3				2020		1	"1001"				0			0						1
4				2020		1	"100145"			0			0						1
5				2020		1	"100293"			0.82		0						0

-- 3. Test JOIN relationship 
SELECT s.supplier_name, p.item_code, p.item_type
FROM products p
JOIN suppliers s ON p.supplier_id = s.supplier_id
LIMIT 10;

--"supplier_name"				"item_code"						"item_type"
"RELIABLE CHURCHILL LLLP"			"100002"					"LIQUOR"
"CONSTANTINE WINES INC"				"100007"					"WINE"
"CONSTANTINE WINES INC"				"100008"					"WINE"
"REPUBLIC NATIONAL DISTRIBUTING CO"	"100009"					"WINE"
"INTERBALT PRODUCTS CORP"			"100011"					"WINE"
"INTERBALT PRODUCTS CORP"			"100012"					"WINE"
"TRICANA SHIPPERS & IMPORT"			"100022"					"WINE"
"PWSWN INC"							"100023"					"WINE"
"PWSWN INC"							"100024"					"WINE"
"DOPS INC"							"10004"						"WINE"

-- JOIN worked correctly; supplier names are correctly linked to products through the foreign key relationship

-- Execute final JOIN: Top 10 suppliers by warehouse sales using JOINs
-- Previously queried from flat table warehouse_and_retail_sales
-- Now querying across normalized schema: sales → products → suppliers
SELECT 
    s.supplier_name,
    ROUND(SUM(sl.warehouse_sales)::numeric, 2) AS total_warehouse_sales
FROM sales sl
JOIN products p ON sl.item_code = p.item_code
JOIN suppliers s ON p.supplier_id = s.supplier_id
GROUP BY s.supplier_id, s.supplier_name
ORDER BY total_warehouse_sales DESC
LIMIT 10;

-- "supplier_name"					"total_warehouse_sales"
"CROWN IMPORTS"								1651870.00
"MILLER BREWING COMPANY"					1425650.00
"ANHEUSER BUSCH INC"						1370050.00
"HEINEKEN USA"								829546.00
"E & J GALLO WINERY"						197434.00
"BOSTON BEER CORPORATION"					186096.00
"DIAGEO NORTH AMERICA INC"					170581.00
"YUENGLING BREWERY"							134192.00
"FLYING DOG BREWERY LLLP"					128292.00
"CONSTELLATION BRANDS"						118287.00

-- The results match the original flat table query exactly — same 10 suppliers, same order. 
-- Normalization worked correctly