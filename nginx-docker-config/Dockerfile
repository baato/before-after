FROM nginx

RUN rm /etc/nginx/conf.d/default.conf
COPY ./siteconfig.conf /etc/nginx/conf.d/

COPY frontend_main/ /usr/share/nginx/html/
