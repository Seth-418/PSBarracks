Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$main_form = New-Object System.Windows.Forms.Form

$configFilePath = "C:\PSBarracks\config.json"

$icon = New-Object System.Drawing.Icon("C:\PSBarracks\psbarracks.ico")

$configContent = Get-Content -path $configFilePath -Raw  | ConvertFrom-Json

$folderLocation = $configContent.folderLocation

Write-Output $folderLocation

$scripts = @(Get-ChildItem -path $folderLocation -Recurse -filter *.ps1 | select-object -expandproperty Name)

$main_form.Text ='PSBarracks'
$main_form.Width = 400
$main_form.Height = 525
$main_form.FormBorderStyle='FixedDialog'
$main_form.MaximizeBox=$false

$scriptView = New-Object System.Windows.Forms.ListBox
$scriptview.width = 350
$scriptView.height = 275
$scriptView.Location = "15,15"
$scriptView.Add_Click({listClick})

foreach ($script in $scripts){
    $scriptview.items.add($script)
}



$main_form.Controls.Add($scriptView)

$descPanel = New-Object System.Windows.Forms.GroupBox
$descPanel.width = 350
$descPanel.Height = 125
$descPanel.Location = "15,285"
$descPanel.text = "Description"
$main_form.Controls.Add($descPanel)
$main_form.Icon = $icon

$runButton = New-Object System.Windows.Forms.Button
$RunButton.text = "Run"
$runButton.width = 80
$runButton.Height = 40
$runbutton.Add_Click({Run})
$runButton.Location = "15,425"
$runButton.Enabled =$false



$scriptDescriptionLabel = New-Object System.Windows.Forms.Label
$scriptDescriptionLabel.width = 325
$scriptDescriptionLabel.Height = 90
$scriptDescriptionLabel.location = "10,30"

$settingsButton = New-Object System.Windows.Forms.Button
$settingsButton.text = "Settings"
$settingsButton.width = 80
$settingsButton.Height = 40
$settingsButton.Add_Click({settingsMenu})
$settingsButton.Location = "105,425"


$editDescriptionButton = New-Object System.Windows.Forms.Button
$editDescriptionButton.text = "Edit Description"
$editDescriptionButton.width = 80
$editDescriptionButton.height = 40
$editDescriptionButton.Add_Click({editDescription})
$editDescriptionButton.Location = "195, 425"
$editDescriptionButton.Enabled = $false

$aboutButton = New-Object System.Windows.Forms.Button
$aboutButton.text = "About"
$aboutButton.Width = 80
$aboutButton.Height = 40
$aboutButton.Add_Click({about})
$aboutButton.Location = "285,425"



$main_form.Controls.Add($aboutButton)
$main_form.Controls.add($settingsButton)
$main_form.Controls.add($EditDescriptionButton)
$main_form.Controls.Add($runButton)

function run(){
$selectedScriptPath = $scripts[$scriptview.SelectedIndex]
  Write-Host $selectedScriptPath
   
    if ($configContent.confirmation -eq $true){

        $confirmationForm = New-Object System.Windows.Forms.Form
        $confirmationForm.text = "Confirmation"
        $confirmationForm.Width = 350
        $confirmationForm.Height = 200
        $confirmationForm.FormBorderStyle='FixedDialog'
        $confirmationForm.MaximizeBox=$false

        $confirmLabel = New-Object System.Windows.Forms.Label
        $confirmLabel.Text = ("Run " + $selectedScriptPath + " ?")
        $confirmLabel.Location = "91, 32"
        $confirmLabel.Autosize = $true
        $confirmLabel.Font = [system.drawing.font]'$confirmLabel.Font.Name$confirmLabel.Font.Size, style=Bold'

        $confirmButton = New-Object System.Windows.Forms.Button
        $confirmButton.Text = "Yes"
        $confirmButton.Location = "40,80"
        $confirmButton.width = 80
        $confirmbutton.Height = 40
        $confirmButton.Add_Click({startRun})

        $runCancelButton = New-Object System.Windows.Forms.Button
        $runCancelButton.Text = "cancel"
        $runCancelButton.Location = "175,80"
        $runCancelButton.width = 80
        $runCancelButton.Height = 40
        $runCancelButton.Add_Click({runCancel})

        $confirmationForm.Controls.Add($confirmButton)

        $confirmationForm.Controls.Add($confirmLabel)

        $confirmationForm.Controls.Add($runCancelButton)
        
            if($configContent.confirmSound -eq $true){
                [System.Media.SystemSounds]::Exclamation.Play()
            }

        $confirmationForm.ShowDialog()
    }
    if ($configContent.confirmation -eq $false){
        startRun
    }

    }

