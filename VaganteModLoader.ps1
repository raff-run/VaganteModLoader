Import-Module -Name .\Anybox\Anybox.psm1

$ModLoaderTempFolderPath = ".\ModLoaderTempFolder"
$ModsFolder = ".\Mods"
$ExtractorPath = ".\vagante-extract.exe"
$VraPath = ".\data.vra"
$BackupVraPath = ".\dataBackup.vra"
$UpdateDetectionDataPath = ".\updateDetectionData.doNotDelete.txt"

$UpdateDetectionModdedHashPrepend = "ModdedVraHash: "

#This creates a popup box, and asks the user to choose which mod will prevail when two mods try to change the same file.
function Resolve-ModConflict {
    param([string]$DuplicateFile, [string]$FirstMod, [string]$SecondMod)
    $Anybox = New-Object Anybox.Anybox

    $Anybox.Icon = 'Question'
    $Anybox.Title = "Mod conflict detected"
    $Anybox.Message = "Two mods are trying to change the same file (" + $FileRelativePath + ").`r`n Choose which one you want to stay:"
    $Anybox.FontSize = 14
    $Anybox.ContentAlignment = 'Center'
    $Anybox.Buttons = @(
      New-AnyboxButton -Name "UseFirstMod" -Text ("Use " + $FirstMod  + "'s version")
      New-AnyboxButton -Name "UseSecondMod" -Text ("Use " + $SecondMod + "'s version")
      New-AnyboxButton -Name "Cancel" -Text 'Cancel mod loading' -IsDefault
    )
    $Anybox.DefaultButton = 'Yes'
    $Anybox.CancelButton = 'No'
    $Anybox.ButtonRows = 2
    $Anybox.Topmost = $true

    $Response = $Anybox | Show-Anybox
    if ($Response['UseFirstMod'] -eq $true) {
        return $FirstMod
    } 
    elseif ($Response['UseSecondMod'] -eq $true) {
        return $SecondMod
    } 
    elseif ($Response['Cancel'] -eq $true) {
        return "Cancel"
    }
}

function Write-UpdateDetectionFile {
    param([string]$ModdedVraHash)
    $Output = "#Please don't change anything in this file - that could mess up update detection and leave you with unwanted mods and/or an unupdated data.vra# `r`n"
    $Output = $Output + $UpdateDetectionModdedHashPrepend + $ModdedVraHash + "`r`n"
    $Output | Out-File -FilePath $UpdateDetectionDataPath
}

#Checks if the data.vra is different from both the backup and the latest modded data.vra
#If that's true, it means one of two things:
#The data.vra was updated by the user, but not using the modloader (unlikely)
#The data.vra was updated by steam (more likely)
function CheckForUpdates {
    $BackupVraHash = (Get-FileHash $BackupVraPath -Algorithm MD5).Hash
    $VraHash = (Get-FileHash $VraPath -Algorithm MD5).Hash
    $ModdedVraHash = ""
    foreach($Line in Get-Content $UpdateDetectionDataPath)
    {
       if($Line.Contains($UpdateDetectionModdedHashPrepend)){
            $ModdedVraHash = $Line.Substring($UpdateDetectionModdedHashPrepend.Length)
       }
    }

    return ($VraHash -ne $ModdedVraHash -and $VraHash -ne $BackupVraHash)
}

