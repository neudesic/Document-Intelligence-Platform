##################################################################
#                                                                #
#   DIP Setup Script                                             #
#                                                                #
#      Spins up azure resources for DIP application.             #
#                                                                #
#                                                                #
#                                                                #
#                                                                #
#      powered by                                                #
#      Neudesic                                                  #
#                                                                #
#                                                                #
##################################################################


#----------------------------------------------------------------#
#   Parameters                                                   #
#----------------------------------------------------------------#


# prefixes
$prefix = "dip-github"
$prefixLowCaseNoDashes = "dipgithub"

# logistics
$location = "eastus";
$resourceGroupName = "DIP"
$resourceProviders = @(
    "microsoft.documentdb",
    "microsoft.insights",
    "microsoft.search",
    "microsoft.sql",
    "microsoft.storage",
    "microsoft.logic",
    "microsoft.web")

# storage resources
$storageAccountName = $prefixLowCaseNoDashes;
$storageContainerW2 = "w2-form"
$storageContainerW2Training = "training-w2-form"
$storageContainerFinancial = "financial-table"
$storageContainerFinancialTraining = "training-financial-table"
$blobsFilePath = "$PSScriptRoot\..\..\blobs\"
$trainingFilePath = "$PSScriptRoot\..\..\training-data\"

# cosmos resources
$cosmosDatabaseName = $prefix + "-db"
$cosmosAccountName = $prefix + "-cosmos-account"
$cosmosContainerFinancial = "financial-table"
$cosmosContainerFinancialEnriched = "financial-table-enriched"
$cosmosContainerW2 = "w2-form"
$cosmosContainerW2Enriched = "w2-form-enriched"
$cosmosContainerProcessed = "processed"

# cognitive services resources
$formRecognizerName = $prefixLowCaseNoDashes + "formreco"
$formRecognizerLocation = "West US 2"

# app service plan
$appServicePlanName = $prefix + "-asp"
$webAppName = $prefix + "-wa"

# function app
$functionAppShape = "shape"
$functionAppEnrich = "enrich"
$functionAppProcess = "process"
$filePathShape = "$PSScriptRoot\..\functions\shapefunc.zip"
$filePathEnrich = "$PSScriptRoot\..\functions\enrichfunc.zip"
$filePathProcess = "$PSScriptRoot\..\functions\processfunc.zip"

# api connections
$documentdbName = "documentdb"
$azureblobName = "azureblob"
$documentdbTemplateFilePath = "$PSScriptRoot\..\templates\document-db-template.json"
$documentdbParametersFilePath = "$PSScriptRoot\..\templates\document-db-parameters.json"
$azureblobTemplateFilePath = "$PSScriptRoot\..\templates\azure-blob-template.json"
$azureblobParametersFilePath = "$PSScriptRoot\..\templates\azure-blob-parameters.json"

# logic app
$logicApp1Name = "logicapp1"
$logicApp2Name = "logicapp2"
$logicApp1TemplateFilePath = "$PSScriptRoot\..\templates\logic-app-1-template.json"
$logicApp2TemplateFilePath = "$PSScriptRoot\..\templates\logic-app-2-template.json"
$logicApp1ParametersFilePath = "$PSScriptRoot\..\templates\logic-app-1-parameters.json"
$logicApp2ParametersFilePath = "$PSScriptRoot\..\templates\logic-app-2-parameters.json"


#----------------------------------------------------------------#
#   Setup                                                        #
#----------------------------------------------------------------#


$ErrorActionPreference = "Stop"


# Sign In
Write-Host Logging in...
Login-AzAccount 


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
$index = 0
$numbers = "123456789"
foreach ($char in $subscriptionId.ToCharArray()) {
    if ($numbers.Contains($char)) {
        break;
    }
    $index++
}
$id = $subscriptionId.Substring($index, $index + 5)
$storageAccountName = $storageAccountName + $id
$cosmosAccountName = $cosmosAccountName + $id
$webAppName = $webAppName + $id
$functionAppShape = $functionAppShape + $id
$functionAppEnrich = $functionAppEnrich + $id
$functionAppProcess = $functionAppProcess + $id


# Register Resource Providers
Write-Host Registering resource providers:`n
foreach ($resourceProvider in $resourceProviders) {
    Write-Host - Registering $resourceProvider
    Register-AzResourceProvider `
        -ProviderNamespace $resourceProvider;
}


# Create Resource Group 
Write-Host Creating Resource Group $resourceGroupName"..."`n
New-AzResourceGroup `
    -Name $resourceGroupName `
    -Location $location `
    -Force
