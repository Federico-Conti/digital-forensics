#include <std/mem.pat>

// ------------------------------
// Protective MBR
// ------------------------------
struct PartitionEntry {
    u8  bootIndicator;
    u8  startCHS[3];
    u8  partitionType;
    u8  endCHS[3];
    u32 relativeSectors;
    u32 totalSectors;
};

// ------------------------------
// GPT Header
// ------------------------------
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

// ------------------------------
// GPT Partition Entries
// ------------------------------
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
GPTHeader Secondary_GPTHeader @ (8191 * 512);
GPTPartitionEntry Secondary_gptPartitions[128] @ (Secondary_GPTHeader.partitionEntryLBA * 512);