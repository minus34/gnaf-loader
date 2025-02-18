
# import geopandas
# import io
# import json
# import logging
# import matplotlib.pyplot as plt
# import multiprocessing
# import numpy
# import os
# import pandas
# import psycopg
# import requests
# import scipy.interpolate
# import sqlalchemy
# import struct
# import urllib.request
# import zipfile
#
# from bs4 import BeautifulSoup
# from datetime import datetime

from osgeo import gdal

dem_file_name = "/Users/hugh.saalmans/Downloads/3secSRTM_DEM/DEM_ESRI_GRID_16bit_Integer/dem3s_int/hdr.adf"
dem_dataset = gdal.Open(dem_file_name, gdal.GA_ReadOnly)

# print(f"Driver: {dem_dataset.GetDriver().ShortName}/{dem_dataset.GetDriver().LongName}")
# print(f"Size is {dem_dataset.RasterXSize} x {dem_dataset.RasterYSize} x {dem_dataset.RasterCount}")
# print(f"Projection is {dem_dataset.GetProjection()}")

geotransform = dem_dataset.GetGeoTransform()

if geotransform:
    print(f"Origin = ({geotransform[0]}, {geotransform[3]})")
    print(f"Pixel Size = ({geotransform[1]}, {geotransform[5]})")

# out_arr = dataset.ReadAsArray()
# print(out_arr)

# if not dataset: