## Ruby throws error: SSL_connect returned=1 errno=0 state=error: certificate verify failed (unable to get local issuer certificate) (OpenSSL::SSL::SSLError)

This error might be caused by the target host using a chain.pem, not a fullchain.pem. We can use below codes to check that.

```
~/.bin/openssl_verify target-host
```

One workaround for ruby is adding below codes:

```
require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
```

## How to generate self signed certificate with custom root CA

### Create root CA

#### Create root key

Attention: this is the key used to sign the certificate requests, anyone holding this can sign certificates on your behalf. So keep it in a safe place!

```
# If you want to encrypt the key, you can add -des3 option or other encryption option.
# By default the numbits is 2048, you can change it to other value, e.g. 4096.
# For more info, please see `openssl genrsa -h`.
openssl genrsa -out rootCA.key
```

#### Create root certificate

```
openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 1024 -out rootCA.crt
```

### Create a certificate

#### Create certificate key

```
openssl genrsa -out mydomain.com.key
```

#### Create the certificate signing request

```
# Interactive way
openssl req -new -key mydomain.com.key -out mydomain.com.csr

# One liner way for automation
openssl req -new -sha256 -key mydomain.com.key -subj "/C=US/ST=CA/O=MyOrg, Inc./CN=mydomain.com" -out mydomain.com.csr
```

If you need to pass additional config you can use the -config parameter, here for example I want to add alternative names to my certificate.

```
openssl req -new -sha256 \
    -key mydomain.com.key \
    -subj "/C=US/ST=CA/O=MyOrg, Inc./CN=mydomain.com" \
    -reqexts SAN \
    -config <(cat /etc/ssl/openssl.cnf \
        <(printf "\n[SAN]\nsubjectAltName=DNS:mydomain.com,DNS:www.mydomain.com")) \
    -out mydomain.com.csr
```

#### Verify the csr's content

```
openssl req -in mydomain.com.csr -noout -text
```

#### Generate the certificate using the csr and key along with the CA root key

```
openssl x509 -req -in mydomain.com.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out mydomain.com.crt -days 500 -sha256
```

#### Verify the certificate's content

```
openssl x509 -in mydomain.com.crt -text -noout
```
