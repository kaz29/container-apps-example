param location string = resourceGroup().location

param acrName string
param acrSku string
param encription string

resource acrResource 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: acrName
  location: location
  sku: {
    name: acrSku
  }
  properties: {
    adminUserEnabled: true
    encryption: {
      status: encription
    }
    dataEndpointEnabled: false
  }
}

output loginServer string = acrResource.properties.loginServer
