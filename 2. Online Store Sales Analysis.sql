------ Data Cleaning
------ First glance dataset

SELECT * 
FROM sales

------ Standarize date format
DROP COLUMN IF EXISTS order_date, year

ALTER TABLE sales
ADD order_date Date
ADD year DATE

UPDATE sales 
SET order_date = strftime('%Y-%m-%d', OrderDate)
SET year = strftime('%Y', OrderDate)

SELECT order_date, OrderDate
FROM sales 

------ Split Address column (state, zipcode)

ALTER TABLE sales
ADD state varchar(255)
ADD zipcode varchar(5)
ADD street varchar (20)

UPDATE sales
SET state = substr(PurchaseAddress, -8,2)
SET zipcode = substr(PurchaseAddress, -5)
SET street = substr(PurchaseAddress, 1, instr(PurchaseAddress,',')-1)

SELECT street, City, state, zipcode
FROM sales
 
------ Checking for duplicates entries

SELECT count (OrderID) AS num_duplicates
FROM (
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY order_date, Product, QuantityOrdered, PurchaseAddress, PriceEach, Sales, City ORDER BY OrderID) AS row_num
FROM sales)
WHERE row_num = 2

-------- Delete 269 duplicate values

DROP TABLE IF EXISTS new_sales

CREATE TEMP TABLE new_sales AS 
SELECT OrderID, order_date, year, Month, Hour, Product, QuantityOrdered, PriceEach, Sales, PurchaseAddress, street, City, state, zipcode 
FROM (
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY order_date, Product, QuantityOrdered, PurchaseAddress, PriceEach, Sales, City ORDER BY OrderID) AS row_num
FROM sales
)
WHERE row_num = 1

------ Removing unused columns

ALTER TABLE new_sales
DROP COLUMN OrderDate, row_num;

SELECT *
FROM new_sales
ORDER BY order_date 
LIMIT 100 

------ ANALYSIS
---- Through the data has given, the manager of the store wants to know:
--- 1. What is the most profitable month for the store?
--- 2. What are total sales and order number by state?
--- 3. The order number, amount of products sold, total sales per year and average sales per order
--- 4. At what time should we show ads to maximize the likelihood that the customer will buy the product?
--- 5. Total sales per product 

------ 1. The order number, amount of products sold, total sales per year and average sales per order

SELECT year, ROUND(SUM(Sales),2) AS total_sales , count(OrderID) AS order_number, SUM(QuantityOrdered) AS num_products_sold, ROUND(SUM(Sales),2)/count(OrderID) AS order_avg
FROM sales
GROUP BY year

------ 2. What is the most profitable month for the store? 

SELECT year, m.month, ROUND(SUM(Sales),2) AS total_sales
FROM new_sales AS n
INNER JOIN month_year AS m 
ON n.Month = m.key
GROUP BY m.month 
ORDER BY total_sales DESC 

------ 3. What are total sales and order number by state?

SELECT c.state, ROUND(SUM(Sales),2) AS total_sales, count(OrderID) AS order_number
FROM new_sales As n
INNER JOIN code_state AS c 
ON n.state = c.code
GROUP BY c.state
ORDER BY SUM(Sales) DESC

----- 4.- At what time should we show ads to maximize the likelihood that the customer will buy the product?

SELECT Hour, count(*) AS count, ROUND(SUM(Sales),2) AS total_sales
FROM new_sales 
GROUP BY Hour
ORDER BY count DESC

------ 5.- Total sales per product 

SELECT Product, SUM(QuantityOrdered) AS quantity_ordered, ROUND(SUM(Sales),2) AS total_sales
FROM new_sales
GROUP BY Product 
ORDER BY quantity_ordered DESC




