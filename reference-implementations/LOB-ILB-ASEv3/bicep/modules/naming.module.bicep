/**
 * Azure naming module - helps maintaining a consistent naming convention
 * Licensed to use under the MIT license.
 * ----------------------------------------------------------------------------
 * Module repository & documentation: https://github.com/nianton/azure-naming
 * Starter repository template:       https://github.com/nianton/bicep-starter
 * ----------------------------------------------------------------------------
 * Microsoft naming convention best practices
 * https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming
 * ----------------------------------------------------------------------------
 * Generated/built on: 2022-05-17T10:34:35.322Z
 */

 @description('Optional. It is not recommended that you use prefix by azure you should be using a suffix for your resources.')
 param prefix array = []
 
 @description('Optional. It is recommended that you specify a suffix for consistency. Please use only lowercase characters when possible.')
 param suffix array = []
 
 @description('Optional. Custom seed value for the unique string to be created -defaults to resourceGroup Id.')
 param uniqueSeed string = resourceGroup().id
 
 @description('Optional. Max length of the uniqueness suffix to be added -defaults to 4')
 param uniqueLength int = 4
 
 @description('Optional. Use dashes as separator where applicable -defaults to true')
 param useDashes bool = true
 
 @description('Optional. Create names using lowercase letters -defaults to true')
 param useLowerCase bool = true
 
 @description('Optional. Used when region abbreviation is needed (placeholder value is "**location**)')
 param location string = resourceGroup().location
 
 var uniquePart = substring(uniqueString(uniqueSeed), 0, uniqueLength)
 var delimiter = useDashes ? '-' : ''
 var locationPlaceholder = '**location**'
 var regionAbbreviations = {
     australiacentral: 'auc'
     australiacentral2: 'auc2'
     australiaeast: 'aue'
     australiasoutheast: 'ause'
     brazilsouth: 'brs'
     brazilsoutheast: 'brse'
     canadacentral: 'canc'
     canadaeast: 'cane'
     centralindia: 'cin'
     centralus: 'cus'
     centraluseuap: 'cuseuap'
     eastasia: 'ea'
     eastus: 'eus'
     eastus2: 'eus2'
     eastus2euap: 'eus2euap'
     francecentral: 'frc'
     francesouth: 'frs'
     germanynorth: 'gern'
     germanywestcentral: 'gerwc'
     japaneast: 'jae'
     japanwest: 'jaw'
     jioindiacentral: 'jioinc'
     jioindiawest: 'jioinw'
     koreacentral: 'koc'
     koreasouth: 'kors'
     northcentralus: 'ncus'
     northeurope: 'neu'
     norwayeast: 'nore'
     norwaywest: 'norw'
     southafricanorth: 'san'
     southafricawest: 'saw'
     southcentralus: 'scus'
     southeastasia: 'sea'
     southindia: 'sin'
     swedencentral: 'swc'
     switzerlandnorth: 'swn'
     switzerlandwest: 'sww'
     uaecentral: 'uaec'
     uaenorth: 'uaen'
     uksouth: 'uks'
     ukwest: 'ukw'
     westcentralus: 'wcus'
     westeurope: 'weu'
     westindia: 'win'
     westus: 'wus'
     westus2: 'wus2'
     westus3: 'wus3'
 }
 
 
 var strPrefixJoined = empty(prefix) ? '' : '${replace(replace(replace(string(prefix), '["', ''), '"]', ''), '","', delimiter)}${delimiter}'
 var strPrefixInterim = useLowerCase ? toLower(strPrefixJoined) : strPrefixJoined
 var strPrefix = replace(strPrefixInterim, locationPlaceholder, regionAbbreviations[location])
 
 var strSuffixJoined =  empty(suffix) ? '' : '${delimiter}${replace(replace(replace(string(suffix), '["', ''), '"]', ''), '","', delimiter)}'
 var strSuffixInterim = useLowerCase ? toLower(strSuffixJoined) : strSuffixJoined
 var strSuffix = replace(strSuffixInterim, locationPlaceholder, regionAbbreviations[location])
 
 var placeholder = '[****]'
 var nameTemplate = '${strPrefix}${placeholder}${strSuffix}'
 var nameUniqueTemplate = '${strPrefix}${placeholder}${strSuffix}${delimiter}${uniquePart}'
 var nameSafeTemplate = toLower(replace(nameTemplate, delimiter, ''))
 var nameUniqueSafeTemplate = toLower(replace(nameUniqueTemplate, delimiter, ''))
 
 output names object = {
   analysisServicesServer: {
     name: substring(replace(nameSafeTemplate, placeholder, 'as'), 0, min(length(replace(nameSafeTemplate, placeholder, 'as')), 63))
     nameUnique: substring(replace(nameUniqueSafeTemplate, placeholder, 'as'), 0, min(length(replace(nameUniqueSafeTemplate, placeholder, 'as')), 63))
     slug: 'as'
   }
   apiManagement: {
     name: substring(replace(nameSafeTemplate, placeholder, 'apim'), 0, min(length(replace(nameSafeTemplate, placeholder, 'apim')), 50))
     nameUnique: substring(replace(nameUniqueSafeTemplate, placeholder, 'apim'), 0, min(length(replace(nameUniqueSafeTemplate, placeholder, 'apim')), 50))
     slug: 'apim'
   }
   appConfiguration: {
     name: substring(replace(nameTemplate, placeholder, 'appcg'), 0, min(length(replace(nameTemplate, placeholder, 'appcg')), 50))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'appcg'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'appcg')), 50))
     slug: 'appcg'
   }
   appServiceEnvironment: {
     name: substring(replace(nameTemplate, placeholder, 'ase'), 0, min(length(replace(nameTemplate, placeholder, 'ase')), 36))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'ase'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'ase')), 36))
     slug: 'ase'
   }
   appServicePlan: {
     name: substring(replace(nameTemplate, placeholder, 'plan'), 0, min(length(replace(nameTemplate, placeholder, 'plan')), 40))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'plan'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'plan')), 40))
     slug: 'plan'
   }
   appService: {
     name: substring(replace(nameTemplate, placeholder, 'app'), 0, min(length(replace(nameTemplate, placeholder, 'app')), 60))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'app'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'app')), 60))
     slug: 'app'
   }
   applicationGateway: {
     name: substring(replace(nameTemplate, placeholder, 'agw'), 0, min(length(replace(nameTemplate, placeholder, 'agw')), 80))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'agw'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'agw')), 80))
     slug: 'agw'
   }
   applicationInsights: {
     name: substring(replace(nameTemplate, placeholder, 'appi'), 0, min(length(replace(nameTemplate, placeholder, 'appi')), 260))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'appi'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'appi')), 260))
     slug: 'appi'
   }
   applicationSecurityGroup: {
     name: substring(replace(nameTemplate, placeholder, 'asg'), 0, min(length(replace(nameTemplate, placeholder, 'asg')), 80))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'asg'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'asg')), 80))
     slug: 'asg'
   }
   automationAccount: {
     name: substring(replace(nameTemplate, placeholder, 'aa'), 0, min(length(replace(nameTemplate, placeholder, 'aa')), 50))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'aa'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'aa')), 50))
     slug: 'aa'
   }
   automationCertificate: {
     name: substring(replace(nameTemplate, placeholder, 'aacert'), 0, min(length(replace(nameTemplate, placeholder, 'aacert')), 128))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'aacert'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'aacert')), 128))
     slug: 'aacert'
   }
   automationCredential: {
     name: substring(replace(nameTemplate, placeholder, 'aacred'), 0, min(length(replace(nameTemplate, placeholder, 'aacred')), 128))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'aacred'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'aacred')), 128))
     slug: 'aacred'
   }
   automationRunbook: {
     name: substring(replace(nameTemplate, placeholder, 'aacred'), 0, min(length(replace(nameTemplate, placeholder, 'aacred')), 63))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'aacred'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'aacred')), 63))
     slug: 'aacred'
   }
   automationSchedule: {
     name: substring(replace(nameTemplate, placeholder, 'aasched'), 0, min(length(replace(nameTemplate, placeholder, 'aasched')), 128))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'aasched'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'aasched')), 128))
     slug: 'aasched'
   }
   automationVariable: {
     name: substring(replace(nameTemplate, placeholder, 'aavar'), 0, min(length(replace(nameTemplate, placeholder, 'aavar')), 128))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'aavar'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'aavar')), 128))
     slug: 'aavar'
   }
   availabilitySet: {
     name: substring(replace(nameTemplate, placeholder, 'avail'), 0, min(length(replace(nameTemplate, placeholder, 'avail')), 80))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'avail'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'avail')), 80))
     slug: 'avail'
   }
   bastionHost: {
     name: substring(replace(nameTemplate, placeholder, 'bas'), 0, min(length(replace(nameTemplate, placeholder, 'bas')), 80))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'bas'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'bas')), 80))
     slug: 'bas'
   }
   batchAccount: {
     name: substring(replace(nameSafeTemplate, placeholder, 'ba'), 0, min(length(replace(nameSafeTemplate, placeholder, 'ba')), 24))
     nameUnique: substring(replace(nameUniqueSafeTemplate, placeholder, 'ba'), 0, min(length(replace(nameUniqueSafeTemplate, placeholder, 'ba')), 24))
     slug: 'ba'
   }
   batchApplication: {
     name: substring(replace(nameTemplate, placeholder, 'baapp'), 0, min(length(replace(nameTemplate, placeholder, 'baapp')), 64))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'baapp'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'baapp')), 64))
     slug: 'baapp'
   }
   batchCertificate: {
     name: substring(replace(nameTemplate, placeholder, 'bacert'), 0, min(length(replace(nameTemplate, placeholder, 'bacert')), 45))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'bacert'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'bacert')), 45))
     slug: 'bacert'
   }
   batchPool: {
     name: substring(replace(nameTemplate, placeholder, 'bapool'), 0, min(length(replace(nameTemplate, placeholder, 'bapool')), 24))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'bapool'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'bapool')), 24))
     slug: 'bapool'
   }
   botChannelDirectline: {
     name: substring(replace(nameTemplate, placeholder, 'botline'), 0, min(length(replace(nameTemplate, placeholder, 'botline')), 64))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'botline'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'botline')), 64))
     slug: 'botline'
   }
   botChannelEmail: {
     name: substring(replace(nameTemplate, placeholder, 'botmail'), 0, min(length(replace(nameTemplate, placeholder, 'botmail')), 64))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'botmail'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'botmail')), 64))
     slug: 'botmail'
   }
   botChannelMsTeams: {
     name: substring(replace(nameTemplate, placeholder, 'botteams'), 0, min(length(replace(nameTemplate, placeholder, 'botteams')), 64))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'botteams'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'botteams')), 64))
     slug: 'botteams'
   }
   botChannelSlack: {
     name: substring(replace(nameTemplate, placeholder, 'botslack'), 0, min(length(replace(nameTemplate, placeholder, 'botslack')), 64))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'botslack'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'botslack')), 64))
     slug: 'botslack'
   }
   botChannelsRegistration: {
     name: substring(replace(nameTemplate, placeholder, 'botchan'), 0, min(length(replace(nameTemplate, placeholder, 'botchan')), 64))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'botchan'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'botchan')), 64))
     slug: 'botchan'
   }
   botConnection: {
     name: substring(replace(nameTemplate, placeholder, 'botcon'), 0, min(length(replace(nameTemplate, placeholder, 'botcon')), 64))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'botcon'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'botcon')), 64))
     slug: 'botcon'
   }
   botWebApp: {
     name: substring(replace(nameTemplate, placeholder, 'bot'), 0, min(length(replace(nameTemplate, placeholder, 'bot')), 64))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'bot'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'bot')), 64))
     slug: 'bot'
   }
   cdnEndpoint: {
     name: substring(replace(nameTemplate, placeholder, 'cdn'), 0, min(length(replace(nameTemplate, placeholder, 'cdn')), 50))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'cdn'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'cdn')), 50))
     slug: 'cdn'
   }
   cdnProfile: {
     name: substring(replace(nameTemplate, placeholder, 'cdnprof'), 0, min(length(replace(nameTemplate, placeholder, 'cdnprof')), 260))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'cdnprof'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'cdnprof')), 260))
     slug: 'cdnprof'
   }
   cognitiveAccount: {
     name: substring(replace(nameTemplate, placeholder, 'cog'), 0, min(length(replace(nameTemplate, placeholder, 'cog')), 64))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'cog'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'cog')), 64))
     slug: 'cog'
   }
   containerApp: {
     name: substring(replace(nameTemplate, placeholder, 'capp'), 0, min(length(replace(nameTemplate, placeholder, 'capp')), 64))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'capp'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'capp')), 64))
     slug: 'capp'
   }
   containerGroup: {
     name: substring(replace(nameTemplate, placeholder, 'cg'), 0, min(length(replace(nameTemplate, placeholder, 'cg')), 63))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'cg'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'cg')), 63))
     slug: 'cg'
   }
   containerRegistry: {
     name: substring(replace(nameSafeTemplate, placeholder, 'acr'), 0, min(length(replace(nameSafeTemplate, placeholder, 'acr')), 63))
     nameUnique: substring(replace(nameUniqueSafeTemplate, placeholder, 'acr'), 0, min(length(replace(nameUniqueSafeTemplate, placeholder, 'acr')), 63))
     slug: 'acr'
   }
   containerRegistryWebhook: {
     name: substring(replace(nameSafeTemplate, placeholder, 'crwh'), 0, min(length(replace(nameSafeTemplate, placeholder, 'crwh')), 50))
     nameUnique: substring(replace(nameUniqueSafeTemplate, placeholder, 'crwh'), 0, min(length(replace(nameUniqueSafeTemplate, placeholder, 'crwh')), 50))
     slug: 'crwh'
   }
   cosmosdbAccount: {
     name: substring(replace(nameTemplate, placeholder, 'cosmos'), 0, min(length(replace(nameTemplate, placeholder, 'cosmos')), 63))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'cosmos'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'cosmos')), 63))
     slug: 'cosmos'
   }
   customProvider: {
     name: substring(replace(nameTemplate, placeholder, 'prov'), 0, min(length(replace(nameTemplate, placeholder, 'prov')), 64))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'prov'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'prov')), 64))
     slug: 'prov'
   }
   dashboard: {
     name: substring(replace(nameTemplate, placeholder, 'dsb'), 0, min(length(replace(nameTemplate, placeholder, 'dsb')), 160))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'dsb'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'dsb')), 160))
     slug: 'dsb'
   }
   dataFactory: {
     name: substring(replace(nameTemplate, placeholder, 'adf'), 0, min(length(replace(nameTemplate, placeholder, 'adf')), 63))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'adf'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'adf')), 63))
     slug: 'adf'
   }
   dataFactoryDatasetMysql: {
     name: substring(replace(nameTemplate, placeholder, 'adfmysql'), 0, min(length(replace(nameTemplate, placeholder, 'adfmysql')), 260))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'adfmysql'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'adfmysql')), 260))
     slug: 'adfmysql'
   }
   dataFactoryDatasetPostgresql: {
     name: substring(replace(nameTemplate, placeholder, 'adfpsql'), 0, min(length(replace(nameTemplate, placeholder, 'adfpsql')), 260))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'adfpsql'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'adfpsql')), 260))
     slug: 'adfpsql'
   }
   dataFactoryDatasetSqlServerTable: {
     name: substring(replace(nameTemplate, placeholder, 'adfmssql'), 0, min(length(replace(nameTemplate, placeholder, 'adfmssql')), 260))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'adfmssql'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'adfmssql')), 260))
     slug: 'adfmssql'
   }
   dataFactoryIntegrationRuntimeManaged: {
     name: substring(replace(nameTemplate, placeholder, 'adfir'), 0, min(length(replace(nameTemplate, placeholder, 'adfir')), 63))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'adfir'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'adfir')), 63))
     slug: 'adfir'
   }
   dataFactoryLinkedServiceDataLakeStorageGen2: {
     name: substring(replace(nameTemplate, placeholder, 'adfsvst'), 0, min(length(replace(nameTemplate, placeholder, 'adfsvst')), 260))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'adfsvst'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'adfsvst')), 260))
     slug: 'adfsvst'
   }
   dataFactoryLinkedServiceKeyVault: {
     name: substring(replace(nameTemplate, placeholder, 'adfsvkv'), 0, min(length(replace(nameTemplate, placeholder, 'adfsvkv')), 260))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'adfsvkv'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'adfsvkv')), 260))
     slug: 'adfsvkv'
   }
   dataFactoryLinkedServiceMysql: {
     name: substring(replace(nameTemplate, placeholder, 'adfsvmysql'), 0, min(length(replace(nameTemplate, placeholder, 'adfsvmysql')), 260))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'adfsvmysql'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'adfsvmysql')), 260))
     slug: 'adfsvmysql'
   }
   dataFactoryLinkedServicePostgresql: {
     name: substring(replace(nameTemplate, placeholder, 'adfsvpsql'), 0, min(length(replace(nameTemplate, placeholder, 'adfsvpsql')), 260))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'adfsvpsql'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'adfsvpsql')), 260))
     slug: 'adfsvpsql'
   }
   dataFactoryLinkedServiceSqlServer: {
     name: substring(replace(nameTemplate, placeholder, 'adfsvmssql'), 0, min(length(replace(nameTemplate, placeholder, 'adfsvmssql')), 260))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'adfsvmssql'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'adfsvmssql')), 260))
     slug: 'adfsvmssql'
   }
   dataFactoryPipeline: {
     name: substring(replace(nameTemplate, placeholder, 'adfpl'), 0, min(length(replace(nameTemplate, placeholder, 'adfpl')), 260))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'adfpl'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'adfpl')), 260))
     slug: 'adfpl'
   }
   dataFactoryTriggerSchedule: {
     name: substring(replace(nameTemplate, placeholder, 'adftg'), 0, min(length(replace(nameTemplate, placeholder, 'adftg')), 260))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'adftg'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'adftg')), 260))
     slug: 'adftg'
   }
   dataLakeAnalyticsAccount: {
     name: substring(replace(nameSafeTemplate, placeholder, 'dla'), 0, min(length(replace(nameSafeTemplate, placeholder, 'dla')), 24))
     nameUnique: substring(replace(nameUniqueSafeTemplate, placeholder, 'dla'), 0, min(length(replace(nameUniqueSafeTemplate, placeholder, 'dla')), 24))
     slug: 'dla'
   }
   dataLakeAnalyticsFirewallRule: {
     name: substring(replace(nameTemplate, placeholder, 'dlfw'), 0, min(length(replace(nameTemplate, placeholder, 'dlfw')), 50))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'dlfw'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'dlfw')), 50))
     slug: 'dlfw'
   }
   dataLakeStore: {
     name: substring(replace(nameSafeTemplate, placeholder, 'dls'), 0, min(length(replace(nameSafeTemplate, placeholder, 'dls')), 24))
     nameUnique: substring(replace(nameUniqueSafeTemplate, placeholder, 'dls'), 0, min(length(replace(nameUniqueSafeTemplate, placeholder, 'dls')), 24))
     slug: 'dls'
   }
   dataLakeStoreFirewallRule: {
     name: substring(replace(nameTemplate, placeholder, 'dlsfw'), 0, min(length(replace(nameTemplate, placeholder, 'dlsfw')), 50))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'dlsfw'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'dlsfw')), 50))
     slug: 'dlsfw'
   }
   databaseMigrationProject: {
     name: substring(replace(nameTemplate, placeholder, 'migr'), 0, min(length(replace(nameTemplate, placeholder, 'migr')), 57))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'migr'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'migr')), 57))
     slug: 'migr'
   }
   databaseMigrationService: {
     name: substring(replace(nameTemplate, placeholder, 'dms'), 0, min(length(replace(nameTemplate, placeholder, 'dms')), 62))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'dms'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'dms')), 62))
     slug: 'dms'
   }
   databricksWorkspace: {
     name: substring(replace(nameTemplate, placeholder, 'dbw'), 0, min(length(replace(nameTemplate, placeholder, 'dbw')), 30))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'dbw'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'dbw')), 30))
     slug: 'dbw'
   }
   devTestLab: {
     name: substring(replace(nameTemplate, placeholder, 'lab'), 0, min(length(replace(nameTemplate, placeholder, 'lab')), 50))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'lab'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'lab')), 50))
     slug: 'lab'
   }
   devTestLinuxVirtualMachine: {
     name: substring(replace(nameTemplate, placeholder, 'labvm'), 0, min(length(replace(nameTemplate, placeholder, 'labvm')), 64))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'labvm'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'labvm')), 64))
     slug: 'labvm'
   }
   devTestWindowsVirtualMachine: {
     name: substring(replace(nameTemplate, placeholder, 'labvm'), 0, min(length(replace(nameTemplate, placeholder, 'labvm')), 15))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'labvm'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'labvm')), 15))
     slug: 'labvm'
   }
   diskEncryptionSet: {
     name: substring(replace(nameTemplate, placeholder, 'des'), 0, min(length(replace(nameTemplate, placeholder, 'des')), 80))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'des'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'des')), 80))
     slug: 'des'
   }
   dnsZone: {
     name: substring(replace(nameTemplate, placeholder, 'dns'), 0, min(length(replace(nameTemplate, placeholder, 'dns')), 63))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'dns'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'dns')), 63))
     slug: 'dns'
   }
   eventGridDomain: {
     name: substring(replace(nameTemplate, placeholder, 'egd'), 0, min(length(replace(nameTemplate, placeholder, 'egd')), 50))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'egd'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'egd')), 50))
     slug: 'egd'
   }
   eventGridDomainTopic: {
     name: substring(replace(nameTemplate, placeholder, 'egdt'), 0, min(length(replace(nameTemplate, placeholder, 'egdt')), 50))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'egdt'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'egdt')), 50))
     slug: 'egdt'
   }
   eventGridEventSubscription: {
     name: substring(replace(nameTemplate, placeholder, 'egs'), 0, min(length(replace(nameTemplate, placeholder, 'egs')), 64))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'egs'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'egs')), 64))
     slug: 'egs'
   }
   eventGridTopic: {
     name: substring(replace(nameTemplate, placeholder, 'egt'), 0, min(length(replace(nameTemplate, placeholder, 'egt')), 50))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'egt'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'egt')), 50))
     slug: 'egt'
   }
   eventHub: {
     name: substring(replace(nameTemplate, placeholder, 'evh'), 0, min(length(replace(nameTemplate, placeholder, 'evh')), 50))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'evh'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'evh')), 50))
     slug: 'evh'
   }
   eventHubAuthorizationRule: {
     name: substring(replace(nameTemplate, placeholder, 'ehar'), 0, min(length(replace(nameTemplate, placeholder, 'ehar')), 50))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'ehar'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'ehar')), 50))
     slug: 'ehar'
   }
   eventHubConsumerGroup: {
     name: substring(replace(nameTemplate, placeholder, 'ehcg'), 0, min(length(replace(nameTemplate, placeholder, 'ehcg')), 50))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'ehcg'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'ehcg')), 50))
     slug: 'ehcg'
   }
   eventHubNamespace: {
     name: substring(replace(nameTemplate, placeholder, 'ehn'), 0, min(length(replace(nameTemplate, placeholder, 'ehn')), 50))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'ehn'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'ehn')), 50))
     slug: 'ehn'
   }
   eventHubNamespaceAuthorizationRule: {
     name: substring(replace(nameTemplate, placeholder, 'ehnar'), 0, min(length(replace(nameTemplate, placeholder, 'ehnar')), 50))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'ehnar'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'ehnar')), 50))
     slug: 'ehnar'
   }
   eventHubNamespaceDisasterRecoveryConfig: {
     name: substring(replace(nameTemplate, placeholder, 'ehdr'), 0, min(length(replace(nameTemplate, placeholder, 'ehdr')), 50))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'ehdr'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'ehdr')), 50))
     slug: 'ehdr'
   }
   expressRouteCircuit: {
     name: substring(replace(nameTemplate, placeholder, 'erc'), 0, min(length(replace(nameTemplate, placeholder, 'erc')), 80))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'erc'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'erc')), 80))
     slug: 'erc'
   }
   expressRouteGateway: {
     name: substring(replace(nameTemplate, placeholder, 'ergw'), 0, min(length(replace(nameTemplate, placeholder, 'ergw')), 80))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'ergw'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'ergw')), 80))
     slug: 'ergw'
   }
   firewall: {
     name: substring(replace(nameTemplate, placeholder, 'afw'), 0, min(length(replace(nameTemplate, placeholder, 'afw')), 80))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'afw'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'afw')), 80))
     slug: 'afw'
   }
   firewallPolicy: {
     name: substring(replace(nameTemplate, placeholder, 'afwp'), 0, min(length(replace(nameTemplate, placeholder, 'afwp')), 80))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'afwp'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'afwp')), 80))
     slug: 'afwp'
   }
   frontDoor: {
     name: substring(replace(nameTemplate, placeholder, 'fd'), 0, min(length(replace(nameTemplate, placeholder, 'fd')), 64))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'fd'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'fd')), 64))
     slug: 'fd'
   }
   frontDoorFirewallPolicy: {
     name: substring(replace(nameTemplate, placeholder, 'fdfw'), 0, min(length(replace(nameTemplate, placeholder, 'fdfw')), 80))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'fdfw'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'fdfw')), 80))
     slug: 'fdfw'
   }
   functionApp: {
     name: substring(replace(nameTemplate, placeholder, 'func'), 0, min(length(replace(nameTemplate, placeholder, 'func')), 60))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'func'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'func')), 60))
     slug: 'func'
   }
   hdInsightHadoopCluster: {
     name: substring(replace(nameTemplate, placeholder, 'hadoop'), 0, min(length(replace(nameTemplate, placeholder, 'hadoop')), 59))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'hadoop'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'hadoop')), 59))
     slug: 'hadoop'
   }
   hdInsightHbaseCluster: {
     name: substring(replace(nameTemplate, placeholder, 'hbase'), 0, min(length(replace(nameTemplate, placeholder, 'hbase')), 59))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'hbase'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'hbase')), 59))
     slug: 'hbase'
   }
   hdInsightInteractiveQueryCluster: {
     name: substring(replace(nameTemplate, placeholder, 'iqr'), 0, min(length(replace(nameTemplate, placeholder, 'iqr')), 59))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'iqr'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'iqr')), 59))
     slug: 'iqr'
   }
   hdInsightKafkaCluster: {
     name: substring(replace(nameTemplate, placeholder, 'kafka'), 0, min(length(replace(nameTemplate, placeholder, 'kafka')), 59))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'kafka'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'kafka')), 59))
     slug: 'kafka'
   }
   hdInsightMlServicesCluster: {
     name: substring(replace(nameTemplate, placeholder, 'mls'), 0, min(length(replace(nameTemplate, placeholder, 'mls')), 59))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'mls'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'mls')), 59))
     slug: 'mls'
   }
   hdInsightRserverCluster: {
     name: substring(replace(nameTemplate, placeholder, 'rsv'), 0, min(length(replace(nameTemplate, placeholder, 'rsv')), 59))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'rsv'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'rsv')), 59))
     slug: 'rsv'
   }
   hdInsightSparkCluster: {
     name: substring(replace(nameTemplate, placeholder, 'spark'), 0, min(length(replace(nameTemplate, placeholder, 'spark')), 59))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'spark'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'spark')), 59))
     slug: 'spark'
   }
   hdInsightStormCluster: {
     name: substring(replace(nameTemplate, placeholder, 'storm'), 0, min(length(replace(nameTemplate, placeholder, 'storm')), 59))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'storm'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'storm')), 59))
     slug: 'storm'
   }
   image: {
     name: substring(replace(nameTemplate, placeholder, 'img'), 0, min(length(replace(nameTemplate, placeholder, 'img')), 80))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'img'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'img')), 80))
     slug: 'img'
   }
   iotCentralApplication: {
     name: substring(replace(nameTemplate, placeholder, 'iotapp'), 0, min(length(replace(nameTemplate, placeholder, 'iotapp')), 63))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'iotapp'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'iotapp')), 63))
     slug: 'iotapp'
   }
   iotHub: {
     name: substring(replace(nameTemplate, placeholder, 'iot'), 0, min(length(replace(nameTemplate, placeholder, 'iot')), 50))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'iot'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'iot')), 50))
     slug: 'iot'
   }
   iotHubConsumerGroup: {
     name: substring(replace(nameTemplate, placeholder, 'iotcg'), 0, min(length(replace(nameTemplate, placeholder, 'iotcg')), 50))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'iotcg'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'iotcg')), 50))
     slug: 'iotcg'
   }
   iotHubDps: {
     name: substring(replace(nameTemplate, placeholder, 'dps'), 0, min(length(replace(nameTemplate, placeholder, 'dps')), 64))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'dps'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'dps')), 64))
     slug: 'dps'
   }
   iotHubDpsCertificate: {
     name: substring(replace(nameTemplate, placeholder, 'dpscert'), 0, min(length(replace(nameTemplate, placeholder, 'dpscert')), 64))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'dpscert'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'dpscert')), 64))
     slug: 'dpscert'
   }
   keyVault: {
     name: substring(replace(nameTemplate, placeholder, 'kv'), 0, min(length(replace(nameTemplate, placeholder, 'kv')), 24))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'kv'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'kv')), 24))
     slug: 'kv'
   }
   keyVaultCertificate: {
     name: substring(replace(nameTemplate, placeholder, 'kvc'), 0, min(length(replace(nameTemplate, placeholder, 'kvc')), 127))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'kvc'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'kvc')), 127))
     slug: 'kvc'
   }
   keyVaultKey: {
     name: substring(replace(nameTemplate, placeholder, 'kvk'), 0, min(length(replace(nameTemplate, placeholder, 'kvk')), 127))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'kvk'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'kvk')), 127))
     slug: 'kvk'
   }
   keyVaultSecret: {
     name: substring(replace(nameTemplate, placeholder, 'kvs'), 0, min(length(replace(nameTemplate, placeholder, 'kvs')), 127))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'kvs'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'kvs')), 127))
     slug: 'kvs'
   }
   kubernetesCluster: {
     name: substring(replace(nameTemplate, placeholder, 'aks'), 0, min(length(replace(nameTemplate, placeholder, 'aks')), 63))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'aks'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'aks')), 63))
     slug: 'aks'
   }
   kustoCluster: {
     name: substring(replace(nameSafeTemplate, placeholder, 'kc'), 0, min(length(replace(nameSafeTemplate, placeholder, 'kc')), 22))
     nameUnique: substring(replace(nameUniqueSafeTemplate, placeholder, 'kc'), 0, min(length(replace(nameUniqueSafeTemplate, placeholder, 'kc')), 22))
     slug: 'kc'
   }
   kustoDatabase: {
     name: substring(replace(nameTemplate, placeholder, 'kdb'), 0, min(length(replace(nameTemplate, placeholder, 'kdb')), 260))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'kdb'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'kdb')), 260))
     slug: 'kdb'
   }
   kustoEventHubDataConnection: {
     name: substring(replace(nameTemplate, placeholder, 'kehc'), 0, min(length(replace(nameTemplate, placeholder, 'kehc')), 40))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'kehc'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'kehc')), 40))
     slug: 'kehc'
   }
   loadBalancer: {
     name: substring(replace(nameTemplate, placeholder, 'lb'), 0, min(length(replace(nameTemplate, placeholder, 'lb')), 80))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'lb'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'lb')), 80))
     slug: 'lb'
   }
   loadBalancerNatRule: {
     name: substring(replace(nameTemplate, placeholder, 'lbnatrl'), 0, min(length(replace(nameTemplate, placeholder, 'lbnatrl')), 80))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'lbnatrl'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'lbnatrl')), 80))
     slug: 'lbnatrl'
   }
   linuxVirtualMachine: {
     name: substring(replace(nameTemplate, placeholder, 'vm'), 0, min(length(replace(nameTemplate, placeholder, 'vm')), 64))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'vm'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'vm')), 64))
     slug: 'vm'
   }
   linuxVirtualMachineScaleSet: {
     name: substring(replace(nameTemplate, placeholder, 'vmss'), 0, min(length(replace(nameTemplate, placeholder, 'vmss')), 64))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'vmss'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'vmss')), 64))
     slug: 'vmss'
   }
   localNetworkGateway: {
     name: substring(replace(nameTemplate, placeholder, 'lgw'), 0, min(length(replace(nameTemplate, placeholder, 'lgw')), 80))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'lgw'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'lgw')), 80))
     slug: 'lgw'
   }
   logAnalyticsWorkspace: {
     name: substring(replace(nameTemplate, placeholder, 'log'), 0, min(length(replace(nameTemplate, placeholder, 'log')), 63))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'log'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'log')), 63))
     slug: 'log'
   }
   machineLearningWorkspace: {
     name: substring(replace(nameTemplate, placeholder, 'mlw'), 0, min(length(replace(nameTemplate, placeholder, 'mlw')), 260))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'mlw'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'mlw')), 260))
     slug: 'mlw'
   }
   managedDisk: {
     name: substring(replace(nameTemplate, placeholder, 'dsk'), 0, min(length(replace(nameTemplate, placeholder, 'dsk')), 80))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'dsk'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'dsk')), 80))
     slug: 'dsk'
   }
   mapsAccount: {
     name: substring(replace(nameTemplate, placeholder, 'map'), 0, min(length(replace(nameTemplate, placeholder, 'map')), 98))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'map'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'map')), 98))
     slug: 'map'
   }
   mariadbDatabase: {
     name: substring(replace(nameTemplate, placeholder, 'mariadb'), 0, min(length(replace(nameTemplate, placeholder, 'mariadb')), 63))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'mariadb'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'mariadb')), 63))
     slug: 'mariadb'
   }
   mariadbFirewallRule: {
     name: substring(replace(nameTemplate, placeholder, 'mariafw'), 0, min(length(replace(nameTemplate, placeholder, 'mariafw')), 128))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'mariafw'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'mariafw')), 128))
     slug: 'mariafw'
   }
   mariadbServer: {
     name: substring(replace(nameTemplate, placeholder, 'maria'), 0, min(length(replace(nameTemplate, placeholder, 'maria')), 63))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'maria'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'maria')), 63))
     slug: 'maria'
   }
   mariadbVirtualNetworkRule: {
     name: substring(replace(nameTemplate, placeholder, 'mariavn'), 0, min(length(replace(nameTemplate, placeholder, 'mariavn')), 128))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'mariavn'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'mariavn')), 128))
     slug: 'mariavn'
   }
   mssqlDatabase: {
     name: substring(replace(nameTemplate, placeholder, 'sqldb'), 0, min(length(replace(nameTemplate, placeholder, 'sqldb')), 128))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'sqldb'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'sqldb')), 128))
     slug: 'sqldb'
   }
   mssqlElasticpool: {
     name: substring(replace(nameTemplate, placeholder, 'sqlep'), 0, min(length(replace(nameTemplate, placeholder, 'sqlep')), 128))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'sqlep'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'sqlep')), 128))
     slug: 'sqlep'
   }
   mssqlServer: {
     name: substring(replace(nameTemplate, placeholder, 'sql'), 0, min(length(replace(nameTemplate, placeholder, 'sql')), 63))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'sql'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'sql')), 63))
     slug: 'sql'
   }
   mysqlDatabase: {
     name: substring(replace(nameTemplate, placeholder, 'mysqldb'), 0, min(length(replace(nameTemplate, placeholder, 'mysqldb')), 63))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'mysqldb'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'mysqldb')), 63))
     slug: 'mysqldb'
   }
   mysqlFirewallRule: {
     name: substring(replace(nameTemplate, placeholder, 'mysqlfw'), 0, min(length(replace(nameTemplate, placeholder, 'mysqlfw')), 128))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'mysqlfw'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'mysqlfw')), 128))
     slug: 'mysqlfw'
   }
   mysqlServer: {
     name: substring(replace(nameTemplate, placeholder, 'mysql'), 0, min(length(replace(nameTemplate, placeholder, 'mysql')), 63))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'mysql'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'mysql')), 63))
     slug: 'mysql'
   }
   mysqlVirtualNetworkRule: {
     name: substring(replace(nameTemplate, placeholder, 'mysqlvn'), 0, min(length(replace(nameTemplate, placeholder, 'mysqlvn')), 128))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'mysqlvn'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'mysqlvn')), 128))
     slug: 'mysqlvn'
   }
   networkInterface: {
     name: substring(replace(nameTemplate, placeholder, 'nic'), 0, min(length(replace(nameTemplate, placeholder, 'nic')), 80))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'nic'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'nic')), 80))
     slug: 'nic'
   }
   networkSecurityGroup: {
     name: substring(replace(nameTemplate, placeholder, 'nsg'), 0, min(length(replace(nameTemplate, placeholder, 'nsg')), 80))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'nsg'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'nsg')), 80))
     slug: 'nsg'
   }
   networkSecurityGroupRule: {
     name: substring(replace(nameTemplate, placeholder, 'nsgr'), 0, min(length(replace(nameTemplate, placeholder, 'nsgr')), 80))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'nsgr'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'nsgr')), 80))
     slug: 'nsgr'
   }
   networkSecurityRule: {
     name: substring(replace(nameTemplate, placeholder, 'nsgr'), 0, min(length(replace(nameTemplate, placeholder, 'nsgr')), 80))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'nsgr'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'nsgr')), 80))
     slug: 'nsgr'
   }
   networkWatcher: {
     name: substring(replace(nameTemplate, placeholder, 'nw'), 0, min(length(replace(nameTemplate, placeholder, 'nw')), 80))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'nw'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'nw')), 80))
     slug: 'nw'
   }
   notificationHub: {
     name: substring(replace(nameTemplate, placeholder, 'nh'), 0, min(length(replace(nameTemplate, placeholder, 'nh')), 260))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'nh'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'nh')), 260))
     slug: 'nh'
   }
   notificationHubAuthorizationRule: {
     name: substring(replace(nameTemplate, placeholder, 'dnsrec'), 0, min(length(replace(nameTemplate, placeholder, 'dnsrec')), 256))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'dnsrec'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'dnsrec')), 256))
     slug: 'dnsrec'
   }
   notificationHubNamespace: {
     name: substring(replace(nameTemplate, placeholder, 'dnsrec'), 0, min(length(replace(nameTemplate, placeholder, 'dnsrec')), 50))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'dnsrec'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'dnsrec')), 50))
     slug: 'dnsrec'
   }
   pointToSiteVpnGateway: {
     name: substring(replace(nameTemplate, placeholder, 'vpngw'), 0, min(length(replace(nameTemplate, placeholder, 'vpngw')), 80))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'vpngw'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'vpngw')), 80))
     slug: 'vpngw'
   }
   postgresqlDatabase: {
     name: substring(replace(nameTemplate, placeholder, 'psqldb'), 0, min(length(replace(nameTemplate, placeholder, 'psqldb')), 63))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'psqldb'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'psqldb')), 63))
     slug: 'psqldb'
   }
   postgresqlFirewallRule: {
     name: substring(replace(nameTemplate, placeholder, 'psqlfw'), 0, min(length(replace(nameTemplate, placeholder, 'psqlfw')), 128))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'psqlfw'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'psqlfw')), 128))
     slug: 'psqlfw'
   }
   postgresqlServer: {
     name: substring(replace(nameTemplate, placeholder, 'psql'), 0, min(length(replace(nameTemplate, placeholder, 'psql')), 63))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'psql'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'psql')), 63))
     slug: 'psql'
   }
   postgresqlVirtualNetworkRule: {
     name: substring(replace(nameTemplate, placeholder, 'psqlvn'), 0, min(length(replace(nameTemplate, placeholder, 'psqlvn')), 128))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'psqlvn'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'psqlvn')), 128))
     slug: 'psqlvn'
   }
   powerbiEmbedded: {
     name: substring(replace(nameTemplate, placeholder, 'pbi'), 0, min(length(replace(nameTemplate, placeholder, 'pbi')), 63))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'pbi'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'pbi')), 63))
     slug: 'pbi'
   }
   privateDnsZone: {
     name: substring(replace(nameTemplate, placeholder, 'pdns'), 0, min(length(replace(nameTemplate, placeholder, 'pdns')), 63))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'pdns'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'pdns')), 63))
     slug: 'pdns'
   }
   publicIp: {
     name: substring(replace(nameTemplate, placeholder, 'pip'), 0, min(length(replace(nameTemplate, placeholder, 'pip')), 80))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'pip'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'pip')), 80))
     slug: 'pip'
   }
   publicIpPrefix: {
     name: substring(replace(nameTemplate, placeholder, 'pippf'), 0, min(length(replace(nameTemplate, placeholder, 'pippf')), 80))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'pippf'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'pippf')), 80))
     slug: 'pippf'
   }
   redisCache: {
     name: substring(replace(nameTemplate, placeholder, 'redis'), 0, min(length(replace(nameTemplate, placeholder, 'redis')), 63))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'redis'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'redis')), 63))
     slug: 'redis'
   }
   redisFirewallRule: {
     name: substring(replace(nameSafeTemplate, placeholder, 'redisfw'), 0, min(length(replace(nameSafeTemplate, placeholder, 'redisfw')), 256))
     nameUnique: substring(replace(nameUniqueSafeTemplate, placeholder, 'redisfw'), 0, min(length(replace(nameUniqueSafeTemplate, placeholder, 'redisfw')), 256))
     slug: 'redisfw'
   }
   relayHybridConnection: {
     name: substring(replace(nameTemplate, placeholder, 'rlhc'), 0, min(length(replace(nameTemplate, placeholder, 'rlhc')), 260))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'rlhc'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'rlhc')), 260))
     slug: 'rlhc'
   }
   relayNamespace: {
     name: substring(replace(nameTemplate, placeholder, 'rln'), 0, min(length(replace(nameTemplate, placeholder, 'rln')), 50))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'rln'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'rln')), 50))
     slug: 'rln'
   }
   resourceGroup: {
     name: substring(replace(nameTemplate, placeholder, 'rg'), 0, min(length(replace(nameTemplate, placeholder, 'rg')), 90))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'rg'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'rg')), 90))
     slug: 'rg'
   }
   roleAssignment: {
     name: substring(replace(nameTemplate, placeholder, 'ra'), 0, min(length(replace(nameTemplate, placeholder, 'ra')), 64))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'ra'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'ra')), 64))
     slug: 'ra'
   }
   roleDefinition: {
     name: substring(replace(nameTemplate, placeholder, 'rd'), 0, min(length(replace(nameTemplate, placeholder, 'rd')), 64))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'rd'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'rd')), 64))
     slug: 'rd'
   }
   route: {
     name: substring(replace(nameTemplate, placeholder, 'rt'), 0, min(length(replace(nameTemplate, placeholder, 'rt')), 80))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'rt'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'rt')), 80))
     slug: 'rt'
   }
   routeTable: {
     name: substring(replace(nameTemplate, placeholder, 'route'), 0, min(length(replace(nameTemplate, placeholder, 'route')), 80))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'route'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'route')), 80))
     slug: 'route'
   }
   serviceFabricCluster: {
     name: substring(replace(nameTemplate, placeholder, 'sf'), 0, min(length(replace(nameTemplate, placeholder, 'sf')), 23))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'sf'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'sf')), 23))
     slug: 'sf'
   }
   serviceBusNamespace: {
     name: substring(replace(nameTemplate, placeholder, 'sb'), 0, min(length(replace(nameTemplate, placeholder, 'sb')), 50))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'sb'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'sb')), 50))
     slug: 'sb'
   }
   serviceBusNamespaceAuthorizationRule: {
     name: substring(replace(nameTemplate, placeholder, 'sbar'), 0, min(length(replace(nameTemplate, placeholder, 'sbar')), 50))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'sbar'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'sbar')), 50))
     slug: 'sbar'
   }
   serviceBusQueue: {
     name: substring(replace(nameTemplate, placeholder, 'sbq'), 0, min(length(replace(nameTemplate, placeholder, 'sbq')), 260))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'sbq'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'sbq')), 260))
     slug: 'sbq'
   }
   serviceBusQueueAuthorizationRule: {
     name: substring(replace(nameTemplate, placeholder, 'sbqar'), 0, min(length(replace(nameTemplate, placeholder, 'sbqar')), 50))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'sbqar'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'sbqar')), 50))
     slug: 'sbqar'
   }
   serviceBusSubscription: {
     name: substring(replace(nameTemplate, placeholder, 'sbs'), 0, min(length(replace(nameTemplate, placeholder, 'sbs')), 50))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'sbs'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'sbs')), 50))
     slug: 'sbs'
   }
   serviceBusSubscriptionRule: {
     name: substring(replace(nameTemplate, placeholder, 'sbsr'), 0, min(length(replace(nameTemplate, placeholder, 'sbsr')), 50))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'sbsr'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'sbsr')), 50))
     slug: 'sbsr'
   }
   serviceBusTopic: {
     name: substring(replace(nameTemplate, placeholder, 'sbt'), 0, min(length(replace(nameTemplate, placeholder, 'sbt')), 260))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'sbt'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'sbt')), 260))
     slug: 'sbt'
   }
   serviceBusTopicAuthorizationRule: {
     name: substring(replace(nameTemplate, placeholder, 'dnsrec'), 0, min(length(replace(nameTemplate, placeholder, 'dnsrec')), 50))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'dnsrec'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'dnsrec')), 50))
     slug: 'dnsrec'
   }
   sharedImage: {
     name: substring(replace(nameTemplate, placeholder, 'si'), 0, min(length(replace(nameTemplate, placeholder, 'si')), 80))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'si'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'si')), 80))
     slug: 'si'
   }
   sharedImageGallery: {
     name: substring(replace(nameSafeTemplate, placeholder, 'sig'), 0, min(length(replace(nameSafeTemplate, placeholder, 'sig')), 80))
     nameUnique: substring(replace(nameUniqueSafeTemplate, placeholder, 'sig'), 0, min(length(replace(nameUniqueSafeTemplate, placeholder, 'sig')), 80))
     slug: 'sig'
   }
   signalrService: {
     name: substring(replace(nameTemplate, placeholder, 'sgnlr'), 0, min(length(replace(nameTemplate, placeholder, 'sgnlr')), 63))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'sgnlr'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'sgnlr')), 63))
     slug: 'sgnlr'
   }
   snapshots: {
     name: substring(replace(nameTemplate, placeholder, 'snap'), 0, min(length(replace(nameTemplate, placeholder, 'snap')), 80))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'snap'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'snap')), 80))
     slug: 'snap'
   }
   sqlElasticpool: {
     name: substring(replace(nameTemplate, placeholder, 'sqlep'), 0, min(length(replace(nameTemplate, placeholder, 'sqlep')), 128))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'sqlep'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'sqlep')), 128))
     slug: 'sqlep'
   }
   sqlFailoverGroup: {
     name: substring(replace(nameTemplate, placeholder, 'sqlfg'), 0, min(length(replace(nameTemplate, placeholder, 'sqlfg')), 63))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'sqlfg'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'sqlfg')), 63))
     slug: 'sqlfg'
   }
   sqlFirewallRule: {
     name: substring(replace(nameTemplate, placeholder, 'sqlfw'), 0, min(length(replace(nameTemplate, placeholder, 'sqlfw')), 128))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'sqlfw'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'sqlfw')), 128))
     slug: 'sqlfw'
   }
   sqlServer: {
     name: substring(replace(nameTemplate, placeholder, 'sql'), 0, min(length(replace(nameTemplate, placeholder, 'sql')), 63))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'sql'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'sql')), 63))
     slug: 'sql'
   }
   storageAccount: {
     name: substring(replace(nameSafeTemplate, placeholder, 'st'), 0, min(length(replace(nameSafeTemplate, placeholder, 'st')), 24))
     nameUnique: substring(replace(nameUniqueSafeTemplate, placeholder, 'st'), 0, min(length(replace(nameUniqueSafeTemplate, placeholder, 'st')), 24))
     slug: 'st'
   }
   storageBlob: {
     name: substring(replace(nameTemplate, placeholder, 'blob'), 0, min(length(replace(nameTemplate, placeholder, 'blob')), 1024))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'blob'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'blob')), 1024))
     slug: 'blob'
   }
   storageContainer: {
     name: substring(replace(nameTemplate, placeholder, 'stct'), 0, min(length(replace(nameTemplate, placeholder, 'stct')), 63))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'stct'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'stct')), 63))
     slug: 'stct'
   }
   storageDataLakeGen2Filesystem: {
     name: substring(replace(nameTemplate, placeholder, 'stdl'), 0, min(length(replace(nameTemplate, placeholder, 'stdl')), 63))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'stdl'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'stdl')), 63))
     slug: 'stdl'
   }
   storageQueue: {
     name: substring(replace(nameTemplate, placeholder, 'stq'), 0, min(length(replace(nameTemplate, placeholder, 'stq')), 63))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'stq'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'stq')), 63))
     slug: 'stq'
   }
   storageShare: {
     name: substring(replace(nameTemplate, placeholder, 'sts'), 0, min(length(replace(nameTemplate, placeholder, 'sts')), 63))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'sts'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'sts')), 63))
     slug: 'sts'
   }
   storageShareDirectory: {
     name: substring(replace(nameTemplate, placeholder, 'sts'), 0, min(length(replace(nameTemplate, placeholder, 'sts')), 63))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'sts'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'sts')), 63))
     slug: 'sts'
   }
   storageTable: {
     name: substring(replace(nameTemplate, placeholder, 'stt'), 0, min(length(replace(nameTemplate, placeholder, 'stt')), 63))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'stt'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'stt')), 63))
     slug: 'stt'
   }
   streamAnalyticsFunctionJavascriptUdf: {
     name: substring(replace(nameTemplate, placeholder, 'asafunc'), 0, min(length(replace(nameTemplate, placeholder, 'asafunc')), 63))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'asafunc'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'asafunc')), 63))
     slug: 'asafunc'
   }
   streamAnalyticsJob: {
     name: substring(replace(nameTemplate, placeholder, 'asa'), 0, min(length(replace(nameTemplate, placeholder, 'asa')), 63))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'asa'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'asa')), 63))
     slug: 'asa'
   }
   streamAnalyticsOutputBlob: {
     name: substring(replace(nameTemplate, placeholder, 'asaoblob'), 0, min(length(replace(nameTemplate, placeholder, 'asaoblob')), 63))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'asaoblob'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'asaoblob')), 63))
     slug: 'asaoblob'
   }
   streamAnalyticsOutputEventHub: {
     name: substring(replace(nameTemplate, placeholder, 'asaoeh'), 0, min(length(replace(nameTemplate, placeholder, 'asaoeh')), 63))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'asaoeh'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'asaoeh')), 63))
     slug: 'asaoeh'
   }
   streamAnalyticsOutputMssql: {
     name: substring(replace(nameTemplate, placeholder, 'asaomssql'), 0, min(length(replace(nameTemplate, placeholder, 'asaomssql')), 63))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'asaomssql'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'asaomssql')), 63))
     slug: 'asaomssql'
   }
   streamAnalyticsOutputServiceBusQueue: {
     name: substring(replace(nameTemplate, placeholder, 'asaosbq'), 0, min(length(replace(nameTemplate, placeholder, 'asaosbq')), 63))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'asaosbq'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'asaosbq')), 63))
     slug: 'asaosbq'
   }
   streamAnalyticsOutputServiceBusTopic: {
     name: substring(replace(nameTemplate, placeholder, 'asaosbt'), 0, min(length(replace(nameTemplate, placeholder, 'asaosbt')), 63))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'asaosbt'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'asaosbt')), 63))
     slug: 'asaosbt'
   }
   streamAnalyticsReferenceInputBlob: {
     name: substring(replace(nameTemplate, placeholder, 'asarblob'), 0, min(length(replace(nameTemplate, placeholder, 'asarblob')), 63))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'asarblob'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'asarblob')), 63))
     slug: 'asarblob'
   }
   streamAnalyticsStreamInputBlob: {
     name: substring(replace(nameTemplate, placeholder, 'asaiblob'), 0, min(length(replace(nameTemplate, placeholder, 'asaiblob')), 63))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'asaiblob'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'asaiblob')), 63))
     slug: 'asaiblob'
   }
   streamAnalyticsStreamInputEventHub: {
     name: substring(replace(nameTemplate, placeholder, 'asaieh'), 0, min(length(replace(nameTemplate, placeholder, 'asaieh')), 63))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'asaieh'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'asaieh')), 63))
     slug: 'asaieh'
   }
   streamAnalyticsStreamInputIotHub: {
     name: substring(replace(nameTemplate, placeholder, 'asaiiot'), 0, min(length(replace(nameTemplate, placeholder, 'asaiiot')), 63))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'asaiiot'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'asaiiot')), 63))
     slug: 'asaiiot'
   }
   subnet: {
     name: substring(replace(nameTemplate, placeholder, 'snet'), 0, min(length(replace(nameTemplate, placeholder, 'snet')), 80))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'snet'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'snet')), 80))
     slug: 'snet'
   }
   templateDeployment: {
     name: substring(replace(nameTemplate, placeholder, 'deploy'), 0, min(length(replace(nameTemplate, placeholder, 'deploy')), 64))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'deploy'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'deploy')), 64))
     slug: 'deploy'
   }
   trafficManagerProfile: {
     name: substring(replace(nameTemplate, placeholder, 'traf'), 0, min(length(replace(nameTemplate, placeholder, 'traf')), 63))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'traf'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'traf')), 63))
     slug: 'traf'
   }
   virtualMachine: {
     name: substring(replace(nameTemplate, placeholder, 'vm'), 0, min(length(replace(nameTemplate, placeholder, 'vm')), 15))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'vm'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'vm')), 15))
     slug: 'vm'
   }
   virtualMachineScaleSet: {
     name: substring(replace(nameTemplate, placeholder, 'vmss'), 0, min(length(replace(nameTemplate, placeholder, 'vmss')), 15))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'vmss'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'vmss')), 15))
     slug: 'vmss'
   }
   virtualNetwork: {
     name: substring(replace(nameTemplate, placeholder, 'vnet'), 0, min(length(replace(nameTemplate, placeholder, 'vnet')), 64))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'vnet'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'vnet')), 64))
     slug: 'vnet'
   }
   virtualNetworkGateway: {
     name: substring(replace(nameTemplate, placeholder, 'vgw'), 0, min(length(replace(nameTemplate, placeholder, 'vgw')), 80))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'vgw'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'vgw')), 80))
     slug: 'vgw'
   }
   virtualNetworkPeering: {
     name: substring(replace(nameTemplate, placeholder, 'vpeer'), 0, min(length(replace(nameTemplate, placeholder, 'vpeer')), 80))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'vpeer'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'vpeer')), 80))
     slug: 'vpeer'
   }
   virtualWan: {
     name: substring(replace(nameTemplate, placeholder, 'vwan'), 0, min(length(replace(nameTemplate, placeholder, 'vwan')), 80))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'vwan'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'vwan')), 80))
     slug: 'vwan'
   }
   windowsVirtualMachine: {
     name: substring(replace(nameTemplate, placeholder, 'vm'), 0, min(length(replace(nameTemplate, placeholder, 'vm')), 15))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'vm'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'vm')), 15))
     slug: 'vm'
   }
   windowsVirtualMachineScaleSet: {
     name: substring(replace(nameTemplate, placeholder, 'vmss'), 0, min(length(replace(nameTemplate, placeholder, 'vmss')), 15))
     nameUnique: substring(replace(nameUniqueTemplate, placeholder, 'vmss'), 0, min(length(replace(nameUniqueTemplate, placeholder, 'vmss')), 15))
     slug: 'vmss'
   }
 }
 
 output regionAbbreviations object = regionAbbreviations
