
# text UTF-8 is default create with this system

str = "utf-16 encoding 😉".encode("utf-16")  # Force to encode as UTF-16
with open("python_UTF16.txt", "wb") as f:
    f.write(str)  # Write binary UTF-16 data to file
    
# VIEW DIFFERENCE IN HEX
# file pippo.txt
# xxd pippo.txt