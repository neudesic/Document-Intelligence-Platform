##################################################################
#                                                                #
#   DIP Cleanup Script                                           #
#                                                                #
#      Deletes azure resources for DIP application.              #
#                                                                #
#                                                                #
#                                                                #
#                                                                #
#      powered by                                                #
#      Neudesic                                                  #
#                                                                #
#                                                                #
##################################################################


# Parameters
$resourceGroupName = "DIP"


# Sign In
Write-Host Logging in...
Connect-AzAccount


# Set Subscription Id
while ($TRUE) {
    try {
        $subscriptionId = Read-Host -Prompt "Input subscription Id"
        Set-AzContext `
            -SubscriptionId $subscriptionId
        break  
    }
    catch {
        Write-Host Invalid subscription Id.`n
    }
}


# Force Deletion
while ($TRUE) {
    try {
        $force = Read-Host -Prompt "Force deletion of resources (y/n)"
        break;
    }
    catch { }
}


# Delete Resources.
foreach ($resourceId in (Get-AzResource -ResourceGroupName $resourceGroupName).Id) {
    if (($force -eq "y") -or ($force -eq "Y") -or ($force -eq "yes") -or ($force -eq "Yes")) {
        Remove-AzResource `
            -ResourceId $resourceId `
            -Force
    } 
    else {
        Remove-AzResource `
            -ResourceId $resourceId 
    }
}


# Delete Resource Group
if (($force -eq "y") -or ($force -eq "Y") -or ($force -eq "yes") -or ($force -eq "Yes")) {
    Remove-AzResourceGroup `
        -Name $resourceGroupName `
        -Force
} 
else {
    Remove-AzResourceGroup `
        -Name $resourceGroupName
}
