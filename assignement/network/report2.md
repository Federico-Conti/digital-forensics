# Wordpress DB (192.168.100.101 --> 10.0.100.100:80)

Rilevata un’attività sospetta che coinvolge l’accesso non autorizzato al pannello phpMyAdmin e tentativi di esfiltrazione dati e compromissione al database mysql

## When

| **Evento**                     | **Timestamp** | **TCP Stream** | **Dettagli**                                   |
|--------------------------------|---------------|----------------|----------------------------------------------- |
| Accesso phpMyAdmin               | 22:42:19:53   | 45             | GET /phpmyadmin/ HTTP/1.1                      |
| Esplorazione del pannello di navigazione | 22:43:54:89   | 250  | GET & POST /phpmyadmin/index.php?route=        |
| Lettura wp_users               | 22:44:40:04   | 255            | GET & POST /phpmyadmin/index.php?route=        |
| Esecuzione query               | 22:44:32:45   | 256            | GET & POST /phpmyadmin/index.php?route=        |
| Esecuzione query               | 22:44:06:05   | 260            | GET & POST /phpmyadmin/index.php?route=        |


## Who/Where

| **Ruolo**         | **Indirizzo IP**       | **Porta**       |
|--------------------|-----------------------|-----------------|
| Attaccante         | 58.16.78.90           | 38316, 52926, 52950, 52974 |
| Server compromesso | 10.0.100.100          | 80 (srv-intranet)     |
| Host impersonato          |  192.168.100.101               | srv-www               |


## What

1. Accesso iniziale al pannello "Welcome to phpMyAdmin"

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

2. Esplorazione struttura del database `wpdb`

```sh
    POST `/phpmyadmin/index.php?route=/navigation&ajax_request=1`
```

3. Accesso diretto alla tabella  `wpdb`e`wp_users`

```sh
    GET `/phpmyadmin/index.php?route=/table/sql&db=wpdb&table=wp_users`  
```

4. Esecuzione di query SQL

    - Console SQL aperta sul database WordPress

        ```sh
            GET  `/phpmyadmin/index.php?route=/database/sql&db=wpdb`  
        ```

    - Estrazione di credenziali

        ```sh
            POST  `/phpmyadmin/index.php?route=/import`  
            ...
            `SELECT ID, user_login, user_pass FROM wp_users`
        ```

4. Modifica della password dell’amministratore

```sh
    POST  `/phpmyadmin/index.php?route=/import`  
    ...
    UPDATE `wp_users` SET `user_pass` = MD5('byebye') WHERE `wp_users`.`ID` = 1;

```

## How

1. Il pannello phpMyAdmin è esposto pubblicamente, consentendo l’accesso diretto da IP esterni.

2. Gli header X-Forwarded-* sono stati usati per:

    - Mascherare l’origine reale (58.16.78.90)
    - Impersonare www.potenzio.com e il server interno 192.168.100.101


## Why

Accesso, modifica e esfiltrazione dei dati aziendali, in particolare:

- Credenziali utente WordPress
- Possibile accesso persistente al backend tramite modifica della password dell’amministratore

**Filtri Wireshark utilizzati**

```bash
(tcp.stream eq 250 || tcp.stream eq 255 || tcp.stream eq 256 || tcp.stream eq 260 || tcp.stream eq 253 || tcp.stream eq 259) && http.request.method == "GET/POST"

http.request.method == "POST" and http contains "sql_query="
```