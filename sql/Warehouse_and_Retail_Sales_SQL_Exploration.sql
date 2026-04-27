--Exploration---
--Sales breakdown by item type
--What is the total retail sales and warehouse sales for each item type (WINE, BEER, LIQUOR)?--
SELECT item_type, 
ROUND(SUM(retail_sales):: numeric, 2) AS total_retail,
ROUND(SUM(warehouse_sales):: numeric, 2) AS total_warehouse
FROM warehouse_and_retail_sales
GROUP BY item_type
ORDER BY total_retail;

--Results:
"item_type"	"total_retail"	"total_warehouse"
"DUNNAGE"		0.00				-121454.00
"KEGS"			0.00				118431.00
				0.00				1.00
"REF"			663.63				-20499.00
"STR_SUPPLIES"	2740.88				0.00
"NON-ALCOHOL"	34084.31			26149.59
"BEER"			574220.53			6527236.51
"WINE"			746498.59			1156984.91
"LIQUOR"		802691.43			94906.27

--Found unexpected categories: Dunnage, REF, STR_SUPPLIES, non-alcohol, and NULL
-- Beer dominates in warehouse sales with a total of $6,527,236.51 --

--Best and worst months for retail sales
--Which month had the highest total retail sales? Which had the lowest? Show all 12 months ranked.
SELECT month, 
ROUND(SUM(retail_sales):: numeric, 2) as monthly_retail
FROM warehouse_and_retail_sales
GROUP BY month
ORDER BY monthly_retail DESC;

--"month"	"monthly_retail"--
7				277927.73
9				254687.49
1				226211.07
11				199947.50
3				193852.33
6				188217.65
8				177740.39
10				177467.37
2				157917.67
12				131634.49
5				94953.10
4				80342.58

-- July has the highest number total retail sales--
--April has the lowest number of total retail sales--

--Top 10 suppliers by warehouse sales
--Who are the top 10 suppliers based on total warehouse sales?
SELECT supplier, 
ROUND(SUM(warehouse_sales):: numeric, 2) AS total_warehouse
FROM warehouse_and_retail_sales
GROUP BY supplier
ORDER BY SUM(warehouse_sales) DESC
LIMIT 10;

--Top 10 Suppliers--
"CROWN IMPORTS"
"MILLER BREWING COMPANY"
"ANHEUSER BUSCH INC"
"HEINEKEN USA"
"E & J GALLO WINERY"
"BOSTON BEER CORPORATION"
"DIAGEO NORTH AMERICA INC"
"YUENGLING BREWERY"
"FLYING DOG BREWERY LLLP"
"CONSTELLATION BRANDS"

--Items sold at retail but not from warehouse
--Find the top 10 items that had retail sales but zero warehouse sales. These items may be coming from a different supply channel.
SELECT item_description, 
ROUND(SUM(retail_sales):: numeric, 2) AS retail
FROM warehouse_and_retail_sales
WHERE warehouse_sales = 0
GROUP BY item_description
HAVING SUM(retail_sales) > 0 
ORDER BY retail DESC
LIMIT 10; 

--Results 
"item_description"								"retail"
"ICE"											6934.00
"SKYY VODKA - 1.75L"							4095.22
"JOHNNIE WALKER RED - 1.75L"					3423.93
"BURNETT'S VODKA - 1.75L"						3152.84
"BACARDI RUM - GOLD - 1.75L"					3038.85
"BOMBAY GIN - SAPPHIRE - 1.75L"					2937.49
"DEWAR'S ""WHITE LABEL"" SCOTCH - 1.75L"		2477.12
"BULLEIT BOURBON - 1.75L"						2220.03
"WOODFORD RESERVE KY STRAIT - 1.75L"			1967.61
"CANADIAN CLUB WHISKEY - 1.75L"					1863.39

--There are 10 items that are sold at retail sales but not in warehouse sales--

--5. How many unique products per item type?
--Count the number of distinct products in each item type category.
SELECT item_type, COUNT(DISTINCT item_code) AS unique_products
FROM warehouse_and_retail_sales
GROUP BY item_type;

-- "item_type"	"unique_products"
"BEER"				5438
"DUNNAGE"			4
"KEGS"				2672
"LIQUOR"			4469
"NON-ALCOHOL"		125
"REF"				11
"STR_SUPPLIES"		27
"WINE"				21200
"NULL"				1

-- Wine has the largest product catalog out of the 9 item types----
-- There is also one unique product in the NULL category--

--RESULTS SUMMARY--
-- Unexpected items found: Dunnage, kegs, STR_SUPPLIES, non-alcohol, and NULL
-- There are negative warehouse sales found in Dunnage with a total of -121,454.00 and REF with a total of -20,499.00
-- One unique products exists in the NULL item type
-- Decision: Kept these rows in for further investigation 


