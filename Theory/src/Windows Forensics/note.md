# Windows Forensics Notes

## FTK (Forensic Toolkit)

- **Partition Structure**:  
    Being an HP computer, the OS included a recovery partition, resulting in multiple partitions.

- **Key Files in [root] (equivalent to C: drive)**:
    - `pagefile.sys`: A paging file used by the OS. It can contain fragments of memory, such as URLs or other data, that were paged to disk during system operation.
        > Example: If a browser is active and part of its memory is paged to disk, the `.onion` URL being accessed might end up in `pagefile.sys`.
    - `hiberfile.sys`: A hibernation file that contains a snapshot of the RAM at the moment the system enters hibernation.

- **Primary Investigation Areas**:
    - **`/Windows`**: Contains OS executables, registries, and other system files.
        - `/System32/config`: Windows registry files.
        - `/prefetch`: A mechanism to optimize application startup by preloading necessary DLLs.  
            > Note: A prefetch file is created only if the executable has been run. Prefetch files are not deleted automatically.
    - **`/Users`**: Contains a subfolder for each user.
        - `/AppData`: Logs user activities.
            - `/Roaming/Microsoft/Windows/`: Tracks recent user activities.
                - `.lnk` files: Shortcut files pointing to other files.  
                    > Example: A `.lnk` file is created every time an executable is opened.
                - Tracks external devices like USB drives.

- **FTK Limitations**:
    - Restricted to the graphical interface.
    - Some files cannot be opened due to the lack of a viewer.
    - Requires mounting a disk and assigning it a drive letter for certain operations.

---

## Arsenal Image Mounter (AIM)

- **Purpose**: Treats a forensic image as if it were a physical disk. Acts as middleware for Windows.
- **Read-Only Mode**: Prevents write permissions.
- **Write Mode**: Uses "AIM Write Filter" to create a differential file (`HD1.E01.diff`) that tracks changes.  
    > This allows permission modifications without altering the original forensic image.

---

## Windows Registry

Ccliner è un tool per cancellare tutto il registro.


- **Overview**: Every action on Windows modifies a value in a registry hive.  
    > Example: A damaged registry file might result in the error "Cannot find the filesystem."

- **Key Features**:
    - Each key modification updates a timestamp (last accessed time).  
        > Note: `Regedit` does not display this field.
    - Registry files cannot be modified directly, even with maximum privileges, as they are in use by the system.  
        > Interaction with `Regedit` is mediated by the `System` user, which has write permissions.

### System Hives
- `HKLM\SAM`: `%WINDIR%\System32\config\SAM`
- `HKLM\SECURITY`: `%WINDIR%\System32\config\SECURITY`
- `HKLM\SOFTWARE`: `%WINDIR%\System32\config\SOFTWARE`
    > tipo di sistema operativo e qunado è stato installato
- `HKLM\SYSTEM`: `%WINDIR%\System32\config\SYSTEM`  
    > Contains system-wide settings, such as timezone configurations.

