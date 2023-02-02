/*1. Write a query to Display the product details (product_class_code, product_id, product_desc, product_price,) as per the following criteria and sort them in descending 
order of category: a. If the category is 2050, increase the price by 2000 b. If the category is 2051, increase the price by 500 c. If the category is 2052, increase the 
price by 600. Hint: Use case statement. no permanent change in table required. (60 ROWS) [NOTE: PRODUCT TABLE] */
	USE ORDERS; -- SELECT DATABASE
	SELECT
		PRODUCT_CLASS_CODE,
		PRODUCT_ID,
		PRODUCT_DESC,
		PRODUCT_PRICE,
	CASE PRODUCT_CLASS_CODE
		WHEN  2050 THEN PRODUCT_PRICE + 2000
		WHEN  2051 THEN PRODUCT_PRICE + 500
		WHEN  2052 THEN PRODUCT_PRICE + 600
		ELSE product_price = 0
	END AS INCREASED_VALUE
	FROM
		PRODUCT
	ORDER BY PRODUCT_DESC DESC;
    

/* 2. Write a query to display (product_class_desc, product_id, product_desc, product_quantity_avail ) and Show inventory status of products as below as per their available 
quantity: a. For Electronics and Computer categories, if available quantity is <= 10, show 'Low stock', 11 <= qty <= 30, show 'In stock', >= 31, show 'Enough stock' b. For 
Stationery and Clothes categories, if qty <= 20, show 'Low stock', 21 <= qty <= 80, show 'In stock', >= 81, show 'Enough stock' c. Rest of the categories, 
if qty <= 15 – 'Low Stock', 16 <= qty <= 50 – 'In Stock', >= 51 – 'Enough stock' For all categories, if available quantity is 0, show 'Out of stock'. 
Hint: Use case statement. (60 ROWS) [NOTE: TABLES TO BE USED – product, product_class] */
    
	SELECT 
		product_class_desc, 
		product_id, 
		product_desc, 
		product_quantity_avail,
	CASE 
		WHEN product_class_desc IN ("Electronics","Computer") AND product_quantity_avail <= 10 THEN "LOW STOCK"
		WHEN product_class_desc IN ("Electronics","Computer") AND PRODUCT_QUANTITY_AVAIL >= 11 AND PRODUCT_QUANTITY_AVAIL <= 30 THEN "IN STOCK"
		WHEN product_class_desc IN ("Electronics","Computer") AND product_quantity_avail >= 31 THEN "ENOUGH STOCK"
		WHEN product_class_desc IN ("Stationery","Clothes") AND product_quantity_avail <= 20 THEN "LOW STOCK"
		WHEN product_class_desc IN ("Stationery","Clothes") AND PRODUCT_QUANTITY_AVAIL >= 21 AND PRODUCT_QUANTITY_AVAIL <= 81 THEN "IN STOCK"
		WHEN product_class_desc IN ("Stationery","Clothes") AND product_quantity_avail >= 81 THEN "ENOUGH STOCK"
		WHEN product_class_desc NOT IN ("Stationery","Clothes","Electronics","Computer") AND product_quantity_avail <= 15 THEN "LOW STOCK"
		WHEN product_class_desc NOT IN ("Stationery","Clothes","Electronics","Computer") AND PRODUCT_QUANTITY_AVAIL >= 16 AND PRODUCT_QUANTITY_AVAIL <= 50 THEN "IN STOCK"
		WHEN product_class_desc NOT IN ("Stationery","Clothes","Electronics","Computer") AND product_quantity_avail >= 51 THEN "ENOUGH STOCK"
	END AS inventory_status
	FROM 
		PRODUCT
	JOIN
		product_class on product.product_class_code = product_class.product_class_code
	;

/* 3. Write a query to Show the count of cities in all countries other than USA & MALAYSIA, with more than 1 city, in the descending order of CITIES. (2 rows) [NOTE: ADDRESS TABLE, 
Do not use Distinct] */

	SELECT
		country,
		count(city) AS No_Of_Cities
	FROM
		address
	WHERE
		country NOT IN("USA", "MALAYSIA") 
	GROUP BY
		country
	LIMIT 2
	;

/* 4. Write a query to display the customer_id,customer full name ,city,pincode,and order details (order id, product class desc, product desc, 
subtotal(product_quantity * product_price)) for orders shipped to cities whose pin codes do not have any 0s in them. Sort the output on customer name and subtotal. 
(52 ROWS) [NOTE: TABLE TO BE USED - online_customer, address, order_header, order_items, product, product_class] */

	SELECT 
		online_customer.customer_id,
		CONCAT(customer_fname, customer_lname) AS customer_full_name,
		city,
		pincode,
		order_header.order_id,
		order_date,
		product_class.product_class_desc,
		product_desc,
		product_quantity * product_price AS Subtotal
	FROM
		online_customer
			JOIN
		address ON online_customer.address_id = address.address_id
			JOIN 
		order_header on online_customer.customer_id=order_header.customer_id
			JOIN
		order_items on order_header.order_id = order_items.order_id
			JOIN
		product on order_items.product_id = product.product_id
			LEFT JOIN
		product_class on product.product_class_code = product_class.product_class_code
	WHERE
		order_status = "Shipped" AND pincode NOT LIKE "%0%"
	ORDER BY
		customer_full_name asc ,Subtotal asc, order_date
	;

