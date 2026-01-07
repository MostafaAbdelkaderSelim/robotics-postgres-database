-- Manufacturing: maintenance entities

-- maintenance_tickets
CREATE TABLE maintenance_tickets (
  ticket_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  robot_id INT REFERENCES robots(robot_id) ON DELETE SET NULL,
  station_id INT REFERENCES stations(station_id) ON DELETE SET NULL,
  issue_code VARCHAR(50) NOT NULL,
  severity VARCHAR(20) NOT NULL CHECK (severity IN ('low','medium','high','critical')),
  status VARCHAR(30) NOT NULL DEFAULT 'open' CHECK (status IN ('open','in_progress','on_hold','resolved','closed','cancelled')),
  opened_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  closed_at TIMESTAMPTZ,
  opened_by_employee_id INT REFERENCES employees(employee_id) ON DELETE SET NULL,
  description TEXT
);

-- maintenance_logs
CREATE TABLE maintenance_logs (
  log_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  ticket_id INT NOT NULL REFERENCES maintenance_tickets(ticket_id) ON DELETE CASCADE,
  robot_id INT REFERENCES robots(robot_id) ON DELETE SET NULL,
  action VARCHAR(100) NOT NULL,
  performed_by_employee_id INT REFERENCES employees(employee_id) ON DELETE SET NULL,
  logged_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  notes TEXT
);