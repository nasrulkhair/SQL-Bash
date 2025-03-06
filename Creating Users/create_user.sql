-- Create the user
CREATE USER etl WITH PASSWORD '1234';

--Grant database access
GRANT CONNECT ON DATABASE dvdrental TO etl;

--Grant table permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO etl;