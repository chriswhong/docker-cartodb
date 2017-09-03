FROM ubuntu:12.04
RUN locale-gen en_US.UTF-8 &&\
	update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
RUN apt-get update &&\
apt-get install -q -y autoconf binutils-doc bison build-essential flex

#apt-utils
RUN apt-get install -q -y apt-utils

#ruby-rvm
RUN apt-get install -q -y ruby-rvm

#varnish
RUN apt-get install -q -y varnish

#git
RUN apt-get install -q -y git

#apt tools
RUN apt-get install -q -y python-software-properties

RUN add-apt-repository ppa:cartodb/gcc &&\
 apt-get update 

RUN apt-get install -q -y gcc-4.9 g++-4.9

ENV CC=/usr/bin/gcc-4.9 
ENV CXX=/usr/bin/g++-4.9

#postgresql
RUN add-apt-repository ppa:cartodb/postgresql-9.5 && apt-get update

#client packages
RUN apt-get install -q -y libpq5 \
                     libpq-dev \
                     postgresql-client-9.5 \
                     postgresql-client-common
#server packages
RUN apt-get install -q -y postgresql-9.5 \
                     postgresql-contrib-9.5 \
                     postgresql-server-dev-9.5 \
                     postgresql-plpython-9.5

#PostgreSQL Config
RUN sed -i 's/\(peer\|md5\)/trust/' /etc/postgresql/9.5/main/pg_hba.conf 

#create users
RUN service postgresql start && \
createuser publicuser --no-createrole --no-createdb --no-superuser -U postgres && \
createuser tileuser --no-createrole --no-createdb --no-superuser -U postgres && \
service postgresql stop

#carto postgres extension
RUN git clone https://github.com/CartoDB/cartodb-postgresql.git &&\
cd cartodb-postgresql &&\
PGUSER=postgres make install

#GIS dependencies
RUN apt-get upgrade -q -y && add-apt-repository ppa:cartodb/gis && apt-get update &&\
 apt-get install -q -y proj proj-bin proj-data libproj-dev &&\ 
 apt-get install -q -y libjson0 libjson0-dev python-simplejson &&\ 
 apt-get install -q -y libgeos-c1v5 libgeos-dev &&\ 
 apt-get install -q -y gdal-bin libgdal1-dev libgdal-dev &&\
 apt-get install -q -y gdal2.1-static-bin

#postgis
RUN apt-get -q -y install libxml2-dev &&\
apt-get install -q -y liblwgeom-2.2.2 postgis postgresql-9.5-postgis-2.2 postgresql-9.5-postgis-scripts

#postgis setup
RUN service postgresql start && \
  createdb -T template0 -O postgres -U postgres -E UTF8 template_postgis &&\
  psql -U postgres template_postgis -c 'CREATE EXTENSION postgis;CREATE EXTENSION postgis_topology;' &&\
  ldconfig &&\
  service postgresql stop

#redis
RUN add-apt-repository ppa:cartodb/redis && apt-get update

RUN apt-get install -q -y redis-server

#nodejs
RUN add-apt-repository ppa:cartodb/nodejs &&\
apt-get update &&\
apt-get install -q -y nodejs

RUN apt-get install -q -y libpixman-1-0 libpixman-1-dev
RUN apt-get install -q -y libcairo2-dev libjpeg-dev libgif-dev libpango1.0-dev

#SQL API
RUN git clone git://github.com/CartoDB/CartoDB-SQL-API.git &&\
cd CartoDB-SQL-API &&\
git checkout master &&\
npm install 

#MAPS API:
RUN git clone git://github.com/CartoDB/Windshaft-cartodb.git &&\
cd Windshaft-cartodb &&\
git checkout master &&\
npm install

#Ruby
RUN apt-get install -q -y wget &&\
wget -O ruby-install-0.5.0.tar.gz https://github.com/postmodern/ruby-install/archive/v0.5.0.tar.gz &&\
tar -xzvf ruby-install-0.5.0.tar.gz &&\
cd ruby-install-0.5.0/ &&\
make install

RUN apt-get -q -y install libreadline6-dev openssl &&\
ruby-install ruby 2.2.3 

ENV PATH=$PATH:/opt/rubies/ruby-2.2.3/bin 

RUN gem install bundler &&\
gem install compass

ENV RAILS_ENV production

#Carto Editor
RUN git clone --recursive https://github.com/CartoDB/cartodb.git &&\
cd cartodb &&\
wget  -O /tmp/get-pip.py https://bootstrap.pypa.io/get-pip.py &&\
python /tmp/get-pip.py 

RUN apt-get install -q -y python-all-dev &&\
apt-get install -q -y imagemagick unp zip 

RUN cd cartodb &&\
bundle install &&\
npm install 

ENV CPLUS_INCLUDE_PATH=/usr/include/gdal
ENV C_INCLUDE_PATH=/usr/include/gdal
ENV PATH=$PATH:/usr/include/gdal

RUN cd cartodb && pip install --no-use-wheel -r python_requirements.txt


#Config Files
ADD ./config/SQLAPI-prod.js \
      /CartoDB-SQL-API/config/environments/production.js
ADD ./config/WS-prod.js \
      /Windshaft-cartodb/config/environments/production.js
ADD ./config/app_config.yml /cartodb/config/app_config.yml
ADD ./config/database.yml /cartodb/config/database.yml
ADD ./config/grunt_production.json /cartodb/config/grunt_production.json

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8


RUN cd cartodb &&\
    export PATH=$PATH:$PWD/node_modules/grunt-cli/bin &&\
    bundle install &&\
    bundle exec grunt --environment production

RUN service postgresql start && service redis-server start &&\
    cd cartodb &&\
    bundle exec rake db:create &&\
    bundle exec rake db:migrate &&\
    service postgresql stop && service redis-server stop


ADD ./create_user /cartodb/script/create_user
RUN service postgresql start && service redis-server start && \
	bash -l -c "cd /cartodb && bash script/create_user" && \
	service postgresql stop && service redis-server stop

EXPOSE 3000 8080 8181

ENV GDAL_DATA /usr/share/gdal/2.1

ADD ./startup.sh /opt/startup.sh
ADD ./config/varnish /etc/default/varnish

VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

CMD ["/bin/bash", "/opt/startup.sh"]
