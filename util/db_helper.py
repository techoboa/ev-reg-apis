#############################################################################################
# Author                Date            Version         Change
# Anurag Shrivastava    03/24/2025      1.0             DB Helper module for DB Connections, Cursor and Query executions
#
#############################################################################################

# Improvement areas: 
# 1. Fetch db users and passwords from a secret manager like HKV, AKV etc. Currently hardcoded.
# 2. Enable connection polling.
# 3. Implement and test retry mechanism


import psycopg2
from psycopg2 import connect
from psycopg2 import Error
from psycopg2 import OperationalError, InterfaceError
import sys
from os import path
import time
import datetime
sys.path.append("/app/containers/ev-apis/util")
sys.path.append("/app/containers/ev-apis/config")
from general_helper import *
from log_helper import *
import configparser

dbConfig = configparser.RawConfigParser()   
dbConfigFile = r'/app/containers/ev-apis/config/db.properties'
dbConfig.read(dbConfigFile)

## DB specific variables
db_host = dbConfig.get('db', 'db_host')
db_name = dbConfig.get('db', 'db_name')
db_port = dbConfig.get('db', 'db_port')
db_schema = dbConfig.get('db', 'db_schema')
db_retries_limit = dbConfig.get('db', 'db_retries_limit')
db_retries_interval = dbConfig.get('db', 'db_retries_interval')
db_user_id = dbConfig.get('db', 'db_user_key')
db_passwd = dbConfig.get('db', 'db_passwd_key')

# TO DO: Improvement area: Fetch db users and passwords from a secret manager like HKV, AKV etc.
#db_user_id = getSecretValue(db_user_key)
#db_passwd = getSecretValue(db_user_pass)

def get_db_conn(logger, run_id):
    try:
        db = connect(database=db_name, user=db_user_id, password=db_passwd, host=db_host, port=db_port)
        lmsg='New DB connection is created'
        logger.info(concat_log_msg(run_id, lmsg))
        return db
    except:
        # TO DO: For connection errors, handle retries here. Throw exception for login issues.
        lmsg='DB Connection error'
        logger.error(concat_log_msg(run_id, lmsg))
        return None

def get_db_cursor(con, logger, run_id):
    try:
        cursor = con.cursor()
        lmsg='New DB cursor is created'
        logger.info(concat_log_msg(run_id, lmsg))
        return cursor
    except:
        # TO DO: Handle cursor errors
        lmsg='Cursor error'
        logger.error(concat_log_msg(run_id, lmsg))
        return None

def execute_select(conn, cursor, logger, run_id, query):
    try:
        conn=get_db_conn(logger, run_id)
        cursor = get_db_cursor(conn, logger, run_id)
        lmsg='Executing query'
        logger.info(concat_log_msg(run_id, lmsg))
        cursor.execute(query)
        lmsg='Done executing query'
        logger.info(concat_log_msg(run_id, lmsg))
        conn.commit()
        return cursor
    except:
        # TO DO: Data and SQL Errors. Throw as needed. 
        lmsg='SQL/Data error'
        logger.error(concat_log_msg(run_id, lmsg))
        return None

def execute_write(conn, cursor, logger, run_id, query):
    try:
        conn=get_db_conn(logger, run_id)
        cursor = get_db_cursor(conn, logger, run_id)
        lmsg='Executing query'
        logger.info(concat_log_msg(run_id, lmsg))
        cursor.execute(query)
        lmsg='Done executing query'
        logger.info(concat_log_msg(run_id, lmsg))
        conn.commit()
        return cursor
    except:
        # TO DO: Data and SQL Errors. Throw as needed. 
        lmsg='SQL/Data error'
        logger.error(concat_log_msg(run_id, lmsg))
        return None


def close_db_conn_cur(conn, cur, logger, run_id):
    try:
        cur.close()
        conn.close()
        lmsg='Closed DB connection and cursor'
        logger.info(concat_log_msg(run_id, lmsg))
    except:
        # TO DO: Data and SQL Errors. Throw as needed.
        lmsg='SQL/Data error: ' + e
        logger.error(concat_log_msg(run_id, lmsg))
        return None


