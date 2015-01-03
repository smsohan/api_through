set +e
docker stop api_through
docker rm api_through
set -e
docker run -p 9081:9081 --name api_through -d --link mongodb:mongodb --env SPYREST_CA_PASS=$SPYREST_CA_PASS smsohan/api_through