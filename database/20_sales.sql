-- Sales tables: orders, order_items, invoices, payments

-- orders
CREATE TABLE orders (
  order_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  customer_id INT NOT NULL REFERENCES customers(customer_id) ON DELETE RESTRICT,
  employee_id INT REFERENCES employees(employee_id) ON DELETE SET NULL,
  order_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  status VARCHAR(30) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','processing','shipped','delivered','cancelled','returned')),
  notes TEXT
);

-- order_items
CREATE TABLE order_items (
  order_id INT NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
  product_id INT NOT NULL REFERENCES products(product_id) ON DELETE RESTRICT,
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  unit_price NUMERIC(12,2) CHECK (unit_price >= 0),
  discount NUMERIC(5,2) NOT NULL DEFAULT 0 CHECK (discount >= 0 AND discount <= 100),
  PRIMARY KEY (order_id, product_id)
);

-- invoices
CREATE TABLE invoices (
  invoice_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  order_id INT NOT NULL UNIQUE REFERENCES orders(order_id) ON DELETE CASCADE,
  invoice_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  due_date TIMESTAMPTZ,
  subtotal NUMERIC(12,2) NOT NULL CHECK (subtotal >= 0),
  tax NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (tax >= 0),
  total NUMERIC(12,2) NOT NULL CHECK (total = subtotal + tax),
  status VARCHAR(20) NOT NULL DEFAULT 'unpaid' CHECK (status IN ('unpaid','paid','void')),
  currency VARCHAR(3) NOT NULL DEFAULT 'USD'
);

-- payments
CREATE TABLE payments (
  payment_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  invoice_id INT NOT NULL REFERENCES invoices(invoice_id) ON DELETE CASCADE,
  payment_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  amount NUMERIC(12,2) NOT NULL CHECK (amount > 0),
  method VARCHAR(30) NOT NULL CHECK (method IN ('cash','card','bank_transfer','paypal','other')),
  transaction_ref VARCHAR(100) UNIQUE,
  status VARCHAR(20) NOT NULL DEFAULT 'completed' CHECK (status IN ('pending','completed','failed'))
);