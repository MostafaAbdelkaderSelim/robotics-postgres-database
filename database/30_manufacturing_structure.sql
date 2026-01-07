-- Manufacturing: structure entities

-- factories
CREATE TABLE factories (
  factory_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name VARCHAR(150) NOT NULL UNIQUE,
  location VARCHAR(255),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- production_lines
CREATE TABLE production_lines (
  line_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  factory_id INT NOT NULL REFERENCES factories(factory_id) ON DELETE CASCADE,
  name VARCHAR(150) NOT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'idle' CHECK (status IN ('idle','running','stopped','maintenance')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(factory_id, name)
);

-- stations
CREATE TABLE stations (
  station_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  line_id INT NOT NULL REFERENCES production_lines(line_id) ON DELETE CASCADE,
  name VARCHAR(150) NOT NULL,
  station_type VARCHAR(50) NOT NULL CHECK (station_type IN ('assembly','welding','painting','testing','packaging','transport','other')),
  status VARCHAR(30) NOT NULL DEFAULT 'idle' CHECK (status IN ('idle','running','stopped','maintenance','fault')),
  position_order INT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(line_id, name)
);

-- robots
CREATE TABLE robots (
  robot_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  serial_number VARCHAR(100) NOT NULL UNIQUE,
  model VARCHAR(100) NOT NULL,
  vendor VARCHAR(100),
  commissioning_date DATE,
  status VARCHAR(30) NOT NULL DEFAULT 'available' CHECK (status IN ('available','assigned','maintenance','fault','retired')),
  current_station_id INT REFERENCES stations(station_id) ON DELETE SET NULL,
  ip_address INET,
  capabilities JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- task_types
CREATE TABLE task_types (
  task_type_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  description TEXT,
  standard_cycle_time_seconds INT CHECK (standard_cycle_time_seconds > 0)
);