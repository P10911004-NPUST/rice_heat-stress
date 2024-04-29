import os
import tkinter as tk
from tkinter import filedialog
import ttkbootstrap as ttk

root = tk.Tk()
root.title("RIA")
root.geometry("600x350")


def select_folder():
    dirname = filedialog.askdirectory()
    images = [
        i
        for i in os.listdir(dirname)
        if i.lower().endswith((".jpg", ".jpeg", "tif", "tiff", "png"))
    ]
    img_count.set(f"Load in {len(images)} images")
    img_list.set(images)


def select_file():
    dirname = filedialog.askopenfilenames()
    images = [
        i
        for i in os.listdir(dirname)
        if i.lower().endswith((".jpg", ".jpeg", "tif", "tiff", "png"))
    ]

    img_count.set(f"Load in {len(images)} images")
    img_list.set(images)


title_label = tk.Label(
    master=root, text="Root Image Analyzer (RIA)", font=("Calibri 20 bold")
)
title_label.pack()

folder_frame = tk.Frame(master=root)
folder_button = tk.Button(
    master=folder_frame,
    text="Select folder",
    font=("Calibri 15"),
    command=select_folder,
)
folder_frame.pack(pady=20, padx=20)
folder_button.pack(side="top")

file_frame = tk.Frame(master=root)
file_button = tk.Button(
    master=folder_frame,
    text="Select file",
    font=("Calibri 15"),
    command=select_file,
)
file_frame.pack(pady=20, padx=20)
file_button.pack(side="bottom")

img_count = tk.StringVar()
img_list = tk.StringVar()
label_img_count = tk.Label(master=root, textvariable=img_count)
label_img_list = tk.Label(master=root, textvariable=img_list)
label_img_list.pack(side="bottom")
label_img_count.pack(side="right")


root.mainloop()
