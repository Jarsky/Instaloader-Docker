# Instaloader Docker

This is a Dockerfile to automatically build a new Docker for the official Instaloader. 
The Dockerfile will grab the latest release version that is available as a release on the Instaloader GitHub page

The official Instaloader Project: https://github.com/instaloader/instaloader

## Installation
1. Clone the Repository
2. Edit the docker-compose.yml with your environment
3. Run ./instaloader.sh to install Instaloader and to update the docker container

## Usage

For full Instaloader usage, refer to [their documentation here](https://instaloader.github.io/index.html).

This docker image will allow you to pass "settings" and "profiles" arguments automatically. 

The default for Docker would typically be /opt/instaloader/config
The files to be created are:
    settings.txt
    profiles.txt

The settings file contains instaloader arguments. 
I recommend creating the file with at least the following arguments:

```
--login=myusername 
--sessionfile=/session-filename 
--stories
--highlights
--tagged
--fast-update
```

The profiles file contains a list of line seperated profiles or hashtags to scrape. 

```
user1
user2
#hashtag1
#hashtag2
[etc]
```