# Function to create an installer lock.
function Create-CustomInstallerLock {
    param (
        [string]$FilePath = "C:\temp\installer.lck"
    )
    if (-Not (Test-Path -Path $FilePath)) {
        New-Item -Path $FilePath -ItemType File
        Write-Output "Installer lock created."
    }
    else {
        Write-Output "Installer lock already exists."
    }
}

# Function to check if an installer lock exists and remove it if it is older than the specified number of hours.
function Check-CustomInstallerLock {
    param (
        [string]$FilePath = "C:\temp\installer.lck",
        [int]$Hours = 2
    )
    if (Test-Path -Path $FilePath) {
        $fileCreationTime = (Get-Item $FilePath).CreationTime
        if ($fileCreationTime -lt (Get-Date).AddHours(-$Hours)) {
            Remove-CustomInstallerLock -FilePath $FilePath
            Write-Output "Old installer lock removed. Continuing script."
        }
        else {
            Write-Output "Installer lock exists and is not older than $Hours hours. Exiting script."
            return $false  # Return false to indicate the script should stop
        }
    }
    else {
        Write-Output "Installer lock does not exist. Continuing script."
    }
    return $true  # Return true to indicate the script can continue
}

# Function to remove the installer lock.
function Remove-CustomInstallerLock {
    param (
        [string]$FilePath = "C:\temp\installer.lck"
    )
    if (Test-Path -Path $FilePath) {
        Remove-Item -Path $FilePath
        Write-Output "Installer lock removed."
    }
    else {
        Write-Output "Installer lock does not exist."
    }
}

# Function to ensure the specified temp directory exists.
function Create-TempDirectory {
    param (
        [string]$TempDir = "C:\temp"
    )
    if (-Not (Test-Path -Path $TempDir)) {
        New-Item -Path $TempDir -ItemType Directory
        Write-Output "Created directory: $TempDir"
    }
    else {
        Write-Output "$TempDir directory already exists."
    }
}

# Function to check if the application specified in $AppDisplayName is installed.
function Is-AppInstalled {
    param (
        [string]$AppDisplayName
    )

    $keys = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
    )

    foreach ($key in $keys) {
        try {
            $subkeys = Get-ChildItem -Path $key -ErrorAction Stop
            foreach ($subkey in $subkeys) {
                try {
                    $product = Get-ItemProperty -Path "$key\$($subkey.PSChildName)" -ErrorAction Stop
                    if ($null -ne $product.DisplayName -and $product.DisplayName -like $AppDisplayName) {
                        Write-Output "Detected App: $($product.DisplayName)"
                        return $true
                    }
                }
                catch {
                    Write-Output "Failed to read registry key: $key\$($subkey.PSChildName). Error: $_"
                    continue
                }
            }
        }
        catch {
            Write-Output "Error accessing registry key: $key. Error: $_"
        }
    }
    return $false
}

# Function to check if the application specified in $AppDisplayName is already installed.
function Check-IfAppIsInstalled {
    param (
        [string]$AppDisplayName
    )

    if (Is-AppInstalled -AppDisplayName $AppDisplayName) {
        Write-Output "Application is already installed. Exiting script."
        return $false  # Return false to indicate the script should stop
    }
    else {
        Write-Output "Application is not installed. Proceeding with installation."
        return $true  # Return true to indicate the script can continue
    }
}

# Function to remove the installation file.
function Remove-InstallationFile {
    param (
        [string]$FilePath
    )

    try {
        Remove-Item -Path $FilePath -ErrorAction Stop
        Write-Output "Cleaned up installer."
    }
    catch {
        Write-Output "Error during cleanup: $_"
    }
}

function Download-File {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Url,

        [Parameter(Mandatory = $false, Position = 1)]
        [string]$DestinationPath = $(Join-Path -Path $env:TEMP -ChildPath (Split-Path -Leaf $Url)),

        [Parameter(Mandatory = $false)]
        [int]$TimeoutSec = 300,

        [Parameter(Mandatory = $false)]
        [string]$UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",

        [Parameter(Mandatory = $false)]
        [Switch]$Overwrite
    )

    # Check if the destination file exists and if overwrite is not allowed
    if (Test-Path -Path $DestinationPath) {
        if (-not $Overwrite.IsPresent) {
            Write-Warning "The file '$DestinationPath' already exists. Use -Overwrite to overwrite it."
            return
        }
    }

    try {
        $webClient = New-Object System.Net.WebClient
        $webClient.Headers["User-Agent"] = $UserAgent
        $webClient.DownloadFile($Url, $DestinationPath)

        Write-Host "File downloaded successfully to '$DestinationPath'."
    }
    catch {
        Write-Error "Failed to download file from '$Url'. Error: $_"
    }
    finally {
        $webClient.Dispose()
    }
}
