# ManageVappProperty

This is a PowerCLI based library used for managing OVF properties on a virtual machine. This requires PowerCLI to be installed. Can only be used by connecting to a vCenter. You will not be able to set VM VappProperties by connecting to a standalone ESXi host.

### Workflow
1. First enable OVFTransport by using Set-VMOVFTransport
2. Once OVFTransport is enabled you can use the Set-VMOVFProperty or New-VMOVFProperty to set the appropriate properties.

### Example
```
Get-VM test-vm-ovf-property | Set-VMOVFTransport -Enable:$true
```
