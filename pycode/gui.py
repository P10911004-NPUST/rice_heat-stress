import os
import tkinter as tk
from tkinter import filedialog


def select_folder():
    dirname = filedialog.askdirectory()
    images = [
        i
        for i in os.listdir(dirname)
        if i.lower().endswith((".jpg", ".jpeg", "tif", "tiff", "png"))
    ]
    folder_img_list.set(images)
    folder_img_num.set(f"Load in {len(images)} images")


if __name__ == "__main__":

    root = tk.Tk()
    root.title("RIA")
    root.geometry("600x350")

    title_label = tk.Label(
        master=root, text="Root Image Analyzer (RIA)", font=("Calibri 20 bold")
    )
    title_label.pack()

    """ Folder selection
    Select folder only, the program will automatically read in images within the directory specified
    """
    folder_frame = tk.Frame(master=root)

    folder_button = tk.Button(
        master=folder_frame,
        text="Select folder",
        font=("Calibri 15"),
        command=select_folder,
    )

    folder_img_num = tk.StringVar()
    folder_img_list = tk.StringVar()

    folder_label = tk.Label(
        master=folder_frame,
        text="Select folder with images",
        font=("Calibri 15"),
        textvariable=folder_img_num,
    )

    folder_frame.pack(pady=20, padx=20)
    folder_button.pack(padx=20, side="left", anchor="center")
    folder_label.pack(padx=20, side="right", anchor="center")

    root.mainloop()
