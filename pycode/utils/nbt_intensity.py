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

from .filters import min_filter, max_filter

def nbt_intensity(img_path):
   img_folder = os.path.join(img_path)
   img_list = [i for i in os.listdir(img_folder) if re.search("(?=.*tiff)|(?=.*tif)", i)]

   output_dir = os.path.join(os.path.dirname(img_folder), "OUT_" + os.path.basename(img_folder))
   if not os.path.exists(output_dir):
      os.makedirs(output_dir)

   csv = {"img_name": [], "selected_area": [], "total_intensity": [], "intensity_per_area": []}

   for img in img_list:
      try:
         # print(f"\nCalculating NBT intensity for {img}...\n")
         output_filename = "OUT_" + img
         raw_img = os.path.join(img_folder, img)
         # raw_img = cv2.imread(raw_img, cv2.IMREAD_COLOR)[:, :, ::-1]
         raw_img = cv2.imread(raw_img, cv2.IMREAD_COLOR)
         # R, G, B = cv2.split(raw_img)
         B, _, _ = cv2.split(raw_img)
         B = cv2.bitwise_not(B)

         thresh = skf_filters.threshold_multiotsu(B, classes=3)
         roi = B >= np.max(thresh)

         # The filtering process requires uint8 values
         roi = np.multiply(roi, 255).astype(np.uint8)

         # Filtering process
         for _ in range(5):
            roi = cv2.medianBlur(roi, 7)
            roi = min_filter(roi, (3, 3), iteration=1)
            roi = cv2.medianBlur(roi, 7)
            roi = max_filter(roi, (3, 3), iteration=1)

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
         
         # Insert resulted values into a dictionary
         csv["img_name"].append(img)
         csv["selected_area"].append(nbt_area)
         csv["total_intensity"].append(nbt_intensity)
         csv["intensity_per_area"].append(nbt_intensity_per_area)

         # Plotting
         ## Create contour
         contours, hierarchy = cv2.findContours(roi, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
         ## Draw contour line on a blank image
         contours = cv2.drawContours(B * 0, contours, -1, (255, 0, 0), thickness=7)
         ## Show the coutour as red color
         contours = cv2.merge([contours, contours * 0, contours * 0])
         ## Combined the original image with the contour line
         contours = cv2.addWeighted(raw_img, 1, contours, 1, 0)
         titles = ["RGB image", f"Area: {nbt_area / 1_000:.2f}K", f"Intensity: {nbt_intensity / 1_000_000:.2f}M"]
         images = [raw_img, roi, contours]
         k = 0
         for titles in titles:
            _ = plt.subplot(1, 3, k + 1), plt.imshow(images[k]), plt.title(titles), plt.axis("off")
            k += 1
         plt.savefig(os.path.join(output_dir, output_filename), dpi=330, bbox_inches='tight', pad_inches=0)
         plt.close("all")
         _ = gc.collect()
         print("Save to {}".format(os.path.join(output_dir, output_filename)))

      except:
         # if the image is problematic
         csv["img_name"].append(img)
         csv["selected_area"].append("NA")
         csv["total_intensity"].append("NA")
         print("Problematic image: " + img)

   # df0 = pd.DataFrame.from_dict(csv)
   # df0.to_csv(os.path.join(output_dir, f"OUT_{os.path.basename(img_folder)}.csv"), index=False)

