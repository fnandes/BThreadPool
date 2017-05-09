if(Test-Path .\artifacts) { Remove-Item .\artifacts -Force -Recurse }

# Evaluate next version based on AppVeyor build version
$actual_version = "$env:APPVEYOR_BUILD_VERSION"
Write-Host "Set version to $actual_version"

# Set version on project files
ls */*/*.csproj | foreach { echo $_.FullName} |
foreach {
    $content = get-content "$_"
    $content = $content.Replace("99.99.99", $actual_version)
    set-content "$_" $content -encoding UTF8
}

& dotnet restore
if ($LASTEXITCODE -ne 0)
{
    throw "dotnet restore failed with exit code $LASTEXITCODE"
}

& dotnet pack .\src\BThreadPool -c Release -o .\artifacts

# Rollback version on project files
ls */*/*.csproj | foreach { echo $_.FullName} |
foreach {
    $content = get-content "$_"
    $content = $content.Replace($actual_version, "99.99.99")
    set-content "$_" $content -encoding UTF8
}