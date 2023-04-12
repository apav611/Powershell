<#
    .DESCRIPTION
        

    .NOTES
        AUTHOR: Adam Pavlik
        LASTEDIT: 4/12/2023
#>

# define variables
Param
(
  [Parameter (Mandatory= $false)]
  [String] $rgName = "TestRG1",

  [Parameter (Mandatory= $false)]
  [String] $gatewayName = "VNet1GW",

  [Parameter (Mandatory= $false)]
  [Int] $disconnectThreshold = 10
)

# login to azure
try
{
    "Logging in to Azure..."
    " "
    $connect = Connect-AzAccount -Identity
}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}

"Checking for open P2S VPN connections on the $gatewayName gateway..."
" "

# get azure vpn client connection status
$vpnClientConnectionStatus = Get-AzVirtualNetworkGatewayVpnClientConnectionHealth -ResourceGroupName $rgName -VirtualNetworkGatewayname $gatewayName

if ($vpnClientConnectionStatus -eq $null) {
    "No VPN client connections found"
    return
}
else {
    "VPN client connections found"
    " "

    # for each vpn client connection discconect if duration is greater than disconnectThreshold
    foreach ($connection in $vpnClientConnectionStatus) {
        "   Evaluating connection duration for $($connection.VpnUserName)"
        " "
        
        if ($connection.VpnConnectionDuration -gt $disconnectThreshold) {
            "   Disconnecting $($connection.VpnUserName) because current duration is $($connection.VpnConnectionDuration)"
            " "
            $conDisc = Disconnect-AzVirtualNetworkGatewayVpnConnection -ResourceGroupName $rgName -VirtualNetworkGatewayName $gatewayName -VpnConnectionId $connection.VpnConnectionId
        }
        else {
            "   Connection duration is less than threshold: $($connection.VpnConnectionDuration)"
            " "
        }
    }
    
    $m = $vpnClientConnectionStatus | measure | Select-Object Count
    
    "$($m.count) connection(s) evaluated"
}