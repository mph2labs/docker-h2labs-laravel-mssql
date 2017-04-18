FROM ubuntu:wily
MAINTAINER h2labs <mp@h2labs.co.uk>

# Downloads URLs
#ENV MS_ODBC_URL https://download.microsoft.com/download/B/C/D/BCDD264C-7517-4B7D-8159-C99FC5535680/RedHat6/msodbcsql-11.0.2270.0.tar.gz
#ENV FIX_SCRIPT Microsoft--SQL-Server--ODBC-Driver-1.0-for-Linux-Fixed-Install-Scripts
#ENV FIX_SCRIPT_URL https://github.com/Andrewpk/${FIX_SCRIPT}/archive/master.zip

# Set the locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN apt-get update && apt-get -y install aptitude wget unzip make gcc libkrb5-3 libgssapi-krb5-2 apt-transport-https

# Download ODBC install files & scripts
#RUN cd /tmp && wget -O msodbcsql.tar.gz ${MS_ODBC_URL} && wget -O odbc-fixed.zip ${FIX_SCRIPT_URL}

# Unzip downloaded files
#RUN cd /tmp && tar -xzf ./msodbcsql.tar.gz && unzip -o ./odbc-fixed.zip && cp ./${FIX_SCRIPT}-master/* ./msodbcsql-11.0.2270.0

# Run install scripts
#RUN cd /tmp/msodbcsql-11.0.2270.0 && yes YES | ./build_dm.sh --accept-warning --libdir=/usr/lib/x86_64-linux-gnu && ./install.sh install --accept-license --force

# Clean installation files
RUN apt-get remove -y aptitude wget unzip make gcc && apt-get -y autoremove && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN apt-get update && \
    apt-get -y install apache2 php5 php5-mssql git curl php5-mcrypt php5-json freetds-common freetds-bin php5-sybase vim && \
    apt-get -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
    
#Alternative download urls for mssql 13 driver 
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/15.10/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN apt-get update
RUN ACCEPT_EULA=Y apt-get -y install msodbcsql=13.1.4.0-1
RUN apt-get -y install unixodbc-dev

# Clean installation files
RUN apt-get remove -y aptitude wget unzip make gcc && apt-get -y autoremove && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN /usr/sbin/a2enmod rewrite
RUN php5enmod mssql

ADD 000-laravel.conf /etc/apache2/sites-available/
ADD 001-laravel-ssl.conf /etc/apache2/sites-available/
RUN /usr/sbin/a2dissite '*' && /usr/sbin/a2ensite 000-laravel 001-laravel-ssl

RUN /usr/bin/curl -sS https://getcomposer.org/installer |/usr/bin/php
RUN /bin/mv composer.phar /usr/local/bin/composer
RUN /usr/local/bin/composer create-project laravel/laravel /var/www/laravel --prefer-dist
RUN /bin/chown www-data:www-data -R /var/www/laravel/storage /var/www/laravel/bootstrap/cache

# Uncomment these two lines to fix "non-UTF8" chars encoding and time format problems
# ADD freetds.conf /etc/freetds/
# ADD locales.conf /etc/freetds/

EXPOSE 80
EXPOSE 443

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]