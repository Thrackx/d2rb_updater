
$button4_Click = {
    # Download the file from the provided link
    $global:destinationPath = "C:\Users\Am798\Documents\UpdaterProject\"
    $webpageUrl = "https://raw.githubusercontent.com/Thrackx/d2rb_updater/main/Link"
    $webpageContent = Invoke-WebRequest -Uri $webpageUrl -UseBasicParsing
    $repoUrl = $webpageContent.Content.Trim()
    $fileName = Split-Path -Path $repoUrl -Leaf
    $rardestinationPath = Join-Path $destinationPath $fileName
    Invoke-WebRequest -Uri $repoUrl -OutFile $rardestinationPath
    $textBox1.AppendText("Latest file downloaded to $rardestinationPath`r`n")
}


$button1_Click = {
    $folderBrowserDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowserDialog.Description = "Select Destination Folder"
    if ($folderBrowserDialog.ShowDialog() -eq 'OK') {
        $global:destinationPath = $folderBrowserDialog.SelectedPath
        $textBox2.Text = "$global:destinationPath"
    }
}

$button2_Click = {
    $oldfolderBrowserDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $oldfolderBrowserDialog.Description = "Select the old path location of Bot"
    if ($oldfolderBrowserDialog.ShowDialog() -eq 'OK') {
        $global:oldDestinationPath = $oldfolderBrowserDialog.SelectedPath
		$global:oldPath = Join-Path -Path "$global:oldDestinationPath" -ChildPath "day"
        $global:settingsJsonPath = Join-Path -Path "$global:oldPath" -ChildPath "settings.json"
        $textBox3.Text = "$global:oldDestinationPath"
        #$textBox1.AppendText("SettingJson= $global:settingsJsonPath`r`n")
    }
}

