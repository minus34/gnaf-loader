
import geopandas
import io
import json
import logging
import matplotlib.pyplot as plt
import multiprocessing
import numpy
import os
import pandas
import psycopg2
import requests
import scipy.interpolate
import sqlalchemy
import struct
import urllib.request
import zipfile

from bs4 import BeautifulSoup
from datetime import datetime

from osgeo import gdal

dem_file_name = "/Users/hugh.saalmans/Downloads/3secSRTM_DEM/DEM_ESRI_GRID_16bit_Integer/dem3s_int/hdr.adf"
dem_dataset = gdal.Open(dem_file_name, gdal.GA_ReadOnly)


# print("Driver: {}/{}".format(dataset.GetDriver().ShortName,
#                              dataset.GetDriver().LongName))
#
# print("Size is {} x {} x {}".format(dataset.RasterXSize,
#                                     dataset.RasterYSize,
#                                     dataset.RasterCount))
#
# print("Projection is {}".format(dataset.GetProjection()))

geotransform = dem_dataset.GetGeoTransform()

if geotransform:
    print("Origin = ({}, {})".format(geotransform[0], geotransform[3]))
    print("Pixel Size = ({}, {})".format(geotransform[1], geotransform[5]))

# out_arr = dataset.ReadAsArray()
# print(out_arr)

# if not dataset: