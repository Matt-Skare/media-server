#                __    __          __                          
#  _____ _____ _/  |__/  |_  _____|  | _______ _______   ____  
# /     \\__  \\   __\   __\/  ___/  |/ /\__  \\_  __ \_/ __ \ 
#|  Y Y  \/ __ \|  |  |  |  \___ \|    <  / __ \|  | \/\  ___/ 
#|__|_|  (____  /__|  |__| /____  >__|_ \(____  /__|    \___  >
#      \/     \/                \/     \/     \/            \/ 
#



#==============
#Create folders
#==============
mkdir config
mkdir data
mkdir data\media
mkdir data\media\movies
mkdir data\media\tv
mkdir data\media\music
mkdir data\torrents
mkdir data\torrents\movies
mkdir data\torrents\tv
mkdir data\usenet\complete
mkdir data\usenet\complete\movies
mkdir data\usenet\complete\tv
mkdir data\usenet\incomplete



#============
#Start server
#============
docker-compose --env-file config.env up -d



#Wait for the server to start up
Start-Sleep -Seconds 120


#============
#Create files
#============
New-Item -ItemType File -Path ".\setup.conf"



#=======================
#Copy API key for bazarr
#=======================
$sourceFile = ".\config\bazarr\config\config.yaml"
$destinationFile = ".\setup.conf"

if (Test-Path $sourceFile) {
    $lines = Get-Content $sourceFile
    $foundAuth = $false

    foreach ($line in $lines) {
        if ($line -like "auth:*") {
            $foundAuth = $true
        } elseif ($foundAuth -and $line -like "  apikey: *") {
            $apiKeyValue = $line.TrimStart("^  apikey: *")
            $apiKeyValue = "bazarr_api_key=" + $apiKeyValue
            Add-Content $destinationFile $apiKeyValue 
            $foundAuth = $false # Reset for subsequent 'auth:' blocks
            break # Stop searching within the block
        }
    }
} else {
   Write-Error "Source file not found: $sourceFile" 
}



#=========================
#Copy API key for prowlarr
#=========================
$sourceFile = ".\config\prowlarr\config.xml"
$destinationFile = ".\setup.conf"

if (Test-Path $sourceFile) {
    [xml]$xmlConfig = Get-Content $sourceFile
    $apiKeyValue = $xmlConfig.Config.ApiKey 
    $apiKeyValue = "prowlarr_api_key=" + $apiKeyValue
    Add-Content $destinationFile $apiKeyValue 
} else {
   Write-Error "Source file not found: $sourceFile" 
}



#=======================
#Copy API key for radarr
#=======================
$sourceFile = ".\config\radarr\config.xml"

if (Test-Path $sourceFile) {
    [xml]$xmlConfig = Get-Content $sourceFile
    $apiKeyValue = $xmlConfig.Config.ApiKey 
    $apiKeyValue = "radarr_api_key=" + $apiKeyValue
    Add-Content $destinationFile $apiKeyValue 
} else {
   Write-Error "Source file not found: $sourceFile" 
}



#=======================
#Copy API key for sonarr
#=======================
$sourceFile = ".\config\sonarr\config.xml"

if (Test-Path $sourceFile) {
    [xml]$xmlConfig = Get-Content $sourceFile
    $apiKeyValue = $xmlConfig.Config.ApiKey 
    $apiKeyValue = "sonarr_api_key=" + $apiKeyValue
    Add-Content $destinationFile $apiKeyValue 
} else {
   Write-Error "Source file not found: $sourceFile" 
}



#=======================
#Copy API key for lidarr
#=======================
$sourceFile = ".\config\lidarr\config.xml"

if (Test-Path $sourceFile) {
    [xml]$xmlConfig = Get-Content $sourceFile
    $apiKeyValue = $xmlConfig.Config.ApiKey 
    $apiKeyValue = "lidarr_api_key=" + $apiKeyValue
    Add-Content $destinationFile $apiKeyValue 
} else {
   Write-Error "Source file not found: $sourceFile" 
}