$button3_Click = {
    if (-not $global:destinationPath) {
        $textBox1.AppendText("Please select a destination folder first.`r`n")
    }
    elseif (-not $global:oldDestinationPath) {
        $textBox1.AppendText("Please select the old install location.`r`n")
    }
    else {
        if ($Checkbox3.Checked) {
            $rarFilePath = ""
            # Download the file from the provided link
            $webpageUrl = "https://raw.githubusercontent.com/Thrackx/d2rb_updater/main/Link"
            $webpageContent = Invoke-WebRequest -Uri $webpageUrl -UseBasicParsing
            $repoUrl = $webpageContent.Content.Trim()
            $fileName = Split-Path -Path $repoUrl -Leaf
            #$textBox1.AppendText("Rar File Name: $FileName`r`n")
            $rardestinationPath = Join-Path $destinationPath $fileName
            $textBox1.AppendText("Rar DestinationPath: $rardestinationPath`r`n")
            $textBox1.AppendText("Please wait while rar is downloaded.  This takes around 15 seconds depending on connection.`r`n")
            #$ProgressPreference = 'SilentlyContinue'
            Invoke-WebRequest -Uri $repoUrl -OutFile $rardestinationPath
            $textBox1.AppendText("File downloaded completed to $rardestinationPath`r`n")
            $rarFilePath = $rardestinationPath
            $global:drarfilename = [System.IO.Path]::GetFileNameWithoutExtension($FileName)
        }
               
        else {
            # Seclect the RAR to extract
            $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
            $openFileDialog.Filter = "RAR files (*.rar)|*.rar"
            $openFileDialog.Title = "Select a RAR file to extract"
            $dialogResult = $openFileDialog.ShowDialog()
            if ($dialogResult -eq [System.Windows.Forms.DialogResult]::OK) {
                $rarFilePath = $openFileDialog.FileName
                $global:drarfilename = [System.IO.Path]::GetFileNameWithoutExtension($rarFilePath)
            }
        }

        # Extract the RAR file
        Extract-RarFile -RarFilePath $rarFilePath -DestinationPath $global:destinationPath -TextBox $textBox1
  

            # Check if settings.json exists in the old path location
            if (Test-Path -Path $global:settingsJsonPath) {
                #$textBox1.AppendText("$global:settingsJsonPath`r`n")
                #$textBox1.AppendText("RarFileName: $rarFileName.`r`n")
                #$textBox1.AppendText("G DestPath: $global:destinationPath.`r`n")
                # Copy settings.json to the newly extracted location
                $newPath = Join-Path -Path $global:destinationPath -ChildPath "$global:drarFileName\day"
                #$textBox1.AppendText("New Path: $newPath.`r`n")
                } else {
                $textBox1.AppendText("The old path location does not contain a settings.json file.`r`n")
                }

                if (-not (Test-Path -Path $newPath)) {
                    New-Item -ItemType Directory -Path $newPath | Out-Null
                }           

                $newSettingsJsonPath = Join-Path -Path $newPath -ChildPath "settings.json"
                Copy-Item -Path $global:settingsJsonPath -Destination $newSettingsJsonPath -Force
                $textBox1.AppendText("The settings.json was copied to the new bot folder successfully`r`n" )

                # Replace the BotPath in settings.json with the new destination path
                $content = Get-Content $newSettingsJsonPath -Raw
                $content = $content -replace '("BotPath":\s*")[^"]+(")', "`$1$($global:destinationPath -replace '\\', '\\')\\$global:drarfilename\\D2RB\\D2RB.exe`$2"
                Set-Content $newSettingsJsonPath -Value $content
                $textBox1.AppendText("The BotPath in settings.json was updated successfully`r`n" )

                # Get the path of the settings.json file
                $global:settingsFilePath = Join-Path -Path $global:oldDestinationPath -ChildPath "Day\settings.json"
                

                # Check if the settings file exists
                if (Test-Path -Path $global:settingsFilePath -PathType Leaf) {
	                # Read the settings.json file as JSON
	                $settingsJson = Get-Content -Path $settingsFilePath -Raw | ConvertFrom-Json

	                # Check if the CharacterName property exists and is not empty
	                if ($settingsJson.Bots.CharacterName -and $settingsJson.Bots.CharacterName.Count -gt 0) {
		                # Loop through each character name
		                foreach ($character in $settingsJson.Bots.CharacterName) {
			                # Construct the old and new paths for the character-specific folder
			                $oldCharacterPath = Join-Path -Path $global:oldDestinationPath -ChildPath "D2RB\Settings\$character"
			                $newCharacterPath = Join-Path -Path $global:destinationPath -ChildPath "$global:drarfilename\D2RB\Settings\$character"

			                # Check if the old character-specific folder exists
			                if (Test-Path -Path $oldCharacterPath -PathType Container) {
				                # Create the new character-specific folder if it doesn't exist
				                if (-not (Test-Path -Path $newCharacterPath -PathType Container)) {
					                New-Item -ItemType Directory -Path $newCharacterPath | Out-Null
				                }

				                # Copy the contents of the old character-specific folder to the new one
				                Copy-Item -Path $oldCharacterPath\* -Destination $newCharacterPath -Recurse -Force
				                $textBox1.AppendText("Copied character $($character) settings folder to new bot folder.`r`n" )
			                }
			                
		                }
	                } 
	                else {
		                $textBox1.AppendText("No characters found in settings file.`r`n" )
	                }
                }
                else {
                    $textBox1.AppendText("settings.json not found in old bot folder.`r`n")
                }
          
                # Check if checkBox4 is checked
                if ($checkBox4.Checked) {
                    # Rename the old destination folder
                    if (-not [string]::IsNullOrEmpty($global:oldDestinationPath)) {
                        $oldDestinationFolderName = Split-Path -Path $global:oldDestinationPath -Leaf
                        $parentFolder = Split-Path -Path $global:oldDestinationPath -Parent
                        $newOldDestinationPath = Join-Path -Path $parentFolder -ChildPath "Old_$($oldDestinationFolderName)"
                        Rename-Item -Path $global:oldDestinationPath -NewName $newOldDestinationPath -Force
                        $textBox1.AppendText("Old bot folder successfully renamed to $($newOldDestinationPath)`r`n")
                    }
                    else {
                        $textBox1.AppendText("Failed to update old bot folder name.`r`n")
                    }
                }
                   
                # Add Registry Keys for Both Exe's to Run as Admin
                if ($checkBox2.Checked) {
                    $textBox1.AppendText("Starting exe update process for D2RB and Day.`r`n")
                    # Set variables to indicate value and key to set
                    $NewCombinedPath = Join-Path -Path $global:drarFileName -ChildPath "D2RB\D2RB.exe"
                    $global:NewD2RBEXELocation = Join-Path -Path $destinationPath -ChildPath $NewCombinedPath
                    $NewDayEXELocation = Join-Path -Path $newPath -ChildPath "day.exe"
                    $RegistryPath = 'HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers'
                    $Name1	=  $NewDayEXELocation
                    $Name2 = $global:NewD2RBEXELocation
                    $Value = '~ RUNASADMIN'

                    # Create the key if it does not exist
                    If (-NOT (Test-Path $RegistryPath)) {
                        New-Item -Path $RegistryPath -Force | Out-Null
                        }

                        # Now set the value
                        New-ItemProperty -Path $RegistryPath -Name $Name1 -Value $Value -PropertyType String -Force
                        New-ItemProperty -Path $RegistryPath -Name $Name2 -Value $Value -PropertyType String -Force
                        $textBox1.AppendText("Both exe's successfully updated to run as Administrator`r`n")
                    }

                # Update the old webhook by prompting user to submit it if checkbox is selected.
                if ($checkBox1.Checked) {
                    $textBox1.AppendText("Starting Webhook Update.`r`n")
    
                    # Set variables
                    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
                    $openFileDialog.Filter = "PS1 files (*.ps1)|*.ps1"
                    $openFileDialog.Title = "Select the Old Webhook Script"
                    $dialogResult = $openFileDialog.ShowDialog()

                    if ($dialogResult -eq [System.Windows.Forms.DialogResult]::OK) {
                        # Get the selected file path
                        $oldScriptPath = $openFileDialog.FileName

                        $global:NewD2RBEXELocation = "$global:drarFileName\D2RB"

                        # Update the old webhook script
                        try {
                            $oldScriptContent = Get-Content $oldScriptPath
                            $oldScriptContent = $oldScriptContent -replace '(?ms)^(Monitor-Folder\s+-path\s+")[^"]*(")', "`$1$global:destinationPath\$global:drarFileName\D2RB`$2"
                            Set-Content $oldScriptPath $oldScriptContent
                            $textBox1.AppendText("Webhook Updated Successfully`r`n")
                        }
                        catch {
                            $textBox1.AppendText("Failed to update webhook.`r`n")
                            $textBox1.AppendText($_.Exception.Message)
                        }
                    }
}
        }
}


