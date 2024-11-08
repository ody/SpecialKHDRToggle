# Do the logging
$logFile = Join-Path -Path $PSScriptRoot -ChildPath "log.txt"
Start-Transcript -Path $logFile

Write-Host "Starting SpecialK HDR Toggle..."

# Load the PSIni module
Import-Module PSIni

# Define the path to the JSON file relative to the script's location
$jsonFilePath = Join-Path -Path $PSScriptRoot -ChildPath "games.json"

# Load the JSON file
$jsonContent = Get-Content -Path $jsonFilePath -Raw | ConvertFrom-Json

# Get the environment variable value
$clientHdrState = $env:SUNSHINE_CLIENT_HDR

Write-Host "Moonlight client HDR state: $clientHdrState"

# Iterate over each name in the JSON file
foreach ($game in $jsonContent.games) {
    # Construct the path to the INI file
    $iniFilePath = Join-Path -Path $env:USERPROFILE -ChildPath "Documents\My Mods\SpecialK\Profiles\$game\dxgi.ini"

    # Check if the INI file exists
    if (Test-Path -Path $iniFilePath) {
        # Read the INI file content
        $iniContent = Get-IniContent $iniFilePath

        # Check if the SpecialK.HDR section exists
        if (-not $iniContent.Contains('SpecialK.HDR')) {
            throw "Error: The section 'SpecialK.HDR' does not exist in $iniFilePath"
        }

        # Update the Use16BitSwapChain setting in the SpecialK.HDR section
        if ($iniContent['SpecialK.HDR'].Contains('Use16BitSwapChain')) {
            $iniContent['SpecialK.HDR']['Use16BitSwapChain'] = $clientHdrState
        } else {
            throw "Error: The key 'Use16BitSwapChain' does not exist in the 'SpecialK.HDR' section of $iniFilePath"
        }

        # Write the updated content back to the INI file
        Out-IniFile -InputObject $iniContent -FilePath $iniFilePath -Force

        Write-Host "Updated $iniFilePath to HDR Status of $clientHdrState"
    } else {
        Write-Host "INI file not found for $game"
    }
}