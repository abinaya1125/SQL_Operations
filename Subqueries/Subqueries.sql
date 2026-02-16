
SELECT first_name, last_name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees)
ORDER BY salary DESC;

SELECT first_name, last_name, dept_id
FROM employees
WHERE dept_id IN (
    SELECT dept_id FROM departments WHERE budget > 500000
);

SELECT product_name, category
FROM products
WHERE product_id NOT IN (
    SELECT DISTINCT product_id FROM order_details
);

SELECT first_name, last_name, email
FROM customers c
WHERE EXISTS (
    SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id
);

SELECT first_name, last_name, email
FROM customers c
WHERE NOT EXISTS (
    SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id
);

SELECT e.first_name, e.last_name, e.salary,
       (SELECT AVG(salary) FROM employees e2 WHERE e2.dept_id = e.dept_id) AS dept_avg_salary
FROM employees e
WHERE e.salary > (SELECT AVG(salary) FROM employees e2 WHERE e2.dept_id = e.dept_id);

SELECT first_name, last_name, salary
FROM employees e1
WHERE 4 = (
    SELECT COUNT(DISTINCT e2.salary)
    FROM employees e2
    WHERE e2.salary >= e1.salary
);

SELECT first_name, last_name,
       (SELECT dept_name FROM departments d WHERE d.dept_id = e.dept_id) AS department
FROM employees e;

SELECT dept_avg.dept_id, dept_avg.avg_salary, d.dept_name
FROM (
    SELECT dept_id, AVG(salary) AS avg_salary
    FROM employees
    GROUP BY dept_id
) dept_avg
INNER JOIN departments d ON dept_avg.dept_id = d.dept_id
WHERE dept_avg.avg_salary > 60000;

SELECT first_name, last_name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees)
  AND dept_id IN (SELECT dept_id FROM departments WHERE location = 'New York')
  AND emp_id NOT IN (SELECT manager_id FROM employees WHERE manager_id IS NOT NULL);

SELECT c.first_name, c.last_name,
       (SELECT COUNT(*) FROM orders o WHERE o.customer_id = c.customer_id) AS order_count
FROM customers c
ORDER BY order_count DESC;

SELECT dept_id, COUNT(*) AS employee_count
FROM employees
GROUP BY dept_id
HAVING COUNT(*) > (SELECT AVG(emp_count) FROM (
    SELECT COUNT(*) AS emp_count FROM employees GROUP BY dept_id
) AS avg_counts);

SELECT first_name, last_name, salary
FROM employees
WHERE dept_id IN (
    SELECT dept_id FROM departments 
    WHERE budget > (
        SELECT AVG(budget) FROM departments
    )
)
AND salary > (
    SELECT AVG(salary) FROM employees 
    WHERE dept_id IN (
        SELECT dept_id FROM departments WHERE location = 'New York'
    )
);

SELECT e.first_name, e.last_name, e.hire_date,
       (SELECT AVG(DATEDIFF(CURDATE(), hire_date)) 
        FROM employees e2 
        WHERE e2.dept_id = e.dept_id) AS avg_dept_tenure
FROM employees e
WHERE DATEDIFF(CURDATE(), e.hire_date) > (
    SELECT AVG(DATEDIFF(CURDATE(), hire_date)) 
    FROM employees e2 
    WHERE e2.dept_id = e.dept_id
);

SELECT first_name, last_name, dept_id, salary
FROM (
    SELECT first_name, last_name, dept_id, salary,
           RANK() OVER (PARTITION BY dept_id ORDER BY salary DESC) AS dept_rank
    FROM employees
) ranked
WHERE dept_rank = 1;
