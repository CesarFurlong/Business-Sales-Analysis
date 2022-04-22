# Online Store Sales Analysis 
Analysis of sales performance in a store

## Resumen
0. Planteamiento del problema
1. Preparación de datos
2. Limpieza de datos
3. Exploración de datos
4. Conclusiones y recomendaciones

## Planteamiento del problema

## Preparación de los datos
El conjunto de datos contiene información de ventas de una tienda online durante 13 meses. El conjunto de datos consta de 10 columnas y 185.970 filas, cada una de las cuales representa un atributo de compra en un producto adquirido. 

| Nombre de columna | Descripción |
| :------: | :------: |
| OrderID | Unique ID for each order |
| Product | Item being purchased |
| QuantityOrdered | Quantity of products ordered |
| PriceEach | Price for one unit of that product |
| OrderDate | Date the order is placed |
| PurchaseAddress | Address to which the order is shipped |
| Sales | Total price for each order |

Fuente del dataset: [Kaggle](https://www.kaggle.com/datasets/beekiran/sales-data-analysis)

## Limpieza de datos

### Unificar el formato de fechas
Cambiamos el formato de la columna OrderDate de 'DateTime' a 'Date'

 ``` bash
 DROP COLUMN IF EXISTS order_date, year

ALTER TABLE sales
ADD order_date Date
ADD year DATE

UPDATE sales 
SET order_date = strftime('%Y-%m-%d', OrderDate)
SET year = strftime('%Y', OrderDate)

SELECT order_date, OrderDate
FROM sales 
 ```

### Dividir la información de la columna Address
En esta sección se hizo uso de las funciones "sbstr" e "instr" para extraer la información separada por un delimitador de texto de la columna PurchaseAddress. SQLite no cuenta con la función de CHARINDEX.

``` bash
ALTER TABLE sales
ADD state varchar(255)
ADD zipcode varchar(5)
ADD street varchar (20)

UPDATE sales
SET state = substr(PurchaseAddress, -8,2)
SET zipcode = substr(PurchaseAddress, -5)
SET street = substr(PurchaseAddress, 1, instr(PurchaseAddress,',')-1)

SELECT state, zipcode, street
FROM sales
```

### Buscar y eliminar los valores duplicados
La función ROW_NUMBER asigna un número a cada fila con información que debe ser única en cada propiedad como orderID, address, product y muestra el número de veces que una fila con los mismos datos aparece en el conjunto de datos. 

``` bash
DROP TABLE IF EXISTS new_sales

CREATE TEMP TABLE new_sales AS 
SELECT OrderID, order_date, year, Month, Product, QuantityOrdered, PriceEach, Sales, PurchaseAddress, street, City, state, zipcode 
FROM (
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY order_date, Product, QuantityOrdered, PurchaseAddress, PriceEach, Sales, City ORDER BY OrderID) AS row_num
FROM sales
)
WHERE row_num = 1
```

### Eliminamos las columnas con información iterante al análisis

``` bash
ALTER TABLE new_sales
DROP COLUMN OrderDate, row_num
```

## Exploración de datos
Q1: ¿Cuál fue el mejor mes de ventas? ¿Cuánto se ganó ese mes?

``` bash
SELECT year, m.month, ROUND(SUM(Sales),2) AS total_sales
FROM new_sales AS n
INNER JOIN month_year AS m 
ON n.Month = m.key
GROUP BY m.month 
ORDER BY total_sales DESC 
```
Q2: ¿Cuáles son las ventas totales y el número de pedidos por estado?

``` bash
SELECT c.state, ROUND(SUM(Sales),2) AS total_sales, count(OrderID) AS order_number
FROM new_sales As n
INNER JOIN code_state AS c 
ON n.state = c.code
GROUP BY c.state
ORDER BY SUM(Sales) DESC
```

Q3: ¿Qué ciudad ha vendido más productos?

``` bash
SELECT city, SUM(QuantityOrdered) AS quantity_product_order, ROUND(SUM(Sales),2) AS total_sales
FROM new_sales
GROUP BY city
ORDER BY quantity_product_order DESC
```

Q4: ¿A qué hora debemos mostrar los anuncios para maximizar la probabilidad de que el cliente compre el producto?

``` bash
SELECT Hour, count(*) AS count
FROM sales 
GROUP BY Hour
ORDER BY count DESC
```

Q5: ¿Qué producto se ha vendido más? ¿Por qué cree que se ha vendido más?


## Conclusiones y recomendaciones












