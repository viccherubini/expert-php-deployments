#!/usr/bin/env bash

# If Vagrant has already been provisioned, do not do anything.
# This saves us from accidentally running `vagrant up` without the --no-provision
# flag and messing up the box.
VAGRANT_PROVISIONED=/etc/vagrant-provisioned

if [ -e $VAGRANT_PROVISIONED ]
then
    exit 0
fi

# Change these accordingly.
DBUSER="vitalstorm_metrics"
DBNAME="vitalstorm_metrics"
DBUSERTEST="vitalstorm_metrics_test"
DBNAMETEST="vitalstorm_metrics_test"

# Install some basic libraries and tools.
apt-get update
apt-get install -y bash-completion build-essential vim libssl-dev openssl git bison flex curl libxml2-utils htop

# Postgres libraries
apt-get install -y libkrb5-dev libxml2 libxml2-dev libxslt1-dev libossp-uuid-dev uuid python-dev libreadline6 libreadline-dev

# PHP libraries
apt-get install -y autoconf libcurl4-openssl-dev libmcrypt4 libmcrypt-dev libicu48 libicu-dev

# Ensure we are using UTF-8 and in UTC for everything.
echo UTC > /etc/timezone
dpkg-reconfigure --frontend noninteractive tzdata
locale-gen en_US.UTF-8
update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

# Update the default .profile so it includes the
# PostgreSQL command line tools in the standard $PATH
wget -qO /etc/skel/.profile https://s3.amazonaws.com/build.brightmarch/.profile

# We will manually compile the most important packages ourselves
# and the code for them is stored in /opt/src.
mkdir -p /opt/src/{ruby,php,php-redis,redis,postgresql}

cd /opt/src/ruby
wget -q https://s3.amazonaws.com/build.brightmarch/ruby-2.0.0-p247.tar.gz
tar -xzf ruby-2.0.0-p247.tar.gz
cd ruby-2.0.0-p247
./configure
make && make install
gem install sass compass

# Create a postgres user that will manage everything Postgres.
useradd --home-dir /home/postgres --create-home --shell /bin/bash --user-group postgres

cd /opt/src/postgresql
wget -q https://s3.amazonaws.com/build.brightmarch/postgresql-9.2.4.tar.bz2
tar -xjf postgresql-9.2.4.tar.bz2
cd postgresql-9.2.4
./configure --disable-debug --enable-thread-safety --with-gssapi --with-openssl --with-libxml --with-libxslt --with-ossp-uuid --with-python --without-bonjour
make world && make install

# Now that Postgres is installed, su into the postgres user to set up the database cluster.
su - postgres -c "initdb -D /home/postgres/cluster -E 'UTF-8'"

# Install the Postgres init.d service script.
wget -qO /etc/init.d/postgres https://s3.amazonaws.com/build.brightmarch/postgres
chmod +x /etc/init.d/postgres
update-rc.d postgres defaults
/etc/init.d/postgres start

# Sleep for 5 seconds to give Postgres a chance to start up.
sleep 5

# Now that the Postgres server is started, created the user and database to use for this project.
su - postgres -c "createuser -d -e -hlocalhost -Upostgres $DBUSER"
su - postgres -c "createdb -E 'UTF-8' -O $DBUSER -hlocalhost -U$DBUSER $DBNAME"
su - postgres -c "createuser -d -e -hlocalhost -Upostgres $DBUSERTEST"
su - postgres -c "createdb -E 'UTF-8' -O $DBUSERTEST -hlocalhost -U$DBUSERTEST $DBNAMETEST"

cd /opt/src/redis
wget -q https://s3.amazonaws.com/build.brightmarch/redis-2.6.10.tar.gz
tar -xzf redis-2.6.10.tar.gz
cd redis-2.6.10
make && make install
mkdir -p /etc/redis
cp redis.conf /etc/redis/redis.conf
sed -i 's/daemonize no/daemonize yes/g' /etc/redis/redis.conf

# Install the Redis init.d service script.
wget -qO /etc/init.d/redis https://s3.amazonaws.com/build.brightmarch/redis
chmod +x /etc/init.d/redis
update-rc.d redis defaults
/etc/init.d/redis start

# Sleep for 5 seconds to give Redis a chance to start up.
sleep 5

cd /opt/src/php
wget -q https://s3.amazonaws.com/build.brightmarch/php-5.5.4.tar.gz
tar -xzf php-5.5.4.tar.gz
cd php-5.5.4
./configure --with-openssl --with-zlib --with-curl --enable-zip --with-xmlrpc --enable-soap --enable-sockets --with-pgsql --with-pdo-pgsql --with-mcrypt --enable-mbstring --with-libxml-dir --enable-intl --enable-pcntl --enable-opcache
make && make install
cp php.ini-development /usr/local/lib/php.ini

cd /opt/src/php-redis
git clone git://github.com/nicolasff/phpredis.git
cd phpredis
phpize
./configure
make && make install

# Add redis.so to the list of extensions so PHP will pick it up.
echo "extension=redis.so" >> /usr/local/lib/php.ini
echo "date.timezone=UTC" >> /usr/local/lib/php.ini

# Add some helpful bash and vim files.
cp /etc/skel/.profile /home/vagrant/.profile
wget -qO /home/vagrant/.bash_aliases https://s3.amazonaws.com/build.brightmarch/.bash_aliases
wget -qO /home/vagrant/.bash_envvars https://s3.amazonaws.com/build.brightmarch/.bash_envvars
wget -qO /home/vagrant/.vimrc https://s3.amazonaws.com/build.brightmarch/.vimrc

chown -R vagrant:vagrant /home/vagrant

touch $VAGRANT_PROVISIONED
