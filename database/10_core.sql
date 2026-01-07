-- Core tables: departments, employees, customers, products

-- departments
CREATE TABLE departments (
  department_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- employees
CREATE TABLE employees (
  employee_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  department_id INT NOT NULL REFERENCES departments(department_id) ON DELETE RESTRICT,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  phone VARCHAR(50),
  hire_date DATE NOT NULL DEFAULT CURRENT_DATE,
  job_title VARCHAR(100),
  salary NUMERIC(12,2) NOT NULL CHECK (salary >= 0),
  status VARCHAR(30) NOT NULL DEFAULT 'active' CHECK (status IN ('active','inactive','terminated')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- customers
CREATE TABLE customers (
  customer_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  email CITEXT NOT NULL UNIQUE,
  phone VARCHAR(50),
  address_line1 VARCHAR(255),
  address_line2 VARCHAR(255),
  city VARCHAR(100),
  country VARCHAR(100),
  postal_code VARCHAR(20),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- products
CREATE TABLE products (
  product_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  sku VARCHAR(100) NOT NULL UNIQUE,
  name VARCHAR(150) NOT NULL,
  description TEXT,
  unit_price NUMERIC(12,2) NOT NULL CHECK (unit_price >= 0),
  unit_in_stock INTEGER NOT NULL DEFAULT 0 CHECK (unit_in_stock >= 0),
  discontinued BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);