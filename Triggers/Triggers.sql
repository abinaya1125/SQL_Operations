
DELIMITER //
CREATE TRIGGER tr_validate_employee_email
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    IF NEW.email NOT LIKE '%@%.%' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Invalid email format';
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER tr_prevent_salary_decrease
BEFORE UPDATE ON employees
FOR EACH ROW
BEGIN
    IF NEW.salary < OLD.salary THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Salary cannot be decreased';
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER tr_log_new_employee
AFTER INSERT ON employees
FOR EACH ROW
BEGIN
    INSERT INTO employee_audit (emp_id, action, action_date, old_values, new_values)
    VALUES (NEW.emp_id, 'INSERT', NOW(), NULL, 
            JSON_OBJECT('first_name', NEW.first_name, 'last_name', NEW.last_name, 'salary', NEW.salary));
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER tr_log_employee_changes
AFTER UPDATE ON employees
FOR EACH ROW
BEGIN
    IF NEW.salary != OLD.salary OR NEW.dept_id != OLD.dept_id THEN
        INSERT INTO employee_audit (emp_id, action, action_date, old_values, new_values)
        VALUES (NEW.emp_id, 'UPDATE', NOW(), 
                JSON_OBJECT('salary', OLD.salary, 'dept_id', OLD.dept_id),
                JSON_OBJECT('salary', NEW.salary, 'dept_id', NEW.dept_id));
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER tr_prevent_employee_deletion
BEFORE DELETE ON employees
FOR EACH ROW
BEGIN
    DECLARE dependent_count INT;
    
    SELECT COUNT(*) INTO dependent_count 
    FROM employees WHERE manager_id = OLD.emp_id;
    
    IF dependent_count > 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Cannot delete employee with direct reports';
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER tr_update_stock_on_order
AFTER INSERT ON order_details
FOR EACH ROW
BEGIN
    UPDATE products 
    SET stock_quantity = stock_quantity - NEW.quantity
    WHERE product_id = NEW.product_id;
    
    -- Check if stock is below reorder level
    IF (SELECT stock_quantity FROM products WHERE product_id = NEW.product_id) <= 
       (SELECT reorder_level FROM products WHERE product_id = NEW.product_id) THEN
        INSERT INTO reorder_alerts (product_id, alert_date, message)
        VALUES (NEW.product_id, NOW(), 'Stock below reorder level');
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER tr_order_status_change
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
    IF NEW.status != OLD.status THEN
        INSERT INTO order_status_history (order_id, old_status, new_status, change_date)
        VALUES (NEW.order_id, OLD.status, NEW.status, NOW());
        
        -- If order is shipped, update shipped date
        IF NEW.status = 'Shipped' AND OLD.status != 'Shipped' THEN
            UPDATE orders SET shipped_date = NOW() WHERE order_id = NEW.order_id;
        END IF;
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER tr_set_order_defaults
BEFORE INSERT ON orders
FOR EACH ROW
BEGIN
    IF NEW.order_date IS NULL THEN
        SET NEW.order_date = CURDATE();
    END IF;
    
    IF NEW.status IS NULL THEN
        SET NEW.status = 'Pending';
    END IF;
    
    IF NEW.freight IS NULL THEN
        SET NEW.freight = 0;
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER tr_customer_welcome
AFTER INSERT ON customers
FOR EACH ROW
BEGIN
    INSERT INTO customer_communications (customer_id, comm_type, comm_date, message)
    VALUES (NEW.customer_id, 'Welcome', NOW(), 
            CONCAT('Welcome ', NEW.first_name, '! Thank you for registering.'));
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER tr_validate_credit_limit
BEFORE UPDATE ON customers
FOR EACH ROW
BEGIN
    IF NEW.credit_limit < 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Credit limit cannot be negative';
    END IF;
    
    IF NEW.credit_limit > 100000 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Credit limit exceeds maximum allowed';
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER tr_calculate_order_total
AFTER INSERT ON order_details
FOR EACH ROW
BEGIN
    DECLARE order_total DECIMAL(12,2);
    
    SELECT SUM(unit_price * quantity * (1 - discount)) INTO order_total
    FROM order_details 
    WHERE order_id = NEW.order_id;
    
    UPDATE orders 
    SET total_amount = order_total 
    WHERE order_id = NEW.order_id;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER tr_archive_deleted_orders
