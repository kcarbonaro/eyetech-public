# =========================================================
# Function to Search AD Users and get their details from AD
# ---------------------------------------------------------
function Search-ADUsername {
    param (
        [string]$Domain,
        [string]$Username,
        [string]$Password,
        [string]$SamAccountName
    )

    # Create Directory Entry object
    $objDomain = New-Object System.DirectoryServices.DirectoryEntry "LDAP://$Domain", $Username, $Password

    # Configure the Directory Searcher
    $objSearcher = New-Object System.DirectoryServices.DirectorySearcher
    $objSearcher.SearchRoot = $objDomain
    $objSearcher.PageSize = 1000
    $objSearcher.Filter = "(&(objectCategory=person)(samaccountname=$SamAccountName))"
    $objSearcher.SearchScope = "Subtree"
    
    # Perform the search and return selected properties of the first result
    $searchResult = $objSearcher.FindOne()

    if ($searchResult -ne $null) {
        # Retrieve the user properties from the search result
        $userProps = @{
            DisplayName = $searchResult.Properties["displayname"][0]
            Designation = $searchResult.Properties["title"][0]
        }

        # Return the user properties
        return $userProps
    } else {
        Write-Error "The user '$SamAccountName' was not found in the domain."
        return $null
    }
}

# ==================================================================
# Function to search for a given computer name in Active Directory 
# and return its properties like Operating System, OS Version, etc.
# ------------------------------------------------------------------
function Search-ADComputerName {
    param (
        [string]$Domain,
        [string]$Username,
        [string]$Password,
        [string]$ComputerName
    )

    # Create Directory Entry object
    $objDomain = New-Object System.DirectoryServices.DirectoryEntry "LDAP://$Domain", $Username, $Password

    # Configure the Directory Searcher
    $objSearcher = New-Object System.DirectoryServices.DirectorySearcher
    $objSearcher.SearchRoot = $objDomain
    $objSearcher.PageSize = 1000
    
    # Filter to find the specific computer name
    $objSearcher.Filter = "(&(objectCategory=computer)(name=$ComputerName))"

    # Specify the properties you want to retrieve
    $objSearcher.PropertiesToLoad.Add("name")
    $objSearcher.PropertiesToLoad.Add("operatingSystem")
    $objSearcher.PropertiesToLoad.Add("operatingSystemVersion")
    $objSearcher.PropertiesToLoad.Add("lastLogonTimestamp")
    
    # Execute the search
    $searchResult = $objSearcher.FindOne()

    if ($searchResult -ne $null) {
        # Retrieve the properties from the search result
        $computerProps = @{
            Name = $searchResult.Properties["name"][0]
            OperatingSystem = $searchResult.Properties["operatingSystem"][0]
            OperatingSystemVersion = $searchResult.Properties["operatingSystemVersion"][0]
            LastLogonTimestamp = [DateTime]::FromFileTime([Int64]$searchResult.Properties["lastLogonTimestamp"][0])
        }

        # Return the properties of the computer
        return $computerProps
    } else {
        Write-Error "The computer '$ComputerName' was not found in the domain."
        return $null
    }
}
