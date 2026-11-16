[CmdletBinding()]
param(
    [string]$Tag = (Get-Date -Format "yyyyMMddHHmmss")
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot

function Invoke-Checked {
    param(
        [Parameter(Mandatory = $true)][string]$Command,
        [Parameter(Mandatory = $true)][string[]]$Arguments
    )

    & $Command @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "$Command failed with exit code $LASTEXITCODE."
    }
}

Push-Location $root
try {
    $accountId = (& az account show --query id --output tsv)
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($accountId)) {
        throw "Sign in to Azure CLI and select the target subscription before deployment."
    }

    $registryName = (& terraform -chdir=terraform output -raw acr_name)
    if ($LASTEXITCODE -ne 0) { throw "Terraform output acr_name is unavailable; apply infrastructure first." }
    $registryServer = (& terraform -chdir=terraform output -raw acr_login_server)
    if ($LASTEXITCODE -ne 0) { throw "Terraform output acr_login_server is unavailable." }
    $image = "$registryServer/api:$Tag"

    Invoke-Checked "dotnet" @(
        "publish",
        "src/AzureContainerApps.Api/AzureContainerApps.Api.csproj",
        "--configuration", "Release",
        "--output", "publish"
    )
    Invoke-Checked "docker" @("build", "--file", "src/Dockerfile", "--tag", $image, ".")
    Invoke-Checked "az" @("acr", "login", "--name", $registryName)
    Invoke-Checked "docker" @("push", $image)
    Invoke-Checked "terraform" @(
        "-chdir=terraform",
        "apply",
        "-auto-approve",
        "-var=container_image=$image"
    )

    Write-Host "Application deployed: $(terraform -chdir=terraform output -raw container_app_url)"
}
finally {
    Pop-Location
}
