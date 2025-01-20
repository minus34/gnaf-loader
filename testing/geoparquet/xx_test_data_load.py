
# script to download and load a remote GeoParquet file for when Apache Sedona supports the emerging GeoParquet format
#
# NOTE: as of 20250220 - geometry field currently loads as binary type; should be geometry type when supported
#

import base64
import json
import logging
import os
import pyarrow as pa
import pyarrow.parquet as pq
import sys

from datetime import datetime
from multiprocessing import cpu_count

# input path for parquet file
# input_url = "https://storage.googleapis.com/open-geodata/linz-examples/nz-buildings-outlines.parquet"
# input_path = "/Users/s57405/tmp/nz-building-outlines.parquet"
input_path = "/Users/s57405/tmp/geoscape_202502/geoparquet/address_principals.parquet"

# number of CPUs to use in processing (defaults to number of local CPUs)
num_processors = cpu_count()


def main():
    start_time = datetime.now()

    # open parquet file using pyarrow
    parquet_file = pq.ParquetFile(input_path)

    # get Geoparquet metadata
    # fred = json.dumps(parquet_file.metadata.metadata)

    metadata = parquet_file.metadata.metadata

    for key in metadata.keys():
        if key != b"ARROW:schema":
        #     decoded_schema = base64.b64decode(metadata[b"ARROW:schema"])
        #     schema2 = pa.ipc.read_schema(pa.BufferReader(decoded_schema))
        #     print(schema2)
        # else:
            geo_metadata = json.loads(metadata[key].decode("utf-8"))
            print(json.dumps(geo_metadata, indent=2, sort_keys=False))

    schema = parquet_file.schema
    print(schema)


if __name__ == "__main__":
    full_start_time = datetime.now()

    # setup logging
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)

    # set Spark logging levels
    logging.getLogger("pyspark").setLevel(logging.ERROR)
    logging.getLogger("py4j").setLevel(logging.ERROR)

    # set logger
    log_file = os.path.abspath(__file__).replace(".py", ".log")
    logging.basicConfig(filename=log_file, level=logging.DEBUG, format="%(asctime)s %(message)s",
                        datefmt="%m/%d/%Y %I:%M:%S %p")

    # setup logger to write to screen as well as writing to log file
    # define a Handler which writes INFO messages or higher to the sys.stderr
    console = logging.StreamHandler()
    console.setLevel(logging.INFO)
    # set a format which is simpler for console use
    formatter = logging.Formatter("%(name)-12s: %(levelname)-8s %(message)s")
    # tell the handler to use this format
    console.setFormatter(formatter)
    # add the handler to the root logger
    logging.getLogger("").addHandler(console)

    task_name = "Apache Sedona testing"
    system_name = "mobility.ai"

    logger.info("{} started".format(task_name))
    logger.info("Running on Python {}".format(sys.version.replace("\n", " ")))

    main()

    time_taken = datetime.now() - full_start_time
    logger.info("{} finished : {}".format(task_name, time_taken))
    print()