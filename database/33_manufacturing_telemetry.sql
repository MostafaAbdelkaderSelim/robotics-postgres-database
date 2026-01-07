-- Manufacturing: telemetry and KPIs

-- downtime_events
CREATE TABLE downtime_events (
  event_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  line_id INT REFERENCES production_lines(line_id) ON DELETE SET NULL,
  station_id INT REFERENCES stations(station_id) ON DELETE SET NULL,
  robot_id INT REFERENCES robots(robot_id) ON DELETE SET NULL,
  category VARCHAR(30) NOT NULL CHECK (category IN ('planned','unplanned')),
  reason_code VARCHAR(50) NOT NULL,
  start_time TIMESTAMPTZ NOT NULL,
  end_time TIMESTAMPTZ,
  CHECK (end_time IS NULL OR end_time >= start_time)
);

-- sensor_readings
CREATE TABLE sensor_readings (
  reading_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  robot_id INT REFERENCES robots(robot_id) ON DELETE CASCADE,
  sensor_name VARCHAR(100) NOT NULL,
  value NUMERIC(18,6),
  unit VARCHAR(20),
  reading_time TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  data JSONB
);

-- alerts
CREATE TABLE alerts (
  alert_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  robot_id INT REFERENCES robots(robot_id) ON DELETE SET NULL,
  station_id INT REFERENCES stations(station_id) ON DELETE SET NULL,
  severity VARCHAR(20) NOT NULL CHECK (severity IN ('info','warning','error','critical')),
  message TEXT NOT NULL,
  raised_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  acknowledged_at TIMESTAMPTZ,
  status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active','acknowledged','resolved'))
);

-- shifts
CREATE TABLE shifts (
  shift_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  line_id INT NOT NULL REFERENCES production_lines(line_id) ON DELETE CASCADE,
  name VARCHAR(50) NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  CHECK (start_time <> end_time),
  UNIQUE(line_id, name)
);

-- oee_metrics
CREATE TABLE oee_metrics (
  oee_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  line_id INT NOT NULL REFERENCES production_lines(line_id) ON DELETE CASCADE,
  metric_date DATE NOT NULL,
  availability NUMERIC(5,4) NOT NULL CHECK (availability >= 0 AND availability <= 1),
  performance NUMERIC(5,4) NOT NULL CHECK (performance >= 0 AND performance <= 1),
  quality NUMERIC(5,4) NOT NULL CHECK (quality >= 0 AND quality <= 1),
  oee NUMERIC(5,4) GENERATED ALWAYS AS (availability * performance * quality) STORED,
  UNIQUE(line_id, metric_date)
);