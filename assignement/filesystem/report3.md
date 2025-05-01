# strange.dd

This section analyzes the disk image `strange.dd`, which exhibits an unusual dual file system configuration. The image uses a GPT partition scheme with a single partition labeled as `Microsoft basic data`. Within this partition, both FAT32 and Ext3 file systems coexist, creating an ambiguous setup that challenges traditional forensic tools. The analysis explores the partition scheme, identifies the file systems, and extracts their contents.

## Partition Scheme Identification

- The disk image strange.dd uses a GPT partition scheme.
- It includes a Protective MBR and GPT header.
- Only one partition entry is defined in Primary GPT Entries, labeled as `Microsoft basic data`.


```bash
fdisk -l strange.dd
#Output
    Disk strange.dd: 8 GiB, 8589934592 bytes, 16777216 sectors
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    Disklabel type: gpt
    Disk identifier: B5D4692F-0DB0-4356-B0E5-5A70BACB2347

mmls strange.dd
#Output
        Slot      Start        End          Length       Description
    000:  Meta      0000000000   0000000000   0000000001   Safety Table
    001:  -------   0000000000   0000002047   0000002048   Unallocated
    002:  Meta      0000000001   0000000001   0000000001   GPT Header
    003:  Meta      0000000002   0000000033   0000000032   Partition Table
    004:  000       0000002048   0016777182   0016775135   Microsoft basic data
    005:  -------   0016777183   0016777215   0000000033   Unallocated
```

\begin{center}
\includegraphics[width=1 \linewidth]{./assignement/filesystem/media/3.0.png}
\captionof{figure}{Primary GPT Header}
\label{fig:hex-analysis-3}
\end{center}

\begin{center}
\includegraphics[width=1 \linewidth]{./assignement/filesystem/media/3.1.png}
\captionof{figure}{entry[0] in Primary GPT Entries}
\label{fig:hex-analysis-4}
\end{center}


## File System Type Identification

Extract only the partiotion part to better analyze it

```bash
mmcat strange.dd 4 > microsoftdata.dd
```

The `disktype` command reveals something unusual about this partition:
both file systems appear to coexist within the same partition space of ~8 GiB.

```bash
fsstat microsoftdata.dd
#Output
    Multiple file system types detected (EXT2/3/4 or FAT)

disktype microsoftdata.dd
#Output
--- microsoftdata.dd
Regular file, size 7.999 GiB (8588868608 bytes)
    FAT32 file system (hints score 3 of 5)
        Unusual sector size 2048 bytes
        Volume size 7.931 GiB (8515354624 bytes, 519736 clusters of 16 KiB)
        Volume name "FAT32LABEL"
    Ext4 file system
        Volume name "ext3label"
        UUID 66A53AB6-90CE-4122-8B31-8102D0845496 (DCE, v4)
        Last mounted at "/dir/dev1"
        Volume size 7.999 GiB (8588865536 bytes, 2096891 blocks of 4 KiB)
 ```

Potential Scenarios:

- Possible file system-in-file system nesting (e.g., FAT embedded within an EXT partition).
- Hidden Volumes: There could be a FAT file system hidden at a specific offset within the EXT3 partition.

**ImHex analysis**

The analysis confirms the following:

1. Recognizes the FAT32 boot sector at the start of the partition
    - FAT32 characteristics:
        - Sector size: 2048 bytes.
        - Contains only 1 FAT table instead of the standard 2
        - No backup boot sector is present
        - Volume label: `"FAT32LABEL"`

2. An Ext3 SuperBlocks file system resides in the 1024 offset (as required by the standard)

\begin{center}
\includegraphics[width=1 \linewidth]{./assignement/filesystem/media/3.3.png}
\captionof{figure}{FAT boot sector}
\label{fig:hex-analysis-1}
\end{center}

\begin{center}
\includegraphics[width=1 \linewidth]{./assignement/filesystem/media/3.2.png}
\captionof{figure}{Ext3 First SuperBlock}
\label{fig:hex-analysis-2}
\end{center}

