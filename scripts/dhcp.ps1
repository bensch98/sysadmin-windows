# Read specified config file
$configFileName = $args[0]
$configFilePath = Join-Path $PSScriptRoot -ChildPath "..\$configFileName"
$config = Get-Content -Path $configFilePath -Raw | ConvertFrom-Json

# Prompt crendentials from user
# $credential = Get-credential -UserName $config.username -Message "[admin] password: "

$plaintextPassword = ""
$securePassword = ConvertTo-SecureString -String $plaintextPassword -AsPlainText -Force
$securePassword = Read-Host "[admin] password for $($config.username)" -AsSecureString
$credential = New-Object System.Management.Automation.PSCredential($config.username, $securePassword)

Write-Information "Login via $($config.username) into $($config.server) statement."

# Ports commonly used for PowerShell remoting
# - HTTP: 5985
# - HTTPS: 5986 
$sessionOption = New-PSSessionOption -NoMachineProfile
$session = New-PSSession -ComputerName "localhost" -Port 5985 -SessionOption $sessionOption

Invoke-Command -ComputerName $config.server -Credential $credential -Session $session -ScriptBlock {
    # import modules
    if (-not (Get-Module -Name DhcpServer)) {
        Import-Module DhcpServer -SkipEditionCheck
    }

    $PSVersionTable.PSVersion

    #$scopes = Get-DhcpServerv4Scope -ComputerName $env:COMPUTERNAME
    #foreach ($scope in $scopes) {
    #    Get-DhcpServerv4Lease -ComputerName $env:COMPUTERNAME -ScopeId $scope.ScopeId
    #}
}