FROM beevelop/cordova:v7.0.1

RUN npm install -g yarn
RUN apt-get -qq update && \
    apt-get -qq install -y git && \
    apt-get -qq install -y openssh-client && \
    apt-get -qq install -y jq