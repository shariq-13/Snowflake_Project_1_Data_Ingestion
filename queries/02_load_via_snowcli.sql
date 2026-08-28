use role sysadmin;
use warehouse data_ingestion_wh;
use database PROJECT_DB;

--===================================
-- Loading data using SnowCLI
--===================================

-- login snowsql
-- snowsql

-- Create FILE format
CREATE OR REPLACE FILE FORMAT FILE_FORMAT_CLI
	type = 'CSV'
	field_delimiter = '|'
	skip_header = 1;

-- Create a stage table
CREATE OR REPLACE STAGE SNOW_CLI_STAGE
	file_format = FILE_FORMAT_CLI;

DESC STAGE SNOW_CLI_STAGE;

-- snowsql -a <account_identifier> -u <username>
-- snowsql -a NHZOCAW-EXC99808 -u BILAL03
-- enter your password

-- put data into stage
PUT 'file:///G:/AWS/snowflake-data-ingestion/snowflake-data-ingestion/data/customer_detail.csv'
  @SNOW_CLI_STAGE
  AUTO_COMPRESS=TRUE;


-- list stage to see how many files are there
list @SNOW_CLI_STAGE;


-- Resume warehouse, in case the auto-resume feature is OFF
ALTER WAREHOUSE <name> RESUME;

-- customer table
CREATE TABLE CUSTOMER_DETAILS_CLI (
    first_name STRING,
    last_name STRING,
    address STRING,
    city STRING,
    state STRING
);

-- copy data from stage to table
COPY INTO CUSTOMER_DETAILS_CLI
	FROM @SNOW_CLI_STAGE
    files=('customer_detail.csv.gz')
	file_format = (format_name = FILE_FORMAT_CLI)
	on_error = 'skip_file';

-- table must have data
SELECT * FROM CUSTOMER_DETAILS_CLI;

-- We can also give a COPY command with the pattern if your stage contains multiple  files
COPY INTO mycsvtable
	FROM @mycsvstage
	file_format = (format_name = FILE_FORMAT_CLI)
	pattern = '*.contain[1-5].csv.gz'
	on_error = 'skip_file';
