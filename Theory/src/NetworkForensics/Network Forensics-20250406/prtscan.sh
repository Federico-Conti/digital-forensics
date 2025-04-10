#EX4
http.request.method == "POST" && http contains "login"

   
    #portscan
    nmap 192.168.221.1
    nmap -sV -O 192.168.221.1
    nc -z -v 192.168.221.1 1-1000

tcp.flags.syn == 1 && tcp.flags.ack == 1

#EX5
ftp && ftp contains "Entering Passive Mode"

# View TCP Stream clinet-server for each Passive Mode
    #227 Entering Passive Mode (0,0,0,0,156,68)
        '''
        PWD

        257 "/" is the current directory

        TYPE I

        200 Switching to Binary mode.

        PASV

        227 Entering Passive Mode (0,0,0,0,156,68).

        LIST

        150 Here comes the directory listing.
        226 Directory send OK.

        MDTM netfor.zip
        '''

    #227 Entering Passive Mode (0,0,0,0,156,71)

        '''
        PWD

        257 "/" is the current directory

        TYPE I

        200 Switching to Binary mode.

        PASV

        227 Entering Passive Mode (0,0,0,0,156,71).

        RETR netfor.zip

        150 Opening BINARY mode data connection for netfor.zip (11028 bytes).
        226 Transfer complete.
        '''

# How to calculate the FTP data port?
    # (156 × 256) + 68 = 40004 port 
    # (156 × 256) + 71 = 40007 port 

#The server made TCP port 40004 available to transfer the contents of the directory (LIST command).
tcp.port == 40004
#-rw-rw-r--    1 ftp      ftp         11028 Apr 17 14:03 netfor.zip

# #The server made TCP port 40007 available to transfer the  file 
tcp.port == 40007
# save zip.bin and unzip

