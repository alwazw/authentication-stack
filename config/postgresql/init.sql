-- Create databases for different services
CREATE DATABASE authentik;
CREATE DATABASE pgadmin;

-- Create users with appropriate permissions
CREATE USER authentik_user WITH PASSWORD 'authentik_secure_password_2024';
CREATE USER pgadmin_user WITH PASSWORD 'pgadmin_secure_password_2024';

-- Grant permissions
GRANT ALL PRIVILEGES ON DATABASE authentik TO authentik_user;
GRANT ALL PRIVILEGES ON DATABASE pgadmin TO pgadmin_user;

-- Additional security settings
ALTER USER authentik_user CREATEDB;
ALTER USER pgadmin_user CREATEDB;

