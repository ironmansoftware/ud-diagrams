$BuildFolder = $PSScriptRoot

$powerShellGet = Import-Module PowerShellGet  -PassThru -ErrorAction Ignore
if ($powerShellGet.Version -lt ([Version]'1.6.0')) {
	Install-Module PowerShellGet -Scope CurrentUser -Force -AllowClobber
	Import-Module PowerShellGet -Force
}

Set-Location $BuildFolder

$OutputPath = "$BuildFolder\output\UniversalDashboard.Diagrams"

Remove-Item -Path $OutputPath -Force -ErrorAction SilentlyContinue -Recurse
Remove-Item -Path "$BuildFolder\public" -Force -ErrorAction SilentlyContinue -Recurse

New-Item -Path $OutputPath -ItemType Directory

npm install
npm run build

Copy-Item $BuildFolder\public\*.bundle.js $OutputPath
Copy-Item $BuildFolder\public\*.map $OutputPath
Copy-Item $BuildFolder\UniversalDashboard.Diagrams.psm1 $OutputPath

$Version = "1.0.2"

$manifestParameters = @{
	Path = "$OutputPath\UniversalDashboard.Diagrams.psd1"
	Author = "Adam Driscoll"
	CompanyName = "Ironman Software, LLC"
	Copyright = "2020 Ironman Software, LLC"
	RootModule = "UniversalDashboard.Diagrams.psm1"
	Description = "Diagrams for Universal Dashboard."
	ModuleVersion = $version
	Tags = @("universaldashboard", "diagrams", "ud-control", "ud-licensed")
	ReleaseNotes = "Added support for loading license from environment variable."
	FunctionsToExport = @(
		"New-UDDiagram"
		"New-UDDiagramNode"
		"New-UDDiagramLink"
	)
	IconUri = "https://github.com/ironmansoftware/ud-diagrams/raw/master/images/logo.png"
	ProjectUri = "https://github.com/ironmansoftware/ud-diagrams"
  RequiredModules = @()
}

New-ModuleManifest @manifestParameters 

if ($prerelease -ne $null) {
	Update-ModuleManifest -Path "$OutputPath\UniversalDashboard.Diagrams.psd1" -Prerelease $prerelease
}