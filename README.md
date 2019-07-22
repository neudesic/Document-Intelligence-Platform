# Document Integration Platform

* [Introduction](#introduction)
* [Prerequisites](#prerequisites)
* [Build](#build)
* [Cleanup](#cleanup)

## Introduction 
The Document Integration Platform  (DIP) is a framework to quickly build AI solutions for document intensive use cases that require a “skilled reviewer”, a "skilled reviewer" being a resources that can review, identify or possibly perform a tasks on said documents based on certain criteria.

## Prerequisites

* Azure subscription. If you don't have one, create a [free account](https://azure.microsoft.com/en-us/free/?WT.mc_id=A261C142F) before continuing.

* [PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-6) 5.1 or higher on Windows, or PowerShell Core 6.x and later on all platforms.

* [Az Powershell Module](https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-2.4.0)
  * You can't have both the AzureRM and Az modules installed for PowerShell 5.1 for Windows at the same time. If you need to keep AzureRM available on your system, install the Az module for [PowerShell Core 6.x](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-windows?view=powershell-6) or later.

* A subscription to [Form Recognizer](https://azure.microsoft.com/en-us/services/cognitive-services/form-recognizer/). Since Form Recognizer is still in Preview, access must be [requested](https://forms.office.com/Pages/ResponsePage.aspx?id=v4j5cvGGr0GRqy180BHbRyj5DlT4gqZKgEsfbkRQK5xUMjZVRU02S1k4RUdLWjdKUkNRQVRRTDg1NC4u). Once access has been granted, continue to the [Build](#build) section.

## Build

* Depending on your powershell settings, you will likely have to run the following command before running the setup script:

       Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

* Run ./setup/scripts/setup.ps1.

* A Microsoft login screen should appear. Sign in with the Azure account you want the application built in. NOTE: the login screen occasionally appears behind other windows.
  
* The powershell script will prompt you for a subscription Id. Provide the id to the subscription you want the Azure resources created in.

## Cleanup

* Depending on your powershell settings, you will likely have to run the following command before running the cleanup script:

       Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

* Run ./setup/scripts/cleanup.ps1.

* The powershell script will prompt you for:
  * Subscription Id: provide the id for the subscription you want the Azure resources deleted from.  
  * Resource Group: the name of the resource group you want deleted.
  * Force deletion:
    * If you would like the script to delete the entire resource group without asking for your confirmation, enter "Y".
    * If you would like the script to prompt you to confirm the deletion of each individual resource, enter "N".
