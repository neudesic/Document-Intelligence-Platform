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
$angularConfigFilePath = "$PSScriptRoot\..\..\blobs\angular-app\assets\config.json"

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

# cognitive search
$cognitiveSearchName = $prefixLowCaseNoDashes + "search"
$dataSourceNameW2 = "datasource-w2"
$dataSourceNameFinancial = "datasource-financial"
$indexName = $prefixLowCaseNoDashes + "-index"
$skillsetName = $prefixLowCaseNoDashes + "-skillset"
$indexerNameW2 = $prefixLowCaseNoDashes + "-indexer-w2"
$indexerNameFinancial = $prefixLowCaseNoDashes + "-indexer-financial"


#----------------------------------------------------------------#
#   Setup                                                        #
#----------------------------------------------------------------#


$ErrorActionPreference = "Stop"


# Sign In
Write-Host Logging in...
$credentials = Get-Credential
Connect-AzAccount -Credential $credentials


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
Enable-AzContextAutosave -Scope CurrentUser
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
$cognitiveSearchName = $cognitiveSearchName + $id


function Process_Jobs {
    param($idArray)
    Write-Host `nResults:
    foreach ($id in $idArray) {
        Wait-Job -Id $id
        Receive-Job -Id $id
        Remove-Job -Id $id
    }
}


#----------------------------------------------------------------#
#   Stage 1                                                      #
#----------------------------------------------------------------#


$stage1 = @()


# Register Resource Providers
Write-Host Registering resource providers:`n 
foreach ($resourceProvider in $resourceProviders) {
    Write-Host - Registering $resourceProvider
    $job = Start-Job -ArgumentList $resourceProvider, $credentials -ScriptBlock {
        Connect-AzAccount -Credential $args[1]
        Register-AzResourceProvider `
            -ProviderNamespace $args[0]
    }
    $stage1 += $job.Id
}


# Create Resource Group 
Write-Host `nCreating Resource Group $resourceGroupName"..."`n
$job = Start-Job -ArgumentList $resourceGroupName, $location, $credentials -ScriptBlock {
    Connect-AzAccount -Credential $args[2]
    New-AzResourceGroup `
        -Name $args[0] `
        -Location $args[1] `
        -Force
}
$stage1 += $job.Id


Process_Jobs -idArray $stage1


#----------------------------------------------------------------#
#   Stage 2                                                      #
#----------------------------------------------------------------#


$stage2 = @()


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
$job = Start-Job -ArgumentList $resourceGroupName, $location, $cosmosAccountName, ($cosmosProperties | ConvertTo-Json), $credentials -ScriptBlock {
    Connect-AzAccount -Credential $args[4]
    New-AzResource `
        -ResourceType "Microsoft.DocumentDb/databaseAccounts" `
        -ApiVersion "2015-04-08" `
        -ResourceGroupName $args[0] `
        -Location $args[1] `
        -Name $args[2] `
        -PropertyObject ($args[3] | ConvertFrom-Json) `
        -Force
}
$stage2 += $job.Id


# Create Storage Account
Write-Host Creating storage account...
$job = Start-Job -ArgumentList $resourceGroupName, $storageAccountName, $location, $credentials -ScriptBlock {
    Connect-AzAccount -Credential $args[3]
    $ErrorActionPreference = "Stop"
    try {
        $storageAccount = Get-AzStorageAccount `
            -ResourceGroupName $args[0] `
            -AccountName $args[1]
    }
    catch {
        $storageAccount = New-AzStorageAccount `
            -AccountName $args[1] `
            -ResourceGroupName $args[0] `
            -Location $args[2] `
            -SkuName Standard_LRS `
            -Kind StorageV2 
    }
    $storageAccount
    $storageContext = $storageAccount.Context
    Start-Sleep -s 1

    Enable-AzStorageStaticWebsite `
        -Context $storageContext `
        -IndexDocument "index.html" `
        -ErrorDocument404Path "error.html"
}
$stage2 += $job.Id


# Create Form Recognizer Account
Write-Host Creating Form Recognizer service...
$job = Start-Job -ArgumentList $resourceGroupName, $formRecognizerName, $formRecognizerLocation, $credentials -ScriptBlock {
    Connect-AzAccount -Credential $args[3]
    New-AzCognitiveServicesAccount `
        -ResourceGroupName $args[0] `
        -Name $args[1] `
        -Type FormRecognizer `
        -SkuName F0 `
        -Location $args[2]
}
$stage2 += $job.Id


# Create App Service Plan
Write-Host Creating app service plan...
$job = Start-Job -ArgumentList $appServicePlanName, $location, $resourceGroupName, $credentials -ScriptBlock {
    Connect-AzAccount -Credential $args[3]
    New-AzAppServicePlan `
        -Name $args[0] `
        -Location $args[1] `
        -ResourceGroupName $args[2] `
        -Tier Free
}
$stage2 += $job.Id


# Create Cognitive Search Service
Write-Host Creating Cognitive Search Service...
$job = Start-Job -ArgumentList $resourceGroupName, $cognitiveSearchName, $location, $credentials -ScriptBlock {
    Connect-AzAccount -Credential $args[3]
    New-AzSearchService `
        -ResourceGroupName $args[0] `
        -Name $args[1] `
        -Sku "Free" `
        -Location $args[2]
}
$stage2 += $job.Id


Process_Jobs -idArray $stage2
$storageAccount = Get-AzStorageAccount `
    -ResourceGroupName $resourceGroupName `
    -Name $storageAccountName
$storageContext = $storageAccount.Context
$websiteUrl = $storageAccount.PrimaryEndpoints.Web


#----------------------------------------------------------------#
#   Stage 3                                                      #
#----------------------------------------------------------------#


$stage3 = @()


# Create Cosmos Database
Write-Host Creating CosmosDB Database...
$cosmosDatabaseProperties = @{
    "resource" = @{ "id" = $cosmosDatabaseName };
    "options"  = @{ "Throughput" = 500 }
} 
$cosmosResourceName = $cosmosAccountName + "/sql/" + $cosmosDatabaseName
$job = Start-Job -ArgumentList $resourceGroupName, $cosmosResourceName, ($cosmosDatabaseProperties | ConvertTo-Json), $credentials -ScriptBlock {
    Connect-AzAccount -Credential $args[3]
    New-AzResource `
        -ResourceType "Microsoft.DocumentDb/databaseAccounts/apis/databases" `
        -ApiVersion "2015-04-08" `
        -ResourceGroupName $args[0] `
        -Name $args[1] `
        -PropertyObject ($args[2] | ConvertFrom-Json) `
        -Force
}
$stage3 += $job.Id


# Create Storage Containers
Write-Host Creating blob containers...
$storageContainerNames = @($storageContainerW2, $storageContainerW2Training, $storageContainerFinancial, $storageContainerFinancialTraining)
foreach ($containerName in $storageContainerNames) {
    $job = Start-Job -ArgumentList $resourceGroupName, $storageAccountName, $containerName, $credentials -ScriptBlock {
        Connect-AzAccount -Credential $args[3]
        $ErrorActionPreference = "Stop"
        $storageAccount = Get-AzStorageAccount `
            -ResourceGroupName $args[0] `
            -Name $args[1]
        $storageContext = $storageAccount.Context
        try {
            Get-AzStorageContainer `
                -Name $args[2] `
                -Context $storageContext
        }
        catch {
            new-AzStoragecontainer `
                -Name $args[2] `
                -Context $storageContext `
                -Permission container
        }
    }
    $stage3 += $job.Id
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
    $job = Start-Job -ArgumentList $resourceGroupName, $location, $name, ($functionAppSettings | ConvertTo-Json), $storageAccountName, $filepath, $credentials -ScriptBlock {
        Connect-AzAccount -Credential $args[6]
        New-AzResource `
            -ResourceGroupName $args[0] `
            -Location $args[1] `
            -ResourceName $args[2] `
            -ResourceType "microsoft.web/sites" `
            -Kind "functionapp" `
            -Properties ($args[3] | ConvertFrom-Json) `
            -Force

        $storageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $args[0] -AccountName $args[4]).Value[0]
        $storageAccountName = $args[4]
        $storageAccountConnectionString = "DefaultEndpointsProtocol=https;AccountName=$storageAccountName;AccountKey=$($storageAccountKey)"
        $functionAppSettings = @{
            AzureWebJobsDashboard       = $storageAccountConnectionString;
            AzureWebJobsStorage         = $storageAccountConnectionString;
            FUNCTION_APP_EDIT_MODE      = "readwrite";
            FUNCTIONS_EXTENSION_VERSION = "~2";
            FUNCTIONS_WORKER_RUNTIME    = "dotnet";
        }

        # Configure Function App
        Write-Host Configuring $args[2]"..."
        Set-AzWebApp `
            -Name $args[2] `
            -ResourceGroupName $args[0] `
            -AppSettings $functionAppSettings 

        # Deploy Function To Function App
        Write-Host Deploying $args[2]"..."
        $deploymentCredentials = Invoke-AzResourceAction `
            -ResourceGroupName $args[0] `
            -ResourceType Microsoft.Web/sites/config `
            -ResourceName ($args[2] + "/publishingcredentials") `
            -Action list `
            -ApiVersion 2015-08-01 `
            -Force
        $username = $deploymentCredentials.Properties.PublishingUserName
        $password = $deploymentCredentials.Properties.PublishingPassword 
        $name = $args[2]
        $apiUrl = "https://$($name).scm.azurewebsites.net/api/zipdeploy"
        $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username, $password)))
        $userAgent = "powershell/1.0"
        Invoke-RestMethod `
            -Uri $apiUrl `
            -Headers @{Authorization = ("Basic {0}" -f $base64AuthInfo) } `
            -UserAgent $userAgent `
            -Method POST `
            -InFile $args[5] `
            -ContentType "multipart/form-data"
    }
    $stage3 += $job.Id
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
    $job = Start-Job -ArgumentList $resourceGroupName, $connectionName, $templateFilePath, $parametersFilePath, $credentials -ScriptBlock {
        Connect-AzAccount -Credential $args[4]
        New-AzResourceGroupDeployment `
            -ResourceGroupName $args[0] `
            -Name $args[1] `
            -TemplateFile $args[2] `
            -TemplateParameterFile $args[3]
    }
    $stage3 += $job.Id
}


Process_Jobs -idArray $stage3


#----------------------------------------------------------------#
#   Stage 4                                                      #
#----------------------------------------------------------------#


$stage4 = @()


# Create Cosmos Containers
Write-Host Creating CosmosDB Containers...
$cosmosContainerNames = @($cosmosContainerFinancial, $cosmosContainerFinancialEnriched, 
    $cosmosContainerW2, $cosmosContainerW2Enriched, $cosmosContainerProcessed)
foreach ($containerName in $cosmosContainerNames) {
    $containerResourceName = $cosmosAccountName + "/sql/" + $cosmosDatabaseName + "/" + $containerName
    $job = Start-Job -ArgumentList $resourceGroupName, $containerResourceName, $containerName, $credentials `
        -ScriptBlock {
        Connect-AzAccount -Credential $args[3]
        $cosmosContainerProperties = @{
            "resource" = @{
                "id"           = $args[2]; 
                "partitionKey" = @{
                    "paths" = @("/id"); 
                    "kind"  = "Hash"
                }; 
            };
            "options"  = @{ }
        }
        New-AzResource `
            -ResourceType "Microsoft.DocumentDb/databaseAccounts/apis/databases/containers" `
            -ApiVersion "2015-04-08" `
            -ResourceGroupName $args[0] `
            -Name $args[1] `
            -PropertyObject $cosmosContainerProperties `
            -Force 
    }
    $stage4 += $job.Id
}


# Populate Angular Configuration File
$angularConfig = Get-Content $angularConfigFilePath | ConvertFrom-Json
$angularConfig.cosmosAccount = $cosmosAccountName
$angularConfig.storageAccount = $storageAccountName
$angularConfig.cosmosAccessKey = $cosmosAccessKey.primaryMasterKey
$angularConfig.searchAccount = $cognitiveSearchName
$angularConfig.searchKey = (Get-AzSearchQueryKey -ResourceGroupName $resourceGroupName -ServiceName $cognitiveSearchName).Key
$angularConfig | ConvertTo-Json | Out-File $angularConfigFilePath


# Upload Blobs And Training Data
Write-Host Uploading blobs and training documents...`n
$trainingInfo = @(
    (($blobsFilePath + "w2-form/"), $storageContainerW2), `
    (($blobsFilePath + "financial-table/"), $storageContainerFinancial), `
    (($trainingFilePath + "w2-form/"), $storageContainerW2Training), `
    (($trainingFilePath + "financial-table/"), $storageContainerFinancialTraining),
    (($blobsFilePath + "angular-app/"), "`$web")
)
foreach ($info in $trainingInfo) {
    $filePath = $info[0]
    $containerName = $info[1]
    $files = Get-ChildItem $filePath
    $job = Start-Job -ArgumentList $filepath, $files, $containerName, $resourceGroupName, $storageAccountName, $credentials -ScriptBlock {
        Connect-AzAccount -Credential $args[5]
        foreach ($file in $args[1]) {
            Write-Host - Uploading $file.Name
            $storageAccount = Get-AzStorageAccount `
                -ResourceGroupName $args[3] `
                -Name $args[4]
            $storageContext = $storageAccount.Context
            if ($file.Name -eq "assets") {
                Get-ChildItem ($args[0] + $file.Name) | set-AzStorageblobcontent `
                    -Container $args[2] `
                    -Blob 'config.json' `
                    -Context $storageContext `
                    -Force
                continue
            }
            if (($file | Select-Object Extension).Extension -eq '.html') {
                set-AzStorageblobcontent `
                    -File ($args[0] + $file.Name) `
                    -Container $args[2] `
                    -Blob $file.Name `
                    -Context $storageContext `
                    -Properties @{"ContentType" = "text/html" } `
                    -Force
                continue
            }
            if (($file | Select-Object Extension).Extension -eq '.css') {
                set-AzStorageblobcontent `
                    -File ($args[0] + $file.Name) `
                    -Container $args[2] `
                    -Blob $file.Name `
                    -Context $storageContext `
                    -Properties @{"ContentType" = "text/css" } `
                    -Force
                continue
            }
            set-AzStorageblobcontent `
                -File ($args[0] + $file.Name) `
                -Container $args[2] `
                -Blob $file.Name `
                -Context $storageContext `
                -Force
        }
    }
    $stage4 += $job.Id
}


Process_Jobs -idArray $stage4


#----------------------------------------------------------------#
#   Stage 5                                                      #
#----------------------------------------------------------------#


$stage5 = @()


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
    $job = Start-Job -ArgumentList $containerName, $formRecognizeHeader, $formRecognizerTrainUrl, $resourceGroupName, $storageAccountName, $credentials -ScriptBlock {
        Connect-AzAccount -Credential $args[5]
        $storageAccount = Get-AzStorageAccount `
            -ResourceGroupName $args[3] `
            -Name $args[4]
        $storageContext = $storageAccount.Context
        $formRecognizerModels = @{ }
        $storageContainerUrl = (Get-AzStorageContainer -Context $storageContext -Name $args[0]).CloudBlobContainer.Uri.AbsoluteUri
        $body = "{`"source`": `"$($storageContainerUrl)`"}"
        $response = Invoke-RestMethod -Method Post -Uri $args[2] -ContentType "application/json" -Headers $args[1] -Body $body
        $response
        $formRecognizerModels[$args[0]] = $response.modelId
        return $formRecognizerModels
    }
    $stage5 += $job.Id
}

Write-Host `nResults:
foreach ($id in $stage5) {
    Wait-Job -Id $id
    $modelMap = (Receive-Job -Id $id -Keep)[-1]
    foreach ($key in $modelMap.Keys) {
        $formRecognizerModels[$key] = $modelMap[$key]
        break
    }
    Receive-Job -Id $id
    Remove-Job -Id $id
}


#----------------------------------------------------------------#
#   Stage 6                                                      #
#----------------------------------------------------------------#


$stage6 = @()


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
$job = Start-Job -ArgumentList $resourceGroupName, $logicApp1Name, $logicApp1TemplateFilePath, $logicApp1ParametersFilePath, $credentials -ScriptBlock {
    Connect-AzAccount -Credential $args[4]
    New-AzResourceGroupDeployment `
        -ResourceGroupName $args[0] `
        -Name $args[1] `
        -TemplateFile $args[2] `
        -TemplateParameterFile $args[3]
}
$stage6 += $job.Id


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
$job = Start-Job -ArgumentList $resourceGroupName, $logicApp2Name, $logicApp2TemplateFilePath, $logicApp2ParametersFilePath, $credentials -ScriptBlock {
    Connect-AzAccount -Credential $args[4]
    New-AzResourceGroupDeployment `
        -ResourceGroupName $args[0] `
        -Name $args[1] `
        -TemplateFile $args[2] `
        -TemplateParameterFile $args[3]
}
$stage6 += $job.Id


# Configure Cognitive Search Service
Write-Host Configuring Cognitive Search Service...
$job = Start-Job -ArgumentList $resourceGroupName, $cognitiveSearchName, $location, $storageAccountName, $storageContainerW2, $storageContainerFinancial, `
    $dataSourceNameW2, $dataSourceNameFinancial, $indexName, $skillsetName, $indexerNameW2, $indexerNameFinancial, $credentials `
    -ScriptBlock {
    Connect-AzAccount -Credential $args[12]
    $resourceGroupName = $args[0]
    $cognitiveSearchName = $args[1]
    $storageAccountName = $args[3]
    $storageContainerW2 = $args[4]
    $storageContainerFinancial = $args[5]
    $dataSourceNameW2 = $args[6]
    $dataSourceNameFinancial = $args[7]
    $indexName = $args[8]
    $skillsetName = $args[9]
    $indexerNameW2 = $args[10]
    $indexerNameFinancial = $args[11]

    # Create Cognitive Search Data Source
    Write-Host Creating cognitive search data sources...
    $cognitiveSearchKey = (Get-AzSearchAdminKeyPair -ResourceGroupName $resourceGroupName -ServiceName $cognitiveSearchName).Primary
    $dataSourceHeader = @{
        "api-key" = $cognitiveSearchKey
    }
    $storageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $resourceGroupName -AccountName $storageAccountName).Value[0]
    $storageAccountConnectionString = "DefaultEndpointsProtocol=https;AccountName=$storageAccountName;AccountKey=$($storageAccountKey)"
    $dataSourceUrl = "https://" + $cognitiveSearchName + ".search.windows.net/datasources?api-version=2019-05-06"
    $dataSourceInfo = @(
        ($dataSourceNameW2, $storageContainerW2), 
        ($dataSourceNameFinancial, $storageContainerFinancial));
    foreach ($info in $dataSourceInfo) {
        $dataSourceName = $info[0]
        $container = $info[1]
        $dataSourceBody = @{
            "name"        = $dataSourceName
            "type"        = "azureblob"
            "credentials" = @{"connectionString" = $storageAccountConnectionString }
            "container"   = @{ "name" = $container }
        } | ConvertTo-Json
        try {
            Invoke-RestMethod `
                -Method Post `
                -Uri $dataSourceUrl `
                -Headers $dataSourceHeader `
                -Body $dataSourceBody `
                -ContentType "application/json"
        }
        catch { }
    }


    # Create Cognitive Search Index
    Write-Host Creating cognitive search index...
    $indexHeader = @{
        'api-key'      = $cognitiveSearchKey
        'Content-Type' = 'application/json' 
    }
    $indexBody = @{
        "name"   = $indexName
        "fields" = @(
            @{
                "name"       = "id";
                "type"       = "Edm.String";
                "key"        = $true;
                "searchable" = $true;
                "filterable" = $true;
                "facetable"  = $false;
                "sortable"   = $true
            },
            @{
                "name"       = "content";
                "type"       = "Edm.String";
                "sortable"   = $false;
                "searchable" = $true;
                "filterable" = $false;
                "facetable"  = $false
            },
            @{
                "name"       = "keyPhrases";
                "type"       = "Collection(Edm.String)";
                "searchable" = $true;
                "sortable"   = $false;
                "filterable" = $true;
                "facetable"  = $true
            },
            @{
                "name"       = "organizations";
                "type"       = "Collection(Edm.String)";
                "searchable" = $true;
                "sortable"   = $false;
                "filterable" = $true;
                "facetable"  = $true
            },
            @{
                "name"       = "persons";
                "type"       = "Collection(Edm.String)";
                "searchable" = $true;
                "sortable"   = $false;
                "filterable" = $true;
                "facetable"  = $true
            },
            @{
                "name"       = "locations";
                "type"       = "Collection(Edm.String)";
                "searchable" = $true;
                "sortable"   = $false;
                "filterable" = $true;
                "facetable"  = $true
            },
            @{
                "name"       = "metadata_storage_path";
                "type"       = "Edm.String";
                "searchable" = $true;
                "sortable"   = $false;
                "filterable" = $false;
                "facetable"  = $false
            },
            @{
                "name"       = "metadata_storage_name";
                "type"       = "Edm.String";
                "searchable" = $true;
                "sortable"   = $false;
                "filterable" = $false;
                "facetable"  = $false
            }
        )
    } | ConvertTo-Json
    $indexUrl = "https://" + $cognitiveSearchName + ".search.windows.net/indexes?api-version=2019-05-06"
    try {
        Invoke-RestMethod `
            -Method Post `
            -Uri $indexUrl `
            -Headers $indexHeader `
            -Body $indexBody `
            -ContentType "application/json"
    }
    catch { }


    # Create Cognitive Search Skillset
    Write-Host Creating cognitive search skillset...
    $skillsetHeader = @{
        'api-key'      = $cognitiveSearchKey
        'Content-Type' = 'application/json' 
    }
    $skillsetBody = '
{
    "name": "' + $skillsetName + '",
    "skills": [
        {
            "@odata.type": "#Microsoft.Skills.Vision.OcrSkill",
            "name": "#8",
            "description": null,
            "context": "/document/normalized_images/*",
            "textExtractionAlgorithm": "printed",
            "lineEnding": "Space",
            "defaultLanguageCode": "en",
            "detectOrientation": true,
            "inputs": [
                {
                    "name": "image",
                    "source": "/document/normalized_images/*",
                    "sourceContext": null,
                    "inputs": []
                }
            ],
            "outputs": [
                {
                    "name": "text",
                    "targetName": "text"
                }
            ]
        },
        {
            "@odata.type": "#Microsoft.Skills.Text.EntityRecognitionSkill",
            "name": "#1",
            "description": null,
            "context": "/document",
            "categories": [
                "Person",
                "Organization",
                "Location"
            ],
            "defaultLanguageCode": "en",
            "minimumPrecision": null,
            "includeTypelessEntities": null,
            "inputs": [
                {
                    "name": "text",
                    "source": "/document/mergedText",
                    "sourceContext": null,
                    "inputs": []
                }
            ],
            "outputs": [
                {
                    "name": "persons",
                    "targetName": "persons"
                },
                {
                    "name": "organizations",
                    "targetName": "organizations"
                },
                {
                    "name": "locations",
                    "targetName": "locations"
                }
            ]
        },
        {
            "@odata.type": "#Microsoft.Skills.Text.KeyPhraseExtractionSkill",
            "name": "#2",
            "description": null,
            "context": "/document",
            "defaultLanguageCode": "en",
            "maxKeyPhraseCount": null,
            "inputs": [
                {
                    "name": "text",
                    "source": "/document/mergedText",
                    "sourceContext": null,
                    "inputs": []
                }
            ],
            "outputs": [
                {
                    "name": "keyPhrases",
                    "targetName": "keyPhrases"
                }
            ]
        },
        {
            "@odata.type": "#Microsoft.Skills.Text.MergeSkill",
            "name": "#4",
            "description": null,
            "context": "/document",
            "insertPreTag": " ",
            "insertPostTag": " ",
            "inputs": [
                {
                    "name": "text",
                    "source": "/document/content",
                    "sourceContext": null,
                    "inputs": []
                },
                {
                    "name": "itemsToInsert",
                    "source": "/document/normalized_images/*/text",
                    "sourceContext": null,
                    "inputs": []
                },
                {
                    "name": "offsets",
                    "source": "/document/normalized_images/*/contentOffset",
                    "sourceContext": null,
                    "inputs": []
                }
            ],
            "outputs": [
                {
                    "name": "mergedText",
                    "targetName": "mergedText"
                }
            ]
        }
    ]
}'
    $skillsetUrl = "https://" + $cognitiveSearchName + ".search.windows.net/skillsets/" + $skillsetName + "?api-version=2019-05-06"
    Invoke-RestMethod `
        -Uri $skillsetUrl `
        -Headers $skillsetHeader `
        -Method Put `
        -Body $skillsetBody


    # Create Cognitive Search Indexer
    Write-Host Creating cognitive search indexer...
    $indexerHeader = @{
        "api-key" = $cognitiveSearchKey
    }
    $information = @(
        ($indexerNameW2, $dataSourceNameW2),
        ($indexerNameFinancial, $dataSourceNameFinancial)
    )
    foreach ($info in $information) {
        $indexerName = $info[0]
        $datasource = $info[1]

        $indexerUrl = "https://" + $cognitiveSearchName + ".search.windows.net/indexers/" + $indexerName + "?api-version=2019-05-06"
        $indexerBody = '
        {
            "dataSourceName": "' + $datasource + '",
            "targetIndexName": "' + $indexName + '",
            "skillsetName": "' + $skillsetName + '",
            "fieldMappings": [
                {
                    "sourceFieldName": "metadata_storage_path",
                    "targetFieldName": "doc_id",
                    "mappingFunction": {
                        "name": "base64Encode"
                    }
                },
                {
                    "sourceFieldName": "metadata_storage_path",
                    "targetFieldName": "doc_path"
                },
                {
                    "sourceFieldName": "metadata_storage_name",
                    "targetFieldName": "doc_name"
                }
            ],
            "outputFieldMappings": [
                {
                    "sourceFieldName": "/document/organizations",
                    "targetFieldName": "organizations"
                },
                {
                    "sourceFieldName": "/document/persons",
                    "targetFieldName": "persons"
                },
                {
                    "sourceFieldName": "/document/locations",
                    "targetFieldName": "locations"
                },
                {
                    "sourceFieldName": "/document/keyPhrases",
                    "targetFieldName": "keyPhrases"
                }
            ],
            "parameters": {
                "batchSize": 1,
                "maxFailedItems": -1,
                "maxFailedItemsPerBatch": -1,
                "configuration": {
                    "dataToExtract": "contentAndMetadata",
                    "imageAction": "generateNormalizedImages"
                }
            }
        }'
        Invoke-RestMethod `
            -Method Put `
            -Uri $indexerUrl `
            -Headers $indexerHeader `
            -Body $indexerBody `
            -ContentType "application/json"
    }
}
$stage6 += $job.Id


