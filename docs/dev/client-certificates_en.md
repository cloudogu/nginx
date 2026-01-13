# Mutual TLS with client certificates

Nginx Dogu supports client authentication using certificates (Mutual TLS). When this feature is enabled,
Nginx requests a certificate from the client during the TLS handshake and validates it against a stored
Certificate Authority (CA).

## Configuration

The configuration is done via the Dogu configuration `mutual_tls/enabled`.

### 1. Store CA certificate

In order for Nginx to validate the client certificates, the public certificate of the CA must be known globally in the CES.
The CA certificate must be stored in PEM format in the global configuration:

```bash
cat client-ca.crt | etcdctl set /config/_global/certificate/client-ca.crt
```

> Note: A CA certificate can be generated as follows, for example:
> 1. Generate key: `openssl genrsa -out client-ca.key 4096`
> 2. Create certificate: ` openssl req -x509 -new -nodes -key client-ca.key -sha256 -days 3650 -out client-ca.crt -subj "/C=DE/O=MyOrg/CN=MyOrg Client Root CA`


### 2. Enable authentication

Client authentication is disabled by default. It can be enabled via the Dogu config of nginx:

```bash
etcdctl set /config/nginx/mutual_tls/enabled true
```

After making this change, the Nginx Dogu must be restarted so that the CA certificate is loaded from the registry and the
configuration is regenerated.

## How it works

Once `mutual_tls/enabled` is set to `true`:

1. The `startup.sh` script extracts the CA certificate from the global registry to `/etc/ssl/client-ca.crt`.
2. The `ssl.conf` activates the Nginx directives `ssl_client_certificate` and `ssl_verify_client on`.

### Exception for internal Dogu requests
To enable Dogus to send requests to other Dogus without a client certificate (e.g., to validate the CAS session),
an exception is created in `nginx.conf` for all requests originating from the internal Docker network (`172.18.0.1/32`).

For this to work, split DNS must be configured accordingly.
When installing the CES, this can be configured in setup.json under `useInternalIp` or `internalIp`. See: https://docs.cloudogu.com/de/docs/system-components/ces-setup/operations/setup-json/#useinternalip

This creates a corresponding entry in the `/etc/hosts` of the CES instance.
To configure a CES instance for split DNS after installation, a corresponding entry must be stored in `/etc/hosts` for the internal IP.
For example:
```
<internal IP>  <DNS name>
172.18.0.1    ces.example.com
```

After that, all Dogus must be restarted once.

## Generate a client certificate
The following steps are necessary to generate a client certificate:

1. Generate user key: `openssl genrsa -out client1.key 4096`
2. Generate a certificate signing request (CSR): `openssl req -new -key client1.key -out client1.csr -subj “/C=DE/O=MyOrg/OU=Clients/CN=client1”`
3. Generate client extension file:
```bash
     cat > client.ext <<‘EOF’
     basicConstraints = CA:FALSE
     keyUsage = digitalSignature, keyEncipherment
     extendedKeyUsage = clientAuth
     subjectKeyIdentifier = hash
     EOF
   ```
4. Sign CSR: `openssl x509 -req -in client1.csr -CA client-ca.crt -CAkey client-ca.key -CAcreateserial -out client1.crt -days 365 -sha256 -extfile client.ext`
5. Export client certificate: `openssl pkcs12 -export -inkey client1.key -in client1.crt -certfile client-ca.crt -name “client1” -out client1.p12`

The exported certificate can now be imported into the browser.