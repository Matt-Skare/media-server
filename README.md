# AWMSDD (Automated Windows Media Server for Docker Desktop)

- [Media Server](#media-server)
  - [About](#about)
  - [Installation](#installation)
    - [Install Docker](#install-docker)
    - [Clone this repo](#clone-this-repo)
    - [Build your `.env` file](#build-your-env-file)
  - [Configuration](#configuration)
    - [Configure Prowlarr](#configure-prowlarr)
    - [Configure Radarr](#configure-radarr)
    - [Configure Sonarr](#configure-sonarr)
    - [Configure Lidarr](#configure-lidarr)
    - [Configure Bazarr](#configure-bazarr)
    - [Configure Plex](#configure-plex)
    - [Configure Overseerr](#configure-overseerr)
  - [Thank You](#thank-you)
    - [Other media servers](#other-media-servers)
  - [Future Plans](#future-plans)
  - [Troubleshooting](#troubleshooting)

```
                __    __          __                          
  _____ _____ _/  |__/  |_  _____|  | _______ _______   ____  
 /     \\__  \\   __\   __\/  ___/  |/ /\__  \\_  __ \_/ __ \ 
|  Y Y  \/ __ \|  |  |  |  \___ \|    <  / __ \|  | \/\  ___/ 
|__|_|  (____  /__|  |__| /____  >__|_ \(____  /__|    \___  >
      \/     \/                \/     \/     \/            \/ 
```

---

# Media Server

## About

This is an automated media server using docker desktop on Windows. The goal of this project is to provide media server functionality to Windows users, while maintaing simplicity and keeping the configuration lightweight.

The media server uses the following components

- `plex`
- `sonarr`
- `radarr`
- `lidarr`
- `prowlarr`
- `bazarr`
- ~~`tautulli`~~ (future)
  - to look at plex server logs
- ~~`portainer`~~ (future)
  - container management
- ~~`watchtower`~~ (future)
  - automating container updates
- ~~`nginx + letsencrypt`~~ (future)
  - reverse proxying to reach your services at \*.domain.tld
- ~~`heimdall`~~ (future)
  - application dashboard
- `gluetun`
- `qBittorrent`
- `overseerr`
- `flaresolverr`

Configuration steps are as follows:

1. Install docker desktop
2. define configuration variables
3. `docker-compose up`
4. configure `qbittorrent`
5. add an indexer to `prowlarr`
6. configure `sonarr` / `radarr` / `lidarr` to use the `prowlarr` indexer
7. configure `sonarr` / `radarr` / `lidarr` to use `qbittorrent` as their download client
8. add libraries to `plex`
9. configure `overseerr` to request new content
10. start watching!

## Installation

### Install Docker

- <https://www.docker.com/products/docker-desktop/>

### Clone this repo

```sh
git clone https://github.com/Matt-Skare/media-server.git
```

### Build your `.env` file

The provided `config.env` file contains my recommend configuration, which is mostly default settings for the included apps. The directory structure provided will ensure your downloads and content are organized in such a way that all applications can access what they need. If you choose to modify the default configuration (outside of VPN settings), I am not responsible if your media server becomes unusable in the future.

#### VPN setup

This media server uses `gluetun` to provide a VPN service to other containers. I will include instructions for configuring gluetun to use Mullvad, all other VPN providers are outside the scope of this documentation.

- Retrieve your wireguard configuration from Mullvad
  - Go to your Mullvad account page
  - Under `Downloads` select `WireGuard configuration`
  - Click `Generate key`
  - Scroll down to `Select one or multiple exit locations`
  - Select your desired country, city, and server (or all servers)
  - Download zip archive.
- Open one of the downloaded `.conf` files (it doesn't matter which one, we only care about the private key and wireguard address which should be the same across all files)
- Open the `config.env` file
- Under the gluetun settings `VPN_SERVICE_PROVIDER` and `VPN_TYPE` should already be set to mullvad, and wireguard respectively. If they are not, change them now.
- Copy the `PrivateKey` value from the mullvad .conf file to `WIREGUARD_PRIVATE_KEY` in `config.env`
- Copy the IPv4 address (XXX.XXX.XXX.XXX/32) from the mullvad .conf file to `WIREGUARD_ADDRESSES` in `config.env`
- Enter the city you selected to create your wireguard configuration after `WIREGUARD_CITY` in `config.env`
- Your gluetun configuration should look something like this:

```sh
# ======== gluetun ========
VPN_SERVICE_PROVIDER=mullvad
VPN_TYPE=wireguard
OPENVPN_USER=
OPENVPN_PASSWORD=
WIREGUARD_PRIVATE_KEY=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
WIREGUARD_ADDRESSES=XXX.XXX.XXX.XXX/32
WIREGUARD_CITY=ATLANTIS
UPDATER_PERIOD=
```

### Deploying the server

When you are finished making changes to the included `config.env` file save it and run `setup.ps1`. Let it finish, it's not frozen it's just waiting for the server to complete before some final configurations.

## Configuration

This guide will assume you are using default configurations. Once the powershell script is done deploying the server we can start configuring the applications.

### Configure qBittorrent

- Retrieve the default password
  - In docker desktop, click on the `qbittorrent` container name.
  - Locate the line `The WebUI administrator password was not set. A temporary password is provided for this session:` and copy the temporary password.
  - Navigate to `http://localhost:8080/`
  - Sign in with the username `admin` and whatever your temporary password is.
- Change default settings and set a new password
  - At the top select `Tools` and then `Downloads`
  - Under `Saving Management` change the Default Torrent Management Mode to `Automatic`
  - Change `When Default Save Path changed:` to `Relocate affected torrents`
  - Change `When Category Save Path changed:` to `Relocate affected torrents`
  - Change the default save path to `/data/torrents`
  - Select the `BitTorrent` tab and set up seeding limits if you would like
  - Select the `Web UI` tab
  - Under `Authentication` set a new password
  - Scroll down and click save.
- Set up categories
  - On the left right click on `All` under categories and choose `Add category`
  - Radarr
    - Category name: `radarr`
    - Save path `/data/torrents/movies`
  - Sonarr
    - Category name: `sonarr`
    - Save path `/data/torrents/tv`
  - Lidarr
    - Category name: `lidarr`
    - Save path `/data/torrents/music`

### Configure Prowlarr

- Navigate to `http://localhost:9696/`
- You will be prompted to set up authentication for prowlarr. For Authentication Method use `Forms`
- Add a new indexer. Select the indexer you would like to add, test the connection, then save.
- Under settings, select indexers. Click the big plus to add a new indexer proxy. Choose FlareSolverr
- Leave the name as `FlareSolverr`, and add the tag `flaresolverr`. Change host from `http://localhost:8191/` to `http://flaresolverr:8191/`
- Save the indexer proxy.
- Open up the file named `setup.conf`. This file contains the API keys we will need to set up our applications. (If the file is empty, run `setup.ps1` again and it should populate.)
- Set up applications. Select `Apps` on the left.
  - Radarr
    - Name: `Radarr`
    - Sync Level: `Add and Remove Only`
    - Tags: Leave this blank
    - Prowlarr Server `http://prowlarr:9696`
    - Radarr Server: `http://radarr:7878`
    - API Key: Your radar API key
    - Test the connection and save.
  - Sonarr
    - Name: `Sonarr`
    - Sync Level: `Add and Remove Only`
    - Tags: Leave this blank
    - Prowlarr Server `http://prowlarr:9696`
    - Sonarr Server: `http://sonarr:8989`
    - API Key: Your sonarr API key
    - Test the connection and save.
  - Lidarr
    - Name: `Lidarr`
    - Sync Level: `Add and Remove Only`
    - Tags: Leave this blank
    - Prowlarr Server `http://prowlarr:9696`
    - Radarr Server: `http://lidarr:8686`
    - API Key: You lidarr API key
    - Test the connection and save.

### Configure Radarr

- Navigate to `http://localhost:7878/` and set up authentication. Same process as prowlarr.
- Click on `Settings` then `Media Management` on the left
  - Check the box for `Rename Movies`. Choose a naming format you like. I'm leaving it as default.
  - Under File Management check the box for `Unmonitor Deleted Movies`
  - Under Root Folders click `Add Root Folder` and choose `/data/media/movies/`
  - Click Save Changes at the top
-  Click on `Profiles` on the left
  - Click on the big plus under `Quality Profiles`
  - Call the profile `1080p/4k`
  - Select everything from `HDTV-1080p` to `Remux-2160p`
  - Check the box for `Upgrades Allowed` and select `Bluray-2160p`
  - Click Save
- Set up qBittorrent as a download client. Select Download Clients on the left.
  - Select `qBittorrent`
    - Name: `qBittorrent`
    - Host: `gluetun` (We are sending qBittorrent traffic through the gluetun container, so prowlarr is unable to connect to qBittorrent directly)
    - Port: `8080`
    - Username: `Your qBittorrent username`
    - Password: `Your qBittorrent password`
    - Category: `radarr`
    - Test connection and save.

### Configure Sonarr

- Navigate to `http://localhost:8989/` and set up authentication. Same process as radarr.
- Click on `Settings` then `Media Management` on the left
  - Check the box for `Rename Episodes`. Choose a naming format you like. I'm leaving it as default.
  - Under File Management check the box for `Unmonitor Deleted Episodes`
  - Under Root Folders click `Add Root Folder` and choose `/data/media/tv/`
  - Click Save Changes at the top
-  Click on `Profiles` on the left
  - Click on the big plus under `Quality Profiles`
  - Call the profile `1080p/4k`
  - Select everything from `WEB 1080p` to `Bluray-2160p Remux`
  - Check the box for `Upgrades Allowed` and select `Bluray-2160p`
  - Click Save
- Set up qBittorrent as a download client. Select Download Clients on the left.
  - Select `qBittorrent`
    - Name: `qBittorrent`
    - Host: `gluetun` (We are sending qBittorrent traffic through the gluetun container, so prowlarr is unable to connect to qBittorrent directly)
    - Port: `8080`
    - Username: `Your qBittorrent username`
    - Password: `Your qBittorrent password`
    - Category: Change `tv-sonarr` to `sonarr`
    - Test connection and save.

### Configure Lidarr

- Navigate to `http://localhost:8686/` and set up authentication. Same process as sonarr.
- Click on `Settings` then `Media Management` on the left
  - Click the big plus to add a new root folder.
    - Name: `Music`
    - Path: Choose `/data/media/music/`
  - Check the box for `Rename Tracks`. Choose a naming format you like. I'm leaving it as default.
  - Click Save Changes at the top
- Set up qBittorrent as a download client. Select Download Clients on the left.
  - Select `qBittorrent`
    - Name: `qBittorrent`
    - Host: `gluetun` (We are sending qBittorrent traffic through the gluetun container, so prowlarr is unable to connect to qBittorrent directly)
    - Port: `8080`
    - Username: `Your qBittorrent username`
    - Password: `Your qBittorrent password`
    - Category: `lidarr`
    - Test connection and save.

### Configure Bazarr

- Navigate to `http://localhost:6767`
- Under `Security` and `Authentication` choose `Form`. Set a username and password.
- Click `Save` at the top
- On the left choose `Languages`.
  - Language Filter: English
  - Click `Add New Profile` and name it `English`
  - Click `Add Language` and select `English`
  - Press `Save`
- Under `Default Settings` enable both toggles and choose the profile we just created.
- Click `Save` at the top
- Click on `Providers` on the left
  - Click the big plus to add a new provider.
  - Choose a subtitles provider. I am choosing OpenSubtitles.com, you do not need to add a username and password.
  - Click `Save` and then again at the top.
- Choose `Sonarr` on the left
  - Address: `sonarr`
  - API Key: `Your sonarr API key`
  - Click `Test`. If a version number is displayed, bazarr connected succesfully to sonarr.
  - Click `Save` at the top.
- Choose `Radarr` on the left
  - Address: `radarr`
  - API Key: `Your radarr API key`
  - Click `Test`. If a version number is displayed, bazarr connected succesfully to radarr.
  - Click `Save` at the top.
 
### Configure Plex

- Navigate to `http://localhost:32400/web/`
- Follow Plex setup as normal.
- When adding your libraries use the folders under `/data/media/`. For example your movies library should be `/data/media/movies/`
- Under `Library` settings check the first three boxes for `Scan my library automatically`, `Run a partial scan when changes are detected`, and `Include music libraries in automatic updates`.

### Configure Overseerr

- Navigate to `http://localhost:5055/setup`
- Sign in with your plex account
- Click the button to list plex servers associated with your account. I would use one of the `secure` servers.
- Click `Save Changes` then enable your Plex libraries and click `Start Scan`. Wait for the scan to complete then click `Continue`.
- Click `Add Radarr Server`
  - Select the box for `Default Server`
  - Server Name: `radarr`
  - Hostname: `radarr`
  - API Key: `Your radarr API key`
  - Click `Test` If this completes succesfully, you will be able to select a quality profile and root folder.
  - Quality Profile: `1080p/4k`
  - Root Folder: `/data/media/movies`
  - Minimum Availability: Your choice. I like to choose announced so when the movie is released it will automatically download.
  - Click `Add Server`
- Click `Add Sonarr Server`
  - Select the box for `Default Server`
  - Server Name: `sonarr`
  - Hostname: `sonarr`
  - API Key: `Your sonarr API key`
  - Click `Test` If this completes succesfully, you will be able to select a quality profile and root folder.
  - Quality Profile: `1080p/4k`
  - Root Folder: `/data/media/tv`
  - Click `Add Server`
- Click `Finish Setup` 

## Thank You

### Other Media Servers

[ghostserverurl]: https://github.com/ghostserverd/mediaserver-docker
[atanasyanewurl]: https://github.com/atanasyanew/media-server

This project is based on a few other media servers that also use docker and *arr services. Check them out here:

- [Automated Media Server 👻][ghostserverurl]
- [Automated home media server][atanasyanewurl]

## Future Plans

- Auto-configuration for `plex` libraries
- Improve documentation
- Better health checking

## Troubleshooting

- qBittorrent is not downloading. DHT is showing 0 nodes, my connection status says "Firewalled". Help!
  - No need to fear. This happens sometimes, I'm working on it. For now the fix is to restart both the gluetun container and the qBittorrent container from docker desktop.
