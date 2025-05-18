## Architettura 

### Posizionamento dei server

I server `srv-ns` e `srv-www` sono collocati nella DMZ (Demilitarized Zone) della rete aziendale. La DMZ è una rete separata progettata per esporre servizi pubblici verso l’esterno, proteggendo la rete interna da accessi diretti.

- **Subnet DMZ interna:** `192.168.100.0/24`
- **IP pubblici NATtati:** `198.51.100.100` (`srv-ns`), `198.51.100.101` (`srv-www`)

### Flusso di accesso dal client

Quando un client (ad esempio, Chrome) vuole accedere a `http://www.potenzio.com` o alla intranet:

1. Il client invia una richiesta DNS a `srv-ns` (`198.51.100.100`).
2. `srv-ns` risponde con l’indirizzo IP di `srv-www` (`198.51.100.101`).
3. Il client apre una connessione HTTP verso `198.51.100.101` (porta 80).
4. La risposta viene fornita da `srv-www` o da `src.intranet`.

---

## DNS

- **provider-ns:** DNS resolver (ricorsivo) che risolve nomi pubblici (es. `google.com`, `iit.it`, ecc.).
- **srv-ns:** DNS autoritativo che gestisce il dominio interno `potenzio.com`.

### Risoluzione DNS per www.potenzio.com

Quando il client RED digita nel browser `http://www.potenzio.com`:

1. Il client contatta il resolver configurato, cioè `provider-ns` (`203.0.113.1`).
2. `provider-ns` non conosce direttamente l’IP di `www.potenzio.com`, ma sa come scoprirlo:
    - Interroga i Root DNS: “Chi gestisce .com?”
    - Ottiene l’IP del server TLD `.com`.
    - Chiede al TLD: “Chi è autoritativo per potenzio.com?”
    - Il TLD risponde: `ns.potenzio.com` → `198.51.100.100`
3. A questo punto, `provider-ns` interroga direttamente `srv-ns`.
        A www.potenzio.com?
        → Risposta: 198.51.100.101

srv-ns deve essere raggiungibile da Internet (o dal Simulated Internet) sulla porta 53, altrimenti nessun client esterno potrà risolvere www.potenzio.com.

- Un client interno (client-chrome) potrebbe interrogare direttamente srv-ns, se configurato come resolver interno.

- Ma per traffico esterno (RED, YELLOW, provider-ns) la comunicazione con srv-ns è necessaria per la risoluzione DNS pubblica.