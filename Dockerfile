# Usa la imagen oficial de PHP que tiene los archivos fuente necesarios para compilar extensiones
FROM php:8.2-cli

# Establece el directorio de trabajo
WORKDIR /app

# Configurar el entorno para evitar problemas en la instalación de paquetes
ENV DEBIAN_FRONTEND=noninteractive

# Actualiza la lista de paquetes y agrega herramientas esenciales
RUN apt-get update && apt-get install -y --no-install-recommends \
    unzip curl git zip libpng-dev libjpeg-dev libfreetype6-dev \
    libonig-dev libxml2-dev mariadb-client libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Instala extensiones de PHP necesarias para Laravel
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_mysql mbstring xml bcmath zip curl gd intl

# Instala Composer globalmente
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copia archivos esenciales primero para aprovechar la caché de Docker
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
