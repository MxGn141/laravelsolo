# Usa la imagen oficial de PHP con FPM (FastCGI Process Manager)
FROM php:8.2-fpm

# Establece el directorio de trabajo
WORKDIR /app

# Instala dependencias esenciales
RUN apt-get update && apt-get install -y \
    unzip curl git zip libpng-dev libjpeg-dev libfreetype6-dev \
    libonig-dev libxml2-dev && \
    docker-php-ext-install pdo pdo_mysql gd mbstring xml

# Instala Composer globalmente
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copia archivos esenciales primero para aprovechar la caché
COPY composer.json composer.lock ./

# Instala las dependencias de PHP
RUN composer install --no-dev --no-interaction --prefer-dist

# Copia el resto del código del proyecto
COPY . .

# Establece permisos correctos
RUN chmod -R 775 storage bootstrap/cache

# Instala dependencias de Node.js y construye el frontend
RUN npm install
RUN npm run build

# Expone el puerto 8000 para el servidor de desarrollo
EXPOSE 8000

# Inicia el servidor PHP cuando el contenedor se ejecuta
CMD ["php", "-S", "0.0.0.0:8000", "-t", "public"]
