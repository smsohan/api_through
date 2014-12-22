HOST=$1
ROOT="certs/http-mitm-proxy"
CA="$ROOT/ca"

openssl genrsa -out $ROOT/$HOST-key.pem 1024
openssl req -new -key $ROOT/$HOST-key.pem -out $ROOT/$HOST.csr
openssl x509 -req -days 3650 -CA $CA/cacert.pem -CAkey $CA/cakey.pem -in $ROOT/$HOST.csr -out $ROOT/$HOST-cert.pem