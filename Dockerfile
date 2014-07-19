FROM dockerfile/nodejs
MAINTAINER Kevin Littlejohn <kevin@littlejohn.id.au>
# Copied from desmondmorris/hubot

# Install hubot & coffee-script globally
RUN npm install -g hubot coffee-script

# Create new hubot
WORKDIR /usr/local/opt
RUN hubot --create hubot
WORKDIR /usr/local/opt/hubot
RUN chmod +x bin/hubot
RUN npm install
RUN npm install forever -g
RUN npm install hubot-slack hubot-flowdock --save

# Create hubot system user
RUN adduser --disabled-password --gecos "" hubot

# Install redis-server and supervisor
RUN apt-get -qqy install redis-server
ADD start.sh /usr/local/bin/

EXPOSE 8080
CMD /usr/local/bin/start.sh
