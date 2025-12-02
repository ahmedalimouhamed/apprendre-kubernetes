# Image de base officielle PHP avec Apache
FROM php:8.2-apache

# Définir le répertoire de travail
WORKDIR /var/www/html

# Copier les fichiers de l'application dans le conteneur
COPY . .

# Installer les extensions PHP nécessaires
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Activer les modules Apache utiles
RUN a2enmod rewrite headers

# Supprimer les warnings "ServerName"
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Donner les bons droits à Apache
RUN chown -R www-data:www-data /var/www/html

# Exposer le port HTTP
EXPOSE 80

# Lancer Apache en mode foreground
CMD ["apache2-foreground"]
