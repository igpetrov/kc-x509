#!/bin/bash

# Shared variables
PW="password"

# CA variables
CA_COUNTRY="CA"
CA_STATE="BC"
CA_LOCALITY="Vancouver"
CA_ORG_NAME="Trustworthy CA Provider LTD"
CA_ORG_UNIT="Trustworthy CA Provider LTD"
CA_CN="Root CA"

# Generate new CA key and certificate
openssl req -x509 -sha256 -days 3650 -newkey rsa:4096 -keyout rootCA.key -out rootCA.crt -subj "/C=$CA_COUNTRY/ST=$CA_STATE/L=$CA_LOCALITY/O=$CA_ORG_NAME/OU=$CA_ORG_UNIT/CN=$CA_CN" -passout pass:$PW

# IDP (Keycloak) variables
IDP_COUNTRY="DE"
IDP_STATE="BW"
IDP_LOCALITY="Karlsruhe"
IDP_ORG_NAME="IDP Security Provider GmbH"
IDP_ORG_UNIT="Keycloak Dept"
IDP_SERVER_CN="keycloak"

# Generate new Keycloak key and certificate
openssl req -new -newkey rsa:4096 -keyout keycloak.key -out keycloak.csr -nodes -subj "/C=$IDP_COUNTRY/ST=$IDP_STATE/L=$IDP_LOCALITY/O=$IDP_ORG_NAME/OU=$IDP_ORG_UNIT/CN=$IDP_SERVER_CN" -passout pass:$PW

# Define extension params for Keycloak
cat <<EOF > keycloak.ext
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
subjectAltName = @alt_names

[alt_names]
DNS.1 = $IDP_SERVER_CN
DNS.2 = localhost
EOF

# Sign keycloak key with CA certificate
openssl x509 -req -CA rootCA.crt -CAkey rootCA.key -in keycloak.csr -out keycloak.crt -days 365 -CAcreateserial -extfile keycloak.ext

# Convert keycloak certificate to PEM format
openssl x509 -in keycloak.crt -out keycloak-crt.pem -outform PEM

# Convert keycloak key to PEM format
openssl rsa -in  keycloak.key -out keycloak-key.pem

# Create truststore
keytool -import -alias root.ca -file rootCA.crt -keypass $PW -keystore truststore.jks -storepass $PW

# Private client
USER_COUNTRY="UA"
USER_STATE="ODS"
USER_LOCALITY="Odesa"
USER_ORG_NAME="Private"
USER_ORG_UNIT="Private"
USER_SERVER_CN="Private"
USER_EMAIL_ADDRESS="igpetrov@github.io"

# Create user certificate
openssl req -new -newkey rsa:4096 -nodes -keyout personal.key -out personal.csr -subj "/emailAddress="$USER_EMAIL_ADDRESS"/C=$USER_COUNTRY/ST=$USER_STATE/L=$USER_LOCALITY/O=$USER_ORG_NAME/OU=$USER_ORG_UNIT/CN=$USER_SERVER_CN"

# Sign user certificate with CA
openssl x509 -req -CA rootCA.crt -CAkey rootCA.key -in personal.csr -out personal.crt -days 365 -CAcreateserial

# Export user certificate
openssl pkcs12 -export -out personal.p12 -name "personal" -inkey personal.key -in personal.crt -passout pass:$PW

# Convert personal certificate to PEM format
openssl x509 -in personal.crt -out personal-crt.pem -outform PEM

# Convert personal key to PEM format
openssl rsa -in  personal.key -out personal-key.pem