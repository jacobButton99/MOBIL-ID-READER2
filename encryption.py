from cryptography.fernet import Fernet


#key = Fernet.generate_key()
#with open("secret.key", "wb") as key_file:
#    key_file.write(key)

def encrypt_id(id):
    """
    Encrypts a id
    """
    key = open("/home/pi/MOBIL-ID-Reader2/reader.key", "rb").read()
    encoded_id = id.encode()
    f = Fernet(key)
    encrypted_id = f.encrypt(encoded_id)

    return encrypted_id

def decrypt_id(encrypted_id):
    """
    Decrypts an encrypted id
    """
    key = open("/home/pi/MOBIL-ID-Reader2/reader.key.key", "rb").read()
    f = Fernet(key)
    try:
        decrypted_id = f.decrypt(encrypted_id)
    except:
        decrypted_id = None

    return decrypted_id


encrypted = encrypt_id("12345678")
print(encrypted)


decrypted = decrypt_id(encrypted.decode().encode())
print(decrypted.decode())