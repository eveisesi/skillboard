FROM node:16.16.0-alpine3.15 as builder

ENV NUXT_VERSION=2.15.8

WORKDIR /app
COPY . .
RUN : \ 
    && yarn install \
    && yarn build --standalone \
    && yarn add "nuxt-start@${NUXT_VERSION}" \
    && yarn cache clean \
    && :

ENTRYPOINT [ "npx", "nuxt-start" ]
EXPOSE 3000