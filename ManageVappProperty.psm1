#####################################################################
## Copyright 2017 Chandrashekhar Joshi
##
## Redistribution and use in source and binary forms, with or without
## modification, are permitted provided that the following conditions
## are met:
## 
## 1. Redistributions of source code must  retain the above copyright
## notice, this list of conditions and the following disclaimer.
## 
## 2. Redistributions in binary form must reproduce the above copyright
## notice, this list of conditions and the following disclaimer in the
## documentation and/or other materials provided with the distribution.
## 
## THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
## "AS IS" AND ANY EXPRESS OR  IMPLIED WARRANTIES,  INCLUDING, BUT NOT
## LIMITED TO,  THE IMPLIED WARRANTIES OF  MERCHANTABILITY AND FITNESS
## FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
## COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
## INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
## BUT  NOT  LIMITED  TO, PROCUREMENT OF SUBSTITUTE  GOODS OR SERVICES; 
## LOSS OF USE, DATA, OR  PROFITS; OR  BUSINESS  INTERRUPTION)  HOWEVER 
## CAUSED  AND  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
## LIABILITY,  OR  TORT (INCLUDING  NEGLIGENCE OR OTHERWISE) ARISING IN 
## ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
## POSSIBILITY OF SUCH DAMAGE.
#####################################################################

###############################################
#### Get Existing VM OVF Property          ####
###############################################

function  Get-VMOVFProperty {
    param(
        [parameter(
            Position=0,
            Mandatory=$true,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True)
        ][Alias('VMName')] [string]$VM
    )

    process {
        foreach ($VMInstance in $VM) {
            $VMobj = Get-VM $VMInstance

            $VMObj.ExtensionData.Config.VAppConfig.Property
        }
    }
}

###############################################
#### Clear ALL VM OVF Property             ####
###############################################

function  Clear-VMOVFProperty {
    param(
        [parameter(
            Position=0,
            Mandatory=$true,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True)
        ][Alias('VMName')] [string]$VM
    )

    process {
        foreach ($VMInstance in $VM) {
            $VMobj = Get-VM $VMInstance

            $Spec = New-Object VMware.Vim.VirtualMachineConfigSpec
            $Spec.VAppConfigRemoved = $true

            $VMObj.ExtensionData.ReconfigVM($Spec)
        }
    }
}

###############################################
#### Create New VM OVF Property            ####
###############################################

function  New-VMOVFProperty {
    param(
        [parameter(
            Position=0,
            Mandatory=$true,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True)
        ][Alias('VMName')] [string]$VM,

        [parameter(
            Mandatory=$true)
        ][Alias('OVFPropertyName')] [string]$Name,

        [parameter(
            Mandatory=$true)
        ][Alias('OVFPropertyValue')] [string]$Value,

        [parameter(
            Mandatory=$true)
        ][Alias('OVFPropertyType')] [string]$Type,

        [string]$Description
    )

    process {
        foreach ($VMInstance in $VM) {
            $VMobj = Get-VM $VMInstance

            $key = $VMObj.ExtensionData.Config.VAppConfig.Property.Count
    
            $Spec = New-Object VMware.Vim.VirtualMachineConfigSpec
            $Spec.VAppConfig = New-Object VMware.Vim.VmConfigSpec

            $PropertySpec = New-Object VMware.Vim.VAppPropertySpec
            $PropertySpec.operation = "add"
            $PropertySpec.info = New-Object VMware.Vim.VAppPropertyInfo
            $PropertySpec.info.key = $key
            $PropertySpec.info.id = $Name
            $PropertySpec.info.label = $Name
            $PropertySpec.info.type = $Type
            $PropertySpec.info.userConfigurable = $false
            $PropertySpec.info.defaultValue = $Value
            $PropertySpec.info.description = $Description
    
            $Spec.vAppConfig.property += $PropertySpec

            $VMObj.ExtensionData.ReconfigVM($Spec)
        }
    }
}

###############################################
#### Set Exisitng VM OVF Property          ####
###############################################

function  Set-VMOVFProperty {
    param(
        [parameter(
            Position=0,
            Mandatory=$true,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True)
        ][Alias('VMName')] [string]$VM,

        [parameter(
            Mandatory=$true)
        ][Alias('OVFPropertyName')] [string]$Name,

        [parameter(
            Mandatory=$true)
        ][Alias('OVFPropertyValue')] [string]$Value
    )

    process {
        foreach ($VMInstance in $VM) {
            $VMobj = Get-VM $VMInstance


            $VAppProperty = $VMobj.ExtensionData.Config.VAppConfig.Property| %{
                $Property = $_;
                if ($Property.Label -match $Name) {
                    return $Property
                }        
            }
    
            $VAppProperty.DefaultValue = $Value

            $Spec = New-Object VMware.Vim.VirtualMachineConfigSpec
            $Spec.VAppConfig = New-Object VMware.Vim.VmConfigSpec
    
            $PropertySpec = New-Object VMware.Vim.VAppPropertySpec
            $PropertySpec.Operation = "edit"
            $PropertySpec.Info = $VAppProperty  

            $Spec.VAppConfig.Property += $PropertySpec

            $VMObj.ExtensionData.ReconfigVM($Spec)
        }
    }
}

###############################################
#### Enable / Disable VM OVF Transport     ####
###############################################

function  Set-VMOVFTransport {
    param(
        [parameter(
            Position=0,
            Mandatory=$true,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True)
        ][Alias('VMName')] [string]$VM,

        [bool]$Enable = $false
    )

    process {
        foreach ($VMInstance in $VM) {
            $VMobj = Get-VM $VMInstance

            $Spec = New-Object VMware.Vim.VirtualMachineConfigSpec

            if ($Enable) {
                #Write-Host "Enabling OVF Transport"
                $Spec.VAppConfig = New-Object VMware.Vim.VmConfigSpec        
                $Spec.VAppConfig.OvfEnvironmentTransport = "com.vmware.guestInfo"      
            } else {
                #Write-Host "Disabling OVF Transport"
                $Spec.vAppConfigRemoved = $true
            }

            $VMObj.ExtensionData.ReconfigVM($Spec)
        }
    }
}