### User Hives
- `HKCU\`: `%USERS%\<username>\NTUSER.DAT`  
    > Core of user configurations and historical activities.
- `HKCU\Software\`: `%USERS%\<username>\AppData\Local\Microsoft\Windows\USRCLASS.DAT`  
    > Tracks the history of navigated folders.

---

## Registry Explorer

- **Functionality**: Allows viewing all information stored in Windows registry files.
- **Features**: Displays a "Last Write Timestamp" column, indicating when a file was last accessed or modified.

**Accessing Host PC Hives**
To view the host PC's hives, ensure the application is running in administrator mode.

**Handling Registry Files from External Images**
When retrieving registry files from external images, you might encounter the following error message:  
**"Primary and secondary sequence numbers do not match!"**

Cause:

    This error occurs when the registry file contains uncommitted data (not yet written permanently) stored in transaction logs. The primary and secondary sequence numbers are used to ensure file integrity. A mismatch indicates that the file was not closed properly, possibly due to an unexpected shutdown or system crash.

Steps to Resolve:

    1. Click **Yes** when prompted.  
        - The system will automatically apply the transaction log data to the hive file, restoring it to the most recent consistent state.

    2. A dialog box will appear, prompting you to select the transaction log files.  
        - Choose the following files:
        - `SOFTWARE.LOG2`
        - `SOFTWARE.LOG1`

    3. Specify the path to save the cleaned hive file (e.g., `SOFTWARE.clean`).

    4. "Do you eant to laod the updated dirve?"
        -  select **Yes**

    4. **"Do you want to load the dirty hive?"**
        -  select **No** 


Next time you can directly upload the .clean file

- **User Information**:
  - Found in `%WINDIR%\System32\config\SAM`
  - Default Windows includes 4 well-known users
  - Additional created users start from ID 1001
  
  | User ID | User Name |
  |---------|-----------|
  | 500     | Admin_IIT |
  | 501     | Guest |
  | 503     | DefaultAccount |
  | 504     | WDAGUtilityAccount |
  | 1001    | UsrICT |

- **Timeline Construction**:
  - Important to use correct timestamp format
  - Information is stored in UTC, not local time
  - Local time is calculated as UTC +/- timezone offset

## System Configuration

1. `SOFTWARE\Microsoft\Windows NT\CurrentVersion`:
    - Contains OS version details, build information, and installation dates.
    - **Unix Epoch Format**:  
      Represents installation date/time as seconds since January 1, 1970, 00:00:00 UTC. Commonly used in system logs and databases.
    - **Windows File Time Format**:  
      Microsoft's proprietary timestamp format, measuring 100-nanosecond intervals since January 1, 1601, 00:00:00 UTC. Used in the registry for the "InstallTime" value.

2. `SYSTEM\Select`:
    - The `Select` key contains values such as:
      - `Current`: Indicates the currently active `ControlSet`.
      - `Default`: Indicates the `ControlSet` to be used at the next boot.
      - `LastKnownGood`: Indicates the `ControlSet` used during the last successful configuration.
      - `Failed`: Indicates a `ControlSet` that failed to work correctly.

3. `SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName`:
    - Stores the computer's name.

4. `SYSTEM\CurrentControlSet\Control\TimeZoneInformation`:
    - Contains timezone configuration details.

5. `SYSTEM\CurrentControlSet\Services`:
    - Each subkey represents a system service or driver.  
      - Contains values specifying:
         - The executable path of the service/driver.
         - Startup type (automatic, manual, or disabled).
         - Dependencies on other services.
         - Service/driver-specific parameters.
    - **Network TCP/IP Parameters**:  
      Tracks IP assignments to the machine when connecting to different networks.

6. `SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces`:
    - Contains a subkey for each network adapter (e.g., Ethernet, Wi-Fi).
    - Stores TCP/IP configuration details for each interface.
    - Tracks the last assigned IP address for each interface.
    - Does not directly indicate which network the adapter was connected to or the connection timestamps.
    - The network name can be freely set by the user or system.

     > **Note**: The value in `lease` is always in UTC format.

7. `SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList`:
    - Maintains a history of all networks the PC has connected to.
    - For each network, stores details such as:
      - Network name.
      - Gateway (router) information.
      - MAC address of the gateway.  
         > The MAC address uniquely identifies a network adapter. The first 24 bits of the MAC address indicate the manufacturer (lookup tools are available online to identify the vendor).

    > **Note**: The `FIRST connect local` value indicates the local date and time (PC timezone) when the computer first connected to a network.  
    > This is **not** in UTC format.  
    > Always verify the timezone of timestamps when constructing event timelines to avoid misinterpretation.

**How Wi-Fi Networks Work**

- When viewing available Wi-Fi networks, the device displays:
  - Network name (SSID).
  - Signal strength.
  - A prompt for a password if required.
- **Why are networks visible?**  
  Access Points (APs) periodically broadcast 802.11 packets called "beacons," which include the network name (SSID) and MAC address.
- As the device moves, it detects nearby Wi-Fi networks through these beacons.
- Websites like [wigle.net](https://wigle.net/) collect information about Wi-Fi networks and their MAC addresses globally.

**Forensic Analysis of MAC Addresses**
- By analyzing the Windows registry, MAC addresses of routers (gateways) the PC connected to can be extracted.
- These MAC addresses can be searched on platforms like wigle.net to potentially locate the geographic position of a network.
- **Caution**: Access Points (APs) can be moved or reconfigured, so their location may not always be static.


8. `SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall`:
    - Lists all installed 64-bit programs that can be uninstalled.
    - Contains installation path information, useful for tracing installations from external media.

9. `SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall`:
    - Same as above but for 32-bit applications.

10. `SYSTEM\CurrentControlSet\Control\Windows`:
    - Contains critical system timing information.
    - `ShutdownTime`: Records the exact time of the last system shutdown in Windows File Time format.  
      Useful for determining when the system was last properly shut down and for timeline continuity during forensic analysis.

11. `SOFTWARE\Microsoft\Windows\CurrentVersion\Run`:
    - Lists programs that start automatically at system boot.
    - These programs start regardless of which user logs in.
    - Critical for identifying persistent malware or unauthorized applications.

## User Activities

1. `NTUSER.DAT\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall`  
   - Tracks all installed applications for the user.

2. `NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs`  
   - Tracks recently opened files by the user.  
   - For each file extension, stores the last 20 files opened.  
   - Contains an `MRUList` value that tracks the order in which files were accessed.  
     - **Note**: The `MRUList` value stores the order of file identifiers in 4-byte chunks.  
   - The `RecentDocs` key contains a list of the last 150 files opened, regardless of extension, in chronological order.  
     - Limitation: Does not track the file path.  
     - Solution: Use the `OpenSavePidlMRU` key, which tracks fewer files but includes the file path.  

3. `NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\LastVisitedPidlMRU`  
   - Tracks the last path of files opened for each executable.

4. `NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\OpenSavePidlMRU`  
   - Tracks the last files opened for each file extension.  
   - Includes the file path.

5. `NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist`  
   - Tracks executables run by the user.  
   - **Note**: If only the application name is visible (without the path), it indicates the executable was run directly from the user's home directory.  
   - **Historical Functionality**: Introduced in Windows XP and still present today, it tracks the most frequently used applications by the user.  
     - **Purpose**: Historically used to manage the population of the Windows Start Menu.  
     - Tracks detailed information about applications executed by each user.  
   - **Caution with `RunTimeCounter`**:  
     - Example: "Chrome was executed 17 times, was in focus at least 9 times, and was active for at least 9 minutes."  
     - These values may sometimes be reset or deleted by the OS under certain conditions.
