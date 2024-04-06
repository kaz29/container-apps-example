param location string = resourceGroup().location

param logAnalyticsWorkspaceName string = 'example-log'
param logAnaliticsSku string = 'PerGB2018'
param retentionInDays int = 30

param appInsightsName string = 'example-app-insights'
param environmentName string = 'example-container-apps-env'

// Create a Log Analytics workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: any({
    retentionInDays: retentionInDays
    features: {
      searchVersion: 1
      legacy: 0
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    sku: {
      name: logAnaliticsSku
    }
  })
}

// Create an Application Insights resource
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: { 
    Application_Type: 'web'
    WorkspaceResourceId:logAnalyticsWorkspace.id
  }
}

resource environment 'Microsoft.App/managedEnvironments@2023-05-01' = {
  name: environmentName
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
    daprAIInstrumentationKey: appInsights.properties.InstrumentationKey
    zoneRedundant: false
    peerAuthentication: {
      mtls: {
        enabled: false
      }
    }
    workloadProfiles: [{
      name: 'myworkload'
      maximumCount: 10
      minimumCount: 3
      workloadProfileType: 'D4'
    }]
  }
}

