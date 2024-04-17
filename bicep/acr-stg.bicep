param location string = resourceGroup().location

param acrName string = 'exampleacr'
param acrSku string = 'Standard'
param encription string = 'disabled'

module acr 'acr.bicep' = {
  name: 'example-acr'
  params: {
    location: location
    acrName: acrName
    acrSku: acrSku
    encription: encription
  }
}
