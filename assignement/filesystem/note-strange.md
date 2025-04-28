**Combining filesystems Viewer FAT32**

```c 

#include <std/mem.pat>

struct bootSector {
    u8  jumpInstruction[3];    
    char oemID[8];              
    u16 bytesPerSector;        //2048
    u8  sectorsPerCluster;     
    u16 reservedSectors;        //34868
    u8  numberOfFATs;          
    u16 rootEntries;           
    u16 totalSectors16;        
    u8  mediaDescriptor;       
    u16 sectorsPerFAT16;        
    u16 sectorsPerTrack;       
    u16 numberOfHeads;          
    u32 hiddenSectors;          
    u32 totalSectors32;      
      
    /* --- FAT32 extended BPB --- */
    u32 sectorsPerFAT32;        
    u16 flags;                  
    u16 version;               
    u32 rootCluster;           
    u16 fsInfoSector;        
    u16 backupBootSector;       
    u8  reserved[12];           

    /* --- BIOS‐drive and serial --- */
    u8  driveNumber;            
    u8  reserved1;             
    u8  bootSignature;          
    u32 volumeSerialNumber;     
    char volumeLabel[11];      
    char fileSystemType[8];     

    /* --- Boot code and signature --- */
    u8  bootCode[420];          
    u16 signature;              
};

bootSector reservedArea @ 0x00;

struct reservedSectors{
u8 reserve[reservedArea.reservedSectors*2048];
};

struct FAT{

u8 fat[2048];

};

struct fatDataArea{
u8 fatarea[(4193781-35892)*16384]; //16384 cluster size
};


reservedSectors reservesectors @ 0; //reserveSector contain also the 512 reservedArea
FAT fat @ 34868*2048; //0x441A000
fatDataArea fatdataarea @ (35892*2048); //0x461A000
```


**PARTITIONS Viewer**
```c
#include <std/mem.pat>
struct MBRPartitionEntry {
    u8 bootIndicator;
    u8 startCHS[3];
    u8 partitionType;
    u8 endCHS[3];
    u32 relativeSectors;
    u32 totalSectors;
};
struct MBR {
    u8 bootCode[0x1B8]; // 446 bytes
    u32 diskSignature; // offset 0x1B8
    u16 reserved; // offset 0x1BC (often 0x0000)
    MBRPartitionEntry partitions[4]; // 4 partition entries, each 16 bytes
    u16 signature; // offset 0x1FE, should be 0x55AA
 };
 
MBR mbr @ 0x00;

struct PartitionEntry {
    u8  bootIndicator;
    u8  startCHS[3];
    u8  partitionType;
    u8  endCHS[3];
    u32 relativeSectors;
    u32 totalSectors;
};

struct GPTHeader {
    char signature[8];          // "EFI PART"
    u32  revision;              // typically 0x00010000
    u32  headerSize;            // usually 92 (0x5C)
    u32  headerCRC32;           // CRC32 of the header
    u32  reserved;              // must be zero
    u64  currentLBA;            // LBA of this header
    u64  backupLBA;             // LBA of the backup GPT header
    u64  firstUsableLBA;
    u64  lastUsableLBA;
    u8   diskGUID[16];          // 128-bit GUID for the disk
    u64  partitionEntryLBA;     // LBA where partition entries start
    u32  numberOfPartitionEntries;  // number of partition entries
    u32  sizeOfPartitionEntry;      // size of each partition entry (often 128)
    u32  partitionEntryArrayCRC32;  // CRC32 of the partition entries
    u8   reserved2[420];        // 512 - 92 = 420 (fills one 512-byte sector)
};

struct GPTPartitionEntry {
    u8  partitionTypeGUID[16];
    u8  uniquePartitionGUID[16];
    u64 firstLBA;
    u64 lastLBA;
    u64 flags;
    u16 partitionName[36]; // 72 bytes (UTF-16)
};


//SECONDARY

// LBA = fdisk -l console.dd
GPTHeader Primary_GPTHeader @ (1 * 512);
GPTPartitionEntry Primary_gptPartitions[128] @ (Primary_GPTHeader.partitionEntryLBA * 512);

//SECONDARY

// LBA = fdisk -l console.dd
GPTHeader Secondary_GPTHeader @ (16777215 * 512);
GPTPartitionEntry Secondary_gptPartitions[128] @ (Secondary_GPTHeader.partitionEntryLBA * 512);


```