Start-Sleep -s 5


#----------------------------------------------------------------#
#   Azure Resources                                              #
#----------------------------------------------------------------#


# Create Storage Account
try {
    Write-Host Creating storage account...
    $storageAccount = Get-AzStorageAccount `
        -ResourceGroupName $resourceGroupName `
        -AccountName $storageAccountName
}
catch {
    $storageAccount = New-AzStorageAccount `
        -AccountName $storageAccountName `
        -ResourceGroupName $resourceGroupName `
        -Location $location `
        -SkuName Standard_LRS `
        -Kind StorageV2 
}
$storageAccount
$storageContext = $storageAccount.Context
Start-Sleep -s 5


# Create Storage Containers
Write-Host Creating blob containers...
$storageContainerNames = @($storageContainerW2, $storageContainerW2Training, $storageContainerFinancial, $storageContainerFinancialTraining)
foreach ($containerName in $storageContainerNames) {
    try {
        Get-AzStorageContainer `
            -Name $containerName `
            -Context $storageContext
    }
    catch {
        new-AzStoragecontainer `
            -Name $containerName `
            -Context $storageContext `
            -Permission container
    }
}
Start-Sleep -s 5


# Upload Blobs And Training Data
Write-Host Uploading blobs and training documents...`n
$trainingInfo = @(
    (($blobsFilePath + "w2-form/"), $storageContainerW2), `
    (($blobsFilePath + "financial-table/"), $storageContainerFinancial), `
    (($trainingFilePath + "w2-form/"), $storageContainerW2Training), `
    (($trainingFilePath + "financial-table/"), $storageContainerFinancialTraining))
