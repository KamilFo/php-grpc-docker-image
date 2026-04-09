FROM php:8.4-fpm

# Установка системных зависимостей
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    zlib1g-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Установка PHP расширений
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd sockets

# Установка Redis расширения
RUN pecl install redis && docker-php-ext-enable redis

# Установка gRPC расширения
RUN pecl install grpc && docker-php-ext-enable grpc

# Установка Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Установка российских корневых сертификатов для T-Bank API
COPY certs/russian_trusted_root_ca_pem.crt /usr/local/share/ca-certificates/
COPY certs/russian_trusted_sub_ca_pem.crt /usr/local/share/ca-certificates/
RUN update-ca-certificates

# Установка рабочей директории
WORKDIR /var/www

# Копирование файлов приложения
COPY . /var/www

# Установка прав
RUN chown -R www-data:www-data /var/www
RUN chmod -R 755 /var/www

EXPOSE 9000

CMD ["php-fpm"]
