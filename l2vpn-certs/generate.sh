#!/usr/bin/zsh

if ! [ -f $2.key ]; then openssl genrsa -out $2.key 4096; fi
openssl req -new -sha256 -extensions v3_req \
    -key $2.key \
    -subj "/C=CA/ST=Ontario/L=Niagara Falls/O=tishco networks/CN=$2" \
    -addext "extendedKeyUsage = critical, serverAuth, clientAuth" \
    -out /tmp/$2.csr
openssl x509 -sha256 -copy_extensions copyall -req -in /tmp/$2.csr \
    -CA $1.crt -CAkey $1.key -CAcreateserial -days 3653 \
    -out $2.crt && rm /tmp/$2.csr
