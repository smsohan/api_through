FROM dockerfile/node

MAINTAINER sohan39@gmail.com

WORKDIR /api_through
ADD ./package.json /api_through/package.json

RUN npm install

ADD . /api_through

CMD ["node", "index.js"]

EXPOSE 9081


