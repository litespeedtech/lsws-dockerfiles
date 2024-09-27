# LiteSpeed Docker Container
[![Build Status](https://github.com/litespeedtech/lsws-dockerfiles/workflows/docker-build/badge.svg)](https://hub.docker.com/r/litespeedtech/litespeed)
[![docker pulls](https://img.shields.io/docker/pulls/litespeedtech/litespeed?style=flat&color=blue)](https://hub.docker.com/r/litespeedtech/litespeed) 
[<img src="https://img.shields.io/badge/slack-LiteSpeed-blue.svg?logo=slack">](litespeedtech.com/slack) 
[<img src="https://img.shields.io/twitter/follow/litespeedtech.svg?label=Follow&style=social">](https://twitter.com/litespeedtech)

Install a lightweight LiteSpeed container using Stable version in Ubuntu 24.04 Linux.

### Prerequisites
*  [Install Docker](https://www.docker.com/)

## Building Components
The system will regulary build LiteSpeed Latest stable version, along with the last two PHP versions.

|Component|Version|
| :-------------: | :-------------: |
|Linux|Ubuntu 24.04|
|LiteSpeed|[Latest stable version](https://www.litespeedtech.com/products/litespeed-web-server/download)|
|PHP|[Latest stable version](http://rpms.litespeedtech.com/debian/)|

## Usage
### Downloading an image
Download the litespeed image, we can use latest for latest version
```
docker pull litespeedtech/litespeed:latest
```
or specify the LiteSpeed version with lsphp version
```
docker pull litespeedtech/litespeed:6.2.2-lsphp83
```
### Starting a Container
```
docker run --name litespeed -p 7080:7080 -p 80:80 -p 443:443 -it litespeedtech/litespeed-beta:latest
```
You can also run with Detached mode, like so:
```
docker run -d --name litespeed -p 7080:7080 -p 80:80 -p 443:443 -it litespeedtech/litespeed-beta:latest
```
Tip, you can get rid of `-p 7080:7080` from the command if you don’t need the web admin access.  

Note: The container will auto-apply a 15-day trial license. Please contact LiteSpeed to extend the trial, or apply your own license, [starting from $0](https://www.litespeedtech.com/pricing).

### Adding a sample page
The server should start running successfully, and you should be able to log into the container. Add some files you want to display with the following command:
```
docker exec -it openlitespeed bash
```
Your default `WORKDIR` should be `/var/www/vhosts/`, since the default document root path is `/var/www/vhosts/localhost/html`. Simply add the following command to `index.php`, then we can verify it from the browser with a public server IP address on both HTTP and HTTPS. 
```
echo '<?php phpinfo();' > localhost/html/index.php
```

### Stopping a Container
Feel free to substitute the "litespeed" to the "Container_ID" if you did not define any name for the container.
```
docker stop litespeed
```

## Customization
Sometimes you may want to install more packages from the default image, or some other web server or PHP version which is not officially provided. You can build an image based on an existing image. Here’s how:
  1. Download the dockerfile project 
  2. `cd` into the project directory
  3. Edit the Dockerfile here if necessary
  4. Build, feeling free to substitute server and PHP versions to fit your needs 

For example,
```
git clone https://github.com/litespeedtech/lsws-dockerfiles.git
cd lsws-dockerfiles/template
bash build.sh -L 6.2.2 -P lsphp83
```

## Support & Feedback
If you still have a question after using LiteSpeed Docker, you have a few options.
* Join [the GoLiteSpeed Slack community](https://litespeedtech.com/slack/) for real-time discussion
* Post to [the LiteSpeed Forums](https://www.litespeedtech.com/support/forum/) for community support
* Reporting any issue on [Github lsws-dockerfiles](https://github.com/litespeedtech/lsws-dockerfiles/issues) project

**Pull requests are always welcome** 