param environmentName string = 'example-container-apps-env'
param containerAppName string = 'example-app'
param location string = resourceGroup().location
param imageName string = 'example-app'
param tagName string
param acrUserName string
@secure()
param acrSecret string

param revisionSuffix string
param oldRevisionSuffix string
param isExternalIngress bool = true

@allowed([
  'multiple'
  'single'
])
param revisionMode string = 'multiple'

resource environment 'Microsoft.App/managedEnvironments@2022-03-01' existing = {
  name: environmentName
}

resource containerApp 'Microsoft.App/containerApps@2023-04-01-preview' = {
  name: containerAppName
  location: location
  properties: {
    workloadProfileName: 'Consumption'
    managedEnvironmentId: environment.id
    configuration: {
      activeRevisionsMode: revisionMode
      dapr:{
        enabled:false
      }
      ingress: {
        external: isExternalIngress
        targetPort: 80
        transport: 'auto'
        allowInsecure: false
        traffic: ((contains(revisionSuffix, oldRevisionSuffix)) ? [
          {
            weight: 100
            latestRevision: true
          }
        ] : [
          {
            weight: 0
            latestRevision: true
          }
          {
            weight: 100
            revisionName: '${containerAppName}--${oldRevisionSuffix}'
          }
        ])
      }
      secrets: [
        {
          name: 'acr-secret'
          value: acrSecret
        }
      ]
      registries: [
        {
            server: '${acrUserName}.azurecr.io'
            username: acrUserName
            passwordSecretRef: 'acr-secret'
        }
      ]
    }
    template: {
      revisionSuffix: revisionSuffix
      containers: [
        {
          image: '${acrUserName}.azurecr.io/${imageName}:${tagName}'
          name: containerAppName
          resources: {
            cpu: any('0.5')
            memory: '1Gi'
          }
        }
      ]
      scale: {
        minReplicas: 0
        maxReplicas: 5
        rules: [
          {
            name: 'http-scaling-rule'
            http: {
              metadata: {
                concurrentRequests: '60'
              }
            }
          }
        ]
      }
    }
  }
}

output fqdn string = containerApp.properties.configuration.ingress.fqdn
