import os
from PIL import Image
from PIL.ExifTags import TAGS
#from skimage import io
from bioio import BioImage
from bioio import writers
import bioio_czi
import skimage.filters as skf_filters
import numpy as np
#import matplotlib.pyplot as plt
import pandas as pd

def Z_projection(img, methods = "max_intensity"):
    img = np.max(img, axis=0)
    img = img.astype(np.uint8)
    RGB_img = np.zeros((width, height, 3), dtype = np.uint8)
    RGB_img[:, :, 1] = img
    out_img = Image.fromarray(RGB_img, mode="RGB")
    return out_img

img_dir = "./WT-vs-mutants_Mock_20250221"
img_list = [i for i in os.listdir(img_dir) if i.endswith((".czi"))]

bioimg = BioImage(os.path.join(img_dir, img_list[0]), reader=bioio_czi.Reader)
img = bioimg.data
width_micron = img.physical_pixel_sizes.X  # micro meter (um)
height_micron = img.physical_pixel_sizes.Y

###########################################################################
# Maximum intensity
###########################################################################
df0 = pd.DataFrame(columns = ["img_name", "area", "total_intensity"])
i = "M07_R01_Cr01_20250221.czi"
for i in img_list:
    bioimg = BioImage(os.path.join(img_dir, i), reader=bioio_czi.Reader)

    width_micron = bioimg.physical_pixel_sizes.X  # micro meter (um)
    height_micron = bioimg.physical_pixel_sizes.Y

    _, _, Zstack, height, width = bioimg.shape

    img = np.array(bioimg.data, dtype=np.double)[0, 0, :, :, :]

    arr0 = np.max(img, axis=0)
    arr0 = arr0.astype(np.uint8)   
    
    RGB_img = np.ndarray([1, 1, 3, height, width])  # dim: TCZYX
    RGB_img.shape
    #RGB_img = np.zeros((1, 1, 3, height, width), dtype = np.uint8)
    RGB_img[0, 0, 1, :, :] = arr0

    writers.OmeTiffWriter.save(
        data = RGB_img, 
        uri = os.path.join(img_dir, i.replace(".czi", ".tif")), 
        physical_pixel_sizes = [Zstack, height_micron, width_micron]
    )
    
    # Apply thresholding
    try:
        threshold = skf_filters.threshold_multiotsu(arr0, classes = 2)
    except:
        threshold = [0, 255]

    arr0[arr0 < np.max(threshold)] = 0
    
    total_intensity = arr0.sum()
    staining_area = np.sum(arr0 > 0)
    avg_intensity = total_intensity / staining_area

    # Dataframe
    df0 = pd.concat([ 
        df0, 
        pd.DataFrame({
            "img_name": [i], 
            "area": [staining_area], 
            "total_intensity": [total_intensity], 
            "avg_intensity": [avg_intensity]
        }) 
    ])


df0.to_csv(os.path.join(img_dir, "total_intensity.csv"), index=False)


image = np.ndarray([1, 10, 3, 1024, 2048])