FROM node:16.0-alpine

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

ARG LINK=no

RUN adduser -S ory -D -u 10000 -s /bin/nologin

COPY package.json .
COPY package-lock.json .

RUN npm ci

COPY . /usr/src/app

RUN if [ "$LINK" == "true" ]; then (cd ./contrib/sdk/generated; rm -rf node_modules; npm ci; npm run build); \
    cp -r ./contrib/sdk/generated/* node_modules/@ory/kratos-client/; \
    fi

ENV KRATOS_ADMIN_URL "http://0.0.0.0:4434/"
ENV KRATOS_PUBLIC_URL "http://0.0.0.0:4433/"
ENV KRATOS_BROWSER_URL "http://0.0.0.0:4433/"
ENV PORT "4455"
ENV HYDRA_ADMIN_URL http://0.0.0.0:4445

RUN npm run build

USER 10000

ENTRYPOINT npm run serve

EXPOSE 4455