Process_Jobs -idArray $stage6


#----------------------------------------------------------------#
#   Stage 7                                                      #
#----------------------------------------------------------------#


$stage7 = @()


# Process Documents
Write-Host  Processing documents...`n
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
    Write-Host `n$containerName`n  
    $container = Get-AzStorageContainer -Name $containerName -Context $storageContext | Get-AzStorageBlob
    foreach ($file in $container) { 
        $fileName = $file.Name
        Write-Host Deploying $fileName"..."  
        $body = @{
            "recordId" = ("/" + $containerName + "/" + $file.Name);
            "modelId"  = $model;
            "formType" = $formType
        } | ConvertTo-Json
        $job = Start-Job -ArgumentList $logicAppTriggerUri, ($body | ConvertTo-Json), $credentials -ScriptBlock {
            Connect-AzAccount -Credential $args[2]
            Invoke-RestMethod `
                -Uri $args[0] `
                -Method Post `
                -ContentType "application/json" `
                -Body ($args[1] | ConvertFrom-Json) 
        }
        $stage7 += $job.Id
    }
}


Process_Jobs -idArray $stage7


#----------------------------------------------------------------#
#   Stage 8                                                      #
#----------------------------------------------------------------#


$stage8 = @()


Write-Host `nAnalyzing documents:`n  
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
    $job = Start-Job -ArgumentList $logicAppTriggerUri, ($body | ConvertTo-Json), $credentials -ScriptBlock {
        Connect-AzAccount -Credential $args[2]
        Invoke-RestMethod `
            -Uri $args[0] `
            -Method Post `
            -ContentType "application/json" `
            -Body ($args[1] | ConvertFrom-Json) 
    }
    $stage8 += $job.Id
}


Process_Jobs -idArray $stage8


Write-Host Deployment complete.`n
Write-Host Navigate to: $websiteUrl
Start-Process $websiteUrl
