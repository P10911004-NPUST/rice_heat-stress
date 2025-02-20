import os
from PIL import Image
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import czifile

img_dir = "./WT-vs-mutants_Mock_20250219"
#img_list = os.listdir(img_dir)
img_list = [i for i in os.listdir(img_dir) if i.endswith((".czi"))]

for i in img_list:
    img = czifile.imread(os.path.join(img_dir, i))
    img = np.array(img, dtype=np.double)
    _, _, _, channel, width, height, _ = img.shape

    # Sum up all channels into one channel array
    arr0 = np.zeros((width, height))
    for chn in range(0, channel):
        arr0 += img[0, 0, 0, chn, :, :, 0]

    # Normalize the array and convert it to uint8
    arr1 = ((arr0 - arr0.min()) / (arr0.max() - arr0.min())) * 255.0
    arr1 = arr1.astype(np.uint8)

    RGB_img = np.zeros((width, height, 3), dtype=np.uint8)
    RGB_img[:, :, 1] = arr1

    out_img = Image.fromarray(RGB_img, mode="RGB")
    out_img.save(os.path.join(img_dir, f"{i.removesuffix('.czi')}.tiff"), "TIFF")


