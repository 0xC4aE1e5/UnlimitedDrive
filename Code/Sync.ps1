$currentDrive = Split-Path -Path $PSScriptRoot -Qualifier
$currentDriveBackslash = [String]::Concat($currentDrive, "\")

$blockedFiles = @("Sync.ps1")

get-childitem $currentDrive -recurse | where { ! $_.PSIsContainer } | % {
    if ($blockedFiles.Contains($_.Name)) {
        return
    }
    if ($_.Name.EndsWith(".url")) {
        return
    }
    echo ([String]::Concat("Syncing ", $_.name, ".."))
    $out = curl.exe -s -F ([String]::Concat("file=@", $_.FullName)) https://api.anonfiles.com/upload | ConvertFrom-Json
    if ($out.status) {
        $url = $out.data.file.url.short
        Set-Content -Path ([String]::Concat($_.fullname, ".url")) -Value @"
[InternetShortcut]
IDList=
URL=$url
"@ 
        del $_.FullName -force
    } else {
        echo ([String]::Concat("Failed to sync ", $_.FullName, "!"))
    }
}

echo "Done."
cmd /c pause