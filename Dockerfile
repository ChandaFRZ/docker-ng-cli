# docker container for angular 8.2 tests (karma, coverage, protractor)
# docker build for gitlab-ci


FROM node:12.7.0

MAINTAINER Friedrich Chanda Bachinger "freeza@gmx.at"

ARG USER_HOME_DIR="/tmp"
ARG APP_DIR="/app"
ARG USER_ID=1000

ENV NPM_CONFIG_LOGLEVEL=warn NG_CLI_ANALYTICS=false
ENV HOME "$USER_HOME_DIR"

WORKDIR $APP_DIR
EXPOSE 4200

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

RUN apt-get update && apt-get install -qqy --no-install-recommends \
    dumb-init \
    git \
    build-essential \
    python \
    procps \
    rsync \
    openssh-client \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN set -xe \
    && mkdir -p $USER_HOME_DIR \
    && chown $USER_ID $USER_HOME_DIR \
    && chmod a+rw $USER_HOME_DIR \
    && mkdir -p $APP_DIR \
    && chown $USER_ID $APP_DIR \
    && chown -R $USER:$GROUP $APP_DIR/.npm \
    && chown -R $USER:$GROUP $APP_DIR/.config \
    && chown -R node /usr/local/lib /usr/local/include /usr/local/share /usr/local/bin \
    && (cd "$USER_HOME_DIR"; su node -c "npm install -g yarn; chmod +x /usr/local/bin/yarn; npm cache clean --force")

RUN echo "deb http://dl.google.com/linux/chrome/deb/ stable main" | tee -a /etc/apt/sources.list
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN apt-get -qq update -y
RUN apt-get -qq install -y google-chrome-stable xvfb gtk2-engines-pixbuf xfonts-cyrillic xfonts-100dpi xfonts-75dpi xfonts-base xfonts-scalable imagemagick x11-apps default-jre
RUN Xvfb :0 -ac -screen 0 1024x768x24 &
RUN export DISPLAY=:99
RUN npm install --silent --unsafe-perm -g @angular/cli@8.2.0
RUN npm install --silent @angular-devkit/build-angular
RUN npm install -g webdriver-manager

USER $USER_ID