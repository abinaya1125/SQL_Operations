
DELIMITER //
CREATE PROCEDURE sp_get_employee_by_id(IN emp_id INT)
BEGIN
    SELECT 
        emp_id,
        first_name,
        last_name,
        email,
        job_title,
        salary,
        dept_id
    FROM employees
    WHERE employees.emp_id = emp_id;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_get_employee_count(OUT emp_count INT)
BEGIN
    SELECT COUNT(*) INTO emp_count FROM employees;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_check_salary_range(IN emp_id_param INT, OUT is_high_earner BOOLEAN)
BEGIN
    DECLARE emp_salary DECIMAL(10,2);
    DECLARE avg_salary DECIMAL(10,2);
    
    SELECT salary INTO emp_salary FROM employees WHERE emp_id = emp_id_param;
    SELECT AVG(salary) INTO avg_salary FROM employees;
    
    SET is_high_earner = (emp_salary > avg_salary);
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_hire_employee(
    IN fname VARCHAR(50),
    IN lname VARCHAR(50),
    IN email_param VARCHAR(100),
    IN job_title_param VARCHAR(100),
    IN salary_param DECIMAL(10,2),
    IN dept_id_param INT,
    OUT new_emp_id INT
)
BEGIN
    DECLARE email_count INT;
    
    -- Check if email already exists
    SELECT COUNT(*) INTO email_count FROM employees WHERE email = email_param;
    
    IF email_count = 0 THEN
        INSERT INTO employees (first_name, last_name, email, job_title, salary, dept_id, hire_date)
        VALUES (fname, lname, email_param, job_title_param, salary_param, dept_id_param, CURDATE());
        
        SET new_emp_id = LAST_INSERT_ID();
    ELSE
        SET new_emp_id = -1; -- Email already exists
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_give_department_raises(IN dept_id_param INT, IN raise_percentage DECIMAL(5,2))
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE emp_id_var INT;
    DECLARE current_salary DECIMAL(10,2);
    
    DECLARE emp_cursor CURSOR FOR 
        SELECT emp_id, salary FROM employees WHERE dept_id = dept_id_param;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN emp_cursor;
    
    read_loop: LOOP
        FETCH emp_cursor INTO emp_id_var, current_salary;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        UPDATE employees 
        SET salary = salary * (1 + raise_percentage / 100)
        WHERE emp_id = emp_id_var;
    END LOOP;
    
    CLOSE emp_cursor;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_safe_delete_employee(IN emp_id_param INT, OUT result_message VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET result_message = 'Error deleting employee';
    END;
    
    START TRANSACTION;
    
    -- Check if employee exists
    IF EXISTS (SELECT 1 FROM employees WHERE emp_id = emp_id_param) THEN
        -- Update manager_id of employees reporting to this employee
        UPDATE employees SET manager_id = NULL WHERE manager_id = emp_id_param;
        
        -- Delete the employee
        DELETE FROM employees WHERE emp_id = emp_id_param;
        
        COMMIT;
        SET result_message = 'Employee deleted successfully';
    ELSE
        SET result_message = 'Employee not found';
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_generate_sales_report(IN start_date DATE, IN end_date DATE)
BEGIN
    DROP TEMPORARY TABLE IF EXISTS temp_sales_report;
    
    CREATE TEMPORARY TABLE temp_sales_report (
        customer_id INT,
        customer_name VARCHAR(101),
        order_count INT,
        total_amount DECIMAL(12,2),
        avg_order_value DECIMAL(12,2)
    );
    
    INSERT INTO temp_sales_report
    SELECT 
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        COUNT(DISTINCT o.order_id) AS order_count,
        SUM(od.unit_price * od.quantity) AS total_amount,
        AVG(od.unit_price * od.quantity) AS avg_order_value
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_details od ON o.order_id = od.order_id
    WHERE o.order_date BETWEEN start_date AND end_date
    GROUP BY c.customer_id, c.first_name, c.last_name
    ORDER BY total_amount DESC;
    
    SELECT * FROM temp_sales_report;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_employee_dashboard(IN dept_id_param INT)
BEGIN
    -- Department summary
    SELECT 
        d.dept_name,
        COUNT(e.emp_id) AS employee_count,
        AVG(e.salary) AS avg_salary,
        MAX(e.salary) AS max_salary
    FROM departments d
    LEFT JOIN employees e ON d.dept_id = e.dept_id
    WHERE d.dept_id = dept_id_param
    GROUP BY d.dept_id, d.dept_name;
    
    -- Employees in department
    SELECT 
        emp_id,
        first_name,
        last_name,
        job_title,
        salary,
        DATEDIFF(CURDATE(), hire_date) AS days_employed
    FROM employees
    WHERE dept_id = dept_id_param
    ORDER BY salary DESC;
    
    -- Recent hires in department
    SELECT 
        first_name,
        last_name,
        job_title,
        hire_date
    FROM employees
    WHERE dept_id = dept_id_param AND hire_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
    ORDER BY hire_date DESC;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_flexible_employee_search(
    IN search_column VARCHAR(50),
    IN search_value VARCHAR(100)
)
BEGIN
    SET @sql = CONCAT('SELECT * FROM employees WHERE ', search_column, ' = ?');
    
    PREPARE stmt FROM @sql;
    SET @search_param = search_value;
    EXECUTE stmt USING @search_param;
    DEALLOCATE PREPARE stmt;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_bulk_insert_employees()
BEGIN
    DECLARE i INT DEFAULT 1;
    
    WHILE i <= 10 DO
        INSERT INTO employees (first_name, last_name, email, job_title, salary, dept_id, hire_date)
        VALUES (
            CONCAT('FirstName', i),
            CONCAT('LastName', i),
            CONCAT('employee', i, '@company.com'),
            'Developer',
            50000 + (i * 1000),
            1,
            CURDATE()
        );
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_process_order(
    IN customer_id_param INT,
    IN product_id_param INT,
    IN quantity_param INT,
    OUT order_id_result INT,
    OUT result_message VARCHAR(100)
)
BEGIN
    DECLARE product_stock INT;
    DECLARE product_price DECIMAL(10,2);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET result_message = 'Error processing order';
        SET order_id_result = -1;
    END;
    
    START TRANSACTION;
    
    -- Check product availability
    SELECT stock_quantity, unit_price INTO product_stock, product_price
    FROM products WHERE product_id = product_id_param;
    
    IF product_stock >= quantity_param THEN
        -- Create order
        INSERT INTO orders (customer_id, order_date, status)
        VALUES (customer_id_param, CURDATE(), 'Processing');
        
        SET order_id_result = LAST_INSERT_ID();
        
        -- Create order detail
        INSERT INTO order_details (order_id, product_id, unit_price, quantity)
        VALUES (order_id_result, product_id_param, product_price, quantity_param);
        
        -- Update product stock
        UPDATE products 
        SET stock_quantity = stock_quantity - quantity_param 
        WHERE product_id = product_id_param;
        
        COMMIT;
        SET result_message = 'Order processed successfully';
    ELSE
        SET result_message = 'Insufficient stock';
        SET order_id_result = -1;
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_calculate_anniversary_bonuses()
BEGIN
    SELECT 
        emp_id,
        first_name,
        last_name,
        hire_date,
        DATEDIFF(CURDATE(), hire_date) AS days_employed,
        FLOOR(DATEDIFF(CURDATE(), hire_date) / 365) AS years_employed,
        CASE 
            WHEN FLOOR(DATEDIFF(CURDATE(), hire_date) / 365) >= 10 THEN salary * 0.10
            WHEN FLOOR(DATEDIFF(CURDATE(), hire_date) / 365) >= 5 THEN salary * 0.05
            WHEN FLOOR(DATEDIFF(CURDATE(), hire_date) / 365) >= 3 THEN salary * 0.02
            ELSE 0
        END AS anniversary_bonus
    FROM employees
    WHERE is_active = TRUE
    ORDER BY years_employed DESC;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_check_data_integrity()
BEGIN
    -- Check employees without departments
    SELECT 'Employees without departments' AS issue, COUNT(*) AS count
    FROM employees WHERE dept_id IS NULL OR dept_id NOT IN (SELECT dept_id FROM departments);
    
    -- Check orders without customers
    SELECT 'Orders without customers' AS issue, COUNT(*) AS count
    FROM orders WHERE customer_id NOT IN (SELECT customer_id FROM customers);
    
    -- Check order details without orders
    SELECT 'Order details without orders' AS issue, COUNT(*) AS count
    FROM order_details WHERE order_id NOT IN (SELECT order_id FROM orders);
    
    -- Check negative or zero prices
    SELECT 'Products with invalid prices' AS issue, COUNT(*) AS count
    FROM products WHERE unit_price <= 0;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_get_employees_page(IN page_num INT, IN page_size INT)
BEGIN
    DECLARE offset_val INT;
    SET offset_val = (page_num - 1) * page_size;
    
    SELECT 
        emp_id,
        first_name,
        last_name,
        job_title,
        salary,
        dept_id
    FROM employees
    ORDER BY emp_id
    LIMIT offset_val, page_size;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_get_employee_summary_json(IN dept_id_param INT)
BEGIN
    SELECT 
        JSON_OBJECT(
            'department', (SELECT dept_name FROM departments WHERE dept_id = dept_id_param),
            'employee_count', COUNT(*),
            'average_salary', AVG(salary),
            'employees', JSON_ARRAYAGG(
                JSON_OBJECT(
                    'id', emp_id,
                    'name', CONCAT(first_name, ' ', last_name),
                    'job_title', job_title,
                    'salary', salary
                )
            )
        ) AS department_summary
    FROM employees
    WHERE dept_id = dept_id_param;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_archive_old_orders(IN months_old INT)
BEGIN
    DECLARE archived_count INT;
    
    START TRANSACTION;
    
    -- Create archive table if not exists
    CREATE TABLE IF NOT EXISTS orders_archive LIKE orders;
    
    -- Move old orders to archive
    INSERT INTO orders_archive
    SELECT * FROM orders 
    WHERE order_date <= DATE_SUB(CURDATE(), INTERVAL months_old MONTH);
    
    SET archived_count = ROW_COUNT();
    
    -- Delete old orders from main table
    DELETE FROM orders 
    WHERE order_date <= DATE_SUB(CURDATE(), INTERVAL months_old MONTH);
    
    COMMIT;
    
    SELECT CONCAT('Archived ', archived_count, ' orders') AS result;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_update_employee_comprehensive(
    IN emp_id_param INT,
    IN new_salary DECIMAL(10,2),
    IN new_dept_id INT,
    IN new_job_title VARCHAR(100),
    OUT success BOOLEAN,
    OUT message VARCHAR(200)
)
BEGIN
    DECLARE emp_exists INT;
    DECLARE dept_exists INT;
    
    SET success = FALSE;
    SET message = '';
    
    -- Check if employee exists
    SELECT COUNT(*) INTO emp_exists FROM employees WHERE emp_id = emp_id_param;
    
    IF emp_exists = 0 THEN
        SET message = 'Employee not found';
    ELSE
        -- Check if department exists
        SELECT COUNT(*) INTO dept_exists FROM departments WHERE dept_id = new_dept_id;
        
        IF dept_exists = 0 THEN
            SET message = 'Department not found';
        ELSE
            UPDATE employees 
            SET salary = new_salary,
                dept_id = new_dept_id,
                job_title = new_job_title
            WHERE emp_id = emp_id_param;
            
            SET success = TRUE;
            SET message = 'Employee updated successfully';
        END IF;
    END IF;
END //
DELIMITER ;
