---Create table ----
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