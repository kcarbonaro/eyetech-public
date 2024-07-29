Invoke-RestMethod -Uri "https://github.com/kcarbonaro/eyetech-public/blob/51a2d171c25417597cad86b62b1c2327a2ff69dc/common-functions/custom-registry-functions.ps1" -OutFile ".\custom-registry-functions.ps1"
. .\custom-registry-functions.ps1

# Set variables
$BaseKey = "companyname"

# Create-CustomRegistrySoftwareStructure -BaseKey $BaseKey
Add-CustomRegistrySoftware -BaseKey $BaseKey -SoftwareName "Foxit"
Add-CustomRegistrySoftware -BaseKey $BaseKey -SoftwareName "Libre Office"

# Update software status
Update-CustomRegistrySoftwareStatus -BaseKey $BaseKey -SoftwareName "Foxit" -Installed "Yes"
Update-CustomRegistrySoftwareStatus -BaseKey $BaseKey -SoftwareName "Libre Office" -Installed "No"

# Check software status
$foxitStatus = Check-CustomRegistrySoftwareStatus -BaseKey $BaseKey -SoftwareName "Foxit"
$libreOfficeStatus = Check-CustomRegistrySoftwareStatus -BaseKey $BaseKey -SoftwareName "Libre Office"

$foxitStatus | Format-Table
$libreOfficeStatus | Format-Table

# Remove software and base key
Remove-CustomRegistrySoftware -BaseKey $BaseKey -SoftwareName "Foxit"
Remove-CustomRegistrySoftwareStructure -BaseKey $BaseKey
