# Document Intelligence Platform

* [Introduction](#introduction)
* [Overview](#overview)
  * [Example Use Case](#example-use-case)
    * [Problem](#problem)
    * [Solution](#solution)
  * [DIP Specifics](#dip-specifics)
* [Build](#build)
  * [Prerequisites](#prerequisites)
  * [Run](#run)
  * [Results](#results)
  * [Cleanup](#cleanup)

# Introduction 

* The Document Intelligence Platform (DIP) is a framework to quickly build AI solutions for document intensive use cases that require a “skilled reviewer”, a "skilled reviewer" being a resource that can review, identify and perform tasks on said documents based on certain criteria.

* The Document Intelligence Platform included in this repository processes W-2 forms and financial tables. However, it can be **customized** for a variety of use cases.

![](https://i.imgur.com/aoPWp7f.png)

# Overview

## Example Use Case

### Problem

Jim is a mortgage loan officer. He is responsible for processing mortgage applications.
In order to do so Jim must:

* Organize and validate a variety of documents

* Create company standard KPIs

* Calculate a risk score

* Approve or reject the application

Jim is skilled at what he does. His time is best spent analyzing relevant and organized information. However Jim faces a major challenge. The majority of his time is spent ingesting, organizing and extracting information from documents.

### Solution

Microsoft Azure AI, Machine Learning, and Storage can help address this challenge by automating the:

* Classification of documents

* Validation of documents

* Extraction of relevant information

* Storage of information

Setting up such a solution involves three major stages:

![](https://imgur.com/AqNgzbz.png)

1. Setting up the Azure platform. This stage is relatively simple and does not require too much technical knowledge.

2. Configuring multiple Azure services and training AI models. This step is more involved and requires moderate technical knowledge.

3. Building the pipeline: bringing everything together to form a complete and seamless solution. This stage is sophisticated and demands technical expertise.

The complete solution is a **Cognitive Solution**. A cognitive solution transforms unstructured data into insights and actions that solve business problems. The unstructured data goes through ingestion, enrichment, analysis, and insights.
<br>  
![](https://imgur.com/UIcGJTa.png)
<br>


## DIP Specifics

The Document Intelligence Platform (**DIP**) is a prime example of a Cognitive Solution.

* Automates the setup and configuration of numerous Azure services.
  * Resource providers
  * Resource group
  * Storage account / containers
  * CosmosDB account / database / collections
  * Form Recognizer service / models
  * App service plan
  * DocumentDB / Blob api connections
  * Function Apps
  * Logic Apps

* Receives unstructured data as input: financial tables and W2 forms.

* Ingestion
  * Uploads the unstructured data to blob containers within cloud storage.
* Enrichment
  * Utilizes AI models to extract key-value pairs, text, and tables from the documents. Shapes the data and stores it in CosmosDB database collections.
* Analysis
  * Processes the data from the various documents of a single applicant and produces new metrics such as spending forecasts and ratings.
* Representation:
  * Deploys a website which displays the resulting information in a 

# Build

## Prerequisites

* Azure subscription. If you don't have one, create a [free account](https://azure.microsoft.com/en-us/free/?WT.mc_id=A261C142F) before continuing.

* [PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-6) 5.1 or higher on Windows, or PowerShell Core 6.x and later on all platforms.

* [Az Powershell Module](https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-2.4.0)

      Install-Module -Name Az -AllowClobber -Scope CurrentUser
  * You can't have both the AzureRM and Az modules installed for PowerShell 5.1 for Windows at the same time. If you need to keep AzureRM available on your system, install the Az module for [PowerShell Core 6.x](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-windows?view=powershell-6) or later.

* [Az Search](https://docs.microsoft.com/en-us/azure/search/search-manage-powershell#import-azsearch) (Azure Search module for powershell)

      Install-Module -Name Az.Search

* A subscription to [Form Recognizer](https://azure.microsoft.com/en-us/services/cognitive-services/form-recognizer/). Since Form Recognizer is still in Preview, access must be [requested](https://forms.office.com/Pages/ResponsePage.aspx?id=v4j5cvGGr0GRqy180BHbRyj5DlT4gqZKgEsfbkRQK5xUMjZVRU02S1k4RUdLWjdKUkNRQVRRTDg1NC4u). Once access has been granted, continue to the [Run](#run) section.

## Run

* Depending on your powershell settings, you will likely have to run the following command before running the setup script:

       Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

* Run ./setup/scripts/setup.ps1.

* A Microsoft login screen should appear. Sign in with the Azure account you want the application built in. NOTE: the login screen occasionally appears behind other windows.
  
* The powershell script will prompt you for a subscription Id. Provide the id to the subscription you want the Azure resources created in.

## Results

* Upon completion, the script will automatically navigate to the following website:

![](https://i.imgur.com/LH06Brj.png)

* Click the "Load Applicants" button to begin using the web app.


## Cleanup

* Depending on your powershell settings, you will likely have to run the following command before running the cleanup script:

       Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

* Run ./setup/scripts/cleanup.ps1.

* The powershell script will prompt you for:
  * Subscription Id: provide the id for the subscription you want the Azure resources deleted from.  
  * Force deletion:
    * If you would like the script to delete the entire resource group without asking for your confirmation, enter "Y".
    * If you would like the script to prompt you to confirm the deletion of each individual resource, enter "N".
