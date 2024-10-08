# ====================================================
# Generic Read JSON file content to Hashtable Function
# ----------------------------------------------------
function Get-JsonData {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )

    # Check if the JSON file exists
    if (-Not (Test-Path -Path $FilePath)) {
        Write-Error "The file '$FilePath' does not exist."
        return $null
    }

    # Read the JSON content from the file
    $jsonContent = Get-Content -Path $FilePath -Raw | ConvertFrom-Json

    # Return the JSON object for further use
    return $jsonContent
}

# ==================================================
# Generic Save to JSON file from hashtable Function
# --------------------------------------------------
function Save-JsonData {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath,
        [Parameter(Mandatory = $true)]
        [hashtable]$Data
    )

    # Convert the hashtable to JSON and save it to the file
    $jsonContent = $Data | ConvertTo-Json -Depth 3
    Set-Content -Path $FilePath -Value $jsonContent
}
