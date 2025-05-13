import os
from PIL import Image

def convert_image_format(img_in, img_out):

   if (os.path.isfile(img_in)):
      if (not os.path.exists(os.path.dirname(img_out))):
         os.mkdir(os.path.dirname(img_out))
      img = Image.open(img_in)
      img.save(img_out)

   if (os.path.isdir(img_in)):
      print("Input should be an image file")


img_folder = "./report/images/DAT5_28-vs-38_20240418"
img_list = [i for i in os.listdir(img_folder) if i.lower().endswith((".jpg", ".jpeg", ".png", ".bmp", ".tif", ".tiff"))]
for img_tif in img_list:
   img_tif = os.path.join(img_folder, img_tif)
   img_png = img_tif.replace(".tif", ".png")
   convert_image_format(img_tif, img_png)