param nameSufix string = '001'
param globalRedundancy bool = true

var storageAccountName = 'patostream${nameSufix}'

var location = resourceGroup().location
// var storageSku = 'Standard_LRS' // declare variable and assign value

resource stg 'Microsoft.Storage/storageAccounts@2019-06-01' = {
    name: storageAccountName
    location: location
    kind: 'Storage'
    sku: {
        name: globalRedundancy ? 'Standard_GRS' : 'Standard_LRS' // if true --> GRS, else --> LRS
    }
}

resource blob 'Microsoft.Storage/storageAccounts/blobServices/containers@2019-06-01' = {
    name: '${stg.name}/default/logs'
    // dependsOn will be added when the template is compiled
}

output storageId string = stg.id
output computedStorageName string = stg.name
output blobEndpoint string = stg.properties.primaryEndpoints.blob