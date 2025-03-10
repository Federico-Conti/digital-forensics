


#Challenge 1
    ## Find the string containing the flag inside spaghetti.png
    strings spaghetti.png | grep flag

#Challenge 2
    ## Find the string containing the flag inside spaghetti-with.png
    strings -e S spaghetti-with-meatballs.png | grep flag # FAIL
    ## How many bytes does UTF-8 use to encode the flag?
    strings -e S spaghetti-with-meatballs.png | grep flag | cut -d { -f 2 | cut -d } -f 1 | hexdump -C

#Challenge 3 (BMP)
    ## Swap the width and height values of Dennis Ritchie (https://www.cs.virginia.edu/~jh2jf/courses/cs2130/spring2023/labs/lab2-hex-editor.html)
    ## Open with editor --> check bpm_struct and individual values --> swap width and height values
        """s32 width out;
    s32 height out;
    u64 widthAddr out;
    u64 heightAddr out;

    struct BMPHeader { // Total: 54 bytes
        u16 type; // Magic identifier: 0x4d42
        u32 size; // File size in bytes
        u16 reserved1; // Not used
        u16 reserved2; // Not used
        u32 offset; // Offset to image data in bytes
        u32 dib_header_size; // DIB Header size in bytes (40bytes)
        s32 width_px; // Width of the image
        s32 height_px; // Height of image
        u16 num_planes; // Number of color planes
        u16 bits_per_pixel; // Bits per pixel
        u32 compression; // Compression type
        u32 image_size_bytes; // Image size in bytes
        s32 x_resolution_ppm; // Pixels per meter
        s32 y_resolution_ppm; // Pixels per meter
        u32 num_colors; // Number of colors
        u32 important_colors; // Important colors
    };
    
    
    BMPHeader header @ 0x00;
    width = header.width_px;
    height = header.height_px;
    widthAddr = addressof(header.width_px);
    heightAddr = addressof(header.height_px);
    """
    ## Save and check
    ## see https://www.cs.virginia.edu/luther/CSO1/S2022/lab02-hex-editor.html

# Challenge 4 (JPG)
    ## During a transmission, one of our files got corrupted. Take a look and see if you can do something about it.
    ## 03-Corrupted.jpg --> bit JPG header are corrupted


# Challenge 5 ( steganography JPG)
    ## hide a final warning of hideme_master.jpg
    ## see https://www.ccoderun.ca/programming/2017-01-31_jpeg/ --> serch height 
    ## or use Patern editor:
            """
            #include <std/mem.pat>
            #pragma endian big

            struct Component {
            u8 YComp;
            u8 SamplingFactor;
            u8 QTableNum;
            };

            struct Segment {

                u8 marker;
                u8 segmentId;
                
                if (marker == 0xFF && segmentId == 0xC0) {
                    u16 length;
                    u8 bitsperpixel;
                    u16 height;
                    u16 width;
                    u8 ncomp;
                    Component comp[ncomp];
                } else
                    continue;
            };

            Segment seg[while(!std::mem::eof())] @ 0x00;
            """
    ## decrease height in ImHEX 


# Challenge 6 (data exfiltration)
## Download the .eml (https://github.com/enricorusso/DF_Exs/raw/main/data_organization/mail.eml)

    ### FIRST METHOD

    ## Open in editor and copy out everything from the start of the Base64 block to its end (but not the MIME headers). /9j/4AAQSkZJRgABAQAAAQABAAD/...

    base64 -d signature_base64.txt > signature.jpg
    binwalk signature.jpg # check if there is any hidden data
    binwalk -e signature.jpg # extract hidden data
    unzip hidden.zip
    ## ## increase height in ImHEX to find the password
    
    ### SECOND METHOD
    dd if=signature.jpg of=hidden.zip bs=1 skip=19580
    unzip hidden.zip

    ### THIRD METHOD
    grep -A100000 _bcJPkVe2nbj_lquOawM3OTf mail.eml | grep -A100000  -i "content-type: image/jpeg" | tail -n +6 | cut -d- -f 1 | base64 -d > signature-new.jpg
    binwalk -e signature-new.jpg
    unzip 4C7C.zip




# Challenge 7: hidden file
   binwalk -e 05-Idea.jpg  # is buggy sometimes
   #option1
   binwalk --dd='.*' 05-Idea.jpg 
   #option2
   dd if=05-Idea.jpg of=file.7z bs=1 skip=33519 count=9999999

   7z x file.7z