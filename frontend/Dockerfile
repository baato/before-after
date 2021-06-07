# build the frontend app
FROM node:12.2.0-alpine AS frontend_app

RUN mkdir /src
COPY src/ /src/

WORKDIR /src/app/
RUN yarn install
RUN yarn build


# server the app using nginx
FROM nginx

RUN rm /etc/nginx/conf.d/default.conf
COPY ./siteconfig.conf /etc/nginx/conf.d/

COPY --from=frontend_app /src/app/dist/ /usr/share/nginx/html/
