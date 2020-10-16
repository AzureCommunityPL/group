param nameSufix string = '001'
param ubuntuOSVersion string {
    default: '18.04-LTS'
    allowed: [
        '12.04.5-LTS'
        '14.04.5-LTS'
        '16.04.0-LTS'
        '18.04-LTS'
    ]
}
param adminUsername string {
    default: 'emil'
}

param authenticationType string {
    default: 'sshPublicKey'
    allowed: [
        'sshPublicKey'
        'password'
    ]
}

param adminPasswordOrKey string {
    default: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCdiZSR85ZdsHucn/0K1zH2NnRwxoB0FLpFsOkXnHRjoCm4e7+Do83nXLZPG1KzyDDEe/Sm+UgGpBhT0HvNfu0XukqNVxvReTUbHBoFwnot+KTX9jlBd6C04N9CMZ7ANwtw9KvrgtRZZD13y+Qztzbpz7tcLIrhegVsinhykkg1gGxxE4ZRgMCfd5dskrfJ+M0CZfaFGwcPP7dUKf4vYyZVEwM0ErvbhYojAtaTZLMPxUIeCuYeV2e8LstL2nN271rCcfKcFixKXVlttkSTHPSYVn/HPbTvBAap42C7zS98ooyngq4WGvx8JXrAgtugyAVK/YB/b4RHgzQgBYW3nURn lukasz@UKASZKAUNY3BC3'
}

var frontendNetworkSecurityGroupName = 'fe-nsg'

var location = resourceGroup().location

var vnetcfg = {
    name: 'vNET'
    addressSpacePrefix: '10.10.0.0/23'
    feSubnetName: 'Frontend'
    feSubnetPrefix: '10.10.0.0/24'
    beSubnetName: 'Backend'
    beSubnetPrefix: '10.10.1.0/27'
    mgmtSubnetName: 'Management'
    mgmtSubnetPrefix: '10.10.1.32/27'
}

var asfrontendcfg = {
    name: 'ASFrontend'
    platformUpdateDomainCount: 5
    platformFaultDomainCount: 3
}

var linuxConfiguration = {
    disablePasswordAuthentication: true
    ssh: {
        publicKeys: [
            {
                path: '/home/${adminUsername}/.ssh/authorized_keys'
                keyData: adminPasswordOrKey
            }
        ]
    }
}

var vmFrontend001 = {
    vmName: 'vmFe001'
    networkInterfaceName: 'fe001-nic'
    subnetRef: '${vnet.id}/subnets/${vnetcfg.feSubnetName}'
    vmSize: 'Standard_B2s'
    osDiskType: 'Standard_LRS'
}

resource vnet 'Microsoft.Network/virtualNetworks@2020-05-01' = {
    name: vnetcfg.name
    location: location
    properties: {
        addressSpace: {
            addressPrefixes: [
                vnetcfg.addressSpacePrefix
            ]
        }
        subnets: [
            {
                name: vnetcfg.feSubnetName
                properties: {
                    addressPrefix: vnetcfg.feSubnetPrefix
                }
            }
            {
                name: vnetcfg.beSubnetName
                properties: {
                    addressPrefix: vnetcfg.beSubnetPrefix
                }
            }
            {
                name: vnetcfg.mgmtSubnetName
                properties: {
                    addressPrefix: vnetcfg.mgmtSubnetPrefix
                }
            }
        ]
    }
}

resource ASFrontend 'Microsoft.Compute/availabilitySets@2020-06-01' = {
    name: asfrontendcfg.name
    location: location
    properties: {
        platformUpdateDomainCount: asfrontendcfg.platformUpdateDomainCount
        platformFaultDomainCount: asfrontendcfg.platformFaultDomainCount
    }
}

resource FrontEndpublicIP 'Microsoft.Network/publicIPAddresses@2019-02-01' = {
    name: 'fe-public-ip'
    location: location
    properties: {
        publicIPAllocationMethod: 'Static'
        publicIPAddressVersion: 'IPv4'
    }
    sku: {
        name: 'Standard'
    }
}

resource FrontendLoadBalancer 'Microsoft.Network/loadBalancers@2020-06-01' = {
    name: 'fe-lb'
    location: location
    sku: {
      name: 'Standard'
    }
    properties: {
      frontendIPConfigurations: [
        {
          name: 'frontend'
          properties: {
            publicIPAddress: {
              id: FrontEndpublicIP.id
            }
          }
        }
      ]
      backendAddressPools: [
        {
          name: 'backend'
        }
      ]
      loadBalancingRules: [
        {
          name: 'HTTPLBRule'
          properties: {
            frontendIPConfiguration: {
                id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', 'fe-lb', 'frontend')
            }
            backendAddressPool: {
                id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', 'fe-lb', 'backend')
            }
            frontendPort: 443
            backendPort: 443
            protocol: 'Tcp'
            probe: {
                id: resourceId('Microsoft.Network/loadBalancers/probes', 'fe-lb', 'probe')
            }
          }
        }
      ]
      probes: [
        {
          name: 'probe'
          properties: {
            protocol: 'Tcp'
            port: 443
          }
        }
      ]
    }
  }

// nsg - frontend



resource nsgFrontend 'Microsoft.Network/networkSecurityGroups@2019-02-01' = {
    name: frontendNetworkSecurityGroupName
    location: location
    properties: {
        securityRules: [
            {
                name: 'SSH'
                properties: {
                    priority: 1000
                    protocol: 'Tcp'
                    access: 'Allow'
                    direction: 'Inbound'
                    sourceAddressPrefix: '*'
                    sourcePortRange: '*'
                    destinationAddressPrefix: '*'
                    destinationPortRange: '22'
                }
            }
            {
                name: 'HTTPS'
                properties: {
                    priority: 1100
                    protocol: 'Tcp'
                    access: 'Allow'
                    direction: 'Inbound'
                    sourceAddressPrefix: '*'
                    sourcePortRange: '*'
                    destinationAddressPrefix: '*'
                    destinationPortRange: '443'
                }
            }
        ]
    }
}

// vm fe001 - nic
resource feNic001 'Microsoft.Network/networkInterfaces@2018-10-01' = {
    name: vmFrontend001.networkInterfaceName
    location: location
    properties: {
        ipConfigurations: [
            {
                name: 'ipconfig1'
                properties: {
                    subnet: {
                        id: vmFrontend001.subnetRef
                    }
                    privateIPAllocationMethod: 'Dynamic'
                    loadBalancerBackendAddressPools: [
                        {
                          id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', 'fe-lb', 'backend')
                        }
                      ]
                }
            }
        ]
        networkSecurityGroup: {
            id: nsgFrontend.id
        }
    }
}

resource vmFe001 'Microsoft.Compute/virtualMachines@2019-03-01' = {
    name: vmFrontend001.vmName
    location: location
    properties: {
        hardwareProfile: {
            vmSize: vmFrontend001.vmSize
        }
        storageProfile: {
            osDisk: {
                createOption: 'FromImage'
                managedDisk: {
                    storageAccountType: vmFrontend001.osDiskType
                }
            }
            imageReference: {
                publisher: 'Canonical'
                offer: 'UbuntuServer'
                sku: ubuntuOSVersion
                version: 'latest'
            }
        }
        networkProfile: {
            networkInterfaces: [
                {
                    id: feNic001.id
                }
            ]
        }
        osProfile: {
            computerName: vmFrontend001.vmName
            adminUsername: adminUsername
            adminPassword: adminPasswordOrKey
            linuxConfiguration: any(authenticationType == 'password' ? null : linuxConfiguration) // TODO: workaround for https://github.com/Azure/bicep/issues/449
        }
    }
}