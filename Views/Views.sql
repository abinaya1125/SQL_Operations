
CREATE VIEW v_employee_summary AS
SELECT 
    emp_id,
    CONCAT(first_name, ' ', last_name) AS full_name,
    email,
    job_title,
    salary,
    dept_id
FROM employees;

CREATE VIEW v_employee_department AS
SELECT 
    e.emp_id,
    e.first_name,
    e.last_name,
    e.job_title,
    e.salary,
    d.dept_name,
    d.location,
    d.budget
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;

CREATE VIEW v_department_stats AS
SELECT 
    d.dept_id,
    d.dept_name,
    d.location,
    COUNT(e.emp_id) AS employee_count,
    AVG(e.salary) AS avg_salary,
    MAX(e.salary) AS max_salary,
    MIN(e.salary) AS min_salary,
    SUM(e.salary) AS total_salary
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name, d.location;

CREATE VIEW v_high_earners AS
SELECT 
    emp_id,
    first_name,
    last_name,
    job_title,
    salary,
    dept_id
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);

CREATE VIEW v_employee_rankings AS
SELECT 
    emp_id,
    first_name,
    last_name,
    dept_id,
    salary,
    RANK() OVER (PARTITION BY dept_id ORDER BY salary DESC) AS dept_rank,
    RANK() OVER (ORDER BY salary DESC) AS company_rank
FROM employees;

CREATE VIEW v_customer_lifetime_value AS
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.registration_date,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(od.unit_price * od.quantity * (1 - od.discount)) AS total_spent,
    AVG(od.unit_price * od.quantity * (1 - od.discount)) AS avg_order_value,
    DATEDIFF(CURDATE(), c.registration_date) AS days_as_customer
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN order_details od ON o.order_id = od.order_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email, c.registration_date;

CREATE VIEW v_active_products AS
SELECT 
    product_id,
    product_name,
    category,
    unit_price,
    stock_quantity,
    CASE 
        WHEN stock_quantity <= reorder_level THEN 'Low Stock'
        WHEN is_discontinued = TRUE THEN 'Discontinued'
        ELSE 'Available'
    END AS status
FROM products
WHERE is_discontinued = FALSE;

CREATE VIEW v_employee_performance AS
SELECT 
    emp_id,
    first_name,
    last_name,
    salary,
    dept_id,
    CASE 
        WHEN salary < 40000 THEN 'Entry Level'
        WHEN salary BETWEEN 40000 AND 60000 THEN 'Mid Level'
        WHEN salary BETWEEN 60001 AND 80000 THEN 'Senior Level'
        ELSE 'Executive'
    END AS performance_level,
    CASE 
        WHEN commission_pct IS NOT NULL THEN 'Commission Eligible'
        ELSE 'Fixed Salary'
    END AS compensation_type
FROM employees;

CREATE VIEW v_recent_hires AS
SELECT 
    emp_id,
    first_name,
    last_name,
    job_title,
    hire_date,
    DATEDIFF(CURDATE(), hire_date) AS days_employed,
    CASE 
        WHEN DATEDIFF(CURDATE(), hire_date) <= 90 THEN 'New Hire'
        WHEN DATEDIFF(CURDATE(), hire_date) <= 365 THEN 'First Year'
        ELSE 'Experienced'
    END AS tenure_category
FROM employees
WHERE hire_date >= DATE_SUB(CURDATE(), INTERVAL 2 YEAR);

CREATE TABLE mv_monthly_sales AS
SELECT 
    YEAR(order_date) AS year,
    MONTH(order_date) AS month,
    COUNT(*) AS order_count,
    SUM(freight) AS total_freight,
    SUM(od.unit_price * od.quantity) AS total_sales
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
GROUP BY YEAR(order_date), MONTH(order_date);

CREATE PROCEDURE refresh_monthly_sales()
BEGIN
    TRUNCATE TABLE mv_monthly_sales;
    INSERT INTO mv_monthly_sales
    SELECT 
        YEAR(order_date) AS year,
        MONTH(order_date) AS month,
        COUNT(*) AS order_count,
        SUM(freight) AS total_freight,
        SUM(od.unit_price * od.quantity) AS total_sales
    FROM orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY YEAR(order_date), MONTH(order_date);
END;

CREATE VIEW v_all_personnel AS
SELECT 
    emp_id AS id,
    CONCAT(first_name, ' ', last_name) AS name,
    email,
    job_title AS role,
    'Employee' AS type
FROM employees
UNION ALL
SELECT 
    customer_id AS id,
    CONCAT(first_name, ' ', last_name) AS name,
    email,
    'Customer' AS role,
    'Customer' AS type
FROM customers;

CREATE VIEW v_employee_analysis AS
WITH dept_avg AS (
    SELECT dept_id, AVG(salary) AS avg_salary
    FROM employees
    GROUP BY dept_id
),
salary_ranges AS (
    SELECT 
        emp_id,
        salary,
        CASE 
            WHEN salary < 40000 THEN 'Low'
            WHEN salary < 70000 THEN 'Medium'
            ELSE 'High'
        END AS salary_range
    FROM employees
)
SELECT 
    e.emp_id,
    e.first_name,
    e.last_name,
    e.salary,
    da.avg_salary,
    sr.salary_range,
    e.salary - da.avg_salary AS salary_difference
FROM employees e
JOIN dept_avg da ON e.dept_id = da.dept_id
JOIN salary_ranges sr ON e.emp_id = sr.emp_id;

CREATE VIEW v_employee_public AS
SELECT 
    emp_id,
    first_name,
    last_name,
    job_title,
    dept_id
FROM employees
WHERE is_active = TRUE;

CREATE VIEW v_top_customers AS
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    COUNT(DISTINCT o.order_id) AS order_count,
    SUM(od.unit_price * od.quantity) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_details od ON o.order_id = od.order_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email
HAVING COUNT(DISTINCT o.order_id) >= 3
ORDER BY total_spent DESC;

SELECT * FROM v_employee_summary WHERE dept_id = 1;
SELECT * FROM v_department_stats ORDER BY avg_salary DESC;
SELECT * FROM v_customer_lifetime_value WHERE total_orders > 5;

UPDATE v_employee_summary 
SET job_title = 'Senior Developer' 
WHERE emp_id = 1;

DROP VIEW IF EXISTS v_employee_summary;
