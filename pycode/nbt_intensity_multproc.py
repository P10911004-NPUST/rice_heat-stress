import os
import re
import gc
import cv2
import numpy as np
import pandas as pd
from matplotlib import pyplot as plt
import multiprocessing as mp

from utils.nbt_intensity import nbt_intensity


img_path = "../img/NBT/DAT5_28-vs-38_20240418"
img_list = [os.path.join(img_path, i) for i in os.listdir(img_path) if re.search("(?=.*tiff)|(?=.*tif)", i)]

df0 = {"img_name": [], "nbt_area": [], "nbt_intensity": [], "nbt_intensity_per_area": []}
for img in img_list:
   img_name, area, intensity, intensity_per_area = nbt_intensity(img)
   df0["img_name"].append(img_name)
   df0["nbt_area"].append(area)
   df0["nbt_intensity"].append(intensity)
   df0["nbt_intensity_per_area"].append(intensity_per_area)

out_dir = os.path.join(os.path.dirname(img_path), f"OUT_{os.path.basename(img_path)}")
if not os.path.exists(out_dir):
   os.makedirs(out_dir)

df0 = pd.DataFrame.from_dict(df0)
df0.to_csv(os.path.join(out_dir, f"OUT_{os.path.basename(img_path)}.csv"), index=False)


# use_cores = os.cpu_count() - 1
# pool = mp.Pool(processes=use_cores)
# img_name, area, intensity, intensity_per_area = pool.map(nbt_intensity, img_list)


