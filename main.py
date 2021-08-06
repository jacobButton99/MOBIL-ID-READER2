from __future__ import print_function
import pyzbar.pyzbar as pyzbar
import cv2
from cryptography.fernet import Fernet
from hid import Keyboard
from time import sleep

##############################################################################
#### This is the code for continuous detection and decryption of a qr code
##############################################################################



# uses pyzbar to decode the qr code
def decode_qr(im):
    decoded_id = pyzbar.decode(im)
    if (len(decoded_id) == 0):
        return None
    else:
        return decoded_id[0].data.decode()

# uses Cryptography to decrypt the id
def decrypt_id(encrypted_id):

    key = open("reader.key", "rb").read()
    f = Fernet(key)

    try:
        decrypted_id = f.decrypt(encrypted_id)
    except:
        decrypted_id = None

    return decrypted_id

# sets up camera
capture = cv2.VideoCapture(0)
kbd = Keyboard()

# Contiuios loop for detecting and decoding

while(1):
    # cv2 image capture
    _, img = capture.read()

    # decodes the qr_code
    id_num = decode_qr(img)

    # if a qr code is found the "id" will attempt to be decrypted
    if id_num != None:
        decrypted = decrypt_id(id_num.encode())

        # if the "id" is decrypted succcessfully it will be printed
        if decrypted != None:
            print(decrypted.decode())
            kbd.write(str(decrypted.decode()) + '\n')
            sleep(1)

    
# resets the camera when the code is done
capture.release()
cv2.destroyAllWindows()
