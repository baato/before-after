# build the frontend app
FROM node:12.2.0-alpine AS frontend_app

RUN mkdir /src
COPY src/ /src/

WORKDIR /src/app/

# The bundled yarn 1.15.2 can't parse this lockfile ("Invalid value type ...").
# Upgrade to a modern yarn 1.x. --unsafe-perm avoids the old-npm-on-alpine
# "could not get uid/gid [ 'nobody', 0 ]" failure when running as root.
RUN npm install -g --unsafe-perm yarn@1.22.22
RUN yarn install
RUN yarn build


# server the app using nginx
FROM nginx

RUN rm /etc/nginx/conf.d/default.conf
COPY ./siteconfig.conf /etc/nginx/conf.d/

COPY --from=frontend_app /src/app/dist/ /usr/share/nginx/html/
