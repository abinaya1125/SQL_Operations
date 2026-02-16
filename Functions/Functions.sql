
DELIMITER //
CREATE FUNCTION fn_get_full_name(first_name_param VARCHAR(50), last_name_param VARCHAR(50))
RETURNS VARCHAR(101)
DETERMINISTIC
BEGIN
    RETURN CONCAT(first_name_param, ' ', last_name_param);
END //
DELIMITER ;

DELIMITER //
CREATE FUNCTION fn_annual_salary(monthly_salary DECIMAL(10,2), commission_pct DECIMAL(5,2))
RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
    DECLARE commission_amount DECIMAL(10,2);
    SET commission_amount = IFNULL(commission_pct, 0) * monthly_salary;
    RETURN monthly_salary * 12 + commission_amount;
END //
DELIMITER ;

DELIMITER //
CREATE FUNCTION fn_performance_rating(salary_param DECIMAL(10,2), years_employed INT)
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE rating VARCHAR(20);
    
    IF salary_param > 80000 AND years_employed >= 5 THEN
        SET rating = 'Excellent';
    ELSEIF salary_param > 60000 AND years_employed >= 3 THEN
        SET rating = 'Good';
    ELSEIF salary_param > 40000 THEN
        SET rating = 'Average';
    ELSE
        SET rating = 'Needs Improvement';
    END IF;
    
    RETURN rating;
END //
DELIMITER ;

DELIMITER //
CREATE FUNCTION fn_dept_employee_count(dept_id_param INT)
RETURNS INT
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE emp_count INT;
    SELECT COUNT(*) INTO emp_count FROM employees WHERE dept_id = dept_id_param;
    RETURN emp_count;
END //
DELIMITER ;

DELIMITER //
CREATE FUNCTION fn_years_of_service(hire_date_param DATE)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN FLOOR(DATEDIFF(CURDATE(), hire_date_param) / 365);
END //
DELIMITER ;

DELIMITER //
CREATE FUNCTION fn_format_phone(phone_param VARCHAR(20))
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE formatted_phone VARCHAR(20);
    
    IF phone_param IS NULL OR LENGTH(phone_param) = 0 THEN
        RETURN 'N/A';
    END IF;
    
    IF LENGTH(phone_param) = 10 THEN
        SET formatted_phone = CONCAT(
            SUBSTRING(phone_param, 1, 3), '-',
            SUBSTRING(phone_param, 4, 3), '-',
            SUBSTRING(phone_param, 7, 4)
        );
    ELSE
        SET formatted_phone = phone_param;
    END IF;
    
    RETURN formatted_phone;
END //
DELIMITER ;

DELIMITER //
CREATE FUNCTION fn_avg_dept_salary(dept_id_param INT)
RETURNS DECIMAL(10,2)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE avg_salary DECIMAL(10,2);
    SELECT AVG(salary) INTO avg_salary FROM employees WHERE dept_id = dept_id_param;
    RETURN IFNULL(avg_salary, 0);
END //
DELIMITER ;

DELIMITER //
CREATE FUNCTION fn_safe_division(numerator DECIMAL(12,2), denominator DECIMAL(12,2))
RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
    IF denominator = 0 THEN
        RETURN 0;
    END IF;
    RETURN numerator / denominator;
END //
DELIMITER ;