**SuperBlock EXT**
```c
struct ExtSuperblock {
    u32 inodes_count;                  // 0–3 Number of inodes in file system
    u32 blocks_count;                  // 4–7 Number of blocks in file system
    u32 r_blocks_count;                // 8–11 Reserved blocks
    u32 free_blocks_count;             // 12–15 Unallocated blocks
    u32 free_inodes_count;             // 16–19 Unallocated inodes
    u32 first_data_block;              // 20–23 Block where block group 0 starts
    u32 log_block_size;                // 24–27 Block size (shift 1024 << n)
    u32 log_frag_size;                 // 28–31 Fragment size (shift 1024 << n)
    u32 blocks_per_group;              // 32–35 Number of blocks per group
    u32 frags_per_group;               // 36–39 Number of fragments per group
    u32 inodes_per_group;              // 40–43 Number of inodes per group
    u32 mtime;                         // 44–47 Last mount time
    u32 wtime;                         // 48–51 Last written time
    u16 mount_count;                   // 52–53 Current mount count
    u16 max_mount_count;               // 54–55 Maximum mount count
    u16 magic;                         // 56–57 Signature (0xEF53)
    u16 state;                         // 58–59 File system state
    u16 errors;                        // 60–61 Error handling method
    u16 minor_rev_level;               // 62–63 Minor version
    u32 lastcheck;                     // 64–67 Last consistency check time
    u32 checkinterval;                 // 68–71 Interval between checks
    u32 creator_os;                    // 72–75 Creator OS
    u32 rev_level;                     // 76–79 Major version
    u16 def_resuid;                    // 80–81 UID for reserved blocks
    u16 def_resgid;                    // 82–83 GID for reserved blocks
    u32 first_ino;                     // 84–87 First non-reserved inode
    u16 inode_size;                    // 88–89 Size of inode structure
    u16 block_group_nr;                // 90–91 Block group of this superblock
    u32 feature_compat;                // 92–95 Compatible feature flags
    u32 feature_incompat;              // 96–99 Incompatible feature flags
    u32 feature_ro_compat;             // 100–103 Read-only feature flags
    u8  uuid[16];                      // 104–119 File system ID
    char volume_name[16];              // 120–135 Volume name
    char last_mounted[64];             // 136–199 Path where last mounted
    u32 algo_bitmap;                   // 200–203 Algorithm usage bitmap
    u8  prealloc_blocks;               // 204     Number of blocks to preallocate (files)
    u8  prealloc_dir_blocks;           // 205     Number of blocks to preallocate (dirs)
    u16 unused_1;                      // 206–207 Unused
    u8  journal_uuid[16];              // 208–223 Journal ID
    u32 journal_inum;                  // 224–227 Journal inode
    u32 journal_dev;                   // 228–231 Journal device
    u32 last_orphan;                   // 232–235 Head of orphan inode list
    u8  unused_2[788];                 // 236–1023 Unused
};

ExtSuperblock sb @ 0x8000000;
```





**jpg verify**
```bash
losetup -r /dev/loop1 strange.dd
# To verify that the loop device was correctly attached, check system logs
sudo dmesg | tail
# To inspect the loop device and view partition details
sudo fdisk -l /dev/loop1
# Use partx to make partition available
sudo partx -a /dev/loop1
mount -oro /dev/loop1p1 /mnt/strange
binwalk ext3_nashorn_*.jpg
dd if=ext3_nashorn_1.jpg bs=1 skip=139539 of=hidden_payload.bin

```
