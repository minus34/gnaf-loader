# script gets URLs of all Australian BoM weather station observations
# ... and saves them to a CSV

import csv
# import pandas
# import matplotlib.pyplot as plt
import requests

from bs4 import BeautifulSoup

states = ["ACT", "NSW", "NT", "QLD", "SA", "TAS", "VIC", "WA"]

# urls for each state's weather observations
base_url = "http://www.bom.gov.au/{0}/observations/{0}all.shtml"

output_urls = list()

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
            output_url = url.replace("/products/", "http://www.bom.gov.au/fwo/").replace(".shtml", ".json")
            # print(output_url)

            output_urls.append(output_url)

with open('weather_observations_urls.csv', 'w', newline='') as output_file:
    output_file.write("\n".join(output_urls))
