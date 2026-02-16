
SELECT COUNT(*) AS total_employees FROM employees;

SELECT COUNT(DISTINCT dept_id) AS number_of_departments FROM employees;

SELECT SUM(salary) AS total_payroll FROM employees;

SELECT AVG(salary) AS average_salary FROM employees;

SELECT MIN(salary) AS min_salary, MAX(salary) AS max_salary FROM employees;

SELECT dept_id, COUNT(*) AS employee_count, AVG(salary) AS avg_salary
FROM employees
GROUP BY dept_id;

SELECT dept_id, COUNT(*) AS employee_count
FROM employees
GROUP BY dept_id
HAVING COUNT(*) > 5;

SELECT dept_id, job_title, COUNT(*) AS count, AVG(salary) AS avg_salary
FROM employees
GROUP BY dept_id, job_title
ORDER BY avg_salary DESC;

SELECT c.customer_id, c.first_name, c.last_name, 
       SUM(od.unit_price * od.quantity * (1 - od.discount)) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_details od ON o.order_id = od.order_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC;

SELECT category, COUNT(*) AS product_count, AVG(unit_price) AS avg_price
FROM products
WHERE is_discontinued = FALSE
GROUP BY category
ORDER BY product_count DESC;

SELECT YEAR(order_date) AS order_year, 
       MONTH(order_date) AS order_month,
       COUNT(*) AS order_count,
       SUM(freight) AS total_freight
FROM orders
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY order_year, order_month;

SELECT first_name, last_name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees)
ORDER BY salary DESC;

SELECT d.dept_name, d.budget, 
       COUNT(e.emp_id) AS employee_count,
       SUM(e.salary) AS total_salaries,
       d.budget - SUM(e.salary) AS remaining_budget
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name, d.budget
ORDER BY remaining_budget DESC;

SELECT c.customer_id, c.first_name, c.last_name,
       COUNT(o.order_id) AS order_count,
       MIN(o.order_date) AS first_order,
       MAX(o.order_date) AS last_order
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY order_count DESC;

SELECT major, 
       COUNT(*) AS student_count,
       AVG(gpa) AS avg_gpa,
       MIN(gpa) AS min_gpa,
       MAX(gpa) AS max_gpa
FROM students
WHERE gpa IS NOT NULL
GROUP BY major
HAVING COUNT(*) >= 3
ORDER BY avg_gpa DESC;
