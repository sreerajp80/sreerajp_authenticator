<#
.SYNOPSIS
    Builds the Android app (split APKs, one universal APK, or an App Bundle),
    names the files, and writes a SHA-256 checksum file for each one.

.DESCRIPTION
    Steps, in order:
      1. Read the version from pubspec.yaml (for 2.10.6+34: 2.10.6 and 34).
      2. Check the options. Refused combinations stop here, before Flutter runs.
      3. Delete any old Flutter-named output, so a stale file is never renamed
         as this build.
      4. Run flutter build with the chosen flavor, mode and flags.
      5. Rename each output to
         <Name>-[<abi>-]v<version>_<build>-<flavor>-<mode>.<apk|aab>.
      6. Delete the .sha1 files Flutter writes next to APKs (Flutter has no
         SHA-256 option, and it writes them after Gradle ends, so this has to
         happen here and not in Gradle).
      7. Write <file>.sha256 in the standard sha256sum format:
         "<lower-case hash>  <file name>" (UTF-8, no BOM).
      8. Print each file with its size and SHA-256, and the symbols folder.
      9. Stop the Gradle daemons.

    The script writes only inside build/. Signing is done by Gradle from
    android/key.properties; this script never reads that file or the keystore.
    It has no app name built in. Works in Windows PowerShell 5.1 and
    PowerShell 7. Full guide: docs/release_process.md section 9.

.PARAMETER Name
    Base name for the output files. Required. Letters, digits, . _ - only.

.PARAMETER Target
    apk = APKs (split per ABI unless -NoSplit). aab = App Bundle.

.PARAMETER Flavor
    prod (default) or dev.

.PARAMETER Mode
    release (default), profile or debug.

.PARAMETER NoSplit
    APK only: build one universal APK instead of one per ABI.

.PARAMETER NoObfuscate
    Leave out --obfuscate and --split-debug-info. Refused for prod release.

.PARAMETER SymbolsDir
    Where --split-debug-info writes symbols. Must be inside build/. Default:
    aab: build/symbols/android-<flavor>-<x.y.z+n>/
    apk: build/symbols/android-<flavor>-<x.y.z+n>-apk/
    (separate folders: APK and AAB are separate compiles, and each needs its
    own symbols to decode crash stack traces).

.EXAMPLE
    .\tool\build_release.ps1 -Name SreerajP_Authenticator -Target aab

.EXAMPLE
    .\tool\build_release.ps1 -Name SreerajP_Authenticator -Target apk

.EXAMPLE
    .\tool\build_release.ps1 -Name SreerajP_Authenticator -Target apk -Flavor dev -Mode debug
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[A-Za-z0-9._-]+$')]
    [string]$Name,

    [Parameter(Mandatory = $true)]
    [ValidateSet('apk', 'aab')]
    [string]$Target,

    [ValidateSet('prod', 'dev')]
    [string]$Flavor = 'prod',

    [ValidateSet('release', 'profile', 'debug')]
    [string]$Mode = 'release',

    [switch]$NoSplit,

    [switch]$NoObfuscate,

    [string]$SymbolsDir
)

$ErrorActionPreference = 'Stop'

# The production flavor: a release of it must be obfuscated.
$productionFlavor = 'prod'

function Stop-WithMessage([string]$Message) {
    Write-Host $Message -ForegroundColor Red
    exit 1
}

# SHA-256 with .NET, not Get-FileHash: Windows PowerShell 5.1 started from
# PowerShell 7 can pick up the wrong module path and not find Get-FileHash.
function Get-Sha256Hex([string]$Path) {
    $sha = [System.Security.Cryptography.SHA256]::Create()
    $stream = [System.IO.File]::OpenRead($Path)
    try {
        $bytes = $sha.ComputeHash($stream)
    } finally {
        $stream.Dispose()
        $sha.Dispose()
    }
    return (($bytes | ForEach-Object { $_.ToString('x2') }) -join '')
}

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$buildRoot = Join-Path $repoRoot 'build'

