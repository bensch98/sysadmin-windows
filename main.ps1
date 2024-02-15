param (
    [string]
    [Parameter(Mandatory = $true, Position = 0)]
    $Command,

    [string]
    [Parameter()]
    $Config,

    [array]
    [Parameter()]
    $Arguments = @()
)

# import modules
Import-Module "$PSScriptRoot\modules\common.psm1" -Force

if ($Config) {
    $configFilePath = Join-Path $PSScriptRoot -ChildPath $Config
    Write-Output "Using specified config: $Config"
} else {
    $configFilePath = Join-Path $PSScriptRoot -ChildPath "local.json"
    Write-Output "Using default config: local.json"
}

if (-not (Test-Path $configFilePath)) {
    Write-Error "Config file not found: $configFilePath"
    Exit 1
}

# global settings
$cfg = Import-GlobalConfig -ConfigFilePath $configFilePath
$cfg | Add-Member -MemberType NoteProperty -Name "credential" -Value $(Login -config cfg)

# available commands
switch ($Command) {
    "get-reservations" { 
        . "$PSScriptRoot\commands\get-reservations.ps1";
        Get-Reservations $config1
    }
    default {
        Write-Error "Invalid command: $Command";
        Exit 1
    }
}