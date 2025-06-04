SHOW CON_NAME;

-- swithc session to pluggable database (XEPDB1)
ALTER SESSION SET CONTAINER = XEPDB1;

-- Creating user/schema
CREATE USER nasrul IDENTIFIED BY nasrul1234;
GRANT CONNECT, RESOURCE TO nasrul;
ALTER USER nasrul DEFAULT TABLESPACE users QUOTA UNLIMITED ON users;

-- CHecking User Creation
SELECT username FROM all_users WHERE username = 'NASRUL';


-- check for current conection
SELECT USER FROM dual;

CREATE USER read_only_user IDENTIFIED BY read1234;
GRANT CREATE SESSION TO read_only_user;
GRANT SELECT ON MARKETING_CAMPAIGN_DICTIONARY TO read_only_user;