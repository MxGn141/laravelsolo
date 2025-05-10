# Usa la imagen oficial de PHP con CLI, que incluye los archivos fuente necesarios
FROM php:8.2-cli

# Establece el directorio de trabajo
WORKDIR /app

# Configurar el entorno para evitar problemas en la instalación
ENV DEBIAN_FRONTEND=noninteractive

# --------------------------------------
# 🔧 Actualización de paquetes
# --------------------------------------
RUN apt-get update

# --------------------------------------
# 🔧 Instalación de herramientas esenciales
# --------------------------------------
RUN apt-get install -y unzip curl git zip mariadb-client libpq-dev ca-certificates

# --------------------------------------
# 🔧 Instalación de librerías necesarias para PHP
# --------------------------------------
RUN apt-get install -y libpng-dev libjpeg-dev libfreetype6-dev
RUN apt-get install -y libonig-dev libxml2-dev libzip-dev
RUN apt-get install -y libcurl4-openssl-dev libssl-dev libxslt-dev pkg-config

# --------------------------------------
# 🔧 Instalación de extensiones de PHP
# --------------------------------------
RUN docker-php-ext-install pdo
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install mbstring
RUN docker-php-ext-install xml
RUN docker-php-ext-install bcmath
RUN docker-php-ext-install zip
RUN docker-php-ext-install curl
RUN docker-php-ext-install gd
RUN docker-php-ext-install intl
RUN docker-php-ext-install xsl

# --------------------------------------
# 🔧 Configuración de extensiones
# --------------------------------------
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-configure intl

# --------------------------------------
# 🔧 Instalación de Composer
# --------------------------------------
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# --------------------------------------
# 🔧 Copia de archivos esenciales
# --------------------------------------
COPY composer.json composer.lock ./

# --------------------------------------
# 🔧 Limpieza y actualización de Composer
# --------------------------------------
RUN composer self-update
RUN composer clear-cache

# --------------------------------------
# 🔧 Instalación de dependencias de Laravel
# --------------------------------------
RUN composer install --no-dev --no-interaction --prefer-dist

# --------------------------------------
# 🔧 Copia del resto del código del proyecto
# --------------------------------------
COPY . .

# --------------------------------------
# 🔧 Corrección de permisos
# --------------------------------------
RUN chmod -R 775 storage bootstrap/cache

# --------------------------------------
# 🔧 Instalación de dependencias de Node.js y construcción del frontend
# --------------------------------------
RUN npm install
RUN npm run build

# --------------------------------------
# 🔧 Exposición del puerto para el servidor
# --------------------------------------
EXPOSE 8000

# --------------------------------------
# 🔧 Inicio del servidor PHP
# --------------------------------------
CMD ["php", "-S", "0.0.0.0:8000", "-t", "public"]
