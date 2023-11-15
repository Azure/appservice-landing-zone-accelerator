<!-- markdownlint-disable -->
## Contents
<!-- markdownlint-restore -->

- [Contents](#contents)
- [Contributing](#contributing)
- [GitHub Operations, Conventions and other Standards](#github-operations-conventions-and-other-standards)
  - [GitHub Basics](#github-basics)
  - [Folder Structure and Naming Conventions](#folder-structure-and-naming-conventions)
  - [Forking the Repository](#forking-the-repository)
  - [Branch Naming Standards](#branch-naming-standards)
  - [Commit Standards (optional)](#commit-standards-optional)
- [Style Guide and coding conventions](#style-guide-and-coding-conventions)
  - [Bicep Best Practices and Conventions](#bicep-best-practices-and-conventions)
  - [Terraform Best Practices and Conventions](#terraform-best-practices-and-conventions)
- [Issue Tracker](#issue-tracker)
- [Pull Request Process](#pull-request-process)

---

## Contributing

This project welcomes contributions and suggestions. Most contributions require you to agree to a Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the Microsoft Open Source Code of Conduct. For more information see the Code of Conduct FAQ or contact opencode@microsoft.com with any additional questions or comments.

The rest of this document outlines a few important notes/guidelines to help us to start contributing to this *Landing Zone Accelerator* project effectively.

## GitHub Operations, Conventions and other Standards

### GitHub Basics

The following guides provide basic knowledge for understanding Git command usage and the workflow of GitHub.

- [Introduction to version control with Git](https://docs.microsoft.com/learn/paths/intro-to-vc-git/)
- [Git Cheat Sheet](https://education.github.com/git-cheat-sheet-education.pdf)
- [GitHub Flow](https://guides.github.com/introduction/flow/)

### Folder Structure and Naming Conventions

- Github uses ASCII for ordering files and folders. For consistent ordering create all files and folders in **lowercase**. The only exception to this guideline is the *common supporting files* such as README.md, CONTRIBUTING.md etc files, that should be in the format **UPPERCASE.lowercase**. Remember that there are operating systems that handle files with different casing as distinct files, so we need to avoid these kind of conflicts. 
- Avoid **camelCase** for files and folders consisting of two or more words. Use only lowercase and append words with dashes, i.e. **`folder-name-one`** and **not** `folderNameOne` 

> NOTE: the aforementioned rules can be overridden, if any Language Coding Styles or Guidelines instruct the usage of different conventions

Below you can see the selected folder structure for the project. The main folders and a brief description of their purpose is as follows:

- **docs**
  The *docs* folder contains two subfolders; **design-areas** and **media**.
  - The **design-areas** subfolder contains the relevant documentation. 
  - The **media** subfolder  will contain images or other media file types used in the README.md files. Folder structure inside that subfolder is optional and free to the grouping desires of every author. For instance if you create the README.md file describing the architecture of the *scenario1* scenario, and *scenario1* sub-folder may be created to group all supporting media files together. In the same context, if the *Design Area* documents (as described above) need some supporting media material, we can add them in this subfolder or create a new subfolder, named *design-areas* and add them all there, for grouping puproses
  
- **sample-apps**
  This folder may contain one or more subfolders, depending on the selected sample applications that will be created to serve as smoke tests or best-practices examples using the specific Landing Zone Accelerator artifacts. Folder structure inside each sample application sub-folder is free. 
- **scenarios**
  This folder can contain one or more scenarios (currently contains secure-baseline), but in the future more scenarios might be added. Each scenario has the following (minimum) folder structure
  - (scenario1)\bicep
    Stores Azure Bicep related deployment scripts and artifacts for the given scenario. Contains also a README.md file that gives detailed instructions on how to use the specific IaC artifacts and scripts, to help end users parameterize and deploy successfully the LZA scenario
  - (scenario1)\terraform
    Stores terraform related deployment scripts and artifacts (if any) for the given scenario. Contains also a README.md file that gives detailed instructions on how to use the specific IaC artifacts and scripts, to help end users parameterize and deploy successfully the LZA scenario
  - (scenario1)\README.md
    Outlines the details of the specific scenario (architecture, resources to be deployed, business case scenarios etc) for the given scenario
  - *shared* 
    To avoid duplication of code modules/artifacts, we store all scripts, modules or coding artifacts in general, in this subfolder. This folder can have more depth, i.e. one folder for every deployment method (i.e. bicep, terraform etc) as shown below in the sample folder structure. Contains also a README.md file that gives details of the shared modules/scripts to help end-users understand their functionality. 

``` bash
docs
├── design-areas
│   ├── **/*.md
├── media
|   ├── scenario1
│   |   ├── **/*.png
│   |   ├── **/*.vsdx
sample-apps
├── sample-app1
├── sample-app2
scenarios
├── scenario1
│   ├── bicep
│   |   ├── **/*.azcli
│   |   ├── **/*.bicep
│   |   ├── **/*.json
│   |   ├── README.md
│   ├── terraform
│   ├── README.md
├── scenario2
│   ├── bicep
│   |   ├── **/*.azcli
│   |   ├── **/*.bicep
│   |   ├── **/*.json
│   |   ├── README.md
│   ├── terraform
│   ├── README.md
├── shared
│   ├── bicep
│   │   ├── modules
│   ├── terraform
│   │   ├── modules
│   ├── vm-script.ps1
README.md
CONTIBUTING.md
.gitignore
```

### Forking the Repository

Unless you are working with multiple contributors on the same file, we ask that you fork the repository and submit your pull request from there. The following guide explains how to fork a GitHub repo.

- [Contributing to GitHub projects](https://guides.github.com/activities/forking/).

### Branch Naming Standards

For branches, use the following prefixes depending on which is most applicable to the work being done:
| Prefix    | Purpose | 
|-------------|-----------|
|fix/|Any task related to a bug or minor fix|
|feat/|Any task related to a new feature of the codebase|
|chore/|Any basic task that involves minor updates that are not bugs|
|docs/|Any task pertaining to documentation|
|ci/|Any task pertaining to workflow changes |
|test/|Any task pertaining to testing updates |

### Commit Standards (optional)

Prefixing the commits as described below, is **optional**, however is **highly encouraged**.  
For commits, use the following prefixes depending on which is most applicable to the changes:
| Prefix    | Purpose |
|-------------|-----------|
|fix:|Update to code base or bug|
|feat:|New feature added to code base|
|chore:|Basic task to update formatting or versions, etc.|
|docs:|New documentations or updates to documentation in Markdown file(s) |
|ci:|New workflow or updates to workflow(s) |
|test:|New tests or updates to testing framework(s) |

## Style Guide and coding conventions

A guide outlining the coding conventions and style guidelines that should be followed when contributing code to the repository is outlined below:

### Bicep Best Practices and Conventions

- The starting point for any deployment should be named **main.bicep**. This (usually) should be the main deployment file, scoped at *subscription* level, and it would call several sub-deployments, usually at the resource group scope.
  - The **main.bicep** file should be accompanied with a parameter file named **main.parameters.jsonc**. The benefit of the `*.jsonc` file extension is that you can use  inline comments (either `//` or `/* ... */`) in Visual Studio Code (otherwise you will get an error message saying "*Comments not permitted in JSON*"). [Bicep Parameter Files](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/parameter-files)
  - Details of using the deployment should be given in the README.md file. However if we need extra scripts to either deploy the bicep files or other functionality use a naming conventions as the following
    - deploy.main.sh: for bash-based script deploying the main.bicep
    - deploy.main.ps1: for powershell-based script deploying the main.bicep

- Do not include compiled versions of the bicep files (i.e. no `main.json ` files)

- Use strictly `camelCasing` for all elements like parameters, variables, resources, modules and outputs, and avoid prepending those elements in a [Hungarian Notation](https://en.wikipedia.org/wiki/Hungarian_notation) style.  
  
  **Bad practice examples that should be avoided:**

  ``` bicep
  \\ BAD PRACTICE param EXAMPLES
  param parVmSubnetAddressPrefix string
  param strVmSubnetAddressPrefix string

  \\ GOOD PRACTICE param EXAMPLES
  param vmSubnetAddressPrefix string

  \\ BAD PRACTICE variable EXAMPLES
  var varAppGwSubnetName = 'xyz'

  \\ GOOD PRACTICE variable EXAMPLES
  var appGwSubnetName = 'xyz'  

  \\ BAD PRACTICE output EXAMPLES
  output outAcrId string = acr.id
  output strAcrId string = acr.id
  output outStrAcrId string = acr.id

  \\ GOOD PRACTICE output EXAMPLES
  output acrId string = acr.id
  ```

  **Acceptable naming convention examples:**

    ``` bicep

  \\ GOOD PRACTICE param EXAMPLES
  param vmSubnetAddressPrefix string

  \\ GOOD PRACTICE variable EXAMPLES
  var appGwSubnetName = 'xyz'  

  \\ GOOD PRACTICE output EXAMPLES
  output acrId string = acr.id
  ```

- For **parameters and outputs**, avoid using extreme abbreviations, and stick to well known (de-facto) Azure resource abbreviations. Examples:
  - **expressRouteGwName**  instead of *erGwName*
  - **storageAccountName** instead of *stAccName*

- Bicep is a declarative language, which means the elements can appear in any order. In reality you can put parameter declarations anywhere in the template file, and the same you can do for resources, variables and outputs. However it is highly recommended that any bicep template file to adhere to the following order `Parameters > Variables > Resources/Modules > Outputs` as shown in the code snippet.

  ``` bicep
  targetScope = 'subscription'
  // ================ //
  // Parameters       //
  // ================ //

  @description('suffix that will be used to name the resources in a pattern like <resourceAbbreviation>-<workloadName>')
  param workloadName string

  @description('Required. The environment for which the deployment is being executed')
  @allowed([
    'dev'
    'uat'
    'prod'
    'dr'
  ])
  param environment string

  param resourceTags object = {}

  // ================ //
  // Variables        //
  // ================ //
  var tags = union({
    workloadName: workloadName
    environment: environment
  }, resourceTags)

  // ================ //
  // Resources        //
  // ================ //
  resource spokeResourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
    name: spokeResourceGroupName
    location: location
    tags: tags
  }

  // ================ //
  // Outputs          //
  // ================ //
  output spokeRgName string = spokeResourceGroup.name

  ```

- Use [parameter decorators](https://docs.microsoft.com/azure/azure-resource-manager/bicep/parameters#decorators) to ensure integrity of user inputs are complete and therefore enable successful deployment
  - Use the [`@secure()` parameter decorator](https://docs.microsoft.com/azure/azure-resource-manager/bicep/parameters#secure-parameters) **ONLY** for inputs. Never for outputs as this is not stored securely and will be stored/shown as plain-text!
  - All parameters should have a meaningful `@description `
  - Use constraints where possible, allowed values, min/max, but Use the `@allowed` decorator sparingly, as it can mistakenly result in blocking valid deployments
  - If more than one parameter decorators are present, the `@description` decorator should always come first. 
  - Place a blank line before and after each decorated parameter
  - Avoid prompting for parameter value at runtime. Parameters should either be initialized in the bicep template file and/or in the accompanying pramater file.

- `targetScope` should always be indicated at the beginning of the bicep template file

- Use variables for values that are used multiple times throughout a template or for creating complex expressions
- Remove all unused variables from all templates

- Parameters and variables should be named according to their use on specific properties where applicable.  For example a parameter used for the name property on a storageAccount would be named `storageAccountName` rather than simple `name` or `storageAccount`. A parameter used for the size of a VM should be `vmSize` rather than `size`.  As well, parameters, variables and outputs that related to a specific resource should use the resource's symbolic name as a prefix.

- All expressions, used in conditionals and loops, should be stored in a variable to simplify code readability

- For naming the deployed azure resources, we suggest following the conventions  outlined in [Azure Resource Naming Convention](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming). At a minimum we should follow the following pattern (where applicable) `<ResourceType>-<AppName>-<OptionalIdentifierOrInstance>`  where:
  - *ResourceType*: A prefix identifying the resource type, as porposed here [Azure Resource Abbreviations](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
  - *AppName*: A brief identifierof the workload/system/application name given from the end user as initialization parameter.
  - OptionalIdentifierOrInstance: anything that makes sense. 
  - For instance if you deploy resources for a workload named "*marketCampaign* and among other resources you need to deploy two web apps, one hosting the backend API and one hosting the Frontend web app then the names of the two web apps would be
    - `app-marketCampaign-backEnd`
    - `app-marketCampaign-frontEnd`
  
- Consider sanitizing names of resources to avoid deployment errors. For example consider the name limitations for a storage account (all lowercase, less than 24 characters long, no dashes etc).

  ``` bicep
  var maxStorageNameLength = 24
  var storageName = length(name) > maxStorageNameLength ? toLower(substring(replace(name, '-', ''), 0, maxStorageNameLength)) : toLower(replace(name, '-', ''))
  ```

- Use bicep **parameter** files for giving the end user the ability to paramterize the deployed resources. (i.e. to select CIDR network spaces, to select SKUs for given resources etc). As a rule of thumb, avoid using the parameter file for *naming recources*, unless there is a really good reason for that. Naming resources should be handled centrally (preferably with variables), following specific rules (as already described). Try not to overuse parameters in the template, because this creates a burden on your template users, since they need to understand the values to use for each resource, and the impact of setting each parameter. Consider using the [t-shirt sizing pattern](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/patterns-configuration-set#solution)

- Avoid using `dependsOn` in the bicep template files. Bicep is building [implicit depedencies](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/resource-dependencies#implicit-dependency) for us, as long as we follow some good practices rules. For instance a resource A depends on a Resource B (i.e. a storage Account) chances are that in resource A you need somehow to pass data of the Resource B(i.e. name, ID etc.). In that case, avoid passing the resource name as string, but pass the property Name of the resource instead (i.e. `myStorage.Name`)

``` bicep
var storageName='ttst20230301'

resource resourceModuleA 'module/someResource' = {
  name: 'myResource'

  //This is wrong, does NOT build implicit depedency
  //storageAccountName: storageName

   //This is OK, does build implicit depedency
  storageAccountName: storage.name
}

resource storage 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: storageName
  location: location
  kind: kind
  sku: {
    name: skuName
  }
  tags: union(tags, {
    displayName: storageName
  })
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
  }
}



```
 

**More details for the afforementioned guidelines you may find at:**
- [Bicep Best Practices](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/best-practices)
- [Deployment Scripts in Bicep](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deployment-script-bicep)
- [Configuration Map Pattern and t-shirt sizing](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/patterns-configuration-set): Can be used to provide a smaller set of parameters 
- [Logical Parameters](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/patterns-logical-parameter)
- [Azure Resource Naming Convention](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [Azure Resource Abbreviations](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)

### Terraform Best Practices and Conventions

- Use modules: Terraform modules allow you to reuse and share code across different projects and teams. This helps to reduce duplication of effort and increases consistency
- Use Terraform variables: Use Terraform variables to provide input values and make your code more flexible and easier to maintain.
- Use Terraform outputs: Use Terraform outputs to extract information about your infrastructure for later use.
- Use comments to explain the purpose and context of your code. This helps other people who are reviewing your code and makes it easier to maintain in the future.
- Use Terraform format: Format your Terraform code using the `terraform fmt` command to ensure consistency and readability.
- Use separate Terraform files for each resource: Terraform can manage multiple resources in a single Terraform file. However, it's better to split the resources into multiple Terraform files for better organization and maintainability.
- Check the Hashicorp [Terraform Style Convention](https://developer.hashicorp.com/terraform/language/syntax/style)
- Use [snake_case](https://en.wikipedia.org/wiki/Snake_case) (lowercase with underscore character) for all Terraform resource or object names.
- Declare all variable blocks for a module in **variables.tf**, including a description and type
- Provide no defaults defined in **variables.tf** with all variable arguments being provided in **terraform.tfvars**
- Declare all outputs in **outputs.tf**, including a description
- Modules must always include the following files, even if empty: **main.tf**, **variables.tf**, and **outputs.tf**

## Issue Tracker

> TODO: Instructions on how to use the issue tracker, including how to submit bugs and feature requests.

## Pull Request Process

> TODO: A description of the pull request process, including the criteria that pull requests will be reviewed against and the steps that will be taken to merge a pull request.
