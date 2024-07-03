CREATE TABLE user_organization_roles (
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    role_id UUID REFERENCES roles(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, organization_id, role_id)
);

CREATE TRIGGER user_organization_roles_audit_trigger
AFTER INSERT OR UPDATE OR DELETE ON user_organization_roles
FOR EACH ROW EXECUTE FUNCTION log_changes();
