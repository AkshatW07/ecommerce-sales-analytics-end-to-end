CREATE DATABASE ecommerce_project;
USE ecommerce_project;

CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(255),
    brand VARCHAR(100),
    category VARCHAR(100),
    product_rating FLOAT
);

SELECT * FROM staging_products LIMIT 5;

CREATE TABLE clean_products AS
SELECT 
    product_name,
    brand,
    category,
    CASE 
        WHEN product_rating REGEXP '^[0-9.]+$' 
        THEN product_rating 
        ELSE NULL 
    END AS product_rating
FROM staging_products;

INSERT INTO products (product_name, brand, category, product_rating)
SELECT product_name, brand, category, product_rating
FROM clean_products;

SELECT * FROM products LIMIT 10;

DROP TABLE staging_products;
DROP TABLE clean_products;


-- PRICING TABLE

-- verifying
SELECT * FROM staging_pricing LIMIT 5;

-- CREATE ROW MAPPING
CREATE TABLE products_row_map AS
SELECT 
    product_id,
    ROW_NUMBER() OVER () AS row_num
FROM products;

CREATE TABLE pricing_row_map AS
SELECT 
    retail_price,
    discounted_price,
    discount_percent,
    ROW_NUMBER() OVER () AS row_num
FROM staging_pricing;

-- final pricing table
CREATE TABLE pricing (
    product_id INT,
    retail_price FLOAT,
    discounted_price FLOAT,
    discount_percent FLOAT
);

INSERT INTO pricing (product_id, retail_price, discounted_price, discount_percent)
SELECT 
    p.product_id,
    pr.retail_price,
    pr.discounted_price,
    pr.discount_percent
FROM pricing_row_map pr
JOIN products_row_map p
ON pr.row_num = p.row_num;

-- adding foreign keys now
ALTER TABLE pricing
ADD CONSTRAINT fk_product
FOREIGN KEY (product_id) REFERENCES products(product_id);

SELECT * FROM pricing LIMIT 5;

DROP TABLE IF EXISTS staging_pricing;
DROP TABLE IF EXISTS pricing_row_map;
DROP TABLE IF EXISTS products_row_map;



