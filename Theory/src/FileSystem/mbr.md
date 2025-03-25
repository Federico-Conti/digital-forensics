## Partition Entry Structure

- **bootIndicator (u8)**:  
    A single byte flag that indicates whether the partition is bootable. A value of 0x80 typically marks the partition as active (bootable), while 0x00 means it’s not.

- **startCHS (u8[3])**:  
    A three-byte array representing the starting address of the partition in CHS (Cylinder-Head-Sector) format. Although CHS is largely obsolete, it historically provided the location on disk where the partition begins.

- **partitionType (u8)**:  
    This byte defines the type of the partition. It specifies the file system or the intended use (for example, FAT, NTFS, Linux swap, etc.) based on predefined type codes.

- **endCHS (u8[3])**:  
    Similar to startCHS, this three-byte array holds the ending address of the partition in CHS format. It marks the final cylinder, head, and sector of the partition.

- **relativeSectors (u32)**:  
    A 32-bit value that indicates the starting sector of the partition relative to the beginning of the disk. This offset tells the system where the partition’s data begins.

- **totalSectors (u32)**:  
    This 32-bit field specifies the total number of sectors contained in the partition, essentially defining its size.

## MBR Structure

- **bootCode (u8[0x1B8])**:  
    An array of 446 bytes that contains the boot loader code. This is the first code executed during system startup and is responsible for initiating the boot process.

- **diskSignature (u32)**:  
    Located immediately after the boot code, this 4-byte field is often used to uniquely identify the disk. Some operating systems (like Windows) use this signature for disk management purposes.

- **reserved (u16)**:  
    A 2-byte field, typically set to zero, that is reserved for future use or specific system requirements. It generally does not contain any active data.

- **partitions (PartitionEntry[4])**:  
    An array of four PartitionEntry structures, each 16 bytes in size. These entries provide details for up to four primary partitions on the disk.

- **signature (u16)**:  
    A 2-byte signature field at the very end of the MBR, which should always contain the value 0x55AA. This signature is used as a sanity check to verify the integrity of the MBR.