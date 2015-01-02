HOST=$1
BASEDIR=$(dirname $0)
ROOT="${BASEDIR}/certs/http-mitm-proxy"
CA="$ROOT/ca"

echo "GENERATING PRIVATE KEY FILE"
openssl genrsa -out $ROOT/$HOST-key.pem 1024
echo "GENERATING CERTIFICATE REQUEST FILE"
openssl req -new -key $ROOT/$HOST-key.pem -subj "/C=CA/ST=AB/L=Calgary/O=SpyREST/CN=$HOST" -out $ROOT/$HOST.csr
echo "SIGNING CERTIFICATE REQUEST"
openssl x509 -req -days 3650 -CA $CA/cacert.pem -CAkey $CA/cakey.pem -in $ROOT/$HOST.csr -passin env:SPYREST_CA_PASS -out $ROOT/$HOST-cert.pem