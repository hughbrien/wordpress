FROM tutum/lamp:latest
MAINTAINER Fernando Mayo <fernando@tutum.co>, Feng Honglin <hfeng@tutum.co>

# Install plugins
RUN apt-get update && \
  apt-get -y install php5-gd && \
  rm -rf /var/lib/apt/lists/*

RUN apt-get -qq update

RUN apt-get -qq -y install curl 

RUN apt-get -qq -y install git

# Download latest version of Wordpress into /app
RUN rm -fr /app && git clone --depth=1 https://github.com/WordPress/WordPress.git /app

# Configure Wordpress to connect to local DB
ADD wp-config.php /app/wp-config.php

# Modify permissions to allow plugin upload
RUN chown -R www-data:www-data /app/wp-content /var/www/html

# Add database setup script
ADD create_mysql_admin_user.sh /create_mysql_admin_user.sh
ADD create_db.sh /create_db.sh
RUN chmod +x /*.sh


RUN sh -c "echo 'deb http://apt.datadoghq.com/ stable main' > /etc/apt/sources.list.d/datadog.list"
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C7A7DA52
RUN sudo apt-get update
RUN sudo apt-get install datadog-agent

#Custom Code to include Key code 
RUN sudo sh -c "sed 's/api_key:.*/api_key: 55f5cd3bfc0fd6a0710c7423da543e10/' /etc/dd-agent/datadog.conf.example > /etc/dd-agent/datadog.conf"

RUN /etc/init.d/datadog-agent start

EXPOSE 80 3306
CMD ["/run.sh"]
