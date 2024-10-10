# About repository

Example connecting with X509

## Execution

### Start docker instance

`docker-compose up`

### cURL call

```shell
curl -X POST "https://localhost:18443/auth/realms/master/protocol/openid-connect/token" \
  --cert ./certs/personal-crt.pem \
  --key ./certs/personal-key.pem \
  --cacert ./certs/rootCA.pem \
  -d "client_id=qwerty" \
  -d "client_secret=xxxxxxx" \
  -d "grant_type=client_credentials" \
  -H "Content-Type: application/x-www-form-urlencoded" \
    -vvv --insecure
```

### Running java application with certificates

```shell
-Djavax.net.ssl.trustStore=<PATH_TO_PROJECT>/certs/truststore.jks
-Djavax.net.ssl.trustStorePassword=password
-Djavax.net.ssl.keyStore=<PATH_TO_PROJECT>/certs/personal.p12
-Djavax.net.ssl.keyStorePassword=password
-Djdk.internal.httpclient.disableHostnameVerification=true
-Dcom.sun.jndi.ldap.object.disableEndpointIdentification=true
-Djavax.net.debug=ssl:handshake:verbose:keymanager:sslctx
```