foreach ($info in $trainingInfo) {
    $filePath = $info[0]
    $containerName = $info[1]
    $files = Get-ChildItem $filePath
    foreach ($file in $files) {
        Write-Host - Uploading $file.Name
        set-AzStorageblobcontent `
            -File ($filePath + $file.Name) `
            -Container $containerName `
            -Blob $file.Name `
            -Context $storageContext `
            -Force
    }
}


# Create Form Recognizer Account
Write-Host Creating Form Recognizer service...
New-AzCognitiveServicesAccount `
    -ResourceGroupName $resourceGroupName `
    -Name $formRecognizerName `
    -Type FormRecognizer `
    -SkuName F0 `
    -Location $formRecognizerLocation
Start-Sleep -s 10


# Train Form Recognizer
Write-Host Training Form Recognizer...
$formRecognizerKey = (Get-AzCognitiveServicesAccountKey -ResourceGroupName $resourceGroupName -Name $formRecognizerName).Key1
$formRecognizerLocation = (Get-AzCognitiveServicesAccount -ResourceGroupName $resourceGroupName -Name $formRecognizerName).Location -replace '\s', ''
$formRecognizerTrainUrl = "https://" + $formRecognizerLocation + ".api.cognitive.microsoft.com/formrecognizer/v1.0-preview/custom/train"
$formRecognizeHeader = @{
    "Ocp-Apim-Subscription-Key" = $formRecognizerKey
}

$formRecognizerModels = @{ }
$storageContainerTraining = @($storageContainerW2Training, $storageContainerFinancialTraining)
foreach ($containerName in $storageContainerTraining) {
    $storageContainerUrl = (Get-AzStorageContainer -Context $storageContext -Name $containerName).CloudBlobContainer.Uri.AbsoluteUri
    $body = "{`"source`": `"$($storageContainerUrl)`"}"
    $response = Invoke-RestMethod -Method Post -Uri $formRecognizerTrainUrl -ContentType "application/json" -Headers $formRecognizeHeader -Body $body
    $response
    $formRecognizerModels[$containerName] = $response.modelId
}


# Create Cosmos SQL API Account
Write-Host Creating CosmosDB account...
$cosmosLocations = @(
    @{ "locationName" = "East US"; "failoverPriority" = 0 }
)

$consistencyPolicy = @{
    "defaultConsistencyLevel" = "BoundedStaleness";
    "maxIntervalInSeconds"    = 300;
    "maxStalenessPrefix"      = 100000
}

$cosmosProperties = @{
    "databaseAccountOfferType"     = "standard";
    "locations"                    = $cosmosLocations;
    "consistencyPolicy"            = $consistencyPolicy;
    "enableMultipleWriteLocations" = "true"
}
New-AzResource `
    -ResourceType "Microsoft.DocumentDb/databaseAccounts" `
    -ApiVersion "2015-04-08" `
    -ResourceGroupName $resourceGroupName `
    -Location $location `
    -Name $cosmosAccountName `
    -PropertyObject $cosmosProperties `
    -Force
Start-Sleep -s 5


# Create Cosmos Database
Write-Host Creating CosmosDB Database...
$cosmosDatabaseProperties = @{
    "resource" = @{ "id" = $cosmosDatabaseName };
    "options"  = @{ "Throughput" = 400 }
} 
$cosmosResourceName = $cosmosAccountName + "/sql/" + $cosmosDatabaseName
New-AzResource `
    -ResourceType "Microsoft.DocumentDb/databaseAccounts/apis/databases" `
    -ApiVersion "2015-04-08" `
    -ResourceGroupName $resourceGroupName `
    -Name $cosmosResourceName `
    -PropertyObject $cosmosDatabaseProperties `
    -Force
Start-Sleep -s 5


# Create Cosmos Container
Write-Host Creating CosmosDB Containers...
$cosmosContainerNames = @($cosmosContainerFinancial, $cosmosContainerFinancialEnriched, 
    $cosmosContainerW2, $cosmosContainerW2Enriched, $cosmosContainerProcessed)
foreach ($containerName in $cosmosContainerNames) {
    $cosmosContainerProperties = @{
        "resource" = @{
            "id"           = $containerName; 
            "partitionKey" = @{
                "paths" = @("/id"); 
                "kind"  = "Hash"
            }; 
        };
        "options"  = @{ }
    } 
    $containerResourceName = $cosmosAccountName + "/sql/" + $cosmosDatabaseName + "/" + $containerName

    New-AzResource `
        -ResourceType "Microsoft.DocumentDb/databaseAccounts/apis/databases/containers" `
        -ApiVersion "2015-04-08" `
        -ResourceGroupName $resourceGroupName `
        -Name $containerResourceName `
        -PropertyObject $cosmosContainerProperties `
        -Force 
}


# Create App Service Plan
Write-Host Creating app service plan...
New-AzAppServicePlan `
    -Name $appServicePlanName `
    -Location $location `
    -ResourceGroupName $resourceGroupName `
    -Tier Free
Start-Sleep -s 5


# Create Web App
try {
    Write-Host Creating web app...
    Get-AzWebApp `
        -ResourceGroupName $resourceGroupName `
        -Name $webAppName
}
catch {
    New-AzWebApp `
        -ResourceGroupName $resourceGroupName `
        -Name $webAppName `
        -Location $location `
        -AppServicePlan $appServicePlanName
}


# Azure Functions
$functionAppInformation = @(
    ($functionAppShape, $filePathShape), `
    ($functionAppEnrich, $filePathEnrich), `
    ($functionAppProcess, $filePathProcess))
foreach ($info in $functionAppInformation) {
    $name = $info[0]
    $filepath = $info[1]
    $functionAppSettings = @{
        serverFarmId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Web/serverFarms/$AppServicePlanName";
        alwaysOn     = $True;
    }

    # Create Function App
    Write-Host Creating Function App $name"..."
    New-AzResource `
        -ResourceGroupName $resourceGroupName `
        -Location $location `
        -ResourceName $name `
        -ResourceType "microsoft.web/sites" `
        -Kind "functionapp" `
        -Properties $functionAppSettings `
        -Force

    $storageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $resourceGroupName -AccountName $storageAccountName).Value[0]
    $storageAccountConnectionString = "DefaultEndpointsProtocol=https;AccountName=$storageAccountName;AccountKey=$($storageAccountKey)"
    $functionAppSettings = @{
        AzureWebJobsDashboard       = $storageAccountConnectionString;
        AzureWebJobsStorage         = $storageAccountConnectionString;
        FUNCTION_APP_EDIT_MODE      = "readwrite";
        FUNCTIONS_EXTENSION_VERSION = "~2";
        FUNCTIONS_WORKER_RUNTIME    = "dotnet";
    }

    # Configure Function App
    Write-Host Configuring $name"..."
    Set-AzWebApp `
        -Name $name `
        -ResourceGroupName $resourceGroupName `
        -AppSettings $functionAppSettings 

    # Deploy Function To Function App
    Write-Host Deploying $name"..."
    $deploymentCredentials = Invoke-AzResourceAction `
        -ResourceGroupName $resourceGroupName `
        -ResourceType Microsoft.Web/sites/config `
        -ResourceName ($name + "/publishingcredentials") `
        -Action list `
        -ApiVersion 2015-08-01 `
        -Force
    $username = $deploymentCredentials.Properties.PublishingUserName
    $password = $deploymentCredentials.Properties.PublishingPassword 
    $apiUrl = "https://$($info[0]).scm.azurewebsites.net/api/zipdeploy"
    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username, $password)))
    $userAgent = "powershell/1.0"
    Invoke-RestMethod `
        -Uri $apiUrl `
        -Headers @{Authorization = ("Basic {0}" -f $base64AuthInfo) } `
        -UserAgent $userAgent `
        -Method POST `
        -InFile $filePath `
        -ContentType "multipart/form-data"
}

    
# Deploy API Connections
$storageAccountKey = (Get-AzStorageAccountKey `
        -ResourceGroupName $resourceGroupName `
        -AccountName $storageAccountName).Value[0]
$azureblobParametersTemplate = Get-Content $azureblobParametersFilePath | ConvertFrom-Json
$azureblobParameters = $azureblobParametersTemplate.parameters
$azureblobParameters.subscription_id.value = $subscriptionId
$azureblobParameters.storage_account_name.value = $storageAccountName
$azureblobParameters.storage_access_key.value = $storageAccountKey
$azureblobParameters.location.value = $location
$azureblobParametersTemplate | ConvertTo-Json | Out-File $azureblobParametersFilePath

$cosmosAccessKey = Invoke-AzResourceAction `
    -Action listKeys `
    -ResourceType "Microsoft.DocumentDb/databaseAccounts" `
    -ApiVersion "2015-04-08" `
    -ResourceGroupName $resourceGroupName `
    -Force `
    -Name $cosmosAccountName | Select-Object * 
$documentdbParametersTemplate = Get-Content $documentdbParametersFilePath | ConvertFrom-Json
$documentdbParameters = $documentdbParametersTemplate.parameters
$documentdbParameters.subscription_id.value = $subscriptionId
$documentdbParameters.location.value = $location
$documentdbParameters.cosmos_account_name.value = $cosmosAccountName
$documentdbParameters.cosmos_access_key.value = $cosmosAccessKey.primaryMasterKey
$documentdbParametersTemplate | ConvertTo-Json | Out-File $documentdbParametersFilePath

$apiConnectionInformation = @(
    ($azureblobName, $azureblobTemplateFilePath, $azureblobParametersFilePath), 
    ($documentdbName, $documentdbTemplateFilePath, $documentdbParametersFilePath)
)
foreach ($info in $apiConnectionInformation) {
    $connectionName = $info[0]
    $templateFilePath = $info[1]
    $parametersFilePath = $info[2]
    Write-Host Deploying $connectionName"..."
    New-AzResourceGroupDeployment `
        -ResourceGroupName $resourceGroupName `
        -Name $connectionName `
        -TemplateFile $templateFilePath `
        -TemplateParameterFile $parametersFilePath
}
Start-Sleep -s 5


# Deploy Logic Apps
$shapeResourceId = Get-AzResource `
    -ResourceGroupName $resourceGroupName `
    -Name $functionAppShape
$enrichResourceId = Get-AzResource `
    -ResourceGroupName $resourceGroupName `
    -Name $functionAppEnrich
$processResourceId = Get-AzResource `
    -ResourceGroupName $resourceGroupName `
    -Name $functionAppProcess
$azureblobResourceid = Get-AzResource `
    -ResourceGroupName $resourceGroupName `
    -Name $azureblobName
$documentdbResourceId = Get-AzResource `
    -ResourceGroupName $resourceGroupName `
    -Name $documentdbName

$logicApp1ParametersTemplate = Get-Content $logicApp1ParametersFilePath | ConvertFrom-Json
$logicApp1Parameters = $logicApp1ParametersTemplate.parameters
$logicApp1Parameters.logic_app_name.value = $logicApp1Name
$logicApp1Parameters.subscription_id.value = $subscriptionId
$logicApp1Parameters.shape_resource_id.value = $shapeResourceId.Id
$logicApp1Parameters.enrich_resource_id.value = $enrichResourceId.Id
$logicApp1Parameters.azureblob_resource_id.value = $azureblobResourceid.Id
$logicApp1Parameters.documentdb_resource_id.value = $documentdbResourceId.Id
$logicApp1Parameters.location.value = $location
$logicApp1Parameters.form_reco_key.value = $formRecognizerKey
$logicApp1Parameters.cosmos_db_name.value = $cosmosDatabaseName
$logicApp1Parameters.cosmos_container_financial.value = $cosmosContainerFinancial
$logicApp1Parameters.cosmos_container_financial_enriched.value = $cosmosContainerFinancialEnriched
$logicApp1Parameters.cosmos_container_w2.value = $cosmosContainerW2
$logicApp1Parameters.cosmos_container_w2_enriched.value = $cosmosContainerW2Enriched
$logicApp1ParametersTemplate | ConvertTo-Json | Out-File $logicApp1ParametersFilePath
Write-Host Deploying Logic App 1...
New-AzResourceGroupDeployment `
    -ResourceGroupName $resourceGroupName `
    -Name $logicApp1Name `
    -TemplateFile $logicApp1TemplateFilePath `
    -TemplateParameterFile $logicApp1ParametersFilePath

$logicApp2ParametersTemplate = Get-Content $logicApp2ParametersFilePath | ConvertFrom-Json
$logicApp2Parameters = $logicApp2ParametersTemplate.parameters
$logicApp2Parameters.logic_app_name.value = $logicApp2Name
$logicApp2Parameters.subscription_id.value = $subscriptionId
$logicApp2Parameters.process_resource_id.value = $processResourceId.Id
$logicApp2Parameters.documentdb_resource_id.value = $documentdbResourceId.Id
$logicApp2Parameters.location.value = $location
$logicApp2Parameters.cosmos_db_name.value = $cosmosDatabaseName
$logicApp2Parameters.cosmos_container_financial.value = $cosmosContainerFinancial
$logicApp2Parameters.cosmos_container_financial_enriched.value = $cosmosContainerFinancialEnriched
$logicApp2Parameters.cosmos_container_w2.value = $cosmosContainerW2
$logicApp2Parameters.cosmos_container_w2_enriched.value = $cosmosContainerW2Enriched
$logicApp2Parameters.cosmos_container_processed.value = $cosmosContainerProcessed
$logicApp2ParametersTemplate | ConvertTo-Json | Out-File $logicApp2ParametersFilePath
Write-Host Deploying Logic App 2...
New-AzResourceGroupDeployment `
    -ResourceGroupName $resourceGroupName `
    -Name $logicApp2Name `
    -TemplateFile $logicApp2TemplateFilePath `
    -TemplateParameterFile $logicApp2ParametersFilePath


# Process Documents
Write-Host  Deploying documents...`n
$runInformation = @(
    ($storageContainerFinancial, $formRecognizerModels[$storageContainerFinancialTraining], "Financial Table"),
    ($storageContainerW2, $formRecognizerModels[$storageContainerW2Training], "W2")
)
$logicAppTriggerName = (Get-AzLogicAppTrigger `
        -ResourceGroupName $resourceGroupName `
        -Name $logicApp1Name).Name 
