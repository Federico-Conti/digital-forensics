# Esfiltrazione dei dati (192.168.100.101 --> 10.0.100.100:80)

**When**

| **Evento**                     | **Timestamp** | **TCP Stream** | **Dettagli**                                   |
|--------------------------------|---------------|----------------|----------------------------------------------- |
| Login phpMyAdmin               | 22:42:19:53   | 45             | GET /phpmyadmin/ HTTP/1.1                      |
| Esploraizone tabelle in Navigation panel | 22:43:54:89   | 250  | GET & POST /phpmyadmin/index.php?route=        |
| Lettura wp_users               | 22:44:40:04   | 255            | GET & POST /phpmyadmin/index.php?route=        |
| Esecuzione query               | 22:44:32:45   | 256            | GET & POST /phpmyadmin/index.php?route=        |
| Esecuzione query               | 22:44:06:05   | 260            | GET & POST /phpmyadmin/index.php?route=        |



**Who/Where**

| **Ruolo**         | **Indirizzo IP**       | **Porta**       |
|--------------------|-----------------------|-----------------|
| Attaccante         | 58.16.78.90           | 38316, 52926, 52950, 52974 |
| Server compromesso | 10.0.100.100          | 80 (srv-intranet)     |
| Impersona          |  192.168.100.101               | srv-www               |


**What**

1. login di accesso "Welcome to phpMyAdmin"

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

2.  Interrogazione struttura del database (`wpdb`) per ottenere lista tabelle, viste, relazioni.

```sh
    POST `/phpmyadmin/index.php?route=/navigation&ajax_request=1`
```

3. Accesso diretto alla tabella utenti WordPress, azione preparatoria alla lettura delle tabelle `wpdb`e`wp_users`

```sh
    GET `/phpmyadmin/index.php?route=/table/sql&db=wpdb&table=wp_users`  
```

4. Preparazione ed esecuzione query SQL

    - Console SQL aperta sul database WordPress.

        ```sh
            GET  `/phpmyadmin/index.php?route=/database/sql&db=wpdb`  
        ```

    - Esecuzione di una query SQL diretta per estrarre username e hash delle password

        ```sh
            POST  `/phpmyadmin/index.php?route=/import`  
            ...
            `SELECT ID, user_login, user_pass FROM wp_users`
        ```

4. Modifica della password dell'utente con ID=1

```sh
    POST  `/phpmyadmin/index.php?route=/import`  
    ...
    UPDATE `wp_users` SET `user_pass` = MD5('byebye') WHERE `wp_users`.`ID` = 1;

```

**How**

1. L'interfaccia /phpmyadmin/ è accessibile da fuori rete.

2. **X-Forwarded Headers**:

  - Impersonano l'host `www.potenzio.com`.
  - Utilizzano il client IP `58.16.78.90`


**Why**
accesso/modifica/esfiltrazione dati della compagnia.


## Considerazioni

- L'accesso diretto al pannello SQL e l'interazione con il database backend indicano un'attività potenzialmente malevola.
- L'uso di X-Forwarded headers per mascherare l'origine delle richieste solleva ulteriori sospetti.
- L'indirizzo IP pubblico utilizzato (`58.16.78.90`) non è riconosciuto come parte della rete interna, suggerendo un tentativo di offuscamento.

**Filtri Wireshark utilizzati**

```bash
(tcp.stream eq 250 || tcp.stream eq 255 || tcp.stream eq 256 || tcp.stream eq 260 || tcp.stream eq 253 || tcp.stream eq 259) && http.request.method == "GET/POST"

http.request.method == "POST" and http contains "sql_query="
```

