-- Manufacturing: execution entities

-- work_orders
CREATE TABLE work_orders (
  work_order_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  factory_id INT NOT NULL REFERENCES factories(factory_id) ON DELETE RESTRICT,
  line_id INT REFERENCES production_lines(line_id) ON DELETE SET NULL,
  product_id INT REFERENCES products(product_id) ON DELETE RESTRICT,
  quantity INT NOT NULL CHECK (quantity > 0),
  due_date DATE,
  priority VARCHAR(20) NOT NULL DEFAULT 'normal' CHECK (priority IN ('low','normal','high','urgent')),
  status VARCHAR(30) NOT NULL DEFAULT 'planned' CHECK (status IN ('planned','in_progress','paused','completed','cancelled')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- work_order_operations
CREATE TABLE work_order_operations (
  operation_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  work_order_id INT NOT NULL REFERENCES work_orders(work_order_id) ON DELETE CASCADE,
  station_id INT REFERENCES stations(station_id) ON DELETE SET NULL,
  task_type_id INT NOT NULL REFERENCES task_types(task_type_id) ON DELETE RESTRICT,
  sequence_no INT NOT NULL CHECK (sequence_no > 0),
  planned_start TIMESTAMPTZ,
  planned_end TIMESTAMPTZ,
  status VARCHAR(30) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','queued','running','completed','failed','skipped')),
  UNIQUE(work_order_id, sequence_no)
);

-- robot_tasks
CREATE TABLE robot_tasks (
  robot_task_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  robot_id INT NOT NULL REFERENCES robots(robot_id) ON DELETE CASCADE,
  operation_id INT REFERENCES work_order_operations(operation_id) ON DELETE SET NULL,
  station_id INT REFERENCES stations(station_id) ON DELETE SET NULL,
  task_type_id INT REFERENCES task_types(task_type_id) ON DELETE SET NULL,
  assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  started_at TIMESTAMPTZ,
  finished_at TIMESTAMPTZ,
  status VARCHAR(30) NOT NULL DEFAULT 'assigned' CHECK (status IN ('assigned','running','completed','failed','aborted')),
  notes TEXT
);