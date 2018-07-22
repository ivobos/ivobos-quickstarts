FROM beevelop/cordova:v8.0.0

RUN apt-get -qq update && \
    apt-get -qq install -y git && \
    apt-get -qq install -y openssh-client && \
    apt-get -qq install -y jq

RUN yes | /opt/android/tools/bin/sdkmanager --update
