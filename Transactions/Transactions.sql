
START TRANSACTION;
UPDATE employees SET dept_id = 2 WHERE emp_id = 1;
UPDATE departments SET budget = budget - 50000 WHERE dept_id = 1;
UPDATE departments SET budget = budget + 50000 WHERE dept_id = 2;
COMMIT;

START TRANSACTION;
BEGIN
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Order processing failed, transaction rolled back' AS result;
    END;
    
    -- Check product availability
    DECLARE stock_available INT;
    SELECT stock_quantity INTO stock_available FROM products WHERE product_id = 1;
    
    IF stock_available >= 10 THEN
        -- Create order
        INSERT INTO orders (customer_id, order_date, status) VALUES (1, CURDATE(), 'Processing');
        SET @order_id = LAST_INSERT_ID();
        
        -- Create order detail
        INSERT INTO order_details (order_id, product_id, unit_price, quantity) 
        VALUES (@order_id, 1, 100.00, 10);
        
        -- Update stock
        UPDATE products SET stock_quantity = stock_quantity - 10 WHERE product_id = 1;
        
        COMMIT;
        SELECT 'Order processed successfully' AS result;
    ELSE
        ROLLBACK;
        SELECT 'Insufficient stock, transaction rolled back' AS result;
    END IF;
END;

START TRANSACTION;
BEGIN
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK TO savepoint_before_update;
        SELECT 'Error occurred, rolled back to savepoint' AS result;
    END;
    
    -- First update
    SAVEPOINT savepoint_before_update;
    UPDATE products SET stock_quantity = stock_quantity - 5 WHERE product_id = 1;
    
    -- Second update
    UPDATE products SET stock_quantity = stock_quantity - 3 WHERE product_id = 2;
    
    -- Check if any stock went negative
    IF EXISTS (SELECT 1 FROM products WHERE stock_quantity < 0) THEN
        ROLLBACK TO savepoint_before_update;
        SELECT 'Stock would go negative, rolled back' AS result;
    ELSE
        COMMIT;
        SELECT 'Inventory updated successfully' AS result;
    END IF;
END;

START TRANSACTION;
BEGIN
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Employee hiring failed, transaction rolled back' AS result;
    END;
    
    -- Insert employee
    INSERT INTO employees (first_name, last_name, email, job_title, salary, dept_id, hire_date)
    VALUES ('John', 'Doe', 'john.doe@company.com', 'Developer', 60000, 1, CURDATE());
    SET @emp_id = LAST_INSERT_ID();
    
    -- Update department budget
    UPDATE departments SET budget = budget - 60000 WHERE dept_id = 1;
    
    -- Create employee record in HR system (simulation)
    INSERT INTO hr_records (emp_id, hire_date, status) VALUES (@emp_id, CURDATE(), 'Active');
    
    COMMIT;
    SELECT CONCAT('Employee ', @emp_id, ' hired successfully') AS result;
END;

START TRANSACTION;
BEGIN
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Transfer failed, transaction rolled back' AS result;
    END;
    
    -- Debit from account 1
    UPDATE accounts SET balance = balance - 1000 WHERE account_id = 1;
    
    -- Credit to account 2
    UPDATE accounts SET balance = balance + 1000 WHERE account_id = 2;
    
    -- Record transaction
    INSERT INTO transactions (from_account, to_account, amount, transaction_date)
    VALUES (1, 2, 1000, CURDATE());
    
    COMMIT;
    SELECT 'Transfer completed successfully' AS result;
END;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
SELECT * FROM employees WHERE dept_id = 1 FOR UPDATE;
COMMIT;

START TRANSACTION;
BEGIN
    DECLARE EXIT HANDLER FOR 1213 (Deadlock found)
    BEGIN
        ROLLBACK;
        SELECT 'Deadlock occurred, please retry' AS result;
    END;
    
    -- Update in consistent order to prevent deadlocks
    UPDATE employees SET salary = salary * 1.05 WHERE dept_id = 1;
    UPDATE departments SET budget = budget * 1.05 WHERE dept_id = 1;
    
    COMMIT;
    SELECT 'Updates completed successfully' AS result;
END;

START TRANSACTION;
BEGIN
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Data integrity violation, transaction rolled back' AS result;
    END;
    
    -- Insert order
    INSERT INTO orders (customer_id, order_date, status) VALUES (1, CURDATE(), 'Pending');
    SET @order_id = LAST_INSERT_ID();
    
    -- Validate customer exists
    IF NOT EXISTS (SELECT 1 FROM customers WHERE customer_id = 1) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer does not exist';
    END IF;
    
    -- Insert order details
    INSERT INTO order_details (order_id, product_id, unit_price, quantity) 
    VALUES (@order_id, 1, 50.00, 5);
    
    COMMIT;
    SELECT 'Order created with validation' AS result;
END;

START TRANSACTION;
BEGIN
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Compensation logic
        UPDATE employees SET salary = salary / 1.10 WHERE dept_id = 1;
        ROLLBACK;
        SELECT 'Error occurred, compensation applied' AS result;
    END;
    
    -- Give raises
    UPDATE employees SET salary = salary * 1.10 WHERE dept_id = 1;
    
    -- Check budget
    DECLARE total_salaries DECIMAL(12,2);
    DECLARE budget DECIMAL(12,2);
    
    SELECT SUM(salary) INTO total_salaries FROM employees WHERE dept_id = 1;
    SELECT budget INTO budget FROM departments WHERE dept_id = 1;
    
    IF total_salaries > budget THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Budget exceeded';
    END IF;
    
    COMMIT;
    SELECT 'Raises applied successfully' AS result;