DELIMITER //
CREATE FUNCTION fn_calculate_bonus(
    base_salary DECIMAL(10,2), 
    performance_rating VARCHAR(20), 
    years_service INT
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE bonus_percentage DECIMAL(5,2);
    DECLARE bonus_amount DECIMAL(10,2);
    
    CASE performance_rating
        WHEN 'Excellent' THEN SET bonus_percentage = 0.15;
        WHEN 'Good' THEN SET bonus_percentage = 0.10;
        WHEN 'Average' THEN SET bonus_percentage = 0.05;
        ELSE SET bonus_percentage = 0.02;
    END CASE;
    
    -- Add loyalty bonus
    IF years_service >= 10 THEN
        SET bonus_percentage = bonus_percentage + 0.05;
    ELSEIF years_service >= 5 THEN
        SET bonus_percentage = bonus_percentage + 0.02;
    END IF;
    
    SET bonus_amount = base_salary * bonus_percentage;
    RETURN bonus_amount;
END //
DELIMITER ;

DELIMITER //
CREATE FUNCTION fn_customer_total_spent(customer_id_param INT)
RETURNS DECIMAL(12,2)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE total_spent DECIMAL(12,2);
    
    SELECT COALESCE(SUM(od.unit_price * od.quantity), 0) INTO total_spent
    FROM orders o
    JOIN order_details od ON o.order_id = od.order_id
    WHERE o.customer_id = customer_id_param;
    
    RETURN total_spent;
END //
DELIMITER ;

DELIMITER //
CREATE FUNCTION fn_product_availability(product_id_param INT)
RETURNS VARCHAR(50)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE stock_qty INT;
    DECLARE reorder_qty INT;
    DECLARE discontinued BOOLEAN;
    DECLARE status VARCHAR(50);
    
    SELECT stock_quantity, reorder_level, is_discontinued 
    INTO stock_qty, reorder_qty, discontinued
    FROM products WHERE product_id = product_id_param;
    
    IF discontinued THEN
        SET status = 'Discontinued';
    ELSEIF stock_qty = 0 THEN
        SET status = 'Out of Stock';
    ELSEIF stock_qty <= reorder_qty THEN
        SET status = 'Low Stock';
    ELSE
        SET status = 'Available';
    END IF;
    
    RETURN status;
END //
DELIMITER ;

DELIMITER //
CREATE FUNCTION fn_compound_interest(
    principal DECIMAL(12,2), 
    rate DECIMAL(8,4), 
    years INT, 
    compounds_per_year INT
)
RETURNS DECIMAL(15,2)
DETERMINISTIC
BEGIN
    DECLARE result DECIMAL(15,2);
    SET result = principal * POWER(1 + (rate / compounds_per_year), years * compounds_per_year);
    RETURN result;
END //
DELIMITER ;

DELIMITER //
CREATE FUNCTION fn_employee_to_json(emp_id_param INT)
RETURNS JSON
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE emp_json JSON;
    
    SELECT JSON_OBJECT(
        'id', emp_id,
        'name', CONCAT(first_name, ' ', last_name),
        'email', email,
        'job_title', job_title,
        'salary', salary,
        'department', (SELECT dept_name FROM departments WHERE dept_id = employees.dept_id)
    ) INTO emp_json
    FROM employees WHERE emp_id = emp_id_param;
    
    RETURN emp_json;
END //
DELIMITER ;

DELIMITER //
CREATE FUNCTION fn_generate_employee_code(first_name_param VARCHAR(50), last_name_param VARCHAR(50), emp_id_param INT)
RETURNS VARCHAR(10)
DETERMINISTIC
BEGIN
    DECLARE code VARCHAR(10);
    SET code = CONCAT(
        UPPER(SUBSTRING(first_name_param, 1, 2)),
        UPPER(SUBSTRING(last_name_param, 1, 2)),
        LPAD(emp_id_param, 6, '0')
    );
    RETURN code;
END //
DELIMITER ;

DELIMITER //
CREATE FUNCTION fn_budget_utilization(dept_id_param INT)
RETURNS DECIMAL(5,2)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE total_budget DECIMAL(12,2);
    DECLARE total_salaries DECIMAL(12,2);
    DECLARE utilization DECIMAL(5,2);
    
    SELECT budget INTO total_budget FROM departments WHERE dept_id = dept_id_param;
    SELECT COALESCE(SUM(salary), 0) INTO total_salaries FROM employees WHERE dept_id = dept_id_param;
    
    IF total_budget = 0 THEN
        RETURN 0;
    END IF;
    
    SET utilization = (total_salaries / total_budget) * 100;
    RETURN utilization;
END //
DELIMITER ;

-- Usage examples:
-- SELECT fn_get_full_name('John', 'Doe') AS full_name;
-- SELECT fn_annual_salary(5000, 0.10) AS annual_salary;
-- SELECT fn_performance_rating(75000, 3) AS rating;
-- SELECT fn_dept_employee_count(1) AS emp_count;
-- SELECT fn_years_of_service('2020-01-15') AS years_service;
-- SELECT fn_format_phone('1234567890') AS formatted_phone;
-- SELECT fn_avg_dept_salary(1) AS avg_salary;
-- SELECT fn_safe_division(100, 5) AS result;
-- SELECT fn_calculate_bonus(60000, 'Good', 4) AS bonus;
-- SELECT fn_customer_total_spent(1) AS total_spent;
-- SELECT fn_product_availability(1) AS status;
-- SELECT fn_compound_interest(10000, 0.05, 10, 12) AS future_value;
-- SELECT fn_employee_to_json(1) AS employee_json;
-- SELECT fn_generate_employee_code('John', 'Doe', 123) AS emp_code;
-- SELECT fn_budget_utilization(1) AS utilization_pct;
