CREATE TABLE permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    key TEXT NOT NULL UNIQUE CHECK (key ~ '^[a-z0-9_]+$'), -- Enforcing snake_case
    name TEXT NOT NULL,
    description TEXT NOT NULL
);

CREATE TRIGGER permissions_audit_trigger
AFTER INSERT OR UPDATE OR DELETE ON permissions
FOR EACH ROW EXECUTE FUNCTION log_changes();