This dual file system setup demonstrates forensic techniques (TSK), making it challenging to identify and analyze the true contents of the disk image.



After some attempts to get some hints from strings command:

 ```bash
 strings --radix=d microsoftdata.dd | grep -i -E 'jpg|hint'

 #Output
    4206644 ext3_nashorn_1.jpg
    4206672 ext3_nashorn_2.jpg
    4206700 ext3_nashorn_3.jpg
    4268084 ext3_nashorn_1.jpg
    4268112 ext3_nashorn_2.jpg
    4321332 ext3_nashorn_1.jpg
    4321360 ext3_nashorn_2.jpg
    4321388 ext3_nashorn_3.jpg
    73506912 FAT32_~1JPG
    73507008 FAT32_~2JPG
    73507104 FAT32_~3JPG
    6576670208 There is a  hint here
 ```

**Analysing the HINT**

 ```bash
xxd -s 6576670208 -l 512 microsoftdata.dd

```

This is the suggested paper: **[4.2. Example B: Ext3 and FAT32](https://www.sciencedirect.com/science/article/pii/S2666281722000804)**

An **Ambiguous File System Partition** is a deliberately crafted partition where show:

- it is possible to create ambiguous file system partitions by integrating a guest file system into the structures of a host file system: integrating a fully functional FAT32 into Ext3.
- Traditional forensic tools may detect one, both, or even get confused.

\begin{center}
\includegraphics[width=0.7 \linewidth]{./assignement/filesystem/media/3.4.png}
\captionof{figure}{overview of the construction }
\label{fig:hex-analysis-2}
\end{center}

*"the superblock of Ext3 has a fixed offset of 1024 bytes, which provides enough space for another data structure to be placed before. Therefore, the Ext3 file system serves as the host file system for the combination with FAT32."*

This technique demonstrates the challenges in identifying and analyzing the true contents of a disk image, requiring advanced forensic methods to uncover hidden data.

\clearpage

**Map Both File Systems Precisely**

1. **FAT**

 ```bash
fsstat -f fat microsoftdata.dd
#Output
    FILE SYSTEM INFORMATION
    --------------------------------------------
    File System Type: FAT32

    OEM Name: mkfs.fat
    Volume ID: 0xacd4ced3
    Volume Label (Boot Sector): FAT32LABEL
    Volume Label (Root Directory): FAT32LABEL
    File System Type Label: FAT32
    Next Free Sector (FS Info): 4295003172
    Free Sector Count (FS Info): 0

    Sectors before file system: 2048

    File System Layout (in sectors)
    Total Range: 0 - 4193782
    * Reserved: 0 - 34867
    ** Boot Sector: 0
    ** FS Info Sector: 1
    ** Backup Boot Sector: 0
    * FAT 0: 34868 - 35891 # FAT0
    * Data Area: 35892 - 4193782
    ** Cluster Area: 35892 - 4193779
    *** Root Directory: 35892 - 35899
    ** Non-clustered: 4193780 - 4193782

    METADATA INFORMATION
    --------------------------------------------
    Range: 2 - 266105029
    Root Directory: 2

    CONTENT INFORMATION
    --------------------------------------------
    Sector Size: 2048
    Cluster Size: 16384
    Total Cluster Range: 2 - 519737

    FAT CONTENTS (in sectors)
    --------------------------------------------
    35892-35899 (8) -> EOF
    35900-36059 (160) -> EOF
    36060-36227 (168) -> EOF
    36228-36379 (152) -> EOF
 ```

-  size of the FS is 2048 * 4193782 = 8588865536 bytes.

 2. **Ext3**

 ```bash
 fsstat -f ext3 microsoftdata.dd
#Output
    ....
    CONTENT INFORMATION
    --------------------------------------------
    Block Range: 0 - 2096890
    Block Size: 4096
    Free Blocks: 2027400

    BLOCK GROUP INFORMATION
    --------------------------------------------
    Number of Block Groups: 64
    Inodes per group: 8192
    Blocks per group: 32768
    ....
    Group: 0:
    Inode Range: 1 - 8192
    Block Range: 0 - 32767
    Layout:
        Super Block: 0 - 0
        Group Descriptor Table: 1 - 1
        Data bitmap: 513 - 513
        Inode bitmap: 514 - 514
        Inode Table: 515 - 1026
        Data Blocks: 1027 - 32767
    Free Inodes: 8181 (99%)
    Free Blocks: 0 (0%) # !!!
    Total Directories: 2
    ....
  ``` 

- The FS size is 4096 * 2096890 = 8588861440 bytes.

*To protect FAT32 data from being overwritten by the Ext3 file system, the group descriptor table, the superblock (and their copies) and the respective block bitmaps had to be manipulated. Vice versa, clusters occupied by the Ext3 file system had to be marked as bad in the FAT.*

- Ext3 avoids overwriting Fat32 by marking 0 free blocks in the first group.
- All groups have almost all free blocks except for the first one, where there are no free blocks.

Summary

| Offset (Hex) | Offset (Dec) | Content                |
|--------------|--------------|------------------------|
| 0x00000000   | 0            | FAT32 Boot Sector      |
| 0x00000400   | 1024         | Ext3 Superblock        |
| 0x00008834   | 34868        | FAT                    |
| 0x00008C34   | 35892        | FAT32 Data Area Start  |
| 0x003FFDF5   | 4193781      | FAT32 Data Area End    |

## File System extraction



```bash
sudo mount -o loop,ro -t ext3 microsoftdata.dd /mnt/strange/ext3
#Output
    sha256sum ext3_nashorn_*
    8b79029a06610f29ba1c16e4cd4cf498e196e3a7f67a53efebb32f720f3d472d  ext3_nashorn_1.jpg
    0cb84374324e13606bb22b4164323bb487f9088e4a2cc700673180256174e294  ext3_nashorn_2.jpg
    193067cecbd63195bfab2f3f702cc44ff3c6e6fa8de5335a405fbeb9955c3512  ext3_nashorn_3.jpg

sudo mount -o loop,ro -t vfat microsoftdata.dd /mnt/strange/fat32
#Output
    sha256sum fat32_nashorn_*
    8b79029a06610f29ba1c16e4cd4cf498e196e3a7f67a53efebb32f720f3d472d  fat32_nashorn_1.jpg
    0cb84374324e13606bb22b4164323bb487f9088e4a2cc700673180256174e294  fat32_nashorn_2.jpg
    193067cecbd63195bfab2f3f702cc44ff3c6e6fa8de5335a405fbeb9955c3512  fat32_nashorn_3.jpg
```


## Failed attempts

Try to mount the image by jumping directly to the Ext3 superblock FAIL

```bash
mount -o ro,loop,offset=1024 microsoftdata.dd /mnt/strange
#Output
    mount: /mnt/strange: wrong fs type, bad option, bad superblock on /dev/loop0, m
    missing codepage or helper program, or other error.
        dmesg(1) may have more information after failed mount system call.

```

Let's go look for the backuop superblock and mount with resepct offest also fail:

 - To protect FAT32 data from being overwritten by the Ext3 file system, the group descriptor table, the superblock (and their backup) and the respective block bitmaps are manipulated,

```bash
dumpe2fs microsoftdata.dd | grep -i superblock
#Output
    Primary superblock at 0, Group descriptors at 1-1
    Backup superblock at 32768, Group descriptors at 32769-32769
    ...
    ...
    ...

```

Zeroing out the first 512 bytes allowed successful mounting of the Ext3 file system; however, the FAT32 file system specifications were lost in the process.

```bash
cp microsoftdata.dd microsoftdata_clean.dd

dd if=/dev/zero of=microsoftdata_clean.dd bs=512 count=1 conv=notrunc

sudo mount -o ro,loop microsoftdata_clean.dd /mnt/strange
```