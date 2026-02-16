
SELECT 
    CURDATE() AS current_date,
    CURTIME() AS current_time,
    NOW() AS current_datetime,
    SYSDATE() AS system_date;

SELECT 
    first_name,
    hire_date,
    YEAR(hire_date) AS hire_year,
    MONTH(hire_date) AS hire_month,
    DAY(hire_date) AS hire_day,
    QUARTER(hire_date) AS hire_quarter,
    WEEK(hire_date) AS hire_week,
    DAYOFWEEK(hire_date) AS day_of_week,
    DAYNAME(hire_date) AS day_name,
    MONTHNAME(hire_date) AS month_name
FROM employees
WHERE emp_id <= 5;

SELECT 
    first_name,
    hire_date,
    DATEDIFF(CURDATE(), hire_date) AS days_employed,
    TIMESTAMPDIFF(YEAR, hire_date, CURDATE()) AS years_employed,
    TIMESTAMPDIFF(MONTH, hire_date, CURDATE()) AS months_employed,
    DATE_ADD(hire_date, INTERVAL 5 YEAR) AS five_year_anniversary,
    DATE_SUB(CURDATE(), INTERVAL 30 DAY) AS thirty_days_ago
FROM employees
WHERE emp_id <= 5;

SELECT 
    order_date,
    DATE_FORMAT(order_date, '%Y-%m-%d') AS format_1,
    DATE_FORMAT(order_date, '%M %d, %Y') AS format_2,
    DATE_FORMAT(order_date, '%W, %M %e, %Y') AS format_3,
    DATE_FORMAT(order_date, '%d/%m/%Y') AS format_4,
    DATE_FORMAT(order_date, '%b %d, %y') AS format_5
FROM orders
WHERE order_id <= 5;

SELECT 
    first_name,
    UPPER(first_name) AS uppercase,
    LOWER(first_name) AS lowercase,
    INITCAP(first_name) AS initcap,
    LENGTH(first_name) AS name_length,
    CHAR_LENGTH(first_name) AS char_length
FROM employees
WHERE emp_id <= 5;

SELECT 
    product_name,
    SUBSTRING(product_name, 1, 5) AS first_5_chars,
    SUBSTRING(product_name, -3) AS last_3_chars,
    LEFT(product_name, 3) AS left_3,
    RIGHT(product_name, 3) AS right_3,
    INSTR(product_name, 'Pro') AS position_of_pro,
    LOCATE('Pro', product_name) AS locate_pro
FROM products
WHERE product_id <= 5;

SELECT 
    email,
    LTRIM('  hello world  ') AS left_trim,
    RTRIM('  hello world  ') AS right_trim,
    TRIM('  hello world  ') AS trim_all,
    LPAD('123', 8, '0') AS left_pad,
    RPAD('ABC', 8, 'X') AS right_pad
FROM customers
WHERE customer_id <= 3;

SELECT 
    product_name,
    REPLACE(product_name, 'Pro', 'Professional') AS replaced,
    INSERT(product_name, 3, 2, 'XX') AS inserted,
    CONCAT('Product: ', product_name) AS concatenated
FROM products
WHERE product_id <= 5;

SELECT 
    first_name,
    last_name,
    CONCAT(first_name, ' ', last_name) AS full_name,
    POSITION('John' IN CONCAT(first_name, ' ', last_name)) AS john_position,
    STRCMP(first_name, 'John') AS compare_to_john,
    CONCAT_WS('-', first_name, last_name, email) AS name_email_dash
FROM employees
WHERE emp_id <= 5;

SELECT 
    email,
    REGEXP_LIKE(email, '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$') AS is_valid_email,
    REGEXP_INSTR(email, '@') AS at_position,
    REGEXP_SUBSTR(email, '[^@]+') AS username_part,
    REGEXP_REPLACE(email, '@.*$', '@example.com') AS masked_email
FROM customers
WHERE customer_id <= 5;

SELECT 
    order_date,
    shipped_date,
    TIMESTAMP(order_date, '10:30:00') AS order_with_time,
    MAKETIME(14, 30, 45) AS custom_time,
    STR_TO_DATE('2023-12-25', '%Y-%m-%d') AS parsed_date,
    TIME_TO_SEC('02:30:00') AS seconds_from_time
FROM orders
WHERE order_id <= 5;

SELECT 
    NOW() AS current_timestamp,
    UNIX_TIMESTAMP() AS unix_timestamp,
    FROM_UNIXTIME(UNIX_TIMESTAMP()) AS from_unix,
    TIMESTAMPADD(SECOND, 3600, NOW()) AS plus_one_hour,
    TIMESTAMPDIFF(HOUR, '2023-01-01', NOW()) AS hours_since_new_year;

SELECT 
    order_date,
    order_date + INTERVAL 7 DAY AS delivery_date,
    WEEKDAY(order_date) AS day_of_week_num,
    CASE 
        WHEN WEEKDAY(order_date) >= 5 THEN order_date + INTERVAL (8 - WEEKDAY(order_date)) DAY
        ELSE order_date + INTERVAL 1 DAY
    END AS next_business_day
