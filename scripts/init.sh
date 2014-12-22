ROOT="certs/http-mitm-proxy"
CA="$ROOT/ca"
mkdir -p $CA

openssl genrsa -out $CA/ca.key 1024
openssl req -new -x509 -days 3650 -extensions v3_ca -keyout $CA/cakey.pem -out $CA/cacert.pem -config /System/Library/OpenSSL/openssl.cnf
echo "02" > $CA/cacert.srl