FROM ubuntu:22.04

# Avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install Apache, MySQL, PHP, Perl and SSH
RUN apt-get update && apt-get install -y \
    apache2 \
    mysql-server \
    php \
    php-mysql \
    libapache2-mod-php \
    perl \
    libdbi-perl \
    libdbd-mysql-perl \
    libtimedate-perl \
    libhtml-template-perl \
    libcgi-pm-perl \
    libwww-perl \
    openssh-server \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configure SSH
RUN mkdir /var/run/sshd
RUN echo 'root:password' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# Configure Apache
RUN a2enmod cgi
RUN sed -i 's/DirectoryIndex index.html index.cgi index.pl index.php/DirectoryIndex index.pl index.cgi index.php index.html/g' /etc/apache2/mods-enabled/dir.conf

# Create directory for Perl scripts
RUN mkdir -p /var/www/html/perl
RUN chown -R www-data:www-data /var/www/html/

# Make sure CGI is enabled for Perl
RUN echo 'AddHandler cgi-script .pl .cgi' >> /etc/apache2/apache2.conf
RUN echo '<Directory "/var/www/html">\n\
    Options +ExecCGI\n\
    Options +FollowSymLinks\n\
</Directory>' >> /etc/apache2/conf-available/perl-cgi.conf
RUN a2enconf perl-cgi

# Create a default test script in case the www directory is empty
RUN echo '#!/usr/bin/perl\n\
print "Content-type: text/html\\n\\n";\n\
print "<html><head><title>Perl CGI Test</title></head>";\n\
print "<body>";\n\
print "<h1>Perl is working!</h1>";\n\
print "<p>Server time: ", scalar(localtime), "</p>";\n\
print "<p>This is the default test script. Place your custom scripts in the www folder.</p>";\n\
print "</body></html>";\n' > /var/www/html/perl/test.pl
RUN chmod +x /var/www/html/perl/test.pl

# Setup MySQL
RUN service mysql start && \
    mysql -e "CREATE DATABASE testdb;" && \
    mysql -e "CREATE USER 'testuser'@'localhost' IDENTIFIED BY 'password';" && \
    mysql -e "GRANT ALL PRIVILEGES ON testdb.* TO 'testuser'@'localhost';" && \
    mysql -e "FLUSH PRIVILEGES;"

# Create a sample table
RUN service mysql start && \
    mysql testdb -e "CREATE TABLE test_table (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(50), value VARCHAR(255));" && \
    mysql testdb -e "INSERT INTO test_table (name, value) VALUES ('test1', 'Hello from MySQL');"

# Expose ports
EXPOSE 22 80 3306

# Setup entrypoint script to handle permissions and startup
RUN echo '#!/bin/bash\n\
# Make sure all Perl scripts are executable\n\
find /var/www/html -name "*.pl" -exec chmod +x {} \\;\n\
find /var/www/html -name "*.cgi" -exec chmod +x {} \\;\n\
\n\
# Ensure proper ownership\n\
chown -R www-data:www-data /var/www/html\n\
\n\
# Start services\n\
service ssh start\n\
service mysql start\n\
apache2ctl -D FOREGROUND\n\
' > /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Start services
ENTRYPOINT ["/entrypoint.sh"]
