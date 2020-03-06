# LiteSpeed Docker Container (Beta)
[![Build Status](https://travis-ci.com/litespeedtech/lsws-docker-env.svg?branch=master)](https://hub.docker.com/r/litespeedtech/litespeed)
[![LiteSpeed](https://img.shields.io/badge/litespeed-5.4.5-informational?style=flat&color=blue)](https://hub.docker.com/r/litespeedtech/litespeed)
[![docker pulls](https://img.shields.io/docker/pulls/litespeedtech/litespeed?style=flat&color=blue)](https://hub.docker.com/r/litespeedtech/litespeed)
[![beta pulls](https://img.shields.io/docker/pulls/litespeedtech/litespeed-beta?label=beta%20pulls)](https://hub.docker.com/r/litespeedtech/litespeed-beta)
[<img src="https://img.shields.io/badge/slack-LiteSpeed-blue.svg?logo=slack">](litespeedtech.com/slack) 
[<img src="https://img.shields.io/twitter/follow/litespeedtech.svg?label=Follow&style=social">](https://twitter.com/litespeedtech)

Install a lightweight LiteSpeed container using Stable version in Ubuntu 18.04 Linux.

### Prerequisites
*  [Install Docker](https://www.docker.com/)

## Build Components
The system will regulary build LiteSpeed Latest stable version, along with the last two PHP versions.

|Component|Version|
| :-------------: | :-------------: |
|Linux|Ubuntu 18.04|
|LiteSpeed|[Latest stable version](https://www.litespeedtech.com/products/litespeed-web-server/download)|
|PHP|[Latest stable version](http://rpms.litespeedtech.com/debian/)|

## Usage
### Download an image
Download the litespeed image, we can use latest for latest version
```
docker pull litespeedtech/litespeed:latest
```
or specify the LiteSpeed version with lsphp version
```
docker pull litespeedtech/litespeed-beta:5.4.5-lsphp74
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

### Verify
We can add a sample page to make sure server is working correctly. First, we want to login to the container and add a test file. 
```
docker exec -it litespeed bash
```
We should see **/var/www/vhosts/** as our default `WORKDIR`. Since the default document root path is **/var/www/vhosts/localhost/html**. Simply add the following command to index.php file. 
```
echo '<?php phpinfo();' > localhost/html/index.php
```
Now we can verify it from the browser with a public server IP address or pointed Domain on both HTTP/HTTPS. 

### Stopping a Container
Feel free to substitute the "litespeed" to the "Container_ID" if you did not define any name for the container.
```
docker stop litespeed
```

## Support & Feedback
If you still have a question after using LiteSpeed Docker, you have a few options.
* Join [the GoLiteSpeed Slack community](litespeedtech.com/slack) for real-time discussion
* Post to [the LiteSpeed Forums](https://www.litespeedtech.com/support/forum/) for community support
* Reporting any issue on [Github ols-dockerfiles](https://github.com/litespeedtech/ols-dockerfiles/issues) project

**Pull requests are always welcome** 