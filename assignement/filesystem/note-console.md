```bash





````bash
xz -dk console.dd.xz
sudo mount -oro console.dd /mnt/console1
strings -e S xbox.jpg | hexdump

file console.dd
#
console.dd: DOS/MBR boot sector, code offset 0x3c+2, OEM-ID "mkfs.fat", sectors/cluster 4, root entries 512, sectors 8192 (volumes <=32 MB), Media descriptor 0xf8, sectors/FAT 6, sectors/track 32, serial number 0xb9e28db8, unlabeled, FAT (12 bit)
#

      00000000  ff d8 ff e0 0a 4a 46 49  46 0a 32 22 33 2a 37 25  |.....JFIF.2"3*7%|
```

```bash


fdisk -l console.dd
#
Disk console.dd: 4 MiB, 4194304 bytes, 8192 sectors # 
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x00000000
#

mmls console.dd
#
GUID Partition Table (EFI)
Offset Sector: 0
Units are in 512-byte sectors

      Slot      Start        End          Length       Description
000:  -------   0000000000   0000002047   0000002048   Unallocated
001:  002       0000002048   0000008158   0000006111   Linux filesystem
002:  Meta      0000008159   0000008190   0000000032   Partition Table
003:  -------   0000008159   0000008191   0000000033   Unallocated
004:  Meta      0000008191   0000008191   0000000001   GPT Header
#

img_stat console.dd
#
IMAGE FILE INFORMATION
--------------------------------------------
Image Type: raw

Size in bytes: 4194304
Sector size:    512
#


mmls -t gpt console.dd
#
GUID Partition Table (EFI)
Offset Sector: 0
Units are in 512-byte sectors

      Slot      Start        End          Length       Description
000:  -------   0000000000   0000002047   0000002048   Unallocated
001:  002       0000002048   0000008158   0000006111   Linux filesystem
002:  Meta      0000008159   0000008190   0000000032   Partition Table
003:  -------   0000008159   0000008191   0000000033   Unallocated
004:  Meta      0000008191   0000008191   0000000001   GPT Header

fsstat -o 2048 console.dd
#
FILE SYSTEM INFORMATION
--------------------------------------------
File System Type: NTFS
Volume Serial Number: 46ACAF237FF4C000
OEM Name: NTFS
Version: Windows XP

METADATA INFORMATION
--------------------------------------------
First Cluster of MFT: 4
First Cluster of MFT Mirror: 381
Size of MFT Entries: 1024 bytes
Size of Index Records: 4096 bytes
Range: 0 - 65
Root Directory: 5

CONTENT INFORMATION
--------------------------------------------
Sector Size: 512
Cluster Size: 4096
Total Cluster Range: 0 - 762
Total Sector Range: 0 - 6109

$AttrDef Attribute Values:
$STANDARD_INFORMATION (16)   Size: 48-72   Flags: Resident
$ATTRIBUTE_LIST (32)   Size: No Limit   Flags: Non-resident
$FILE_NAME (48)   Size: 68-578   Flags: Resident,Index
$OBJECT_ID (64)   Size: 0-256   Flags: Resident
$SECURITY_DESCRIPTOR (80)   Size: No Limit   Flags: Non-resident
$VOLUME_NAME (96)   Size: 2-256   Flags: Resident
$VOLUME_INFORMATION (112)   Size: 12-12   Flags: Resident
$DATA (128)   Size: No Limit   Flags:
$INDEX_ROOT (144)   Size: No Limit   Flags: Resident
$INDEX_ALLOCATION (160)   Size: No Limit   Flags: Non-resident
$BITMAP (176)   Size: No Limit   Flags: Non-resident
$REPARSE_POINT (192)   Size: 0-16384   Flags: Non-resident
$EA_INFORMATION (208)   Size: 8-8   Flags: Resident
$EA (224)   Size: 0-65536   Flags:
$LOGGED_UTILITY_STREAM (256)   Size: 0-65536   Flags: Non-resident
#

```


```bash
dd if=console.dd of=ntfs.dd bs=512 skip=2048 count=6110

mount -oro  ntfs.dd /mnt/console1

file ps5.jpg
ps5.jpg: JPEG image data, JFIF standard 1.01, resolution (DPI), density 72x72, segment length 16, baseline, precision 8, 400x225, components 3

```



``` bash

fls -rp console.dd -o 0
r/r 4:  xbox.jpg
v/v 130867:     $MBR
v/v 130868:     $FAT1
v/v 130869:     $FAT2
V/V 130870:     $OrphanFiles

fls -rp console.dd -o 2048
#
r/r 4-128-1:    $AttrDef
r/r 8-128-2:    $BadClus
r/r 8-128-1:    $BadClus:$Bad
r/r 6-128-1:    $Bitmap
r/r 7-128-1:    $Boot
d/d 11-144-2:   $Extend
r/r 25-144-2:   $Extend/$ObjId:$O
r/r 24-144-3:   $Extend/$Quota:$O
r/r 24-144-2:   $Extend/$Quota:$Q
r/r 26-144-2:   $Extend/$Reparse:$R
r/r 2-128-1:    $LogFile
r/r 0-128-1:    $MFT
r/r 1-128-1:    $MFTMirr
r/r 9-128-2:    $Secure:$SDS
r/r 9-144-3:    $Secure:$SDH
r/r 9-144-4:    $Secure:$SII
r/r 10-128-1:   $UpCase
r/r 10-128-2:   $UpCase:$Info
r/r 3-128-3:    $Volume
r/r 64-128-2:   ps5. #  64: This is likely the MFT entry number, which uniquely identifies the file or directory within the Master File Table.

V/V 65: $OrphanFiles
-/r * 16:       $OrphanFiles/OrphanFile-16
-/r * 17:       $OrphanFiles/OrphanFile-17
-/r * 18:       $OrphanFiles/OrphanFile-18
-/r * 19:       $OrphanFiles/OrphanFile-19
-/r * 20:       $OrphanFiles/OrphanFile-20
-/r * 21:       $OrphanFiles/OrphanFile-21
-/r * 22:       $OrphanFiles/OrphanFile-22
-/r * 23:       $OrphanFiles/OrphanFile-23

```

``` bash 
foremost -i console.dd -o output_dir/

icat -r -o 2048 console.dd 0 > MFT.bin

 C:\Users\feconti\Desktop\DF-sw\ZimmermanTools\MFTECmd.exe -f MFT.bin --csv .\ --csvf console_mft.csv
```







Qualcuno ha formattato velocemente LBA 0 con FAT12, ma ha dimenticato di cancellare il GPT di backup e le sue voci di partizione, che puntano ancora a quello che sembra un volume ext-familiare che inizia al settore 2048.

Qualcuno ha formattato velocemente il primo MiB con un piccolo volume FAT, ma non ha mai pulito la GPT di backup, lasciando la partizione NTFS originale (≈ 3 MiB) completamente recuperabile.