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

Note: the LAST MODIFIED is also when a file finishes downloading

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
- All Date are in UTC Format 

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

---

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

**Network TCP/IP Parameters**:  
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
(e.g UTC = LOCAL+5h)

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
    
---

## User Activities

1. `NTUSER.DAT\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall`  
   - Tracks all installed applications for the user.
   - inserts the installed apps with the user setup.

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
   -  `{CEBFF...}` trace the execution of the app directly with a click on the .exe
   - `{F4E57...}` trace the execution of applications by clicking on the .lnk

   - **Note**: If only the application name is visible (without the path), it indicates the executable was run directly from START or Task Bar
   - **Historical Functionality**: Introduced in Windows XP and still present today, it tracks the most frequently used applications by the user.  
     - **Purpose**: Historically used to manage the population of the Windows Start Menu.  
     - Tracks detailed information about applications executed by each user.  
   - **Caution with `RunTimeCounter`**:  
     - Example: "Chrome was executed 17 times, was in focus at least 9 times, and was active for at least 9 minutes."  
     - These values may sometimes be reset or deleted by the OS under certain conditions.

---

## LNK Files / Shortcut Files

A pointer saved in a file with the `.lnk` extension.  

        - A shortcut to execute an application on the user's desktop.
        - A shortcut to open a file automatically created (e.g., recent file).

Windows automatically creates `.lnk` files in the "Recent" folder for non-executable files opened by the user.
 -  `C:\Users\user\AppData\Roaming\Microsoft\Windows`
 - `.lnk` files persist even if the target file is deleted
 - `.lnk` is also created for the parent folder of the target file (This makes it possible to reconstruct the folder tree)

Content:

- Target drive type (Fixed, Removable, Network).
- Path of the target file.
      - Drive letter, volume label, and volume serial number (for local drives).
      - Network path and drive letter (optional, for network resources).
- Target file MAC timestamps (Modified, Accessed, Created).
- Target file size.

Types of .lnk Files

1. User-Created: (not relevant and not saved in Recent Folder)
    - These are manually created by users, often during the setup 
    of an application or to speed up the launch of a program.
    Example: A shortcut placed on the desktop to quickly open a frequently used application.

2. System-Created: 
    - Automatically generated by the operating system whenever 
    a non-executable file (e.g., Word, Excel) is opened.
    Example: Opening a .docx file creates a .lnk file that contains metadata about the target file.

 - Use FTK (Forensic Toolkit) to mount the disk and navigate to the "Recent" folder.  
        > Accessing the folder locally may not be possible due to system restrictions.

If the file is deleted, the shortcut link remains intact.  

There are Windows tasks designed to delete the "Recent" folder.

1. `%USERS%\<username>\AppData\Roaming\Microsoft\Windows\Recent`

- For each non-executable file opened, the OS generates two `.lnk` files:
    1. One pointing to the target file.
    2. One pointing to the parent folder of the target file.
- The "Recent" folder can store up to 149 `.lnk` files per user. In most cases, this limit may be exceeded.

- **Creation Time**:  
    Indicates the first time a file with that name was opened.
- **Modified Time**:  
    Indicates the last time a file with that name was opened.

- **Source (.lnk)**:
    Indicates the first and last time the pointed file was opened.
- **Target**:
    Indicates if a pointed file was copied to its destination.

Note:

- **Source Creation == Source Modified**  
This means the original file was opened only once and was not modified afterward.

- **Target Modification < Target Creation**
This scenario indicates that the target file was mass-copied from a source. The modification of the target occurred before its creation, suggesting the file already existed in another location.
So the date of Mofica is inherited while the date of Creation is updated.

- **Source Created == Target Created**  
This indicates that the `.lnk` file was automatically created following the creation of the original file.

Some records have missing TIME values. Why?

- The column "Target MFT Entry Number" provides the entry of the pointed file in the MFT of the volume where it resides.
- If the value is 0x0, the OS was unable to access the MFT of that file to save it.
- This is not a processing/parsing error.

In windows 11 when I create a vine file, I still create an .lnk file and therefore it is not associated with the first opening.


**Volume Serial NUmber**
When we format a storage device and create a volume, a Serial Number is generated and stored in the Volume Boot Record (VBR). The Volume Boot Record is located in the first 512 bytes of the volume and contains important metadata about the file system.

This Serial Number is software-generated and is not tied to the physical hardware of the device. The hardware Serial Number, on the other hand, is embedded in the firmware of the storage device and is unique to the physical device itself.


**LECmd**

Automatically scans `.lnk` files and entire folders, providing output in `.csv` format that can be parsed using TimelineExplorer.

- `Lecmd.exe –f “filename.lnk”`
- `Lecmd.exe –d <PATH-TO-FOLDER> --csv <PATH-TO-OUTPUT>`

-  `Lecmd.exe –f “filename.lnk” `
-  `Lecmd.exe –d <PATH-TO-FOLDER> --csv <PATH-TO-OUTPUT> `

---

## Jumplists

Windows 7/8/10 Taskbar Feature

- **Purpose**:
  - Opening an app.
  - Accessing a recently opened file.
  - Navigating to a recently opened folder.
  - Visiting a recently opened website.
- Contains more references to opened files than "RecentDocs" and the "Recent" folder.

Stored in the user's "Recent" folder:
- Contains two subfolders:
  - `AutomaticDestinations`: Sequence of `.lnk` files added whenever an app is opened.
  - `CustomDestinations`: Each app stores custom data (e.g., Chrome stores most visited websites).

