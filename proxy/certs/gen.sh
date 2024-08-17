#!/usr/bin/env bash

set -e
set -x

# Set variables
CA_KEY="ca-key.pem"
CA_CERT="ca.pem"
SERVER_KEY="server-key.pem"
SERVER_CERT="server-cert.pem"
SERVER_CSR="server.csr"
CLIENT_KEY="key.pem"
CLIENT_CERT="cert.pem"
CLIENT_CSR="client.csr"
EXTFILE="extfile.cnf"
DAYS=365
COMMON_NAME="localhost"


rm *.pem

# Generate CA private key and public certificate
openssl genrsa -out $CA_KEY 4096
openssl req -new -x509 -days $DAYS -key $CA_KEY -sha256 -out $CA_CERT -subj "/CN=Docker CA"

# Generate Server private key and certificate signing request (CSR)
openssl genrsa -out $SERVER_KEY 4096
openssl req -subj "/CN=$COMMON_NAME" -sha256 -new -key $SERVER_KEY -out $SERVER_CSR

# Create configuration file for the extensions
echo "subjectAltName = DNS:$COMMON_NAME,IP:127.0.0.1" > $EXTFILE

# Generate Server certificate
openssl x509 -req -days $DAYS -sha256 -in $SERVER_CSR -CA $CA_CERT -CAkey $CA_KEY -CAcreateserial -out $SERVER_CERT -extfile $EXTFILE

# Generate Client private key and certificate signing request (CSR)
openssl genrsa -out $CLIENT_KEY 4096
openssl req -subj '/CN=client' -new -key $CLIENT_KEY -out $CLIENT_CSR

# Generate Client certificate
openssl x509 -req -days $DAYS -sha256 -in $CLIENT_CSR -CA $CA_CERT -CAkey $CA_KEY -CAcreateserial -out $CLIENT_CERT

# Clean up CSR files
rm -f $SERVER_CSR $CLIENT_CSR $EXTFILE

echo "Docker TLS certificates have been generated in the current directory."