FROM orders
WHERE order_id <= 5;

SELECT 
    first_name,
    last_name,
    date_of_birth,
    TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) AS age,
    TIMESTAMPDIFF(MONTH, date_of_birth, CURDATE()) AS age_in_months,
    DAYOFYEAR(date_of_birth) AS day_of_year,
    CASE 
        WHEN DAYOFYEAR(date_of_birth) <= DAYOFYEAR(CURDATE()) 
        THEN TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE())
        ELSE TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) - 1
    END AS exact_age
FROM students
WHERE date_of_birth IS NOT NULL
LIMIT 5;

SELECT 
    dept_id,
    GROUP_CONCAT(first_name ORDER BY first_name SEPARATOR ', ') AS employee_names,
    GROUP_CONCAT(DISTINCT job_title ORDER BY job_title SEPARATOR ' | ') AS job_titles,
    COUNT(*) AS employee_count
FROM employees
GROUP BY dept_id
ORDER BY dept_id;

SELECT 
    product_name,
    REVERSE(product_name) AS reversed_name,
    REPEAT(product_name, 2) AS repeated_name,
    SPACE(5) AS five_spaces,
    CONCAT('Hello', SPACE(2), 'World') AS hello_world
FROM products
WHERE product_id <= 3;

SELECT 
    order_id,
    order_date,
    required_date,
    shipped_date,
    DATEDIFF(required_date, order_date) AS required_days,
    DATEDIFF(shipped_date, order_date) AS actual_days,
    CASE 
        WHEN shipped_date IS NULL THEN 'Not Shipped'
        WHEN DATEDIFF(shipped_date, required_date) <= 0 THEN 'On Time'
        ELSE CONCAT('Late by ', DATEDIFF(shipped_date, required_date), ' days')
    END AS shipping_status
FROM orders
WHERE order_id <= 10;

SELECT 
    email,
    TRIM(BOTH ' ' FROM email) AS trimmed_email,
    REPLACE(email, ' ', '') AS no_spaces,
    LOWER(TRIM(email)) AS clean_email,
    CASE 
        WHEN email REGEXP '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$' 
        THEN 'Valid'
        ELSE 'Invalid'
    END AS email_validation
FROM customers
WHERE customer_id <= 5;

SELECT 
    order_date,
    DATE_FORMAT(order_date, '%Y-%m') AS year_month,
    DATE_FORMAT(order_date, '%b %Y') AS month_year,
    DATE_FORMAT(order_date, '%W, %M %e, %Y') AS full_date,
    DATE_FORMAT(order_date, '%d-%b-%y') AS short_date,
    DAYOFMONTH(order_date) AS day,
    MONTHNAME(order_date) AS month_name,
    YEAR(order_date) AS year
FROM orders
WHERE order_id <= 5;

SELECT 
    product_name,
    CASE 
        WHEN product_name LIKE '%Laptop%' THEN 'Laptop Category'
        WHEN product_name LIKE '%Mouse%' THEN 'Mouse Category'
        WHEN product_name LIKE '%Desk%' THEN 'Furniture Category'
        ELSE 'Other Category'
    END AS product_category,
    REGEXP_REPLACE(product_name, '[0-9]', '') AS name_without_numbers,
    LENGTH(REGEXP_REPLACE(product_name, '[^a-zA-Z]', '')) AS letter_count
FROM products
WHERE product_id <= 10;

SELECT 
    order_date,
    FIRST_DAY(order_date) AS first_day_of_month,
    LAST_DAY(order_date) AS last_day_of_month,
    DAYOFMONTH(LAST_DAY(order_date)) AS days_in_month,
    DATE_FORMAT(order_date, '%Y-%m-01') AS month_start,
    DATE_FORMAT(LAST_DAY(order_date), '%Y-%m-%d') AS month_end
FROM orders
WHERE order_id <= 5;

SELECT 
    first_name,
    last_name,
    CONCAT(UPPER(SUBSTRING(first_name, 1, 1)), LOWER(SUBSTRING(first_name, 2))) AS formatted_first,
    CONCAT(UPPER(SUBSTRING(last_name, 1, 1)), LOWER(SUBSTRING(last_name, 2))) AS formatted_last,
    CONCAT(UPPER(SUBSTRING(first_name, 1, 1)), '. ', UPPER(SUBSTRING(last_name, 1, 1)), '.') AS initials,
    CONCAT(first_name, ' ', SUBSTRING(last_name, 1, 1), '.') AS first_last_initial
FROM employees
WHERE emp_id <= 5;

SELECT 
    order_date,
    YEAR(order_date) AS calendar_year,
    QUARTER(order_date) AS calendar_quarter,
    CASE 
        WHEN MONTH(order_date) BETWEEN 1 AND 3 THEN CONCAT(YEAR(order_date) - 1, '-Q4')
        WHEN MONTH(order_date) BETWEEN 4 AND 6 THEN CONCAT(YEAR(order_date), '-Q1')
        WHEN MONTH(order_date) BETWEEN 7 AND 9 THEN CONCAT(YEAR(order_date), '-Q2')
        ELSE CONCAT(YEAR(order_date), '-Q3')
    END AS fiscal_quarter,
    CASE 
        WHEN MONTH(order_date) BETWEEN 1 AND 6 THEN 'H1'
        ELSE 'H2'
    END AS half_year
