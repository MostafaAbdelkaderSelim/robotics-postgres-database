-- Views

-- Order totals
CREATE OR REPLACE VIEW v_order_totals AS
SELECT
  oi.order_id,
  SUM(oi.quantity * oi.unit_price * (1 - oi.discount/100)) AS subtotal
FROM order_items oi
GROUP BY oi.order_id;

-- Downtime durations
CREATE OR REPLACE VIEW v_downtime_durations AS
SELECT
  event_id,
  line_id,
  station_id,
  robot_id,
  category,
  reason_code,
  start_time,
  end_time,
  EXTRACT(EPOCH FROM (COALESCE(end_time, NOW()) - start_time))::INT AS duration_seconds
FROM downtime_events;