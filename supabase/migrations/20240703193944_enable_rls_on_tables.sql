-- Enable and Configure RLS for Organizations
ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Create organizations only by authenticated users"
ON organizations FOR INSERT
TO authenticated
USING (true);

CREATE POLICY "Select organizations based on roles"
ON organizations FOR SELECT
USING (
    EXISTS (
        SELECT 1
        FROM user_organization_roles
        WHERE user_id = auth.uid() AND organization_id = organizations.id
    )
);

ALTER TABLE organizations FORCE ROW LEVEL SECURITY;

-- Enable and Configure RLS for Roles
ALTER TABLE roles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Select roles based on organization roles"
ON roles FOR SELECT
USING (
    EXISTS (
        SELECT 1
        FROM user_organization_roles
        WHERE user_id = auth.uid() AND organization_id = roles.organization_id
    )
);

ALTER TABLE roles FORCE ROW LEVEL SECURITY;

-- Enable and Configure RLS for Permissions
ALTER TABLE permissions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Select permissions based on roles"
ON permissions FOR SELECT
USING (
    EXISTS (
        SELECT 1
        FROM role_permissions
        JOIN roles ON role_permissions.role_id = roles.id
        JOIN user_organization_roles ON user_organization_roles.role_id = roles.id
        WHERE user_organization_roles.user_id = auth.uid()
    )
);

ALTER TABLE permissions FORCE ROW LEVEL SECURITY;

-- Enable and Configure RLS for Role Permissions
ALTER TABLE role_permissions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Select role_permissions based on user roles"
ON role_permissions FOR SELECT
USING (
    EXISTS (
        SELECT 1
        FROM user_organization_roles
        WHERE user_id = auth.uid() AND role_id = role_permissions.role_id
    )
);

ALTER TABLE role_permissions FORCE ROW LEVEL SECURITY;

-- Enable and Configure RLS for User Organization Roles
ALTER TABLE user_organization_roles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Select user_organization_roles based on user"
ON user_organization_roles FOR SELECT
USING (user_id = auth.uid());

ALTER TABLE user_organization_roles FORCE ROW LEVEL SECURITY;

-- Enable and Configure RLS for Projects
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Select projects based on organization roles"
ON projects FOR SELECT
USING (
    EXISTS (
        SELECT 1
        FROM user_organization_roles
        WHERE user_id = auth.uid() AND organization_id = projects.organization_id
    )
);

CREATE POLICY "Insert, update, delete projects based on permissions"
ON projects FOR INSERT, UPDATE, DELETE
USING (
    EXISTS (
        SELECT 1
        FROM user_organization_roles
        JOIN role_permissions ON user_organization_roles.role_id = role_permissions.role_id
        JOIN permissions ON role_permissions.permission_id = permissions.id
        WHERE user_organization_roles.user_id = auth.uid()
        AND user_organization_roles.organization_id = projects.organization_id
        AND permissions.key IN ('create_project', 'update_project', 'delete_project')
    )
);

ALTER TABLE projects FORCE ROW LEVEL SECURITY;

-- Enable and Configure RLS for Applications
ALTER TABLE applications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Select applications based on project roles"
ON applications FOR SELECT
USING (
    EXISTS (
        SELECT 1
        FROM projects
        JOIN user_organization_roles ON projects.organization_id = user_organization_roles.organization_id
        WHERE user_organization_roles.user_id = auth.uid()
        AND applications.project_id = projects.id
    )
);

CREATE POLICY "Insert, update, delete applications based on permissions"
ON applications FOR INSERT, UPDATE, DELETE
USING (
    EXISTS (
        SELECT 1
        FROM projects
        JOIN user_organization_roles ON projects.organization_id = user_organization_roles.organization_id
        JOIN role_permissions ON user_organization_roles.role_id = role_permissions.role_id
        JOIN permissions ON role_permissions.permission_id = permissions.id
        WHERE user_organization_roles.user_id = auth.uid()
        AND applications.project_id = projects.id
        AND permissions.key IN ('create_application', 'update_application', 'delete_application')
    )
);

ALTER TABLE applications FORCE ROW LEVEL SECURITY;

-- Enable and Configure RLS for Templates
ALTER TABLE templates ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Select templates for all authenticated users"
ON templates FOR SELECT
TO authenticated
USING (true);

ALTER TABLE templates FORCE ROW LEVEL SECURITY;

-- Enable and Configure RLS for Integrations
ALTER TABLE integrations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Select integrations based on application roles"
ON integrations FOR SELECT
USING (
    EXISTS (
        SELECT 1
        FROM applications
        JOIN projects ON applications.project_id = projects.id
        JOIN user_organization_roles ON projects.organization_id = user_organization_roles.organization_id
        WHERE user_organization_roles.user_id = auth.uid()
        AND integrations.application_id = applications.id
    )
);

CREATE POLICY "Insert, update, delete integrations based on permissions"
ON integrations FOR INSERT, UPDATE, DELETE
USING (
    EXISTS (
        SELECT 1
        FROM applications
        JOIN projects ON applications.project_id = projects.id
        JOIN user_organization_roles ON projects.organization_id = user_organization_roles.organization_id
        JOIN role_permissions ON user_organization_roles.role_id = role_permissions.role_id
        JOIN permissions ON role_permissions.permission_id = permissions.id
        WHERE user_organization_roles.user_id = auth.uid()
        AND integrations.application_id = applications.id
        AND permissions.key IN ('create_integration', 'update_integration', 'delete_integration')
    )
);

ALTER TABLE integrations FORCE ROW LEVEL SECURITY;
