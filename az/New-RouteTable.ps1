<#
.SYNOPSIS
    Create/populate UDR and force tunnel
.DESCRIPTION
    The following script creates a User Defined Route, populates it with Routes, and sets a forced tunneling default site to a virtual network gateway.
#>

# Set variables
$rgName = "rg-infra-wvd"
$location = "eastus"
$rtName = "rt-infra-avd"

$routeJson = '[{
                    "Name": "ToPrivateSubnet",
                    "AddressPrefix": "192.168.0.1/16",
                    "NextHopType": "VirtualNetworkGateway"
                },
                {
                    "Name": "ToPrivateSubnet1",
                    "AddressPrefix": "192.168.1.1/32",
                    "NextHopType": "VirtualNetworkGateway"
                }
               ]'

# Create route table
$routeTable = New-AzRouteTable `
  -Name $rtName `
  -ResourceGroupName $rgName `
  -location $location

# Convert JSON to variable
$routes = $routeJson | ConvertFrom-Json

# Parse routes and add them to the route table
foreach ($route in $routes) {

    Write-Output "Creating Route Name: $($route.Name)"

    Get-AzRouteTable -ResourceGroupName $rgName `
                     -Name $rtName `
                     | Add-AzRouteConfig `
                     -Name $route.Name `
                     -AddressPrefix $route.AddressPrefix `
                     -NextHopType $route.NextHopType `
                     | Set-AzRouteTable

}

# Get local gateway
$LocalGateway = Get-AzLocalNetworkGateway -Name "ContosoLocalGateway " `
                                          -ResourceGroup "ContosoResourceGroup"
# Get virtual gateway
$VirtualGateway = Get-AzVirtualNetworkGateway -Name "ContosoVirtualGateway"

# Set virtual network gateway default (force tunnel)
Set-AzVirtualNetworkGatewayDefaultSite -GatewayDefaultSite $LocalGateway `
                                       -VirtualNetworkGateway $VirtualGateway