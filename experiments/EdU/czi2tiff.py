import os
from PIL import Image
from PIL.ExifTags import TAGS
from skimage import io
import skimage.filters as skf_filters
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import czifile

def Z_projection(img, methods = "max_intensity"):
    img = np.max(img, axis=0)
    img = img.astype(np.uint8)
    RGB_img = np.zeros((width, height, 3), dtype = np.uint8)
    RGB_img[:, :, 1] = img
    out_img = Image.fromarray(RGB_img, mode="RGB")
    return out_img

img_dir = "./salt_stress/osrgf1-7_0-100mM_20250714"
img_list = [i for i in os.listdir(img_dir) if i.endswith((".czi"))]

#img0 = os.path.join(img_dir, "DAI07_M07_0nM_Cr_R13_20250725.czi")
#img0 = czifile.imread(img0)
#img0.shape

###########################################################################
# Maximum intensity
###########################################################################
df0 = pd.DataFrame(columns = ["img_name", "area", "total_intensity"])
for i in img_list:
    img = czifile.imread(os.path.join(img_dir, i))
    img = np.array(img, dtype=np.double)
    _, _, channel, zstack, width, height, _ = img.shape

    img = img[0, 0, 0, :, :, :, 0]

    arr0 = np.max(img, axis=0)
    arr0 = arr0.astype(np.uint8)    
    
    # Apply thresholding
    try:
        thresh = skf_filters.threshold_multiotsu(arr0, classes = 2)
    except:
        thresh = [0, 255]

    arr0[arr0 < np.max(thresh)] = 0

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

    out_img = Z_projection(img, methods = "max_intensity")
    out_img.save(os.path.join(img_dir, f"{i.removesuffix('.czi')}.tiff"), "TIFF")

df0.to_csv(os.path.join(img_dir, "total_intensity.csv"), index=False)


############################################################################
## Get the min & max values of this batch of images
############################################################################
#max_val = list()
#min_val = list()
#for i in img_list:
#    img = czifile.imread(os.path.join(img_dir, i))
#    img = np.array(img, dtype=np.double)
#    _, _, _, zstack, width, height, _ = img.shape

#    # Sum up all zstacks into one zstack array
#    arr0 = np.zeros((width, height))
#    for chn in range(0, zstack):
#        arr0 += img[0, 0, 0, chn, :, :, 0]   

#    max_val = np.append(max_val, arr0.max())
#    min_val = np.append(min_val, arr0.min())

#max_val = np.max(max_val)
#min_val = np.min(min_val)

############################################################################
## Proceed images
############################################################################
#df0 = pd.DataFrame(columns = ["img_name", "area", "total_intensity"])
#for i in img_list:
#    img = czifile.imread(os.path.join(img_dir, i))
#    img = np.array(img, dtype=np.double)
#    _, _, _, zstack, width, height, _ = img.shape

#    # Sum up all zstacks into one zstack array
#    arr0 = np.zeros((width, height))
#    for chn in range(0, zstack):
#        arr0 += img[0, 0, 0, chn, :, :, 0]

#    # Normalize the array and convert it to uint8
#    arr1 = arr0
#    arr1 = ((arr0 - min_val) / (max_val - min_val)) * 255.0
#    arr1 = arr1.astype(np.uint8)

#    # Apply thresholding
#    try:
#        thresh = skf_filters.threshold_multiotsu(arr1, classes = 2)
#    except:
#        thresh = [0, 255]

#    arr1[arr1 < np.max(thresh)] = 0

#    total_intensity = arr1.sum()
#    staining_area = np.sum(arr1 > 0)
#    avg_intensity = total_intensity / staining_area

#    # Export as RGB image in TIFF format
#    RGB_img = np.zeros((width, height, 3), dtype=np.uint8)
#    RGB_img[:, :, 1] = arr1
#    out_img = Image.fromarray(RGB_img, mode="RGB")
#    out_img.save(os.path.join(img_dir, f"{i.removesuffix('.czi')}.tiff"), "TIFF")

#    # Dataframe
#    df0 = pd.concat([ 
#        df0, 
#        pd.DataFrame({
#            "img_name": [i], 
#            "area": [staining_area], 
#            "total_intensity": [total_intensity], 
#            "avg_intensity": [avg_intensity]
#        }) 
#    ])

#df0.to_csv(os.path.join(img_dir, "total_intensity.csv"), index=False)


