#include <std/mem.pat>

struct bootSector {
    u8  jumpInstruction[3];     // 00h: Jump Code + NOP
    char oemID[8];              // 03h: OEM Name
    u16 bytesPerSector;         // 0Bh: Bytes Per Sector
    u8  sectorsPerCluster;      // 0Dh: Sectors Per Cluster
    u16 reservedSectors;        // 0Eh: Reserved Sector Count
    u8  numberOfFATs;           // 10h: Number of FATs
    u16 rootEntries;            // 11h: Root Entries (0 for FAT32)
    u16 totalSectors16;         // 13h: Total Sectors (if < 0x10000; else see totalSectors32)
    u8  mediaDescriptor;        // 15h: Media Descriptor
    u16 sectorsPerFAT16;        // 16h: Sectors per FAT (0 for FAT32)
    u16 sectorsPerTrack;        // 18h: Sectors Per Track
    u16 numberOfHeads;          // 1Ah: Number of Heads
    u32 hiddenSectors;          // 1Ch: Hidden Sectors
    u32 totalSectors32;         // 20h: Total Sectors (if totalSectors16 == 0)

    /* --- FAT32 extended BPB --- */
    u32 sectorsPerFAT32;        // 24h: Sectors Per FAT
    u16 flags;                  // 28h: Flags (mirroring, active FAT copy)
    u16 version;                // 2Ah: Version (high=major, low=minor)
    u32 rootCluster;            // 2Ch: Root directory start cluster (usually 2)
    u16 fsInfoSector;           // 30h: FSInfo sector number
    u16 backupBootSector;       // 32h: Backup boot sector number
    u8  reserved[12];           // 34h: Reserved

    /* --- BIOS‐drive and serial --- */
    u8  driveNumber;            // 40h: Logical Drive Number
    u8  reserved1;              // 41h: Unused
    u8  bootSignature;          // 42h: Extended boot signature (0x29)
    u32 volumeSerialNumber;     // 43h: Volume Serial Number
    char volumeLabel[11];       // 47h: Volume Label (padded)
    char fileSystemType[8];     // 52h: File system type (“FAT32   ”)

    /* --- Boot code and signature --- */
    u8  bootCode[420];          // 5Ah: Executable Boot Code
    u16 signature;              // 1FEh: 0xAA55
};

bootSector reservedArea @ 0x00;
