FROM node:16

WORKDIR /usr/src/app

COPY . .

ARG NPM_USER
ARG NPM_PW
ARG NPM_EMAIL
ARG NPM_REGISTRY

RUN npm install -g npm-cli-login; npm-cli-login -u "$NPM_USER" -p "$NPM_PW" -e "$NPM_EMAIL" -r "$NPM_REGISTRY"; \
  npm install; \
  ./node_modules/.bin/tsc;

CMD [ "node", "dist/index.js" ]
