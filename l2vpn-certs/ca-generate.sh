#!/usr/bin/zsh

if ! [ -f $1.key ]; then openssl genrsa -out $1.key 4096; fi
openssl req -new -sha256 -extensions v3_req \
    -key $1.key \
    -subj "/C=CA/ST=Ontario/L=Niagara Falls/O=tishco networks/CN=$1" \
    -addext "basicConstraints = critical, CA:true, pathlen:1" \
    -addext "keyUsage = critical, keyCertSign, cRLSign" \
    -out /tmp/$1.csr
openssl x509 -sha256 -copy_extensions copyall -req -in /tmp/$1.csr \
    -signkey $1.key -days 7305 -out $1.crt && rm /tmp/$1.csr
