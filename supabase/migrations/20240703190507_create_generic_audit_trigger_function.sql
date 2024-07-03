CREATE OR REPLACE FUNCTION log_changes()
RETURNS TRIGGER AS $$
DECLARE
    old_row JSONB;
    new_row JSONB;
BEGIN
    IF (TG_OP = 'DELETE') THEN
        old_row := row_to_json(OLD);
        new_row := NULL;
    ELSIF (TG_OP = 'INSERT') THEN
        old_row := NULL;
        new_row := row_to_json(NEW);
    ELSE
        old_row := row_to_json(OLD);
        new_row := row_to_json(NEW);
    END IF;

    INSERT INTO audit_log (table_name, operation, changed_by, old_values, new_values)
    VALUES (TG_TABLE_NAME, TG_OP, auth.uid(), old_row, new_row);

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;
