# Usa la imagen oficial de PHP con CLI (incluye archivos fuente para compilar extensiones)
FROM php:8.2-cli

# Establece el directorio de trabajo
WORKDIR /app

# Configurar el entorno para evitar problemas en la instalación de paquetes
ENV DEBIAN_FRONTEND=noninteractive

# Actualizar la lista de paquetes
RUN apt-get update

# Instalar herramientas esenciales
RUN apt-get install -y unzip curl git zip mariadb-client libpq-dev

# Instalar librerías para PHP GD
RUN apt-get install -y libpng-dev libjpeg-dev libfreetype6-dev libonig-dev libxml2-dev

# Instalar extensiones de PHP individualmente
RUN docker-php-ext-install pdo
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install mbstring
RUN docker-php-ext-install xml
RUN docker-php-ext-install bcmath
RUN docker-php-ext-install zip
RUN docker-php-ext-install curl
RUN docker-php-ext-install gd
RUN docker-php-ext-install intl

# Configurar GD correctamente
RUN docker-php-ext-configure gd --with-freetype --with-jpeg

# Instala Composer globalmente
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copia archivos esenciales primero
COPY composer.json composer.lock ./

# Limpieza y actualización de Composer
RUN composer self-update && composer clear-cache

# Instala dependencias de Laravel
RUN composer install --no-dev --no-interaction --prefer-dist

# Copia el resto del código del proyecto
COPY . .

# Establecer permisos correctos
RUN chmod -R 775 storage bootstrap/cache

# Instala dependencias de Node.js y construye el frontend
RUN npm install
RUN npm run build

# Expone el puerto 8000 para el servidor
EXPOSE 8000

# Inicia el servidor PHP cuando el contenedor se ejecuta
CMD ["php", "-S", "0.0.0.0:8000", "-t", "public"]