FROM orders
WHERE order_id <= 10;

SELECT 
    phone,
    CASE 
        WHEN phone IS NULL THEN 'Missing'
        WHEN phone REGEXP '^[0-9]{10}$' THEN 'Valid 10-digit'
        WHEN phone REGEXP '^[0-9]{3}-[0-9]{3}-[0-9]{4}$' THEN 'Valid formatted'
        WHEN phone REGEXP '^\\([0-9]{3}\\) [0-9]{3}-[0-9]{4}$' THEN 'Valid with area code'
        ELSE 'Invalid format'
    END AS phone_validation,
    REGEXP_REPLACE(phone, '[^0-9]', '') AS digits_only,
    CASE 
        WHEN LENGTH(REGEXP_REPLACE(phone, '[^0-9]', '')) = 10 THEN '10 digits'
        ELSE 'Not 10 digits'
    END AS digit_count
FROM customers
WHERE phone IS NOT NULL
LIMIT 5;

SELECT 
    e.first_name,
    e.last_name,
    e.hire_date,
    CONCAT('Employee: ', e.first_name, ' ', e.last_name) AS employee_label,
    CONCAT('Hired: ', DATE_FORMAT(e.hire_date, '%M %d, %Y')) AS hire_label,
    CONCAT('Tenure: ', TIMESTAMPDIFF(YEAR, e.hire_date, CURDATE()), ' years, ',
           TIMESTAMPDIFF(MONTH, e.hire_date, CURDATE()) % 12, ' months') AS tenure_label,
    CASE 
        WHEN TIMESTAMPDIFF(YEAR, e.hire_date, CURDATE()) >= 5 
        THEN CONCAT('Veteran (', DATE_FORMAT(e.hire_date, '%Y'), ')')
        ELSE CONCAT('Recent (', DATE_FORMAT(e.hire_date, '%Y'), ')')
    END AS experience_category
FROM employees e
WHERE emp_id <= 5;

SELECT 
    JSON_OBJECT('name', CONCAT(first_name, ' ', last_name), 
                'email', email, 
                'hire_date', DATE_FORMAT(hire_date, '%Y-%m-%d')) AS employee_json,
    JSON_EXTRACT(JSON_OBJECT('name', CONCAT(first_name, ' ', last_name)), '$.name') AS name_from_json
FROM employees
WHERE emp_id <= 3;

SELECT 
    product_name,
    CASE 
        WHEN product_name REGEXP '(?i)laptop|notebook' THEN 'Portable Computer'
        WHEN product_name REGEXP '(?i)mouse|trackpad' THEN 'Pointing Device'
        WHEN product_name REGEXP '(?i)keyboard|keypad' THEN 'Input Device'
        WHEN product_name REGEXP '(?i)monitor|display' THEN 'Display Device'
        ELSE 'Other Device'
    END AS device_type,
    REGEXP_INSTR(product_name, '[0-9]') AS first_digit_position,
    IF(REGEXP_INSTR(product_name, '[0-9]') > 0, 
       SUBSTRING(product_name, REGEXP_INSTR(product_name, '[0-9]')), 
       'No Numbers') AS number_part
FROM products
WHERE product_id <= 10;

SELECT 
    NOW() AS local_time,
    CONVERT_TZ(NOW(), '+00:00', '+05:30') AS ist_time,
    CONVERT_TZ(NOW(), '+00:00', '-08:00') AS pst_time,
    UTC_TIMESTAMP() AS utc_time,
    TIMESTAMP(NOW()) AS timestamp_now
FROM DUAL;

SELECT 
    emp_id,
    first_name,
    last_name,
    UPPER(CONCAT(SUBSTRING(first_name, 1, 2), SUBSTRING(last_name, 1, 2), 
                 LPAD(emp_id, 4, '0'))) AS employee_code,
    CONCAT('EMP-', YEAR(hire_date), '-', LPAD(emp_id, 6, '0')) AS formal_code,
    MD5(CONCAT(first_name, last_name, emp_id)) AS hash_code
FROM employees
WHERE emp_id <= 5;

SELECT 
    order_date,
    order_date + INTERVAL 1 DAY AS next_day,
    order_date + INTERVAL 1 WEEK AS next_week,
    order_date + INTERVAL 1 MONTH AS next_month,
    order_date + INTERVAL 1 QUARTER AS next_quarter,
    order_date + INTERVAL 1 YEAR AS next_year,
    LAST_DAY(order_date) AS month_end,
    DATE_ADD(order_date, INTERVAL WEEKDAY(order_date) DAY) AS week_start,
    DATE_ADD(order_date, INTERVAL (6 - WEEKDAY(order_date)) DAY) AS week_end
FROM orders
WHERE order_id <= 5;
