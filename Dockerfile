# Usa la imagen oficial de PHP con FPM
FROM php:8.2-fpm

# Establece el directorio de trabajo
WORKDIR /app

# Configurar el entorno para evitar errores en la instalación
ENV DEBIAN_FRONTEND=noninteractive

# Actualizar y limpiar caché antes de instalar paquetes
RUN apt-get clean && apt-get update && apt-get install -y --no-install-recommends \
    unzip curl git zip libpng-dev libjpeg-dev libfreetype6-dev \
    libonig-dev libxml2-dev php-mbstring php-xml php-bcmath php-tokenizer \
    php-zip php-curl php-gd php-intl php-pdo php-mysql \
    && rm -rf /var/lib/apt/lists/*

# Instalar Composer globalmente
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copiar archivos esenciales primero
COPY composer.json composer.lock ./

# Limpieza y actualización de Composer
RUN composer self-update && composer clear-cache

# Instalar dependencias de PHP
RUN composer install --no-dev --no-interaction --prefer-dist

# Copiar el resto del código del proyecto
COPY . .

# Asegurar permisos correctos
RUN chmod -R 775 storage bootstrap/cache

# Instalar dependencias de Node.js y construir frontend
RUN npm install
RUN npm run build

# Expone el puerto 8000 para el servidor
EXPOSE 8000

# Inicia el servidor PHP cuando el contenedor se ejecuta
CMD ["php", "-S", "0.0.0.0:8000", "-t", "public"]
