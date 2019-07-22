* [Introduction](#introduction)
* [Getting Started](#getting-started)
* [Build](#build)
* [Tear Down](#tear-down)


# Introduction 
The Document Integration Platform  (DIP) is a framework to quickly build AI solutions for document intensive use cases that requires a “skilled reviewer”, a "skilled reviewer" being a resources that can review, identify or possibly perform a tasks on said documents based on certain criteria.

# Getting Started

## Prerequisites

* Azure subscription. If you don't have one, create a [free account](https://azure.microsoft.com/en-us/free/?WT.mc_id=A261C142F) before continuing.

* [PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-6) 5.1 or higher on Windows, or PowerShell Core 6.x and later on all platforms.

* [Az Powershell Module](https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-2.4.0)
  * You can't have both the AzureRM and Az modules installed for PowerShell 5.1 for Windows at the same time. If you need to keep AzureRM available on your system, install the Az module for [PowerShell Core 6.x](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-windows?view=powershell-6) or later.

* A subscription key for [Form Recognizer](https://azure.microsoft.com/en-us/services/cognitive-services/form-recognizer/). Since Form Recognizer is still in Preview, access must be [requested](https://forms.office.com/Pages/ResponsePage.aspx?id=v4j5cvGGr0GRqy180BHbRyj5DlT4gqZKgEsfbkRQK5xUMjZVRU02S1k4RUdLWjdKUkNRQVRRTDg1NC4u). Once access has been granted, create a form recognizer service and obtain the key.

# Build

* Run ./setup/scripts/setup.ps1.

* A Microsoft login screen should appear. Sign in with the Azure account you want the application built in.
  
* The powershell script will prompt you for:
  * Subscription Id: provide the id for the subscription you want the Azure resources created in.  
  * Form Recognizer key: provide the key for the Form Recognizer service you created.


