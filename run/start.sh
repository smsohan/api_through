docker run -d -v /db:/data/db -p 27017:27017 -p 28017:28017 --name mongodb dockerfile/mongodb mongod --rest --httpinterface --smallfiles
docker run -d -p 9081:9081 --name api_proxy --link mongodb:mongodb smsohan/api_through

