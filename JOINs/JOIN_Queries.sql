
SELECT e.first_name, e.last_name, d.dept_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;

SELECT e.first_name, e.last_name, d.dept_name, e.salary
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > 70000;

SELECT c.first_name, c.last_name, o.order_id, o.order_date, p.product_name
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
INNER JOIN order_details od ON o.order_id = od.order_id
INNER JOIN products p ON od.product_id = p.product_id;

SELECT d.dept_name, COUNT(e.emp_id) AS employee_count
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY employee_count;

SELECT c.first_name, c.last_name, c.email
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

SELECT e.first_name, e.last_name, d.dept_name
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id;

SELECT e.first_name AS employee, e.last_name, 
       m.first_name AS manager, m.last_name
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.emp_id;

SELECT e.first_name AS employee, e.hire_date,
       m.first_name AS manager, m.hire_date
FROM employees e
JOIN employees m ON e.manager_id = m.emp_id
WHERE e.hire_date < m.hire_date;

SELECT c.first_name, c.last_name, c.city,
       COUNT(DISTINCT o.order_id) AS order_count,
       SUM(od.quantity * od.unit_price) AS total_spent,
       AVG(od.quantity * od.unit_price) AS avg_order_value
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN order_details od ON o.order_id = od.order_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.city
HAVING COUNT(DISTINCT o.order_id) > 0
ORDER BY total_spent DESC;

SELECT e.first_name, e.last_name, e.hire_date,
       DATEDIFF(CURDATE(), e.hire_date) AS days_employed,
       d.dept_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
WHERE DATEDIFF(CURDATE(), e.hire_date) > 365;

SELECT d.dept_name, p.category
FROM departments d
CROSS JOIN (SELECT DISTINCT category FROM products) p;

SELECT e.first_name, e.last_name, e.salary
FROM employees e
INNER JOIN (
    SELECT dept_id, AVG(salary) AS avg_dept_salary
    FROM employees
    GROUP BY dept_id
) dept_avg ON e.dept_id = dept_avg.dept_id
WHERE e.salary > dept_avg.avg_dept_salary;

SELECT e.first_name, e.last_name, e.salary,
       CASE 
           WHEN e.salary < 50000 THEN 'Low'
           WHEN e.salary BETWEEN 50000 AND 80000 THEN 'Medium'
           ELSE 'High'
       END AS salary_level,
       d.dept_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;

SELECT d.dept_name, 
       COUNT(DISTINCT e.emp_id) AS employee_count,
       COUNT(DISTINCT o.order_id) AS orders_processed,
       SUM(od.quantity * od.unit_price) AS total_revenue
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
LEFT JOIN orders o ON e.emp_id = o.emp_id
LEFT JOIN order_details od ON o.order_id = od.order_id
GROUP BY d.dept_id, d.dept_name;

SELECT CONCAT(e.first_name, ' ', e.last_name) AS full_name,
       UPPER(d.dept_name) AS department,
       LOWER(e.job_title) AS job_title
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;

SELECT 
    e1.first_name AS employee,
    e1.job_title,
    e2.first_name AS manager,
    e2.job_title AS manager_title,
    d.dept_name
FROM employees e1
LEFT JOIN employees e2 ON e1.manager_id = e2.emp_id
LEFT JOIN departments d ON e1.dept_id = d.dept_id
ORDER BY d.dept_name, e1.first_name;

SELECT 
    d.dept_name,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN e.salary > 70000 THEN 1 ELSE 0 END) AS high_earners,
    SUM(CASE WHEN e.commission_pct IS NOT NULL THEN 1 ELSE 0 END) AS commission_employees
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name;

SELECT 
    c.first_name,
    c.last_name,
    COUNT(o.order_id) AS total_orders,
    SUM(CASE WHEN YEAR(o.order_date) = 2023 THEN 1 ELSE 0 END) AS orders_2023,
    SUM(CASE WHEN YEAR(o.order_date) = 2024 THEN 1 ELSE 0 END) AS orders_2024
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(o.order_id) > 0;

SELECT 
    e.first_name,
    e.last_name,
    p.product_name,
    od.quantity,
    od.unit_price,
    o.order_date,
    CASE 
        WHEN o.shipped_date IS NULL THEN 'Not Shipped'
        WHEN o.shipped_date <= o.required_date THEN 'On Time'
        ELSE 'Late'
    END AS shipping_status
FROM employees e
INNER JOIN orders o ON e.emp_id = o.emp_id
INNER JOIN order_details od ON o.order_id = od.order_id
INNER JOIN products p ON od.product_id = p.product_id
WHERE o.order_date >= '2023-01-01';

SELECT 
    d.dept_name,
    e.first_name,
    e.last_name,
    e.salary,
    RANK() OVER (PARTITION BY d.dept_name ORDER BY e.salary DESC) AS salary_rank
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
ORDER BY d.dept_name, salary_rank;
