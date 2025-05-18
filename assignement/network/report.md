# Identificazione e mappatura degli IP principali ("Main Players")

## Analisi statistica IP

| IP A            | IP B            | Packets | Note                                                   |
|------------------|-----------------|---------|--------------------------------------------------------|
| 192.168.100.101 | 10.0.100.100    | 3571    | traffico HTTP tra srv-www e srv-intranet              |
| 10.0.200.100    | 192.168.100.100 | 3136    |  traffico da client verso DMZ (srv-www)             |
| 192.168.100.100 | 203.0.113.113   | 2952    | DNS verso provider-ns (trusted)                      |
| 58.16.78.90     | 192.168.100.101 | 2751    | traffico da IP esterno (simulated Internet)           |
| 58.16.122.33    | 192.168.100.101 | 1648    | altro traffico significativo dall'esterno            |

Gli IP 58.16.78.90, 58.16.122.33, 58.16.120.39 e simili appartengono alla simulated Internet.

- Si osservano frequenti connessioni in ingresso verso la porta 80 di 192.168.100.101 (srv-www), provenienti da questi IP esterni.


Gli IP come 104.85.x.x, 104.18.x.x, 34.x.x.x, 13.x.x.x sono riconducibili a servizi cloud.

L’indirizzo 10.0.200.100 risulta associato all’utente più attivo all’interno della rete simulata, con accessi a numerosi siti e servizi popolari, tra cui: Pinterest, eBay, Aranzulla, MyPersonalTrainer, ecc.

- Esempio di filtro utilizzato: `ssl.handshake.extensions_server_name && ip.addr == 104.85.8.193`

## Analisi statistica TCP

Le statistiche TCP confermano i seguenti pattern rilevanti:

1. Comunicazioni sospette originate da 192.168.100.101 su porte elevate (52926, 52944, 52950, 52974, 52934, 52960) dirette verso 10.0.100.100:80

- Flussi osservati: `tcp.stream eq 250,255,256,260,253,259`
   
2. Numerose connessioni da IP esterni (es. 58.16.78.90, 58.16.122.33, 58.16.119.40, 58.16.120.x) verso 192.168.100.101:80 (srv-www interno)

    - In particolare, l’IP 58.16.78.90 appare con centinaia di connessioni e sessioni HTTP caratterizzate da payload bidirezionali significativi
    - Esempi di flussi: `tcp.stream eq 461,441,132,137,298`




