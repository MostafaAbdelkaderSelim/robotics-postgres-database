-- Trigger functions and triggers

-- Recalculate invoice totals on order_items changes
CREATE OR REPLACE FUNCTION fn_update_invoice_totals() RETURNS TRIGGER AS $$
DECLARE v_order_id INT;
BEGIN
  v_order_id = COALESCE(NEW.order_id, OLD.order_id);
  UPDATE invoices i
  SET subtotal = COALESCE((
        SELECT SUM(oi.quantity * oi.unit_price * (1 - oi.discount/100))
        FROM order_items oi
        WHERE oi.order_id = v_order_id
      ), 0),
      total = COALESCE((
        SELECT SUM(oi.quantity * oi.unit_price * (1 - oi.discount/100))
        FROM order_items oi
        WHERE oi.order_id = v_order_id
      ), 0) + i.tax
  WHERE i.order_id = v_order_id;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_recalc_invoice_totals
AFTER INSERT OR UPDATE OR DELETE ON order_items
FOR EACH ROW
EXECUTE FUNCTION fn_update_invoice_totals();

-- Set unit_price from product if not provided
CREATE OR REPLACE FUNCTION fn_set_unit_price() RETURNS TRIGGER AS $$
BEGIN
  IF NEW.unit_price IS NULL THEN
    SELECT p.unit_price INTO NEW.unit_price FROM products p WHERE p.product_id = NEW.product_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_unit_price
BEFORE INSERT ON order_items
FOR EACH ROW
EXECUTE FUNCTION fn_set_unit_price();

-- Validate payment not exceeding invoice total
CREATE OR REPLACE FUNCTION fn_validate_payment() RETURNS TRIGGER AS $$
DECLARE v_total NUMERIC(12,2);
DECLARE v_paid NUMERIC(12,2);
BEGIN
  SELECT total INTO v_total FROM invoices WHERE invoice_id = NEW.invoice_id FOR UPDATE;
  SELECT COALESCE(SUM(amount) FILTER (WHERE status='completed'),0) INTO v_paid FROM payments WHERE invoice_id = NEW.invoice_id;
  IF (v_paid + NEW.amount) > v_total THEN
    RAISE EXCEPTION 'Payment exceeds invoice total';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_payment
BEFORE INSERT ON payments
FOR EACH ROW
EXECUTE FUNCTION fn_validate_payment();