FROM dockerfile/nodejs

MAINTAINER sohan39@gmail.com

ADD . /api_through
WORKDIR /api_through

CMD ["node", "index.js"]

EXPOSE 9081


