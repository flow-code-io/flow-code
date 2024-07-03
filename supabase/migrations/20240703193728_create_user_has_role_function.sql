CREATE OR REPLACE FUNCTION user_has_role(user_id UUID, organization_id UUID, role_key TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM user_organization_roles uor
        JOIN roles r ON uor.role_id = r.id
        WHERE uor.user_id = user_id
        AND uor.organization_id = organization_id
        AND r.key = role_key
    );
END;
$$ LANGUAGE plpgsql;
