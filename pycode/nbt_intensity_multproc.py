import os
import gc
import re
import cv2
import math
import numpy as np
import pandas as pd
import matplotlib
from matplotlib import pyplot as plt
import skimage.filters as skf_filters
import multiprocessing as mp

def min_filter(img, kernel=(3, 3), iteration=1):
   shape = cv2.MORPH_RECT
   kernel = cv2.getStructuringElement(shape, kernel)
   res = cv2.erode(img, kernel, iterations=iteration)
   return res

def max_filter(img, kernel_size=(3, 3), iteration=1):
   shape = cv2.MORPH_RECT
   kernel = cv2.getStructuringElement(shape, kernel_size)
   res = cv2.dilate(img, kernel)
   return res

font = {'family' : 'sans',
        'weight' : 'bold',
        'size'   : 5
        }

matplotlib.rc('font', **font)

def nbt_intensity(img_dir, plots = True):
   dirname = os.path.dirname(img_dir)
   img_name = os.path.basename(img_dir)
   output_dir = os.path.join(os.path.dirname(dirname), "OUT_" + os.path.basename(dirname))
   output_img = os.path.join(output_dir, "OUT_" + img_name)

   if not os.path.exists(output_dir):
      os.makedirs(output_dir)

   try:
      raw_img = cv2.imread(img_dir, cv2.IMREAD_COLOR)[:, :, ::-1]
      h, w, d = raw_img.shape
      _, _, B = cv2.split(raw_img)
      B = cv2.bitwise_not(B)

      thresh = skf_filters.threshold_multiotsu(B, classes=3)
      roi = B >= np.max(thresh)

      # The filtering process requires uint8 values
      roi = np.multiply(roi, 255).astype(np.uint8)

      # Filtering process
      for _ in range(3):
         roi = cv2.medianBlur(roi, 7)
         roi = min_filter(roi, (3, 3), iteration=1)
         roi = cv2.medianBlur(roi, 7)
         roi = max_filter(roi, (3, 3), iteration=1)

      # Create contour
      contours, hierarchy = cv2.findContours(roi, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

      # convert back to float values of 0 or 1
      roi = roi / 255.0

      # NBT staining area (pixels)
      nbt_area = np.sum(roi)

      # NBT staining intensity (sum of digital number of the staining area)
      if False:  
         # Testing only, not running
         nbt_intensity = (B / 255.0) * roi
         nbt_intensity = cv2.normalize(nbt_intensity, None, 0, 255, cv2.NORM_MINMAX)
         nbt_intensity = np.sum(nbt_intensity)

      nbt_intensity = np.sum((B * 1.0) * roi)

      # Minimize the impact of root size variation to the NBT intensity values
      nbt_intensity_per_area = nbt_intensity / nbt_area

      if plots:
         # Plotting
         ## Draw contour line on a blank image
         contours = cv2.drawContours(B * 0, contours, -1, (255, 0, 0), thickness=7)
         ## Show the coutour as red color
         contours = cv2.merge([contours, contours * 0, contours * 0])
         ## Combined the original image with the contour line
         contours = cv2.addWeighted(raw_img, 1, contours, 1, 0)
         titles = [
            "RGB image", 
            f"Area: {nbt_area / 1_000:.2f}K ({(100 * nbt_area / (h * w)):.2f}%)", 
            f"Intensity: {nbt_intensity / 1_000_000:.2f}M"
            ]
         images = [raw_img, roi, contours]
         k = 0
         for titles in titles:
            _ = plt.subplot(1, 3, k + 1), plt.imshow(images[k]), plt.title(titles), plt.axis("off")
            k += 1
         plt.savefig(output_img, dpi=330, bbox_inches='tight', pad_inches=0)
         plt.close("all")
         _ = gc.collect()
         print("Save to {}".format(os.path.join(output_dir, output_img)))

   except:
      # The image is all white, no staining
      if np.max(B) == 0:
         nbt_area = 0
         nbt_intensity = 0
         nbt_intensity_per_area = 0
      else:
         # if the image is problematic
         nbt_area = "NA"
         nbt_intensity = "NA"
         nbt_intensity_per_area = "NA"
         print("Problematic image: " + img_name)
      
   return img_name, nbt_area, nbt_intensity, nbt_intensity_per_area



img_path = "./img/NBT/DAT5_28-vs-38_20240418"
img_list = [os.path.join(img_path, i) for i in os.listdir(img_path) if re.search("(?=.*tiff)|(?=.*tif)", i)]

nbt_intensity(img_list[1])

df0 = {"img_name": [], "nbt_area": [], "nbt_intensity": [], "nbt_intensity_per_area": []}
for img in img_list:
   img_name, area, intensity, intensity_per_area = nbt_intensity(img)
   df0["img_name"].append(img_name)
   df0["nbt_area"].append(area)
   df0["nbt_intensity"].append(intensity)
   df0["nbt_intensity_per_area"].append(intensity_per_area)

df0 = pd.DataFrame.from_dict(df0)

out_dir = os.path.join(os.path.dirname(img_path), f"OUT_{os.path.basename(img_path)}")
if not os.path.exists(out_dir):
   os.makedirs(out_dir)
df0.to_csv(os.path.join(out_dir, f"OUT_{os.path.basename(img_path)}.csv"), index=False)



# use_cores = os.cpu_count() - 1
# pool = mp.Pool(processes=use_cores)
# img_name, area, intensity, intensity_per_area = pool.map(nbt_intensity, img_list)


