Invoke-RestMethod -Uri "https://github.com/kcarbonaro/eyetech-public/blob/ca8323b0e66ea36f2aa35b06c05b242052e753b4/common-functions/custom-installer-functions.ps1" -OutFile ".\custom-installer-functions.ps1"
. .\custom-installer-functions.ps1

# Set variables
$tempDir = "c:\temp"
$installerLockFilename = "installer.lck"
$InstallerLockExpiry = 2
$appDisplayName = "*Lenovo System Update"
$installerFilename = "system_update_5.08.03.59.exe"

$downloadUrl = "https://download.lenovo.com/pccbbs/thinkvantage_en/system_update_5.08.03.59.exe"
$downloadPath = "$tempDir\system_update_5.08.03.59.exe"
$timeoutSec = 600

# Create Temp directory if it does not exist
Create-TempDirectory -TempDir $tempDir

# Check for an existing installer lock
Check-CustomInstallerLock -FilePath "$tempDir\$installerLockFilename" -Hours $InstallerLockExpiry

# Check if the app is already installed
Check-IfAppIsInstalled -AppDisplayName $appDisplayName

# Create an installer lock
Create-CustomInstallerLock -FilePath "$tempDir\$installerLockFilename"

#
# Proceed with installation steps here...
#
Download-File -Url $downloadUrl -DestinationPath $downloadPath -TimeoutSec $timeoutSec -Overwrite
Start-Process -FilePath $downloadPath -ArgumentList "/VERYSILENT /NORESTART" -Wait

# Remove installer lock after installation
Remove-CustomInstallerLock -FilePath "$tempDir\$installerLockFilename"

# Clean up the installation file
Remove-InstallationFile -FilePath "$tempDir\$installerFilename"
