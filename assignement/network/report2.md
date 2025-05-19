# WordPress DB (192.168.100.101 --> 10.0.100.100:80)

Suspicious activity detected involving unauthorized access to the phpMyAdmin panel and attempts to exfiltrate data and compromise the MySQL database.

## When

| **Event**                     | **Timestamp** | **TCP Stream** | **Details**                                   |
|--------------------------------|---------------|----------------|-----------------------------------------------|
| phpMyAdmin access              | 22:42:19:53   | 45             | GET /phpmyadmin/ HTTP/1.1                     |
| Navigation panel exploration   | 22:43:54:89   | 250            | GET & POST /phpmyadmin/index.php?route=       |
| Reading wp_users               | 22:44:40:04   | 255            | GET & POST /phpmyadmin/index.php?route=       |
| Query execution                | 22:44:32:45   | 256            | GET & POST /phpmyadmin/index.php?route=       |
| Query execution                | 22:44:06:05   | 260            | GET & POST /phpmyadmin/index.php?route=       |

## Who/Where

| **Role**         | **IP Address**         | **Port**        |
|-------------------|-----------------------|-----------------|
| Attacker          | 58.16.78.90           | 38316, 52926, 52950, 52974 |
| Compromised server| 10.0.100.100          | 80 (srv-intranet)     |
| Impersonated host | 192.168.100.101       | srv-www               |

## What

1. Initial access to the "Welcome to phpMyAdmin" panel

```sh
    GET /phpmyadmin/ HTTP/1.1
    Host: 10.0.100.100
    User-Agent: gobuster/3.6
    Accept-Encoding: gzip
    X-Forwarded-For: 58.16.78.90
    X-Forwarded-Host: www.potenzio.com
    X-Forwarded-Server: 192.168.100.101 
    Connection: Keep-Alive
```

2. Exploration of the `wpdb` database structure

```sh
    POST `/phpmyadmin/index.php?route=/navigation&ajax_request=1`
```

3. Direct access to the `wpdb` and `wp_users` tables

```sh
    GET `/phpmyadmin/index.php?route=/table/sql&db=wpdb&table=wp_users`  
```

4. Execution of SQL queries

    - SQL console opened on the WordPress database

        ```sh
            GET  `/phpmyadmin/index.php?route=/database/sql&db=wpdb`  
        ```

    - Credential extraction

        ```sh
            POST  `/phpmyadmin/index.php?route=/import`  
            ...
            `SELECT ID, user_login, user_pass FROM wp_users`
        ```

5. Modification of the administrator password

```sh
    POST  `/phpmyadmin/index.php?route=/import`  
    ...
    UPDATE `wp_users` SET `user_pass` = MD5('byebye') WHERE `wp_users`.`ID` = 1;
```

## How

1. The phpMyAdmin panel is publicly exposed, allowing direct access from external IPs.

2. The X-Forwarded-* headers were used to:

    - Mask the real origin (58.16.78.90)
    - Impersonate www.potenzio.com and the internal server 192.168.100.101

## Why

Access, modification, and exfiltration of corporate data, specifically:

- WordPress user credentials
- Possible persistent access to the backend through administrator password modification

**Wireshark filters used**

```bash
(tcp.stream eq 250 || tcp.stream eq 255 || tcp.stream eq 256 
|| tcp.stream eq 260 || tcp.stream eq 253 || tcp.stream eq 259) 
&& http.request.method == "GET/POST"

http.request.method == "POST" and http contains "sql_query="
```