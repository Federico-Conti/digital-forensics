#include <std/mem.pat>

struct bootSector {
    u8  jumpInstruction[3];
    char oemID[8];
    u16 bytesPerSector;
    u8  sectorsPerCluster;
    u16 reservedSectors;
    u8  numberOfFATs;
    u16 rootEntries;
    u16 totalSectors16;
    u8  mediaDescriptor;
    u16 sectorsPerFAT16;
    u16 sectorsPerTrack;
    u16 numberOfHeads;
    u32 hiddenSectors;
    u32 totalSectors32;
    u8  driveNumber;
    u8  reserved1;
    u8  bootSignature;
    u32 volumeSerialNumber;
    char volumeLabel[11];
    char fileSystemType[8];
    u8  bootCode[0x1C0]; 
    u16 signature;
};

struct fat {
    char filename[8];         // Filename (padded with spaces)
    char extension[3];        // File extension
    u8   attributes;          // File attributes (e.g., read-only, hidden)
    u8   reserved;            // Reserved for Windows NT
    u8   creationTimeTenth;   // Millisecond creation time
    u16  creationTime;        // Time file was created
    u16  creationDate;        // Date file was created
    u16  lastAccessDate;      // Last accessed date
    u16  firstClusterHigh;    // High word of first cluster number
    u16  lastModifiedTime;    // Last modified time
    u16  lastModifiedDate;    // Last modified date
    u16  firstClusterLow;     // Low word of first cluster number
    u32  fileSize;            // File size in bytes
};

bootSector bootSector @ 0x00;

u32 resareasize = bootSector.reservedSectors * bootSector.bytesPerSector;

u32 reservedSectors[resareasizer] @ 0x00 + bootSector.bytesPerSector;

u32 fatsize = bootSector.sectorsPerFAT16 * bootSector.bytesPerSector;


# Volume Boot Sector 


1. **Jump Instruction (jumpInstruction[3])**
    - **Offset:** 0x000 - 0x002
    - **Size:** 3 bytes
    - **Description:** This is the boot code jump instruction (e.g., EB 3C 90).
    - **Purpose:** It tells the CPU where to jump in the boot sector to start executing the bootloader.

2. **OEM Identifier (oemID[8])**
    - **Offset:** 0x003 - 0x00A
    - **Size:** 8 bytes
    - **Description:** ASCII string that identifies the formatting tool (e.g., "MSWIN4.1").
    - **Purpose:** Used by formatting utilities to indicate what created the file system.

3. **Bytes per Sector (bytesPerSector)**
    - **Offset:** 0x00B - 0x00C
    - **Size:** 2 bytes (Little Endian)
    - **Description:** Number of bytes per sector (commonly 512, 1024, 2048, or 4096).
    - **Purpose:** Defines how many bytes make up a single sector.

4. **Sectors per Cluster (sectorsPerCluster)**
    - **Offset:** 0x00D
    - **Size:** 1 byte
    - **Description:** Number of sectors per cluster (power of 2, e.g., 1, 2, 4, 8, etc.).
    - **Purpose:** Determines the size of a cluster (basic allocation unit for files).

5. **Reserved Sectors (reservedSectors)**
    - **Offset:** 0x00E - 0x00F
    - **Size:** 2 bytes
    - **Description:** Number of reserved sectors (usually 1 for FAT16).
    - **Purpose:** The first sector is always reserved for the boot sector; additional reserved sectors may contain file system metadata.

6. **Number of FATs (numberOfFATs)**
    - **Offset:** 0x010
    - **Size:** 1 byte
    - **Description:** Number of File Allocation Tables (typically 2).
    - **Purpose:** Having multiple FATs provides redundancy; if one gets corrupted, the system can recover from the backup.

7. **Root Directory Entries (rootEntries)**
    - **Offset:** 0x011 - 0x012
    - **Size:** 2 bytes
    - **Description:** Maximum number of entries in the root directory (usually 512).
    - **Purpose:** Defines how many files or folders can exist in the root directory.

8. **Total Sectors (16-bit) (totalSectors16)**
    - **Offset:** 0x013 - 0x014
    - **Size:** 2 bytes
    - **Description:** Total number of sectors in the file system (if 0, use totalSectors32).
    - **Purpose:** Determines the total size of the partition.

9. **Media Descriptor (mediaDescriptor)**
    - **Offset:** 0x015
    - **Size:** 1 byte
    - **Description:** Identifies the storage type (e.g., 0xF8 for a hard disk).
    - **Purpose:** Used by the OS to recognize removable vs fixed disks.

10. **Sectors per FAT (sectorsPerFAT16)**
     - **Offset:** 0x016 - 0x017
     - **Size:** 2 bytes
     - **Description:** Number of sectors used by each FAT table.
     - **Purpose:** Helps locate where file allocation information is stored.

11. **Sectors per Track (sectorsPerTrack)**
     - **Offset:** 0x018 - 0x019
     - **Size:** 2 bytes
     - **Description:** Number of sectors per track in CHS addressing.
     - **Purpose:** Used for compatibility with older BIOSes.

