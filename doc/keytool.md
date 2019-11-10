## List aliases in a truststore

```
keytool -v -list -keystore truststore.jks
```

## Convert truststore to pem

### Method 1

```
keytool -exportcert -rfc -file <pem-file> -keystore truststore.jks -alias <alias>
```

### Method 2

```
keytool -importkeystore -srckeystore truststore.jks -destkeystore truststore.p12 -deststoretype PKCS12
openssl pkcs12 -in truststore.p12 -out truststore.pem
```

## Change keystore or truststore password

```
keytool -storepasswd -keystore keystore.jks
```

## Export public key

```
openssl pkcs12 -export -name servercert -in server.crt -inkey server.key -out myp12keystore.p12
```
