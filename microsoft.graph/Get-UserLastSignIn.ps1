<#
.SYNOPSIS
    Find inactive users in Azure Ad
.DESCRIPTION
    The following script gets all users who haven't signed-in since the define variable $daysOld.
#>

#install graph PS module
Install-Module Microsoft.Graph

# variables
# daysOld must be a negative integer
$daysOld = -10

# calculate date
$xAgoDate = (get-date).AddDays($daysOld)

# not required if connecting to Global
Get-MgEnvironment

# connect with Graph, if connecting to cloud other then Global include -Environment and Name from previous cmd
# example: Connect-Graph -Environment USGov -Scopes "Directory.Read.All", "AuditLog.Read.All"
Connect-Graph -Scopes "Directory.Read.All", 
                      "AuditLog.Read.All"

# set required API version
Select-MgProfile "beta"

# print out users whom haven't logged in during audit period
Get-MgUser -Property SignInActivity | Where-Object {$_.SignInActivity.LastSignInDateTime -le $xAgoDate} `
                                    | Select-Object DisplayName,
                                                    UserPrincipalName,
                                                    UserType,
                                                    CreatedDateTime,
                                                    @{Name='LastSignInDateTime'; Expression={$_.SignInActivity.LastSignInDateTime}}