# Function to check if a custom event log exists
function Test-CustomEventLog {
    param (
        [string]$logName
    )
    
    return [System.Diagnostics.EventLog]::Exists($logName)
}

# Function to check if a custom event source exists
function Test-CustomEventSource {
    param (
        [string]$sourceName
    )
    
    return [System.Diagnostics.EventLog]::SourceExists($sourceName)
}

# Function to create a custom event log if it doesn't exist
function Create-CustomEventLog {
    param (
        [string]$logName,
        [string]$sourceName
    )

    if (-not (Test-CustomEventLog -logName $logName)) {
        New-EventLog -LogName $logName -Source $sourceName
    }
    elseif (-not (Test-CustomEventSource -sourceName $sourceName)) {
        # If the log exists but the source doesn't, associate the source with the log
        [System.Diagnostics.EventLog]::CreateEventSource($sourceName, $logName)
    }
}

# Function to write an entry to a custom event log
function Write-CustomEventToLog {
    param (
        [string]$logName,
        [string]$sourceName,
        [string]$entryType,
        [int]$eventId,
        [string]$message
    )

    # Ensure the event log exists
    Create-CustomEventLog -logName $logName -sourceName $sourceName
    
    Write-EventLog -LogName $logName -Source $sourceName -EntryType $entryType -EventId $eventId -Message $message
}

# Function to read the last specified number of events from a custom event log
function Get-CustomEventsFromLog {
    param (
        [string]$logName,
        [string]$sourceName = $null,
        [int]$numberOfEvents,
        [int]$eventId = $null
    )

    $events = Get-EventLog -LogName $logName -Newest $numberOfEvents

    if ($sourceName) {
        $events = $events | Where-Object { $_.Source -eq $sourceName }
    }
    if ($eventId) {
        $events = $events | Where-Object { $_.InstanceId -eq $eventId }
    }

    return $events
}

# Function to clear the event log
function Clear-CustomEventLog {
    param (
        [string]$logName
    )
    
    Clear-EventLog -LogName $logName
}

# Function to completely delete the log
function Remove-CustomEventLog {
    param (
        [string]$logName
    )

    if (Test-CustomEventLog -logName $logName) {
        Remove-EventLog -LogName $logName
    }
}
