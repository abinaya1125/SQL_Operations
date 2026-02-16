
SELECT * FROM employees;

SELECT first_name, last_name, email, city FROM customers;

SELECT first_name, last_name, salary FROM employees WHERE salary > 50000;

SELECT * FROM customers WHERE country = 'USA';

SELECT product_name, stock_quantity, reorder_level 
FROM products 
WHERE stock_quantity < reorder_level;

SELECT first_name, last_name, salary, dept_id 
FROM employees 
WHERE salary > 60000 AND dept_id = 1;

SELECT product_name, category, unit_price 
FROM products 
WHERE category = 'Electronics' OR category = 'Computers';

SELECT first_name, last_name, job_title 
FROM employees 
WHERE job_title IN ('Manager', 'Developer', 'Analyst');

SELECT product_name, category 
FROM products 
WHERE category NOT IN ('Discontinued', 'Obsolete');

SELECT first_name, last_name, hire_date 
FROM employees 
WHERE hire_date BETWEEN '2020-01-01' AND '2023-12-31';

SELECT product_name, unit_price 
FROM products 
WHERE unit_price BETWEEN 100 AND 500;

SELECT first_name, last_name, email 
FROM customers 
WHERE email LIKE '%@gmail.com';

SELECT product_name FROM products WHERE product_name LIKE 'Laptop%';

SELECT first_name, last_name, phone FROM customers WHERE phone IS NULL;

SELECT first_name, last_name, commission_pct FROM employees WHERE commission_pct IS NOT NULL;
