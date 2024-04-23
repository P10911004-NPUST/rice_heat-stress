import os
import re
import cv2
import math
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import skimage.feature as skf_feature
import skimage.filters as skf_filters

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

# ========== DAT1 ==========
img_folder = os.path.join("./img/NBT/DAT5_28-vs-38_20240418")
img_list = [i for i in os.listdir(img_folder) if re.search("(?=.*tiff)|(?=.*tif)", i)]
len(img_list)

output_dir = os.path.join(os.path.dirname(img_folder), "OUT_" + os.path.basename(img_folder))
if not os.path.exists(output_dir):
    os.makedirs(output_dir)

for i in img_list:
   print(f"Calculating NBT intensity for {i}...")
   output_filename = "OUT_" + i
   raw_img = os.path.join(img_folder, i)
   raw_img = cv2.imread(raw_img, cv2.IMREAD_COLOR)[:, :, ::-1]
   h, w, d = raw_img.shape
   R, G, B = cv2.split(raw_img)
   B = cv2.bitwise_not(B)

   thresh = skf_filters.threshold_multiotsu(B, classes=3)
   roi = B >= np.max(thresh)
   roi = np.multiply(roi, 255).astype(np.uint8)

   for i in range(10):
      roi = cv2.medianBlur(roi, 5)
      roi = min_filter(roi, (5, 5), iteration=1)
      roi = cv2.medianBlur(roi, 5)
      roi = max_filter(roi, (5, 5), iteration=1)

   # NBT staining area (%)
   nbt_area = 100 * np.sum(roi / 255.0) / (h * w)

   nbt_intensity = (B / 255.0) * (roi / 255.0)
   nbt_intensity = cv2.normalize(nbt_intensity, None, 0, 255, cv2.NORM_MINMAX)
   nbt_intensity = np.sum(nbt_intensity)

   contours, hierarchy = cv2.findContours(roi, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
   contours = cv2.drawContours(B * 0, contours, -1, (255, 0, 0), thickness=11)
   contours = cv2.merge([contours, contours * 0, contours * 0])
   contours = cv2.addWeighted(raw_img, 1, contours, 1, 0)

   plt.subplot(131); plt.imshow(raw_img), plt.axis("off"), plt.title("RGB image")
   plt.subplot(132); plt.imshow(roi, cmap="gray"), plt.axis("off"), plt.title(f"Intensity: {nbt_intensity:.2f}")
   plt.subplot(133); plt.imshow(contours), plt.axis("off"), plt.title(f"Area: {nbt_area:.2f}%")
   plt.savefig(os.path.join(output_dir, output_filename), dpi=330, bbox_inches='tight', pad_inches=0)
