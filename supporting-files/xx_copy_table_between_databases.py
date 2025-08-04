
import io
import logging
import os
import psycopg  # need to install package
import subprocess

from datetime import datetime

# ---------------------------------------------------------------------------------------
# set database parameters
# ---------------------------------------------------------------------------------------

source_platform = "postgres"
source_credentials = "localhost_super"
source_schema = "gnaf_202508"
source_table = "boundary_concordance"

target_platform = "postgres"
target_credentials = "localhost_super"
target_schema = "testing"
target_table = "boundary_concordance"

# ---------------------------------------------------------------------------------------


def main():
    # get database credentials
    source_pg_settings = get_password(source_credentials)
    target_pg_settings = get_password(target_credentials)

    # create source & target postgres connect strings
    source_pg_connect_string = "dbname={DB} host={HOST} port={PORT} user={USER} password={PASS}" \
        .format(**source_pg_settings)

    target_pg_connect_string = "dbname={DB} host={HOST} port={PORT} user={USER} password={PASS}" \
        .format(**target_pg_settings)

    # # step 1 - create or truncate existing table
    create_or_truncate_table(source_pg_settings, target_pg_connect_string)

    # step 2 - copy data in memory
    copy_table(source_pg_connect_string, target_pg_connect_string)


def create_or_truncate_table(source_pg_settings, target_pg_connect_string):
    start_time = datetime.now()

    source_host = "{HOST}".format(**source_pg_settings)
    source_database = "{DB}".format(**source_pg_settings)
    source_password = "{PASS}".format(**source_pg_settings)

    # connect to target Postgres database
    target_pg_conn = psycopg.connect(target_pg_connect_string)
    target_pg_conn.autocommit = True
    target_pg_cur = target_pg_conn.cursor()

    # check if target table exists
    sql = f"""SELECT EXISTS (
                SELECT 1 FROM information_schema.tables 
                WHERE table_schema = '{target_schema}'
                AND table_name   = '{target_table}'
              )"""
    target_pg_cur.execute(sql)
    table_exists = target_pg_cur.fetchone()[0]

    if table_exists:
        # delete all rows without logging changes
        sql = f"TRUNCATE TABLE {target_schema}.{target_table}"
        target_pg_cur.execute(sql)

        logger.info(f"\t - target table truncated : {datetime.now() - start_time}")
    else:
        # create table and indexes
        # TODO: should create indexes after initial data load, but it's simpler to do it here

        # run pg_dump to get create table/index statements
        cmd = f"""target PGPASSWORD={source_password};pg_dump -t '{source_schema}.{source_table}' --schema-only -h {source_host} -d {source_database}"""
        raw_dump_sql = run_command_line(cmd).split("\n")
        # clean comments and blank lines
        if raw_dump_sql is not None:
            dump_sql = io.StringIO()
            for line in raw_dump_sql:
                if line[:2] != "--" and line != "":
                    dump_sql.write(line)

            # split output into separate SQL statements
            dump_sql.seek(0)
            sql_commands = dump_sql.read().split(";")

            # for each type of statement - make specific edits to allow the import into the target platform
            for sql in sql_commands:
                # replace source schema and table with the target
                sql = sql.replace(f"{source_schema}.{source_table}", f"{target_schema}.{target_table}")
                sql = sql.replace(f" {source_table}_", f" {target_table}_")

                # create target table
                if sql[:13] == "CREATE TABLE ":
                    try:
                        target_pg_cur.execute(sql)
                    except Exception as e:
                        logger.fatal(f"Can't create table : {e}")
                        logger.fatal(sql)

                # create index(es)
                if sql[:13] == "CREATE INDEX ":
                    try:
                        target_pg_cur.execute(sql)
                    except Exception as e:
                        logger.fatal(f"Can't create index : {e}")
                        logger.fatal(sql)

            logger.info(f"\t - target table created : {datetime.now() - start_time}")

    target_pg_cur.close()
    target_pg_conn.close()


def copy_table(source_pg_connect_string, target_pg_connect_string):
    start_time = datetime.now()

    # connect to source Postgres database
    source_pg_conn = psycopg.connect(source_pg_connect_string)
    source_pg_cur = source_pg_conn.cursor()

    # connect to target Postgres database -- need long timeout for large table
    target_pg_conn = psycopg.connect(target_pg_connect_string, options='-c statement_timeout=14400000')  # 2hr timeout
    target_pg_conn.autocommit = True
    target_pg_cur = target_pg_conn.cursor()

    # copy using in-memory io
    with source_pg_cur.copy(f"COPY (SELECT * FROM {source_schema}.{source_table}) TO STDOUT") as source:
        with target_pg_cur.copy(f"COPY {target_schema}.{target_table} FROM STDIN") as target:
            for data in source:
                target.write(data)

    logger.info("\t - source table loaded into memory: {}".format(datetime.now() - start_time))
    start_time = datetime.now()

    target_pg_cur.execute("ANALYSE {}.{}".format(target_schema, target_table))

    target_pg_cur.execute("SELECT count(*) FROM {}.{}".format(target_schema, target_table))
    num_rows = target_pg_cur.fetchone()[0]

    target_pg_cur.close()
    target_pg_conn.close()

    source_pg_cur.close()
    source_pg_conn.close()

    logger.info("\t - imported to target table : {} total rows : {}".format(num_rows, datetime.now() - start_time))


def run_command_line(cmd):
    """run a command line and return it's output (unless it fails)"""
    try:
        output = subprocess.check_output(cmd, stderr=subprocess.STDOUT, shell=True, universal_newlines=True)
        # logger.info("\tCmd Line SUCCESS: \n{}".format(output))
        return output
    except subprocess.CalledProcessError as e:
        # logger.info("\tCmd Line FAIL: {0} {1}".format(e.returncode, e.output))
        return None


# get database credentials from local file
# TODO - use a proper secrets vault
def get_password(connection_name):
    passwords_file_path = os.path.join(os.environ["GIT_HOME"], "passwords.ini")

    if os.path.exists(passwords_file_path):
        passwords_file = open(passwords_file_path,'r').read().splitlines()
        passwords_file = [i for i in passwords_file if len(i) != 0]  # remove empty lines
        passwords_file = [i for i in passwords_file if i[0] != "#"]  # remove comment lines

        params = dict()
        for ini in passwords_file:
            params[ini.split()[0].rstrip().lstrip()] = ini.split(':=')[1].rstrip().lstrip()

        return dict(item.split("|") for item in params[connection_name].split(","))


if __name__ == '__main__':
    full_start_time = datetime.now()

    # set logger
    log_file = os.path.abspath(__file__).replace(".py", ".log")
    logging.basicConfig(filename=log_file, level=logging.DEBUG, format="%(asctime)s %(message)s",
                        datefmt="%m/%d/%Y %I:%M:%S %p")

    logger = logging.getLogger()
    logger.setLevel(logging.INFO)

    # setup logger to write to screen as well as writing to log file
    # define a Handler which writes INFO messages or higher to the sys.stderr
    console = logging.StreamHandler()
    console.setLevel(logging.INFO)
    # set a format which is simpler for console use
    formatter = logging.Formatter('%(name)-12s: %(levelname)-8s %(message)s')
    # tell the handler to use this format
    console.setFormatter(formatter)
    # add the handler to the root logger
    logging.getLogger('').addHandler(console)

    task_name = "Copy Postgres table between databases"

    logger.info(f"{task_name} started : {datetime.now()}")

    main()

    logger.info(f"{task_name} finished : {datetime.now() - full_start_time}")