BEFORE DELETE ON orders
FOR EACH ROW
BEGIN
    INSERT INTO orders_archive (order_id, customer_id, order_date, status, total_amount, deleted_date)
    VALUES (OLD.order_id, OLD.customer_id, OLD.order_date, OLD.status, OLD.total_amount, NOW());
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER tr_check_department_budget
AFTER UPDATE ON employees
FOR EACH ROW
BEGIN
    DECLARE dept_budget DECIMAL(12,2);
    DECLARE total_salaries DECIMAL(12,2);
    
    IF NEW.dept_id != OLD.dept_id OR NEW.salary != OLD.salary THEN
        SELECT budget INTO dept_budget FROM departments WHERE dept_id = NEW.dept_id;
        SELECT COALESCE(SUM(salary), 0) INTO total_salaries FROM employees WHERE dept_id = NEW.dept_id;
        
        IF total_salaries > dept_budget THEN
            INSERT INTO budget_alerts (dept_id, alert_date, message, total_salaries, budget)
            VALUES (NEW.dept_id, NOW(), 'Department budget exceeded', total_salaries, dept_budget);
        END IF;
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER tr_validate_student_gpa
BEFORE INSERT ON students
FOR EACH ROW
BEGIN
    IF NEW.gpa IS NOT NULL AND (NEW.gpa < 0 OR NEW.gpa > 4.0) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'GPA must be between 0 and 4.0';
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER tr_check_course_capacity
AFTER INSERT ON enrollments
FOR EACH ROW
BEGIN
    DECLARE enrollment_count INT;
    
    SELECT COUNT(*) INTO enrollment_count 
    FROM enrollments 
    WHERE course_id = NEW.course_id AND status = 'Enrolled';
    
    IF enrollment_count > 30 THEN
        INSERT INTO course_capacity_alerts (course_id, alert_date, enrollment_count)
        VALUES (NEW.course_id, NOW(), enrollment_count);
    END IF;
END //
DELIMITER ;

-- Required supporting tables for triggers:
CREATE TABLE IF NOT EXISTS employee_audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT,
    action VARCHAR(10),
    action_date DATETIME,
    old_values JSON,
    new_values JSON
);

CREATE TABLE IF NOT EXISTS reorder_alerts (
    alert_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT,
    alert_date DATETIME,
    message VARCHAR(200)
);

CREATE TABLE IF NOT EXISTS order_status_history (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    old_status VARCHAR(20),
    new_status VARCHAR(20),
    change_date DATETIME
);

CREATE TABLE IF NOT EXISTS customer_communications (
    comm_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    comm_type VARCHAR(50),
    comm_date DATETIME,
    message TEXT
);

CREATE TABLE IF NOT EXISTS orders_archive (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    status VARCHAR(20),
    total_amount DECIMAL(12,2),
    deleted_date DATETIME
);

CREATE TABLE IF NOT EXISTS budget_alerts (
    alert_id INT AUTO_INCREMENT PRIMARY KEY,
    dept_id INT,
    alert_date DATETIME,
    message VARCHAR(200),
    total_salaries DECIMAL(12,2),
    budget DECIMAL(12,2)
);

CREATE TABLE IF NOT EXISTS course_capacity_alerts (
    alert_id INT AUTO_INCREMENT PRIMARY KEY,
    course_id INT,
    alert_date DATETIME,
    enrollment_count INT
);

-- Add total_amount column to orders table if it doesn't exist
ALTER TABLE orders ADD COLUMN IF NOT EXISTS total_amount DECIMAL(12,2);
