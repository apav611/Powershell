<#
.SYNOPSIS
    Copy routes to new Route table
.DESCRIPTION
    
#>

param(
    [Parameter(Mandatory)]
    [string]$sourceSubscriptionID,

    [Parameter(Mandatory)]
    [string]$sourceResourceGroup,
    
    [Parameter(Mandatory)]
    [string]$sourceRouteTableName,

    [Parameter(Mandatory)]
    [string]$destinationSubscriptionID,

    [Parameter(Mandatory)]
    [string]$destinationResourceGroup,

    [Parameter(Mandatory)]
    [string]$destinationRouteTableName,

    [Parameter(Mandatory)]
    [string]$destinationLocation
)

# set context to source subsription
Set-AzContext $sourceSubscriptionID

# get routes from source route table
$sourceRoutes = (Get-azRoutetable -ResourceGroupName $sourceResourceGroup `
                                  -Name $sourceRouteTableName).Routes

# check for desitnation routes, throw error if empty
if (!$sourceRoutes) {
    Write-Output "Error: no routes found in source Route table"
    throw
}

# set context to destination subsription
Set-AzContext $desitnationSubscriptionID

# Create route table
$newRouteTable = New-AzRouteTable -Name $destinationRouteTableName `
                                  -ResourceGroupName $destinationResourceGroup `
                                  -location $destinationLocation

# Populate newly create route table with routes from source
foreach ($route in $sourceRoutes) {
    
    Write-Output "Adding Route Name: $($route.Name) to $destinationRouteTableName"

    Get-AzRouteTable -ResourceGroupName $destinationResourceGroup `
                     -Name $newRouteTable.Name `
                     | Add-AzRouteConfig `
                     -Name $route.Name `
                     -AddressPrefix $route.AddressPrefix `
                     -NextHopType $route.NextHopType `
                     | Set-AzRouteTable `
                     | Out-Null

}
