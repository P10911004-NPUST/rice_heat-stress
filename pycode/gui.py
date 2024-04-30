import os
import re
import gc
import cv2
import time
import numpy as np
import pandas as pd
from matplotlib import pyplot as plt
import multiprocessing as mp
import tkinter as tk
from tkinter import filedialog

from utils.nbt_intensity import nbt_intensity


def select_folder():
    global images, output_dir, output_csv

    dirname = filedialog.askdirectory()

    output_dir = os.path.join(
        os.path.dirname(dirname), "OUT_" + os.path.basename(dirname)
    )

    output_csv = os.path.join(output_dir, os.path.basename(output_dir) + ".csv")

    images = [
        os.path.join(dirname, i)
        for i in os.listdir(dirname)
        if i.lower().endswith((".jpg", ".jpeg", "tif", "tiff", "png"))
    ]
    folder_img_num.set(f"Load in {len(images)} images")


def run_nbt():
    df0 = {
        "img_name": [],
        "nbt_area": [],
        "nbt_intensity": [],
        "nbt_intensity_per_area": [],
    }
    pool = mp.Pool()
    res = pool.map(nbt_intensity, images)
    pool.close()
    pool.join()
    df0["img_name"] = [i[0] for i in res]
    df0["nbt_area"] = [i[1] for i in res]
    df0["nbt_intensity"] = [i[2] for i in res]
    df0["nbt_intensity_per_area"] = [i[3] for i in res]

    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    df0 = pd.DataFrame.from_dict(df0)
    df0.to_csv(output_csv, index=False)
    nbt_label_log.set("Finished !")


if __name__ == "__main__":

    root = tk.Tk()
    root.iconbitmap("icon.ico")
    root.title("RIA")
    root.geometry("600x350")

    title_label = tk.Label(
        master=root, text="Root Image Analyzer (RIA)", font=("Calibri 20 bold")
    )
    title_label.pack()

    ############################################################################
    # Folder selection
    ############################################################################
    folder_frame = tk.Frame(master=root)

    folder_button = tk.Button(
        master=folder_frame,
        text="Select folder",
        font="Calibri 15",
        command=select_folder,
    )

    folder_img_num = tk.StringVar()

    folder_label = tk.Label(
        master=folder_frame,
        text="Select folder containing images",
        font=("Calibri 15"),
        textvariable=folder_img_num,
    )

    ############################################################################
    # Run NBT
    ############################################################################

    nbt_frame = tk.Frame(master=root)

    nbt_button = tk.Button(
        master=nbt_frame,
        text="NBT intensity",
        font="Calibri 15",
        command=run_nbt,
    )

    nbt_label_log = tk.StringVar()

    nbt_label = tk.Label(
        master=nbt_frame,
        text="NBT intensity",
        font=("Calibri 13"),
        textvariable=nbt_label_log,
    )

    ############################################################################
    # Pack layout
    ############################################################################
    folder_frame.pack(pady=20, padx=20, fill="both")
    folder_button.pack(padx=20, side="left", anchor="center")
    folder_label.pack(padx=20, side="right", anchor="center")

    nbt_frame.pack(padx=20, pady=20, fill="both")
    nbt_button.pack(padx=20, side="top", anchor="center")
    nbt_label.pack(padx=20, side="bottom", anchor="center")

    root.mainloop()