12. **Number of Heads (numberOfHeads)**
     - **Offset:** 0x01A - 0x01B
     - **Size:** 2 bytes
     - **Description:** Number of disk heads (e.g., 255 for modern disks).
     - **Purpose:** Part of CHS (Cylinder-Head-Sector) addressing.

13. **Hidden Sectors (hiddenSectors)**
     - **Offset:** 0x01C - 0x01F
     - **Size:** 4 bytes
     - **Description:** Number of hidden sectors before the FAT16 partition.
     - **Purpose:** Used in multi-partition disks to determine the offset.

14. **Total Sectors (32-bit) (totalSectors32)**
     - **Offset:** 0x020 - 0x023
     - **Size:** 4 bytes
     - **Description:** Used if totalSectors16 == 0 (for large partitions).
     - **Purpose:** Supports larger FAT16 partitions.

15. **Drive Number (driveNumber)**
     - **Offset:** 0x024
     - **Size:** 1 byte
     - **Description:** BIOS drive number (e.g., 0x80 for HDD).
     - **Purpose:** Identifies the boot drive.

16. **Reserved Field (reserved1)**
     - **Offset:** 0x025
     - **Size:** 1 byte
     - **Description:** Reserved, often set to 0x00.
     - **Purpose:** Can be used by bootloaders.

17. **Extended Boot Signature (bootSignature)**
     - **Offset:** 0x026
     - **Size:** 1 byte
     - **Description:** If 0x29, the volume serial number, label, and FS type fields exist.
     - **Purpose:** Indicates the presence of extra boot sector fields.

18. **Volume Serial Number (volumeSerialNumber)**
     - **Offset:** 0x027 - 0x02A
     - **Size:** 4 bytes
     - **Description:** Unique identifier for the partition.
     - **Purpose:** Helps differentiate volumes.

19. **Volume Label (volumeLabel)**
     - **Offset:** 0x02B - 0x035
     - **Size:** 11 bytes
     - **Description:** Human-readable name of the volume.
     - **Purpose:** Identifies the disk in file explorers.

20. **File System Type (fileSystemType)**
     - **Offset:** 0x036 - 0x03D
     - **Size:** 8 bytes
     - **Description:** String like "FAT16 ".
     - **Purpose:** Indicates the file system type.

21. **Boot Code (bootCode[0x1BE])**
     - **Offset:** 0x03E - 0x1FD
     - **Size:** 446 bytes
     - **Description:** Contains bootloader instructions.
     - **Purpose:** If the drive is bootable, this code starts the OS.

22. **Boot Sector Signature (signature)**
     - **Offset:** 0x1FE - 0x1FF
     - **Size:** 2 bytes
     - **Description:** Always 0x55AA (little-endian).
     - **Purpose:** Marks the sector as a valid boot sector.


# Directory entry 

1. **File Name and Extension**
    - **Bytes:** 0x00 - 0x0A
    - **Description:** Uses the MS-DOS 8.3 filename format:
        - 8 characters for the filename.
        - 3 characters for the extension.
        - If the first byte is 0xE5, the file has been deleted.
        - If the first byte is 0x05, it encodes 0xE5 for compatibility reasons.

2. **Attribute Byte**
    - **Byte:** 0x0B
    - **Description:** Indicates the file type and properties:
        - 0x01 – Read-Only (RO)
        - 0x02 – Hidden (H)
        - 0x04 – System (S)
        - 0x08 – Volume Label (V)
        - 0x10 – Directory (D)
        - 0x20 – Archive (A) (indicates a file has been modified)
    - These values can be combined (e.g., 0x03 means a file is both Read-Only and Hidden).

3. **Reserved Byte**
    - **Byte:** 0x0C
    - **Description:** Not actively used in FAT12/16. In FAT32, this field is sometimes repurposed.

4. **10ms Create Time**
    - **Byte:** 0x0D
    - **Description:** Stores fine-grained timestamps (only in FAT32). Represents millisecond precision for when the file was created.

5. **Create Time**
    - **Bytes:** 0x0E - 0x0F
    - **Description:** Timestamp when the file was originally created.

6. **Create Date**
    - **Bytes:** 0x10 - 0x11
    - **Description:** Stores the file creation date.

7. **Last Access Date**
    - **Bytes:** 0x12 - 0x13
    - **Description:** Records the last time the file was accessed. Granularity: Only stores the date (not the exact time).

8. **Unused**
    - **Bytes:** 0x14 - 0x15
    - **Description:** Reserved for future use.

9. **Modified Time & Modified Date**
    - **Bytes:** 0x16 - 0x19
    - **Description:** Tracks last file modification (write operation). Granularity: 2-second precision.

10. **Starting Cluster**
    - **Bytes:** 0x1A - 0x1B
    - **Description:** Identifies the first cluster of the file's data. If a file spans multiple clusters, FAT entries track the chain.

11. **File Size**
    - **Bytes:** 0x1C - 0x1F
    - **Description:** 32-bit integer indicating file size (in bytes). Directories have a size of 0.
