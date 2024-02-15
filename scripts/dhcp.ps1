# Read specified config file
$configFileName = $args[0]
$configFilePath = Join-Path $PSScriptRoot -ChildPath "..\$configFileName"
$config = Get-Content -Path $configFilePath -Raw | ConvertFrom-Json

$securePassword = Read-Host "[admin] password for $($config.username)" -AsSecureString
$loginName = "$($config.domain)\$($config.username)"
$credential = New-Object System.Management.Automation.PSCredential($loginName, $securePassword)

Write-Information "Login via $($config.username) into $($config.server) statement."

# Ports commonly used for PowerShell remoting
# - HTTP: 5985
# - HTTPS: 5986

# command block to execute on the remote server
$session = New-PSSession -ComputerName $config.server -Credential $credential -Port 5985
Invoke-Command -Session $session -ScriptBlock {
    # import modules
    try {
        $prevCulture = [System.Threading.Thread]::CurrentThread.CurrentUICulture
        [System.Threading.Thread]::CurrentThread.CurrentUICulture = "de-DE"
        Import-Module DhcpServer -ErrorAction Stop
    } 
    catch {
        Write-Warning "An error occurred while importing the DhcpServer module: $_"
    }
    finally {
        [System.Threading.Thread]::CurrentThread.CurrentUICulture = $prevCulture
    }

    # create directory for exports if it doesn't existent
    if (-not (Test-Path -Path $Using:config.exportsDir -PathType Container)) {
        New-Item -Path $Using:config.exportsDir -ItemType Directory
    }

    $files = @()
    $scopes = Get-DhcpServerv4Scope -ComputerName $env:COMPUTERNAME
    foreach ($scope in $scopes) {
        $fileName = "$($Using:config.exportsDir)\dhcp_reservation_$($scope.ScopeId.ToString().Replace('.', '-')).csv"
        $reservations = Get-DhcpServerv4Reservation -ComputerName $env:COMPUTERNAME -ScopeId $scope.ScopeId
        $reservations | Export-Csv -Path $fileName -NoTypeInformation
        $files += $fileName
    }

    $files
}
# check if exportsDir exists
$localExportsDir = Join-Path $PSScriptRoot -ChildPath "..\$($config.exportsDir)"
if (-not (Test-Path -Path $localExportsDir -PathType Container)) {
    New-Item -Path $localExportsDir -ItemType Directory
}
# download exports
Copy-Item "C:\Users\$($config.username)\Documents\exports\*" -Destination $localExportsDir -FromSession $session

# cleanup
Remove-PSSession $session
Exit