END;

START TRANSACTION;
BEGIN
    DECLARE CONTINUE HANDLER FOR 1205 (Lock wait timeout)
    BEGIN
        ROLLBACK;
        SELECT 'Lock wait timeout, transaction rolled back' AS result;
    END;
    
    -- Set lock timeout
    SET SESSION innodb_lock_wait_timeout = 5;
    
    -- Perform updates with potential locks
    UPDATE employees SET salary = salary * 1.02 WHERE dept_id = 1;
    
    COMMIT;
    SELECT 'Updates completed within timeout' AS result;
END;

DELIMITER //
CREATE PROCEDURE sp_retry_transaction()
BEGIN
    DECLARE retry_count INT DEFAULT 0;
    DECLARE max_retries INT DEFAULT 3;
    DECLARE success BOOLEAN DEFAULT FALSE;
    
    WHILE retry_count < max_retries AND NOT success DO
        BEGIN
            DECLARE EXIT HANDLER FOR 1213 (Deadlock found)
            BEGIN
                SET retry_count = retry_count + 1;
                IF retry_count >= max_retries THEN
                    SELECT 'Max retries reached, giving up' AS result;
                END IF;
            END;
            
            START TRANSACTION;
            
            -- Perform transaction work
            UPDATE employees SET salary = salary * 1.03 WHERE dept_id = 1;
            
            COMMIT;
            SET success = TRUE;
            SELECT 'Transaction completed successfully' AS result;
        END;
    END WHILE;
END //
DELIMITER ;

START TRANSACTION;
BEGIN
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        INSERT INTO transaction_log (transaction_type, status, error_message, timestamp)
        VALUES ('Employee Update', 'FAILED', 'Error occurred', NOW());
        SELECT 'Transaction failed and logged' AS result;
    END;
    
    -- Log transaction start
    INSERT INTO transaction_log (transaction_type, status, timestamp)
    VALUES ('Employee Update', 'STARTED', NOW());
    
    -- Perform updates
    UPDATE employees SET salary = salary * 1.05 WHERE emp_id = 1;
    
    -- Log transaction success
    INSERT INTO transaction_log (transaction_type, status, timestamp)
    VALUES ('Employee Update', 'COMPLETED', NOW());
    
    COMMIT;
    SELECT 'Transaction completed and logged' AS result;
END;

START TRANSACTION;
BEGIN
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        -- Call external system rollback (simulation)
        SELECT 'Distributed transaction rolled back' AS result;
    END;
    
    -- Local database operation
    INSERT INTO local_orders (customer_id, amount) VALUES (1, 100.00);
    
    -- External system operation (simulation)
    -- CALL external_system.create_order(1, 100.00);
    
    -- If external operation succeeds, commit local
    COMMIT;
    SELECT 'Distributed transaction completed' AS result;
END;

START TRANSACTION;
BEGIN
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Batch processing failed, transaction rolled back' AS result;
    END;
    
    -- Process multiple records
    INSERT INTO batch_results (record_id, status, processed_date)
    SELECT emp_id, 'PROCESSED', CURDATE() 
    FROM employees 
    WHERE dept_id = 1 AND salary > 50000;
    
    -- Update processed records
    UPDATE employees SET processed = TRUE 
    WHERE dept_id = 1 AND salary > 50000;
    
    COMMIT;
    SELECT CONCAT('Batch processed ', ROW_COUNT(), ' records') AS result;
END;

START TRANSACTION;
BEGIN
    DECLARE should_commit BOOLEAN DEFAULT TRUE;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        SET should_commit = FALSE;
        SELECT 'Error detected, will not commit' AS result;
    END;
    
    -- Perform multiple operations
    UPDATE employees SET salary = salary * 1.02 WHERE dept_id = 1;
    UPDATE departments SET budget = budget * 1.02 WHERE dept_id = 1;
    
    -- Validation check
    IF (SELECT COUNT(*) FROM employees WHERE salary < 30000) > 0 THEN
        SET should_commit = FALSE;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Salary below minimum';
    END IF;
    
    IF should_commit THEN
        COMMIT;
        SELECT 'Transaction committed successfully' AS result;
    ELSE
        ROLLBACK;
        SELECT 'Transaction rolled back due to validation' AS result;
    END IF;
END;

-- Supporting tables for transaction examples:
CREATE TABLE IF NOT EXISTS accounts (
    account_id INT PRIMARY KEY,
    balance DECIMAL(12,2),
    account_type VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    from_account INT,
    to_account INT,
    amount DECIMAL(12,2),
    transaction_date DATE
);

CREATE TABLE IF NOT EXISTS hr_records (
    record_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT,
    hire_date DATE,
    status VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS transaction_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_type VARCHAR(50),
    status VARCHAR(20),
    error_message TEXT,
    timestamp DATETIME
);

CREATE TABLE IF NOT EXISTS local_orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    amount DECIMAL(12,2)
);

CREATE TABLE IF NOT EXISTS batch_results (
    result_id INT AUTO_INCREMENT PRIMARY KEY,
    record_id INT,
    status VARCHAR(20),
    processed_date DATE
);

ALTER TABLE employees ADD COLUMN IF NOT EXISTS processed BOOLEAN DEFAULT FALSE;
