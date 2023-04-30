# D2RB Updater
# Written by Thrack

# What it does: Updates the path for the bot within the settings.json and transfers all character settings.

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


# Transfer Character files over
# Check if the settings file exists
if (Test-Path -Path "$newSettingsBotPath\Day\settings.json" -PathType Leaf) {
	# Read the settings.json file as JSON
	$settingsJson = Get-Content -Path "$newSettingsBotPath\Day\settings.json" -Raw | ConvertFrom-Json

	# Check if the CharacterName property exists and is not empty
	if ($settingsJson.Bots.CharacterName -and $settingsJson.Bots.CharacterName.Count -gt 0) {
		# Loop through each character name
		foreach ($character in $settingsJson.Bots.CharacterName) {
			# Construct the old and new paths for the character-specific folder
            $oldCharacterPath = Join-Path -Path $oldSettingsBotPath -ChildPath "D2RB\Settings\$character"
			$newCharacterPath = Join-Path -Path $newSettingsBotPath -ChildPath "D2RB\Settings\$character"

			# Check if the old character-specific folder exists
			if (Test-Path -Path $oldCharacterPath -PathType Container) {
				# Create the new character-specific folder if it doesn't exist
				if (-not (Test-Path -Path $newCharacterPath -PathType Container)) {
					New-Item -ItemType Directory -Path $newCharacterPath | Out-Null
				}

				# Copy the contents of the old character-specific folder to the new one
				Copy-Item -Path $oldCharacterPath\* -Destination $newCharacterPath -Recurse -Force
				Write-Host ("Copied character $($character) settings folder to new bot folder.`r`n" )
			}
			                
		}
	} 
	else {
		Write-Host ("No characters found in settings file.`r`n" )
	}
}
else {
    Write-Host ("settings.json not found in old bot folder.`r`n")
}
