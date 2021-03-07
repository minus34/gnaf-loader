
from osgeo import gdal

file_name = "/Users/hugh.saalmans/Downloads/3secSRTM_DEM/DEM_ESRI_GRID_16bit_Integer/dem3s_int/hdr.adf"


dataset = gdal.Open(file_name, gdal.GA_ReadOnly)


print("Driver: {}/{}".format(dataset.GetDriver().ShortName,
                             dataset.GetDriver().LongName))

print("Size is {} x {} x {}".format(dataset.RasterXSize,
                                    dataset.RasterYSize,
                                    dataset.RasterCount))

print("Projection is {}".format(dataset.GetProjection()))

geotransform = dataset.GetGeoTransform()

if geotransform:
    print("Origin = ({}, {})".format(geotransform[0], geotransform[3]))
    print("Pixel Size = ({}, {})".format(geotransform[1], geotransform[5]))


# if not dataset: