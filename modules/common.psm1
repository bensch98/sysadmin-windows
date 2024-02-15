function Import-GlobalConfig {
    param(
        [string]
        [Parameter(Mandatory = $true)]
        $configFilePath
    )
    $config = Get-Content -Path $configFilePath -Raw | ConvertFrom-Json
    return $config
}

function Login {
    param(
        [string]
        [Parameter(Mandatory = $true)]
        $config
    )
    $securePassword = Read-Host "[admin] password for $($config1.username)" -AsSecureString
    $loginName = "$($config.domain)\$($config.username)"
    $credential = New-Object System.Management.Automation.PSCredential($loginName, $securePassword)
    $config | Add-Member -MemberType NoteProperty -Name "credential" -Value $credential
    return $credential
}