# Load the PSIni module
Import-Module PSIni

# Define the path to the JSON file relative to the script's location
$jsonFilePath = Join-Path -Path $PSScriptRoot -ChildPath "games.json"

# Load the JSON file
$jsonContent = Get-Content -Path $jsonFilePath -Raw | ConvertFrom-Json

# Get the environment variable value
$hdrValue = $env:SUNSHINE_CLIENT_HDR

# Iterate over each name in the JSON file
foreach ($name in $jsonContent.names) {
    # Construct the path to the INI file
    $iniFilePath = Join-Path -Path $env:USERPROFILE -ChildPath "Profiles\$name\dxgi.ini"

    # Check if the INI file exists
    if (Test-Path -Path $iniFilePath) {
        # Read the INI file content
        $iniContent = Get-IniContent -Path $iniFilePath

        # Check if the SpecialK.HDR section exists
        if (-not $iniContent.ContainsKey('SpecialK.HDR')) {
            throw "Error: The section 'SpecialK.HDR' does not exist in $iniFilePath"
        }

        # Update the Use16BitSwapChain setting in the SpecialK.HDR section
        if ($iniContent['SpecialK.HDR'].ContainsKey('Use16BitSwapChain')) {
            $iniContent['SpecialK.HDR']['Use16BitSwapChain'] = $hdrValue
        } else {
            throw "Error: The key 'Use16BitSwapChain' does not exist in the 'SpecialK.HDR' section of $iniFilePath"
        }

        # Write the updated content back to the INI file
        Out-IniFile -InputObject $iniContent -FilePath $iniFilePath

        Write-Output "Updated $iniFilePath"
    } else {
        Write-Output "INI file not found for $name"
    }
}