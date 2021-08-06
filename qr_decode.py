from __future__ import print_function
import pyzbar.pyzbar as pyzbar
import cv2

def decode_qr(im):
    decoded_id = pyzbar.decode(im)
    if (len(decoded_id) == 0):
        return 0
    else:
        return decoded_id[0].data.decode()

im = cv2.imread("qrcode.png")

id_num = decode_qr(im)

print(id_num)