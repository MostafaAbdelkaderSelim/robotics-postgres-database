-- Indexes

-- Sales/Core indexes
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_order_date ON orders(order_date);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
CREATE INDEX idx_invoices_order_id ON invoices(order_id);
CREATE INDEX idx_payments_invoice_id ON payments(invoice_id);
CREATE INDEX idx_customers_email ON customers(email);

-- Manufacturing indexes
CREATE INDEX idx_lines_factory_id ON production_lines(factory_id);
CREATE INDEX idx_stations_line_id ON stations(line_id);
CREATE INDEX idx_robots_current_station_id ON robots(current_station_id);
CREATE INDEX idx_robot_tasks_robot_id ON robot_tasks(robot_id);
CREATE INDEX idx_work_orders_line_id ON work_orders(line_id);
CREATE INDEX idx_work_order_operations_work_order_id ON work_order_operations(work_order_id);
CREATE INDEX idx_downtime_line_station ON downtime_events(line_id, station_id);
CREATE INDEX idx_sensor_readings_robot_time ON sensor_readings(robot_id, reading_time);
CREATE INDEX idx_alerts_status ON alerts(status);
CREATE INDEX idx_oee_line_date ON oee_metrics(line_id, metric_date);

-- Performance indexes
CREATE INDEX idx_robots_capabilities_gin ON robots USING GIN (capabilities);
CREATE INDEX idx_sensor_readings_data_gin ON sensor_readings USING GIN (data);
CREATE INDEX idx_alerts_active ON alerts(status) WHERE status = 'active';
CREATE INDEX idx_maintenance_tickets_open ON maintenance_tickets(status) WHERE status = 'open';
CREATE INDEX idx_robot_tasks_station_status ON robot_tasks(station_id, status, assigned_at);
CREATE INDEX idx_work_order_operations_status ON work_order_operations(work_order_id, status);