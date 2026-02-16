
-- Create Database
CREATE DATABASE IF NOT EXISTS company_db;
USE company_db;

 -- Departments Table
 CREATE TABLE departments (
    dept_id INT PRIMARY KEY AUTO_INCREMENT,
    dept_name VARCHAR(100) NOT NULL,
    location VARCHAR(100),
    manager_id INT,
    budget DECIMAL(12,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

 -- Employees Table
      emp_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    hire_date DATE NOT NULL,
    job_title VARCHAR(100) NOT NULL,
    salary DECIMAL(10,2) NOT NULL,
    commission_pct DECIMAL(5,2),
    dept_id INT,
    manager_id INT,
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id),
    FOREIGN KEY (manager_id) REFERENCES employees(emp_id)
);

   CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
     last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    city VARCHAR(50),
    country VARCHAR(50),
    registration_date DATE NOT NULL,
    credit_limit DECIMAL(10,2),
    is_vip BOOLEAN DEFAULT FALSE
);

   CREATE TABLE products (
     product_name VARCHAR(100) NOT NULL,
      cost_price DECIMAL(10,2),
    stock_quantity INT DEFAULT 0,
    reorder_level INT DEFAULT 10,
    is_discontinued BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

 -- Orders Table
 CREATE TABLE orders (
     customer_id INT NOT NULL,
       ship_via VARCHAR(50),
    freight DECIMAL(10,2) DEFAULT 0,
    ship_name VARCHAR(100),
    ship_address TEXT,
    ship_city VARCHAR(50),
    ship_country VARCHAR(50),
    status ENUM('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled') DEFAULT 'Pending',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id)
);

   CREATE TABLE order_details (
      unit_price DECIMAL(10,2) NOT NULL,
   );

 -- Students Table
      student_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
      date_of_birth DATE,
       is_active BOOLEAN DEFAULT TRUE
);

 -- Courses Table
 CREATE TABLE courses (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
     course_name VARCHAR(100) NOT NULL,
    credits INT NOT NULL,
  
       enrollment_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    enrollment_date DATE NOT NULL,
    grade CHAR(2),
    status ENUM('Enrolled', 'Completed', 'Dropped', 'Withdrawn') DEFAULT 'Enrolled',
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id),
    UNIQUE KEY unique_enrollment (student_id, course_id)
);
    
-- Insert sample departments
INSERT INTO departments (dept_name, location, budget) VALUES
('Engineering', 'New York', 1000000.00),
('Sales', 'Chicago', 500000.00),
('Marketing', 'Los Angeles', 300000.00),
( ('Finance', 'Chicago', 400000.00);

-- Insert sample employees
INSERT INTO employees (first_name, last_name, email, hire_date, job_title, salary, dept_id) VALUES
( ('Jane', 'Doe', 'jane.doe@company.com', '2019-03-20', 'Sales Manager', 85000.00, 2),
 ('Sarah', 'Williams', 'sarah.williams@company.com', '2018-11-05', 'HR Manager', 70000.00, 4),
('David', 'Brown', 'david.brown@company.com', '2020-09-12', 'Financial Analyst', 65000.00, 5);
 -- Insert sample customers
INSERT INTO customers (first_name, last_name, email, registration_date, city, country) VALUES
('Alice', 'Cooper', 'alice@email.com', '2022-01-15', 'New York', 'USA'),
('Bob', 'Marley', 'bob@email.com', '2022-02-20', 'Los Angeles', 'USA'),
('Charlie', 'Brown', 'charlie@email.com', '2022-03-10', 'Chicago', 'USA'),
('Diana', 'Prince', 'diana@email.com', '2022-04-05', 'Boston', 'USA'),
('Eva', 'Green', 'eva@email.com', '2022-05-12', 'Seattle', 'USA');

-- Insert sample products
INSERT INTO products (product_name, category, unit_price, stock_quantity) VALUES
('Laptop Pro', 'Electronics', 999.99, 50),
('Wireless Mouse', 'Electronics', 29.99, 200),
('Office Chair', 'Furniture', 199.99, 30),
('Standing Desk', 'Furniture', 499.99, 15),
('Coffee Maker', 'Appliances', 89.99, 40);

-- Insert sample courses
INSERT INTO courses (course_code, course_name, credits, department) VALUES
('CS101', 'Introduction to Computer Science', 3, 'Computer Science'),
('MATH201', 'Calculus II', 4, 'Mathematics'),
('ENG101', 'English Literature', 3, 'English'),
('PHYS101', 'Physics I', 4, 'Physics'),
('CHEM101', 'General Chemistry', 4, 'Chemistry');

-- Insert sample students
INSERT INTO students (first_name, last_name, email, enrollment_date, major, gpa) VALUES
('Frank', 'Sinatra', 'frank@university.edu', '2021-09-01', 'Computer Science', 3.8),
('Grace', 'Kelly', 'grace@university.edu', '2021-09-01', 'Mathematics', 3.9),
('Henry', 'Ford', 'henry@university.edu', '2021-09-01', 'Engineering', 3.5),
('Iris', 'West', 'iris@university.edu', '2021-09-01', 'Physics', 3.7),
('Jack', 'Ryan', 'jack@university.edu', '2021-09-01', 'Chemistry', 3.6);
