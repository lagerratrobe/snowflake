
-- 7.0.0   Access Control and User Management
--         Expect this lab to take approximately 40 minutes.
--         Lab Purpose: Students will work with the Snowflake security model and
--         learn how to create roles, grant privileges, build, and implement
--         basic security models.

-- 7.1.0   Determine Privileges (GRANTs)

-- 7.1.1   Navigate to [Worksheets] and create a new worksheet named Managing
--         Security.

-- 7.1.2   If you haven’t created the class database or warehouse, do it now

CREATE WAREHOUSE IF NOT EXISTS VIPER_WH;
CREATE DATABASE IF NOT EXISTS VIPER_DB;


-- 7.1.3   Run these commands to see what has been granted to you as a user, and
--         to your roles:

SHOW GRANTS TO USER VIPER;
SHOW GRANTS TO ROLE TRAINING_ROLE;
SHOW GRANTS TO ROLE SYSADMIN;
SHOW GRANTS TO ROLE SECURITYADMIN;

--         NOTE: The TRAINING_ROLE has some specific privileges granted - not
--         all roles in the system would be able to see these results.

-- 7.2.0   Work with Role Permissions

-- 7.2.1   Change your role to SECURITYADMIN:

USE ROLE SECURITYADMIN;


-- 7.2.2   Create two new custom roles, called VIPER_CLASSIFIED and
--         VIPER_GENERAL:

CREATE ROLE VIPER_CLASSIFIED;
CREATE ROLE VIPER_GENERAL;


-- 7.2.3   GRANT both roles to SYSADMIN, and to your user:

GRANT ROLE VIPER_CLASSIFIED, VIPER_GENERAL TO ROLE SYSADMIN;
GRANT ROLE VIPER_CLASSIFIED, VIPER_GENERAL TO USER VIPER;


-- 7.2.4   Change to the role SYSADMIN, so you can assign permissions to the
--         roles you created:

USE ROLE SYSADMIN;


-- 7.2.5   Create a warehouse named VIPER_SHARED_WH:

CREATE WAREHOUSE VIPER_SHARED_WH;


-- 7.2.6   Grant both new roles privileges to use the shared warehouse:

GRANT USAGE ON WAREHOUSE VIPER_SHARED_WH
  TO ROLE VIPER_CLASSIFIED;
GRANT USAGE ON WAREHOUSE VIPER_SHARED_WH
  TO ROLE VIPER_GENERAL;


-- 7.2.7   Create a database called VIPER_CLASSIFIED_DB:

CREATE DATABASE VIPER_CLASSIFIED_DB;


-- 7.2.8   Grant the role VIPER_CLASSIFIED all necessary privileges to create
--         tables on any schema in VIPER_CLASSIFIED_DB:

GRANT USAGE ON DATABASE VIPER_CLASSIFIED_DB
TO ROLE VIPER_CLASSIFIED;
GRANT USAGE ON ALL SCHEMAS IN DATABASE VIPER_CLASSIFIED_DB
TO ROLE VIPER_CLASSIFIED;
GRANT CREATE TABLE ON ALL SCHEMAS IN DATABASE VIPER_CLASSIFIED_DB
TO ROLE VIPER_CLASSIFIED;


-- 7.2.9   Use the role VIPER_CLASSIFIED, and create a table called
--         SUPER_SECRET_TBL inside the VIPER_CLASSIFIED_DB.PUBLIC schema:

USE ROLE VIPER_CLASSIFIED;
USE VIPER_CLASSIFIED_DB.PUBLIC;
CREATE TABLE SUPER_SECRET_TBL (id INT);


-- 7.2.10  Insert some data into the table:

INSERT INTO SUPER_SECRET_TBL VALUES (1), (10), (30);


-- 7.2.11  Assign GRANT SELECT privileges on SUPER_SECRET_TBL to the role
--         VIPER_GENERAL:

GRANT SELECT ON SUPER_SECRET_TBL TO ROLE VIPER_GENERAL;


