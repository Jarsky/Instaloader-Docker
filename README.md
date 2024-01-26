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

# Updating Session File & Profile List (Powershell)

You're probably running your Docker on a remote server.  
You can use the included Powershell Script on your Windows PC to remotely update these automatically.  

## Requirements:
```
You must be running Docker on Linux
You must have Key Authentication setup for SSH (SFTP) (Key required in PPK format i.e PuTTyKeyGen)
Requires 615_import_firefox_session.py
Requires WinSCP installed and Windows PATH configured
Firefox Browser
```

## Usage:

Download the instaloader.ps1 script to your Windows PC  
Ensure you have all the requirements  
Right click the script and edit the Variables section  
**Do not edit below the variables unless you know what you're doing**   
Run the Powershell script to update your sessions file and/or profile list  

![InstaloaderPS](https://i.imgur.com/CZYr9xf.png)