Each application has a unique AppID.  
Reference: [AppIDs List](https://github.com/EricZimmerman/JumpList/blob/master/JumpList/Resources/AppIDs.txt)

Advantages:

- Tracks how and with which app a file was opened, not just that it was opened.
- For a given app, it can show the last 2,000 (or more) files opened.
- Jumplists persist even after uninstalling an app.
- Provides evidence of both file opening and application execution.

- **Creation Time**: Indicates the first time the application was executed.
- **Modified Time**: Indicates the last time the application was executed.
- **Interaction Count**: Tracks how many times a file was opened.

Note:

- The **Source Created** timestamp is identical for all files because it reflects the creation date of the `.automaticDestinations-ms` file itself.  
  There is no individual creation or modification date associated with each element within the file, as it is a single container holding all entries.  
  Correlate the "Creation" and "Modified" timestamps of the `.automaticDestinations-ms` file to analyze the timeline accurately.

- For any given file, there may be several records. Check the source to identify different applications.

- Each application version has its own AppID, so we can have a more historical view

**JLECmd**

Automatically scans `.lnk` files and entire folders, providing output in `.csv` format that can be parsed using TimelineExplorer.

- `JLecmd.exe –f “AppID.automaticDestinations-ms”`
- `JLecmd.exe –d <PATH-TO-FOLDER> --csv <PATH-TO-OUTPUT> -q`

---

## USB Device Analysis

1. `SYSTEM\CurrentControlSet\ENUM\USB`
   - Every time a USB device is connected to the PC, a key is created under the `\USB` registry path.  
   - Each vendor and product combination is grouped under the same parent key.  

   **Key Structure**:  
   - **VID (Vendor ID)**: Identifies the manufacturer of the USB device.  
   - **PID (Product ID)**: Specifies the product model.  

These identifiers are assigned by Microsoft to ensure compliance. Manufacturers must obtain VID and PID from Microsoft to create compliant devices.

   Each subkey represents the physical serial number of the USB device stored in its firmware.  
   - If the registry contains a record with `Service=USBSTR`, it indicates that the USB device can store data.

2. `SYSTEM\CurrentControlSet\ENUM\USBSTOR` 
   - Contains similar information as the previous registry path but with VID and PID explicitly written.  
   - Includes a `FriendlyName` record, which represents how the USB device identifies itself to the OS.  
     - **Note**: Branded devices typically provide a descriptive string, while generic or non-compliant devices may not.

3. `SYSTEM\CurrentControlSet\ENUM\USBSTOR\<device>\<S/N>\Properties\{83da6326-97a6-4088-9453-a1923f573b29}` 
   - Under the `Properties` subkey, timestamps are stored:  
     - **0064**: First connection of the USB device.  
     - **0066**: Last time the device was connected.  
     - **0067**: Last time the device was removed (safe or unsafe eject).

4. `SOFTWARE\Microsoft\Windows NT\CurrentVersion\EMDMgmt` 
   - The Volume Serial Number changes every time a storage device is formatted.  
   - This registry key contains a subkey for each connected device, represented by a string with VID, PID, and the last part of the string being the Volume Serial Number in hexadecimal format.  
   - To identify the physical device used, convert the hexadecimal Volume Serial Number and compare it with the Volume Serial Number found in `.lnk` file records.

---

## Prefetch

The Prefetch feature in Windows is designed to improve system performance by preloading libraries and code required by applications. It tracks the dynamic link libraries (DLLs) that an executable depends on, allowing the system to optimize application startup times.


- Enhances performance by caching frequently used libraries and code.
-  Prefetch data is stored in `.pf` files located in `C:\Windows\Prefetch`.
    - One `.pf` file is created per executable.
    - Windows Vista/7: Maximum of 128 `.pf` files.
    - Windows 8/10: Maximum of 1024 `.pf` files.
    - Windows Vista/7: Tracks the last time the executable was run.
    - Windows 8/10: Tracks the last 8 times the executable was run.

When an executable is launched, Windows monitors its activity for the first 10 seconds. During this period:

- The system identifies and records the DLLs required by the application.
- If a file is opened (e.g., via "Open/File"), the file is also logged in the Prefetch data.

This behavior is particularly useful for forensic analysis, as it provides insights into application usage and associated files.

**PECmd**
Parses Prefetch files to extract detailed information.

- Tracks the number of times an executable has been launched (`Run Count`).
- Provides timeline for the applications.

- `PECmd.exe –d <PATH-TO-PREFETCH-FOLDER> --csv <PATH-TO-OUTPUT>`
- `PECmd.exe –f “filename.pf”`


Consider launching Google Chrome:

- During the first 10 seconds, Prefetch records all DLLs Chrome attempts to load.
- If a file is opened within this timeframe, it is also logged in the Prefetch data.

This mechanism allows investigators to determine not only which applications were executed but also which files were accessed during their execution.

---

## Internet Browsers

- Multiple browsers can be installed on a system.
- Commonly used browsers:
    - Google Chrome
    - Microsoft Edge
    - Mozilla Firefox

Chrome stores user data in:
    - `C:\Users\<username>\AppData\Local\Google\Chrome\User Data\Default`

- Data is primarily stored in SQLite databases, which are portable and can be analyzed with an interpreter.
- Key databases:
  - `History`
  - `Cookies`
  - `Last Session`
  - `Last Tabs`
  - `Login Data`

**Hindsight**

[Hindsight GitHub Repository](https://github.com/obsidianforensics/hindsight) 

- Parses the Chrome user profile folder.
- C:\Users\user\Desktop\DF-sw>hindsight.exe -i "C:\Users\user\AppData\Local\Google\Chrome\User Data\Default" -o "C:\Users\user\EXTRACTED"
- Generates an `.xlsx` output containing a timeline of user actions.
- Categorizes data from Chrome databases (e.g., history, cookies) for forensic analysis.


NOta:
to get an idea of what the user has done we do not care

- cache e cookie

