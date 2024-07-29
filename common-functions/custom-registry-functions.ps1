function New-CustomRegistryKey {
    param (
        [string]$Path
    )
    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
        Write-Output "Created key: $Path"
    }
    else {
        Write-Output "Key already exists: $Path"
    }
}

function Set-CustomRegistryValue {
    param (
        [string]$Path,
        [string]$Name,
        [string]$Value,
        [Microsoft.Win32.RegistryValueKind]$Type = [Microsoft.Win32.RegistryValueKind]::String
    )
    Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type
    Write-Output "Set value: $Name = $Value at $Path"
}

function Get-CustomRegistryValue {
    param (
        [string]$Path,
        [string]$Name
    )
    try {
        $value = Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop
        return $value.$Name
    }
    catch {
        Write-Output "Failed to get value: $Name at $Path"
        return $null
    }
}

function Create-CustomRegistrySoftwareStructure {
    param (
        [string]$BaseKey
    )
    $basePath = "HKCU:\$BaseKey"
    $softwarePath = "$basePath\Software"
    
    if (-not (Test-Path $softwarePath)) {
        New-CustomRegistryKey -Path $basePath
        New-CustomRegistryKey -Path $softwarePath
        Write-Output "Base structure created successfully under '$BaseKey'."
    }
    else {
        Write-Output "Base structure already exists under '$BaseKey'."
    }
}

function Add-CustomRegistrySoftware {
    param (
        [string]$BaseKey,
        [string]$SoftwareName
    )
    $softwarePath = "HKCU:\$BaseKey\Software\$SoftwareName"
    
    New-CustomRegistryKey -Path $softwarePath
    Set-CustomRegistryValue -Path $softwarePath -Name "Required" -Value "No"
    Set-CustomRegistryValue -Path $softwarePath -Name "Installed" -Value "No"
    Set-CustomRegistryValue -Path $softwarePath -Name "Installed on" -Value ""
    
    Write-Output "Software '$SoftwareName' added with default values under '$BaseKey'."
}

function Update-CustomRegistrySoftwareStatus {
    param (
        [string]$BaseKey,
        [string]$SoftwareName,
        [string]$Installed,
        [string]$InstalledOn = $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    )
    $softwarePath = "HKCU:\$BaseKey\Software\$SoftwareName"
    
    if (Test-Path $softwarePath) {
        if ($Installed -eq "Yes") {
            Set-CustomRegistryValue -Path $softwarePath -Name "Installed" -Value "Yes"
            Set-CustomRegistryValue -Path $softwarePath -Name "Installed on" -Value $InstalledOn
        }
        elseif ($Installed -eq "No") {
            Set-CustomRegistryValue -Path $softwarePath -Name "Installed" -Value "No"
            Set-CustomRegistryValue -Path $softwarePath -Name "Installed on" -Value ""
        }
        
        Write-Output "Software '$SoftwareName' status updated to Installed: $Installed under '$BaseKey'."
    }
    else {
        Write-Output "Software '$SoftwareName' does not exist under '$BaseKey'."
    }
}

function Check-CustomRegistrySoftwareStatus {
    param (
        [string]$BaseKey,
        [string]$SoftwareName
    )
    $softwarePath = "HKCU:\$BaseKey\Software\$SoftwareName"
    
    $required = Get-CustomRegistryValue -Path $softwarePath -Name "Required"
    $installed = Get-CustomRegistryValue -Path $softwarePath -Name "Installed"
    $installedOn = Get-CustomRegistryValue -Path $softwarePath -Name "Installed on"
    
    return @{
        SoftwareName = $SoftwareName
        Required     = $required
        Installed    = $installed
        InstalledOn  = $installedOn
    }
}

function Remove-CustomRegistrySoftware {
    param (
        [string]$BaseKey,
        [string]$SoftwareName
    )
    $softwarePath = "HKCU:\$BaseKey\Software\$SoftwareName"
    
    if (Test-Path $softwarePath) {
        Remove-Item -Path $softwarePath -Recurse -Force
        Write-Output "Software '$SoftwareName' removed from '$BaseKey'."
    }
    else {
        Write-Output "Software '$SoftwareName' does not exist under '$BaseKey'."
    }
}

function Remove-CustomRegistrySoftwareStructure {
    param (
        [string]$BaseKey
    )
    $basePath = "HKCU:\$BaseKey"
    
    if (Test-Path $basePath) {
        Remove-Item -Path $basePath -Recurse -Force
        Write-Output "Base structure and all software under '$BaseKey' removed."
    }
    else {
        Write-Output "Base structure under '$BaseKey' does not exist."
    }
}
