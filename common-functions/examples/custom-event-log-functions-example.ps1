Invoke-RestMethod -Uri "https://github.com/kcarbonaro/eyetech-public/blob/a21d734ae39b2281ee7b170d0352bd146283d40c/common-functions/custom-event-log-functions.ps1" -OutFile ".\custom-event-log-functions.ps1"
. .\custom-event-log-functions.ps1

# Example usage
$logName = "CustomLog"
$sourceName = "CustomSource"

# Ensure the event log exists
Create-CustomEventLog -logName $logName -sourceName $sourceName

# Write an event to the log
Write-CustomEventToLog -logName $logName -sourceName $sourceName -entryType "Information" -eventId 2 -message "This is a custom event."

# Get the last 5 events from the log
$events = Get-CustomEventsFromLog -logName $logName -numberOfEvents 5
$events | ForEach-Object { Write-Output $_ }

# Clear the event log
Clear-CustomEventLog -logName $logName

# Remove the event log completely
Remove-CustomEventLog -logName $logName
