# script gets URLs of all Australian BoM weather station observations
# ... and saves them to a CSV

import csv
import logging
import multiprocessing
import os
# import pandas
# import matplotlib.pyplot as plt
import requests

from bs4 import BeautifulSoup
from datetime import datetime

# where to save the files
output_path = os.path.join(os.path.dirname(os.path.realpath(__file__)), "data")

# states to include (note: no "OT" state in BoM observations)
states = ["ACT", "NSW", "NT", "QLD", "SA", "TAS", "VIC", "WA"]

# urls for each state's weather observations
base_url = "http://www.bom.gov.au/{0}/observations/{0}all.shtml"


def main():
    start_time = datetime.now()

    obs_urls = list()

    for state in states:
        # get URL for web page to scrape
        input_url = base_url.format(state.lower())

        # load and parse web page
        r = requests.get(input_url)
        soup = BeautifulSoup(r.content, features="html.parser")

        # get all links
        links = soup.find_all('a', href=True)

        for link in links:
            url = link['href']

            if "/products/" in url:

                # change URL to get JSON file of weather obs
                obs_url = url.replace("/products/", "http://www.bom.gov.au/fwo/").replace(".shtml", ".json")
                # logger.info(obs_url)

                obs_urls.append(obs_url)

    with open(os.path.join(output_path, 'weather_observations_urls.txt'), 'w', newline='') as output_file:
        output_file.write("\n".join(obs_urls))

    logger.info("Got obs file list : {}".format(datetime.now() - start_time))
    start_time = datetime.now()

    # download each obs file using multiprocessing
    pool = multiprocessing.Pool(processes=12)

    num_jobs = len(obs_urls)

    results = pool.imap_unordered(run_multiprocessing, obs_urls)

    pool.close()
    pool.join()

    result_list = list(results)
    num_results = len(result_list)

    if num_jobs > num_results:
        logger.warning("\t- A MULTIPROCESSING PROCESS FAILED WITHOUT AN ERROR\nACTION: Check the record counts")

    for result in result_list:
        if result != "SUCCESS":
            logger.warning(result)

    logger.info("Downloaded all obs files : {}".format(datetime.now() - start_time))
    # start_time = datetime.now()

    return True


def run_multiprocessing(url):
    file_path = os.path.join(output_path, "obs", url.split("/")[-1])

    try:
        with open(file_path, 'w', newline='') as output_file:
            output_file.write(requests.get(url).text)

        result = "SUCCESS"
        # print("Saved {}".format(file_path))
    except Exception as ex:
        result = "\t- FAILED! : {} : {}".format(file_path, ex)
        # print(result)

    return result


if __name__ == '__main__':
    logger = logging.getLogger()

    # set logger
    log_file = os.path.abspath(__file__).replace(".py", ".log")
    logging.basicConfig(filename=log_file, level=logging.DEBUG, format="%(asctime)s %(message)s",
                        datefmt="%m/%d/%Y %I:%M:%S %p")

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

    logger.info("")
    logger.info("Start weather obs download")
    # psma.check_python_version(logger)

    if main():
        logger.info("Finished successfully!")
    else:
        logger.fatal("Something bad happened!")

    logger.info("")
    logger.info("-------------------------------------------------------------------------------")