/* 5. Write a Query to display product id,product description,totalquantity(sum(product quantity) for an item which has been bought maximum no. of times (Quantity Wise) 
along with product id 201. (USE SUB-QUERY) (1 ROW) [NOTE: ORDER_ITEMS TABLE, PRODUCT TABLE] */

	SELECT count(oi.PRODUCT_ID) AS COUNT_ITEMS,oi.PRODUCT_ID,pd.PRODUCT_DESC,sum(oi.PRODUCT_QUANTITY) AS TOTAL_QUANTITY
	FROM 
		ORDER_ITEMS AS oi
	INNER JOIN 
	PRODUCT AS pd ON oi.PRODUCT_ID = pd.PRODUCT_ID
	WHERE oi.ORDER_ID IN (SELECT ORDER_ID FROM ORDER_ITEMS WHERE PRODUCT_ID = 201)
	AND oi.PRODUCT_ID != 201
	GROUP BY oi.PRODUCT_ID
	ORDER BY COUNT_ITEMS DESC
	LIMIT 1;

/* 6. Write a query to display the customer_id,customer name, email and order details (order id, product desc,product qty, subtotal(product_quantity * product_price)) 
for all customers even if they have not ordered any item.(225 ROWS) [NOTE: TABLE TO BE USED - online_customer, order_header, order_items, product] */

	SELECT 
		online_customer.customer_id,
		CONCAT(Customer_fname, customer_lname) AS customer_name,
		customer_email,
		order_header.order_id,
		product_desc,
		product_quantity,
		(product_quantity*product_price) AS subtotal
	FROM
		online_customer 
	LEFT JOIN 
		order_header on online_customer.customer_id = order_header.customer_id
	LEFT JOIN 
		order_items on order_header.order_id = order_items.order_id
	LEFT JOIN 
		product on order_items.product_id = product.product_id
	;

/* 7. Write a query to display carton id, (len*width*height) as carton_vol and identify the optimum carton (carton with the least volume whose volume is greater than the 
total volume of all items (len * width * height * product_quantity)) for a given order whose order id is 10006, Assume all items of an order are packed into one 
single carton (box). (1 ROW) [NOTE: CARTON TABLE] */	
	SELECT 
		carton_id,
		(len*width*height) AS carton_volume
	FROM
		carton
	WHERE 
		(len*width*height) > ( select sum(len*width*height*product_quantity) from product join order_items on product.product_id = order_items.product_id WHERE order_id = 10006)
	limit 1
	;

/* 8. Write a query to display details (customer id,customer fullname,order id,product quantity) of customers who bought more than ten (i.e. total order qty) products per 
shipped order. (11 ROWS) [NOTE: TABLES TO BE USED - online_customer, order_header, order_items,] */

	SELECT
		online_customer.customer_id,
		CONCAT(customer_fname, customer_lname) AS customer_fullname,
		order_header.order_id,
		sum(product_quantity) AS total_quantity
	FROM
		online_customer 
		JOIN order_header ON online_customer.customer_id = order_header.customer_id
		JOIN order_items ON order_header.order_id = order_items.order_id
	WHERE 
		order_header.order_status = "Shipped" 
	GROUP BY 
		order_header.order_id
	HAVING sum(product_quantity) > 10
	;

/* 9. Write a query to display the order_id, customer id and customer full name of customers along with (product_quantity) as total quantity of products shipped for order 
ids > 10060. (6 ROWS) [NOTE: TABLES TO BE USED - online_customer, order_header, order_items] */

	SELECT
		order_header.order_id,
		order_header.customer_id,
		CONCAT(online_customer.customer_fname, online_customer.customer_lname) AS customer_fullname,
		sum(product_quantity) AS total_quantity 
	FROM
		order_header
		JOIN online_customer ON order_header.customer_id = online_customer.customer_id
		JOIN order_items ON order_header.order_id = order_items.order_id
	WHERE 
		order_status = "Shipped" AND order_header.order_id > 10060
	GROUP BY 
		order_header.order_id
	;


/* 10. Write a query to display product class description ,total quantity (sum(product_quantity),Total value (product_quantity * product price) and show which class of products 
have been shipped highest(Quantity) to countries outside India other than USA? Also show the total value of those items. (1 ROWS)[NOTE:PRODUCT TABLE,ADDRESS TABLE,
ONLINE_CUSTOMER TABLE,ORDER_HEADER TABLE,ORDER_ITEMS TABLE,PRODUCT_CLASS TABLE] */

	SELECT
		country,
		product_class_desc,
		sum(product_quantity) AS total_value,
		(product_quantity * product_price) AS total_quantity
	FROM
		address 
		JOIN online_customer ON address.address_id = online_customer.address_id
		JOIN order_header ON online_customer.customer_id = order_header.customer_id
		JOIN order_items ON order_header.order_id = order_items.order_id
		JOIN product ON order_items.product_id = product.product_id
		JOIN product_class ON product.product_class_code = product_class.product_class_code
	WHERE 
		order_header.order_status = "Shipped" And country NOT IN ("India","USA")
	GROUP BY
		order_header.order_id, product.product_id, product_class.product_class_code
	order by
		count((product_quantity * product_price))desc limit 1;


