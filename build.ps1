[CmdletBinding()]
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]] $MakeArgs
)

$ErrorActionPreference = "Stop"

$Image = "pokeyellow-build:rgbds-1.0.1-python3"
$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

if (-not $MakeArgs -or $MakeArgs.Count -eq 0) {
    $MakeArgs = @("compare")
}

& docker version --format "{{.Server.Version}}" *> $null
if ($LASTEXITCODE -ne 0) {
    throw "Docker is not running or is not reachable. Start Docker Desktop, then run this script again."
}

& docker image inspect $Image *> $null
if ($LASTEXITCODE -ne 0) {
    & docker build --tag $Image $RepoRoot
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
}

$Mount = "${RepoRoot}:/work"

if ($MakeArgs[0] -eq "shell") {
    & docker run --rm -it -v $Mount -w /work $Image bash
    exit $LASTEXITCODE
}

& docker run --rm -v $Mount -w /work $Image make "RGBDS=/opt/rgbds/" @MakeArgs
exit $LASTEXITCODE
