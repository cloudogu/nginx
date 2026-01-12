# Mutual TLS mit Client Zertifikaten

Das Nginx-Dogu unterstützt die Authentifizierung von Clients mittels Zertifikaten (Mutual TLS). Wenn diese Funktion aktiviert
ist, fordert Nginx beim TLS-Handshake ein Zertifikat vom Client an und validiert dieses gegen eine hinterlegte
Certificate Authority (CA).

## Konfiguration

Die Konfiguration erfolgt über die Dogu-Konfiguration `client_auth/enabled`.

### 1. CA Zertifikat hinterlegen

Damit Nginx die Client-Zertifikate validieren kann, muss das öffentliche Zertifikat der CA global im CES bekannt sein.
Das CA-Zertifikat muss im PEM-Format in der globalen Konfiguration gespeichert werden:

```bash
cat client-ca.crt | etcdctl set /config/_global/certificate/client-ca.crt
```

> Hinweis: Ein CA-Zertifikat kann z.B. so erzeugt werden:
> 1. Key erzeugen: `openssl genrsa -out client-ca.key 4096`
> 2. Zerifikat erstellen: ` openssl req -x509 -new -nodes -key client-ca.key -sha256 -days 3650 -out client-ca.crt -subj "/C=DE/O=MyOrg/CN=MyOrg Client Root CA`

### 2. Authentifizierung aktivieren

Die Client-Authentifizierung ist standardmäßig deaktiviert. Sie über die Dogu-Config des nginx aktiviert werden:

```bash
etcdctl set /config/nginx/client_auth/enabled true
```

Nach der Änderung muss das Nginx-Dogu neu gestartet werden, damit das CA-Zertifikat aus der Registry geladen und die
Konfiguration neu generiert wird.

## Funktionsweise

Sobald `client_auth/enabled` auf `true` gesetzt ist:

1. Extrahiert das `startup.sh` Skript das CA-Zertifikat aus der globalen Registry nach `/etc/ssl/client-ca.crt`.
2. Aktiviert die `ssl.conf` die Nginx-Direktiven `ssl_client_certificate` und `ssl_verify_client on`.

### Ausnahme für interne Dogu-Requests
Damit Dogus auch ohne Client-Zertifikat Requests an andere Dogus stellen können (z.B. zur Validierung der CAS-Session),
wird in der `nginx.conf` eine Ausnahme für alle Requests erstellt, die aus dem internen Docker-Netzwerk (`172.18.0.1/32`) stammen.

Damit das funktioniert, muss Split-DNS entsprechend konfiguriert sein.
Bei der Installation des CES kann dies in der setup.json unter `useInternalIp` bzw. `internalIp` konfiguriert werden. Siehe: https://docs.cloudogu.com/de/docs/system-components/ces-setup/operations/setup-json/#useinternalip

Dabei wird dann ein entsprechender Eintrag in der `/etc/hosts` der CES-Instanz erzeugt.
Um eine CES-Instanz nach der Installation für Split-DNS zu konfigurieren, muss für die interne IP ein entsprechender Eintrag in der `/etc/hosts` hinterlegt werden.
Zum Beispiel:
```
<interne IP>  <DNS-Name>
172.18.0.1    ces.example.com
```

Danach müssen alle Dogus einmal neugestartet werden.

## Ein Client-Zertifikat erzeugen
Folgende Schritte sind nötig um ein Client-Zertifikat zu erzeugen:

1. User-Key generieren: `openssl genrsa -out client1.key 4096`
2. Certificate Signing Request (CSR) generieren: `openssl req -new -key client1.key -out client1.csr -subj "/C=DE/O=MyOrg/OU=Clients/CN=client1"`
3. Client extension file generieren:
   ```bash
     cat > client.ext <<'EOF'
     basicConstraints = CA:FALSE
     keyUsage = digitalSignature, keyEncipherment
     extendedKeyUsage = clientAuth
     subjectKeyIdentifier = hash
     EOF
   ```
4. CSR signieren: `openssl x509 -req -in client1.csr -CA client-ca.crt -CAkey client-ca.key -CAcreateserial -out client1.crt -days 365 -sha256 -extfile client.ext`
5. Client-Zertifikat und exportierem: `openssl pkcs12 -export -inkey client1.key -in client1.crt -certfile client-ca.crt -name "client1" -out client1.p12`

Das exportierte Zertifikat kann nun im Browser importiert werden.