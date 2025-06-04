/* Table Modification - setup pk & fk 
steps:
1. check for table
2. confirming the column constraint and status
3. alter table */

-- a. customers (no dependencies)
SELECT *
FROM customers
FETCH FIRST 5 ROWS ONLY;

ALTER TABLE customers
ADD CONSTRAINT pk_customers PRIMARY KEY (customer_id);

-- b. products
SELECT * 
FROM products
FETCH FIRST 5 ROWS ONLY;

/* have to clean for duplicates/null values. cannot set product_id
as primary key */

--checking for duplicates
SELECT
    product_id,
    COUNT(*) count
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;

-- deleting duplicates (use oracle rowid specialty)
DELETE FROM products p1
WHERE ROWID > (
    SELECT MIN(ROWID)
    FROM products p2
    WHERE p1.product_id = p2.product_id
    );

ALTER TABLE products
ADD CONSTRAINT pk_products PRIMARY KEY (product_id);

-- c. order_details 

SELECT *
FROM order_details
FETCH FIRST 5 ROWS ONLY;

/* order_id - pk
    customer_id -fk */
    
ALTER TABLE order_details
ADD CONSTRAINT pk_order_detals PRIMARY KEY (order_id);

ALTER TABLE order_details
ADD CONSTRAINT fk_order_customers 
FOREIGN KEY (customer_id) 
REFERENCES customers(customer_id);

-- d. order_items
SELECT *
FROM order_items
FETCH FIRST 25 ROWS ONLY;


/* handling missing column - item_id (PK),
using row_number() method to uniqiely identify each row */

ALTER TABLE order_items
ADD item_id NUMBER;

UPDATE order_items oi
SET item_id = (
  SELECT rn
  FROM (
    SELECT ROWID AS rid,
           ROW_NUMBER() OVER (ORDER BY ROWID) AS rn
    FROM order_items
  ) ordered
  WHERE ordered.rid = oi.ROWID
);

ALTER TABLE order_items
ADD CONSTRAINT pk_order_items PRIMARY KEY (item_id);

ALTER TABLE order_items
ADD CONSTRAINT fk_order_items_order
FOREIGN KEY (order_id)
REFERENCES order_details(order_id);

ALTER TABLE order_items
ADD CONSTRAINT fk_order_items_product
FOREIGN KEY (product_id)
REFERENCES products(product_id);

/* seller_id wont act as the fk since theres no reference table
to refer seller_id col to */

-- e. payment
SELECT *
FROM payment
FETCH FIRST 5 ROWS ONLY;

ALTER TABLE payment
ADD CONSTRAINT fk_payment_order
FOREIGN KEY (order_id)
REFERENCES order_details(order_id);



/* Create table dictionary - Track changes and table altered  */
CREATE TABLE retail_dictionary (
    table_name VARCHAR(50),
    col_name VARCHAR(50),
    description VARCHAR(200),
    data_type VARCHAR(50),
    transformation_note VARCHAR(100),
    rows_affected INT
);

INSERT INTO retail_dictionary (table_name, col_name, description, data_type, transformation_note)
VALUES ('payment', 'order_id', 'set FK to order_id', '-', 'set FK to order_id reference to order_details table');



SELECT * FROM retail_dictionary;

