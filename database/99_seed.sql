-- Seed data for robotics schema
BEGIN;

-- Departments
INSERT INTO departments(name) VALUES
  ('Engineering'),
  ('Sales'),
  ('Maintenance')
ON CONFLICT(name) DO NOTHING;

-- Employees
INSERT INTO employees(department_id, first_name, last_name, email, phone, job_title, salary)
VALUES
  ((SELECT department_id FROM departments WHERE name='Engineering'), 'Mostafa', 'Selim', 'mostafa.selim@example.com', '01000000000', 'Data Engineer', 25000),
  ((SELECT department_id FROM departments WHERE name='Sales'), 'Sara', 'Adel', 'sara.adel@example.com', '01100000000', 'Account Manager', 18000),
  ((SELECT department_id FROM departments WHERE name='Maintenance'), 'Omar', 'Khaled', 'omar.khaled@example.com', '01200000000', 'Maintenance Lead', 20000)
ON CONFLICT(email) DO NOTHING;

-- Customers
INSERT INTO customers(first_name, last_name, email, phone, city, country)
VALUES
  ('Ahmed', 'Hassan', 'ahmed.hassan@example.com', '01500000000', 'Cairo', 'Egypt'),
  ('Laila', 'Nour', 'laila.nour@example.com', '01500000001', 'Giza', 'Egypt')
ON CONFLICT(email) DO NOTHING;

-- Products
INSERT INTO products(sku, name, description, unit_price, unit_in_stock)
VALUES
  ('RB-ARM-100', 'Robot Arm A100', '6-axis industrial robot arm', 120000.00, 10),
  ('CNV-BELT-50', 'Conveyor Belt 50m', 'Heavy duty conveyor belt', 35000.00, 25),
  ('SNS-TEMP-01', 'Temperature Sensor', 'High-precision temperature sensor', 900.00, 100)
ON CONFLICT(sku) DO NOTHING;

-- Orders
INSERT INTO orders(customer_id, employee_id, status, notes)
VALUES
  ((SELECT customer_id FROM customers WHERE email='ahmed.hassan@example.com'), (SELECT employee_id FROM employees WHERE email='sara.adel@example.com'), 'processing', 'Initial robotics order'),
  ((SELECT customer_id FROM customers WHERE email='laila.nour@example.com'), (SELECT employee_id FROM employees WHERE email='mostafa.selim@example.com'), 'pending', 'Sensors and conveyor belts')
RETURNING order_id;

-- Invoices (create with zero subtotal; trigger will recalc after items)
INSERT INTO invoices(order_id, due_date, subtotal, tax, total, status, currency)
SELECT order_id, NOW() + INTERVAL '14 days', 0, 500.00, 500.00, 'unpaid', 'USD' FROM orders
ON CONFLICT(order_id) DO NOTHING;

-- Order items (unit_price resolved by trigger if NULL)
INSERT INTO order_items(order_id, product_id, quantity, unit_price, discount)
VALUES
  ((SELECT order_id FROM orders ORDER BY order_id ASC LIMIT 1), (SELECT product_id FROM products WHERE sku='RB-ARM-100'), 1, NULL, 0),
  ((SELECT order_id FROM orders ORDER BY order_id ASC LIMIT 1), (SELECT product_id FROM products WHERE sku='SNS-TEMP-01'), 10, NULL, 5),
  ((SELECT order_id FROM orders ORDER BY order_id DESC LIMIT 1), (SELECT product_id FROM products WHERE sku='CNV-BELT-50'), 2, NULL, 0)
ON CONFLICT DO NOTHING;

-- A safe payment under invoice total
INSERT INTO payments(invoice_id, amount, method, status)
SELECT i.invoice_id, 1000.00, 'bank_transfer', 'completed'
FROM invoices i
JOIN orders o ON o.order_id = i.order_id
ORDER BY i.invoice_id ASC
LIMIT 1;

-- Manufacturing structure
INSERT INTO factories(name, location) VALUES ('Main Factory', 'Industrial Zone A')
ON CONFLICT(name) DO NOTHING;

INSERT INTO production_lines(factory_id, name, status)
VALUES ((SELECT factory_id FROM factories WHERE name='Main Factory'), 'Line-1', 'running')
ON CONFLICT(factory_id, name) DO NOTHING;

INSERT INTO stations(line_id, name, station_type, status, position_order)
VALUES
  ((SELECT line_id FROM production_lines WHERE name='Line-1'), 'Station-Assembly', 'assembly', 'running', 1),
  ((SELECT line_id FROM production_lines WHERE name='Line-1'), 'Station-Testing', 'testing', 'idle', 2)
