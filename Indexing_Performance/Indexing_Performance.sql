
CREATE INDEX idx_employee_email ON employees(email);

CREATE INDEX idx_employee_dept_salary ON employees(dept_id, salary);

CREATE UNIQUE INDEX idx_unique_customer_email ON customers(email);

CREATE INDEX idx_active_employees ON employees(emp_id) WHERE is_active = TRUE;

CREATE FULLTEXT INDEX idx_product_name_fulltext ON products(product_name);

EXPLAIN SELECT * FROM employees WHERE dept_id = 1 AND salary > 50000;

EXPLAIN FORMAT=JSON SELECT e.first_name, e.last_name, d.dept_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > 60000;

SHOW INDEX FROM employees;

ANALYZE TABLE employees, departments, customers;

OPTIMIZE TABLE employees;

CREATE INDEX idx_order_customer_date ON orders(customer_id, order_date, order_id);

SELECT order_id, order_date, status FROM orders WHERE customer_id = 123;

CREATE INDEX idx_customer_lastname ON customers(last_name(20));

DROP INDEX idx_unused_index ON table_name;

SELECT * FROM employees USE INDEX (idx_employee_dept_salary) 
WHERE dept_id = 1 AND salary > 50000;

SELECT * FROM employees FORCE INDEX (idx_employee_email) 
WHERE email = 'john.doe@company.com';

SELECT * FROM employees IGNORE INDEX (idx_employee_dept_salary) 
WHERE dept_id = 1;

CREATE SPATIAL INDEX idx_location ON locations(coordinates);

SHOW INDEX FROM employees WHERE Key_name = 'idx_employee_dept_salary';

SELECT 
    table_name,
    index_name,
    cardinality,
    sub_part,
    packed,
    nullable,
    index_type
FROM information_schema.statistics 
WHERE table_schema = 'company_db'
ORDER BY table_name, seq_in_index;

SELECT 
    start_time,
    query_time,
    lock_time,
    rows_sent,
    rows_examined,
    sql_text
FROM mysql.slow_log 
WHERE start_time > DATE_SUB(NOW(), INTERVAL 1 DAY)
ORDER BY query_time DESC;

SELECT 
    DIGEST_TEXT,
    COUNT_STAR,
    AVG_TIMER_WAIT/1000000000 AS avg_time_seconds,
    MAX_TIMER_WAIT/1000000000 AS max_time_seconds,
    SUM_ROWS_EXAMINED/COUNT_STAR AS avg_rows_examined
FROM performance_schema.events_statements_summary_by_digest
WHERE DIGEST_TEXT LIKE '%employees%'
ORDER BY AVG_TIMER_WAIT DESC;

SELECT 
    table_name,
    ROUND(((data_length + index_length) / 1024 / 1024), 2) AS table_size_mb,
    table_rows
FROM information_schema.tables 
WHERE table_schema = 'company_db'
ORDER BY (data_length + index_length) DESC;

SELECT 
    object_name,
    index_name,
    count_read,
    count_fetch,
    sum_timer_fetch/1000000000 AS total_fetch_time_seconds
FROM performance_schema.table_io_waits_summary_by_index_usage
WHERE object_schema = 'company_db'
ORDER BY count_read DESC;

CREATE INDEX idx_employee_upper_name ON employees((UPPER(first_name)));

SELECT * FROM employees WHERE UPPER(first_name) = 'JOHN';

CREATE INDEX idx_employee_salary_desc ON employees(salary DESC);

CREATE INDEX idx_test_index ON employees(dept_id) INVISIBLE;

ALTER TABLE employees ALTER INDEX idx_test_index VISIBLE;

SET autocommit = 0;
SET unique_checks = 0;
SET foreign_key_checks = 0;
-- Perform bulk inserts here
SET foreign_key_checks = 1;
SET unique_checks = 1;
COMMIT;
