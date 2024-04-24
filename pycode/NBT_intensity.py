import os
import gc
import re
import cv2
import math
import numpy as np
import pandas as pd
import matplotlib
from matplotlib import pyplot as plt
import skimage.feature as skf_feature
import skimage.filters as skf_filters

font = {'family' : 'sans',
        'weight' : 'bold',
        'size'   : 5}

matplotlib.rc('font', **font)

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

def sd_filter(img, kernel_size=(3, 3)):
   img1 = cv2.blur(img ** 2, kernel_size)
   img2 = cv2.blur(img, kernel_size) ** 2
   res = math.sqrt(img1 - img2)
   return res

def nbt_intensity(img_path):
   img_folder = os.path.join(img_path)
   img_list = [i for i in os.listdir(img_folder) if re.search("(?=.*tiff)|(?=.*tif)", i)]
   len(img_list)

   output_dir = os.path.join(os.path.dirname(img_folder), "OUT_" + os.path.basename(img_folder))
   if not os.path.exists(output_dir):
      os.makedirs(output_dir)

   csv = {"img_name": [], "nbt_area": [], "nbt_intensity": []}

   for img in img_list:
      try:
         print(f"\nCalculating NBT intensity for {img}...\n")
         output_filename = "OUT_" + img
         raw_img = os.path.join(img_folder, img)
         raw_img = cv2.imread(raw_img, cv2.IMREAD_COLOR)[:, :, ::-1]
         h, w, d = raw_img.shape
         R, G, B = cv2.split(raw_img)
         B = cv2.bitwise_not(B)

         thresh = skf_filters.threshold_multiotsu(B, classes=3)
         roi = B >= np.max(thresh)
         roi = np.multiply(roi, 255).astype(np.uint8)

         for i in range(3):
            roi = cv2.medianBlur(roi, 5)
            roi = min_filter(roi, (3, 3), iteration=1)
            roi = cv2.medianBlur(roi, 5)
            roi = max_filter(roi, (3, 3), iteration=1)

         # NBT staining area (pixels)
         nbt_area = np.sum(roi / 255.0)

         # NBT staining intensity (sum of digital number of the staining area)
         nbt_intensity = (B / 255.0) * (roi / 255.0)
         nbt_intensity = cv2.normalize(nbt_intensity, None, 0, 255, cv2.NORM_MINMAX)
         nbt_intensity = np.sum(nbt_intensity)
         
         contours, hierarchy = cv2.findContours(roi, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
         contours = cv2.drawContours(B * 0, contours, -1, (255, 0, 0), thickness=7)
         contours = cv2.merge([contours, contours * 0, contours * 0])
         contours = cv2.addWeighted(raw_img, 1, contours, 1, 0)

         # Insert data into dictionary
         csv["img_name"].append(img)
         csv["nbt_area"].append(nbt_area)
         csv["nbt_intensity"].append(nbt_intensity)

         # Plotting
         titles = ["RGB image", f"Area: {nbt_area / 1_000:.2f}K", f"Intensity: {nbt_intensity / 1_000_000:.2f}M"]
         images = [raw_img, roi, contours]
         k = 0
         for titles in titles:
            _ = plt.subplot(1, 3, k + 1), plt.imshow(images[k]), plt.title(titles), plt.axis("off")
            k += 1
         
         plt.savefig(os.path.join(output_dir, output_filename), dpi=330, bbox_inches='tight', pad_inches=0)

         plt.close("all")
         _ = gc.collect()

      except:
         print(f"\nFailed to calculate NBT intensity for {img}...\n")
         csv["img_name"].append(img)
         csv["nbt_area"].append("NA")
         csv["nbt_intensity"].append("NA")

   df0 = pd.DataFrame.from_dict(csv)
   df0.to_csv(os.path.join(output_dir, f"OUT_{os.path.basename(img_folder)}.csv"), index=False)


# DAT 2
nbt_intensity("./img/NBT/DAT2_28-vs-38_20240415")

# DAT 3
nbt_intensity("./img/NBT/DAT3_28-vs-38_20240416")

# DAT 4
nbt_intensity("./img/NBT/DAT4_28-vs-38_20240417")

# DAT 5
nbt_intensity("./img/NBT/DAT5_28-vs-38_20240418")