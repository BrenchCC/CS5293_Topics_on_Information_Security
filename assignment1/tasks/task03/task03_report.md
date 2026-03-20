## Task 03 Report (Encryption Mode: ECB vs. CBC)

### 1) What Was Done
I encrypted BMP images with AES-128 in two modes: `-aes-128-ecb` and `-aes-128-cbc`.

The script processes:
- The provided image [pic_original.bmp](../../assignment1-supplymentary/pic_original.bmp)
- A personal image generated from the provided image by resizing + rotating ([own_picture.bmp](./output/own_picture.bmp))

### 2) Screenshot Evidence (Provided Picture)
Original and encrypted views (after keeping BMP header viewable):
- Original: [provided_original.png](./screenshots/provided_original.png)
- ECB encrypted: [provided_ecb.png](./screenshots/provided_ecb.png)
- CBC encrypted: [provided_cbc.png](./screenshots/provided_cbc.png)

### 3) Screenshot Evidence (Own Picture)
Original and encrypted views:
- Original: [own_original.png](./screenshots/own_original.png)
- ECB encrypted: [own_ecb.png](./screenshots/own_ecb.png)
- CBC encrypted: [own_cbc.png](./screenshots/own_cbc.png)

### 4) Can Useful Information Be Derived from the Encrypted Image?
Yes, from ECB-encrypted images, visible structural patterns and approximate object/layout boundaries can still be inferred. In contrast, CBC-encrypted images appear much more random, and useful visual information about the original content is largely hidden.

### 5) Brief Observations
ECB encrypts identical plaintext blocks into identical ciphertext blocks, so repeated visual patterns remain visible in the encrypted image. CBC introduces chaining with an IV, which breaks these repeating visual patterns and produces a more noise-like output.

### 6) Tools and Methods Used
- OpenSSL `enc` with `-aes-128-ecb` and `-aes-128-cbc`
- `dd` and `cat` to keep BMP header and rebuild encrypted BMP files
- `sips` to export PNG screenshot evidence files
- Size summary artifact: [task03_summary.txt](./output/task03_summary.txt)