$logicAppTriggerUri = (Get-AzLogicAppTriggerCallbackUrl `
        -ResourceGroupName $resourceGroupName `
        -Name $logicApp1Name `
        -TriggerName $logicAppTriggerName).Value
foreach ($info in $runInformation) {
    $containerName = $info[0]
    $model = $info[1]
    $formType = $info[2] 

    Write-Host `n$containerName`n`n  
    $container = Get-AzStorageContainer -Name $containerName -Context $storageContext | Get-AzStorageBlob
    foreach ($file in $container) { 
        $fileName = $file.Name
        Write-Host Deploying $fileName"..."  
        $body = @{
            "recordId" = ("/" + $containerName + "/" + $file.Name);
            "modelId"  = $model;
            "formType" = $formType
        } | ConvertTo-Json

        Invoke-RestMethod `
            -Uri $logicAppTriggerUri `
            -Method Post `
            -ContentType "application/json" `
            -Body $body 
    }
}

Write-Host `nProcessing documents:`n`n  
$logicAppTriggerName = (Get-AzLogicAppTrigger `
        -ResourceGroupName $resourceGroupName `
        -Name $logicApp2Name).Name 
$logicAppTriggerUri = (Get-AzLogicAppTriggerCallbackUrl `
        -ResourceGroupName $resourceGroupName `
        -Name $logicApp2Name `
        -TriggerName $logicAppTriggerName).Value
$container = Get-AzStorageContainer -Name $storageContainerFinancial -Context $storageContext | Get-AzStorageBlob
foreach ($file in $container) { 
    $fileName = $file.Name
    Write-Host Processing $fileName"..."  
    $body = @{
        "recordId" = $file.Name
    } | ConvertTo-Json

    Invoke-RestMethod `
        -Uri $logicAppTriggerUri `
        -Method Post `
        -ContentType "application/json" `
        -Body $body 
}


Write-Host  Deployment complete.