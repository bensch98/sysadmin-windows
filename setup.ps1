$hooksDir = ".git/hooks"
$hookFile = "$hooksDir/pre-commit"

$hookContent = @"
#!/bin/bash

FILE_TO_CHECK="modules/common.psm1"
LINE_TO_SEARCH="plainTextPassword"

if grep -q "plainTextPassword" "modules/common.psm1"; then
    echo "Error: Commit leaks a credential in plain text."
    echo "Please remove the forbidden line before commiting."
    exit 1
fi
"@

# create hooks if it doesn't exist
if (-not (Test-Path $hooksDir)) {
    New-Item -ItemType Directory -Path $hooksDir -ErrorAction Stop | Out-Null
}

Set-Content -Path $hookFile -Value $hookContent -ErrorAction Stop
Set-ItemProperty -Path $hookFile -Name IsReadOnly -Value $false