ON CONFLICT(line_id, name) DO NOTHING;

INSERT INTO robots(serial_number, model, vendor, status, current_station_id, ip_address, capabilities)
VALUES
  ('SN-ARM-A100-001', 'A100', 'RoboCorp', 'available', (SELECT station_id FROM stations WHERE name='Station-Assembly'), '192.168.1.101', '{"payload_kg":10,"reach_mm":1200,"axes":6}'),
  ('SN-ARM-A100-002', 'A100', 'RoboCorp', 'available', (SELECT station_id FROM stations WHERE name='Station-Testing'), '192.168.1.102', '{"payload_kg":10,"reach_mm":1200,"axes":6}')
ON CONFLICT(serial_number) DO NOTHING;

INSERT INTO task_types(name, description, standard_cycle_time_seconds)
VALUES ('Pick-and-Place', 'Picking and placing parts', 30), ('Welding', 'Automated welding', 45)
ON CONFLICT(name) DO NOTHING;

-- Manufacturing execution
INSERT INTO work_orders(factory_id, line_id, product_id, quantity, due_date, priority, status)
VALUES ((SELECT factory_id FROM factories WHERE name='Main Factory'), (SELECT line_id FROM production_lines WHERE name='Line-1'), (SELECT product_id FROM products WHERE sku='RB-ARM-100'), 5, CURRENT_DATE + INTERVAL '7 days', 'high', 'in_progress')
RETURNING work_order_id;

INSERT INTO work_order_operations(work_order_id, station_id, task_type_id, sequence_no, planned_start, planned_end, status)
VALUES
  ((SELECT work_order_id FROM work_orders ORDER BY work_order_id DESC LIMIT 1), (SELECT station_id FROM stations WHERE name='Station-Assembly'), (SELECT task_type_id FROM task_types WHERE name='Pick-and-Place'), 1, NOW(), NOW() + INTERVAL '2 hours', 'running'),
  ((SELECT work_order_id FROM work_orders ORDER BY work_order_id DESC LIMIT 1), (SELECT station_id FROM stations WHERE name='Station-Testing'), (SELECT task_type_id FROM task_types WHERE name='Welding'), 2, NOW() + INTERVAL '2 hours', NOW() + INTERVAL '4 hours', 'pending');

INSERT INTO robot_tasks(robot_id, operation_id, station_id, task_type_id, assigned_at, status)
VALUES
  ((SELECT robot_id FROM robots WHERE serial_number='SN-ARM-A100-001'), (SELECT operation_id FROM work_order_operations WHERE sequence_no=1 ORDER BY operation_id DESC LIMIT 1), (SELECT station_id FROM stations WHERE name='Station-Assembly'), (SELECT task_type_id FROM task_types WHERE name='Pick-and-Place'), NOW(), 'running');

-- Telemetry and KPIs
INSERT INTO downtime_events(line_id, station_id, robot_id, category, reason_code, start_time, end_time)
VALUES ((SELECT line_id FROM production_lines WHERE name='Line-1'), (SELECT station_id FROM stations WHERE name='Station-Testing'), (SELECT robot_id FROM robots WHERE serial_number='SN-ARM-A100-002'), 'unplanned', 'sensor_fault', NOW() - INTERVAL '30 minutes', NOW() - INTERVAL '10 minutes');

INSERT INTO sensor_readings(robot_id, sensor_name, value, unit, reading_time, data)
VALUES ((SELECT robot_id FROM robots WHERE serial_number='SN-ARM-A100-001'), 'temperature', 55.3, 'C', NOW(), '{"raw":55.3,"status":"ok"}');

INSERT INTO alerts(robot_id, station_id, severity, message, raised_at, status)
VALUES ((SELECT robot_id FROM robots WHERE serial_number='SN-ARM-A100-002'), (SELECT station_id FROM stations WHERE name='Station-Testing'), 'warning', 'Temperature high threshold', NOW(), 'active');

INSERT INTO shifts(line_id, name, start_time, end_time)
VALUES ((SELECT line_id FROM production_lines WHERE name='Line-1'), 'Shift-A', '08:00', '16:00')
ON CONFLICT(line_id, name) DO NOTHING;

INSERT INTO oee_metrics(line_id, metric_date, availability, performance, quality)
VALUES ((SELECT line_id FROM production_lines WHERE name='Line-1'), CURRENT_DATE, 0.92, 0.88, 0.95)
ON CONFLICT(line_id, metric_date) DO NOTHING;

COMMIT;