-- 7.2.12  Use the role VIPER_GENERAL to SELECT * from the table
--         SUPER_SECRET_TBL:

USE ROLE VIPER_GENERAL;
SELECT * FROM VIPER_CLASSIFIED_DB.PUBLIC.SUPER_SECRET_TBL;

--         What happens? Why?

-- 7.2.13  Grant role VIPER_GENERAL usage on all schemas in
--         VIPER_CLASSIFIED_DB:

USE ROLE SYSADMIN;
GRANT USAGE ON DATABASE VIPER_CLASSIFIED_DB TO ROLE VIPER_GENERAL;
GRANT USAGE ON ALL SCHEMAs IN DATABASE VIPER_CLASSIFIED_DB TO ROLE VIPER_GENERAL;


-- 7.2.14  Now try again:

USE ROLE VIPER_GENERAL;
SELECT * FROM VIPER_CLASSIFIED_DB.PUBLIC.SUPER_SECRET_TBL;


-- 7.2.15  Drop the database VIPER_CLASSIFIED_DB:

USE ROLE SYSADMIN;
DROP DATABASE VIPER_CLASSIFIED_DB;


-- 7.2.16  Drop the roles VIPER_CLASSIFIED and VIPER_GENERAL:

USE ROLE SECURITYADMIN;
DROP ROLE VIPER_CLASSIFIED;
DROP ROLE VIPER_GENERAL;

--         HINT: What role do you need to use to do this?

-- 7.3.0   Create Parent and Child Roles

-- 7.3.1   Change your role to SECURITYADMIN:

USE ROLE SECURITYADMIN;


-- 7.3.2   Create a parent and child role, and GRANT the roles to the role
--         SYSADMIN. At this point, the roles are peers (neither one is below
--         the other in the hierarchy):

CREATE ROLE VIPER_child;
CREATE ROLE VIPER_parent;
GRANT ROLE VIPER_child, VIPER_parent TO ROLE SYSADMIN;


-- 7.3.3   Give your user name privileges to use the roles:

GRANT ROLE VIPER_child, VIPER_parent TO USER VIPER;


-- 7.3.4   Change your role to SYSADMIN:

USE ROLE SYSADMIN;


-- 7.3.5   Grant the following object permissions to the child role:

GRANT USAGE ON WAREHOUSE VIPER_WH TO ROLE VIPER_child;
GRANT USAGE ON DATABASE VIPER_DB TO ROLE VIPER_child;
GRANT USAGE ON SCHEMA VIPER_DB.PUBLIC TO ROLE VIPER_child;
GRANT CREATE TABLE ON SCHEMA VIPER_DB.PUBLIC
   TO ROLE VIPER_child;


-- 7.3.6   Use the child role to create a table:

USE ROLE VIPER_child;
USE WAREHOUSE VIPER_WH;
USE DATABASE VIPER_DB;
USE SCHEMA VIPER_DB.PUBLIC;
CREATE TABLE genealogy (name STRING, age INTEGER, mother STRING,
   father STRING);


-- 7.3.7   Verify that you can see the table:

SHOW TABLES LIKE '%genealogy%';


-- 7.3.8   Use the parent role and view the table:

USE ROLE VIPER_parent;
SHOW TABLES LIKE '%genealogy%';

--         You will not see the table, because the parent role has not been
--         granted access.

-- 7.3.9   Change back to the SECURITYADMIN role and change the hierarchy so the
--         child role is beneath the parent role:

USE ROLE SECURITYADMIN;
GRANT ROLE VIPER_child to ROLE VIPER_parent;


-- 7.3.10  Use the parent role, and verify the parent can now see the table
--         created by the child:

USE ROLE VIPER_parent;
SHOW TABLES LIKE '%genealogy%';


-- 7.3.11  Suspend and resize the warehouse

USE ROLE TRAINING_ROLE;
ALTER WAREHOUSE VIPER_WH SET WAREHOUSE_SIZE=XSmall;
ALTER WAREHOUSE VIPER_WH SUSPEND;

