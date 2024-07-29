Invoke-RestMethod -Uri "https://github.com/kcarbonaro/eyetech-public/blob/ca8323b0e66ea36f2aa35b06c05b242052e753b4/common-functions/custom-installer-functions.ps1" -OutFile ".\custom-installer-functions.ps1"
. .\custom-installer-functions.ps1

# Set variables
$tempDir = "c:\temp"
$installerLockFilename = "installer.lck"
$InstallerLockExpiry = 2
$appDisplayName = "*Libre*"
$installerFilename = "LibreOffice.msi"

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

# Remove installer lock after installation
Remove-CustomInstallerLock -FilePath "$tempDir\$installerLockFilename"

# Clean up the installation file
Remove-InstallationFile -FilePath "$tempDir\$installerFilename"
