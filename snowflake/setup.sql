USE ROLE ACCOUNTADMIN;

-- ---------------------------------------------------------------------
-- 1. Warehouse: keep compute cheap (suspends after 60 seconds idle)
-- ---------------------------------------------------------------------
ALTER WAREHOUSE COMPUTE_WH SET
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND   = 60
  AUTO_RESUME    = TRUE;

USE WAREHOUSE COMPUTE_WH;

-- ---------------------------------------------------------------------
-- 2. Databases and schemas
--    DBT_LEARNING.RAW  = raw data loaded from S3
--    DBT_LEARNING.APPS = Streamlit app
--    WALMART_E2E       = where dbt builds the models (schema DBT_PETER)
-- ---------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS DBT_LEARNING;
CREATE SCHEMA   IF NOT EXISTS DBT_LEARNING.RAW;
CREATE SCHEMA   IF NOT EXISTS DBT_LEARNING.APPS;
CREATE DATABASE IF NOT EXISTS WALMART_E2E;

-- ---------------------------------------------------------------------
-- 3. Storage integration: Snowflake's secure link to the IAM role
-- ---------------------------------------------------------------------
CREATE STORAGE INTEGRATION IF NOT EXISTS s3_walmart_int
  TYPE                      = EXTERNAL_STAGE
  STORAGE_PROVIDER          = 'S3'
  ENABLED                   = TRUE
  STORAGE_AWS_ROLE_ARN      = '<ROLE_ARN>'
  STORAGE_ALLOWED_LOCATIONS = ('s3://<BUCKET>/walmart/');

-- Copy STORAGE_AWS_IAM_USER_ARN and STORAGE_AWS_EXTERNAL_ID from this output
-- into the IAM role's trust policy in AWS before continuing.
DESC INTEGRATION s3_walmart_int;

-- If the allowed location is wrong, fix it with ALTER (keeps the same external ID).
-- Do NOT use CREATE OR REPLACE: it generates a new external ID and breaks the trust policy.
-- ALTER STORAGE INTEGRATION s3_walmart_int
--   SET STORAGE_ALLOWED_LOCATIONS = ('s3://<BUCKET>/walmart/');

-- ---------------------------------------------------------------------
-- 4. File format and stage
-- ---------------------------------------------------------------------
USE SCHEMA DBT_LEARNING.RAW;

CREATE OR REPLACE FILE FORMAT csv_fmt
  TYPE                         = CSV
  PARSE_HEADER                 = TRUE
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  NULL_IF                      = ('', 'NULL');
  -- Note: the source writes missing values as 'NA', which is NOT converted here.
  -- The dbt staging models handle it with TRY_TO_DOUBLE.

CREATE OR REPLACE STAGE walmart_stage
  URL                 = 's3://<BUCKET>/walmart/'
  STORAGE_INTEGRATION = s3_walmart_int
  FILE_FORMAT         = csv_fmt;

-- Checkpoint: must list department.csv, stores.csv and fact.csv
LIST @walmart_stage;

-- ---------------------------------------------------------------------
-- 5. Raw tables, created from the file headers
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE DEPARTMENT USING TEMPLATE (
  SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*)) WITHIN GROUP (ORDER BY ORDER_ID)
  FROM TABLE(INFER_SCHEMA(
    LOCATION    => '@walmart_stage/department.csv',
    FILE_FORMAT => 'csv_fmt')));

CREATE OR REPLACE TABLE STORES USING TEMPLATE (
  SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*)) WITHIN GROUP (ORDER BY ORDER_ID)
  FROM TABLE(INFER_SCHEMA(
    LOCATION    => '@walmart_stage/stores.csv',
    FILE_FORMAT => 'csv_fmt')));

CREATE OR REPLACE TABLE FACT USING TEMPLATE (
  SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*)) WITHIN GROUP (ORDER BY ORDER_ID)
  FROM TABLE(INFER_SCHEMA(
    LOCATION    => '@walmart_stage/fact.csv',
    FILE_FORMAT => 'csv_fmt')));

-- ---------------------------------------------------------------------
-- 6. Load the data
-- ---------------------------------------------------------------------
COPY INTO DEPARTMENT FROM @walmart_stage/department.csv MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;
COPY INTO STORES     FROM @walmart_stage/stores.csv     MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;
COPY INTO FACT       FROM @walmart_stage/fact.csv       MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;

-- ---------------------------------------------------------------------
-- 7. Checks
-- ---------------------------------------------------------------------
-- Expected: DEPARTMENT 421,570 | STORES 45 | FACT 8,190
SELECT 'DEPARTMENT' AS table_name, COUNT(*) AS row_count FROM DEPARTMENT
UNION ALL SELECT 'STORES', COUNT(*) FROM STORES
UNION ALL SELECT 'FACT',   COUNT(*) FROM FACT;

-- Missing markdowns are stored as the text 'NA' (expected: 4,158 of 8,190)
SELECT COUNT(*)                     AS total_rows,
       COUNT_IF("MarkDown1" = 'NA') AS na_rows
FROM FACT;

-- Next: run `dbt build` (builds WALMART_E2E.DBT_PETER), then open the Streamlit app.
