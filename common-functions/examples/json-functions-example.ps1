# =================
# EXAMPLE JSON FILE
# -----------------
#{
#  "name": "Joe",
#  "role": "RMM Engineer",
#  "skills": ["Python", "PowerShell", "Scripting"]
#}

# =============
# EXAMPLE USAGE
# -------------
# Specify the JSON file path
$jsonFilePath = "C:\path\to\your\example.json"
$jsonOtherFilePath = "C:\path\to\your\example2.json"

# Read the JSON data
$jsonData = Get-JsonData -FilePath $jsonFilePath

# Display the current content of the JSON file
Write-Host "Current JSON Data:"
$jsonData

# Save the JSON data
Save-JsonData -FilePath $jsonFilePath -Data $jsonHash
