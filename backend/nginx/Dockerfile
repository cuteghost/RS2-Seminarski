FROM nginx:latest

COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./fullchain.pem /etc/ssl/certs/fullchain.pem
COPY ./privkey.pem /etc/ssl/certs/privkey.pem
COPY ./wait-for-it.sh /wait-for-it.sh
RUN chmod +x /wait-for-it.sh

CMD ["/wait-for-it.sh", "webapi:80", "nginx -g 'daemon off;'"]
