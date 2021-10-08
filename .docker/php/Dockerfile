FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y --no-install-recommends \
    curl unzip ca-certificates openssl php7.4 php7.4-cli php7.4-common php7.4-curl \
    php7.4-json php7.4-mbstring php7.4-mysql php7.4-xml php7.4-zip \
    php7.4-odbc php7.4-sqlite3 php7.4-gd php7.4-fpm php7.4-bcmath php7.4-bz2 php7.4-common

COPY ./.docker/php/app-entrypoint.sh /usr/local/bin/

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php -r "if (hash_file('sha384', 'composer-setup.php') === '906a84df04cea2aa72f40b5f787e49f22d4c2f19492ac310e8cba5b96ac8b64115ac402c8cd292b8a03482574915d1a8') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer && \
    test -f /usr/local/bin/composer || exit 1

RUN useradd ubuntu; \
    mkdir /app; \
    chown -R ubuntu /app;

USER ubuntu

WORKDIR /app

EXPOSE 80 443

ENTRYPOINT [ "app-entrypoint.sh" ]

CMD [ "php", "artisan", "serve", "--host=0.0.0.0", "--port=80" ]