function Extract-RarFile {
    param (
        [string]$RarFilePath,
        [string]$DestinationPath,
        [System.Windows.Forms.TextBox]$TextBox
    )

    if (-not (Test-Path -Path $DestinationPath)) {
        New-Item -ItemType Directory -Path $DestinationPath | Out-Null
    }

    $TextBox.AppendText("Extracting RAR file...`r`n")
    & "C:\Program Files\7-Zip\7z.exe" x "$RarFilePath" "-o`"$DestinationPath`""

    if (Test-Path -Path "$DestinationPath\$($rarFileName)") {
        $TextBox.AppendText("RAR file extracted to $DestinationPath`r`n")
    }
    else {
        $TextBox.AppendText("Failed to extract RAR file to $DestinationPath`r`n")
    }
}


[void][System.Reflection.Assembly]::Load('System.Drawing, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
[void][System.Reflection.Assembly]::Load('System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
$MainForm = New-Object -TypeName System.Windows.Forms.Form
[System.Windows.Forms.Label]$label1 = $null
[System.Windows.Forms.Button]$button1 = $null
[System.Windows.Forms.Button]$button2 = $null
[System.Windows.Forms.Button]$button3 = $null
[System.Windows.Forms.Label]$label4 = $null
[System.Windows.Forms.CheckBox]$checkBox1 = $null
[System.Windows.Forms.CheckBox]$checkBox2 = $null
[System.Windows.Forms.CheckBox]$checkBox3 = $null
[System.Windows.Forms.Label]$label5 = $null
[System.Windows.Forms.CheckBox]$checkBox4 = $null
[System.Windows.Forms.CheckBox]$checkBox5 = $null
[System.Windows.Forms.CheckBox]$checkBox6 = $null
[System.Windows.Forms.CheckBox]$checkBox7 = $null
[System.Windows.Forms.TextBox]$textBox2 = $null
[System.Windows.Forms.TextBox]$textBox3 = $null
[System.Windows.Forms.TextBox]$textBox4 = $null
[System.Windows.Forms.Label]$label2 = $null
[System.Windows.Forms.TextBox]$textBox1 = $null
function InitializeComponent
{
$label1 = (New-Object -TypeName System.Windows.Forms.Label)
$button1 = (New-Object -TypeName System.Windows.Forms.Button)
$button2 = (New-Object -TypeName System.Windows.Forms.Button)
$button3 = (New-Object -TypeName System.Windows.Forms.Button)
$label4 = (New-Object -TypeName System.Windows.Forms.Label)
$checkBox1 = (New-Object -TypeName System.Windows.Forms.CheckBox)
$checkBox2 = (New-Object -TypeName System.Windows.Forms.CheckBox)
$checkBox3 = (New-Object -TypeName System.Windows.Forms.CheckBox)
$label5 = (New-Object -TypeName System.Windows.Forms.Label)
$textBox1 = (New-Object -TypeName System.Windows.Forms.TextBox)
$checkBox4 = (New-Object -TypeName System.Windows.Forms.CheckBox)
$checkBox5 = (New-Object -TypeName System.Windows.Forms.CheckBox)
$checkBox6 = (New-Object -TypeName System.Windows.Forms.CheckBox)
$checkBox7 = (New-Object -TypeName System.Windows.Forms.CheckBox)
$textBox2 = (New-Object -TypeName System.Windows.Forms.TextBox)
$textBox3 = (New-Object -TypeName System.Windows.Forms.TextBox)
$textBox4 = (New-Object -TypeName System.Windows.Forms.TextBox)
$label2 = (New-Object -TypeName System.Windows.Forms.Label)
$MainForm.SuspendLayout()
#
#label1
#
$label1.AutoSize = $true
$label1.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]37,[System.Int32]26))
$label1.Name = [System.String]'label1'
$label1.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]296,[System.Int32]13))
$label1.TabIndex = [System.Int32]0
$label1.Text = [System.String]'Please choose each of the following in order, then hit update:'
#
#button1
#
$button1.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]55,[System.Int32]68))
$button1.Name = [System.String]'button1'
$button1.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]135,[System.Int32]42))
$button1.TabIndex = [System.Int32]1
$button1.Text = [System.String]'Select Destination'
$button1.UseVisualStyleBackColor = $true
$button1.add_Click($button1_Click)
#
#button2
#
$button2.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]55,[System.Int32]148))
$button2.Name = [System.String]'button2'
$button2.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]135,[System.Int32]42))
$button2.TabIndex = [System.Int32]3
$button2.Text = [System.String]'Select Old Location'
$button2.UseVisualStyleBackColor = $true
$button2.add_Click($button2_Click)
#
#button3
#
$button3.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]198,[System.Int32]449))
$button3.Name = [System.String]'button3'
$button3.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]135,[System.Int32]42))
$button3.TabIndex = [System.Int32]4
$button3.Text = [System.String]'Update!'
$button3.UseVisualStyleBackColor = $true
$button3.add_Click($button3_Click)
#
#label4
#
$label4.AutoSize = $true
$label4.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]37,[System.Int32]259))
$label4.Name = [System.String]'label4'
$label4.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]157,[System.Int32]13))
$label4.TabIndex = [System.Int32]6
$label4.Text = [System.String]'Optional Tasks Avalable Below:'
#
#checkBox1
#
$checkBox1.AutoSize = $true
$checkBox1.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]40,[System.Int32]289))
$checkBox1.Name = [System.String]'checkBox1'
$checkBox1.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]111,[System.Int32]17))
$checkBox1.TabIndex = [System.Int32]7
$checkBox1.Text = [System.String]'Update Webhook'
$checkBox1.UseVisualStyleBackColor = $true
$checkBox1.add_CheckedChanged($checkBox1_CheckedChanged)
#
#checkBox2
#
$checkBox2.AutoSize = $true
$checkBox2.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]325,[System.Int32]289))
$checkBox2.Name = [System.String]'checkBox2'
$checkBox2.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]194,[System.Int32]17))
$checkBox2.TabIndex = [System.Int32]8
$checkBox2.Text = [System.String]'Update exe''s to run as administrator'
$checkBox2.UseVisualStyleBackColor = $true
$checkBox2.add_CheckedChanged($checkBox2_CheckedChanged)
#
#checkBox3
#
$checkBox3.AutoSize = $true
$checkBox3.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]76,[System.Int32]329))
$checkBox3.Name = [System.String]'checkBox3'
$checkBox3.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]389,[System.Int32]17))
$checkBox3.TabIndex = [System.Int32]9
$checkBox3.Text = [System.String]'Auto Download Update (If not seclected you will be prompted to provide one)'
$checkBox3.UseVisualStyleBackColor = $true
$checkBox3.add_CheckStateChanged($checkBox3_CheckStateChanged)
#
#label5
#
$label5.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]55,[System.Int32]524))
$label5.Name = [System.String]'label5'
$label5.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]417,[System.Int32]36))
$label5.TabIndex = [System.Int32]10
$label5.Text = [System.String]'Clicking update only works if the Destination and Old Location options display the correct paths.  Update will start the process based on your additional selected options.
'
#
#textBox1
#
$textBox1.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]40,[System.Int32]563))
$textBox1.Multiline = $true
$textBox1.Name = [System.String]'textBox1'
$textBox1.ReadOnly = $true
$textBox1.ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical
$textBox1.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]467,[System.Int32]175))
$textBox1.TabIndex = [System.Int32]11
#
#checkBox4
#
$checkBox4.AutoSize = $true
$checkBox4.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]157,[System.Int32]289))
$checkBox4.Name = [System.String]'checkBox4'
$checkBox4.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]162,[System.Int32]17))
$checkBox4.TabIndex = [System.Int32]12
$checkBox4.Text = [System.String]'Rename old D2RB bot folder'
$checkBox4.UseVisualStyleBackColor = $true
$checkBox4.add_CheckedChanged($checkBox4_CheckedChanged)
#
#checkBox5
#
$checkBox5.AutoSize = $true
$checkBox5.Checked = $true
$checkBox5.CheckState = [System.Windows.Forms.CheckState]::Checked
$checkBox5.Enabled = $false
$checkBox5.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]55,[System.Int32]221))
$checkBox5.Name = [System.String]'checkBox5'
$checkBox5.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]126,[System.Int32]17))
$checkBox5.TabIndex = [System.Int32]13
$checkBox5.Text = [System.String]'Transfer settings.json'
$checkBox5.UseVisualStyleBackColor = $true
#
#checkBox6
#
$checkBox6.AutoSize = $true
$checkBox6.Checked = $true
$checkBox6.CheckState = [System.Windows.Forms.CheckState]::Checked
$checkBox6.Enabled = $false
$checkBox6.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]197,[System.Int32]221))
$checkBox6.Name = [System.String]'checkBox6'
$checkBox6.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]105,[System.Int32]17))
$checkBox6.TabIndex = [System.Int32]14
$checkBox6.Text = [System.String]'Update Bot Path'
$checkBox6.UseVisualStyleBackColor = $true
#
#checkBox7
#
$checkBox7.AutoSize = $true
$checkBox7.Checked = $true
$checkBox7.CheckState = [System.Windows.Forms.CheckState]::Checked
$checkBox7.Enabled = $false
$checkBox7.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]317,[System.Int32]221))
$checkBox7.Name = [System.String]'checkBox7'
$checkBox7.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]155,[System.Int32]17))
$checkBox7.TabIndex = [System.Int32]15
$checkBox7.Text = [System.String]'Transfer Character Settings'
$checkBox7.UseVisualStyleBackColor = $true
#
#textBox2
#
$textBox2.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]204,[System.Int32]68))
$textBox2.Multiline = $true
$textBox2.Name = [System.String]'textBox2'
$textBox2.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]303,[System.Int32]42))
$textBox2.TabIndex = [System.Int32]16
#
#textBox3
#
$textBox3.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]204,[System.Int32]148))
$textBox3.Multiline = $true
$textBox3.Name = [System.String]'textBox3'
$textBox3.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]303,[System.Int32]42))
$textBox3.TabIndex = [System.Int32]17
#
#textBox4
#
$textBox4.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]157,[System.Int32]361))
$textBox4.Multiline = $true
$textBox4.Name = [System.String]'textBox4'
$textBox4.ReadOnly = $true
$textBox4.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]208,[System.Int32]19))
$textBox4.TabIndex = [System.Int32]18
#
#label2
#
$label2.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]75,[System.Int32]392))
$label2.Name = [System.String]'label2'
$label2.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]397,[System.Int32]44))
$label2.TabIndex = [System.Int32]19
$label2.Text = [System.String]'The auto download option only works if I have updated the link.  Please validate the version shown in the box above matches the latest one in discord.  Do not run check the box if it is not.'
$label2.TextAlign = [System.Drawing.ContentAlignment]::TopCenter
$label2.add_Click($label2_Click)
#
#MainForm
#
$MainForm.ClientSize = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]545,[System.Int32]761))
$MainForm.Controls.Add($label2)
$MainForm.Controls.Add($textBox4)
$MainForm.Controls.Add($textBox3)
$MainForm.Controls.Add($textBox2)
$MainForm.Controls.Add($checkBox7)
$MainForm.Controls.Add($checkBox6)
$MainForm.Controls.Add($checkBox5)
$MainForm.Controls.Add($checkBox4)
$MainForm.Controls.Add($textBox1)
$MainForm.Controls.Add($label5)
$MainForm.Controls.Add($checkBox3)
$MainForm.Controls.Add($checkBox2)
$MainForm.Controls.Add($checkBox1)
$MainForm.Controls.Add($label4)
$MainForm.Controls.Add($button3)
$MainForm.Controls.Add($button2)
$MainForm.Controls.Add($button1)
$MainForm.Controls.Add($label1)
$MainForm.Name = [System.String]'MainForm'
$MainForm.Text = [System.String]'D2RB Updater Written By Thrack v1.24'
$MainForm.ResumeLayout($false)
$MainForm.PerformLayout()
Add-Member -InputObject $MainForm -Name label1 -Value $label1 -MemberType NoteProperty
Add-Member -InputObject $MainForm -Name button1 -Value $button1 -MemberType NoteProperty
Add-Member -InputObject $MainForm -Name button2 -Value $button2 -MemberType NoteProperty
Add-Member -InputObject $MainForm -Name button3 -Value $button3 -MemberType NoteProperty
Add-Member -InputObject $MainForm -Name label4 -Value $label4 -MemberType NoteProperty
Add-Member -InputObject $MainForm -Name checkBox1 -Value $checkBox1 -MemberType NoteProperty
Add-Member -InputObject $MainForm -Name checkBox2 -Value $checkBox2 -MemberType NoteProperty
Add-Member -InputObject $MainForm -Name checkBox3 -Value $checkBox3 -MemberType NoteProperty
Add-Member -InputObject $MainForm -Name label5 -Value $label5 -MemberType NoteProperty
Add-Member -InputObject $MainForm -Name checkBox4 -Value $checkBox4 -MemberType NoteProperty
Add-Member -InputObject $MainForm -Name checkBox5 -Value $checkBox5 -MemberType NoteProperty
Add-Member -InputObject $MainForm -Name checkBox6 -Value $checkBox6 -MemberType NoteProperty
Add-Member -InputObject $MainForm -Name checkBox7 -Value $checkBox7 -MemberType NoteProperty
Add-Member -InputObject $MainForm -Name textBox2 -Value $textBox2 -MemberType NoteProperty
Add-Member -InputObject $MainForm -Name textBox3 -Value $textBox3 -MemberType NoteProperty
Add-Member -InputObject $MainForm -Name textBox4 -Value $textBox4 -MemberType NoteProperty
Add-Member -InputObject $MainForm -Name label2 -Value $label2 -MemberType NoteProperty
Add-Member -InputObject $MainForm -Name textBox1 -Value $textBox1 -MemberType NoteProperty
}
. InitializeComponent


$MainForm.ShowDialog() | Out-Null