# --- 1. Version from pubspec.yaml -------------------------------------------
$versionLine = Select-String -Path (Join-Path $repoRoot 'pubspec.yaml') `
    -Pattern '^version:\s*(\d+\.\d+\.\d+)\+(\d+)\s*$' | Select-Object -First 1
if (-not $versionLine) {
    Stop-WithMessage "Could not read 'version: x.y.z+n' from pubspec.yaml. The build number (+n) is needed for the file name."
}
$version = $versionLine.Matches[0].Groups[1].Value
$buildNumber = $versionLine.Matches[0].Groups[2].Value
$fullVersion = "$version+$buildNumber"
$versionTag = "v${version}_$buildNumber"
$suffix = "$Flavor-$Mode"

# --- 2. Check the options (before Flutter runs) ------------------------------
if ($NoObfuscate -and $Flavor -eq $productionFlavor -and $Mode -eq 'release') {
    Stop-WithMessage "A $productionFlavor release must be obfuscated. -NoObfuscate is refused for -Flavor $productionFlavor -Mode release."
}
if ($SymbolsDir -and ($NoObfuscate -or $Mode -eq 'debug')) {
    Stop-WithMessage '-SymbolsDir is only used when the build is obfuscated (not with -NoObfuscate or -Mode debug).'
}
if ($SymbolsDir) {
    # Combine() keeps an absolute path as it is; GetFullPath() removes "..".
    $symbolsFull = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($repoRoot, $SymbolsDir))
    $buildPrefix = $buildRoot.TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
    if (-not $symbolsFull.StartsWith($buildPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        Stop-WithMessage "-SymbolsDir must be inside build/. Got: $SymbolsDir"
    }
}
if ($NoSplit -and $Target -eq 'aab') {
    Write-Host '-NoSplit has no effect for an App Bundle; ignored.' -ForegroundColor Yellow
}
$obfuscate = -not $NoObfuscate
if ($Mode -eq 'debug' -and $obfuscate) {
    Write-Host 'Debug build: --obfuscate and --split-debug-info are left out (Flutter does not support them in debug).' -ForegroundColor Yellow
    $obfuscate = $false
}
$splitPerAbi = ($Target -eq 'apk') -and (-not $NoSplit)

Write-Host "Building $Flavor $Mode $Target for version $version (build $buildNumber)" -ForegroundColor Cyan

# Flutter ABI name -> short name used in our file names.
$abiShortNames = [ordered]@{
    'armeabi-v7a' = 'armeabi'
    'arm64-v8a'   = 'arm64'
    'x86_64'      = 'x86_64'
}

$apkDir = Join-Path $buildRoot 'app\outputs\flutter-apk'
# Gradle names the bundle folder <flavor><Mode>, for example prodRelease.
$modeTitle = $Mode.Substring(0, 1).ToUpperInvariant() + $Mode.Substring(1)
$aabDir = Join-Path $buildRoot "app\outputs\bundle\$Flavor$modeTitle"

# Each entry: the file Flutter writes, and the name we give it.
$outputs = @()
if ($Target -eq 'apk' -and $splitPerAbi) {
    foreach ($abi in $abiShortNames.Keys) {
        $outputs += [pscustomobject]@{
            Source = Join-Path $apkDir "app-$abi-$suffix.apk"
            Final  = Join-Path $apkDir "$Name-$($abiShortNames[$abi])-$versionTag-$suffix.apk"
        }
    }
} elseif ($Target -eq 'apk') {
    $outputs += [pscustomobject]@{
        Source = Join-Path $apkDir "app-$suffix.apk"
        Final  = Join-Path $apkDir "$Name-$versionTag-$suffix.apk"
    }
} else {
    $outputs += [pscustomobject]@{
        Source = Join-Path $aabDir "app-$suffix.aab"
        Final  = Join-Path $aabDir "$Name-$versionTag-$suffix.aab"
    }
}

# --- 3. Remove old Flutter-named output --------------------------------------
foreach ($o in $outputs) {
    Remove-Item -LiteralPath $o.Source, "$($o.Source).sha1" -ErrorAction SilentlyContinue
}

# --- Flutter arguments --------------------------------------------------------
$flutterArgs = @('build')
$flutterArgs += $(if ($Target -eq 'apk') { 'apk' } else { 'appbundle' })
$flutterArgs += @('--flavor', $Flavor, "--$Mode")
if ($obfuscate) {
    if (-not $SymbolsDir) {
        $SymbolsDir = if ($Target -eq 'apk') {
            "build/symbols/android-$Flavor-$fullVersion-apk/"
        } else {
            "build/symbols/android-$Flavor-$fullVersion/"
        }
    }
    $flutterArgs += @('--obfuscate', "--split-debug-info=$SymbolsDir")
}
if ($splitPerAbi) {
    $flutterArgs += '--split-per-abi'
}

Push-Location $repoRoot
try {
    # --- 4. Build -------------------------------------------------------------
    Write-Host "flutter $($flutterArgs -join ' ')" -ForegroundColor DarkGray
    & flutter @flutterArgs
    if ($LASTEXITCODE -ne 0) {
        throw "flutter build failed (exit code $LASTEXITCODE). Nothing was renamed or hashed."
    }

    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    $results = @()

    foreach ($o in $outputs) {
        if (-not (Test-Path -LiteralPath $o.Source)) {
            throw "Expected build output not found: $($o.Source)"
        }

        # --- 5. Rename --------------------------------------------------------
        if (Test-Path -LiteralPath $o.Final) {
            Write-Host "Replacing existing $(Split-Path $o.Final -Leaf)" -ForegroundColor Yellow
            Remove-Item -LiteralPath $o.Final, "$($o.Final).sha256" -ErrorAction SilentlyContinue
        }
        Move-Item -LiteralPath $o.Source -Destination $o.Final

        # --- 6. Delete Flutter's .sha1 ---------------------------------------
        Remove-Item -LiteralPath "$($o.Source).sha1" -ErrorAction SilentlyContinue

        # --- 7. Write .sha256 -------------------------------------------------
        $fileName = Split-Path $o.Final -Leaf
        $hash = Get-Sha256Hex $o.Final
        [System.IO.File]::WriteAllText("$($o.Final).sha256", "$hash  $fileName`n", $utf8NoBom)

        $results += [pscustomobject]@{
            File   = $fileName
            SizeMB = [math]::Round((Get-Item -LiteralPath $o.Final).Length / 1MB, 1)
            SHA256 = $hash
        }
    }

    # --- 8. Report --------------------------------------------------------------
    Write-Host ''
    Write-Host "Done. Files are in $(Split-Path $outputs[0].Final -Parent)" -ForegroundColor Green
    if ($obfuscate) {
        Write-Host "Debug symbols: $SymbolsDir (archive this folder)" -ForegroundColor Green
    }
    $results | Format-Table -AutoSize | Out-String -Width 300 | Write-Host
}
finally {
    # --- 9. Stop Gradle daemons -------------------------------------------------
    $gradlew = Join-Path $repoRoot 'android\gradlew.bat'
    if (Test-Path -LiteralPath $gradlew) {
        Write-Host 'Stopping Gradle daemons...' -ForegroundColor DarkGray
        Push-Location (Join-Path $repoRoot 'android')
        try { & $gradlew --stop | Out-Null } finally { Pop-Location }
    }
    Pop-Location
}
