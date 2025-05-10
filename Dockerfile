FROM php:8.1-fpm

WORKDIR /app

COPY . .

RUN apt-get update && apt-get install -y \
    unzip curl \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN composer install --no-dev --no-interaction --prefer-dist
RUN npm install && npm run build

CMD ["php", "-S", "0.0.0.0:8000", "-t", "public"]
