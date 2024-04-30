import os
import re
import gc
import cv2
import time
import numpy as np
import pandas as pd
from matplotlib import pyplot as plt
import multiprocessing as mp

from utils.nbt_intensity import nbt_intensity

if __name__ == "__main__":
    start = time.perf_counter()

    img_path = "../img/NBT/DAT5_28-vs-38_20240418"
    img_list = [
        os.path.join(img_path, i)
        for i in os.listdir(img_path)
        if re.search("(?=.*tiff)|(?=.*tif)", i)
    ]

    df0 = {
        "img_name": [],
        "nbt_area": [],
        "nbt_intensity": [],
        "nbt_intensity_per_area": [],
    }

    def extract_elements_from_listed_tuple(x):
        df0[list(df0.keys())[x]] = [i[x] for i in res]

    """ Use for-loop 
   requires 99.73 seconds
   """
    #  for img in img_list:
    #      img_name, area, intensity, intensity_per_area = nbt_intensity(img)
    #      df0["img_name"].append(img_name)
    #      df0["nbt_area"].append(area)
    #      df0["nbt_intensity"].append(intensity)
    #      df0["nbt_intensity_per_area"].append(intensity_per_area)

    """ Use native map
   requires 104.4 seconds
   """
    # res = list(map(nbt_intensity, img_list))
    # list(map(extract_elements_from_listed_tuple, range(4)))

    """ Use multiprocessing pool
   requires 17.25 seconds
   """
    pool = mp.Pool()
    res = pool.map(nbt_intensity, img_list)
    pool.close()
    pool.join()
    df0["img_name"] = [i[0] for i in res]
    df0["nbt_area"] = [i[1] for i in res]
    df0["nbt_intensity"] = [i[2] for i in res]
    df0["nbt_intensity_per_area"] = [i[3] for i in res]

    ########################################################################
    # Output results to a csv file
    ########################################################################
    out_dir = os.path.join(
        os.path.dirname(img_path), f"OUT_{os.path.basename(img_path)}"
    )
    if not os.path.exists(out_dir):
        os.makedirs(out_dir)

    df0 = pd.DataFrame.from_dict(df0)
    df0.to_csv(
        os.path.join(out_dir, f"OUT_{os.path.basename(img_path)}.csv"), index=False
    )

    end = time.perf_counter()
    print(f"Use time: {round(end -start, 2)} seconds")
