# D2RB Updater
# Written by Thrack


# Instructions:
# Update the two variables below based on where your previous bot folder is and where the new bot folder is.
# Once set, save the script and run it in Powershell ISE as an administrator.

# Define the old path of the bot.  This is the bot folder where Day and D2RB reside.  Ensure the path ends with a "\".  Example:  C:\D2RB3.2582\
$oldSettingsBotPath = "INSERT OLD BOT LOCATION"

# Define the folder for the new bot.  Ensure the path ends with a "\".  Example: C:\D2RB3.2585\
$newSettingsBotPath = "INSERT OLD BOT LOCATION"



# DO NOT CHANGE ANYTHING  BELOW HERE

# Variables
$newSettingsJsonPath = Join-Path -Path $newSettingsBotPath -ChildPath "\Day"
$oldSettingsJsonPath = Join-Path -Path "$oldSettingsBotPath" -ChildPath "\Day\settings.json"

# Check if settings.json exists in the old path location
if (Test-Path -Path $oldSettingsJsonPath) {
    # Create the new path and directory if they don't exist
    if (-not (Test-Path -Path $newSettingsJsonPath)) {
        $null = New-Item -ItemType Directory -Path (Split-Path $newSettingsJsonPath)
    }

    # Copy settings.json to the new location
    Copy-Item -Path $oldSettingsJsonPath -Destination $newSettingsJsonPath -Force

    $newsettingsfilepath = "$newSettingsJsonPath\settings.json"

    # Replace the BotPath in settings.json with the new destination path
    $content = Get-Content $newsettingsfilepath -Raw
    $content = $content -replace '(\"BotPath\":\s*\")[^"]+(\"),', "`$1$($newSettingsBotPath -replace '\\', '\\')D2RB\\D2RB.exe`$2,"
    Set-Content $newsettingsfilepath -Value $content  

    Write-Host "The settings.json file was copied to the new location and updated successfully"
} else {
    Write-Host "The old path location does not contain a settings.json file"
}
