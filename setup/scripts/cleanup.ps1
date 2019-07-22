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


# Delete Resources.
foreach($resourceId in (Get-AzResource -ResourceGroupName $resourceGroupName).Id) {
    Remove-AzResource `
        -ResourceId $resourceId `
        # -Force
}


# Delete Resource Group.
Remove-AzResourceGroup -Name $resourceGroupName