$ErrorActionPreference = 'Continue'
$env:LEAN_PATH = (Get-Location).Path + ';' + $env:LEAN_PATH
& lean LiouvilleGoldbach/Main.lean
exit $LASTEXITCODE
