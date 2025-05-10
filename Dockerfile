# Usa la imagen oficial de PHP con FPM
FROM php:8.2-fpm

# Establece el directorio de trabajo
WORKDIR /app

# Instala dependencias esenciales
RUN apt-get update && apt-get install -y \
    unzip curl git zip libpng-dev libjpeg-dev libfreetype6-dev \
    libonig-dev libxml2-dev php-mbstring php-xml php-bcmath php-tokenizer \
    php-zip php-curl php-gd php-intl php-pdo php-mysql

# Instala Composer globalmente
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copia archivos esenciales primero para aprovechar la caché de Docker
COPY composer.json composer.lock ./

# Limpieza y actualización de Composer
RUN composer self-update && composer clear-cache

# Instala las dependencias de Laravel
RUN composer install --no-dev --no-interaction --prefer-dist

# Copia el resto del código del proyecto
COPY . .

# Establecer permisos correctos
RUN chmod -R 775 storage bootstrap/cache

# Instala dependencias de Node.js y construye el frontend
RUN npm install
RUN npm run build

# Expone el puerto 8000 para el servidor de desarrollo
EXPOSE 8000

# Inicia el servidor PHP cuando el contenedor se ejecuta
CMD ["php", "-S", "0.0.0.0:8000", "-t", "public"]
