FROM nginx:latest

COPY ./nginx.conf /etc/nginx/nginx.conf

COPY ./fullchain_api.pem /etc/ssl/certs/fullchain_api.pem
COPY ./privkey_api.pem /etc/ssl/certs/privkey_api.pem

COPY ./fullchain_messenger.pem /etc/ssl/certs/fullchain_messenger.pem
COPY ./privkey_messenger.pem /etc/ssl/certs/privkey_messenger.pem

COPY ./fullchain_payment.pem /etc/ssl/certs/fullchain_payment.pem
COPY ./privkey_payment.pem /etc/ssl/certs/privkey_payment.pem

COPY ./wait-for-it.sh /wait-for-it.sh

RUN chmod +x /wait-for-it.sh

CMD ["/wait-for-it.sh", "webapi:80", "nginx -g 'daemon off;'"]
