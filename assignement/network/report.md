# Identification and Mapping of Main IPs ("Main Players")

## IP Statistica Analysis

| IP A            | IP B            | Packets | Notes                                                 |
|------------------|-----------------|---------|-------------------------------------------------------|
| 192.168.100.101 | 10.0.100.100    | 3571    | HTTP traffic between srv-www and srv-intranet         |
| 10.0.200.100    | 192.168.100.100 | 3136    | traffic from client to DMZ (srv-www)                 |
| 192.168.100.100 | 203.0.113.113   | 2952    | DNS to provider-ns (trusted)                         |
| 58.16.78.90     | 192.168.100.101 | 2751    | traffic from external IP (simulated Internet)        |
| 58.16.122.33    | 192.168.100.101 | 1648    | other significant traffic from external sources      |

The IPs 58.16.78.90, 58.16.122.33, 58.16.120.39, and similar belong to the simulated Internet.

- Frequent incoming connections to port 80 of 192.168.100.101 (srv-www) are observed, originated from these external IPs.

IPs such as 104.85.x.x, 104.18.x.x, 34.x.x.x, 13.x.x.x are associated with cloud services.

The address 10.0.200.100 is linked to the most active user within the simulated network, with access to numerous popular sites and services, including Pinterest, eBay, Aranzulla, MyPersonalTrainer, etc.

- Example of filter used: `ssl.handshake.extensions_server_name && ip.addr == 104.85.8.193`

## TCP Statistica Analysis

TCP statistics confirm the following relevant patterns:

1. Suspicious communications originated from 192.168.100.101 on high ports (52926, 52944, 52950, 52974, 52934, 52960) directed to 10.0.100.100:80

- Observed flows: `tcp.stream eq 250,255,256,260,253,259`

2. Numerous connections from external IPs (e.g., 58.16.78.90, 58.16.122.33, 58.16.119.40, 58.16.120.x) to 192.168.100.101:80 (internal srv-www)

    - In particular, the IP 58.16.78.90 appears with hundreds of connections and HTTP sessions characterized by significant bidirectional payloads.
    - Examples of flows: `tcp.stream eq 461,441,132,137,298`




