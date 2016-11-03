# docker-cartodb
This is a dockerized Carto(DB) installation, based on the official [Carto Installation Documentation](http://cartodb.readthedocs.io/en/latest/install.html), using the latest dependencies including ogr2ogr2.1

You should be able to map most of the steps in the `Dockerfile` with those on the install documentation. The steps below were written with a Digital Ocean droplet (docker pre-installed) in mind.

##Build the Container
Go make a sandwich, this will take a while... (About an hour)
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
The scripts created an individual account:  `dev/pass1234`
and an organization with a default account: `admin4example/pass1234`

##To use a Real Domain
I have done this, but not recently.  IIRC, you just need to swap out every place where you see "cartodb.localhost" in `app_config.yml` and enter your domain name, then set up a DNS record to point to the IP address of your server.  You can connect to the docker container's command line with `docker exec -it <yourcontainerid> bin/bash`, make changes to the `app_config.yml` and then restart the container.  It will reload the rails app with the new settings.

##To configure SSL
I have also done this, but not recently.  I believe it is set up as an NGINX proxy.  You can use letsencrypt to quickly get a free SSL cert for your droplet, then configure nginx to listen for https traffic and send it all to the carto docker container which is still listening on http as it always was.  The trick is that the urls that the app sends to the browser may be http so you can get mixed content errors, so you have to make more changes to `app_config.yml` to tell it to embed https urls in links.  This is kind of a brain dump, and I will recreate the steps someday and document them here.

##To enable GZIP
This can also be done in nginx, you just need to enable gzip and add the mime types that carto uses.  

##To use carto-served vector tiles
This is unrelated to carto in Docker, but It's exciting so I thought I would share it.  [See this gist](http://bl.ocks.org/chriswhong/2695b75fd1936bd034df83c91738648d) 

##Attribution
First and foremost, thank you to the Carto team for such a great product that is also open source!
This Dockerfile was inspired by and largely based on [Stefan Verhoeven's image](https://github.com/sverhoeven/docker-cartodb). I could not get it working and descided to start over using the official installation docs.  All of the configs are borrowed directly from his. 

##Pull requests and issues welcomed!
If this doesn't work for you, please open an issue and let's figure out why.