Function startRun(){

if($configContent.runas -eq $true){
    runAs
}

Else{
$runPath = $configContent.FolderLocation + "\" + $selectedscriptPath
Start-Process powershell.exe -ArgumentList "-NoProfile -File `"$runPath`""

try {
    $confirmationForm.Close()
}
catch {
#NOTHING
}
}
}

function runAs(){

    $runPath = $configContent.FolderLocation + "\" + $selectedscriptPath
    $credentials = Get-Credential -Message "Please enter user credentials for script execution."
    if ($credentials -eq $null -or $credentials -eq ""){
    runCancel
    }
    Else{
    Start-Process powershell.exe -Credential $credentials -ArgumentList "-NoProfile -File `"$runPath`""
    $Credentials = $null
    try {
        $confirmationForm.Close()
    }
    catch {
    #NOTHING
    }
}
}


function runCancel(){
    try {
        $confirmationForm.Close()
    }
    catch {
    #NOTHING
    }
}

function editDescription(){
    $selectedScriptPath = $scripts[$scriptview.SelectedIndex]

    $editDescriptionForm = New-Object System.Windows.Forms.Form
    $editDescriptionForm.Text = "Edit Description"
    $editDescriptionForm.Width = 400
    $editDescriptionForm.Height = 250
    $editDescriptionForm.FormBorderStyle='FixedDialog'
    $editDescriptionForm.MaximizeBox=$false


    $editDescriptionLabel = New-Object System.Windows.Forms.Label
    $editDescriptionLabel.Text =   $selectedScriptPath + " - Edit Description"
    $editDescriptionLabel.Width = 390
    $editDescriptionLabel.Height = 30
    $editDescriptionLabel.Location = "5,5"
    #$editDescriptionLabel.Font = [system.drawing.font]'$editDescriptionLabel.Font.Name$editDescriptionLabel.Font.Size, style=Bold'


    $editDescriptionTextBox = new-Object System.Windows.Forms.TextBox
    $editDescriptionTextBox.Multiline = $true;
    $editDescriptionTextBox.Size = New-Object System.Drawing.Size (375, 125)
    $editDescriptionTextBox.location = New-object System.Drawing.Size(5, 35)

    $saveDescriptionButton = New-object System.Windows.Forms.Button
    $saveDescriptionButton.Add_Click({saveDescription})
    $saveDescriptionButton.Text = "Save"
    $saveDescriptionButton.width = 80
    $saveDescriptionButton.Height = 40
    $saveDescriptionButton.Location = "5, 165"

    $cancelDescriptionButton = New-object System.Windows.Forms.Button
    $cancelDescriptionButton.Add_Click({descriptionCancel})
    $cancelDescriptionButton.Text = "Cancel"
    $cancelDescriptionButton.width = 80
    $cancelDescriptionButton.Height = 40
    $cancelDescriptionButton.Location = "95, 165"
    


    Try{$scriptName=$selectedScriptPath.substring(0,$selectedScriptPath.IndexOf('.'))}
    Catch{Return}
   
        If(Test-Path -Path ($folderLocation + "\Descriptions\" + $scriptName + ".txt"))
        {

        $editDescriptionTextBox.text= Get-Content -Path ($folderLocation + "\Descriptions\" + $scriptName + ".txt")
        }
        Else
        {
        $editDescriptionTextBox.text = 'No description file found for " ' + $scriptName + '"'
        }


    $editDescriptionForm.Controls.Add($editDescriptionTextBox)
    $editDescriptionForm.Controls.Add($editDescriptionLabel)
    $editDescriptionForm.Controls.Add($saveDescriptionButton)
    $editDescriptionForm.Controls.Add($cancelDescriptionButton)
    $editDescriptionForm.ShowDialog()

}


function descriptionCancel(){

    $editDescriptionForm.Close()

}

function saveDescription(){
Write-Host "Saving. ."

If(Test-Path -Path ($folderLocation + "\Descriptions\" + $scriptName + ".txt"))
        {

        Set-Content -path ($folderLocation + "\Descriptions\" + $scriptName + ".txt") -value $editDescriptionTextBox.Text
        
Write-Host "Description Saved"

Try{$scriptName=$selectedScriptPath.substring(0,$selectedScriptPath.IndexOf('.'))}
Catch{Return}

    If(Test-Path -Path ($folderLocation + "\Descriptions\" + $scriptName + ".txt"))
    {

    $scriptDescriptionLabel.text= Get-Content -Path ($folderLocation + "\Descriptions\" + $scriptName + ".txt")

    }
    Else
    {
    $scriptDescriptionLabel.text = 'No description file found for " ' + $scriptName + '"'
    }

$descPanel.Controls.Add($scriptDescriptionLabel)

$editDescriptionForm.Close()
        }
Else{
New-Item -Path ($folderLocation + "\Descriptions\" + $scriptName + ".txt") -itemType File -value $editDescriptionTextBox.Text
Write-Host "New .txt file created for " + $scriptName
$editDescriptionForm.Close()
}
}


function settingsMenu(){
    $settings_form = New-Object System.Windows.Forms.Form
    $settings_form.Text ='Settings'
    $settings_form.Width = 400
    $settings_form.Height = 250
    $settings_form.FormBorderStyle='FixedDialog'
    $settings_form.MaximizeBox=$false

    $folderSettingsGroupBox = New-Object System.Windows.Forms.GroupBox
    $folderSettingsGroupBox.Text = "Location Settings"
    $folderSettingsGroupBox.Width = 375
    $folderSettingsGroupBox.Height = 105
    $folderSettingsGroupBox.Location = "5,5"

    $folderSettingsGroupBox = New-Object System.Windows.Forms.GroupBox
    $folderSettingsGroupBox.Text = "Location Settings"
    $folderSettingsGroupBox.Width = 375
    $folderSettingsGroupBox.Height = 105
    $folderSettingsGroupBox.Location = "5,5"

    $toggleSettingsGroupBox = New-Object System.Windows.Forms.GroupBox
    $toggleSettingsGroupBox.Text = "Script Run Settings"
    $toggleSettingsGroupBox.width = 375
    $toggleSettingsGroupBox.Height = 90
    $toggleSettingsGroupBox.Location = "5,115"

    $confirmRunCheckBox = New-Object System.Windows.Forms.CheckBox
    $confirmRunCheckBox.Text = "Enable Confirmation Message"
    $confirmRunCheckBox.AutoSize = $true
    $confirmRunCheckBox.Location = "5,20"
    $confirmRunCheckBox.Add_Click({confirmToggle})
    $confirmRunCheckBox.Checked = $configContent.confirmation

    $soundCheckBox = New-Object System.Windows.Forms.CheckBox
    $soundCheckBox.Text = "Enable Confirmation Sound"
    $soundCheckBox.AutoSize = $true
    $soundCheckBox.Location = "35,40"
    $soundCheckBox.Add_Click({soundToggle})
    $soundCheckBox.Checked = $configContent.confirmSound
    $soundCheckBox.Enabled = $configContent.confirmation

    $runAsCheckBox = New-Object System.Windows.Forms.CheckBox
    $runAsCheckBox.Text = "Run As Another User"
    $runAsCheckBox.AutoSize = $true
    $runAsCheckBox.Location = "5,60"
    $runAsCheckBox.Add_Click({runAsToggle})
    $runAsCheckBox.Checked = $configContent.runas


    $scriptsFolderLabel = New-Object System.Windows.Forms.Label
    $scriptsFolderLabel.Text = "Script Folder:   " + $folderLocation
    $scriptsFolderLabel.Location = "15,30"
    $scriptsFolderLabel.width =325
    $scriptsFolderLabel.Height = 50

    $changeScriptFolderButton = New-Object System.Windows.Forms.Button
    $changeScriptFolderButton.text = "Browse"
    $changeScriptFolderButton.width = 80
    $changeScriptFolderButton.height = 20
    $changeScriptFolderButton.Location = "10,75"
    $changeScriptFolderButton.Add_Click({browseScriptFolder})

    $folderSettingsGroupBox.Controls.Add($changeScriptFolderButton)
    $folderSettingsGroupBox.Controls.Add($scriptsFolderLabel)

    $toggleSettingsGroupBox.Controls.Add($confirmRunCheckBox)
    $toggleSettingsGroupBox.Controls.Add($runAsCheckBox)
    $toggleSettingsGroupBox.Controls.Add($soundCheckBox)

    $settings_form.Controls.Add($toggleSettingsGroupBox)
    $settings_form.Controls.Add($folderSettingsGroupBox)
    $Settings_form.ShowDialog()
}

function runAsToggle(){
    $newRunAsContent = $runAsCheckbox.Checked
    $configContent.runas = $newRunAsContent
    $newRunAsContent = $configContent | ConvertTo-Json -Depth 2
    Set-Content -Path $configFilePath -Value $newRunAsContent
}


function confirmToggle(){
    $newConfirmationContent = $ConfirmRunCheckbox.Checked
    $soundCheckBox.Enabled = $newConfirmationContent
    $configContent.confirmation = $newConfirmationContent
    $newConfirmationContent = $configContent | ConvertTo-Json -Depth 3
    Set-Content -Path $configFilePath -Value $newConfirmationContent
}

function soundToggle(){
    $newSoundContent = $soundCheckbox.Checked
    $configContent.confirmSound = $newSoundContent
    $newSoundContent = $configContent | ConvertTo-Json -Depth 4
    Set-Content -Path $configFilePath -Value $newSoundContent
}

function listClick(){
    $scriptDescriptionLabel.Text = $null
    $selectedScriptPath = $scripts[$scriptview.SelectedIndex]
    $descPanel.text = "Description - " + $selectedScriptPath

    #gets just the script name; removes the .ps1 extension
    #if user clicks empty spot or box when no scripts are populated, a null valued expression error occurs. This try/Catch prevents that
    
    Try{$scriptName=$selectedScriptPath.substring(0,$selectedScriptPath.LastIndexOf('.'))}
    Catch{Return}
   
        If(Test-Path -Path ($folderLocation + "\Descriptions\" + $scriptName + ".txt"))
        {

        $scriptDescriptionLabel.text= Get-Content -Path ($folderLocation + "\Descriptions\" + $scriptName + ".txt")

        }
        Else
        {
        $scriptDescriptionLabel.text = 'No description file found for " ' + $scriptName + '"'
        }

    $descPanel.Controls.Add($scriptDescriptionLabel)

    if($scriptview.SelectedIndex -ne $null){
###button for description editing
        $runButton.enabled = $true
        $editDescriptionButton.enabled = $true
    }
}

function browseScriptFolder(){

    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog

    if ($folderBrowser.ShowDialog() -eq "OK" -and $folderBrowser.SelectedPath -ne "" -and $folderBrowser.SelectedPath -ne $null)
    {
        $newConfigContent = $folderBrowser.SelectedPath
        $configContent.FolderLocation = $newConfigContent
        $newconfigContent = $configContent | ConvertTo-Json -Depth 1
        Set-Content -Path $configFilePath -Value $newconfigContent
        $scriptsFolderLabel.Text = "Script Folder:   " + $configContent.FolderLocation
        $folderLocation = $configContent.FolderLocation
        $scriptview.Items.Clear()
        $scripts = @(Get-ChildItem -path $folderLocation -Recurse -filter *.ps1 | select-object -expandproperty Name)
        foreach ($script in $scripts){
            $scriptview.items.add($script)
        }
        $main_form.Controls.Add($scriptView)
    }
    else 
    {
    Write-Host "Null/invalid path selected, or user cancelled."    
    }


}

function about(){
    $currentDirectory = Get-Location

    $Licensepath= Join-Path -Path $currentDirectory -ChildPath "\license"
    $readMePath= Join-Path -Path $currentDirectory -ChildPath "\readme.md"
    $logoPath = Join-Path -Path $currentDirectory -ChildPath "psbarrackslogo1.png"

    $aboutForm = New-Object System.Windows.Forms.Form
    $aboutForm.Text = "About"
    $aboutForm.width = 600
    $aboutForm.Height = 225
    $aboutForm.FormBorderStyle='FixedDialog'
    $aboutForm.MaximizeBox=$false

    $logoPictureBox = New-Object System.Windows.Forms.PictureBox
    $logoPictureBox.location = "20,0"
    $logoPictureBox.Size ="180,180"
    $logoPictureBox.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::Zoom
    $logoPictureBox.Image = [System.Drawing.Image]::FromFile($logoPath)

    $aboutGroupBox = New-Object System.Windows.Forms.GroupBox
    $aboutGroupBox.Text = "About"
    $aboutGroupBox.Width = 345
    $aboutGroupBox.Height = 145
    $aboutGroupBox.Location = "220,25"
    $aboutGroupBox.Font = [system.drawing.font]'$editDescriptionLabel.Font.Name$editDescriptionLabel.Font.Size, style=Bold'

    $aboutLabel = New-Object System.Windows.Forms.label
    $aboutLabel.Font = New-Object System.Drawing.Font("Segoe UI Empoji",8)
    $aboutLabel.Text = "PSBarracks is a simple GUI that provides an easy way to launch and organize your PS1 Scripts."
    $aboutlabel.AutoSize = $false
    $aboutLabel.size = "315, 40"
    $aboutLabel.Location = "15,30"

    $readMeButton = New-Object System.Windows.Forms.Button
    $readMeButton.Text ="View ReadMe"
    $readMeButton.size = "80,40"
    $readMeButton.Location = "15,80"
    $readMeButton.Add_Click({Start-Process $readMePath})

    $licenseButton = New-Object System.Windows.Forms.Button
    $licenseButton.Text ="View License"
    $licenseButton.size = "80,40"
    $licenseButton.Location = "100,80"
    $licenseButton.Add_Click({Start-Process $licensePath})

    $gitHubButton = New-Object System.Windows.Forms.Button
    $gitHubButton.Text ="View GitHub"
    $gitHubButton.size = "140,40"
    $gitHubButton.Location = "185,80"
    $gitHubButton.BackColor = [System.Drawing.Color]::White
    $gitHubButton.add_mouseEnter({$gitHubButton.BackColor = [System.Drawing.Color]::LightCyan})
    $gitHubButton.add_mouseLeave({$gitHubButton.BackColor = [System.Drawing.Color]::White})
    $gitHubButton.Add_Click({[System.Diagnostics.Process]::Start("https://github.com/Sansell775/PSBarracks")})

    $aboutGroupBox.Controls.Add($gitHubButton)
    $aboutGroupBox.Controls.Add($licenseButton)
    $aboutGroupBox.Controls.Add($aboutLabel)
    $aboutGroupBox.Controls.Add($readMeButton)
    
    $aboutForm.Controls.Add($aboutGroupBox)
    $aboutForm.Controls.Add($logoPictureBox)

    $aboutForm.ShowDialog()
    
    }

$main_form.ShowDialog()
