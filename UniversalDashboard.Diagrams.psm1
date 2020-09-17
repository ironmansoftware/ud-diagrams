
$IndexJs = Get-ChildItem "$PSScriptRoot\index.*.bundle.js"
$JsFiles = Get-ChildItem "$PSScriptRoot\*.bundle.js"
$Maps = Get-ChildItem "$PSScriptRoot\*.map"

$Script:AssetId = [UniversalDashboard.Services.AssetService]::Instance.RegisterScript($IndexJs.FullName)

foreach($item in $JsFiles)
{
    [UniversalDashboard.Services.AssetService]::Instance.RegisterScript($item.FullName) | Out-Null
}

foreach($item in $Maps)
{
    [UniversalDashboard.Services.AssetService]::Instance.RegisterScript($item.FullName) | Out-Null
}

function Script:New-UDDiagram {
    param(
        [Parameter()]
        [string]$Id = (New-Guid).ToString(),
        [Parameter(Mandatory)]
        [Hashtable[]]$Node,
        [Parameter()]
        [Hashtable[]]$Link = @(),
        [Parameter()]
        [switch]$Locked,
        [Parameter()]
        [string]$Height = '100ch',
        [Parameter()]
        [object]$OnSelected
    )

    End {

        if ($null -ne $OnSelected) {
            if ($OnSelected -is [scriptblock]) {
                $OnSelected = New-UDEndpoint -Endpoint $OnSelected -Id ($Id + "onSelected")
            }
            elseif ($OnSelected -isnot [UniversalDashboard.Models.Endpoint]) {
                throw "OnSelected must be a script block or UDEndpoint"
            }
        }

        @{
            assetId = $Script:AssetId 
            isPlugin = $true 
            type = "ud-diagram"
            id = $Id
            nodes = $Node 
            links = $Link
            locked = $locked.IsPresent
            height = $Height
            onSelected = $OnSelected.Name
        }
    }
}

function Script:New-UDDiagramNode {
    param(
        [Parameter()]
        [string]$Id = [Guid]::NewGuid(),
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter()]
        [UniversalDashboard.Models.DashboardColor]$Color,
        [Parameter()]
        [string[]]$OutPort, 
        [Parameter()]
        [string[]]$InPort,
        [Parameter()]
        [int]$xOffset = 0,
        [Parameter()]
        [int]$yOffset = 0
    )

    @{
        id = $Id.ToLower()
        name = $Name.ToLower()
        color = $Color.HtmlColor
        outPorts = $OutPort
        inPorts = $InPort
        xOffset = $xOffset
        yOffset = $yOffset
    }
}

function Script:New-UDDiagramLink {
    param(
        [Parameter(Mandatory = $true)]
        [string]$OutNode, 
        [Parameter(Mandatory = $true)]
        [string]$OutPort,
        [Parameter(Mandatory = $true)]
        [string]$InNode, 
        [Parameter(Mandatory = $true)]
        [string]$InPort
    )

    @{
        outNode = $outNode.ToLower()
        inNode = $inNode.ToLower()
        inPort = $InPort.ToLower()
        outPort = $OutPort.ToLower()
    }
}