#Main function
function LoadMods {
    if(Test-Path $ModLoaderTempFolderPath){ #If temporary folder exists, delete it
        Remove-Item $ModLoaderTempFolderPath -Recurse
    }
    
    if(!(Test-Path $ModsFolder)){ #If Mods folder doesn't exist yet, create it and exit
        New-item $ModsFolder -itemtype directory
        exit
    }
    
    $Mods = Get-ChildItem -Directory $ModsFolder
    
    $FilesMarkedForModding = @{}
    
    #Loop through all folders inside Mods/
    foreach($RootFolder in $Mods){
        "Mod found: " + $RootFolder.Name
        $ModdedFiles = Get-ChildItem -File -Recurse $RootFolder.FullName;   
        foreach($File in $ModdedFiles){
                if($File.Name -ne "ignoreme.ignore" -and $File.Name -ne "readme.txt"){
                    "Found modded file in " + $ModdedFolder.Name + ": " + $File.Name
                    #This was the only way I found to get a relative path from a path that is not the current path
                    $FileRelativePath = $File.FullName.Replace($RootFolder.FullName + "\", "")
                    $conflictResolution = ""
                    
                    #If the file is already in the list of modded files, resolve the conflict
                    if($FilesMarkedForModding.ContainsKey($FileRelativePath)){
                        "Two mods are trying to change the same file: " + $FileRelativePath
                        $conflictResolution = Resolve-ModConflict -DuplicateFile $FileRelativePath -FirstMod $FilesMarkedForModding.Item($FileRelativePath) -SecondMod $RootFolder.Name
                        if($conflictResolution -eq "Cancel"){
                            exit
                        } else {
                            $FilesMarkedForModding.Item($FileRelativePath) = $conflictResolution
                        }
                    }
                    else { #Else, add the file to the list, along with the name of the mod that will change it
                        $FilesMarkedForModding.Add($FileRelativePath, $RootFolder.Name)
                    }
                }
            }
    }
    
    "`r`nHere are what files were changed (Name column) by which mods (Value column)"
    $FilesMarkedForModding
    
    if($FilesMarkedForModding.Count -eq 0){
        "No mods found!"
        [System.Windows.MessageBox]::Show("No mod folders were found inside Mods. Are you sure you installed the mods correctly? `r`nFor example, if your mod only changes rooms.json, the directory tree needs to look kinda like this:`r`nMods\`r`n--->RandomModName`r`n------>rooms.json",'No mods found','OK','Info') | Out-Null
        exit
    }
    
    "Unpacking data.vra..."
    $BackupExists = Test-Path $BackupVraPath
    $GameWasUpdated = $false
    
    if(!$BackupExists){
        Copy-Item $VraPath $BackupVraPath
        $GameWasUpdated = $true
    }
    
    #If the backup exists and there's a update detection file, check for updates
    if($BackupExists -and (Test-Path $UpdateDetectionDataPath)){
        $GameWasUpdated = CheckForUpdates
    }
    
    #If the game was updated, we need to update the backup
    if($GameWasUpdated){
        "The game apparently was updated. Updating data.vra backup."
        Copy-Item $VraPath $BackupVraPath
    }

    #This just didn't work for some reason, so I put out-null instead
    #If anyone knows how to properly redirect the output of Vagante-Extract to a file, that'd help with eventual troubleshooting
    & $extractorPath extract $BackupVraPath $ModLoaderTempFolderPath | Out-Null #| Out-File -FilePath $VaganteExtractLogPath 
    "data.vra unpacked. Placing modded files..."
    
    foreach($File in $FilesMarkedForModding.GetEnumerator()){
        $Destination = Join-Path $ModLoaderTempFolderPath $File.Name
        $Source = Join-Path $ModsFolder $File.Value
        $Source = Join-Path $Source $File.Name
        #if the file exists in Mods/RandomMod but doesn't exist inside the original data.vra, something is wrong
        if(!(Test-Path $Destination)) {
            "Invalid mod file detected."
            [System.Windows.MessageBox]::Show("The mod " + $File.Value + "tried to replace a file that doesn't exist on the game: " + $File.Name + ".`r`nThis file will be ignored and won't be inserted into data.vra.`r`nPlease inform the mod maker about this.",'Invalid File Replacement','OK','Info') | Out-Null
        }
        else {
            Copy-Item -Path $Source -Destination $Destination
        }
    }
    
    "Repacking data.vra with the modded files..."
    & $ExtractorPath archive $ModLoaderTempFolderPath $VraPath | Out-Null #| Add-Content -Path $VaganteExtractLogPath #This just didn't work for some reason, so I put out-null instead
    
    #Now we update the update detection file with the latest modded content
    $ModdedVraHash = (Get-FileHash $VraPath -Algorithm MD5).Hash
    Write-UpdateDetectionFile -ModdedVraHash $ModdedVraHash
    
    Remove-Item $ModLoaderTempFolderPath -Recurse
    
    "Done!"    
}

LoadMods
