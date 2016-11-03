# docker-cartodb
This is a dockerized Carto(DB) installation, based on the official [Carto Installation Documentation](http://cartodb.readthedocs.io/en/latest/install.html), using the latest dependencies including ogr2ogr2.1

You should be able to map most of the steps in the `Dockerfile` with those on the install documentation. The steps below were written with a Digital Ocean droplet (docker pre-installed) in mind.

##Build the Container
Go make a sandwich, this will take a while...
```
git clone https://github.com/chriswhong/docker-cartodb.git
docker build -t="cartodb" docker-cartodb/
```
##Run the Container
This command runs the container with the three main services mapped to the host machine.  `3000` for the frontend, `8080` for the Windshaft Map Tiler (Maps API), and `8181` for the SQL API.
`docker run -d -p 3000:3000 -p 8080:8080 -p 8181:8181 cartodb`

You can't login until you setup nginx to forward specific URLs to the three ports

##Configure Nginx

Install nginx `apt-get install nginx` and then copy `config/cartodb.nginx.proxy.conf` from this repo to `/etc/nginx/conf.d/` and restart nginx `service nginx restart`

##Configure hosts
The host machine is now listening for web connections on port 80, but it's listening for a specific host name: `cartodb.local`.  This isn't a real domain, so you need to manually edit your local `hosts` file (located at `/private/etc/hosts` on a mac).  Add a new line `{your server's IP address} cartodb.localhost`

Fire up your browser and go to `http://cartodb.localhost` and you should be greeted with a carto login screen.
The scripts created an individual account:  dev/pass1234`
and an organization with a default account: admin4example/pass1234

##To use a Real Domain
Coming Soon

##To configure SSL
